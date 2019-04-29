create index mcw_abu_iss_msg_file_ndx on mcw_abu_iss_msg(file_id)
/
create index mcw_abu_iss_msg_search_ndx on mcw_abu_iss_msg(old_card_number, old_expiration_date, new_card_number, new_expiration_date, reason_code)
/
