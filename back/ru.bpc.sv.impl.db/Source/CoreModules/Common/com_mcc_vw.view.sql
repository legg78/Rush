create or replace force view com_mcc_vw as
select id
     , seqnum
     , mcc
     , tcc
     , diners_code
     , mastercard_cab_type
from com_mcc
/
