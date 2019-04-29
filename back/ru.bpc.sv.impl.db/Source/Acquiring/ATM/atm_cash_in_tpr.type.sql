create type atm_cash_in_tpr as object (
    terminal_id       number(8)
  , face_value        number(22 ,4)
  , currency          varchar2(3)
  , denomination_code varchar2(3)
  , is_active         number(1)
)
/
alter type atm_cash_in_tpr add attribute encashed4 number(5) cascade
/
alter type atm_cash_in_tpr add attribute encashed3 number(5) cascade
/
alter type atm_cash_in_tpr add attribute encashed2 number(5) cascade
/
alter type atm_cash_in_tpr add attribute retracted4 number(5) cascade
/
alter type atm_cash_in_tpr add attribute retracted3 number(5) cascade
/
alter type atm_cash_in_tpr add attribute retracted2 number(5) cascade
/
alter type atm_cash_in_tpr add attribute counterfeit3 number(5) cascade
/
alter type atm_cash_in_tpr add attribute counterfeit2 number(5) cascade
/
