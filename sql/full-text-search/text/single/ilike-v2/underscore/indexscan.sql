CREATE TABLE memos (
  id integer,
  content text
);

INSERT INTO memos VALUES (1, '');
INSERT INTO memos VALUES (2, 'a');
INSERT INTO memos VALUES (3, 'ab');

CREATE INDEX grnindex ON memos
 USING pgroonga (content pgroonga.text_full_text_search_ops_v2);

SET enable_seqscan = off;
SET enable_indexscan = on;
SET enable_bitmapscan = off;

SELECT id, content
  FROM memos
 WHERE content ILIKE '_';

DROP TABLE memos;
