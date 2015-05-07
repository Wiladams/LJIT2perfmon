local ffi = require("ffi")
local bit = require("bit")
local lshift, rshift, band, bor, bnot = bit.lshift, bit.rshift, bit.band, bit.bor, bit.bnot

ffi.cdef[[
void *malloc(size_t size);
void * calloc(size_t nelem, size_t size);
void free(void *);
]]

local exports = {}

local function appendDict(dst, src, level)
	level = level or 0
	for k,v in pairs(src) do
		if level > 0 then
			appendDict(dst, v, level-1)
		else
			dst[k] = v;
		end
	end
	return dst;
end

local function printDict(dict, title)
	if title then print(title) end
	
	for k,v in pairs(dict) do
		print(k,v)
	end
end

local function printf(format, ...)
	io.write(string.format(format,...));
end

local function errx(code, format, ...)
	io.write(string.format(format,...))
	error(code)
end

--
-- Reference
-- http://stackoverflow.com/questions/24089751/bit-field-extract-with-struct-in-c
--
-- Need a way to extract bit fields from a uint64_t based number
--
local function extractBitField64(inField, offset, width)

    local bitMask;	-- uint64_t
    local outField;	-- uint64_t

    if (offset+width) == 64 then 
        bitMask = lshift(0xFFFFFFFFFFFFFFFFULL, offset);
    else 
      --Just keep the filed needs to be extrated
      	local lpart = lshift(0xFFFFFFFFFFFFFFFFULL,offset);
      	local rpart = lshift(0xFFFFFFFFFFFFFFFFULL,(offset+width))
      	local diffpart = lpart - rpart

      	print("LPART: ", lpart)
      	print("RPART: ", rpart)
      	print("DIFF: ", diffpart)

        bitMask = bnot(diffpart);  
    end
    print("BITMASK: ", bitMask)

    -- Move to the right most field to be calculated
    outField = rshift(band(inField, bitMask), offset);

    return outField;
end

function extractbits(src, lowbit, bitcount)
	lowbit = lowbit or 0
	bitcount = bitcount or 32

	local value = 0
	for i=0,bitcount-1 do
		value = bor(value, band(src, 2^(lowbit+i)))
	end

	return rshift(value,lowbit)
end



exports.appendDict = appendDict;
exports.errx = errx;
exports.extractbits = extractbits;
exports.printDict = printDict;
exports.printf = printf;


return exports
