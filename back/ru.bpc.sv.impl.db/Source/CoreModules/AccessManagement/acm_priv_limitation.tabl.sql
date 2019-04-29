create table acm_priv_limitation (
    id        number(8) not null
  , priv_id   number(8)
  , condition varchar2(2000)
)
/
comment on table acm_priv_limitation is 'Privilege limitations.'
/
comment on column acm_priv_limitation.id is 'Primary key.'
/
comment on column acm_priv_limitation.priv_id is 'Reference to privilege.'
/
comment on column acm_priv_limitation.condition is 'SQL condition defined access limitation.'
/
alter table acm_priv_limitation add (seqnum number(4))
/
comment on column acm_priv_limitation.seqnum is 'Data version sequentional number.'
/
alter table acm_priv_limitation add (limitation_type varchar2(8))
/
comment on column acm_priv_limitation.limitation_type is 'Privilege limitation type.'
/
