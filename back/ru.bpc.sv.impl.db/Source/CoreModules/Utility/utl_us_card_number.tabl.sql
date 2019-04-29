create table utl_us_card_number (    
    id               number(12)   not null
  , split_hash       number(4)
  , new_card_number  varchar2(24)
  , new_card_hash    number(12)
  , new_card_mask    varchar2(24)
  , old_card_number  varchar2(24)
  , old_card_hash    number(12)
  , old_card_mask    varchar2(24)
)
/

comment on table utl_us_card_number is 'Configuration table for obfuscation utility procedure'
/
comment on column utl_us_card_number.id               is 'Card ID, primary key'
/
comment on column utl_us_card_number.split_hash       is 'Split hash'
/
comment on column utl_us_card_number.new_card_number  is 'New card number'
/
comment on column utl_us_card_number.new_card_hash    is 'New card hash'
/
comment on column utl_us_card_number.new_card_mask    is 'New card mask'
/
comment on column utl_us_card_number.old_card_number  is 'Old card number'
/
comment on column utl_us_card_number.old_card_hash    is 'Old card hash'
/
comment on column utl_us_card_number.old_card_mask    is 'Old card mask'
/
