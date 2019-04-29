create table aup_scheme_template
(
    scheme_id  number(4)
  , templ_id   number(8)
)
/

comment on table aup_scheme_template is 'Links between schemes and templates.'
/

comment on column aup_scheme_template.scheme_id is 'Reference to authorization scheme.'
/

comment on column aup_scheme_template.templ_id is 'Reference to authorization template.'
/