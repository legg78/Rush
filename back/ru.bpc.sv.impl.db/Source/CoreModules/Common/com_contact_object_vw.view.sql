create or replace force view com_contact_object_vw as
select
    a.id
  , a.entity_type
  , a.object_id
  , a.contact_type
  , a.contact_id
from
    com_contact_object a
/
