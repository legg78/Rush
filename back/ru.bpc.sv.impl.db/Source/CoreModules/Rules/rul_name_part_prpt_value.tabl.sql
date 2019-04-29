create table rul_name_part_prpt_value (
    id                  number(8)
    , part_id           number(8)
    , property_id       number(8)
    , property_value    varchar2(200)
)
/
comment on table rul_name_part_prpt_value is 'Property values for name generation'
/
comment on column rul_name_part_prpt_value.id is 'Identifier'
/
comment on column rul_name_part_prpt_value.part_id is 'Part identifier'
/
comment on column rul_name_part_prpt_value.property_id is 'Property identifier'
/
comment on column rul_name_part_prpt_value.property_value is 'Property value'
/
