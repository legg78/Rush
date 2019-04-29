create global temporary table prd_attribute_order_tmp
(
    id             number(8) not null
  , nesting_level  number(3) not null
  , priority       number(8) not null
)
on commit delete rows
/
comment on table prd_attribute_order_tmp is 'The table contains ID''s of all product''s attributes sorted by their display orders.'
/
comment on column prd_attribute_order_tmp.id is 'ID of attribute'
/
comment on column prd_attribute_order_tmp.nesting_level is 'Nesting level of attribute in hierarchy'
/
comment on column prd_attribute_order_tmp.priority is 'Order number of attribute in hierarchy'
/