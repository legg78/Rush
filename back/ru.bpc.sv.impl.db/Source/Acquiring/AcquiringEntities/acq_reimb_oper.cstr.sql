alter table acq_reimb_oper add constraint acq_reimb_oper_pk primary key (id)
/
alter table acq_reimb_oper drop primary key drop index
/
alter table acq_reimb_oper add constraint acq_reimb_oper_pk primary key (id)
/****************** partition start ********************
    using index global
    partition by range (id)
(
    partition acq_reimb_oper_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
/
