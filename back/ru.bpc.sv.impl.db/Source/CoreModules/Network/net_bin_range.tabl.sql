create table net_bin_range (
    pan_low             varchar2(24)
    , pan_high          varchar2(24)
    , pan_length        number(4)
    , priority          number(4)
    , card_type_id      number(4)
    , country           varchar2(3)
    , iss_network_id    number(4)
    , iss_inst_id       number(4)
    , card_network_id   number(4)
    , card_inst_id      number(4)
    , module_code       varchar2(3)
)
/
comment on table net_bin_range is 'Summary of card bin ranges'
/
comment on column net_bin_range.pan_low is 'Range low value'
/
comment on column net_bin_range.pan_high is 'Range high value'
/
comment on column net_bin_range.priority is 'Priority'
/
comment on column net_bin_range.card_type_id is 'Card type identifier'
/
comment on column net_bin_range.country is 'Country code (numeric)'
/
comment on column net_bin_range.iss_network_id is 'Issuing network identifier'
/
comment on column net_bin_range.iss_inst_id is 'Issuing institution identifier'
/
comment on column net_bin_range.pan_length is 'Card number length'
/
comment on column net_bin_range.card_network_id is 'Card owner network identifier'
/
comment on column net_bin_range.card_inst_id is 'Card owner institution identifier'
/
comment on column net_bin_range.module_code is 'Module code which is the source of bin range record'
/

alter table net_bin_range add activation_date date
/
comment on column net_bin_range.activation_date is 'Activation date.'
/
alter table net_bin_range add account_currency varchar2(3)
/
comment on column net_bin_range.account_currency is 'Default cardholder''s billing currency for this range.'
/