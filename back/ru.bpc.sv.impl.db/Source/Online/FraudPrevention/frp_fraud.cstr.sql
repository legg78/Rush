alter table frp_fraud add (constraint frp_fraud_pk primary key (id) , constraint frp_fraud_uk unique (auth_id, entity_type, object_id, is_external))
/
