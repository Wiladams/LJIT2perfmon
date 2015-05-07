-- test_present_pmus.lua
package.path = package.path..";".."../?.lua"

local ffi = require("ffi")
local fun = require("fun")
local common = require("test_common")
local fun = require("fun")()
local PMU = require("pmu")
local pfm = require("pfmlib")


-- A few different ways of iterating over the set
-- take the first one
--each(print, take_n(2, PMU:supportedPMUs()))

-- print all supported PMUs
--each(print, PMU:supportedPMUs())

-- print only the ones that are present
each(print, filter(function(pmu) return pmu.isPresent end, PMU:supportedPMUs()))


--local src = "cool-kid"
--print(src:gsub('-','_'))