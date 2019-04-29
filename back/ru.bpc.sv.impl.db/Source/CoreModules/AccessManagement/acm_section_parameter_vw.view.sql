create or replace force view acm_section_parameter_vw as
select a.id
     , a.seqnum
     , a.section_id
     , a.name
     , a.data_type
     , a.lov_id
from acm_section_parameter a
/
