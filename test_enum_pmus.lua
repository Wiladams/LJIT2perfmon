local ffi = require("ffi")
local pfm = require("pfmlib");


local function supportedPMUs()
	for i=ffi.C.PFM_PMU_NONE, ffi.C.PFM_PMU_MAX-1 do
		local info,err = pfm.GetPMUInfo(i);
		if info and info[0].flags.is_present > 0 then
			print(i, pfm.EventSources[i], err);
		end
	end
end

supportedPMUs();
