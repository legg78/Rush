alter table opr_additional_amount add (constraint opr_additional_amount_pk primary key (oper_id, amount_type)
/****************** partition start ********************
    using index global
    partition by range (oper_id)
(
    partition opr_additional_amount_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
