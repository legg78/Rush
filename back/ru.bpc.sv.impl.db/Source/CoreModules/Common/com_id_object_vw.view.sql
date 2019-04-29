create or replace force view com_id_object_vw as
select a.id
     , a.seqnum
     , a.entity_type
     , a.object_id
     , a.id_type
     , a.id_series
     , a.id_number
     , a.id_issuer
     , a.id_issue_date
     , a.id_expire_date
     , a.inst_id
     , a.country
from com_id_object a
/

