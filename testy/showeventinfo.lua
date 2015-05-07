package.path = package.path..";".."../?.lua"

local ffi = require("ffi")
local bit = require("bit")
local band = bit.band
local bor = bit.bor

local pfm = require("pfmlib")
local common = require("test_common");
local fun = require("fun")();
local S = require("syscall");

common.appendDict(_G, common)
common.appendDict(_G, pfm)

local  MAXBUF	= 1024
local COMBO_MAX	= 18



local options = {
		compact = 0;	-- int
		sort = 0;		-- int
		encode = 0;		-- int
		combo = 0;		-- int
		combo_lim = 0;	-- int
		desc = 0;		-- int
		csv_sep = ',';	-- char *
		efilter = nil;	-- pfm_event_info_t
		ufilter = nil;	-- pfm_event_attr_info_t
		os = nil;		-- pfm_os_t
		mask = 0;		-- uint64_t
}


local function code_info_t()
	local obj = {
		code = 0;
		idx = 0;
	}
	return obj;
end

--static void show_event_info_compact(pfm_event_info_t *info);




if PFMLIB_WINDOWS then
--[[
int set_env_var(const char *var, const char *value, int ov)
{
	size_t len;
	char *str;
	int ret;

	len = strlen(var) + 1 + strlen(value) + 1;

	str = malloc(len);
	if (!str)
		return PFM_ERR_NOMEM;

	sprintf(str, "%s=%s", var, value);

	ret = putenv(str);

	free(str);

	return ret ? PFM_ERR_INVAL : PFM_SUCCESS;
}
--]]
else
local function set_env_var(var, value, ov)
	return S.setenv(var, value, ov);
end
end

-- indicated by a double colon
local function event_has_pname(s)
	return s:find("::")
end

-- char *buf, int plm, int max_encoding
local function print_codes(buf, plm, max_encoding)

	local codes = ffi.new("uint64_t *[1]");
	local count = ffi.new("int[1]")

	local ret = pfm.Lib.pfm_get_event_encoding(buf, bor(PFM_PLM0,PFM_PLM3), nil, nil, codes, count);
	if ret ~= PFM_SUCCESS then 
		if ret == PFM_ERR_NOTFOUND then
			errx(1, "encoding failed, try setting env variable LIBPFM_ENCODE_INACTIVE=1");
		end

		return -1;
	end

	for j = 0, max_encoding-1 do
		if j < count[0] then
			printf("0x%x", tonumber(codes[j]));
		end
		printf("%s", options.csv_sep);
	end

	ffi.C.free(codes[0]);

	return 0;
end


local function check_valid(buf, plm)
	local codes = ffi.new("uint64_t *[1]");
	local count = ffi.new("int[1]")
	local ret = pfm.Lib.pfm_get_event_encoding(buf, bor(PFM_PLM0,PFM_PLM3), nil, nil, codes, count);
	if ret ~= pfm.PFM_SUCCESS then
		return false;
	end

	ffi.C.free(codes[0]);

	return true;
end

--pfm_event_attr_info_t *info
local function match_ufilters(info)

	local ufilter1 = 0;
	local ufilter2 = 0;

	if (options.ufilter.is_dfl) then
		ufilter1 = bor(ufilter1, 0x1);
	end

	if (info.is_dfl) then
		ufilter2 = bor(ufilter2, 0x1);
	end

	if (options.ufilter.is_precise) then
		ufilter1 = bor(ufilter1, 0x2);
	end

	if (info.is_precise) then
		ufilter2 = bor(ufilter2, 0x2);
	end

	if (ufilter1 == 0) then
		return 1;
	end

	-- at least one filter matches
	return band(ufilter1, ufilter2);
end


--pfm_event_info_t *info
-- pmuevent info
local function match_efilters(info)

	pfm_event_attr_info_t ainfo;
	int n = 0;
	int i, ret;

	if (options.efilter.is_precise and not info.isPrecise) then
		return 0;
	end

	memset(&ainfo, 0, sizeof(ainfo));
	ainfo.size = sizeof(ainfo);

	each(function(ainfo) 
			if match_ufilters(ainfo) then
				return 1;
			end

			if ainfo.type == ffi.C.PFM_ATTR_UMASK then
				n = n+1;
			end
		end, info:attributes())
	
--[[
	pfm_for_each_event_attr(i, info) {
		ret = pfm_get_event_attr_info(info->idx, i, options.os, &ainfo);
		if (ret != PFM_SUCCESS)
			continue;
		if (match_ufilters(&ainfo))
			return 1;
                if (ainfo.type == PFM_ATTR_UMASK)
		        n++;
	}
-]]
	if 0 ~= n then 
		return 0 
	end

	return 1
end

--[[
local function show_event_info_combo(pfm_event_info_t *info)

	pfm_event_attr_info_t *ainfo;
	pfm_pmu_info_t pinfo;
	char buf[MAXBUF];
	size_t len;
	int numasks = 0;
	int i, j, ret;
	uint64_t total, m, u;

	memset(&pinfo, 0, sizeof(pinfo));

	pinfo.size = sizeof(pinfo);

	ret = pfm_get_pmu_info(info->pmu, &pinfo);
	if (ret != PFM_SUCCESS)
		errx(1, "cannot get PMU info");

	ainfo = calloc(info->nattrs, sizeof(*ainfo));
	if (!ainfo)
		err(1, "event %s : ", info->name);

	/*
	 * extract attribute information and count number
	 * of umasks
	 *
	 * we cannot just drop non umasks because we need
	 * to keep attributes in order for the enumeration
	 * of 2^n
	 */
	pfm_for_each_event_attr(i, info) {
		ainfo[i].size = sizeof(*ainfo);

		ret = pfm_get_event_attr_info(info->idx, i, options.os, &ainfo[i]);
		if (ret != PFM_SUCCESS)
			errx(1, "cannot get attribute info: %s", pfm_strerror(ret));

		if (ainfo[i].type == PFM_ATTR_UMASK)
			numasks++;
	}
	if (numasks > options.combo_lim) {
		warnx("event %s has too many umasks to print all combinations, dropping to simple enumeration", info->name);
		free(ainfo);
		show_event_info_compact(info);
		return;
	}

	if (numasks) {
		if (info->nattrs > (int)((sizeof(total)<<3))) {
			warnx("too many umasks, cannot show all combinations for event %s", info->name);
			goto end;
		}
		total = 1ULL << info->nattrs;

		for (u = 1; u < total; u++) {
			len = sizeof(buf);
			len -= snprintf(buf, len, "%s::%s", pinfo.name, info->name);
			if (len <= 0) {
				warnx("event name too long%s", info->name);
				goto end;
			}
			for(m = u, j = 0; m; m >>=1, j++) {
				if (m & 0x1ULL) {
					/* we have hit a non umasks attribute, skip */
					if (ainfo[j].type != PFM_ATTR_UMASK)
						break;

					if (len < (1 + strlen(ainfo[j].name))) {
						warnx("umasks combination too long for event %s", buf);
						break;
					}
					strncat(buf, ":", len-1);buf[len-1] = '\0'; len--;
					strncat(buf, ainfo[j].name, len-1);buf[len-1] = '\0';
					len -= strlen(ainfo[j].name);
				}
			}
			-- if found a valid umask combination, check encoding
			if (m == 0) then
				if (options.encode)
					ret = print_codes(buf, bor(PFM_PLM0,PFM_PLM3), pinfo.max_encoding);
				else
					ret = check_valid(buf, bor(PFM_PLM0,PFM_PLM3));
				if (ret)
					printf("%s\n", buf);
			end
		}
	else
		snprintf(buf, sizeof(buf)-1, "%s::%s", pinfo.name, info->name);
		buf[sizeof(buf)-1] = '\0';

		ret = options.encode ? print_codes(buf, PFM_PLM0|PFM_PLM3, pinfo.max_encoding) : 0;
		if (!ret)
			printf("%s\n", buf);
	end
end_label:
	free(ainfo);
end

local function show_event_info_compact(pfm_event_info_t *info)

	pfm_event_attr_info_t ainfo;
	pfm_pmu_info_t pinfo;
	char buf[MAXBUF];
	int i, ret, um = 0;

	memset(&ainfo, 0, sizeof(ainfo));
	memset(&pinfo, 0, sizeof(pinfo));

	pinfo.size = sizeof(pinfo);
	ainfo.size = sizeof(ainfo);

	ret = pfm_get_pmu_info(info->pmu, &pinfo);
	if (ret != PFM_SUCCESS)
		errx(1, "cannot get pmu info: %s", pfm_strerror(ret));

	pfm_for_each_event_attr(i, info) {
		ret = pfm_get_event_attr_info(info->idx, i, options.os, &ainfo);
		if (ret != PFM_SUCCESS)
			errx(1, "cannot get attribute info: %s", pfm_strerror(ret));

		if (ainfo.type != PFM_ATTR_UMASK)
			continue;

		if (!match_ufilters(&ainfo))
			continue;

		snprintf(buf, sizeof(buf)-1, "%s::%s:%s", pinfo.name, info->name, ainfo.name);
		buf[sizeof(buf)-1] = '\0';

		ret = 0;
		if (options.encode) {
			ret = print_codes(buf, PFM_PLM0|PFM_PLM3, pinfo.max_encoding);
		}
		if (!ret) {
			printf("%s", buf);
			if (options.desc) {
				printf("%s", options.csv_sep);
				printf("\"%s. %s.\"", info->desc, ainfo.desc);
			}
			putchar('\n');
		}
		um++;
	}
	if (um == 0) {
		if (!match_efilters(info))
			return;

		snprintf(buf, sizeof(buf)-1, "%s::%s", pinfo.name, info->name);
		buf[sizeof(buf)-1] = '\0';
		if (options.encode) {
			ret = print_codes(buf, PFM_PLM0|PFM_PLM3, pinfo.max_encoding);
			if (ret)
				return;
		}
		printf("%s", buf);
		if (options.desc) {
			printf("%s", options.csv_sep);
			printf("\"%s.\"", info->desc);
		}
		putchar('\n');
	}
end

local function compare_codes(const void *a, const void *b)

	const code_info_t *aa = a;
	const code_info_t *bb = b;
	local m = options.mask;

	if ((aa->code & m) < (bb->code &m))
		return -1;
	if ((aa->code & m) == (bb->code & m))
		return 0;
	
	return 1;
end
--]]

--pfm_event_info_t *info
local function print_event_flags(info)

	local n = 0;

	if info.is_precise>0 then
		common.printf("[precise] ");
		n = n+1;
	end

	if n==0 then
		common.printf("None");
	end
end

--[[
local function print_attr_flags(pfm_event_attr_info_t *info)

	int n = 0;

	if (info->is_dfl) {
		printf("[default] ");
		n++;
	}

	if (info->is_precise) {
		printf("[precise] ");
		n++;
	}

	if (!n)
		printf("None ");
end
--]]

-- pfm_event_info_t *info
local function show_event_info(info)
--[[
	pfm_event_attr_info_t ainfo;
	pfm_pmu_info_t pinfo;
	int mod = 0, um = 0;
	int i, ret;
	const char *src;

	memset(&ainfo, 0, sizeof(ainfo));
	memset(&pinfo, 0, sizeof(pinfo));

	pinfo.size = sizeof(pinfo);
	ainfo.size = sizeof(ainfo);

	if (!match_efilters(info))
		return;
	ret = pfm_get_pmu_info(info->pmu, &pinfo);
	if (ret)
		errx(1, "cannot get pmu info: %s", pfm_strerror(ret));

	printf("#-----------------------------\n"
	       "IDX	 : %d\n"
	       "PMU name : %s (%s)\n"
	       "Name     : %s\n"
	       "Equiv	 : %s\n",
		info->idx,
		pinfo.name,
		pinfo.desc,
		info->name,
		info->equiv ? info->equiv : "None");

	printf("Flags    : ");
	print_event_flags(info);
	putchar('\n');

	printf("Desc     : %s\n", info->desc ? info->desc : "no description available");
	printf("Code     : 0x%"PRIx64"\n", info->code);

	pfm_for_each_event_attr(i, info) {
		ret = pfm_get_event_attr_info(info->idx, i, options.os, &ainfo);
		if (ret != PFM_SUCCESS)
			errx(1, "cannot retrieve event %s attribute info: %s", info->name, pfm_strerror(ret));

		if (ainfo.ctrl >= PFM_ATTR_CTRL_MAX) {
			warnx("event: %s has unsupported attribute source %d", info->name, ainfo.ctrl);
			ainfo.ctrl = PFM_ATTR_CTRL_UNKNOWN;
		}
		src = srcs[ainfo.ctrl];
		switch(ainfo.type) {
		case PFM_ATTR_UMASK:
			if (!match_ufilters(&ainfo))
				continue;

			printf("Umask-%02u : 0x%02"PRIx64" : %s : [%s] : ",
				um,
				ainfo.code,
				src,
				ainfo.name);

			print_attr_flags(&ainfo);

			putchar(':');

			if (ainfo.equiv)
				printf(" Alias to %s", ainfo.equiv);
			else
				printf(" %s", ainfo.desc);

			putchar('\n');
			um++;
			break;
		case PFM_ATTR_MOD_BOOL:
			printf("Modif-%02u : 0x%02"PRIx64" : %s : [%s] : %s (boolean)\n", mod, ainfo.code, src, ainfo.name, ainfo.desc);
			mod++;
			break;
		case PFM_ATTR_MOD_INTEGER:
			printf("Modif-%02u : 0x%02"PRIx64" : %s : [%s] : %s (integer)\n", mod, ainfo.code, src, ainfo.name, ainfo.desc);
			mod++;
			break;
		default:
			printf("Attr-%02u  : 0x%02"PRIx64" : %s : [%s] : %s\n", i, ainfo.code, ainfo.name, src, ainfo.desc);
		}
	}
--]]
end

-- char *event, regex_t *preg
local function show_info(event, preg)
--[[
	pfm_pmu_info_t pinfo;
	pfm_event_info_t info;
	int i, j, ret, match = 0, pname;
	size_t len, l = 0;
	char *fullname = NULL;

	memset(&pinfo, 0, sizeof(pinfo));
	memset(&info, 0, sizeof(info));

	pinfo.size = sizeof(pinfo);
	info.size = sizeof(info);

	pname = event_has_pname(event);

	/*
	 * scan all supported events, incl. those
	 * from undetected PMU models
	 */
	pfm_for_all_pmus(j) {

		ret = pfm_get_pmu_info(j, &pinfo);
		if (ret != PFM_SUCCESS)
			continue;

		/* no pmu prefix, just look for detected PMU models */
		if (!pname && !pinfo.is_present)
			continue;

		for (i = pinfo.first_event; i != -1; i = pfm_get_event_next(i)) {
			ret = pfm_get_event_info(i, options.os, &info);
			if (ret != PFM_SUCCESS)
				errx(1, "cannot get event info: %s", pfm_strerror(ret));

			len = strlen(info.name) + strlen(pinfo.name) + 1 + 2;
			if (len > l) {
				l = len;
				fullname = realloc(fullname, l);
				if (!fullname)
					err(1, "cannot allocate memory");
			}
			sprintf(fullname, "%s::%s", pinfo.name, info.name);

			if (regexec(preg, fullname, 0, NULL, 0) == 0) {
				if (options.compact)
					if (options.combo)
						show_event_info_combo(&info);
					else
						show_event_info_compact(&info);
				else
					show_event_info(&info);
				match++;
			}
		}
	}
	if (fullname)
		free(fullname);
--]]
	return match;
end

-- char *event, regex_t *preg
local function show_info_sorted(event, preg)
--[[
	pfm_pmu_info_t pinfo;
	pfm_event_info_t info;
	unsigned int j;
	int i, ret, n, match = 0;
	size_t len, l = 0;
	char *fullname = NULL;
	code_info_t *codes;

	memset(&pinfo, 0, sizeof(pinfo));
	memset(&info, 0, sizeof(info));

	pinfo.size = sizeof(pinfo);
	info.size = sizeof(info);

	pfm_for_all_pmus(j) {

		ret = pfm_get_pmu_info(j, &pinfo);
		if (ret != PFM_SUCCESS)
			continue;

		codes = malloc(pinfo.nevents * sizeof(*codes));
		if (!codes)
			err(1, "cannot allocate memory\n");

		/* scans all supported events */
		n = 0;
		for (i = pinfo.first_event; i != -1; i = pfm_get_event_next(i)) {

			ret = pfm_get_event_info(i, options.os, &info);
			if (ret != PFM_SUCCESS)
				errx(1, "cannot get event info: %s", pfm_strerror(ret));

			if (info.pmu != j)
				continue;

			codes[n].idx = info.idx;
			codes[n].code = info.code;
			n++;
		}
		qsort(codes, n, sizeof(*codes), compare_codes);
		for(i=0; i < n; i++) {
			ret = pfm_get_event_info(codes[i].idx, options.os, &info);
			if (ret != PFM_SUCCESS)
				errx(1, "cannot get event info: %s", pfm_strerror(ret));

			len = strlen(info.name) + strlen(pinfo.name) + 1 + 2;
			if (len > l) {
				l = len;
				fullname = realloc(fullname, l);
				if (!fullname)
					err(1, "cannot allocate memory");
			}
			sprintf(fullname, "%s::%s", pinfo.name, info.name);

			if (regexec(preg, fullname, 0, NULL, 0) == 0) {
				if (options.compact)
					show_event_info_compact(&info);
				else
					show_event_info(&info);
				match++;
			}
		}
		free(codes);
	}
	if (fullname)
		free(fullname);
--]]
	return match;
end

local function usage()

	common.printf([[
showevtinfo [-L] [-E] [-h] [-s] [-m mask]
	-L 		list one event per line (compact mode)
	-E 		list one event per line with encoding (compact mode)
	-M 		display all valid unit masks combination (use with -L or -E)
	-h 		get help
	-s 		sort event by PMU and by code based on -m mask
	-l 		maximum number of umasks to list all combinations (default: %d)
	-F 		show only events and attributes with certain flags (precise,...)
	-m mask 	hexadecimal event code mask, bits to match when sorting
	-x sep 		use sep as field separator in compact mode
	-D 		print event description in compact mode
	-O os 	show attributes for the specific operating system]],
	COMBO_MAX);
end
--[[
/*
 * keep: [pmu::]event
 * drop everything else
 */
	static void
drop_event_attributes(char *str)
{
	char *p;

	p = strchr(str, ':');
	if (!p)
		return;

	str = p+1;
	/* keep PMU name */
	if (*str == ':')
		str++;

	/* stop string at 1st attribute */
	p = strchr(str, ':');
	if (p)
		*p = '\0';
}
--]]

--[[
struct attr_flags {
	const char *name;
	int ebit; /* bit position in pfm_event_info_t.flags, -1 means ignore */
	int ubit; /*  bit position in pfm_event_attr_info_t.flags, -1 means ignore */
};
--]]

local event_flags={
	[0] = {name = "precise", ebit = 0, ubit=1},
	[1] = {name = "pebs", ebit=0, ubit=1},
	[2] = {name = "default", ebit=-1, ubit=0},
	[3] = {name = "dfl", ebit=-1, ubit=0},
	[4] = {name = nil, ebit=0, ubit=0}
};


-- char *arg
local function parse_filters(arg)
--[[
	-- arg represents a comma separated list of event arguments
	-- iterate over them, matching to items in event_flags
	const struct attr_flags *attr;
	char *p;

	while (arg) {
		p = strchr(arg, ',');
		if (p)
			*p++ = 0;

		for (attr = event_flags; attr->name; attr++) {
			if (!strcasecmp(attr->name, arg)) {
				switch(attr->ebit) {
				case 0:
					options.efilter.is_precise = 1;
					break;
				case -1:
					break;
				default:
					errx(1, "unknown event flag %d", attr->ebit);
				}
				switch (attr->ubit) {
				case 0:
					options.ufilter.is_dfl = 1;
					break;
				case 1:
					options.ufilter.is_precise = 1;
					break;
				case -1:
					break;
				default:
					errx(1, "unknown umaks flag %d", attr->ubit);
				}
				break;
			}
		}
		arg = p;
	}
--]]
end


local supported_oses={
	{ name = "none", os = ffi.C.PFM_OS_NONE },
	{ name = "raw", os = ffi.C.PFM_OS_NONE },
	{ name = "pmu", os = ffi.C.PFM_OS_NONE },

	{ name = "perf", os = PFM_OS_PERF_EVENT},
	{ name = "perf_ext", os = PFM_OS_PERF_EVENT_EXT},
	{ name = nil, }
};

local pmu_types={
	[ffi.C.PFM_PMU_TYPE_UNKNOWN] = "unknown type",
	[ffi.C.PFM_PMU_TYPE_CORE] = "core",
	[ffi.C.PFM_PMU_TYPE_UNCORE] = "uncore",
	[ffi.C.PFM_PMU_TYPE_OS_GENERIC] = "OS generic",
};

local function setup_os(ostr)

	for idx, entry in ipairs(supported_oses) do 
		if entry.name == ostr then
			options.os = entry.os;
			return; 
		end
	end

	common.printf("unknown OS layer %s, choose from:", ostr);
	-- print the valid choices
	for _,entry in ipairs(supported_oses) do
		io.write(string.format("%s, ", entry.name))
	end
	print();

	error()
end

local function main(argc, argv)
	local default_sep = "\t";
	local ostr = nil;
	local endptr = nil;

--[[
	static char *argv_all[2] = { ".*", NULL };
	char **args;
	int i, match;
	regex_t preg;
	int ret, c;
--]]

	pinfo = ffi.new("pfm_pmu_info_t");
	--memset(&pinfo, 0, sizeof(pinfo));
	pinfo.size = ffi.sizeof(pinfo);

--[[
	while ((c=getopt(argc, argv,"hELsm:Ml:F:x:DO:")) ~= -1) {
		switch(c) {
			case 'L':
				options.compact = 1;
				break;
			case 'F':
				parse_filters(optarg);
				break;
			case 'E':
				options.compact = 1;
				options.encode = 1;
				break;
			case 'M':
				options.combo = 1;
				break;
			case 's':
				options.sort = 1;
				break;
			case 'D':
				options.desc = 1;
				break;
			case 'l':
				options.combo_lim = atoi(optarg);
				break;
			case 'x':
				options.csv_sep = optarg;
				break;
			case 'O':
				ostr = optarg;
				break;
			case 'm':
				options.mask = strtoull(optarg, &endptr, 16);
				if (*endptr)
					errx(1, "mask must be in hexadecimal\n");
				break;
			case 'h':
				usage();
				return 0;
			default:
				errx(1, "unknown option error");
		}
	}
--]]

	-- to allow encoding of events from non detected PMU models
	--ret = set_env_var("LIBPFM_ENCODE_INACTIVE", "1", 1);
	--if (ret ~= PFM_SUCCESS) then
	--	errx(1, "cannot force inactive encoding");
	--end

	if (options.mask == 0) then
		options.mask = bnot(0);
	end

	if (optind == argc) then
		args = argv_all;
	else 
		args = argv + optind;
	end

	if (not options.csv_sep) then
		options.csv_sep = default_sep;
	end

	-- avoid combinatorial explosion
	if (options.combo_lim == 0) then
		options.combo_lim = COMBO_MAX;
	end

	if (ostr) then
		setup_os(ostr);
	else
		options.os = ffi.C.PFM_OS_NONE;
	end

--[[
	if (not options.compact) then
		int total_supported_events = 0;
		int total_available_events = 0;

		printf("Supported PMU models:\n");
		pfm_for_all_pmus(i) {
			ret = pfm_get_pmu_info(i, &pinfo);
			if (ret != PFM_SUCCESS)
				continue;

			printf("\t[%d, %s, \"%s\"]\n", i, pinfo.name,  pinfo.desc);
		}

		printf("Detected PMU models:\n");
		pfm_for_all_pmus(i) {
			ret = pfm_get_pmu_info(i, &pinfo);
			if (ret != PFM_SUCCESS)
				continue;

			if (pinfo.is_present) {
				if (pinfo.type >= PFM_PMU_TYPE_MAX)
					pinfo.type = PFM_PMU_TYPE_UNKNOWN;

				printf("\t[%d, %s, \"%s\", %d events, %d max encoding, %d counters, %s PMU]\n",
				       i,
				       pinfo.name,
				       pinfo.desc,
				       pinfo.nevents,
				       pinfo.max_encoding,
				       pinfo.num_cntrs + pinfo.num_fixed_cntrs,
				       pmu_types[pinfo.type]);

				total_supported_events += pinfo.nevents;
			}
			total_available_events += pinfo.nevents;
		}
		printf("Total events: %d available, %d supported\n", total_available_events, total_supported_events);
	}

	while(*args) {
		/* drop umasks and modifiers */
		drop_event_attributes(*args);
		if (regcomp(&preg, *args, REG_ICASE))
			errx(1, "error in regular expression for event \"%s\"", *argv);

		if (options.sort)
			match = show_info_sorted(*args, &preg);
		else
			match = show_info(*args, &preg);

		if (match == 0)
			errx(1, "event %s not found", *args);

		args++;
	}

	regfree(&preg);
--]]
	pfm.Lib.pfm_terminate();

	return 0;
end

return main(#arg, arg)


