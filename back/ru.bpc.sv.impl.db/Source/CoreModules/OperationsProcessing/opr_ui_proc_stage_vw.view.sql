create or replace force view opr_ui_proc_stage_vw as
select n.id
     , n.msg_type
     , n.sttl_type
     , n.oper_type
     , n.proc_stage    
     , n.exec_order
     , n.parent_stage    
     , n.split_method
     , n.status
     , get_text (
         i_table_name    => 'opr_proc_stage'
         , i_column_name => 'name'
         , i_object_id   => n.id
         , i_lang        => l.lang
       ) name
     , get_text (
         i_table_name    => 'opr_proc_stage'
         , i_column_name => 'description'
         , i_object_id   => n.id
         , i_lang        => l.lang
       ) description
     , l.lang
     , n.command
     , n.result_status
  from opr_proc_stage_vw n, com_language_vw l
/
