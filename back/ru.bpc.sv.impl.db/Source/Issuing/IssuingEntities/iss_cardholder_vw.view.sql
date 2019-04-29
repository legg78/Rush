create or replace force view iss_cardholder_vw as 
select 
    a.id
    , a.person_id
    , a.cardholder_number
    , a.cardholder_name
    , a.relation
    , a.resident
    , a.nationality 
    , a.marital_status
    , a.inst_id
    , a.seqnum
from
    iss_cardholder a
/
