create table com_rate_type (
    id                  number(4) not null
    , seqnum            number(4)
    , rate_type         varchar2(8)
    , inst_id           number(4)
    , use_cross_rate    number(1)
    , use_base_rate     number(1)
    , base_currency     varchar2(3)
    , is_reversible     number(1)
    , warning_level     number
    , use_double_typing number(1)
    , use_verification  number(1)
    , adjust_exponent   number(1)
    , exp_period        number(4)
    , rounding_accuracy number(4)
)
/
comment on table com_rate_type is 'Definition of parameters of rates types'
/
comment on column com_rate_type.id is 'Record identifier'
/
comment on column com_rate_type.seqnum is 'Sequential number of record version'
/
comment on column com_rate_type.rate_type is 'Rate type'
/
comment on column com_rate_type.inst_id is 'Institution identifier'
/
comment on column com_rate_type.use_cross_rate is 'Ability to use cross rates'
/
comment on column com_rate_type.use_base_rate is 'Ability to use rates to base currency'
/
comment on column com_rate_type.base_currency is 'Base currency to perform conversion'
/
comment on column com_rate_type.is_reversible is 'Indicator that rate is reversible'
/
comment on column com_rate_type.warning_level is 'Threshold  of difference between previous and current rate which causes a warning'
/
comment on column com_rate_type.use_double_typing is 'Necessity to use double typing when registering rate'
/
comment on column com_rate_type.use_verification is 'Necessity to use verification when registering rate'
/
comment on column com_rate_type.adjust_exponent is 'Necessity to adjust exponents difference between source and destination currency'
/
comment on column com_rate_type.exp_period is 'Default expiration period for rate in days'
/
comment on column com_rate_type.rounding_accuracy is 'Accuracy of rounding during calculations'
/
