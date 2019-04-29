create table vis_reject_code
(
    id                number(16)
    , reject_data_id  number(16)
    , reject_code     varchar2(50)
    , description     varchar2(255)
    , field           varchar2(255)
)
/
comment on table vis_reject_code is 'VISA Reject codes'
/
comment on column vis_reject_code.id is 'Unique identifier'
/
comment on column vis_reject_code.reject_data_id  is 'Reject data record identifier (FK vis_reject_data.id)'
/
comment on column vis_reject_code.reject_code is 'Error code'
/
comment on column vis_reject_code.description is 'Error detail'
/
comment on column vis_reject_code.field is 'Field with error'
/
