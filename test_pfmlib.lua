local ffi = require("ffi")
local pfm = require("pfmlib");

print("pfm VERSION: ",pfm.GetVersion());

local function listEventSources()
	for i=ffi.C.PFM_PMU_NONE, ffi.C.PFM_PMU_MAX-1 do
		local value = rawget(pfm.EventSources, i);
		print(i, value);
	end
end

-- listEventSources();
