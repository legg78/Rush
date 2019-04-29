create table acm_priv_limit_field (
    id              number(8)
  , priv_limit_id   number(8)
  , field           varchar2(200)
  , condition       varchar2(2000)
  , label_id        number(24)
)
/
comment on table acm_priv_limit_field is 'Privilege limitation filelds'
/
comment on column acm_priv_limit_field.id is 'Primary key.'
/
comment on column acm_priv_limit_field.priv_limit_id is 'Reference to privilege limitation id'
/
comment on column acm_priv_limit_field.field is 'Name of field for limitation.'
/
comment on column acm_priv_limit_field.condition is 'SQL condition defined access limitation.'
/
comment on column acm_priv_limit_field.label_id is 'Reference to multilanguage message.'
/
