alter table lty_bonus add constraint lty_bonus_pk primary key (id)
/
alter table lty_bonus drop primary key drop index
/
alter table lty_bonus add (constraint lty_bonus_pk primary key(id)
/****************** partition start ********************
    using index global
    partition by range (id)
(
    partition lty_bonus_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
