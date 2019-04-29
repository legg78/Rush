create table sec_question (
    id              number(16) not null
    , seqnum        number(4)
    , entity_type   varchar2(8)
    , object_id     number(16)
    , question      varchar2(8)
    , word_hash     number(16)
)
/
comment on table sec_question is 'List of security questions been associated with object'
/
comment on column sec_question.id is 'Record identifier'
/
comment on column sec_question.seqnum is 'Sequential number of data version'
/
comment on column sec_question.entity_type is 'Entity type'
/
comment on column sec_question.object_id is 'Object identifier'
/
comment on column sec_question.question is 'Question (SEQU dictionary)'
/
comment on column sec_question.word_hash is 'Hash value of the security word'
/
