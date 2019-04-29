create or replace force view opr_proc_stage_vw as
select id
     , msg_type
     , sttl_type
     , oper_type
     , proc_stage    
     , exec_order
     , parent_stage    
     , split_method
     , status
     , command
     , result_status
  from opr_proc_stage
/
