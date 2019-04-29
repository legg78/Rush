create index rul_name_index_pool_inrn_ndx on rul_name_index_pool(index_range_id)
/
drop index rul_name_index_pool_inrn_ndx
/
create index rul_name_index_pool_inrn_ndx on rul_name_index_pool(index_range_id)
/
create index rul_name_index_pool_random_ndx on rul_name_index_pool(decode(is_used, 0, index_range_id, null))
/
create index rul_name_index_pool_sequen_ndx on rul_name_index_pool(decode(is_used, 0, index_range_id, null), value)
/
