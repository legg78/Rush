create table aup_auth_template
(
    id                  number(8)
  , seqnum              number(4)
  , templ_type          varchar2(8)
  , mod_id              number(4)
  , resp_code           varchar2(8)
)
/

comment on table aup_auth_template is 'Authorization templates.'
/

comment on column aup_auth_template.id is 'Primary key.'
/

comment on column aup_auth_template.seqnum is 'Sequential number of data version'
/

comment on column aup_auth_template.templ_type is 'Template type (Positive, Negative)'
/

comment on column aup_auth_template.mod_id is 'Reference to modifier describing authorization parameters.'
/

comment on column aup_auth_template.resp_code is 'Response code returning if authorization matched with negative template. '
/