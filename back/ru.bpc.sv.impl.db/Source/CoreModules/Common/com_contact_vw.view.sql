create or replace force view com_contact_vw as
select
    id
    , seqnum
    , preferred_lang
    , job_title
    , person_id
    , inst_id
from
    com_contact
/ 