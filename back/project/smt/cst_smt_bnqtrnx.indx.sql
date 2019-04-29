create index cst_smt_bnqtrnx_status on cst_smt_bnqtrnx (decode(status,'BQST0001',split_hash,null))
/

create index cst_bnqtrnx_session_file_ndx on cst_smt_bnqtrnx (session_file_id)
/

create unique index cst_bnqtrnx_pk_ndx on cst_smt_bnqtrnx (id)
/
