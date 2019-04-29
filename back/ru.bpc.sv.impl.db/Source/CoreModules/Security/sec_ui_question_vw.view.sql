create or replace force view sec_ui_question_vw as
select
    q.*
from
    sec_question_word_vw q
/