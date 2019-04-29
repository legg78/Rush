create or replace force view com_ui_id_object_vw as
select a.id
     , a.seqnum
     , a.entity_type
     , a.object_id
     , a.id_type
     , a.id_series
     , a.id_number
     , a.id_issuer
     , a.id_issue_date
     , a.id_expire_date
     , a.inst_id
     , a.country
     , get_text (
           i_table_name  => 'com_id_object'
         , i_column_name => 'DESCRIPTION'
         , i_object_id   => a.id
         , i_lang        => l.lang
      ) description
     , l.lang
  from com_id_object_vw a
     , com_language_vw l
where a.inst_id = get_user_sandbox
/
