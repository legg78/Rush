create or replace type pmo_response_tpr as object(
    order_id                number(16)
  , amount                  number(22, 4)
  , currency                varchar2(3)
  , resp_code               varchar2(8)
)
/
