alter table iss_card_instance add constraint iss_plastic_pk primary key (
    id
)
/

create unique index iss_card_instance_uk on iss_card_instance (
    card_id
    , seq_number
)
/
