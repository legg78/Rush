alter table pmo_order_data add constraint pmo_order_data_uk unique(order_id, param_id) using index
/
alter table pmo_order_data add constraint pmo_order_data_pk primary key (id) using index    -- [@skip patch]
/
