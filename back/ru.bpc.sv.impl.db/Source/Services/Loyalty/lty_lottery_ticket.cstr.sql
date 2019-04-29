alter table lty_lottery_ticket add (constraint lty_lottery_ticket_pk primary key(id)
/****************** partition start ********************
    using index global
    partition by range (id)
(
    partition lty_lottery_ticket_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
