create table opr_proc_stage (
    id                  number(8)   not null
    , msg_type          varchar2(8) not null
    , sttl_type         varchar2(8) not null
    , oper_type	        varchar2(8) not null
    , proc_stage        varchar2(8) not null    
    , exec_order        number(4)   not null
    , parent_stage      varchar2(8) not null    
    , split_method      varchar2(8)
    , status            varchar2(8)
)
/

comment on table opr_proc_stage is 'Stages of processing of operations'
/

comment on column opr_proc_stage.id is 'identifier'
/

comment on column opr_proc_stage.msg_type is 'message type (MSGT key)'
/

comment on column opr_proc_stage.sttl_type is 'settlement type (STTP key)'
/

comment on column opr_proc_stage.oper_type is 'operation type (OPTP key)'
/

comment on column opr_proc_stage.proc_stage is 'Processing stage (PSTG key)'
/

comment on column opr_proc_stage.exec_order is 'Execution order'
/

comment on column opr_proc_stage.parent_stage is 'Parent processing stage (PSTG key)'
/

comment on column opr_proc_stage.split_method is 'Method of splitting of processing into threads'
/

comment on column opr_proc_stage.status is 'Initial status of stage on creation (PRST key)'
/

alter table opr_proc_stage add(command varchar2(8))
/
comment on column opr_proc_stage.command is 'Operation control command (OPCM key)'
/ 

alter table opr_proc_stage add(result_status varchar2(8))
/
comment on column opr_proc_stage.result_status is 'Processed operation status (OPST key)'
/ 
