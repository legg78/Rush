create table mup_acq_bin (
    acq_bin         varchar2(6) not null
    , member_id     varchar2(11)
    , country       varchar2(3)
    , member_name   varchar2(50)
    , eff_date      date
)
/

comment on table mup_acq_bin is 'This table contains all of the acquiring BINs for a particular acquirer and associated card program identifier information.'
/
comment on column mup_acq_bin.acq_bin is 'Acquiring BIN'
/
comment on column mup_acq_bin.member_id is 'The member ID associated to the acquiring BIN ID.'
/
comment on column mup_acq_bin.country is 'The alphabetic country code associated with the acquiring BIN ID (occurs 20 times) and card program identifier.'
/
comment on column mup_acq_bin.member_name is 'Bank name.'
/
comment on column mup_acq_bin.eff_date is 'Date of record activation.'
/
