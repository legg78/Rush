create or replace force view com_company_vw as
select a.id
     , a.seqnum
     , a.embossed_name
     , a.incorp_form
     , a.inst_id
  from com_company a
/
