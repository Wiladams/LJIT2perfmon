-- test_perf_event.h
package.path = package.path..";".."../?.lua"

local ffi = require("ffi")
local bit = require("bit")
local common = require("test_common")

local perf_event = require("perf_event")
local S = require("syscall")

--common.printDict(perf_event.nr.SYS)
-- S.types
-- S.t
-- S.cgroup
-- S.util
-- S.abi
-- S.c
-- S.nl
common.printDict(S.types, "==== S.types ====")
common.printDict(S.types.s, "==== S.types.s ====")

-- these two are the same?
common.printDict(S.types.ctypes, "==== S.types.ctypes ====")
common.printDict(S.t, '==== S.t ====')

common.printDict(S.cgroup, "==== cgroup ====")
common.printDict(S.util, "==== S.util ====")
common.printDict(S.abi, "==== S.abi ====")
common.printDict(S.c, "==== S.c ====")
common.printDict(S.nl, "==== S.nl ====")
