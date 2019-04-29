alter table acq_merchant_type_tree add (
    constraint acq_merchant_type_tree_pk primary key(id)
  , constraint acq_merchant_type_tree_uk unique (merchant_type, parent_merchant_type, inst_id)
)
/