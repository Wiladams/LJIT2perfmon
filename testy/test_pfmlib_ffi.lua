package.path = package.path..";".."../?.lua"

local ffi = require("ffi")
local pfm_ffi = require("pfmlib_ffi")

local function printDict(title, dict)
	print(title)
	for k,v in pairs(dict) do
		print(k,v)
	end
end

print("PATH: ", package.path)
printDict("pfm_ffi", pfm_ffi)


local version = pfm_ffi.Lib.pfm_get_version()

print("pfm VERSION: ",version);


