create or replace force view com_ui_contact_object_vw as
select
    o.id contact_object_id
    , o.entity_type
    , o.object_id
    , o.contact_type
    , c.id contact_id
    , c.seqnum
    , c.preferred_lang
    , c.job_title
    , c.person_id
    , c.inst_id
from
    com_contact_object o
    , com_contact c
where
    o.contact_id = c.id
    and c.inst_id = get_user_sandbox
/
