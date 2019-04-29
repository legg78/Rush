create table prs_sort_param (
    id                 number(4)
    , name             varchar2(200)   
)
/
comment on table prs_sort_param is 'List of sort parameters'
/
comment on column prs_sort_param.id is 'Identifier'
/
comment on column prs_sort_param.name is 'Parameter name'
/
