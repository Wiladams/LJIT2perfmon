package.path = package.path..";".."../?.lua"
local ffi = require("ffi")
local bit = require("bit")
local striter = require("striter")
local fun = require("fun")()
local common = require("test_common")
local pfm = require("pfmlib")
local shared = require("shared")

local function test_functional()

	local function num_gen(param, state)
		state = state + 1;
		return state, state;
	end

	local function generateNumbers()
		return num_gen, nil, -0
	end

	--each(print, generateNumbers())
	each(print, take(5, generateNumbers()))

end

-- generate space delimited values
local SPACE = string.byte(' ')
local TAB = string.byte('\t')
local CR = string.byte('\r')
local LF = string.byte('\n')
local DASH  = string.byte('-')

local function isspace(achar)
	return achar == SPACE or achar == TAB or achar == CR or achar == LF
end

-- given a string with space delimited entities
-- feed out individual strings in the form of pointer, len
-- this routine does not deal with quoted text
local function space_delim_gen(str, idx)
	local len = 0;

	-- skip leading whitespace
	while idx < #str do
		if not isspace(ffi.cast("const char *", str)[idx]) then
			break;
		end

		idx = idx + 1;
	end

	-- Assume we've reached the end, or we're now sitting
	-- on a non-whitespace character
	while idx+len < #str do
		if not isspace(ffi.cast("const char *", str)[idx + len])  then
			len = len + 1;
		else
			break
		end
	end
	
	if len == 0 then
		return nil;
	end

	return idx + len + 1, ffi.cast("const char *", str)+idx, len
end


local function spaceiter(str)
	return space_delim_gen, str, 0
end

-- given a list of space delimited values (such as command line arguments)
-- return a table which contains an entry for each of the values
local function splitCommandLine(cmdline)
	local args = {}

	local function addToTable(str)
		table.insert(args, str)
	end

	each(addToTable,  map(function(ptr,len) return ffi.string(ptr,len) end, spaceiter(cmdline)))

	return args;
end

-- given a command line and the element specification
-- create a table with the arguments matched according
-- to the element spec
-- ignore items that aren't in the elemspec
local function parseCommandLine(cmdline, optstring)
	local args = splitCommandLine(cmdline);
	each(print, args)

	-- go through the commands, looking to see if they're in the optstring
	for idx = 1,#args do
		if string.byte(args[idx]:sub(1,1)) == DASH then
			idx = idx+1
			
		end
		idx = idx + 1;
	end
end

local function test_strings()
	local cmdline = "-h -f  filename.txt -o outputfile -Q -S"
	local args = splitCommandLine(cmdline);

	each(print, args)
end

local function test_parse()
	local cmdline = "-h -f  filename.txt -o outputfile -Q -S"
	local commands = parseCommandLine(cmdline, "hf:o:QST");
end



--each(print, range(0, ffi.C.PFM_PMU_MAX))

--each(print, range(0,0))

local function test_64_bit_extract()
	local u64 = 0xf000000000000000ULL;
	print(u64)
	local extract = common.extractbits(u64,62,2)

	print("Extract: ",extract)
end

local function test_setbits()
	print("==== test_setbits ====")
	local u64 = 0xffeeddffaaccee00ULL;
	local value = 2;
	local newvalue= shared.setbits(u64, 24, 8, value)
	print("OLD: ", u64)
	print("NEW: ", newvalue)

	local extract = common.extractbits(newvalue,24,8)

	print("Extract: ",extract)

end

--test_64_bit_extract()
test_setbits();
--test_strings();
--test_functional();
--test_parse();
