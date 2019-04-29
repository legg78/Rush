create or replace force view app_flow_step_vw
as
   select a.id,
          a.seqnum,
          a.flow_id,
          a.appl_status,
          a.step_source,
          a.read_only,
          a.display_order
     from app_flow_step a
/
