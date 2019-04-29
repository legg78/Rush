create or replace force view dsp_ui_due_date_limit_vw as
select a.id
     , a.seqnum      
     , a.standard_id
     , get_text(i_table_name => 'CMN_STANDARD'
              , i_column_name => 'LABEL'
              , i_object_id  => a.id
              , i_lang       => b.lang)       as standard_name
     , get_label_text(a.message_type, b.lang) as message_type
     , a.is_incoming      
     , a.reason_code      
     , a.respond_due_date 
     , a.resolve_due_date 
     , a.usage_code
     , b.lang
  from dsp_due_date_limit_vw a
     , com_language_vw b
/

