local ffi = require("ffi")
local bit = require("bit")
local lshift = bit.lshift;
local rshift = bit.rshift;
local bnot = bit.bnot;

local S = require("syscall")
local nr = require "syscall.linux.nr"
local _IO, _IOW = S.c.IOCTL._IO, S.c.IOCTL._IOW
local shared = require("shared")

-- The table which will hold anything we want exported
-- from this module
local exports = {}
exports.nr = nr;


ffi.cdef[[
/*
 * attr->type field values
 */
enum perf_type_id {
	PERF_TYPE_HARDWARE	= 0,
	PERF_TYPE_SOFTWARE	= 1,
	PERF_TYPE_TRACEPOINT	= 2,
	PERF_TYPE_HW_CACHE	= 3,
	PERF_TYPE_RAW		= 4,
	PERF_TYPE_BREAKPOINT	= 5,
	PERF_TYPE_MAX
};

/*
 * attr->config values for generic HW PMU events
 *
 * they get mapped onto actual events by the kernel
 */
enum perf_hw_id {
	PERF_COUNT_HW_CPU_CYCLES		= 0,
	PERF_COUNT_HW_INSTRUCTIONS		= 1,
	PERF_COUNT_HW_CACHE_REFERENCES		= 2,
	PERF_COUNT_HW_CACHE_MISSES		= 3,
	PERF_COUNT_HW_BRANCH_INSTRUCTIONS	= 4,
	PERF_COUNT_HW_BRANCH_MISSES		= 5,
	PERF_COUNT_HW_BUS_CYCLES		= 6,
	PERF_COUNT_HW_STALLED_CYCLES_FRONTEND	= 7,
	PERF_COUNT_HW_STALLED_CYCLES_BACKEND	= 8,
	PERF_COUNT_HW_REF_CPU_CYCLES		= 9,
	PERF_COUNT_HW_MAX
};

/*
 * attr->config values for generic HW cache events
 *
 * they get mapped onto actual events by the kernel
 */
enum perf_hw_cache_id {
	PERF_COUNT_HW_CACHE_L1D		= 0,
	PERF_COUNT_HW_CACHE_L1I		= 1,
	PERF_COUNT_HW_CACHE_LL		= 2,
	PERF_COUNT_HW_CACHE_DTLB	= 3,
	PERF_COUNT_HW_CACHE_ITLB	= 4,
	PERF_COUNT_HW_CACHE_BPU		= 5,
	PERF_COUNT_HW_CACHE_NODE	= 6,
	PERF_COUNT_HW_CACHE_MAX
};

enum perf_hw_cache_op_id {
	PERF_COUNT_HW_CACHE_OP_READ		= 0,
	PERF_COUNT_HW_CACHE_OP_WRITE		= 1,
	PERF_COUNT_HW_CACHE_OP_PREFETCH		= 2,
	PERF_COUNT_HW_CACHE_OP_MAX
};

enum perf_hw_cache_op_result_id {
	PERF_COUNT_HW_CACHE_RESULT_ACCESS	= 0,
	PERF_COUNT_HW_CACHE_RESULT_MISS		= 1,
	PERF_COUNT_HW_CACHE_RESULT_MAX
};

/*
 * attr->config values for SW events
 */
enum perf_sw_ids {
	PERF_COUNT_SW_CPU_CLOCK			= 0,
	PERF_COUNT_SW_TASK_CLOCK		= 1,
	PERF_COUNT_SW_PAGE_FAULTS		= 2,
	PERF_COUNT_SW_CONTEXT_SWITCHES		= 3,
	PERF_COUNT_SW_CPU_MIGRATIONS		= 4,
	PERF_COUNT_SW_PAGE_FAULTS_MIN		= 5,
	PERF_COUNT_SW_PAGE_FAULTS_MAJ		= 6,
	PERF_COUNT_SW_ALIGNMENT_FAULTS		= 7,
	PERF_COUNT_SW_EMULATION_FAULTS		= 8,
	PERF_COUNT_SW_MAX
};

/*
 * attr->sample_type values
 */
enum perf_event_sample_format {
	PERF_SAMPLE_IP			= 1U << 0,
	PERF_SAMPLE_TID			= 1U << 1,
	PERF_SAMPLE_TIME		= 1U << 2,
	PERF_SAMPLE_ADDR		= 1U << 3,
	PERF_SAMPLE_READ		= 1U << 4,
	PERF_SAMPLE_CALLCHAIN		= 1U << 5,
	PERF_SAMPLE_ID			= 1U << 6,
	PERF_SAMPLE_CPU			= 1U << 7,
	PERF_SAMPLE_PERIOD		= 1U << 8,
	PERF_SAMPLE_STREAM_ID		= 1U << 9,
	PERF_SAMPLE_RAW			= 1U << 10,
	PERF_SAMPLE_BRANCH_STACK	= 1U << 11,
	PERF_SAMPLE_REGS_USER		= 1U << 12,
	PERF_SAMPLE_STACK_USER		= 1U << 13,
	PERF_SAMPLE_WEIGHT		= 1U << 14,
	PERF_SAMPLE_DATA_SRC		= 1U << 15,
	PERF_SAMPLE_MAX			= 1U << 16,
};

/*
 * branch_sample_type values
 */
enum perf_branch_sample_type {
	PERF_SAMPLE_BRANCH_USER		= 1U << 0,
	PERF_SAMPLE_BRANCH_KERNEL	= 1U << 1,
	PERF_SAMPLE_BRANCH_HV		= 1U << 2,
	PERF_SAMPLE_BRANCH_ANY		= 1U << 3,
	PERF_SAMPLE_BRANCH_ANY_CALL	= 1U << 4,
	PERF_SAMPLE_BRANCH_ANY_RETURN	= 1U << 5,
	PERF_SAMPLE_BRANCH_IND_CALL	= 1U << 6,
	PERF_SAMPLE_BRANCH_MAX		= 1U << 7,
};

enum perf_sample_regs_abi {
	PERF_SAMPLE_REGS_ABI_NONE	= 0,
	PERF_SAMPLE_REGS_ABI_32		= 1,
	PERF_SAMPLE_REGS_ABI_64		= 2,
};

/*
 * attr->read_format values
 */
enum perf_event_read_format {
	PERF_FORMAT_TOTAL_TIME_ENABLED	= 1U << 0,
	PERF_FORMAT_TOTAL_TIME_RUNNING	= 1U << 1,
	PERF_FORMAT_ID			= 1U << 2,
	PERF_FORMAT_GROUP		= 1U << 3,
	PERF_FORMAT_MAX			= 1U << 4,
};
]]

exports.PERF_ATTR_SIZE_VER0	= 64;	-- sizeof first published struct 
exports.PERF_ATTR_SIZE_VER1	= 72;	-- add: config2 
exports.PERF_ATTR_SIZE_VER2	= 80;	-- add: branch_sample_type 


ffi.cdef[[
/*
 * perf_event_attr struct passed to perf_event_open()
 */
typedef struct perf_event_attr {
	uint32_t	type;
	uint32_t	size;
	uint64_t	config;

	union {
		uint64_t	sample_period;
		uint64_t	sample_freq;
	} sample;

	uint64_t	sample_type;
	uint64_t	read_format;

/*
	uint64_t	disabled       :  1;
	uint64_t	inherit	       :  1;
	uint64_t	pinned	       :  1;
	uint64_t	exclusive      :  1;
	uint64_t	exclude_user   :  1;
	uint64_t	exclude_kernel :  1;
	uint64_t	exclude_hv     :  1;
	uint64_t	exclude_idle   :  1;
	uint64_t	mmap           :  1;
	uint64_t	comm	       :  1;
	uint64_t	freq           :  1;
	uint64_t	inherit_stat   :  1;
	uint64_t	enable_on_exec :  1;
	uint64_t	task           :  1;
	uint64_t	watermark      :  1;
	uint64_t	precise_ip     :  2;
	uint64_t	mmap_data      :  1;
	uint64_t	sample_id_all  :  1;
	uint64_t	exclude_host   :  1;
	uint64_t	exclude_guest  :  1;
	uint64_t	exclude_callchain_kernel : 1;
	uint64_t	exclude_callchain_user   : 1;
	uint64_t	__reserved_1   : 41;
*/
	// TODO - need a better way to represent the uint64_t 
	// based bitfields 
	uint64_t bitfield_flag;

	union {
		uint32_t	wakeup_events;
		uint32_t	wakeup_watermark;
	} wakeup;

	uint32_t        bp_type;
	union {
		uint64_t    bp_addr;
		uint64_t	config1; // extend config
	} bpa;
	union {
		uint64_t    bp_len;
		uint64_t	config2; // extend config1
	} bpb;
	uint64_t branch_sample_type;
	uint64_t sample_regs_user;
	uint32_t sample_stack_user;
	uint32_t __reserved_2;
} perf_event_attr_t;
]]

--[[
	As of LuaJIT 2.1, 64-bit values can not be used as bitfields
	in C structures.  This is probably according to the C standard
	the the C parser follows, as the standard only indicates bitfields
	will work with 'int' fields.

	So, we construct this metatype with the bitfield ranges, and implement
	the __newindex, and __index functions so that we can do the bit
	manipulations ourselves.

	Of course, if you want to add any other function to the metatype, you'll
	have to change this code.

	More than likely, you can simply do it in a convenient table class instead
	of in here.
--]]
local perf_event_attr = ffi.typeof("struct perf_event_attr")
local perf_event_attr_mt = {}
perf_event_attr_mt.bitfield_ranges = {
	disabled	   = { 0,  1};
	inherit	       = { 1,  1};
	pinned	       = { 2,  1};
	exclusive      = { 3,  1};
	exclude_user   = { 4,  1};
	exclude_kernel = { 5,  1};
	exclude_hv     = { 6,  1};
	exclude_idle   = { 7,  1};
	mmap           = { 8,  1};
	comm	       = { 9,  1};
	freq           = { 10,  1};
	inherit_stat   = { 11,  1};
	enable_on_exec = { 12,  1};
	task           = { 13,  1};
	watermark      = { 14,  1};
	precise_ip     = { 15,  2};
	mmap_data      = { 17,  1};
	sample_id_all  = { 18,  1};
	exclude_host   = { 19,  1};
	exclude_guest  = { 20,  1};
	exclude_callchain_kernel = { 21, 1};
	exclude_callchain_user   = { 22, 1};
	__reserved_1   = { 23, 41};
}   

perf_event_attr_mt.__index = function(self, key)
	local keyrange = perf_event_attr_mt.bitfield_ranges[key]
	if not keyrange then
		return nil;
	end

	return shared.extractbits64(self.bitfield_flag, keyrange[1], keyrange[2]);
end

perf_event_attr_mt.__newindex = function(self, key, value)		
	--print("perf_event_attr, setting field value: ", key, value)
	local kr = perf_event_attr_mt.bitfield_ranges[key]
	if not kr then
		return nil;
	end
	self.bitfield_flag = shared.setbits64(self.bitfield_flag, kr[1], kr[2], value);

	return res;
end

ffi.metatype(perf_event_attr, perf_event_attr_mt);



ffi.cdef[[
struct perf_branch_entry {
	uint64_t	from;
	uint64_t	to;
/*
	uint64_t	mispred:1,  // target mispredicted 
			predicted:1,	// target predicted 
			reserved:62;
*/
	uint64_t bitfield_flag;
};
]]


local perf_branch_entry = ffi.typeof("struct perf_branch_entry")
local perf_branch_entry_mt = {}
perf_branch_entry_mt.bitfield_ranges = {
	mispred = {0,1};
	predicted = {1,1};
	reserved = {2,62};
}
perf_branch_entry_mt.__index = function(self, key)
	local kr = perf_branch_entry_mt.bitfield_ranges[key]
	if not kr then return nil end

	return shared.extractbits64(self.bitfield_flag, kr[1], kr[2]);
end
perf_branch_entry_mt.__newindex = function(self, key, value)		
	--print("perf_event_attr, setting field value: ", key, value)
	local kr = perf_branch_entry_mt.bitfield_ranges[key]
	if not kr then return end

	self.bitfield_flag = shared.setbits64(self.bitfield_flag, kr[1], kr[2], value);
end
ffi.metatype(perf_branch_entry, perf_branch_entry_mt);


ffi.cdef[[
/*
 * branch stack layout:
 *  nr: number of taken branches stored in entries[]
 *
 * Note that nr can vary from sample to sample
 * branches (to, from) are stored from most recent
 * to least recent, i.e., entries[0] contains the most
 * recent branch.
 */
struct perf_branch_stack {
	uint64_t			nr;
	struct perf_branch_entry        entries[0];
};
]]



-- perf_events ioctl commands, use with event fd
exports.PERF_EVENT_IOC_ENABLE		= _IO ('$', 0)
exports.PERF_EVENT_IOC_DISABLE		= _IO ('$', 1)
exports.PERF_EVENT_IOC_REFRESH		= _IO ('$', 2)
exports.PERF_EVENT_IOC_RESET		= _IO ('$', 3)
exports.PERF_EVENT_IOC_PERIOD		= _IOW('$', 4, "uint64")
exports.PERF_EVENT_IOC_SET_OUTPUT	= _IO ('$', 5)
exports.PERF_EVENT_IOC_SET_FILTER	= _IOW('$', 6, "char")


ffi.cdef[[
/*
 * ioctl() 3rd argument
 */
enum perf_event_ioc_flags {
	PERF_IOC_FLAG_GROUP	= 1U << 0,
};
]]

ffi.cdef[[
/*
 * mmapped sampling buffer layout
 * occupies a 4kb page
 */
struct perf_event_mmap_page {
	uint32_t	version;
	uint32_t	compat_version;
	uint32_t	lock;
	uint32_t	index;
	int64_t		offset;
	uint64_t	time_enabled;
	uint64_t	time_running;
	union {
		uint64_t capabilities;
/*
		uint64_t cap_usr_time:1,
			 cap_usr_rdpmc:1,
			 cap_____res:62;
*/
		uint64_t bitfield_flag;
	} rdmap_cap;
	uint16_t	pmc_width;
	uint16_t	time_shift;
	uint32_t	time_mult;
	uint64_t	time_offset;

	uint64_t	__reserved[120];
	uint64_t  	data_head;
	uint64_t	data_tail;
};

/*
 * sampling buffer event header
 */
struct perf_event_header {
	uint32_t	type;
	uint16_t	misc;
	uint16_t	size;
};
]]



-- event header misc field values
exports.PERF_EVENT_MISC_CPUMODE_MASK	= lshift(3,0)
exports.PERF_EVENT_MISC_CPUMODE_UNKNOWN	= lshift(0,0)
exports.PERF_EVENT_MISC_KERNEL		= lshift(1,0)
exports.PERF_EVENT_MISC_USER		= lshift(2,0)
exports.PERF_EVENT_MISC_HYPERVISOR	= lshift(3,0)
exports.PERF_RECORD_MISC_GUEST_KERNEL	= lshift(4,0)
exports.PERF_RECORD_MISC_GUEST_USER	= lshift(5,0)

exports.PERF_RECORD_MISC_EXACT			= lshift(1, 14)
exports.PERF_RECORD_MISC_EXACT_IP               = lshift(1, 14)
exports.PERF_RECORD_MISC_EXT_RESERVED		= lshift(1, 15)

ffi.cdef[[
// header->type values

enum perf_event_type {
	PERF_RECORD_MMAP		= 1,
	PERF_RECORD_LOST		= 2,
	PERF_RECORD_COMM		= 3,
	PERF_RECORD_EXIT		= 4,
	PERF_RECORD_THROTTLE		= 5,
	PERF_RECORD_UNTHROTTLE		= 6,
	PERF_RECORD_FORK		= 7,
	PERF_RECORD_READ		= 8,
	PERF_RECORD_SAMPLE		= 9,
	PERF_RECORD_MMAP2		= 10,
	PERF_RECORD_MAX
};

enum perf_callchain_context {
	PERF_CONTEXT_HV			= (uint64_t)-32,
	PERF_CONTEXT_KERNEL		= (uint64_t)-128,
	PERF_CONTEXT_USER		= (uint64_t)-512,

	PERF_CONTEXT_GUEST		= (uint64_t)-2048,
	PERF_CONTEXT_GUEST_KERNEL	= (uint64_t)-2176,
	PERF_CONTEXT_GUEST_USER		= (uint64_t)-2560,

	PERF_CONTEXT_MAX		= (uint64_t)-4095,
};
]]


-- flags for perf_event_open()
exports.PERF_FLAG_FD_NO_GROUP =	lshift(1, 0)
exports.PERF_FLAG_FD_OUTPUT	= lshift(1, 1)
exports.PERF_FLAG_PID_CGROUP =	lshift(1, 2)

local __NR_perf_event_open = 0;

if ffi.arch == "x64" then
	__NR_perf_event_open	= 298;
end

if ffi.arch == "x86" then
	__NR_perf_event_open = 336;
end

if ffi.arch == "ppc" then
	__NR_perf_event_open = 319;
end

if ffi.arch == "arm" then
	__NR_perf_event_open = 364;
end

if ffi.arch == "arm64" then
	__NR_perf_event_open = 241;
end

if ffi.arch == "mips" then
	__NR_perf_event_open = 4333;
end




-- perf_event_open() syscall stub
--local function perf_event_open(
--	struct perf_event_attr		*hw_event_uptr,
--	pid_t				pid,
--	int				cpu,
--	int				group_fd,
--	unsigned long			flags)

local function perf_event_open(
	hw_event_uptr,
	pid,
	cpu,
	group_fd,
	flags)
--print("perf_event_open: ", S.perf_event_open, hw_event_uptr, pid, cpu, group_fd, flags)
	local fd =  ffi.C.syscall(nr.SYS.perf_event_open, hw_event_uptr, pid, cpu, group_fd, flags);
	fd = S.t.fd(fd);

	return fd;
end
exports.perf_event_open = perf_event_open


exports.PR_TASK_PERF_EVENTS_ENABLE	= 32
exports.PR_TASK_PERF_EVENTS_DISABLE	= 31


ffi.cdef[[
union perf_mem_data_src {
	uint64_t val;
	struct {
/*
		uint64_t   mem_op:5,	// type of opcode 
			   mem_lvl:14,	// memory hierarchy level 
			   mem_snoop:5,	// snoop mode 
			   mem_lock:2,	// lock instr 
			   mem_dtlb:7,	// tlb access 
			   mem_rsvd:31;
*/
	};
};
]]

local perf_mem_data_src = ffi.typeof("union perf_mem_data_src")
local perf_mem_data_src_mt = {}
perf_mem_data_src_mt.bitfield_ranges = {
	mem_op = {0,5};
	mem_lvl = {5,14};
	mem_snoop = {19,5};
	mem_lock = {24,2};
	mem_dtlb = {26,7};
	mem_rsvd = {33,31};
}
perf_mem_data_src_mt.__index = function(self, key)
	local kr = perf_mem_data_src_mt.bitfield_ranges[key]
	if not kr then
		return nil;
	end

	return shared.extractbits64(self.val, kr[1], kr[2]);
end
perf_mem_data_src_mt.__newindex = function(self, key, value)		
	--print("perf_event_attr, setting field value: ", key, value)
	local kr = perf_mem_data_src_mt.bitfield_ranges[key]
	if not kr then
		return nil;
	end
	self.val = shared.setbits64(self.val, kr[1], kr[2], value);
end
ffi.metatype(perf_mem_data_src, perf_mem_data_src_mt);


-- type of opcode (load/store/prefetch,code) 
exports.PERF_MEM_OP_NA		= 0x01 -- not available 
exports.PERF_MEM_OP_LOAD	= 0x02 -- load instruction 
exports.PERF_MEM_OP_STORE	= 0x04 -- store instruction 
exports.PERF_MEM_OP_PFETCH	= 0x08 -- prefetch 
exports.PERF_MEM_OP_EXEC	= 0x10 -- code (execution) 
exports.PERF_MEM_OP_SHIFT	= 0

-- memory hierarchy (memory level, hit or miss) 
exports.PERF_MEM_LVL_NA		= 0x01  -- not available 
exports.PERF_MEM_LVL_HIT	= 0x02  -- hit level 
exports.PERF_MEM_LVL_MISS	= 0x04  -- miss level  
exports.PERF_MEM_LVL_L1		= 0x08  -- L1 
exports.PERF_MEM_LVL_LFB	= 0x10  -- Line Fill Buffer 
exports.PERF_MEM_LVL_L2		= 0x20  -- L2 
exports.PERF_MEM_LVL_L3		= 0x40  -- L3 
exports.PERF_MEM_LVL_LOC_RAM	= 0x80  -- Local DRAM 
exports.PERF_MEM_LVL_REM_RAM1	= 0x100 -- Remote DRAM (1 hop) 
exports.PERF_MEM_LVL_REM_RAM2	= 0x200 -- Remote DRAM (2 hops) 
exports.PERF_MEM_LVL_REM_CCE1	= 0x400 -- Remote Cache (1 hop) 
exports.PERF_MEM_LVL_REM_CCE2	= 0x800 -- Remote Cache (2 hops) 
exports.PERF_MEM_LVL_IO		= 0x1000 -- I/O memory 
exports.PERF_MEM_LVL_UNC	= 0x2000 -- Uncached memory 
exports.PERF_MEM_LVL_SHIFT	= 5

-- snoop mode 
exports.PERF_MEM_SNOOP_NA	= 0x01 -- not available 
exports.PERF_MEM_SNOOP_NONE	= 0x02 -- no snoop 
exports.PERF_MEM_SNOOP_HIT	= 0x04 -- snoop hit 
exports.PERF_MEM_SNOOP_MISS	= 0x08 -- snoop miss 
exports.PERF_MEM_SNOOP_HITM	= 0x10 -- snoop hit modified 
exports.PERF_MEM_SNOOP_SHIFT	= 19

-- locked instruction 
exports.PERF_MEM_LOCK_NA	= 0x01 -- not available 
exports.PERF_MEM_LOCK_LOCKED	= 0x02 -- locked transaction 
exports.PERF_MEM_LOCK_SHIFT	= 24

-- TLB access 
exports.PERF_MEM_TLB_NA		= 0x01 -- not available 
exports.PERF_MEM_TLB_HIT	= 0x02 -- hit level 
exports.PERF_MEM_TLB_MISS	= 0x04 -- miss level 
exports.PERF_MEM_TLB_L1		= 0x08 -- L1 
exports.PERF_MEM_TLB_L2		= 0x10 -- L2 
exports.PERF_MEM_TLB_WK		= 0x20 -- Hardware Walker
exports.PERF_MEM_TLB_OS		= 0x40 -- OS fault handler 
exports.PERF_MEM_TLB_SHIFT	= 26

local function PERF_MEM_S(a, s) 
	--(((u64)PERF_MEM_##a##_##s) << PERF_MEM_##a##_SHIFT)
	local id = string.format("PERF_MEM_%s_%s", a, s)
	local shift = string.format("PERF_MEM_%s_SHIFT", a)
	return lshift(exports[id], exports[shift])
end


return exports
