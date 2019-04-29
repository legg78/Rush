create or replace type com_tab_column_tpr as object (
    column_name    varchar2(60)
  , data_type      varchar2(60)
  , data_length    number(4)
  , data_precision number(4)
  , data_scale     number(4)
)
/