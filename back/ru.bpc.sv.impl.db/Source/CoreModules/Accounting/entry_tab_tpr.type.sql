create or replace type entry_tab_tpr as object(
    entry_id              number(16)
  , balance_impact        number(1)
  , account_number        varchar2(32)
  , account_currency      varchar2(3)
  , amount_value          number(16)
  , amount_currency       varchar2(3)
)
/
