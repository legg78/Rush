create table vis_validation_rules
(
    id                  number(16)
    , transaction_code  number(16)
    , tcr               number(16)
    , start_position    number(16)
    , end_position      number(16)
    , data_type         varchar2(255)
    , data_format       varchar2(255)
    , mandatory         varchar2(1)
    , dictionary        varchar2(4)
    , lov_id            number(16)
    , direction         number(1)
)
/

comment on table vis_validation_rules is 'Visa validation rules'
/
comment on column vis_validation_rules.id                is 'Unique identifier'
/
comment on column vis_validation_rules.transaction_code  is 'Transaction code'
/
comment on column vis_validation_rules.tcr               is 'Transaction Code Qualifier'
/
comment on column vis_validation_rules.start_position    is 'Start position'
/
comment on column vis_validation_rules.end_position      is 'End position'
/
comment on column vis_validation_rules.data_type         is 'Field type'
/
comment on column vis_validation_rules.data_format       is 'Field format'
/
comment on column vis_validation_rules.mandatory         is 'Mandatory or optional field'
/
comment on column vis_validation_rules.dictionary        is 'Name of dictionary (com_dictionary)'
/
comment on column vis_validation_rules.lov_id            is 'Link to lov'
/
comment on column vis_validation_rules.direction         is '0-Outgoing, 1-Incoming, 9-both'
/

alter table vis_validation_rules modify(tcr varchar2(1)) -- [@skip patch]
/
