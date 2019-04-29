create or replace force view sec_question_word_vw as
select
    q.*
    , w.word
from
    sec_question q
    , sec_word w
where
    q.id = w.question_id
/