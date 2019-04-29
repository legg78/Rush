create index aup_iso8583bic_auth_id_ndx on aup_iso8583bic (auth_id)
/

create index aup_iso8583bic_rrn_ndx on aup_iso8583bic (rrn, terminal_id)
/

create index aup_iso8583bic_trace_ndx on aup_iso8583bic (trace, local_date, terminal_id)
/
