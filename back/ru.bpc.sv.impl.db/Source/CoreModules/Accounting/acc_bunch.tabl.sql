create table acc_bunch (
    id                  number(16)
    , part_key          as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , bunch_type_id     number(4)
    , macros_id         number(16)
    , posting_date      date
    , details_data      varchar2(2000)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition acc_bunch_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)
******************** partition end ********************/
/
comment on table acc_bunch is 'Bunches of entries'
/
comment on column acc_bunch.id is 'Bunch identifier'
/
comment on column acc_bunch.bunch_type_id is 'Bunch type identifier'
/
comment on column acc_bunch.macros_id is 'Macros identifier'
/
comment on column acc_bunch.posting_date is 'Date when bunch was posted'
/
comment on column acc_bunch.details_data is 'Bunch detalisation data'
/
