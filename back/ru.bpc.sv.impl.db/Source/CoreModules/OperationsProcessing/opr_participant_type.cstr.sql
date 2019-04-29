alter table opr_participant_type add (
    constraint opr_participant_type_pk primary key (id)
  , constraint opr_participant_type_uk unique (oper_type, participant_type)
 )
/