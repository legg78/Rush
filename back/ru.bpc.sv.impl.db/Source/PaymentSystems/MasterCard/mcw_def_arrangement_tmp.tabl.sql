create global temporary table mcw_def_arrangement_tmp (
    region              varchar2(3)
    , acq_region        varchar2(3)
    , iss_region        varchar2(3)
    , brand             varchar2(3)
    , priority          number(4)
    , arrangement_type  varchar2(3)
    , arrangement_code  varchar2(8)
)
on commit preserve rows
/

comment on table mcw_def_arrangement_tmp is 'This table identifies the acceptance brand, business service arrangement type and business service arrangement ID for default business service arrangements.'
/

comment on column mcw_def_arrangement_tmp.region is 'The region associated to the acceptance brand, business service arrangement type and business service arrangement ID'
/

comment on column mcw_def_arrangement_tmp.acq_region is '"From" acquiring region associated to the acceptance brand, business service arrangement type and business service arrangement ID.'
/

comment on column mcw_def_arrangement_tmp.iss_region is '"To" issuing region associated to the acceptance brand, business service arrangement type and business service arrangement ID.'
/

comment on column mcw_def_arrangement_tmp.brand is 'The card program identifier'
/

comment on column mcw_def_arrangement_tmp.priority is 'The priority of the business service arrangement type.'
/

comment on column mcw_def_arrangement_tmp.arrangement_type is 'The business service arrangement type.'
/

comment on column mcw_def_arrangement_tmp.arrangement_code is 'The business service arrangement ID code.'
/
