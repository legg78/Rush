create or replace force view cln_ui_stage_vw as
select s.id
     , s.seqnum
     , s.status
     , get_article_text(i_article  => s.status) as status_name
     , s.resolution
     , get_article_text(i_article  => s.resolution) as resolution_name
  from cln_stage s
     , com_language_vw l
/
