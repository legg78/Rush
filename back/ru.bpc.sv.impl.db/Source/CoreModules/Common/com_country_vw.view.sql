create or replace force view com_country_vw as
select id
     , seqnum
     , code
     , name
     , curr_code
     , visa_country_code
     , mastercard_region
     , mastercard_eurozone
     , visa_region
     , sepa_indicator
from com_country
/

