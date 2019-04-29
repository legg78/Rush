create global temporary table cst_collection_tmp(
    tag             varchar2(4)
  , tag_order       number(4)
  , customer_number varchar2(200)
  , data_content    varchar2(4000)
)on commit delete rows
/
comment on table cst_collection_tmp is 'Temporary table for saving collection info'
/
comment on column cst_collection_tmp.tag is 'Tag'
/
comment on column cst_collection_tmp.tag_order is 'Tag order'
/
comment on column cst_collection_tmp.customer_number is 'Customer number'
/
comment on column cst_collection_tmp.data_content is 'Data content'
/
