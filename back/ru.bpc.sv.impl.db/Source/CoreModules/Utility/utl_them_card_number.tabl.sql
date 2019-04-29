create table utl_them_card_number (
    id                number (12)   not null
  , old_card_number   varchar2(24)
  , new_card_number   varchar2(24)
  , split_hash        number(4)
)
/

comment on table utl_them_card_number is 'Configuration table for obfuscation utility procedure'
/
comment on column utl_them_card_number.id               is 'Primary key'
/
comment on column utl_them_card_number.old_card_number  is 'Old card number'
/
comment on column utl_them_card_number.new_card_number  is 'New card number'
/
comment on column utl_them_card_number.split_hash       is 'Split hash'
/

