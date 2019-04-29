create table prs_sort (
    id                 number(4)
    , seqnum           number(4)
    , inst_id          number(4)
    , condition        varchar2(2000)   
)
/
comment on table prs_sort is 'Used to sort the result-set for personalisation cards'
/
comment on column prs_sort.id is 'Sort identifier'
/
comment on column prs_sort.seqnum is 'Sequential number of record version'
/
comment on column prs_sort.inst_id is 'Owner institution identifier'
/
comment on column prs_sort.condition is 'Order condition (as SQL order clause part)'
/
