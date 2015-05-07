package.path = package.path..";".."../?.lua"

local ffi = require("ffi");
local bit = require("bit")
local bor = bit.bor;
local band = bit.band;

local pfm = require("pfmlib");
local common = require("test_common")
local pmuevent = require("pmuevent")
local fun = require("fun")()
local PMU = require("pmu")

common.appendDict(_G, common)
common.appendDict(_G, pfm)


local function main()
	local i, j, ret;
	local total_supported_events = 0;
	local total_available_events = 0;

	-- if nothing specified, use PERF_EVENT
	local peventpmu = PMU(ffi.C.PFM_PMU_PERF_EVENT);

	local eargs = {};
	if #arg < 1  then
		if peventpmu.isPresent then
			eargs[1] = "PERF_COUNT_HW_CPU_CYCLES";
			eargs[2] = "PERF_COUNT_HW_INSTRUCTIONS";
		end
	else 
		for idx, item in ipairs(arg) do
			eargs[idx] = item;
		end
	end


	for _, pmuname in ipairs(eargs) do

		local evt = pmuevent(pmuname);

--[[
		-- which PMU did the event belong to?
		local pinfo = ffi.new("pfm_pmu_info_t");
		ret = pfm.Lib.pfm_get_pmu_info(info.pmu, pinfo);
		if ret ~= pfm.PFM_SUCCESS then
			error(1, "cannot get PMU info: %s", pfm_strerror(ret));
			return 1;
		end
--]]
		printf("=====================\n")
		printf("Requested Event: %s\n", pmuname);
		printf("Actual    Event: %s\n", evt.fstr);
		printf("Name           : %s\n", evt.name);
		printf("Description    : %s\n", evt.desc);
		printf("Equivalent     : %s\n", evt.equiv)
--		printf("PMU            : %s\n", ffi.string(pinfo.desc));
		printf("SIZE           : %d\n", tonumber(evt.size));
		printf("IDX            : %d\n", evt.idx);
		printf("DType          : %d\n", evt.dtype);
		--printf("DType          : %s\n", evt.dtype);
		printf("N Attributes   : %d\n", evt.nattrs);
		printf("Count          : %d\n", evt.count);
		printf("Codes          :\n");
		each(print, evt.codes)

	end


	return 0;
end

main()
