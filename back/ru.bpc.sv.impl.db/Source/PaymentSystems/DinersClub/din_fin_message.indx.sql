create index din_fin_message_CLMS0010_ndx on din_fin_message (decode(status, 'CLMS0010', 'CLMS0010', null))
/
create index din_fin_message_si_CLMS10_ndx on din_fin_message(
    decode(status, 'CLMS0010', sending_institution, null)
)
/
