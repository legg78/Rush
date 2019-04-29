create table atm_collection (
    id              number(12)
    , terminal_id   number(8)
    , start_date    date
    , start_auth_id number(16)
    , end_date      date
    , end_auth_id   number(16)
)
/
comment on table atm_collection is 'Collections of ATM terminal'
/
comment on column atm_collection.id is 'Primary key'
/
comment on column atm_collection.terminal_id is 'Terminal identifier'
/
comment on column atm_collection.start_date is 'Date when collection starts'
/
comment on column atm_collection.start_auth_id is 'Authorization which collection starts with'
/
comment on column atm_collection.end_date is 'Date when collection was finished'
/
comment on column atm_collection.end_auth_id is 'Authorization which collection ends with'
/
alter table atm_collection add collection_number number(8)
/
comment on column atm_collection.collection_number is 'Terminal collection sequential number'
/