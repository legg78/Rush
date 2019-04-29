create or replace force view acm_ui_role_privilege_vw as
select ar.id as role_id
     , ar.name as role_name
     , ap.id as priv_id
     , ap.name as priv_name
     , get_text(i_table_name => 'acm_privilege', i_column_name => 'label', i_object_id => ap.id, i_lang => l.lang) priv_label
     , get_text(i_table_name => 'acm_priv_limitation', i_column_name => 'label', i_object_id => arp.limit_id, i_lang => l.lang) limitation_label
     , arp.limit_id
     , l.lang
     , arp.filter_limit_id
     , get_text(
           i_table_name  => 'acm_priv_limitation'
         , i_column_name => 'label'
         , i_object_id   => arp.filter_limit_id
         , i_lang        => l.lang
       ) filter_limit_label
  from acm_role ar
     , acm_role_privilege arp
     , acm_privilege ap
     , com_language_vw l
 where ar.id = arp.role_id
   and arp.priv_id = ap.id
/
