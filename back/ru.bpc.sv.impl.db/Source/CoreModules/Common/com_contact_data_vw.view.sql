create or replace force view com_contact_data_vw as
select
    id
    , contact_id
    , commun_method
    , commun_address
    , start_date
    , end_date
from
    com_contact_data
/
