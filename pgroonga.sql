SET search_path = public;

CREATE SCHEMA pgroonga;

CREATE FUNCTION pgroonga.score("row" record)
	RETURNS float8
	AS 'MODULE_PATHNAME', 'pgroonga_score'
	LANGUAGE C
	VOLATILE
	STRICT;

CREATE FUNCTION pgroonga.table_name(indexName cstring)
	RETURNS cstring
	AS 'MODULE_PATHNAME', 'pgroonga_table_name'
	LANGUAGE C
	VOLATILE
	STRICT;

CREATE FUNCTION pgroonga.command(groongaCommand text)
	RETURNS text
	AS 'MODULE_PATHNAME', 'pgroonga_command'
	LANGUAGE C
	VOLATILE
	STRICT;

CREATE FUNCTION pgroonga.snippet_html(target text, keywords text[])
	RETURNS text[]
	AS 'MODULE_PATHNAME', 'pgroonga_snippet_html'
	LANGUAGE C
	VOLATILE
	STRICT;

CREATE FUNCTION pgroonga.highlight_html(target text, keywords text[])
	RETURNS text
	AS 'MODULE_PATHNAME', 'pgroonga_highlight_html'
	LANGUAGE C
	VOLATILE
	STRICT;

CREATE FUNCTION pgroonga.match_positions_byte(target text, keywords text[])
	RETURNS integer[2][]
	AS 'MODULE_PATHNAME', 'pgroonga_match_positions_byte'
	LANGUAGE C
	VOLATILE
	STRICT;

CREATE FUNCTION pgroonga.match_positions_character(target text, keywords text[])
	RETURNS integer[2][]
	AS 'MODULE_PATHNAME', 'pgroonga_match_positions_character'
	LANGUAGE C
	VOLATILE
	STRICT;

CREATE FUNCTION pgroonga.query_extract_keywords(query text)
	RETURNS text[]
	AS 'MODULE_PATHNAME', 'pgroonga_query_extract_keywords'
	LANGUAGE C
	VOLATILE
	STRICT;

CREATE FUNCTION pgroonga.flush(indexName cstring)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_flush'
	LANGUAGE C
	VOLATILE
	STRICT;

CREATE FUNCTION pgroonga.match_term(target text, term text)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_match_term_text'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE FUNCTION pgroonga.match_term(target text[], term text)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_match_term_text_array'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE FUNCTION pgroonga.match_term(target varchar, term varchar)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_match_term_varchar'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE FUNCTION pgroonga.match_term(target varchar[], term varchar)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_match_term_varchar_array'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE OPERATOR %% (
	PROCEDURE = pgroonga.match_term,
	LEFTARG = text,
	RIGHTARG = text
);

CREATE OPERATOR %% (
	PROCEDURE = pgroonga.match_term,
	LEFTARG = text[],
	RIGHTARG = text
);

CREATE OPERATOR %% (
	PROCEDURE = pgroonga.match_term,
	LEFTARG = varchar,
	RIGHTARG = varchar
);

CREATE OPERATOR %% (
	PROCEDURE = pgroonga.match_term,
	LEFTARG = varchar[],
	RIGHTARG = varchar
);


CREATE FUNCTION pgroonga.match_query(text, text)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_match_query_text'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE FUNCTION pgroonga.match_query(text[], text)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_match_query_text_array'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE FUNCTION pgroonga.match_query(varchar, varchar)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_match_query_varchar'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE OPERATOR @@ (
	PROCEDURE = pgroonga.match_query,
	LEFTARG = text,
	RIGHTARG = text
);

CREATE OPERATOR @@ (
	PROCEDURE = pgroonga.match_query,
	LEFTARG = text[],
	RIGHTARG = text
);

CREATE OPERATOR @@ (
	PROCEDURE = pgroonga.match_query,
	LEFTARG = varchar,
	RIGHTARG = varchar
);


CREATE FUNCTION pgroonga.match_regexp(text, text)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_match_regexp_text'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE FUNCTION pgroonga.match_regexp(varchar, varchar)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_match_regexp_varchar'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE OPERATOR @~ (
	PROCEDURE = pgroonga.match_regexp,
	LEFTARG = text,
	RIGHTARG = text
);

CREATE OPERATOR @~ (
	PROCEDURE = pgroonga.match_regexp,
	LEFTARG = varchar,
	RIGHTARG = varchar
);


CREATE FUNCTION pgroonga.insert(internal)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_insert'
	LANGUAGE C;
CREATE FUNCTION pgroonga.beginscan(internal)
	RETURNS internal
	AS 'MODULE_PATHNAME', 'pgroonga_beginscan'
	LANGUAGE C;
CREATE FUNCTION pgroonga.gettuple(internal)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_gettuple'
	LANGUAGE C;
CREATE FUNCTION pgroonga.getbitmap(internal)
	RETURNS bigint
	AS 'MODULE_PATHNAME', 'pgroonga_getbitmap'
	LANGUAGE C;
CREATE FUNCTION pgroonga.rescan(internal)
	RETURNS void
	AS 'MODULE_PATHNAME', 'pgroonga_rescan'
	LANGUAGE C;
CREATE FUNCTION pgroonga.endscan(internal)
	RETURNS void
	AS 'MODULE_PATHNAME', 'pgroonga_endscan'
	LANGUAGE C;
CREATE FUNCTION pgroonga.build(internal)
	RETURNS internal
	AS 'MODULE_PATHNAME', 'pgroonga_build'
	LANGUAGE C;
CREATE FUNCTION pgroonga.buildempty(internal)
	RETURNS internal
	AS 'MODULE_PATHNAME', 'pgroonga_buildempty'
	LANGUAGE C;
CREATE FUNCTION pgroonga.bulkdelete(internal)
	RETURNS internal
	AS 'MODULE_PATHNAME', 'pgroonga_bulkdelete'
	LANGUAGE C;
CREATE FUNCTION pgroonga.vacuumcleanup(internal)
	RETURNS internal
	AS 'MODULE_PATHNAME', 'pgroonga_vacuumcleanup'
	LANGUAGE C;
CREATE FUNCTION pgroonga.canreturn(internal)
	RETURNS internal
	AS 'MODULE_PATHNAME', 'pgroonga_canreturn'
	LANGUAGE C;
CREATE FUNCTION pgroonga.costestimate(internal)
	RETURNS internal
	AS 'MODULE_PATHNAME', 'pgroonga_costestimate'
	LANGUAGE C;
CREATE FUNCTION pgroonga.options(internal)
	RETURNS internal
	AS 'MODULE_PATHNAME', 'pgroonga_options'
	LANGUAGE C;

DO LANGUAGE plpgsql $$
BEGIN
	EXECUTE 'DROP ACCESS METHOD IF EXISTS pgroonga CASCADE';
	CREATE FUNCTION pgroonga.handler(internal)
		RETURNS index_am_handler
		AS 'MODULE_PATHNAME', 'pgroonga_handler'
		LANGUAGE C;
	EXECUTE 'CREATE ACCESS METHOD pgroonga ' ||
		'TYPE INDEX ' ||
		'HANDLER pgroonga.handler';
EXCEPTION
	WHEN syntax_error THEN
		DELETE FROM pg_catalog.pg_am WHERE amname = 'pgroonga';
		INSERT INTO pg_catalog.pg_am VALUES(
			'pgroonga',	-- amname
			21,		-- amstrategies
			0,		-- amsupport
			true,		-- amcanorder
			true,		-- amcanorderbyop
			true,		-- amcanbackward
			true,		-- amcanunique
			true,		-- amcanmulticol
			true,		-- amoptionalkey
			true,		-- amsearcharray
			false,		-- amsearchnulls
			false,		-- amstorage
			true,		-- amclusterable
			false,		-- ampredlocks
			0,		-- amkeytype
			'pgroonga.insert',	-- aminsert
			'pgroonga.beginscan',	-- ambeginscan
			'pgroonga.gettuple',	-- amgettuple
			'pgroonga.getbitmap',	-- amgetbitmap
			'pgroonga.rescan',	-- amrescan
			'pgroonga.endscan',	-- amendscan
			0,		-- ammarkpos,
			0,		-- amrestrpos,
			'pgroonga.build',	-- ambuild
			'pgroonga.buildempty',	-- ambuildempty
			'pgroonga.bulkdelete',	-- ambulkdelete
			'pgroonga.vacuumcleanup',	-- amvacuumcleanup
			'pgroonga.canreturn',		-- amcanreturn
			'pgroonga.costestimate',	-- amcostestimate
			'pgroonga.options'	-- amoptions
		);
END;
$$;

CREATE OPERATOR CLASS pgroonga.text_full_text_search_ops DEFAULT FOR TYPE text
	USING pgroonga AS
		OPERATOR 6 pg_catalog.~~,
		OPERATOR 7 pg_catalog.~~*,
		OPERATOR 8 %%,
		OPERATOR 9 @@;

CREATE OPERATOR CLASS pgroonga.text_array_full_text_search_ops
	DEFAULT
	FOR TYPE text[]
	USING pgroonga AS
		OPERATOR 8 %% (text[], text),
		OPERATOR 9 @@ (text[], text);

CREATE OPERATOR CLASS pgroonga.varchar_full_text_search_ops FOR TYPE varchar
	USING pgroonga AS
		OPERATOR 8 %%,
		OPERATOR 9 @@;

CREATE OPERATOR CLASS pgroonga.varchar_ops DEFAULT FOR TYPE varchar
	USING pgroonga AS
		OPERATOR 1 < (text, text),
		OPERATOR 2 <= (text, text),
		OPERATOR 3 = (text, text),
		OPERATOR 4 >= (text, text),
		OPERATOR 5 > (text, text);

CREATE OPERATOR CLASS pgroonga.varchar_array_ops
	DEFAULT
	FOR TYPE varchar[]
	USING pgroonga AS
		OPERATOR 8 %% (varchar[], varchar);

CREATE OPERATOR CLASS pgroonga.bool_ops DEFAULT FOR TYPE bool
	USING pgroonga AS
		OPERATOR 1 <,
		OPERATOR 2 <=,
		OPERATOR 3 =,
		OPERATOR 4 >=,
		OPERATOR 5 >;

CREATE OPERATOR CLASS pgroonga.int2_ops DEFAULT FOR TYPE int2
	USING pgroonga AS
		OPERATOR 1 <,
		OPERATOR 2 <=,
		OPERATOR 3 =,
		OPERATOR 4 >=,
		OPERATOR 5 >;

CREATE OPERATOR CLASS pgroonga.int4_ops DEFAULT FOR TYPE int4
	USING pgroonga AS
		OPERATOR 1 <,
		OPERATOR 2 <=,
		OPERATOR 3 =,
		OPERATOR 4 >=,
		OPERATOR 5 >;

CREATE OPERATOR CLASS pgroonga.int8_ops DEFAULT FOR TYPE int8
	USING pgroonga AS
		OPERATOR 1 <,
		OPERATOR 2 <=,
		OPERATOR 3 =,
		OPERATOR 4 >=,
		OPERATOR 5 >;

CREATE OPERATOR CLASS pgroonga.float4_ops DEFAULT FOR TYPE float4
	USING pgroonga AS
		OPERATOR 1 <,
		OPERATOR 2 <=,
		OPERATOR 3 =,
		OPERATOR 4 >=,
		OPERATOR 5 >;

CREATE OPERATOR CLASS pgroonga.float8_ops DEFAULT FOR TYPE float8
	USING pgroonga AS
		OPERATOR 1 <,
		OPERATOR 2 <=,
		OPERATOR 3 =,
		OPERATOR 4 >=,
		OPERATOR 5 >;

CREATE OPERATOR CLASS pgroonga.timestamp_ops DEFAULT FOR TYPE timestamp
	USING pgroonga AS
		OPERATOR 1 <,
		OPERATOR 2 <=,
		OPERATOR 3 =,
		OPERATOR 4 >=,
		OPERATOR 5 >;

CREATE OPERATOR CLASS pgroonga.timestamptz_ops DEFAULT FOR TYPE timestamptz
	USING pgroonga AS
		OPERATOR 1 <,
		OPERATOR 2 <=,
		OPERATOR 3 =,
		OPERATOR 4 >=,
		OPERATOR 5 >;

DO LANGUAGE plpgsql $$
BEGIN
	PERFORM 1
		FROM pg_type
		WHERE typname = 'jsonb';

	IF FOUND THEN
		CREATE FUNCTION pgroonga.match_query(jsonb, text)
			RETURNS bool
			AS 'MODULE_PATHNAME', 'pgroonga_match_jsonb'
			LANGUAGE C
			IMMUTABLE
			STRICT;

		CREATE OPERATOR @@ (
			PROCEDURE = pgroonga.match_query,
			LEFTARG = jsonb,
			RIGHTARG = text
		);

		CREATE OPERATOR CLASS pgroonga.jsonb_ops DEFAULT FOR TYPE jsonb
			USING pgroonga AS
				OPERATOR 9 @@ (jsonb, text),
				OPERATOR 11 @>;
	END IF;
END;
$$;

CREATE OPERATOR CLASS pgroonga.text_regexp_ops FOR TYPE text
	USING pgroonga AS
		OPERATOR 6 pg_catalog.~~,
		OPERATOR 7 pg_catalog.~~*,
		OPERATOR 10 @~;

CREATE OPERATOR CLASS pgroonga.varchar_regexp_ops FOR TYPE varchar
	USING pgroonga AS
		OPERATOR 10 @~;


/* v2 */
CREATE FUNCTION pgroonga.match_text(text, text)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_match_text'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE OPERATOR &@ (
	PROCEDURE = pgroonga.match_text,
	LEFTARG = text,
	RIGHTARG = text
);

CREATE FUNCTION pgroonga.query_text(text, text)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_query_text'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE OPERATOR &? (
	PROCEDURE = pgroonga.query_text,
	LEFTARG = text,
	RIGHTARG = text
);

CREATE FUNCTION pgroonga.similar_text(text, text)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_similar_text'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE OPERATOR &~? (
	PROCEDURE = pgroonga.similar_text,
	LEFTARG = text,
	RIGHTARG = text
);

CREATE FUNCTION pgroonga.prefix_text(text, text)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_prefix_text'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE OPERATOR &^ (
	PROCEDURE = pgroonga.prefix_text,
	LEFTARG = text,
	RIGHTARG = text
);

CREATE FUNCTION pgroonga.prefix_rk_text(text, text)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_prefix_rk_text'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE OPERATOR &^~ (
	PROCEDURE = pgroonga.prefix_rk_text,
	LEFTARG = text,
	RIGHTARG = text
);

CREATE FUNCTION pgroonga.script_text(text, text)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_script_text'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE OPERATOR &` (
	PROCEDURE = pgroonga.script_text,
	LEFTARG = text,
	RIGHTARG = text
);

CREATE FUNCTION pgroonga.match_contain_text(text, text[])
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_match_contain_text'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE OPERATOR &@> (
	PROCEDURE = pgroonga.match_contain_text,
	LEFTARG = text,
	RIGHTARG = text[]
);

CREATE FUNCTION pgroonga.query_contain_text(text, text[])
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_query_contain_text'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE OPERATOR &?> (
	PROCEDURE = pgroonga.query_contain_text,
	LEFTARG = text,
	RIGHTARG = text[]
);

CREATE FUNCTION pgroonga.prefix_contain_text_array(text[], text)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_prefix_contain_text_array'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE OPERATOR &^> (
	PROCEDURE = pgroonga.prefix_contain_text_array,
	LEFTARG = text[],
	RIGHTARG = text
);

CREATE FUNCTION pgroonga.prefix_rk_contain_text_array(text[], text)
	RETURNS bool
	AS 'MODULE_PATHNAME', 'pgroonga_prefix_rk_contain_text_array'
	LANGUAGE C
	IMMUTABLE
	STRICT;

CREATE OPERATOR &^~> (
	PROCEDURE = pgroonga.prefix_rk_contain_text_array,
	LEFTARG = text[],
	RIGHTARG = text
);

CREATE OPERATOR CLASS pgroonga.text_full_text_search_ops_v2 FOR TYPE text
	USING pgroonga AS
		OPERATOR 6 pg_catalog.~~,
		OPERATOR 7 pg_catalog.~~*,
		OPERATOR 12 &@,
		OPERATOR 13 &?,
		OPERATOR 14 &~?,
		OPERATOR 15 &`,
		OPERATOR 18 &@> (text, text[]),
		OPERATOR 19 &?> (text, text[]);

CREATE OPERATOR CLASS pgroonga.text_term_search_ops_v2 FOR TYPE text
	USING pgroonga AS
		OPERATOR 16 &^,
		OPERATOR 17 &^~;

CREATE OPERATOR CLASS pgroonga.text_array_term_search_ops_v2 FOR TYPE text[]
	USING pgroonga AS
		OPERATOR 20 &^> (text[], text),
		OPERATOR 21 &^~> (text[], text);
