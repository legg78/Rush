create or replace force view pmo_ui_provider_group_vw as
select p.id
     , p.seqnum
     , p.parent_id
     , p.region_code
     , p.provider_group_number
     , p.logo_path
     , get_text(
           i_table_name  => 'pmo_provider_group'
         , i_column_name => 'label'
         , i_object_id   => p.id
         , i_lang        => l.lang
       ) as label
     , get_text(
           i_table_name  => 'pmo_provider_group'
         , i_column_name => 'description'
         , i_object_id   => p.id
         , i_lang        => l.lang
       ) as description
     , get_text(
           i_table_name  => 'pmo_provider_group'
         , i_column_name => 'short_name'
         , i_object_id   => p.id
         , i_lang        => l.lang
       ) as short_name
     , l.lang
     , p.inst_id
  from pmo_provider_group_vw p cross join com_language_vw l
 where p.inst_id in (select inst_id from acm_cu_inst_vw)
/
