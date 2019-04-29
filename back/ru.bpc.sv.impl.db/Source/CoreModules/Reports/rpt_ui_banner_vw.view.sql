create or replace force view rpt_ui_banner_vw as
select a.id
     , a.seqnum
     , a.status
     , a.filename
     , a.inst_id
     , get_text ('rpt_banner', 'label', a.id, b.lang) label
     , get_text ('rpt_banner', 'description', a.id, b.lang) description
     , b.lang
  from rpt_banner a
     , com_language_vw b
 where a.inst_id in (select inst_id from acm_cu_inst_vw)
/