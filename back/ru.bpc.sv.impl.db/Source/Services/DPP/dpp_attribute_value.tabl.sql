create table dpp_attribute_value(
    id         number(16)    not null
  , part_key   as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , dpp_id     number(16)    not null
  , attr_id    number(8)     not null
  , mod_id     number(4)     not null
  , value      varchar2(200) not null
  , split_hash number(4)     not null
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                         -- [@skip patch]
subpartition by list (split_hash)                                                           -- [@skip patch]
subpartition template                                                                       -- [@skip patch]
(                                                                                           -- [@skip patch]
    <subpartition_list>                                                                     -- [@skip patch]
)                                                                                           -- [@skip patch]
(                                                                                           -- [@skip patch]
    partition dpp_attribute_value_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)                                                                                           -- [@skip patch]
******************** partition end ********************/
/
comment on table dpp_attribute_value is 'Deffered payment plan conditions'
/
comment on column dpp_attribute_value.id is 'Primary key.'
/
comment on column dpp_attribute_value.dpp_id is 'Reference to payment plan'
/
comment on column dpp_attribute_value.attr_id is 'Attrubute identifier.'
/
comment on column dpp_attribute_value.mod_id is 'Modifier defined for current value.'
/
comment on column dpp_attribute_value.value is 'Attribute value.'
/
comment on column dpp_attribute_value.split_hash is 'Value to split further processing.'
/
alter table dpp_attribute_value modify(id  null)
/
alter table dpp_attribute_value modify(dpp_id  null)
/
alter table dpp_attribute_value modify(attr_id  null)
/
alter table dpp_attribute_value modify(mod_id  null)
/
alter table dpp_attribute_value modify(value  null)
/
alter table dpp_attribute_value modify(split_hash  null)
/
begin
    for rec in (select count(1) cnt from user_tab_columns where table_name = 'DPP_ATTRIBUTE_VALUE' and column_name = 'PART_KEY')
    loop
        if rec.cnt = 0 then
            execute immediate 'alter table dpp_attribute_value add (part_key as (to_date(substr(lpad(to_char(id), 16, ''0''), 1, 6), ''yymmdd'')) virtual)';
            execute immediate 'comment on column dpp_attribute_value.part_key is ''Partition key''';
        end if;
    end loop;
end;
/
