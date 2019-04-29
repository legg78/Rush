create table emv_variable (
    id                   number(8) not null
    , seqnum             number(4)
    , application_id     number(8) not null
    , variable_type      varchar2(8) not null
    , profile            varchar2(8) not null
)
/
comment on table emv_variable is 'EMV data variable'
/
comment on column emv_variable.id is 'Primary key'
/
comment on column emv_variable.seqnum is 'Data version sequencial number.'
/
comment on column emv_variable.application_id is 'Application indentifier'
/
comment on column emv_variable.variable_type is 'Variable type (EVTP dictionary)'
/
comment on column emv_variable.profile is 'Profile of EMV application (EPFL dictionary)'
/
