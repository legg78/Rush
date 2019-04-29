create table mcw_iss_arrangement (
    pan_low             varchar2(24) not null
    , pan_high          varchar2(24) not null
    , arrangement_type  varchar2(1) not null
    , arrangement_code  varchar2(8) not null
    , brand             varchar2(8) not null
    , type_priority     number(4)
    , brand_priority    number(4)
    , primary key (
       pan_low
       , pan_high
       , arrangement_type
       , arrangement_code
       , brand
    )
)
organization index 
/

comment on table mcw_iss_arrangement is 'This table identifies the card program identifier and business service arrangements associated with an issuer account range.'
/

comment on column mcw_iss_arrangement.pan_low is 'The account number at the low end of the issuing account range associated to the card program identifier and business service arrangement combination.'
/

comment on column mcw_iss_arrangement.pan_high is 'The account number at the high end of the issuing account range associated to the card program identifier and business service arrangement combination.'
/

comment on column mcw_iss_arrangement.arrangement_type is 'The business service arrangement type.'
/

comment on column mcw_iss_arrangement.arrangement_code is 'The business service arrangement ID code.'
/

comment on column mcw_iss_arrangement.brand is 'MasterCard or other proprietary service mark.'
/

comment on column mcw_iss_arrangement.type_priority is 'The priority of the business service arrangement type.'
/

comment on column mcw_iss_arrangement.brand_priority is 'The priority of the issuer card program identifier in relation to its use with the account range and business service arrangement combination. '
/
