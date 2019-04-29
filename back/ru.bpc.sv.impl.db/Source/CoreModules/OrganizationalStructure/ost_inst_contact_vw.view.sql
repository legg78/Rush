create or replace force view ost_inst_contact_vw as
select
    c.id
    , c.seqnum
    , c.preferred_lang
    , c.job_title
    , c.person_id
    , o.object_id inst_id
    , d.commun_method
    , d.commun_address
    , d.start_date
    , d.end_date
from
    com_contact c
    , com_contact_object o
    , com_contact_data d
where
    o.entity_type = 'ENTTINST'
    and o.contact_id = c.id
    and d.contact_id = c.id
/