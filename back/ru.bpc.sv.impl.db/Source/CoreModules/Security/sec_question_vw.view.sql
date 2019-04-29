create or replace force view sec_question_vw as
select
    q.id
  , q.seqnum
  , q.entity_type
  , q.object_id
  , q.question
  , q.word_hash
from
    sec_question q
/
