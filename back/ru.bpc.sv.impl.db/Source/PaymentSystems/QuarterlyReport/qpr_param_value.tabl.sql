create table qpr_param_value(
    id  number(16) not null
  , id_param_value number(6,0)
  , year number(4,0)
  , month_num number(2,0)
  , param_group_id number(4,0)
  , cmid varchar2(12 byte)
  , inst_id varchar2(4 byte)
  , value_1 number(16,2)
  , value_2 number(16,2)
  , value_3 number(16,2)
  , curr_code varchar2(3 byte)
  , mcc varchar2(4 byte)
  , card_type varchar2(60 byte)
  , bin varchar2(6 byte))
/

comment on table qpr_param_value  is 'Values of parameters for VISA and MC quarter reports'
/
comment on column qpr_param_value.id is 'Identifier'
/
comment on column qpr_param_value.id_param_value is 'Value ID'
/
comment on column qpr_param_value.year is 'Year'
/
comment on column qpr_param_value.month_num is 'Month num'
/
comment on column qpr_param_value.param_group_id is 'Parameter group ID (refers to PS_PARAM_GROUP)'
/
comment on column qpr_param_value.cmid is 'CMID'
/
comment on column qpr_param_value.inst_id is 'Institution ID'
/
comment on column qpr_param_value.value_1 is 'Parameter value'
/
comment on column qpr_param_value.value_2 is 'Parameter value 2 (for multiple values)'
/
comment on column qpr_param_value.value_3 is 'Parameter value 3 (for multiple values)'
/
comment on column qpr_param_value.curr_code is 'Currency code (refers to EP_ISOCUR_TAB)'
/
comment on column qpr_param_value.mcc is 'MCC'
/
comment on column qpr_param_value.card_type is 'Card type'
/
comment on column qpr_param_value.bin is 'BIN'
/
alter table qpr_param_value add (card_type_id number(4))
/
comment on column qpr_param_value.card_type_id is 'Card type identifier'
/ 
alter table qpr_param_value add (card_type_feature varchar2(8))
/
comment on column qpr_param_value.card_type_feature is 'Card type feature'
/ 
