create or replace force view app_flow_vw as
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
  from app_flow a
/
