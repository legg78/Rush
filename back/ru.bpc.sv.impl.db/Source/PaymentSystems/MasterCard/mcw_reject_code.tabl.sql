create table mcw_reject_code (
    id                  number(16)                                                       -- [@skip patch]
    , part_key          as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual        -- [@skip patch]
    , reject_data_id    number(16)                                                       -- [@skip patch]
    , de_number         varchar2(5)                                                      -- [@skip patch]
    , severity_code     varchar2(2)                                                      -- [@skip patch]
    , message_code      varchar2(255)                                                    -- [@skip patch]
    , subfield_id       varchar2(3)                                                      -- [@skip patch]
    , is_from_orig_msg  number(1)                                                        -- [@skip patch]
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition mcw_reject_code_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))    -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

begin for rec in (select 1 from dual where not exists (select 1 from user_tab_cols where table_name = 'MCW_REJECT_CODE' and column_name = 'ID')) loop
        execute immediate 'alter table mcw_reject_code add id number(16)';  end loop;
    for rec in (select 2 from dual where not exists
                    (select 3 from user_tab_cols where table_name = 'MCW_REJECT_CODE' and column_name = 'REJECT_DATA_ID')) loop
        execute immediate 'alter table mcw_reject_code add reject_data_id number(16)'; end loop;
    for rec in (select 2 from dual where not exists
                    (select 3 from user_tab_cols where table_name = 'MCW_REJECT_CODE' and column_name = 'IS_FROM_ORIG_MSG')) loop
        execute immediate 'alter table mcw_reject_code add is_from_orig_msg number(1)'; end loop;
end;  --
/


comment on table mcw_reject_code is 'Message Error Indicator (MasterCard Reject codes)'
/

comment on column mcw_reject_code.id is 'Unique identifier'
/
comment on column mcw_reject_code.reject_data_id is 'Reject data record identifier (FK mcw_reject_data.id)'
/
comment on column mcw_reject_code.de_number is 'Data Element ID (DE) (vis_reject_code.field part1)'
/
comment on column mcw_reject_code.severity_code is 'Error Severity Code (vis_reject_code.reject_code)'
/
comment on column mcw_reject_code.message_code is 'Error Message Code (vis_reject_code.description)'
/
comment on column mcw_reject_code.subfield_id is 'Subfield ID (PDS) (vis_reject_code.field part2)'
/
comment on column mcw_reject_code.is_from_orig_msg is '1 - code comed from field of source reject message, 0 - from validation rules'
/
