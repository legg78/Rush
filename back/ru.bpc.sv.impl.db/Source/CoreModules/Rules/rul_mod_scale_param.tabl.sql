create table rul_mod_scale_param (
    id              number(4) not null
    , scale_id      number(4)
    , param_id      number(8)
)
/
comment on table rul_mod_scale_param is 'Usage of parameters in scales'
/
comment on column rul_mod_scale_param.id is 'Record identifier'
/
comment on column rul_mod_scale_param.scale_id is 'Scale identifier'
/
comment on column rul_mod_scale_param.param_id is 'Parameter identifier'
/

