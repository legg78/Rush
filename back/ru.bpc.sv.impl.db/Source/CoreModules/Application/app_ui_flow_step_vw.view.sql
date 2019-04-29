create or replace force view app_ui_flow_step_vw as
select a.id
     , a.seqnum
     , a.flow_id
     , com_api_i18n_pkg.get_text('app_flow_step', 'label', a.id, l.lang) as step_label
     , a.appl_status
     , a.step_source
     , a.read_only
     , a.display_order
     , l.lang
  from app_flow_step a
     , com_language_vw l
/
