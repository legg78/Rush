alter table opr_oper_detail add (
    constraint opr_oper_detail_pk primary key (id)
    using index global
/****************** partition start ********************

    partition by range (id)
    (
        partition evt_opr_oper_detail_maxvalue values less than (maxvalue)
    )
******************** partition end ********************/
)
/
