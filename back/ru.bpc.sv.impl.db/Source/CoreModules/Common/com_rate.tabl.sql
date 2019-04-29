create table com_rate (
    id number(8)        not null
    , seqnum number(4)
    , inst_id number(4)
    , eff_date date
    , reg_date timestamp
    , rate_type varchar2(8)
    , src_scale number
    , src_currency varchar2(3)
    , src_exponent_scale number
    , dst_scale number
    , dst_currency varchar2(3)
    , dst_exponent_scale number
    , status varchar2(8)
    , exp_date date
    , inverted number(1)
    , rate number
    , eff_rate number
    , initiate_rate_id number(8)
)
/
comment on table com_rate is 'Currency rates'
/
comment on column com_rate.id is 'Record identifier'
/
comment on column com_rate.seqnum is 'Sequential version of record'
/
comment on column com_rate.inst_id is 'Institution identifier'
/
comment on column com_rate.eff_date is 'Rate effective date'
/
comment on column com_rate.reg_date is 'Registration date'
/
comment on column com_rate.rate_type is 'Rate type'
/
comment on column com_rate.src_scale is 'Scale of source currency'
/
comment on column com_rate.src_currency is 'Source currency'
/
comment on column com_rate.src_exponent_scale is 'Scale due to source currency exponent'
/
comment on column com_rate.dst_scale is 'Scale of destination currency'
/
comment on column com_rate.dst_currency is 'Destination currency'
/
comment on column com_rate.dst_exponent_scale is 'Scale due to destination currency exponent'
/
comment on column com_rate.status is 'Rate status'
/
comment on column com_rate.exp_date is 'Rate expiration date'
/
comment on column com_rate.inverted is 'Indicator of inverted rate'
/
comment on column com_rate.rate is 'Rate as was registered'
/
comment on column com_rate.eff_rate is 'Calculated effective rate'
/
comment on column com_rate.initiate_rate_id is 'Identifier of initiating rate (in case of rate dependencies)'
/
