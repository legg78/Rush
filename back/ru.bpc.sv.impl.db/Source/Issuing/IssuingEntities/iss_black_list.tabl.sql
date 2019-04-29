create table iss_black_list(
    id          number(12)
  , card_number varchar2(24)
)
/

comment on table iss_black_list is 'Black list of card numbers'
/

comment on column iss_black_list.id is 'Card identifier'
/
comment on column iss_black_list.card_number is 'Card number'
/

alter table iss_black_list modify(id  not null)
/

alter table iss_black_list add constraint iss_black_list_pk  primary key  (id)
/
