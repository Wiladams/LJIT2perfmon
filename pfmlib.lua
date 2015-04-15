local ffi = require("ffi")
local pfm_ffi = require("pfmlib_ffi");


local export= {}
export.ffi = pfm_ffi;

local EventSources = {
	[ffi.C.PFM_PMU_NONE] = "PFM_PMU_NONE",							-- no PMU 
	[ffi.C.PFM_PMU_GEN_IA64] = "PFM_PMU_GEN_IA64",	 				-- Intel IA-64 architected PMU 
	[ffi.C.PFM_PMU_ITANIUM] = "PFM_PMU_ITANIUM",	 				-- Intel Itanium   
	[ffi.C.PFM_PMU_ITANIUM2] = "PFM_PMU_ITANIUM2",					-- Intel Itanium 2 
	[ffi.C.PFM_PMU_MONTECITO] = "PFM_PMU_MONTECITO",				-- Intel Dual-Core Itanium 2 9000 
	[ffi.C.PFM_PMU_AMD64] = "PFM_PMU_AMD64",						-- AMD AMD64 (obsolete) 
	[ffi.C.PFM_PMU_I386_P6] = "PFM_PMU_I386_P6",					-- Intel PIII (P6 core) 
	[ffi.C.PFM_PMU_INTEL_NETBURST] = "PFM_PMU_INTEL_NETBURST",		-- Intel Netburst (Pentium 4) 
	[ffi.C.PFM_PMU_INTEL_NETBURST_P] = "PFM_PMU_INTEL_NETBURST_P",	-- Intel Netburst Prescott (Pentium 4) 
	[ffi.C.PFM_PMU_COREDUO] = "PFM_PMU_COREDUO",					-- Intel Core Duo/Core Solo 
	[ffi.C.PFM_PMU_I386_PM] = "PFM_PMU_I386_PM",					-- Intel Pentium M 
	[ffi.C.PFM_PMU_INTEL_CORE] = "PFM_PMU_INTEL_CORE",		-- Intel Core 
	[ffi.C.PFM_PMU_INTEL_PPRO] = "PFM_PMU_INTEL_PPRO",		-- Intel Pentium Pro 
	[ffi.C.PFM_PMU_INTEL_PII] = "PFM_PMU_INTEL_PII",		-- Intel Pentium II 
	[ffi.C.PFM_PMU_INTEL_ATOM] = "PFM_PMU_INTEL_ATOM",		-- Intel Atom 
	[ffi.C.PFM_PMU_INTEL_NHM] = "PFM_PMU_INTEL_NHM",		-- Intel Nehalem core PMU 
	[ffi.C.PFM_PMU_INTEL_NHM_EX] = "PFM_PMU_INTEL_NHM_EX",		-- Intel Nehalem-EX core PMU 
	[ffi.C.PFM_PMU_INTEL_NHM_UNC] = "PFM_PMU_INTEL_NHM_UNC",		-- Intel Nehalem uncore PMU 
	[ffi.C.PFM_PMU_INTEL_X86_ARCH] = "PFM_PMU_INTEL_X86_ARCH",		-- Intel X86 architectural PMU 

	[ffi.C.PFM_PMU_MIPS_20KC] = "PFM_PMU_MIPS_20KC",		-- MIPS 20KC 
	[ffi.C.PFM_PMU_MIPS_24K] = "PFM_PMU_MIPS_24K",		-- MIPS 24K 
	[ffi.C.PFM_PMU_MIPS_25KF] = "PFM_PMU_MIPS_25KF",		-- MIPS 25KF 
	[ffi.C.PFM_PMU_MIPS_34K] = "PFM_PMU_MIPS_34K",		-- MIPS 34K 
	[ffi.C.PFM_PMU_MIPS_5KC] = "PFM_PMU_MIPS_5KC",		-- MIPS 5KC 
	[ffi.C.PFM_PMU_MIPS_74K] = "PFM_PMU_MIPS_74K",		-- MIPS 74K 
	[ffi.C.PFM_PMU_MIPS_R10000] = "PFM_PMU_MIPS_R10000",		-- MIPS R10000 
	[ffi.C.PFM_PMU_MIPS_R12000] = "PFM_PMU_MIPS_R12000",		-- MIPS R12000 
	[ffi.C.PFM_PMU_MIPS_RM7000] = "PFM_PMU_MIPS_RM7000",		-- MIPS RM7000 
	[ffi.C.PFM_PMU_MIPS_RM9000] = "PFM_PMU_MIPS_RM9000",		-- MIPS RM9000 
	[ffi.C.PFM_PMU_MIPS_SB1] = "PFM_PMU_MIPS_SB1",		-- MIPS SB1/SB1A 
	[ffi.C.PFM_PMU_MIPS_VR5432] = "PFM_PMU_MIPS_VR5432",		-- MIPS VR5432 
	[ffi.C.PFM_PMU_MIPS_VR5500] = "PFM_PMU_MIPS_VR5500",		-- MIPS VR5500 
	[ffi.C.PFM_PMU_MIPS_ICE9A] = "PFM_PMU_MIPS_ICE9A",		-- SiCortex ICE9A 
	[ffi.C.PFM_PMU_MIPS_ICE9B] = "PFM_PMU_MIPS_ICE9B",		-- SiCortex ICE9B 
	[ffi.C.PFM_PMU_POWERPC] = "PFM_PMU_POWERPC",		-- POWERPC 
	[ffi.C.PFM_PMU_CELL] = "PFM_PMU_CELL",			-- IBM CELL 

	[ffi.C.PFM_PMU_SPARC_ULTRA12] = "PFM_PMU_SPARC_ULTRA12",		-- UltraSPARC I; II; IIi; and IIe 
	[ffi.C.PFM_PMU_SPARC_ULTRA3] = "PFM_PMU_SPARC_ULTRA3",		-- UltraSPARC III 
	[ffi.C.PFM_PMU_SPARC_ULTRA3I] = "PFM_PMU_SPARC_ULTRA3I",		-- UltraSPARC IIIi and IIIi+ 
	[ffi.C.PFM_PMU_SPARC_ULTRA3PLUS] = "PFM_PMU_SPARC_ULTRA3PLUS",	-- UltraSPARC III+ and IV 
	[ffi.C.PFM_PMU_SPARC_ULTRA4PLUS] = "PFM_PMU_SPARC_ULTRA4PLUS",	-- UltraSPARC IV+ 
	[ffi.C.PFM_PMU_SPARC_NIAGARA1] = "PFM_PMU_SPARC_NIAGARA1",		-- Niagara-1 
	[ffi.C.PFM_PMU_SPARC_NIAGARA2] = "PFM_PMU_SPARC_NIAGARA2",		-- Niagara-2 

	[ffi.C.PFM_PMU_PPC970] = "PFM_PMU_PPC970",			-- IBM PowerPC 970(FX;GX) 
	[ffi.C.PFM_PMU_PPC970MP] = "PFM_PMU_PPC970MP",		-- IBM PowerPC 970MP 
	[ffi.C.PFM_PMU_POWER3] = "PFM_PMU_POWER3",			-- IBM POWER3 
	[ffi.C.PFM_PMU_POWER4] = "PFM_PMU_POWER4",			-- IBM POWER4 
	[ffi.C.PFM_PMU_POWER5] = "PFM_PMU_POWER5",			-- IBM POWER5 
	[ffi.C.PFM_PMU_POWER5p] = "PFM_PMU_POWER5p",		-- IBM POWER5+ 
	[ffi.C.PFM_PMU_POWER6] = "PFM_PMU_POWER6",			-- IBM POWER6 
	[ffi.C.PFM_PMU_POWER7] = "PFM_PMU_POWER7",			-- IBM POWER7 

	[ffi.C.PFM_PMU_PERF_EVENT] = "PFM_PMU_PERF_EVENT",		-- perf_event PMU 
	[ffi.C.PFM_PMU_INTEL_WSM] = "PFM_PMU_INTEL_WSM",		-- Intel Westmere single-socket (Clarkdale) 
	[ffi.C.PFM_PMU_INTEL_WSM_DP] = "PFM_PMU_INTEL_WSM_DP",		-- Intel Westmere dual-socket (Westmere-EP; Gulftwon) 
	[ffi.C.PFM_PMU_INTEL_WSM_UNC] = "PFM_PMU_INTEL_WSM_UNC",		-- Intel Westmere uncore PMU 

	[ffi.C.PFM_PMU_AMD64_K7] = "PFM_PMU_AMD64_K7",		-- AMD AMD64 K7 
	[ffi.C.PFM_PMU_AMD64_K8_REVB] = "PFM_PMU_AMD64_K8_REVB",		-- AMD AMD64 K8 RevB 
	[ffi.C.PFM_PMU_AMD64_K8_REVC] = "PFM_PMU_AMD64_K8_REVC",		-- AMD AMD64 K8 RevC 
	[ffi.C.PFM_PMU_AMD64_K8_REVD] = "PFM_PMU_AMD64_K8_REVD",		-- AMD AMD64 K8 RevD 
	[ffi.C.PFM_PMU_AMD64_K8_REVE] = "PFM_PMU_AMD64_K8_REVE",		-- AMD AMD64 K8 RevE 
	[ffi.C.PFM_PMU_AMD64_K8_REVF] = "PFM_PMU_AMD64_K8_REVF",		-- AMD AMD64 K8 RevF 
	[ffi.C.PFM_PMU_AMD64_K8_REVG] = "PFM_PMU_AMD64_K8_REVG",		-- AMD AMD64 K8 RevG 
	[ffi.C.PFM_PMU_AMD64_FAM10H_BARCELONA] = "PFM_PMU_AMD64_FAM10H_BARCELONA",	-- AMD AMD64 Fam10h Barcelona RevB 
	[ffi.C.PFM_PMU_AMD64_FAM10H_SHANGHAI] = "PFM_PMU_AMD64_FAM10H_SHANGHAI",	-- AMD AMD64 Fam10h Shanghai RevC  
	[ffi.C.PFM_PMU_AMD64_FAM10H_ISTANBUL] = "PFM_PMU_AMD64_FAM10H_ISTANBUL",	-- AMD AMD64 Fam10h Istanbul RevD  

	[ffi.C.PFM_PMU_ARM_CORTEX_A8] = "PFM_PMU_ARM_CORTEX_A8",		-- ARM Cortex A8 
	[ffi.C.PFM_PMU_ARM_CORTEX_A9] = "PFM_PMU_ARM_CORTEX_A9",		-- ARM Cortex A9 

	[ffi.C.PFM_PMU_TORRENT] = "PFM_PMU_TORRENT",		-- IBM Torrent hub chip 

	[ffi.C.PFM_PMU_INTEL_SNB] = "PFM_PMU_INTEL_SNB",		-- Intel Sandy Bridge (single socket) 
	[ffi.C.PFM_PMU_AMD64_FAM14H_BOBCAT] = "PFM_PMU_AMD64_FAM14H_BOBCAT",	-- AMD AMD64 Fam14h Bobcat 
	[ffi.C.PFM_PMU_AMD64_FAM15H_INTERLAGOS] = "PFM_PMU_AMD64_FAM15H_INTERLAGOS",-- AMD AMD64 Fam15h Interlagos 

	[ffi.C.PFM_PMU_INTEL_SNB_EP] = "PFM_PMU_INTEL_SNB_EP",		-- Intel SandyBridge EP 
	[ffi.C.PFM_PMU_AMD64_FAM12H_LLANO] = "PFM_PMU_AMD64_FAM12H_LLANO",	-- AMD AMD64 Fam12h Llano 
	[ffi.C.PFM_PMU_AMD64_FAM11H_TURION] = "PFM_PMU_AMD64_FAM11H_TURION",	-- AMD AMD64 Fam11h Turion 
	[ffi.C.PFM_PMU_INTEL_IVB] = "PFM_PMU_INTEL_IVB",		-- Intel IvyBridge 
	[ffi.C.PFM_PMU_ARM_CORTEX_A15] = "PFM_PMU_ARM_CORTEX_A15",		-- ARM Cortex A15 

	[ffi.C.PFM_PMU_INTEL_SNB_UNC_CB0] = "PFM_PMU_INTEL_SNB_UNC_CB0",	-- Intel SandyBridge C-box 0 uncore PMU 
	[ffi.C.PFM_PMU_INTEL_SNB_UNC_CB1] = "PFM_PMU_INTEL_SNB_UNC_CB1",	-- Intel SandyBridge C-box 1 uncore PMU 
	[ffi.C.PFM_PMU_INTEL_SNB_UNC_CB2] = "PFM_PMU_INTEL_SNB_UNC_CB2",	-- Intel SandyBridge C-box 2 uncore PMU 
	[ffi.C.PFM_PMU_INTEL_SNB_UNC_CB3] = "PFM_PMU_INTEL_SNB_UNC_CB3",	-- Intel SandyBridge C-box 3 uncore PMU 

	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_CB0] = "PFM_PMU_INTEL_SNBEP_UNC_CB0",	-- Intel SandyBridge-EP C-Box core 0 uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_CB1] = "PFM_PMU_INTEL_SNBEP_UNC_CB1",	-- Intel SandyBridge-EP C-Box core 1 uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_CB2] = "PFM_PMU_INTEL_SNBEP_UNC_CB2",	-- Intel SandyBridge-EP C-Box core 2 uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_CB3] = "PFM_PMU_INTEL_SNBEP_UNC_CB3",	-- Intel SandyBridge-EP C-Box core 3 uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_CB4] = "PFM_PMU_INTEL_SNBEP_UNC_CB4",	-- Intel SandyBridge-EP C-Box core 4 uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_CB5] = "PFM_PMU_INTEL_SNBEP_UNC_CB5",	-- Intel SandyBridge-EP C-Box core 5 uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_CB6] = "PFM_PMU_INTEL_SNBEP_UNC_CB6",	-- Intel SandyBridge-EP C-Box core 6 uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_CB7] = "PFM_PMU_INTEL_SNBEP_UNC_CB7",	-- Intel SandyBridge-EP C-Box core 7 uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_HA] = "PFM_PMU_INTEL_SNBEP_UNC_HA",	-- Intel SandyBridge-EP HA uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_IMC0] = "PFM_PMU_INTEL_SNBEP_UNC_IMC0",	-- Intel SandyBridge-EP IMC socket 0 uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_IMC1] = "PFM_PMU_INTEL_SNBEP_UNC_IMC1",	-- Intel SandyBridge-EP IMC socket 1 uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_IMC2] = "PFM_PMU_INTEL_SNBEP_UNC_IMC2",	-- Intel SandyBridge-EP IMC socket 2 uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_IMC3] = "PFM_PMU_INTEL_SNBEP_UNC_IMC3",	-- Intel SandyBridge-EP IMC socket 3 uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_PCU] = "PFM_PMU_INTEL_SNBEP_UNC_PCU",	-- Intel SandyBridge-EP PCU uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_QPI0] = "PFM_PMU_INTEL_SNBEP_UNC_QPI0",	-- Intel SandyBridge-EP QPI link 0 uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_QPI1] = "PFM_PMU_INTEL_SNBEP_UNC_QPI1",	-- Intel SandyBridge-EP QPI link 1 uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_UBOX] = "PFM_PMU_INTEL_SNBEP_UNC_UBOX",	-- Intel SandyBridge-EP U-Box uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_R2PCIE] = "PFM_PMU_INTEL_SNBEP_UNC_R2PCIE",	-- Intel SandyBridge-EP R2PCIe uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_R3QPI0] = "PFM_PMU_INTEL_SNBEP_UNC_R3QPI0",	-- Intel SandyBridge-EP R3QPI 0 uncore 
	[ffi.C.PFM_PMU_INTEL_SNBEP_UNC_R3QPI1] = "PFM_PMU_INTEL_SNBEP_UNC_R3QPI1",	-- Intel SandyBridge-EP R3QPI 1 uncore 
	[ffi.C.PFM_PMU_INTEL_KNC] = "PFM_PMU_INTEL_KNC",		-- Intel Knights Corner (Xeon Phi) 

	[ffi.C.PFM_PMU_S390X_CPUM_CF] = "PFM_PMU_S390X_CPUM_CF",		-- s390x: CPU-M counter facility 

	[ffi.C.PFM_PMU_ARM_1176] = "PFM_PMU_ARM_1176",		-- ARM 1176 

	[ffi.C.PFM_PMU_INTEL_IVB_EP] = "PFM_PMU_INTEL_IVB_EP",		-- Intel IvyBridge EP 
	[ffi.C.PFM_PMU_INTEL_HSW] = "PFM_PMU_INTEL_HSW",		-- Intel Haswell 

	[ffi.C.PFM_PMU_INTEL_IVB_UNC_CB0] = "PFM_PMU_INTEL_IVB_UNC_CB0",	-- Intel IvyBridge C-box 0 uncore PMU 
	[ffi.C.PFM_PMU_INTEL_IVB_UNC_CB1] = "PFM_PMU_INTEL_IVB_UNC_CB1",	-- Intel IvyBridge C-box 1 uncore PMU 
	[ffi.C.PFM_PMU_INTEL_IVB_UNC_CB2] = "PFM_PMU_INTEL_IVB_UNC_CB2",	-- Intel IvyBridge C-box 2 uncore PMU 
	[ffi.C.PFM_PMU_INTEL_IVB_UNC_CB3] = "PFM_PMU_INTEL_IVB_UNC_CB3",	-- Intel IvyBridge C-box 3 uncore PMU 

	[ffi.C.PFM_PMU_POWER8] = "PFM_PMU_POWER8",			-- IBM POWER8 
	[ffi.C.PFM_PMU_INTEL_RAPL] = "PFM_PMU_INTEL_RAPL",		-- Intel RAPL 

	[ffi.C.PFM_PMU_INTEL_SLM] = "PFM_PMU_INTEL_SLM",		-- Intel Silvermont 
	[ffi.C.PFM_PMU_AMD64_FAM15H_NB] = "PFM_PMU_AMD64_FAM15H_NB",	-- AMD AMD64 Fam15h NorthBridge 

	[ffi.C.PFM_PMU_ARM_QCOM_KRAIT] = "PFM_PMU_ARM_QCOM_KRAIT",		-- Qualcomm Krait 
	[ffi.C.PFM_PMU_PERF_EVENT_RAW] = "PFM_PMU_PERF_EVENT_RAW",		-- perf_events RAW event syntax 

	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_CB0] = "PFM_PMU_INTEL_IVBEP_UNC_CB0",	-- Intel IvyBridge-EP C-Box core 0 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_CB1] = "PFM_PMU_INTEL_IVBEP_UNC_CB1",	-- Intel IvyBridge-EP C-Box core 1 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_CB2] = "PFM_PMU_INTEL_IVBEP_UNC_CB2",	-- Intel IvyBridge-EP C-Box core 2 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_CB3] = "PFM_PMU_INTEL_IVBEP_UNC_CB3",	-- Intel IvyBridge-EP C-Box core 3 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_CB4] = "PFM_PMU_INTEL_IVBEP_UNC_CB4",	-- Intel IvyBridge-EP C-Box core 4 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_CB5] = "PFM_PMU_INTEL_IVBEP_UNC_CB5",	-- Intel IvyBridge-EP C-Box core 5 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_CB6] = "PFM_PMU_INTEL_IVBEP_UNC_CB6",	-- Intel IvyBridge-EP C-Box core 6 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_CB7] = "PFM_PMU_INTEL_IVBEP_UNC_CB7",	-- Intel IvyBridge-EP C-Box core 7 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_CB8] = "PFM_PMU_INTEL_IVBEP_UNC_CB8",	-- Intel IvyBridge-EP C-Box core 8 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_CB9] = "PFM_PMU_INTEL_IVBEP_UNC_CB9",	-- Intel IvyBridge-EP C-Box core 9 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_CB10] = "PFM_PMU_INTEL_IVBEP_UNC_CB10",	-- Intel IvyBridge-EP C-Box core 10 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_CB11] = "PFM_PMU_INTEL_IVBEP_UNC_CB11",	-- Intel IvyBridge-EP C-Box core 11 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_CB12] = "PFM_PMU_INTEL_IVBEP_UNC_CB12",	-- Intel IvyBridge-EP C-Box core 12 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_CB13] = "PFM_PMU_INTEL_IVBEP_UNC_CB13",	-- Intel IvyBridge-EP C-Box core 13 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_CB14] = "PFM_PMU_INTEL_IVBEP_UNC_CB14",	-- Intel IvyBridge-EP C-Box core 14 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_HA0] = "PFM_PMU_INTEL_IVBEP_UNC_HA0",	-- Intel IvyBridge-EP HA 0 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_HA1] = "PFM_PMU_INTEL_IVBEP_UNC_HA1",	-- Intel IvyBridge-EP HA 1 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_IMC0] = "PFM_PMU_INTEL_IVBEP_UNC_IMC0",	-- Intel IvyBridge-EP IMC socket 0 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_IMC1] = "PFM_PMU_INTEL_IVBEP_UNC_IMC1",	-- Intel IvyBridge-EP IMC socket 1 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_IMC2] = "PFM_PMU_INTEL_IVBEP_UNC_IMC2",	-- Intel IvyBridge-EP IMC socket 2 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_IMC3] = "PFM_PMU_INTEL_IVBEP_UNC_IMC3",	-- Intel IvyBridge-EP IMC socket 3 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_IMC4] = "PFM_PMU_INTEL_IVBEP_UNC_IMC4",	-- Intel IvyBridge-EP IMC socket 4 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_IMC5] = "PFM_PMU_INTEL_IVBEP_UNC_IMC5",	-- Intel IvyBridge-EP IMC socket 5 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_IMC6] = "PFM_PMU_INTEL_IVBEP_UNC_IMC6",	-- Intel IvyBridge-EP IMC socket 6 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_IMC7] = "PFM_PMU_INTEL_IVBEP_UNC_IMC7",	-- Intel IvyBridge-EP IMC socket 7 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_PCU] = "PFM_PMU_INTEL_IVBEP_UNC_PCU",	-- Intel IvyBridge-EP PCU uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_QPI0] = "PFM_PMU_INTEL_IVBEP_UNC_QPI0",	-- Intel IvyBridge-EP QPI link 0 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_QPI1] = "PFM_PMU_INTEL_IVBEP_UNC_QPI1",	-- Intel IvyBridge-EP QPI link 1 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_QPI2] = "PFM_PMU_INTEL_IVBEP_UNC_QPI2",	-- Intel IvyBridge-EP QPI link 2 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_UBOX] = "PFM_PMU_INTEL_IVBEP_UNC_UBOX",	-- Intel IvyBridge-EP U-Box uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_R2PCIE] = "PFM_PMU_INTEL_IVBEP_UNC_R2PCIE",	-- Intel IvyBridge-EP R2PCIe uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_R3QPI0] = "PFM_PMU_INTEL_IVBEP_UNC_R3QPI0",	-- Intel IvyBridge-EP R3QPI 0 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_R3QPI1] = "PFM_PMU_INTEL_IVBEP_UNC_R3QPI1",	-- Intel IvyBridge-EP R3QPI 1 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_R3QPI2] = "PFM_PMU_INTEL_IVBEP_UNC_R3QPI2",	-- Intel IvyBridge-EP R3QPI 2 uncore 
	[ffi.C.PFM_PMU_INTEL_IVBEP_UNC_IRP] = "PFM_PMU_INTEL_IVBEP_UNC_IRP",	-- Intel IvyBridge-EP IRP uncore 

	[ffi.C.PFM_PMU_S390X_CPUM_SF] = "PFM_PMU_S390X_CPUM_SF",		-- s390x: CPU-M sampling facility 

	[ffi.C.PFM_PMU_ARM_CORTEX_A57] = "PFM_PMU_ARM_CORTEX_A57",		-- ARM Cortex A57 (ARMv8) 
	[ffi.C.PFM_PMU_ARM_CORTEX_A53] = "PFM_PMU_ARM_CORTEX_A53",		-- ARM Cortex A53 (ARMv8) 

	[ffi.C.PFM_PMU_ARM_CORTEX_A7] = "PFM_PMU_ARM_CORTEX_A7",		-- ARM Cortex A7 

	[ffi.C.PFM_PMU_INTEL_HSW_EP] = "PFM_PMU_INTEL_HSW_EP",		-- Intel Haswell EP 
	[ffi.C.PFM_PMU_INTEL_BDW] = "PFM_PMU_INTEL_BDW",		-- Intel Broadwell EP 

	[ffi.C.PFM_PMU_ARM_XGENE] = "PFM_PMU_ARM_XGENE",		-- Applied Micro X-Gene (ARMv8) 

	-- MUST ADD NEW PMU MODELS HERE
	[ffi.C.PFM_PMU_MAX] = "PFM_PMU_MAX"			-- end marker 
}
export.EventSources = EventSources;

local PMUTypes = {
	[ffi.C.PFM_PMU_TYPE_UNKNOWN] = "PFM_PMU_TYPE_UNKNOWN";	-- unknown PMU type
	[ffi.C.PFM_PMU_TYPE_CORE] = "PFM_PMU_TYPE_CORE";	-- processor core PMU
	[ffi.C.PFM_PMU_TYPE_UNCORE] = "PFM_PMU_TYPE_UNCORE";	-- processor socket-level PMU
	[ffi.C.PFM_PMU_TYPE_OS_GENERIC] = "PFM_PMU_TYPE_OS_GENERIC"; -- generic OS-provided PMU
	[ffi.C.PFM_PMU_TYPE_MAX]= "PFM_PMU_TYPE_MAX"; 
}
export.PMUTypes = PMUTypes;


local function GetErrorString(code)
	local errorStr = export.ffi.Lib.pfm_strerror(code);
	if errorStr ~= nil then
		return ffi.string(errorStr);
	end

	return string.format("UNKNOWN ERROR: %d", code);
end

local function GetVersion()
	return export.ffi.Lib.pfm_get_version();
end

local function GetPMUInfo(pmu)
	local info = ffi.new("pfm_pmu_info_t[1]");
	local err = export.ffi.Lib.pfm_get_pmu_info(pmu, info);
	if err ~= 0 then
		return false,export.GetErrorString(err);
	end
	
	local res = {
		name = ffi.string(info[0].name);
		desc = ffi.string(info[0].desc);
		pmu = EventSources[tonumber(info[0].pmu)];
		["type"] = PMUTypes[tonumber(info[0].type)];
		nevents = info[0].nevents;
		first_event = info[0].first_event;
		max_encoding = info[0].max_encoding;
		num_cntrs = info[0].num_cntrs;
		num_fixed_cntrs = info[0].num_fixed_cntrs;
		is_present = info[0].flags.is_present;
		is_dfl = info[0].flags.is_dfl;		
	};
	
	return res;
end

-- 
-- Given a string name, lookup the numerical PMU source to match
-- if not found, then return false
--
local function PMUTypeFromName(name)
	for idx=ffi.C.PMU_NONE, ffi.C.PFM_PMU_MAX do
		if name == rawget(EventSources, idx) then
			return idx;
		end
	end

	return false
end


export.GetErrorString = GetErrorString;
export.GetVersion = GetVersion;
export.GetPMUInfo = GetPMUInfo;

return export
