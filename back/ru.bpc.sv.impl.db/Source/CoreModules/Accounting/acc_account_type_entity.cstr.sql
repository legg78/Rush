alter table acc_account_type_entity add constraint acc_account_type_entity_pk primary key (
    id
)
/
create unique index acc_account_type_entity_uk on acc_account_type_entity (
    account_type
    , inst_id
    , decode(entity_type, 'ENTTAGNT', 'ENTTINST', entity_type) -- GL account type can be linked only to one entity
)
/ 
