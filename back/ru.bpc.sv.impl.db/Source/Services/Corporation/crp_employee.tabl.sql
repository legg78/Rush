create table crp_employee (
    id                  number(12) not null
    , seqnum            number(4) not null
    , corp_company_id   number(8) not null
    , corp_customer_id  number(12) not null
    , corp_contract_id  number(12) not null
    , dep_id            number(8) not null
    , entity_type       varchar2(8) not null
    , object_id         number(16) not null
    , contract_id       number(12) not null
    , account_id        number(12) not null
    , inst_id           number(4) not null
)
/
comment on table crp_employee is 'Employees. Participants of corporate product.'
/
comment on column crp_employee.id is 'Primary key'
/
comment on column crp_employee.seqnum is 'Sequential number of data version'
/
comment on column crp_employee.corp_company_id is 'Reference to company'
/
comment on column crp_employee.corp_customer_id is 'Reference to coporate customer'
/
comment on column crp_employee.corp_contract_id is 'Reference to corporate contract'
/
comment on column crp_employee.dep_id is 'Reference to department'
/
comment on column crp_employee.entity_type is 'Entity representing participant of corporate product (customer or cardholder)'
/
comment on column crp_employee.object_id is 'Customer or cardholder identifier'
/
comment on column crp_employee.contract_id is 'Contract identifier'
/
comment on column crp_employee.account_id is 'Account for receiving corporate payments'
/
comment on column crp_employee.inst_id is 'Institution identifier'
/
