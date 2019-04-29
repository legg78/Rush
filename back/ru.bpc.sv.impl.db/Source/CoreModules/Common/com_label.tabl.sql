create table com_label
(
    id                  number(8)
  , name                varchar2(200)
  , label_type          varchar2(8)
  , module_code         varchar2(3)
  , env_variable        varchar2(200)
)
/

comment on table com_label is 'List of interface labels and messages.'
/

comment on column com_label.id is 'Primary key.'
/

comment on column com_label.name is 'Unique name (message code).'
/

comment on column com_label.label_type is 'Type of label. Possible values: FATAL, ERROR, WARNING, INFO, DEBUG, CAPTION.'
/

comment on column com_label.module_code is 'Name of module.'
/

comment on column com_label.env_variable is 'List of environment variables (comma separated).'
/