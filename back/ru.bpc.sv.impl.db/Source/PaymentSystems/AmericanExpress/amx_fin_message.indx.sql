create index amx_fin_message_CLMS0010_ndx on amx_fin_message (
    decode(status, 'CLMS0010', 'CLMS0010', null)
)
/
create index amx_fin_message_arn_ndx on amx_fin_message(arn)
/
create index amx_fin_message_collection_ndx on amx_fin_message(is_collection_only)
/
create index amx_fin_message_apn_CLMS10_ndx on amx_fin_message(
    decode(status, 'CLMS0010', apn, null)
)
/
