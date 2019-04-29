create table mup_currency_rate(
    id             number(16)
  , rate_type      varchar2(15)
  , rates_id       number(16)
  , rates_date     date
  , base_curr_code varchar(3)
  , curr_code      varchar(3)
  , curr_name      varchar(3)
  , nominal        number
  , base_rate      number
  , buy_rate       number
  , sell_rate      number
)
/

comment on table mup_currency_rate is 'MUP Currency rates'
/
comment on column mup_currency_rate.Id is 'Identifier'
/
comment on column mup_currency_rate.Rate_type is 'Rate type. For payment system it should be «PAYSYS»'
/
comment on column mup_currency_rate.Rates_id is 'Rates sets identifier from file'
/
comment on column mup_currency_rate.Rates_date is 'Rates date and time'
/
comment on column mup_currency_rate.Base_curr_code is 'Base currency code'
/
comment on column mup_currency_rate.Curr_code is 'Currency code'
/
comment on column mup_currency_rate.Curr_name is 'Currency alpha code'
/
comment on column mup_currency_rate.nominal is 'Currency nominal or Currency exponent'
/
comment on column mup_currency_rate.Base_rate is 'Base rate'
/
comment on column mup_currency_rate.Buy_rate is 'Buy rate'
/
comment on column mup_currency_rate.Sell_rate is 'Sell rate'
/

alter table mup_currency_rate modify id number(8)
/
comment on column mup_currency_rate.rate_type is 'Rate type. For payment system it should be ''PAYSYS'''
/

