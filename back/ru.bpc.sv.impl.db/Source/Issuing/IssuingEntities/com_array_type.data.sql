insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id) values (1001, 2, 'AUDITABLE_PRIVILEGES', 0, 386, 'ENTT0012', 'DTTPCHAR', 9999)
/
update com_array_type set data_type = 'DTTPNMBR' where id = 1001
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1031, 1, 'LIMITS_FOR_AVAL_BALANCE', 0, 1004, 'ENTTLIMT', 'DTTPCHAR', 9999, NULL, NULL)
/
