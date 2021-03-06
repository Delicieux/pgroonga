#pragma once

#ifdef GP_VERSION
#	define PGRN_IS_GREENPLUM
#endif

#ifndef PGRN_IS_GREENPLUM
#	define PGRN_SUPPORT_SCORE
#	define PGRN_SUPPORT_OPTIONS
#	define PGRN_SUPPORT_ENUM_VARIABLE
#	define PGRN_SUPPORT_RECHECK_PER_SCAN
#	define PGRN_SUPPORT_INDEX_ONLY_SCAN
#	define PGRN_SUPPORT_BITMAP_INDEX
#	if PG_VERSION_NUM >= 90400
#		define PGRN_SUPPORT_FILE_NODE_ID_TO_RELATION_ID
#	endif
#endif

#if PG_VERSION_NUM >= 90600
#	define PGRN_SUPPORT_CREATE_ACCESS_METHOD
#endif

#if PG_VERSION_NUM >= 90600
#	define PGRN_SUPPORT_XLOG
#endif

#ifndef ERRCODE_SYSTEM_ERROR
#	define ERRCODE_SYSTEM_ERROR ERRCODE_IO_ERROR
#endif

#ifdef PGRN_IS_GREENPLUM
#	define PGrnDefineCustomIntVariable(name,			\
									   shortDesc,		\
									   longDesc,		\
									   valueAddr,		\
									   bootValue,		\
									   minValue,		\
									   maxValue,		\
									   context,			\
									   flags,			\
									   checkHook,		\
									   assignHook,		\
									   showHook)		\
	DefineCustomIntVariable(name,						\
							shortDesc,					\
							longDesc,					\
							valueAddr,					\
							minValue,					\
							maxValue,					\
							context,					\
							assignHook,					\
							showHook)
#	define PGrnDefineCustomStringVariable(name,			\
										  shortDesc,	\
										  longDesc,		\
										  valueAddr,	\
										  bootValue,	\
										  context,		\
										  flags,		\
										  checkHook,	\
										  assignHook,	\
										  showHook)		\
	DefineCustomStringVariable(name,					\
							   shortDesc,				\
							   longDesc,				\
							   valueAddr,				\
							   context,					\
							   assignHook,				\
							   showHook)
#else
#	define PGrnDefineCustomIntVariable(name,			\
									   shortDesc,		\
									   longDesc,		\
									   valueAddr,		\
									   bootValue,		\
									   minValue,		\
									   maxValue,		\
									   context,			\
									   flags,			\
									   checkHook,		\
									   assignHook,		\
									   showHook)		\
	DefineCustomIntVariable(name,						\
							shortDesc,					\
							longDesc,					\
							valueAddr,					\
							bootValue,					\
							minValue,					\
							maxValue,					\
							context,					\
							flags,						\
							checkHook,					\
							assignHook,					\
							showHook)
#	define PGrnDefineCustomStringVariable(name,			\
										  shortDesc,	\
										  longDesc,		\
										  valueAddr,	\
										  bootValue,	\
										  context,		\
										  flags,		\
										  checkHook,	\
										  assignHook,	\
										  showHook)		\
	DefineCustomStringVariable(name,					\
							   shortDesc,				\
							   longDesc,				\
							   valueAddr,				\
							   bootValue,				\
							   context,					\
							   flags,					\
							   checkHook,				\
							   assignHook,				\
							   showHook)
#endif

#ifdef PGRN_IS_GREENPLUM
#	define IndexBuildHeapScan(heapRelation,		\
							  indexRelation,	\
							  indexInfo,		\
							  allow_sync,		\
							  callback,			\
							  callbackState)	\
	IndexBuildScan(heapRelation,				\
				   indexRelation,				\
				   indexInfo,					\
				   callback,					\
				   callbackState)
#endif
