create table rul_mod_scale (
    id              number(4) not null
    , inst_id       number(4)
    , seqnum        number(4)
    , scale_type    varchar2(8)
)
/
comment on table rul_mod_scale is 'Scales by which attributes can be parametrised'
/
comment on column rul_mod_scale.id is 'Scale identifier'
/
comment on column rul_mod_scale.inst_id is 'Owner Institution identifier'
/
comment on column rul_mod_scale.seqnum is 'Sequential number of data version'
/
comment on column rul_mod_scale.scale_type is 'Category of scale'
/
