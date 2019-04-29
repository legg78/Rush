create or replace type com_param_map_tpr as object (
    name                varchar2(200)
  , char_value          varchar2(2000)
  , number_value        number
  , date_value          date
  , condition           varchar2(200)
)
/
alter type com_param_map_tpr modify attribute char_value varchar2(32000) cascade
/
