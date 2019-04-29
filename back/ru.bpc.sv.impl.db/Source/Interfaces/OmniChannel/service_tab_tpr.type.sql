create or replace type service_tab_tpr as object(
    service_type_name     varchar2(200)
  , service_type_id       varchar2(8)  
  , service_number        varchar2(200)
  , service_type_ext_code varchar2(200)
)
/
