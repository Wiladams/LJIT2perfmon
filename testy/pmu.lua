-- pmu.lua
local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor;
local band = bit.band;

local pfm = require("pfmlib");
local fun = require("fun")()
local pmuevent = require("pmuevent")
local common = require("test_common")


local PMU = {}
setmetatable(PMU, {
	__call = function(self, ...)
		return self:create(...)
	end,
});

local PMU_mt = {
	__index = PMU;
	__tostring = function(self)
		local res = {}
		local present = "false";
		if self.isPresent then present = 'true' end;
		local def = "false"
		if self.isDefault then def = 'true' end;
		local name = self.name:gsub('-','_')

		table.insert(res, string.format("%s = {name='%s', desc='%s', id=%d, type='%s', isPresent=%s, isDefault=%s, nevents=%d, events={",
			pfm.EventSources[self.id],
			name, 
			self.desc, 
			self.id,
			self.type,
			present,
			def,
			self.nevents));

		each(function(eventinfo) 
			table.insert(res, "\n");
			table.insert(res, tostring(eventinfo)) 
			end, 
			self:events());
		table.insert(res, "\n  }\n};")
		return table.concat(res);
	end;
}


function PMU.init(self, pinfo)
	local name = nil;
	local desc = nil;

	if pinfo.name ~= nil then
		name = ffi.string(pinfo.name)
	end

	if pinfo.desc ~= nil then
		desc = ffi.string(pinfo.desc)
	end


	local obj = {
		name = name;
		desc = desc;
		id = tonumber(pinfo.pmu);
		["type"] = pfm.PMUTypes[tonumber(pinfo.type)];
		nevents = pinfo.nevents;
		firstEvent = pinfo.first_event;
		maxEncoding = pinfo.max_encoding;
		numCounters = pinfo.num_cntrs;
		numFixedCounters = pinfo.num_fixed_cntrs;
		isPresent = pinfo.flags.is_present>0;
		isDefault = pinfo.flags.is_dfl > 0;

	}
	setmetatable(obj, PMU_mt);
	return obj;
end

function PMU.create(self, pmuid)
	if not pmuid or type(pmuid) ~= "number" then
		return nil;
	end

	local pinfo = ffi.new("pfm_pmu_info_t");
	pinfo.size = ffi.sizeof(pinfo);
	local ret = pfm.Lib.pfm_get_pmu_info(pmuid, pinfo);
	if (ret ~= pfm.PFM_SUCCESS) then
		return nil;
	end

	return self:init(pinfo)
end

-- an iterator over the PMU IDs
function PMU.ids(self)
	return fun.range(0, ffi.C.PFM_PMU_MAX)
--[[
	local function pmuid_gen(param, state)
		if state < ffi.C.PFM_PMU_MAX then
			return state+1, state;
		end
		return nil;
	end

	return pmuid_gen, nil, ffi.C.PFM_PMU_NONE
--]]
end

function PMU.supportedPMUs(self)
	local function supported_pmu_gen(param, state)
		while (state < ffi.C.PFM_PMU_MAX) do
			local pmu = PMU(state)
			if pmu ~= nil then
				return state+1, pmu
			end
			state = state + 1;
		end
		
		return nil
	end

	return supported_pmu_gen, nil, ffi.C.PFM_PMU_NONE
end

function PMU.eventIDs(self)
	local function event_id_gen(param, currentEvent)
		if currentEvent == -1 then
			return nil;
		end

		local nextEvent = pfm.Lib.pfm_get_event_next(currentEvent)
		return nextEvent, currentEvent
	end

	return event_id_gen, nil, self.firstEvent;
end

function PMU.events(self)
--[[
	local function getEvent(eventid)
		local info = ffi.new("pfm_event_info_t");
		local os = ffi.C.PFM_OS_NONE;
		
		local ret = pfm.Lib.pfm_get_event_info(eventid, os, info);
		if (ret ~= pfm.PFM_SUCCESS) then
			error(1, string.format("cannot get event info: %s", pfm.Lib.pfm_strerror(ret)));
		end
		local evtinfo = {}
		pmuevent.event_info_TO_Table(evtinfo, info)

		return evtinfo;
	end
--]]
	return map(function(id) return pmuevent(id) end, self:eventIDs())
end
--[[
			if (regexec(preg, fullname, 0, NULL, 0) == 0) {
				if (options.compact)
					if (options.combo)
						show_event_info_combo(&info);
					else
						show_event_info_compact(&info);
				else
					show_event_info(&info);
				match++;
			}
--]]

return PMU
