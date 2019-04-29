create or replace type app_data_tpr as object (
    appl_data_id                number(16)
  , element_id                  number(8)
  , parent_id                   number(16)
  , serial_number               number(4)
  , element_value_v             varchar2(2000)
  , element_value_d             date
  , element_value_n             number
  , lang                        varchar2(8)
)
/
