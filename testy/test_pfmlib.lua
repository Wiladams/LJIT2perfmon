package.path = package.path..";".."../?.lua"

local ffi = require("ffi")
local pfm = require("pfmlib");
local common = require("test_common")



common.printDict("==== pfmlib Dict ====", pfm)
print("pfm VERSION: ",pfm.GetVersion());

local function listEventSources()
	for i=ffi.C.PFM_PMU_NONE, ffi.C.PFM_PMU_MAX-1 do
		local value = rawget(pfm.EventSources, i);
		print(i, value);
	end
end

-- listEventSources();
