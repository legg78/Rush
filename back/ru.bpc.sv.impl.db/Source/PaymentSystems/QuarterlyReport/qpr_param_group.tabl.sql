create table qpr_param_group(
    id  number(16) not null
  , param_id number(4,0)
  , group_id number(4,0))
/

comment on table qpr_param_group  is 'Reference of parameters groups and parameters for VISA and MC quarter reports'
/
comment on column qpr_param_group.id is 'Identifier'
/
comment on column qpr_param_group.param_id is 'Parameter ID (refers to PS_PARAM)'
/
comment on column qpr_param_group.group_id is 'Group ID (refers to PS_GROUP)'
/
alter table qpr_param_group add (priority number(8))
/
comment on column qpr_param_group.priority is 'Parameters priority'
/
