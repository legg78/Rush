create index iss_card_hash_ndx on iss_card (card_hash)
/

create index iss_card_mask_rvrs_ndx on iss_card (reverse(card_mask))
/
create index iss_card_contract on iss_card (contract_id)
/
create index iss_card_cardholder_ndx on iss_card (cardholder_id)
/
create index iss_card_customer_ndx on iss_card (customer_id)
/
