create table net_bin_range_index (
    pan_prefix        varchar2(5)
  , pan_low           varchar2(24)
  , pan_high          varchar2(24)
  , primary key (pan_prefix, pan_low, pan_high)
)
organization index 
/
comment on table net_bin_range_index is 'Indexes to access net_bin_range'
/
comment on column net_bin_range_index.pan_prefix is 'PAN prefix (first 5 digits)'
/
comment on column net_bin_range_index.pan_low is 'Range low value'
/
comment on column net_bin_range_index.pan_high is 'Range high value'
/

