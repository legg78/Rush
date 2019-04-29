create index iss_card_status_CSTE0100_ndx on iss_card_instance (
    decode(state, 'CSTE0100', 'CSTE0100')
)
/
create index iss_card_uid_ndx on iss_card_instance (reverse(card_uid))
/
create index iss_card_inst_expir_state_ndx on iss_card_instance (expir_date desc, state)
/
create index iss_delivery_ref_number_ndx on iss_card_instance (delivery_ref_number)
/
