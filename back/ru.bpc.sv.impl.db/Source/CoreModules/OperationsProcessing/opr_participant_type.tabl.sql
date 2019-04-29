create table opr_participant_type
(
    id                number(4)
  , oper_type         varchar2(8)
  , participant_type  varchar2(8)
)
/
comment on table opr_participant_type is 'Connects participant type with oper type.'
/
comment on column opr_participant_type.id is 'Record identifier'
/
comment on column opr_participant_type.oper_type is 'Operation type'
/
comment on column opr_participant_type.participant_type is 'Participant type'
/
alter table opr_participant_type add (oper_reason varchar2(8))
/
comment on column opr_participant_type.oper_reason is 'Operation reason'
/
