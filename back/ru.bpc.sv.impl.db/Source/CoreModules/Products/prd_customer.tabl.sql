create table prd_customer (
    id                   number(12)
  , seqnum               number(4)
  , entity_type          varchar2(8)
  , object_id            number(16)
  , customer_number      varchar2(200)
  , contract_id          number(12)
  , inst_id              number(4)
  , split_hash           number(4)
  , category             varchar2(8)
  , relation             varchar2(8)
  , resident             number(1)
  , nationality          varchar2(3)
  , credit_rating        varchar2(8)
  , money_laundry_risk   varchar2(8)
  , money_laundry_reason varchar2(8)
  , last_modify_date     date
  , last_modify_user     number(8)
  , status               varchar2(8)
  , ext_entity_type      varchar2(8)
  , ext_object_id        number(16)
  , reg_date             date
)
/

comment on table prd_customer is 'Customers.'
/

comment on column prd_customer.id is 'Customer identifier'
/

comment on column prd_customer.seqnum is 'Sequential number of data record version'
/

comment on column prd_customer.entity_type is 'Entity type (ENTTPERS, ENTTCORP)'
/

comment on column prd_customer.object_id is 'Object identifier (person or corporate)'
/

comment on column prd_customer.customer_number is 'External customer number'
/

comment on column prd_customer.contract_id is 'Default customer contract. Using for defining services of customer level.'
/

comment on column prd_customer.inst_id is 'Owner institution identifier'
/

comment on column prd_customer.split_hash is 'Hash value to split processing'
/

comment on column prd_customer.category is 'Category of customer'
/

comment on column prd_customer.relation is 'Relationship client to bank'
/

comment on column prd_customer.resident is 'Person or company is a resident of bank allocation country (1-yes, 0-no)'
/

comment on column prd_customer.nationality is 'Customer nationality'
/

comment on column prd_customer.credit_rating is 'Customer creditability level'
/

comment on column prd_customer.money_laundry_risk is 'Risk of money laundry by customer (Low or High).'
/

comment on column prd_customer.money_laundry_reason is 'Reason of high risk money laundry by customer'
/

comment on column prd_customer.last_modify_date is 'Date of last updating of customer''s data'
/

comment on column prd_customer.last_modify_user is 'User updated customer''s data at the last time'
/

comment on column prd_customer.status is 'Customer status (CTST dictionary)'
/

comment on column prd_customer.ext_entity_type is 'Extended entity type reprsented by customer (Institution, Agent, Service provider etc)'
/

comment on column prd_customer.ext_object_id is 'Identifier of extended entity type reprsented by customer (Institution, Agent, Service provider etc)'
/

comment on column prd_customer.reg_date is 'Customer registration date.'
/

alter table prd_customer add employment_status varchar2(8)
/

alter table prd_customer add employment_period varchar2(8)
/

alter table prd_customer add residence_type varchar2(8)
/

alter table prd_customer add marital_status_date date
/

alter table prd_customer add income_range varchar2(8)
/

alter table prd_customer add number_of_children varchar2(8)
/

comment on column prd_customer.employment_status is 'Employment status (Dictionary CSES)'
/

comment on column prd_customer.employment_period is 'Employment period (Dictionary EMPR)'
/

comment on column prd_customer.residence_type is 'Residence type (Dictionary REST)'
/

comment on column prd_customer.marital_status_date is 'Martial status date'
/

comment on column prd_customer.income_range is 'Income (salary) range (Dictionary INCR)'
/

comment on column prd_customer.number_of_children is 'Number of children (Dictionary CHLD)'
/

alter table prd_customer add marital_status varchar2(8)
/

comment on column prd_customer.marital_status is 'Martial status (Dictionary MRST)'
/
