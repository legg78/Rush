create table emv_linked_script (
    auth_id        number(16)
    , script_id    number(16)
)
/
comment on table emv_linked_script is 'EMV scripts linked to authorization'
/
comment on column emv_linked_script.auth_id is 'Authorization identifier'
/
comment on column emv_linked_script.script_id is 'Script identifier'
/