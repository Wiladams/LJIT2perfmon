-- test_enumpmus.lua
package.path = package.path..";".."../?.lua"

--[[
	A filter iterator. 
	It's fed a pmu, and if the pmu is present, it
	will be passed along.  If not, it will be dropped.
--]]

local function ispresent(pmu)
	return pmu.is_present > 0
end


return ispresent
