alter table opr_bin_info add (constraint opr_bin_info_pk primary key (oper_id, participant_type)
/****************** partition start ********************
    using index global
    partition by range (oper_id)
(
    partition opr_bin_info_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
