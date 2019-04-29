begin update iss_card_instance set card_uid = card_id where card_uid is null; end;
