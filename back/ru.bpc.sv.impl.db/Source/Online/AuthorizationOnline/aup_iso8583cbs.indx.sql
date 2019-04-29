create index aup_iso8583cbs_auth_id_ndx on aup_iso8583cbs (auth_id)
/
create index aup_iso8583cbs_rrn_ndx on aup_iso8583cbs (rrn, terminal_id)
/
create index aup_iso8583cbs_trace_ndx on aup_iso8583cbs (trace, local_date, terminal_id)
/
create index aup_iso8583cbs_resp_msg on aup_iso8583cbs (resp_code, iso_msg_type)
/
create index aup_iso8583cbs_t_a_id_resp_msg on aup_iso8583cbs (terminal_id, auth_id, resp_code, iso_msg_type)
/
