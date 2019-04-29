create or replace force view cln_ui_stage_transition_vw as
select st.id
     , st.seqnum
     , st.stage_id
     , st.transition_stage_id
     , st.reason_code
     , get_article_text(st.reason_code) as reason_name
     , l.lang
  from cln_stage_transition st
     , com_language_vw l
/
