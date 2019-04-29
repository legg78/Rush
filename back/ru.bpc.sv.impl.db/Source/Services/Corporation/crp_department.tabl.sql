create table crp_department (
    id                  number(8) not null
    , seqnum            number(4) not null
    , parent_id         number(8)
    , corp_company_id   number(8) not null
    , corp_customer_id  number(12) not null
    , corp_contract_id  number(12) not null
    , inst_id           number(4) not null
)
/
comment on table crp_department is 'Enterprise departments assigned with exact contract.'
/
comment on column crp_department.id is 'Primary key'
/
comment on column crp_department.seqnum is 'Sequential number of data version'
/
comment on column crp_department.parent_id is 'Referenece to parent department'
/
comment on column crp_department.corp_company_id is 'Company identifier'
/
comment on column crp_department.corp_customer_id is 'Reference to coporate customer'
/
comment on column crp_department.corp_contract_id is 'Reference to corporate contract'
/
comment on column crp_department.inst_id is 'Institution'
/
