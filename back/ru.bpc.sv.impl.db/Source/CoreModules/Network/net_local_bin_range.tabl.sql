create table net_local_bin_range (
    id                  number(8)
    , seqnum            number(4)
    , pan_low           varchar2(24)
    , pan_high          varchar2(24)
    , pan_length        number(4)
    , priority          number(4)
    , card_type_id      number(4)
    , country           varchar2(3)
    , iss_network_id    number(4)
    , iss_inst_id       number(4)
    , card_network_id   number(4)
    , card_inst_id      number(4)
)
/
comment on table net_local_bin_range is 'Local bin ranges'
/
comment on column net_local_bin_range.seqnum is 'Sequential number of record data version'
/
comment on column net_local_bin_range.pan_low is 'Range low value'
/
comment on column net_local_bin_range.pan_high is 'Range high value'
/
comment on column net_local_bin_range.pan_length is 'Card number length'
/
comment on column net_local_bin_range.priority is 'Priority'
/
comment on column net_local_bin_range.card_type_id is 'Card type identifier'
/
comment on column net_local_bin_range.country is 'Country code'
/
comment on column net_local_bin_range.iss_network_id is 'Network identifier'
/
comment on column net_local_bin_range.iss_inst_id is 'Institution identifier'
/
comment on column net_local_bin_range.card_network_id is 'Card owner network identifier'
/
comment on column net_local_bin_range.card_inst_id is 'Card owner institution identifier'
/
comment on column net_local_bin_range.id is 'Record identifier'
/
