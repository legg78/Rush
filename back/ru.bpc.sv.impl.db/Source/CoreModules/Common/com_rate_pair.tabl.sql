create table com_rate_pair (
    id                      number(4) not null
    , seqnum                number(4)
    , rate_type             varchar2(8)
    , inst_id               number(4)
    , src_currency          varchar2(3)
    , dst_currency          varchar2(3)
    , base_rate_type        varchar2(8)
    , base_rate_mnemonic    varchar2(200)
    , base_rate_formula     varchar2(200)
    , req_regular_reg       number(1)
)
/
comment on table com_rate_pair is 'Pairs of currencies and dependencies between rate types'
/
comment on column com_rate_pair.id is 'Record identifier'
/
comment on column com_rate_pair.seqnum is 'Sequential number of record version'
/
comment on column com_rate_pair.rate_type is 'Rate type'
/
comment on column com_rate_pair.inst_id is 'Institution identifier'
/
comment on column com_rate_pair.src_currency is 'Source currency'
/
comment on column com_rate_pair.dst_currency is 'Destination currency'
/
comment on column com_rate_pair.base_rate_type is 'depending rate type'
/
comment on column com_rate_pair.base_rate_mnemonic is 'mnemonic of base rate to use in calculation formula'
/
comment on column com_rate_pair.base_rate_formula is 'formula to calculate rate using base rate (identified by its mnemonic)'
/
comment on column com_rate_pair.req_regular_reg is 'Indicator that rate for this pair requires regular registration'
/

alter table com_rate_pair add (input_mode varchar2(8))
/
alter table com_rate_pair add (src_scale number)
/
alter table com_rate_pair add (dst_scale number)
/
alter table com_rate_pair add (inverted number(1))
/
comment on column com_rate_pair.input_mode is 'Input mode (dictionary RTIM)'
/
comment on column com_rate_pair.src_scale is 'Scale of source currency'
/
comment on column com_rate_pair.dst_scale is 'Scale of destination currency'
/
comment on column com_rate_pair.inverted is 'Indicator of inverted rate'
/
alter table com_rate_pair add rate_example number
/
alter table com_rate_pair add display_order number(4)
/
comment on column com_rate_pair.rate_example is 'Example of exchange rate for enter'
/
comment on column com_rate_pair.display_order is 'Display order'
/