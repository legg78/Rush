create or replace force view evt_ui_event_type_vw as
select id
     , seqnum
     , event_type
     , entity_type
     , reason_lov_id
     , get_article_text(event_type, b.lang) as label
     , b.lang
  from evt_event_type a
     , com_language_vw b
/ 