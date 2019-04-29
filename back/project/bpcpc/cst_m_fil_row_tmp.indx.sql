create index cst_m_fil_row_event_id_ndx on cst_m_fil_row_tmp (event_id)
/
create index cst_m_fil_row_group_ndx on cst_m_fil_row_tmp (contract_number, oper_currency, transaction_type)
/
create index cst_m_fil_row_oper_cur_ndx on cst_m_fil_row_tmp (oper_currency)
/
