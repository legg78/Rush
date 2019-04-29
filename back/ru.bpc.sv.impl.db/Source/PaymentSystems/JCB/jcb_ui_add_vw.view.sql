create or replace force view jcb_ui_add_vw as
select 
    a.id              
    , a.fin_id        
    , a.file_id       
    , a.is_incoming   
    , a.mti           
    , a.de024         
    , a.de032         
    , a.de033         
    , a.de071         
    , a.de093         
    , a.de094         
    , a.de100         
    , a.p3600         
    , a.p3600_1       
    , a.p3600_2       
    , a.p3600_3       
    , a.p3601         
    , a.p3602         
    , a.p3604         
 from jcb_add a
/
