create or replace force view aup_ui_card_status_resp_vw as
select
    n.id
    , n.seqnum
    , n.inst_id
    , n.oper_type
    , n.card_state
    , n.card_status
    , n.pin_presence
    , n.resp_code
    , n.priority
    , n.msg_type
    , n.participant_type
from
    aup_card_status_resp n
/
