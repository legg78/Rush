create or replace force view evt_ui_status_map_vw as
select id
     , seqnum
     , event_type
     , get_article_text(event_type) as event_type_text
     , initiator
     , get_article_text(initiator) as initiator_text
     , initial_status
     , get_article_text(initial_status) as initial_status_text
     , result_status
     , get_article_text(result_status) as result_status_text
	 , priority
     , inst_id
  from evt_status_map
/
