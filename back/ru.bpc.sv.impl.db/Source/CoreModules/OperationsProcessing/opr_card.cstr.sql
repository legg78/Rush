alter table opr_card add (
    constraint opr_card_pk primary key (oper_id, participant_type)
/****************** partition start ********************
    using index global
    partition by range (oper_id)
(
    partition opr_operation_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
alter table opr_card drop primary key drop index
/
alter table opr_card add (constraint opr_card_pk primary key (oper_id, participant_type)
/****************** partition start ********************
    using index global
    partition by range (oper_id)
(
    partition opr_card_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
