create table mup_bin_range (
    pan_low         varchar2(19) not null
    , pan_high      varchar2(19) not null
    , product_id    varchar2(3) not null
    , member_id     varchar2(11)
    , member_name   varchar2(50)
    , country       varchar2(3)
    , eff_date      date
    , priority      number(4)
)
/
comment on table mup_bin_range is 'This table contains all issuing account ranges and associated card program identifier information.'
/
comment on column mup_bin_range.pan_low is 'The account number at the low end of the account range.'
/
comment on column mup_bin_range.pan_high is 'The account number at the high end of the account range.'
/
comment on column mup_bin_range.product_id is 'This is the Product ID recognized by GCMS for the issuer account range and card program identifier combination.'
/
comment on column mup_bin_range.member_id is 'The member ID associated with the account range.'
/
comment on column mup_bin_range.member_name is 'Bank name.'
/
comment on column mup_bin_range.country is 'The ISO-defined numeric country code associated with the account range.'
/
comment on column mup_bin_range.eff_date is 'Date of record activation.'
/
comment on column mup_bin_range.priority is 'The priority code assigned to the card program identifier by the issuer, for the associated account range.'
/

alter table mup_bin_range add crdh_curr_code varchar2(3)
/
comment on column mup_bin_range.crdh_curr_code is 'Cardholder Billing Currency Code'
/
