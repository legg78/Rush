create table mup_validation_rules_de
(
    id              number(16)
    , mti           varchar2(255)
    , function_code varchar2(255)
    , de            number(16)
    , incoming      varchar2(10)
    , outgoing      varchar2(10)
    , dictionary    varchar2(4)
    , lov_id        number(16)
)
/

comment on table mup_validation_rules_de is 'MUP de validation rules'
/
comment on column mup_validation_rules_de.id  is 'Unique identifier'
/
comment on column mup_validation_rules_de.mti is 'Message Type Identifier'
/
comment on column mup_validation_rules_de.function_code is 'Function Code'
/
comment on column mup_validation_rules_de.de is 'Data element number'
/
comment on column mup_validation_rules_de.incoming is 'Mandatory for incoming' 
/
comment on column mup_validation_rules_de.outgoing is 'Mandatory for outgoing'
/
comment on column mup_validation_rules_de.dictionary is 'Core of dictionary' 
/
comment on column mup_validation_rules_de.lov_id is 'Link to array'
/
