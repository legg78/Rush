alter table prd_contract_type add constraint prd_contract_type_pk primary key (
    id
)
/

alter table prd_contract_type add constraint prd_contract_type_uk unique (
    contract_type
    , customer_entity_type
)
/
