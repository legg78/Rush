create or replace type prd_service_tpr as object (
    id                      number(8)
  , service_type_id         number(8)
  , service_type_name       varchar2(200)
  , external_code           varchar2(200)
  , service_number          varchar2(200)
  , is_active               number(1)
  , event_type              varchar2(8)
)
/
