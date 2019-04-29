create table iss_bin_index_range (
    id                  number(8)
    , seqnum            number(4)
    , bin_id            number(8)
    , index_range_id    number(8)
)
/
comment on table iss_bin_index_range is 'Association of BINs and index generation algorithms'
/
comment on column iss_bin_index_range.id is 'Association identifier'
/
comment on column iss_bin_index_range.seqnum is 'Sequential number of data version'
/
comment on column iss_bin_index_range.bin_id is 'BIN identifier'
/
comment on column iss_bin_index_range.index_range_id is 'Index range identifier'
/
