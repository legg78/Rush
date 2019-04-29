create table adt_detail
(
  id           number(16),
  part_key     date as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')),  -- [@skip patch]
  trail_id     number(16),
  column_name  varchar2(30),
  data_type    varchar2(30),
  data_format  varchar2(200),
  old_value    varchar2(200),
  new_value    varchar2(200)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                -- [@skip patch]

(
    partition adt_detail_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on table adt_detail is 'List of changed fields and values history.'
/

comment on column adt_detail.id is 'Primary key.'
/
comment on column adt_detail.trail_id is 'Reference to audit trail.'
/
comment on column adt_detail.column_name is 'Changed column name.'
/
comment on column adt_detail.data_type is 'Column data type.'
/
comment on column adt_detail.data_format is 'Convertation value format into varchar if value in non-varchar type.'
/
comment on column adt_detail.old_value is 'Column value before changes.'
/
comment on column adt_detail.new_value is 'Column value after changes.'
/
alter table adt_detail add (old_clob_value  CLOB)
/
alter table adt_detail add (new_clob_value  CLOB)
/
comment on column adt_detail.old_clob_value is 'Clob column value before changes.'
/
comment on column adt_detail.new_clob_value is 'Clob column value after changes.'
/
comment on column adt_detail.old_clob_value is 'CLOB column value before changes (only lines that were modified).'
/
comment on column adt_detail.new_clob_value is 'CLOB column value after changes (only lines that were modified).'
/
