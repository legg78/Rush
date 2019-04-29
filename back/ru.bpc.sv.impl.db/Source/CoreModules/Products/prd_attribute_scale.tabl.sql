create table prd_attribute_scale (
    id                    number(4)
    , seqnum              number(4)
    , attr_id             number(8)
    , inst_id             number(4)
    , scale_id            number(4)
)
/

comment on table prd_attribute_scale is 'Definition of product attribute scale for institution'
/
comment on column prd_attribute_scale.id is 'Identifier'
/
comment on column prd_attribute_scale.seqnum is 'Sequential number of data version'
/
comment on column prd_attribute_scale.attr_id is 'Attribute identifier'
/
comment on column prd_attribute_scale.inst_id is 'Institution identifier'
/
comment on column prd_attribute_scale.scale_id is 'Scale identifier'
/
