create table vch_card_number (
    voucher_id  number(16)
  , part_key          as (to_date(substr(lpad(to_char(voucher_id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
  , card_number varchar2(24)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition avch_card_number_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table vch_card_number is 'Voucher card numbers.'
/
comment on column vch_card_number.voucher_id is 'Voucher ID - reference to VCH_VOUCHER table.'
/
comment on column vch_card_number.card_number is 'Card number ( if foreign card, otherwise see CARD_ID in VCH_VOUCHER table).'
/
