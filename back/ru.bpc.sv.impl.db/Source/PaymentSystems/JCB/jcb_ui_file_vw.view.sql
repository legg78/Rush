create or replace force view jcb_ui_file_vw as
select
    a.id                  
    , a.inst_id           
    , a.network_id        
    , a.is_incoming       
    , a.proc_date         
    , a.session_file_id   
    , a.is_rejected       
    , a.reject_id             
    , a.header_mti        
    , a.header_de024      
    , a.p3901             
    , a.p3901_1           
    , a.p3901_2           
    , a.p3901_3            
    , a.p3901_4             
    , a.header_de071      
    , a.trailer_mti       
    , a.trailer_de024     
    , a.p3902             
    , a.p3903             
    , a.trailer_de071      
from jcb_file a
/
