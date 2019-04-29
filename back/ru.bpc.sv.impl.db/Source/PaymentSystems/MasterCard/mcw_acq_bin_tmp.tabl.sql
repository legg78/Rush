create global temporary table mcw_acq_bin_tmp (
    acq_bin         varchar2(12) not null
    , member_id     varchar2(12)
    , brand         varchar2(3)
    , country       varchar2(60)
    , region        varchar2(6)
)
on commit preserve rows
/

comment on table mcw_acq_bin_tmp is 'This table contains all of the acquiring BINs for a particular acquirer and associated card program identifier information.'
/

comment on column mcw_acq_bin_tmp.acq_bin is 'Acquiring BIN'
/

comment on column mcw_acq_bin_tmp.brand is 'The card program identifier associated to the acquiring BIN ID.'
/

comment on column mcw_acq_bin_tmp.country is 'The alphabetic country code associated with the acquiring BIN ID (occurs 20 times) and card program identifier.'
/

comment on column mcw_acq_bin_tmp.region is 'The region associated to the acquiring BIN ID (occurs 6 times).'
/

comment on column mcw_acq_bin_tmp.member_id is 'The member ID associated to the acquiring BIN ID.'
/
 