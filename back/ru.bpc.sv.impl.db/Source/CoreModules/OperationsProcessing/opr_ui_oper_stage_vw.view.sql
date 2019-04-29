create or replace force view opr_ui_oper_stage_vw as
select 
     o.oper_id
     , o.proc_stage
     , com_api_dictionary_pkg.get_article_desc(o.proc_stage, l.lang) as proc_stage_desc
     , o.status
     , com_api_dictionary_pkg.get_article_desc(o.status, l.lang) as status_desc
     , l.lang
  from opr_oper_stage o  
     , com_language_vw l
/

