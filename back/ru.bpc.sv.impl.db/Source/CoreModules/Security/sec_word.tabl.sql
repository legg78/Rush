create table sec_word (
    question_id     number(16) not null
    , word          varchar2(200)
)
/
comment on table sec_word is 'Security words (an answers on security questions)'
/
comment on column sec_word.question_id is 'Question identifier'
/
comment on column sec_word.word is 'Security word (answer)'
/