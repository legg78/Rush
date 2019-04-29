create or replace force view acc_ui_selection_step_vw as
select
    c.id
    , c.selection_id
    , c.exec_order
    , c.step
    , c.seqnum
from
    acc_selection_step c
/
