create table bgn_error_code (
    error_code      number(3)
  , description     varchar2(2000)
)
/

comment on table bgn_error_code is 'BORICA error descriptions for bgn_retrieval'
/

comment on column bgn_error_code.error_code is 'Error code'
/

comment on column bgn_error_code.description is 'Description of error'
/
