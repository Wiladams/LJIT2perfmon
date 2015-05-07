-- pmuevent.lua
local ffi = require("ffi")
local pfm = require("pfmlib")
local bit = require("bit")
local bor = bit.bor;
local band = bit.band;
local EventAttribute = require("eventattribute")
local fun = require("fun")

--[[		
		/*
		 * extract raw event encoding
		 *
		 * For perf_event encoding, use
		 * #include <perfmon/pfmlib_perf_event.h>
		 * and the function:
		 * pfm_get_perf_event_encoding()
		 */
--]]

--[[
typedef struct {
	const char		*name;	/* event name */
	const char		*desc;	/* event description */
	const char		*equiv;	/* event is equivalent to */
	size_t			size;	/* struct sizeof */
	uint64_t		code;	/* event raw code (not encoding) */
	pfm_pmu_t		pmu;	/* which PMU */
	pfm_dtype_t		dtype;	/* data type of event value */
	int			idx;	/* unique event identifier */
	int			nattrs;	/* number of attributes */
	int			reserved; /* for future use */
	struct {
		unsigned int	is_precise:1;	/* precise sampling (Intel X86=PEBS) */
		unsigned int	reserved_bits:31;
	} flags;
} pfm_event_info_t;
--]]

local PMUEvent = {}
setmetatable(PMUEvent, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local PMUEvent_mt = {
	__index = PMUEvent;

	__tostring = function(self)

		local precise = "false"
		if self.isPrecise then precise = true; end
		local def = "false"
		if self.isDefault then def = "true" end
		local name = self.name:gsub('-','_');

		res = {}
		table.insert(res, string.format("%s = {\n  desc='%s', \n  rawcode = 0x%x, \n  isPrecise=%s, \n  isDefault=%s, \n  nattrs=%d, \n  attributes={\n",
			name,
			self.desc,
			tonumber(self.rawcode),
			precise,
			def,
			self.nattrs));

		fun.each(function(attr) 
			table.insert(res, string.format("    %s", tostring(attr)))
			table.insert(res, '\n');
			end, self:attributes());

		table.insert(res,"  }\n};")

		return table.concat(res);
	end;

}

-- extract raw event encodings for a particular PMU
local function pmu_encode_arg_TO_PMUEvent(event)
	local fstr = nil;
	if event.fstr ~= nil and event.fstr[0] ~= nil then
		fstr = ffi.string(event.fstr[0])
	end
	local codes = {}
	for idx=1,event.count do
		table.insert(codes, event.codes[idx-1])
	end

	local obj = {
		fstr = fstr;
		size = event.size;
		count = event.count;
		idx = event.idx;
		codes = codes;
	}

	return obj;
end

local function getOSEvent(eventname)
	local e = ffi.new("pfm_pmu_encode_arg_t");
	local fqstr = ffi.new("char *[1]")
	
	e.fstr = fqstr;
	local flags = bor(pfm.PFM_PLM0,pfm.PFM_PLM3);
	local ret = pfm.Lib.pfm_get_os_event_encoding(eventname, 
			flags, 
			ffi.C.PFM_OS_NONE, 
			e);

	if ret ~= pfm.PFM_SUCCESS then
			if ret == pfm.PFM_ERR_TOOSMALL then
--[[			
				free(e.codes);
				e.codes = NULL;
				e.count = 0;
				free(fqstr);
				continue;
--]]			
			end

		if ret == pfm.PFM_ERR_NOTFOUND and eventname:find("::") then
			error(string.format("%s: try setting LIBPFM_ENCODE_INACTIVE=1", pfm.GetErrorString(ret)));
		end

		local strerror = ffi.string(pfm.Lib.pfm_strerror(ret));
		error(string.format("cannot encode event: %s: %s", eventname, strerror));
	end
	
	local evt = pmu_encode_arg_TO_PMUEvent(e)

	--ffi.C.free(fqstr[0]);
	--ffi.C.free(e.codes)

	return evt;
end


function PMUEvent.event_info_TO_Table(evt, info)
	-- have the info, so fill in the event table
	evt.name = ffi.string(info.name);
	evt.desc = ffi.string(info.desc);
	if info.equiv ~= nil then
		evt.equiv = ffi.string(info.equiv)
	end
	evt.rawcode = info.code;
	evt.pmuid = info.pmu;
	evt.dtype = tonumber(info.dtype);
	evt.idx = info.idx;
	evt.nattrs = info.nattrs;
	evt.isPrecise = info.flags.is_precise > 0
end

function getEventInfo(idx)
	local info = ffi.new("pfm_event_info_t");
	local ret = pfm.Lib.pfm_get_event_info(idx, ffi.C.PFM_OS_NONE, info);
	if ret ~= pfm.PFM_SUCCESS then
		error(string.format("cannot get event info: %s", pfm_strerror(ret)));
		return 1;
	end

	return info;
end

function PMUEvent.init(self, obj)
	obj = obj or {}
	setmetatable(obj, PMUEvent_mt);

	return obj;
end

function PMUEvent.create(self, identity)
	local idx = nil;

	if type(identity) == "string" then
		local obj = getOSEvent(identity)
		idx = obj.idx;
	elseif type(identity) ~= "number" then
		return nil;
	end

	idx = identity;

	local info = getEventInfo(idx)
	local obj = {}
	PMUEvent.event_info_TO_Table(obj, info)

	return self:init(obj)
end

local function nil_gen(param, state)
    return nil
end

function PMUEvent.attributeIDs(self)
	if self.nattrs > 0 then
		return fun.range(0, self.nattrs-1)
	end
	
	return nil_gen, nil, 0;

--[[
	local function attribute_id_gen(param, state)
		if state < self.nattrs then
			return state+1, state;
		end

		return nil;
	end

	return attribute_id_gen, nil, 0
--]]
end

function PMUEvent.attributes(self)
	return map(function(id) return EventAttribute(self.idx, id) end, self:attributeIDs())
end

return PMUEvent;
