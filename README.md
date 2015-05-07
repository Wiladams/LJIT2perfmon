# LJIT2perfmon
LuaJIT binding to libpfm4

This binding primarily treats the libprm4 interface, and not the raw
performance interface as represented by the perf_event structures.

The ffi bindings are provided for both, but the various object conveniences
are related to the pfmlib.lua/pfmlib_ffi.lua files.

The testy directory has various examples of how to use the routines in code.
