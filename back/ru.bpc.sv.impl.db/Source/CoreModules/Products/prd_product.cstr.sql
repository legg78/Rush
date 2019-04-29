alter table prd_product add (
    constraint prd_product_pk primary key (id)
)
/
alter table prd_product add (constraint prd_product_uk unique (product_number, inst_id))
/
