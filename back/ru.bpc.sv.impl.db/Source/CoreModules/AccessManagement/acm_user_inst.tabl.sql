create table acm_user_inst (
    id          number(8) not null
  , user_id     number(8) not null
  , inst_id     number(4) not null
  , is_default  number(1)
  , is_entirely number(1) )
/
comment on table acm_user_inst is 'User institutions.'
/
comment on column acm_user_inst.id is 'Primary key.'
/
comment on column acm_user_inst.user_id is 'Reference to user.'
/
comment on column acm_user_inst.inst_id is 'Reference to institution.'
/
comment on column acm_user_inst.is_default is 'Default institution flag.'
/
comment on column acm_user_inst.is_entirely is 'Access to all institution agents flag.'
/
