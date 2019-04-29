create table opr_oper_stage (
    oper_id             number(16)      not null
    , part_key          as (to_date(substr(lpad(to_char(oper_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , proc_stage        varchar2(8)     not null
    , exec_order        number(4)       not null
    , status            varchar2(8)     not null
    , split_hash        number(4)       not null
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
subpartition by list (split_hash)
subpartition template
(
    <subpartition_list>
)
(
    partition opr_oper_stage_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)
******************** partition end ********************/
/

comment on table opr_oper_stage is 'Processed stages of operations'
/

comment on column opr_oper_stage.oper_id is 'Operation identifier'
/
comment on column opr_oper_stage.proc_stage is 'Processing stage (PSTG key)'
/
comment on column opr_oper_stage.exec_order is 'Execution order'
/
comment on column opr_oper_stage.status is 'Status of stage'
/
comment on column opr_oper_stage.split_hash is 'Hash value to split processing'
/
alter table opr_oper_stage add(external_auth_id varchar2(200))
/
comment on column opr_oper_stage.external_auth_id is 'External authorization identifier'
/
alter table opr_oper_stage add(is_reversal number(1))
/
comment on column opr_oper_stage.is_reversal is 'Reversal indicator'
/
