create or replace type rcn_additional_amount_tpr as object (
    amount_value        number(22)
  , currency            varchar2(3)
  , amount_type         varchar2(8)
)
/
