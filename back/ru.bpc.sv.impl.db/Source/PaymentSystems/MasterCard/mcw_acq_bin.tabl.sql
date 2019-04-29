create table mcw_acq_bin (
    acq_bin         varchar2(12) not null
    , member_id     varchar2(12)
    , brand         varchar2(3)
    , country       varchar2(60)
    , region        varchar2(6)
)
/

comment on table mcw_acq_bin is 'This table contains all of the acquiring BINs for a particular acquirer and associated card program identifier information.'
/

comment on column mcw_acq_bin.acq_bin is 'Acquiring BIN'
/

comment on column mcw_acq_bin.brand is 'The card program identifier associated to the acquiring BIN ID.'
/

comment on column mcw_acq_bin.country is 'The alphabetic country code associated with the acquiring BIN ID (occurs 20 times) and card program identifier.'
/

comment on column mcw_acq_bin.region is 'The region associated to the acquiring BIN ID (occurs 6 times).'
/

comment on column mcw_acq_bin.member_id is 'The member ID associated to the acquiring BIN ID.'
/
