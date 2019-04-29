create table opr_entity_oper_type (
    id                  number(4)
    , seqnum            number(4)
    , inst_id           number(4)
    , entity_type       varchar2(8)
    , oper_type         varchar2(8)
    , invoke_method     varchar2(8)
    , reason_lov_id     number(4)
)
/
comment on table opr_entity_oper_type is 'Association of entity types and operation types to manual operation creation'
/
comment on column opr_entity_oper_type.id is 'Record identifier'
/
comment on column opr_entity_oper_type.seqnum is 'Sequential number of record data version'
/
comment on column opr_entity_oper_type.inst_id is 'Institution identifier'
/
comment on column opr_entity_oper_type.entity_type is 'Entity type'
/
comment on column opr_entity_oper_type.oper_type is 'Operation type'
/
comment on column opr_entity_oper_type.invoke_method is 'Operation invoke method'
/
comment on column opr_entity_oper_type.reason_lov_id is 'Identifier of LOV with allowed reason codes'
/
alter table opr_entity_oper_type add (object_type varchar2(8), wizard_id number(4))
/
comment on column opr_entity_oper_type.object_type is 'Object type to restrict some association'
/
comment on column opr_entity_oper_type.wizard_id is 'Reference to wizard'
/
comment on column opr_entity_oper_type.entity_type is 'Entity type for which the wizard is available'
/
comment on column opr_entity_oper_type.oper_type is 'Operation type that should be used by the wizard (if only some exact operation type is not specified inside of the wizard)'
/
comment on column opr_entity_oper_type.object_type is 'Object type to restrict additionaly some association normally based on entity type. For example, combination of entity type ENTTOPER and object type PRTYISS means that the wizard should be available on form Issuing->Operations only'
/
alter table opr_entity_oper_type add entity_object_type varchar2(8)
/
comment on column opr_entity_oper_type.entity_object_type is 'Type of entity object for which wizard is available. For example, combination of entity type ENTTOPER and entity object type OPTP0000 means that the wizard should be available on form *->Operations only if an operation of type OPTP0000 is selected'
/
