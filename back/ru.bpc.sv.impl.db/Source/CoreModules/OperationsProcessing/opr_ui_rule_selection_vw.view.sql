create or replace force view opr_ui_rule_selection_vw as
select
    id
    , seqnum
    , msg_type
    , proc_stage
    , sttl_type
    , oper_type
    , oper_reason
    , is_reversal
    , iss_inst_id
    , acq_inst_id
    , terminal_type
    , oper_currency
    , account_currency
    , sttl_currency
    , mod_id
    , rule_set_id
    , exec_order
from opr_rule_selection
/

