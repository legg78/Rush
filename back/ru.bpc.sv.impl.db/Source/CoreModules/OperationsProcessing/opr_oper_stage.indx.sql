create unique index opr_oper_stage_uk on opr_oper_stage (
    oper_id
    , proc_stage
)
/

create index opr_oper_stage_OPST0100 on opr_oper_stage (
    decode(status, 'OPST0100', 'OPST0100', null)
    , proc_stage
)
/
drop index opr_oper_stage_uk
/
create unique index opr_oper_stage_uk on opr_oper_stage (oper_id, proc_stage)
/****************** partition start ********************
    global
    partition by range(oper_id)
(
    partition opr_oper_stage_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
/

create index opr_oper_external_auth_ndx on opr_oper_stage (external_auth_id)
/****************** partition start ********************
    global
******************** partition end ********************/
/
