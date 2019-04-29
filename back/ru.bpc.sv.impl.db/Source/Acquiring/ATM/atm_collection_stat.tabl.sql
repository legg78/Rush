create table atm_collection_stat
(
    id              number(16)
  , coll_id         number(12)
  , oper_type       varchar2(8)
  , currency        varchar2(3)
  , amount          number(22,4)
)
/

comment on table atm_collection_stat is 'Statistics of collections.'
/

comment on column atm_collection_stat.id is 'Primary key.'
/

comment on column atm_collection_stat.coll_id is 'Collection identifier.'
/

comment on column atm_collection_stat.oper_type is 'Operation type.'
/

comment on column atm_collection_stat.currency is 'Cyrrency of operation.'
/

comment on column atm_collection_stat.amount is 'Total amount of opertions of corresponding type and currency.'
/