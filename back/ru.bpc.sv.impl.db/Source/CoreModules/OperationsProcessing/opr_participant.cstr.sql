alter table opr_participant add (
    constraint opr_participant_pk primary key(oper_id, participant_type)
/****************** partition start ********************
    using index global
    partition by range (oper_id)
(
    partition opr_operation_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
alter table opr_participant drop primary key drop index
/
alter table opr_participant add (constraint opr_participant_pk primary key(oper_id, participant_type)
/****************** partition start ********************
    using index global
    partition by range (oper_id)
(
    partition opr_participant_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
