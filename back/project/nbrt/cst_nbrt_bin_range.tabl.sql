create table cst_nbrt_bin_range (
    id              number(8)
  , pan_low         varchar2(24)
  , pan_high        varchar2(24)
  , pan_length      number(4)
  , priority        number(4)
  , country         varchar2(3)
  , iss_network_id  number(4)
)
/
comment on table cst_nbrt_bin_range is 'National Bank of the Republic of Tajikistan Range Table.'
/
comment on column cst_nbrt_bin_range.id is 'Primary key.'
/
comment on column cst_nbrt_bin_range.pan_low is 'Range low value.'
/
comment on column cst_nbrt_bin_range.pan_high is 'Range high value.'
/
comment on column cst_nbrt_bin_range.pan_length is 'Card number length.'
/
comment on column cst_nbrt_bin_range.priority is 'Priority.'
/
comment on column cst_nbrt_bin_range.country is 'Country code (numeric).'
/
comment on column cst_nbrt_bin_range.iss_network_id is 'Issuing network identifier'
/
