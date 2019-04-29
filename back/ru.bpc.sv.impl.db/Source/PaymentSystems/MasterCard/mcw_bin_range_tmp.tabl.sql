create global temporary table mcw_bin_range_tmp (
    pan_low         varchar2(24) not null
    , pan_high      varchar2(24) not null
    , product_id    varchar2(3) not null
    , brand         varchar2(3)
    , priority      number(4)
    , member_id     varchar2(12)
    , product_type  varchar2(3)
    , country       varchar2(3)
    , region        varchar2(3)
)
on commit preserve rows
/

comment on table mcw_bin_range_tmp is 'This table contains all issuing account ranges and associated card program identifier information.'
/

comment on column mcw_bin_range_tmp.pan_low is 'The account number at the low end of the account range.'
/

comment on column mcw_bin_range_tmp.pan_high is 'The account number at the high end of the account range.'
/

comment on column mcw_bin_range_tmp.product_id is 'This is the Product ID recognized by GCMS for the issuer account range and card program identifier combination.'
/

comment on column mcw_bin_range_tmp.brand is 'The card program identifier associated to the account range.'
/

comment on column mcw_bin_range_tmp.priority is 'The priority code assigned to the card program identifier by the issuer, for the associated account range.'
/

comment on column mcw_bin_range_tmp.member_id is 'The member ID associated with the account range.'
/

comment on column mcw_bin_range_tmp.product_type is 'The product type of the associated account range and card program identifier.Valid values: 1 = Consumer 2 = Commercial 3 = Both'
/

comment on column mcw_bin_range_tmp.country is 'The ISO-defined numeric country code associated with the account range.'
/

comment on column mcw_bin_range_tmp.region is 'The region of the associated country code.'
/

alter table mcw_bin_range_tmp add (paypass_ind  varchar2(1 byte))
/
comment on column mcw_bin_range_tmp.paypass_ind is 'PayPass Enabled Indicator'
/
alter table mcw_bin_range_tmp add non_reloadable_ind varchar2(2 char)
/
comment on column mcw_bin_range_tmp.non_reloadable_ind is 'Indicator to identify BINs (token or PAN) or account ranges that are registered to support non-reloadable prepaid card programs'
/
