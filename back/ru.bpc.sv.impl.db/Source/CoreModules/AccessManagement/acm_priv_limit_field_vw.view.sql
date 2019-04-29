create or replace force view acm_priv_limit_field_vw as
select 
    id
  , priv_limit_id
  , field
  , condition
  , label_id
  from acm_priv_limit_field
/
