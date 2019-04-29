create or replace force view rcn_ui_condition_vw as
select c.id
     , c.seqnum
     , get_text(
           i_table_name  => 'rcn_condition'
         , i_column_name => 'label'
         , i_object_id   => c.id
         , i_lang        => l.lang
       ) as name
     , c.inst_id
     , i.name as inst_name
     , c.recon_type
     , get_article_text(c.recon_type, l.lang) as recon_type_name
     , c.condition_type
     , get_article_text(c.condition_type, l.lang) as condition_type_name
     , c.condition
     , l.lang
     , c.provider_id
     , get_text(
           i_table_name  => 'pmo_condition'
         , i_column_name => 'label'
         , i_object_id   => c.provider_id
         , i_lang        => l.lang
       ) as provider_name
     , c.purpose_id
     , p.label as purpose_name
  from rcn_condition              c
     , ost_ui_institution_sys_vw  i
     , pmo_ui_purpose_vw          p
     , com_language_vw            l
 where c.inst_id    = i.id(+)
   and c.purpose_id = p.id(+)
   and i.lang       = l.lang
/
