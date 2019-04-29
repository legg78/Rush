alter table aup_tag_value add constraint aup_tag_value_pk primary key (
    auth_id 
    , tag_id
)
/
alter table aup_tag_value drop constraint aup_tag_value_pk
/
