-- test_present_pmus.lua
package.path = package.path..";".."../?.lua"

local fun = require("fun")()
local pmu = require("pmu")
local pfm = require("pfmlib")

each(print, map(function(id) return id,  pfm.EventSources[id] end, pmu:ids()))


