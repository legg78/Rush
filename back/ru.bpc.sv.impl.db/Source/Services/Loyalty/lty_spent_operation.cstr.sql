alter table lty_spent_operation add (constraint lty_spent_operation_pk primary key(id)
/****************** partition start ********************
    using index global
    partition by range (id)
(
    partition lty_spent_operation_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
