alter table aut_card add constraint aut_card_pk primary key (
    auth_id
)
/
alter table aut_card drop primary key drop index
/
alter table aut_card add (constraint aut_card_pk primary key(auth_id)
/****************** partition start ********************
    using index global
    partition by range (auth_id)
(
    partition opr_operation_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
alter table aut_card drop primary key drop index
/
alter table aut_card add (constraint aut_card_pk primary key(auth_id)
/****************** partition start ********************
    using index global
    partition by range (auth_id)
(
    partition aut_card_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
