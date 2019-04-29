create or replace force view gui_wizard_step_vw as
select n.id
     , n.seqnum
     , n.wizard_id
     , n.step_order
     , n.step_source
  from gui_wizard_step n
/
