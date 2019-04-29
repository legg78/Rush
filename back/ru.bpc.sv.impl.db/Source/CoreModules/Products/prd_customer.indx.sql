create index prd_customer_number_ndx on prd_customer (reverse(customer_number))
/

create index prd_customer_entity_ndx on prd_customer (entity_type, object_id)
/
