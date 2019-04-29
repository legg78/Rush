create or replace force view pmo_ui_provider_vw as
select pg.id
     , pg.seqnum
     , pg.parent_id
     , pg.region_code
     , pg.provider_group_number as provider_number 
     , 1 as is_provider_group
     , pg.logo_path
     , get_text(
           i_table_name  => 'pmo_provider_group'
         , i_column_name => 'label'
         , i_object_id   => pg.id
         , i_lang        => l.lang
       ) as label
     , get_text(
           i_table_name  => 'pmo_provider_group'
         , i_column_name => 'description'
         , i_object_id   => pg.id
         , i_lang        => l.lang
       ) as description
     , get_text(
           i_table_name  => 'pmo_provider_group'
         , i_column_name => 'short_name'
         , i_object_id   => pg.id
         , i_lang        => l.lang
       ) as short_name
     , l.lang
     , pg.inst_id
  from pmo_provider_group_vw pg
     , com_language_vw l
 where pg.inst_id in (select inst_id from acm_cu_inst_vw)
union all
select p.id
     , p.seqnum
     , p.parent_id
     , p.region_code
     , p.provider_number
     , 0 as is_provider_group
     , p.logo_path
     , get_text(
           i_table_name  => 'pmo_provider'
         , i_column_name => 'label'
         , i_object_id   => p.id
         , i_lang        => l.lang
       ) as label
     , get_text(
           i_table_name  => 'pmo_provider'
         , i_column_name => 'description'
         , i_object_id   => p.id
         , i_lang        => l.lang
       ) as description
     , get_text(
           i_table_name  => 'pmo_provider'
         , i_column_name => 'short_name'
         , i_object_id   => p.id
         , i_lang        => l.lang
       ) as short_name
     , l.lang
     , p.inst_id
  from pmo_provider_vw p
     , com_language_vw l
 where p.inst_id in (select inst_id from acm_cu_inst_vw)
/
