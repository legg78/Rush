alter table iss_card_token add constraint iss_card_token_pk primary key (id)
/
alter table iss_card_token add constraint iss_card_token_uk unique (token)
/
