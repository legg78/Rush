alter table prd_contract add (
    constraint prd_contract_pk primary key (id)
)
/

alter table prd_contract add (
    constraint prd_contract_uk unique (contract_number, inst_id)
)
/