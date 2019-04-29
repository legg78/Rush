create unique index aup_epay_uk on aup_epay (rrn, card_number, local_date, terminal_id, merchant_id, iso_msg_type, direction)
/
create index aup_epay_ndx on aup_epay (trace, terminal_id, merchant_id, local_date, iso_msg_type, direction)
/