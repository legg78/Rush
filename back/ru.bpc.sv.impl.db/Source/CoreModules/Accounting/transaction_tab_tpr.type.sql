create or replace type transaction_tab_tpr as object(    
    transaction_id        number(16)
  , transaction_type      varchar2(8)
  , posting_date          date
  , conversion_rate       number
  , amount_purpose        varchar2(8)
  , entry_list            entry_tab_tpt
)
/
