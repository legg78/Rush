create or replace force view gui_wizard_vw as
select n.id
     , n.seqnum
     , n.maker_privilege_id
     , n.checker_privilege_id
  from gui_wizard n
/
