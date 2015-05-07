-- shared.lua
local bit = require("bit")
local band, bor, lshift, rshift, bnot = bit.band, bit.bor, bit.lshift, bit.rshift, bit.bnot

local exports = {}

-- extract a number from a subsequence of bits 
-- in a 64-bit value
function exports.extractbits64(src, lowbit, bitcount)
	-- create a mask which matches the desired range
	-- of bits
	local mask = 0xffffffffffffffffULL
	mask = lshift(mask, bitcount)
	mask = bnot(mask)
	mask = lshift(mask, lowbit)

	-- use the mask, and a shift to get the desired
	-- value
	local value = rshift(band(mask, src), lowbit)
	return value;
end

function exports.setbits64(dst, lowbit, bitcount, value)
	-- make a whole where the value will be
	local mask = 0xffffffffffffffffULL
	mask = lshift(mask, bitcount)
	mask = bnot(mask)

	-- while we're at it, ensure the value fits
	-- within the bitcount
	value = band(mask, value)

	-- shift the whole, and flip it back
	-- to zeros everywhere but the hole
	mask = lshift(mask, lowbit)
	mask = bnot(mask)

	local newvalue = band(dst, mask)


	-- now take the value, and shift it by the lowbit
	value = lshift(value, lowbit)

	-- finally, stick it in the destination
	dst = bor(newvalue, value)

	return dst
end

return exports;
