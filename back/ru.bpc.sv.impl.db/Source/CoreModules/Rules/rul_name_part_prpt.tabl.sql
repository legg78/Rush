create table rul_name_part_prpt (
    id               number(4)
    , entity_type    varchar2(8)
    , property_name  varchar2(200)
)
/
comment on table rul_name_part_prpt is 'List of property depending on entity type'
/
comment on column rul_name_part_prpt.id is 'Identifier'
/
comment on column rul_name_part_prpt.entity_type is 'Entity type'
/
comment on column rul_name_part_prpt.property_name is 'Property name'
/
