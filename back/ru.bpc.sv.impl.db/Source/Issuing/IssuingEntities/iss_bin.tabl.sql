create table iss_bin (
    id                 number(8)
    , seqnum           number(4)
    , bin              varchar2(24)
    , inst_id          number(4)
    , network_id       number(4)
    , bin_currency     varchar2(3)
    , sttl_currency    varchar2(3)
    , pan_length       number(4)
    , card_type_id     number(4)
    , country          varchar2(3)
    , perso_method_id  number(4)
)
/
comment on table iss_bin is 'List of us issuing bins'
/
comment on column iss_bin.id is 'Record identifier'
/
comment on column iss_bin.bin is 'Bin'
/
comment on column iss_bin.inst_id is 'Institution identifier'
/
comment on column iss_bin.network_id is 'Network identifier'
/
comment on column iss_bin.bin_currency is 'Bin currency'
/
comment on column iss_bin.sttl_currency is 'Bin settlement currency'
/
comment on column iss_bin.pan_length is 'Length of card number'
/
comment on column iss_bin.card_type_id is 'Bin card type identifier'
/
comment on column iss_bin.country is 'Bin country association'
/
comment on column iss_bin.seqnum is 'Sequential number of data version'
/
comment on column iss_bin.perso_method_id is 'Personalization method identifier'
/
alter table iss_bin drop column perso_method_id
/
