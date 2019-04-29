create unique index cst_smt_msstrxn_orig_file_uk on cst_smt_msstrxn_map_tmp (original_file_name, external_auth_id)
/
create index cst_smt_msstrxn_file_load_ndx on cst_smt_msstrxn_map_tmp (input_file_name, load_date)
/
