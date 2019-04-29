create table acc_macros (
    id                  number(16)
    , part_key          as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , entity_type       varchar2(8)
    , object_id         number(16)
    , macros_type_id    number(4)
    , posting_date      date
    , account_id        number(12)
    , amount_purpose    varchar2(8)
    , amount            number(22, 4)
    , currency          varchar2(3)
    , fee_id            number(8)
    , fee_tier_id       number(8)
    , fee_mod_id        number(4)
    , details_data      varchar2(2000)
    , status            varchar2(8)
    , cancel_indicator  varchar2(8)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                -- [@skip patch]
(
    partition acc_macros_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/
comment on table acc_macros is 'Posted macroses are stored here'
/
comment on column acc_macros.id is 'Macros identifier'
/
comment on column acc_macros.entity_type is 'Entity Type of object which macros belongs to'
/
comment on column acc_macros.object_id is 'Identifier of object which macros belongs to'
/
comment on column acc_macros.macros_type_id is 'Macros type'
/
comment on column acc_macros.posting_date is 'Date when macros was posted'
/
comment on column acc_macros.account_id is 'Main account identifier'
/
comment on column acc_macros.amount is 'Macros amount'
/
comment on column acc_macros.currency is 'Macros currency'
/
comment on column acc_macros.amount_purpose is 'Amount purpose (AMPR or fee type)'
/
comment on column acc_macros.fee_id is 'Fee identifier'
/
comment on column acc_macros.fee_tier_id is 'Fee tier identifier'
/
comment on column acc_macros.fee_mod_id is 'Fee modificator'
/
comment on column acc_macros.details_data is 'Macros detalisation data'
/
alter table acc_macros add account_purpose varchar2(8)
/
comment on column acc_macros.account_purpose is 'Account purpose (ACPR)'
/
alter table acc_macros add conversion_rate number
/
comment on column acc_macros.conversion_rate is 'Conversion rate from original amount'
/
alter table acc_macros add conversion_rate_id number(8)
/
comment on column acc_macros.conversion_rate_id is 'Reference to the conversion rate identifier of the operation amount to macros amount '
/
alter table acc_macros add (rate_type varchar2(8 char))
/
comment on column acc_macros.rate_type is 'Conversion rate type'
/
begin
    for rec in (select count(1) cnt from user_tab_columns where table_name = 'ACC_MACROS' and column_name = 'PART_KEY')
    loop
        if rec.cnt = 0 then
            execute immediate 'alter table acc_macros add (part_key as (to_date(substr(lpad(to_char(id), 16, ''0''), 1, 6), ''yymmdd'')) virtual)';
            execute immediate 'comment on column acc_macros.part_key is ''Partition key''';
        end if;
    end loop;
end;
/
