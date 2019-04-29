create or replace type mcw_mcom_fee_tpr as object(
    card_acceptor_id_code      varchar2(15)
  , card_number                varchar2(19)
  , country_code               varchar2(3)
  , currency                   varchar2(3)
  , fee_date                   date
  , destination_member         varchar2(11)
  , fee_id                     varchar2(12)
  , fee_amount                 number(22,4)
  , credit_sender              number(1)
  , credit_receiver            number(1)
  , message                    varchar2(200)
  , reason_code                varchar2(4)
  , claim_id                   varchar2(20)
)
/
