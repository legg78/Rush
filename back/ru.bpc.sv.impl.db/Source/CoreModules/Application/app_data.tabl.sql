create table app_data (
    id            number(16)
  , part_key      as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , appl_id       number(16)
  , element_id    number(8)
  , parent_id     number(16)
  , serial_number number(4)
  , element_value varchar2(2000)
  , is_auto       number(1)
  , lang          varchar2(8)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition app_data_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))           -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table app_data is 'Contents of exact application. Blocks, fields and values.'
/
comment on column app_data.id is 'Primary key.'
/
comment on column app_data.appl_id is 'Reference to application.'
/
comment on column app_data.element_id is 'Reference to structure element.'
/
comment on column app_data.parent_id is 'Reference to parent block.'
/
comment on column app_data.serial_number is 'One type elements serial number in parent element (block).'
/
comment on column app_data.element_value is 'Element value.'
/
comment on column app_data.is_auto is 'Flag if value was generated automaticaly.'
/
comment on column app_data.lang is 'Language code. Dictionary code - ''LANG''.'
/
alter table app_data add (split_hash number(4))
/
comment on column app_data.split_hash is 'Hash value to split further processing'
/
