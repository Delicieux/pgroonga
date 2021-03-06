#include "pgroonga.h"

#include "pgrn_compatible.h"
#include "pgrn_global.h"
#include "pgrn_value.h"
#include "pgrn_variables.h"

#include <utils/guc.h>

#include <groonga.h>

#include <limits.h>

#ifdef PGRN_SUPPORT_ENUM_VARIABLE
static int PGrnLogType;
enum PGrnLogType {
	PGRN_LOG_TYPE_FILE,
	PGRN_LOG_TYPE_WINDOWS_EVENT_LOG,
	PGRN_LOG_TYPE_POSTGRESQL
};
static struct config_enum_entry PGrnLogTypeEntries[] = {
	{"file",              PGRN_LOG_TYPE_FILE,              false},
	{"windows_event_log", PGRN_LOG_TYPE_WINDOWS_EVENT_LOG, false},
	{"postgresql",        PGRN_LOG_TYPE_POSTGRESQL,        false},
	{NULL,                PGRN_LOG_TYPE_FILE,              false}
};
#endif

static char *PGrnLogPath;

#ifdef PGRN_SUPPORT_ENUM_VARIABLE
static int PGrnLogLevel;
static struct config_enum_entry PGrnLogLevelEntries[] = {
	{"none",      GRN_LOG_NONE,    false},
	{"emergency", GRN_LOG_EMERG,   false},
	{"alert",     GRN_LOG_ALERT,   false},
	{"critical",  GRN_LOG_CRIT,    false},
	{"error",     GRN_LOG_ERROR,   false},
	{"warning",   GRN_LOG_WARNING, false},
	{"notice",    GRN_LOG_NOTICE,  false},
	{"info",      GRN_LOG_INFO,    false},
	{"debug",     GRN_LOG_DEBUG,   false},
	{"dump",      GRN_LOG_DUMP,    false},
	{NULL,        GRN_LOG_NONE,    false}
};
#endif

static int PGrnLockTimeout;

#ifdef PGRN_SUPPORT_ENUM_VARIABLE
static void
PGrnPostgreSQLLoggerLog(grn_ctx *ctx, grn_log_level level,
						const char *timestamp, const char *title,
						const char *message, const char *location,
						void *user_data)
{
	const char levelMarks[] = " EACewnid-";

	if (location && location[0])
	{
		ereport(LOG,
				(errmsg("pgroonga:log: %s|%c|%s %s %s",
						timestamp, levelMarks[level], title,
						message, location)));
	}
	else
	{
		ereport(LOG,
				(errmsg("pgroonga:log: %s|%c|%s %s",
						timestamp, levelMarks[level], title, message)));
	}
}

static grn_logger PGrnPostgreSQLLogger = {
	GRN_LOG_DEFAULT_LEVEL,
	GRN_LOG_TIME | GRN_LOG_MESSAGE,
	NULL,
	PGrnPostgreSQLLoggerLog,
	NULL,
	NULL
};

static void
PGrnLogTypeAssign(int new_value, void *extra)
{
	grn_ctx *ctx = &PGrnContext;

	switch (new_value) {
	case PGRN_LOG_TYPE_WINDOWS_EVENT_LOG:
		grn_windows_event_logger_set(ctx, "PGroonga");
		break;
	case PGRN_LOG_TYPE_POSTGRESQL:
		grn_logger_set(ctx, &PGrnPostgreSQLLogger);
		break;
	default:
		grn_logger_set(ctx, NULL);
		break;
	}
}
#endif

static void
PGrnLogPathAssignRaw(const char *new_value)
{
	if (new_value) {
		if (PGrnIsNoneValue(new_value)) {
			grn_default_logger_set_path(NULL);
		} else {
			grn_default_logger_set_path(new_value);
		}
	} else {
		grn_default_logger_set_path(PGrnLogBasename);
	}
}

#ifdef PGRN_IS_GREENPLUM
static const char *
PGrnLogPathAssign(const char *new_value, bool doit, GucSource source)
{
	PGrnLogPathAssignRaw(new_value);
	return new_value;
}
#else
static void
PGrnLogPathAssign(const char *new_value, void *extra)
{
	PGrnLogPathAssignRaw(new_value);
}
#endif

#ifdef PGRN_SUPPORT_ENUM_VARIABLE
static void
PGrnLogLevelAssign(int new_value, void *extra)
{
	grn_default_logger_set_max_level(new_value);
}
#endif

static void
PGrnLockTimeoutAssignRaw(int new_value)
{
	grn_set_lock_timeout(new_value);
}

#ifdef PGRN_IS_GREENPLUM
static bool
PGrnLockTimeoutAssign(int new_value, bool doit, GucSource source)
{
	PGrnLockTimeoutAssignRaw(new_value);
	return true;
}
#else
static void
PGrnLockTimeoutAssign(int new_value, void *extra)
{
	PGrnLockTimeoutAssignRaw(new_value);
}
#endif

void
PGrnInitializeVariables(void)
{
#ifdef PGRN_SUPPORT_ENUM_VARIABLE
	DefineCustomEnumVariable("pgroonga.log_type",
							 "Log type for PGroonga.",
							 "Available log types: "
							 "[file, windows_event_log, postgresql]. "
							 "The default is file.",
							 &PGrnLogType,
							 PGRN_LOG_TYPE_FILE,
							 PGrnLogTypeEntries,
							 PGC_USERSET,
							 0,
							 NULL,
							 PGrnLogTypeAssign,
							 NULL);
#endif

	PGrnDefineCustomStringVariable("pgroonga.log_path",
								   "Log path for PGroonga.",
								   "The default is "
								   "\"${PG_DATA}/" PGrnLogBasename "\". "
								   "Use \"none\" to disable file output.",
								   &PGrnLogPath,
								   NULL,
								   PGC_USERSET,
								   0,
								   NULL,
								   PGrnLogPathAssign,
								   NULL);

#ifdef PGRN_SUPPORT_ENUM_VARIABLE
	DefineCustomEnumVariable("pgroonga.log_level",
							 "Log level for PGroonga.",
							 "Available log levels: "
							 "[none, emergency, alert, critical, "
							 "error, warning, notice, info, debug, dump]. "
							 "The default is notice.",
							 &PGrnLogLevel,
							 GRN_LOG_DEFAULT_LEVEL,
							 PGrnLogLevelEntries,
							 PGC_USERSET,
							 0,
							 NULL,
							 PGrnLogLevelAssign,
							 NULL);
#endif

	PGrnDefineCustomIntVariable("pgroonga.lock_timeout",
								"Try pgroonga.lock_timeout times "
								"at 1 msec intervals to "
								"get write lock in PGroonga.",
								"The default is 10000000. "
								"It means that PGroonga tries to get write lock "
								"between about 2.7 hours.",
								&PGrnLockTimeout,
								grn_get_lock_timeout(),
								0,
								INT_MAX,
								PGC_USERSET,
								0,
								NULL,
								PGrnLockTimeoutAssign,
								NULL);

	EmitWarningsOnPlaceholders("pgroonga");
}
