create table csm_card(
    id                      number(16)
  , part_key                as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , card_number             varchar2(24)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition csm_card_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))         -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table csm_card is 'Dispute cases cards.'
/
comment on column csm_card.id is 'Primary key. Reference to CSM_CASE'
/
comment on column csm_card.card_number is 'Card number.'
/
