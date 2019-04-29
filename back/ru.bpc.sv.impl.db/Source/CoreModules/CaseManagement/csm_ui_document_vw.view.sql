create or replace force view csm_ui_document_vw as
with doc as (
select d.id
     , d.document_type
     , d.document_number
     , d.document_date
     , t.content_type
     , d.entity_type
     , d.object_id
     , t.report_id
     , t.template_id
     , t.file_name
     , t.mime_type
     , t.save_path
     , d.inst_id     
     , c.dispute_id
     , c.id case_id
  from rpt_document d
     , csm_case c 
     , rpt_document_content t
 where d.entity_type in ('ENTT0152', 'ENTT0158') --replace to case
   and d.object_id  = c.id
   and d.id         = t.document_id
)
select doc.id
     , doc.document_type
     , doc.document_number
     , doc.document_date
     , doc.content_type
     , doc.entity_type
     , doc.object_id
     , doc.report_id
     , doc.template_id
     , doc.file_name
     , doc.mime_type
     , doc.save_path
     , doc.inst_id     
     , doc.dispute_id
     , doc.case_id
     , null msg_type
     , null msg_type_text
     , null lang
  from doc
 union all
select d.id
     , d.document_type
     , d.document_number
     , d.document_date
     , t.content_type
     , d.entity_type
     , d.object_id
     , t.report_id
     , t.template_id
     , t.file_name
     , t.mime_type
     , t.save_path
     , d.inst_id     
     , o.dispute_id
     , dc.case_id 
     , o.msg_type
     , get_article_text (o.msg_type, l.lang) msg_type_text
     , l.lang
  from rpt_document d
     , opr_operation o 
     , rpt_document_content t
     , doc dc
     , com_language_vw l
 where d.entity_type = 'ENTT0152' 
   and d.object_id   = o.id
   and o.dispute_id  = dc.dispute_id
   and d.id          = t.document_id
/


