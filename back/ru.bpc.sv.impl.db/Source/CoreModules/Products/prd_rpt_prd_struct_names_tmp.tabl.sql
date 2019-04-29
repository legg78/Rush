create global temporary table prd_rpt_prd_struct_names_tmp
(
    obj_id   varchar2(30)    not null
  , obj_type varchar2(200)   not null
  , obj_name varchar2(2000)
)
on commit delete rows
/
comment on table prd_rpt_prd_struct_names_tmp is 'The table for caching attibute''s names in prefered language from dictionary.'
/
comment on column prd_rpt_prd_struct_names_tmp.obj_id is 'ID of object with type is obj_type'
/
comment on column prd_rpt_prd_struct_names_tmp.obj_type is 'Type of object'
/
comment on column prd_rpt_prd_struct_names_tmp.obj_name is 'Human-oriented name of object'
/