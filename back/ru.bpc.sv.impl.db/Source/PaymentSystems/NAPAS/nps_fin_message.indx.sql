create index nps_fin_message_load_ndx on nps_fin_message(decode(status, 'CLMS0040', 'CLMS0040', null))
/
create index nps_fin_message_date_ndx on nps_fin_message(trans_date)
/
create index nps_fin_message_match_ndx on nps_fin_message(match_oper_id)
/
