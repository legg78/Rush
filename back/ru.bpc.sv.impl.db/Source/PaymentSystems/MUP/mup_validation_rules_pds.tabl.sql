create table mup_validation_rules_pds 
(
    id              number(16)
    , mti           varchar2(255)
    , function_code varchar2(255)
    , pds           number(16)
    , incoming      varchar2(10)
    , outgoing      varchar2(10)
    , dictionary    varchar2(4)
    , lov_id        number(16)
)
/

comment on table mup_validation_rules_pds is 'MUP pds validation rules'
/
comment on column mup_validation_rules_pds.id         is 'Unique identifier'
/
comment on column mup_validation_rules_pds.mti        is 'Message Type Identifier'
/
comment on column mup_validation_rules_pds.function_code is 'Function Code'
/
comment on column mup_validation_rules_pds.pds        is 'Private Data Subelement Tag Number'
/
comment on column mup_validation_rules_pds.incoming   is 'Mandatory for incoming'
/ 
comment on column mup_validation_rules_pds.outgoing   is 'Mandatory for outgoing'
/
comment on column mup_validation_rules_pds.dictionary is 'Code of dictionary'
/ 
comment on column mup_validation_rules_pds.lov_id   is 'Link to array'
/
