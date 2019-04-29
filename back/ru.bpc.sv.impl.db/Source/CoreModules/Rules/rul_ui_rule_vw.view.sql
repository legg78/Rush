create or replace force view rul_ui_rule_vw as
select
    a.id
  , a.seqnum
  , a.rule_set_id
  , a.proc_id
  , a.exec_order
from
    rul_rule a
/
