create index bgn_fin_CLMS0010_ndx on bgn_fin (
    decode(status, 'CLMS0010', 'CLMS0010', null)
)
/
create index bgn_fin_oper_id_ndx on bgn_fin (oper_id)
/
create index bgn_fin_file_id_ndx on bgn_fin (file_id)
/
create index bgn_fin_trans_num_ndx on bgn_fin (transaction_number)
/
 