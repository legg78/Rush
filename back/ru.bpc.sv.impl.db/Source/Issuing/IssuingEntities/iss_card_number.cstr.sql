alter table iss_card_number add constraint iss_card_number_pk primary key (
    card_id
)
/
create unique index iss_card_number_uk on iss_card_number (
    card_number
)
/

drop index iss_card_number_uk
/

create unique index iss_card_number_uk on iss_card_number (reverse(card_number))
/