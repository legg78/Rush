create table mcw_currency_rate (
    id          number(16)
    , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual      -- [@skip patch]
    , p0164_1   varchar2(3)
    , p0164_2   number                                                                   -- [@skip patch]
    , p0164_3   varchar2(1)
    , p0164_4   date
    , p0164_5   numeric(2)
    , de050     varchar2(3)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition mcw_curr_rate_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))      -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table mcw_currency_rate is 'PDS 0164-Currency Cross Rates'
/

comment on column mcw_currency_rate.id is 'Reference to message in MCW_CURRENCY_UPDATE'
/
comment on column mcw_currency_rate.p0164_1 is 'Currency Code'
/
comment on column mcw_currency_rate.p0164_2 is 'Currency Conversion Rate'
/
comment on column mcw_currency_rate.p0164_3 is 'Currency Conversion Type'
/
comment on column mcw_currency_rate.p0164_4 is 'Business Date'
/
comment on column mcw_currency_rate.p0164_5 is 'Delivery Cycle'
/
comment on column mcw_currency_rate.de050 is 'Base currency'
/
