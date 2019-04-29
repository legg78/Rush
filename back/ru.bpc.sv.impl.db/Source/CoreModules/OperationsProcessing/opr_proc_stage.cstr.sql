alter table opr_proc_stage add (
  constraint opr_proc_stage_uk unique (msg_type, sttl_type, oper_type, proc_stage, split_method, status, command)
 )
/

