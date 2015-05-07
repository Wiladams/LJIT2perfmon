-- eventattribute.lua
local ffi = require("ffi")
local pfm = require("pfmlib")
local bit = require("bit")
local bor = bit.bor;
local band = bit.band;

local EventAttribute = {}
setmetatable(EventAttribute, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local EventAttribute_mt = {
	__index = EventAttribute;

	__tostring = function(self)
		local res = {}
		local um = 0;
		local mod = 0;
		local src = pfm.ControlSources[self.ctrl];

		if self.type == ffi.C.PFM_ATTR_UMASK then
			--if (!match_ufilters(&ainfo))
			--	continue;

			table.insert(res, string.format("%s = {Umask=%02u, code=0x%02d, src='%s', ",
				self.name, 
				um,
				tonumber(self.code),
				src));


			--table.insert(res, string.format(self:flagsToString()));
			--table.insert(res, ',');

			if (self.equiv ~= nil) then
				table.insert(res, string.format(" alias='%s'", self.equiv));
			else
				table.insert(res, string.format(" desc='%s'", self.desc));
			end
			
			table.insert(res, "};");
			um = um+1;

		elseif self.type == ffi.C.PFM_ATTR_MOD_BOOL then
			table.insert(res, string.format("%s = {Modif=%02u , code=0x%02d , src='%s' , desc='%s', kind ='bool'};", self.name, mod, tonumber(self.code), src, self.desc));
			--mod++;
		elseif self.type == ffi.C.PFM_ATTR_MOD_INTEGER then
			table.insert(res, string.format("%s = {Modif=%02u , code=0x%02d , src='%s' , desc='%s', kind = 'int'};", self.name,mod, tonumber(self.code), src, self.desc));
			--mod++;
		else
			table.insert(res, string.format("%s = {Attr=%02u  , code=0x%02d , src='%s' , desc='%s'};", self.name,self.idx, tonumber(self.code), src, self.desc));
		end

		return table.concat(res)
	end;
}


function EventAttribute.init(self, ainfo)
	local defaultString = nil;
	if ainfo.defaults.dfl_str ~= nil then
		defaultString = ffi.string(ainfo.defaults.dfl_str);
	end
	local obj = {
		name = ffi.string(ainfo.name);
		desc = ffi.string(ainfo.desc);
		--equiv = ffi.string(ainfo.equiv);
		size = ainfo.size;
		code = ainfo.code;
		["type"] = ainfo.type;
		idx = ainfo.idx;
		ctrl = tonumber(ainfo.ctrl);
		isDefaultUMask = ainfo.flags.is_dfl > 0;
		isPrecise = ainfo.flags.is_precise > 0;
		defaultVal64 = ainfo.defaults.dfl_val64;
		defaultString = defaultString;
		defaultInt = ainfo.defaults.dfl_int;
	}
	setmetatable(obj, EventAttribute_mt);

	return obj;
end

function EventAttribute.create(self, idx,  attridx)
	local ainfo = ffi.new("pfm_event_attr_info_t");
	local ret = pfm.Lib.pfm_get_event_attr_info(idx, attridx, ffi.C.PFM_OS_NONE, ainfo);
	if ret ~= pfm.PFM_SUCCESS then
		--error(string.format("cannot retrieve event attribute info: %s", pfm.GetErrorString(ret)));
		return nil;
	end
	return self:init(ainfo)
end

function EventAttribute.flagsToString(self)
	local res = {}
	local n = 0;

	if (self.isDefault) then
		table.insert(res, "[default] ");
		n = n + 1;
	end

	if (self.isPrecise) then
		table.insert(res, "[precise] ");
		n = n +1;
	end

	if (0 == n) then
		table.insert(res, "NONE ");
	end

	return table.concat(res);
end

return EventAttribute;

--[[
		ret = pfm_get_event_attr_info(info->idx, i, options.os, &ainfo);
		if (ret != PFM_SUCCESS)
			errx(1, "cannot retrieve event %s attribute info: %s", info->name, pfm_strerror(ret));

		if (ainfo.ctrl >= PFM_ATTR_CTRL_MAX) {
			warnx("event: %s has unsupported attribute source %d", info->name, ainfo.ctrl);
			ainfo.ctrl = PFM_ATTR_CTRL_UNKNOWN;
		}
		src = srcs[ainfo.ctrl];
		switch(ainfo.type) {
		case PFM_ATTR_UMASK:
			if (!match_ufilters(&ainfo))
				continue;

			printf("Umask-%02u : 0x%02"PRIx64" : %s : [%s] : ",
				um,
				ainfo.code,
				src,
				ainfo.name);

			print_attr_flags(&ainfo);

			putchar(':');

			if (ainfo.equiv)
				printf(" Alias to %s", ainfo.equiv);
			else
				printf(" %s", ainfo.desc);

			putchar('\n');
			um++;
			break;
		case PFM_ATTR_MOD_BOOL:
			printf("Modif-%02u : 0x%02"PRIx64" : %s : [%s] : %s (boolean)\n", mod, ainfo.code, src, ainfo.name, ainfo.desc);
			mod++;
			break;
		case PFM_ATTR_MOD_INTEGER:
			printf("Modif-%02u : 0x%02"PRIx64" : %s : [%s] : %s (integer)\n", mod, ainfo.code, src, ainfo.name, ainfo.desc);
			mod++;
			break;
		default:
			printf("Attr-%02u  : 0x%02"PRIx64" : %s : [%s] : %s\n", i, ainfo.code, ainfo.name, src, ainfo.desc);
		}
	}
--]]