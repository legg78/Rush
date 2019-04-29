create or replace force view app_ui_flow_vw as
select a.id
     , a.seqnum
     , a.appl_type
     , a.template_appl_id
     , a.inst_id
     , a.is_customer_exist
     , a.is_contract_exist
     , a.customer_type
     , a.contract_type
     , a.mod_id
     , a.xslt_source
     , a.xsd_source
     , get_text('app_flow', 'label', a.id, b.lang) label
     , get_text('app_flow', 'description', a.id, b.lang) description
     , b.lang
  from app_flow a
     , com_language_vw b
 where a.inst_id in (select inst_id from acm_cu_inst_vw)
/
