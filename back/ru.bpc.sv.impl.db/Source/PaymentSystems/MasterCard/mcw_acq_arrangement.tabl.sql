create table mcw_acq_arrangement (
    acq_bin                 varchar2(12) not null
    , arrangement_type      varchar2(1) not null
    , arrangement_code      varchar2(8) not null
    , brand                 varchar2(8) not null
    , priority              number(4)
    , primary key (
        acq_bin
        , arrangement_type
        , arrangement_code
        , brand
    )
)
organization index
/

comment on table mcw_acq_arrangement is 'This table identifies the card program identifier and business service arrangements associated with an acquiring BIN.'
/

comment on column mcw_acq_arrangement.acq_bin is 'The six-position acquiring BIN associated with the card program identifier and business service arrangement information.'
/

comment on column mcw_acq_arrangement.arrangement_type is 'The business service arrangement type.'
/

comment on column mcw_acq_arrangement.arrangement_code is 'The business service arrangement ID code.'
/

comment on column mcw_acq_arrangement.brand is 'MasterCard or other proprietary service mark.'
/

comment on column mcw_acq_arrangement.priority is 'The priority of the business service arrangement type.'
/
