#include "pgroonga.h"

#include "pgrn_global.h"
#include "pgrn_groonga.h"
#include "pgrn_match_positions_byte.h"
#include "pgrn_keywords.h"

#include <catalog/pg_type.h>
#include <utils/builtins.h>

static grn_ctx *ctx = &PGrnContext;
static grn_obj *keywordsTable = NULL;

PG_FUNCTION_INFO_V1(pgroonga_match_positions_byte);

void
PGrnInitializeMatchPositionsByte(void)
{
	keywordsTable = grn_table_create(ctx, NULL, 0, NULL,
									 GRN_OBJ_TABLE_PAT_KEY,
									 grn_ctx_at(ctx, GRN_DB_SHORT_TEXT),
									 NULL);
	grn_obj_set_info(ctx,
					 keywordsTable,
					 GRN_INFO_NORMALIZER,
					 grn_ctx_get(ctx, "NormalizerAuto", -1));
}

void
PGrnFinalizeMatchPositionsByte(void)
{
	if (!keywordsTable)
		return;

	grn_obj_close(ctx, keywordsTable);
	keywordsTable = NULL;
}

static ArrayType *
PGrnMatchPositionsByte(text *target)
{
	grn_obj buffer;
	ArrayType *positions;

	GRN_UINT32_INIT(&buffer, GRN_OBJ_VECTOR);

	{
		const char *string;
		size_t stringLength;
		int baseOffset = 0;

		string = VARDATA_ANY(target);
		stringLength = VARSIZE_ANY_EXHDR(target);

		while (stringLength > 0) {
#define MAX_N_HITS 16
			grn_pat_scan_hit hits[MAX_N_HITS];
			const char *rest;
			int i, nHits;
			size_t chunkLength;

			nHits = grn_pat_scan(ctx, (grn_pat *)keywordsTable,
								 string, stringLength,
								 hits, MAX_N_HITS, &rest);
			for (i = 0; i < nHits; i++) {
				GRN_UINT32_PUT(ctx, &buffer, hits[i].offset + baseOffset);
				GRN_UINT32_PUT(ctx, &buffer, hits[i].length);
			}

			chunkLength = rest - string;
			baseOffset += chunkLength;
			stringLength -= chunkLength;
			string = rest;
#undef MAX_N_HITS
		}
	}

	{
		int i, nElements;
		Datum *elements;
		int dims[2];
		int lbs[2];

		nElements = GRN_BULK_VSIZE(&buffer) / (sizeof(uint32_t) * 2);
		elements = palloc(sizeof(Datum) * 2 * nElements);
		for (i = 0; i < nElements; i++)
		{
			uint32_t offset;
			uint32_t length;

			offset = GRN_UINT32_VALUE_AT(&buffer, i * 2);
			length = GRN_UINT32_VALUE_AT(&buffer, i * 2 + 1);
			elements[i * 2] = Int32GetDatum(offset);
			elements[i * 2 + 1] = Int32GetDatum(length);
		}
		dims[0] = nElements;
		dims[1] = 2;
		lbs[0] = 1;
		lbs[1] = 1;
		positions = construct_md_array(elements,
									   NULL,
									   2,
									   dims,
									   lbs,
									   INT4OID,
									   sizeof(int32_t),
									   true,
									   'i');
		pfree(elements);
	}

	GRN_OBJ_FIN(ctx, &buffer);

	return positions;
}

/**
 * pgroonga.match_positions_byte(target text, keywords text[]) : integer[2][]
 */
Datum
pgroonga_match_positions_byte(PG_FUNCTION_ARGS)
{
	text *target = PG_GETARG_TEXT_PP(0);
	ArrayType *keywords = PG_GETARG_ARRAYTYPE_P(1);
	ArrayType *positions;

	PGrnKeywordsUpdateTable(keywords, keywordsTable);
	positions = PGrnMatchPositionsByte(target);

	PG_RETURN_POINTER(positions);
}
