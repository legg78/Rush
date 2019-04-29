create index aup_iso8583pos_auth_id_ndx on aup_iso8583pos (auth_id)
/

create index aup_iso8583pos_rrn_ndx on aup_iso8583pos (rrn, terminal_id)
/

create index aup_iso8583pos_trace_ndx on aup_iso8583pos (trace, local_date, terminal_id)
/
create index aup_iso8583pos_resp_msg on aup_iso8583pos (resp_code, iso_msg_type)
/
create index aup_iso8583pos_t_a_id_resp_msg on aup_iso8583pos (terminal_id, auth_id, resp_code, iso_msg_type)
/