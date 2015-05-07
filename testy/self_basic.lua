package.path = package.path..";".."../?.lua"

local ffi = require("ffi")
local bit = require("bit")
local bor, band, lshift, rshift = bit.bor, bit.band, bit.lshift, bit.rshift

local PE = require("perf_event")
local pfm = require("pfmlib")

local S = require("syscall")
local nr = require "syscall.linux.nr"
local _IO, _IOW = S.c.IOCTL._IO, S.c.IOCTL._IOW

local common = require("test_common")


local N = 30

local function fib(n)
	if (n == 0) then
		return 0;
	end

	if (n == 1) then
		return 2;
	end

	return fib(n-1)+fib(n-2);
end


local function main(argc, argv)

	local attr = ffi.new("struct perf_event_attr");
	local count = 0
	local values = ffi.new("uint64_t[3]");

--[[
	/*
 	 * 1st argument: event string
 	 * 2nd argument: default privilege level (used if not specified in the event string)
 	 * 3rd argument: the perf_event_attr to initialize
 	 */
--]]
	attr.size = ffi.sizeof("struct perf_event_attr")
	local ret = pfm.Lib.pfm_get_perf_event_encoding("cycles", bor(pfm.PFM_PLM0,pfm.PFM_PLM3), attr, nil, nil);
	if (ret ~= pfm.PFM_SUCCESS) then
		error(string.format("cannot find encoding: %s", pfm.GetStringError(ret)));
	end

--[[
	/*
	 * request timing information because event may be multiplexed
	 * and thus it may not count all the time. The scaling information
	 * will be used to scale the raw count as if the event had run all
	 * along
	 */
--]]
	attr.read_format = bor(ffi.C.PERF_FORMAT_TOTAL_TIME_ENABLED, ffi.C.PERF_FORMAT_TOTAL_TIME_RUNNING);

	-- do not start immediately after perf_event_open()
	attr.disabled = 1;
	print("DISABLED: ", attr.disabled)
--[[
	/*
 	 * create the event and attach to self
 	 * Note that it attaches only to the main thread, there is no inheritance
 	 * to threads that may be created subsequently.
 	 *
 	 * if mulithreaded, then getpid() must be replaced by gettid()
 	 */
--]]
	local fd = PE.perf_event_open(attr, S.getpid(), -1, -1, 0);
print("FD: ", fd, fd:getfd())
	if (not fd) then 
		error("cannot create event");
	end

	
 	-- start counting now
	local ret = S.ioctl(fd, PE.PERF_EVENT_IOC_ENABLE, 0);
	if (ret ~= 0) then
		error("ioctl(enable) failed");
	end

	common.printf("Fibonacci(%d)=%lu\n", N, fib(N));

 	-- stop counting
	ret = ioctl(fd, PERF_EVENT_IOC_DISABLE, 0);
	if (ret ~= 0) then
		error("ioctl(disable) failed");
	end

--[[
	/*
 	 * read the count + scaling values
 	 *
 	 * It is not necessary to stop an event to read its value
 	 */
--]]
	ret = read(fd, values, ffi.sizeof(values));
	if (ret ~= ffi.sizeof(values)) then
		error(string.format("cannot read results: %s", S.strerror(S.errno)));
	end

	--[[
	/*
 	 * scale count
	 *
	 * values[0] = raw count
	 * values[1] = TIME_ENABLED
	 * values[2] = TIME_RUNNING
 	 */
 	 --]]
	if (values[2] >0) then
		count = values[0] * values[1]/values[2];
	end

	common.printf("count=%d\n", count);

	S.close(fd);

	-- free libpfm resources cleanly
	pfm.pfm_terminate();

end

main(#arg, arg)
