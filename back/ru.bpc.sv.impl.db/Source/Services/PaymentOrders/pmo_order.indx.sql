create index pmo_order_template_ndx on pmo_order (template_id)
/
create index pmo_order_customer_ndx on pmo_order (customer_id)
/
create index pmo_order_object_ndx on pmo_order (object_id)
/
drop index pmo_order_object_ndx
/
create index pmo_order_object_entity_ndx on pmo_order (object_id, entity_type)
/****************** partition start ********************
    local
******************** partition end ********************/
/
create index pmo_order_status_ndx on pmo_order (decode(status, 'POSA0001', status, null))
/
drop index pmo_order_customer_ndx
/
create unique index pmo_order_uk on pmo_order (customer_id, is_template, payment_order_number)
/
create index pmo_order_orig_refnum_ndx on pmo_order (originator_refnum)
/
