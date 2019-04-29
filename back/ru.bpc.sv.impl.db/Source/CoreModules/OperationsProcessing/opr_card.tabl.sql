create table opr_card (
    oper_id             number(16)
  , part_key            as (to_date(substr(lpad(to_char(oper_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , participant_type    varchar2(8)
  , card_number         varchar2(24)
  , split_hash          number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
subpartition by list (split_hash)                                                        -- [@skip patch]
subpartition template                                                                    -- [@skip patch]
(                                                                                        -- [@skip patch]
    <subpartition_list>                                                                  -- [@skip patch]
)                                                                                        -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition opr_card_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))         -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/
comment on table opr_card is 'Card numbers involved in operations stored here'
/
comment on column opr_card.oper_id is 'Operation ID'
/
comment on column opr_card.card_number is 'Card number'
/
comment on column opr_card.split_hash is 'Hash value to split further processing'
/
comment on column opr_card.participant_type is 'Type of operation participant (Dictionary "PRTY" - Issuer, Acquirer, Destination)'
/
alter table opr_card add card_number_postfix as (substr(card_number, -4)) virtual
/
comment on column opr_card.card_number_postfix is 'Card number postfix'
/
