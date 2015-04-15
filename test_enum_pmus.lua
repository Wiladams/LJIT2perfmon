local ffi = require("ffi")
local pfm = require("pfmlib");


local function printPMU(pmuinfo)
	print("==== PMU Info ====");
	print(string.format("%15s %s", "PMU", pmuinfo.pmu));
	print(string.format("%15s %s", "name", pmuinfo.name));
	print(string.format("%15s %s", "description", pmuinfo.desc));
	print(string.format("%15s %s", "type", pmuinfo.type));
	print(string.format("%15s %d", "nevents", pmuinfo.nevents));
	print(string.format("%15s %d", "first_event", pmuinfo.first_event));
	print(string.format("%15s %d", "max_encoding", pmuinfo.max_encoding));
	print(string.format("%15s %d", "num_cntrs", pmuinfo.num_cntrs));
	print(string.format("%15s %d", "num_fixed_cntrs", pmuinfo.num_fixed_cntrs));
	print(string.format("%15s %d", "is_present", pmuinfo.is_present));
	print(string.format("%15s %d", "is_dfl", pmuinfo.is_dfl));
end

local function supportedPMUs()
	for i=ffi.C.PFM_PMU_NONE, ffi.C.PFM_PMU_MAX-1 do
		local info,err = pfm.GetPMUInfo(i);
		if info and info.is_present > 0 then
			printPMU(info);
		end
	end
end

supportedPMUs();
