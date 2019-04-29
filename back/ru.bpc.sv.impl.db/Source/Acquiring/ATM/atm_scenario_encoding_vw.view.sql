create or replace force view atm_scenario_encoding_vw
as 
select
    id               
  , seqnum              
  , atm_scenario_id  
  , lang             
  , reciept_encoding 
  , screen_encoding
from 
    atm_scenario_encoding
/