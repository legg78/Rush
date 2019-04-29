create or replace force view com_ui_contact_data_vw as
select
    c.id contact_id
    , c.seqnum
    , c.preferred_lang
    , c.job_title
    , c.person_id
    , c.inst_id
    , d.id contact_data_id
    , d.commun_method
    , d.commun_address
    , d.start_date
    , d.end_date
from
    com_contact c
    , com_contact_data d
where
    d.contact_id = c.id
    and c.inst_id = get_user_sandbox
/
