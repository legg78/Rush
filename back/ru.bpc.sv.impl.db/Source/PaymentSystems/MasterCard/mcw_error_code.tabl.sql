create table mcw_error_code (
    code        number(4)       not null
    , text      varchar2(255)
)
/

comment on table mcw_error_code is 'This table contains the internal IPM error codes and the corresponding message texts for each IPM error code.'
/

comment on column mcw_error_code.code is 'The four-digit internal IPM error message text number. This is a unique number assigned by GCMS.'
/

comment on column mcw_error_code.text is 'The error message text for each corresponding internal IPM error text message number.'
/
