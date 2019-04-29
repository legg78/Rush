create or replace type cst_transfers_tpr as object (
    oper_id             number(16)
  , oper_date           date
  , host_date           date
  , status              varchar2(8 byte)
  , status_reason       varchar2(8 byte)
  , is_reversal         number(1)
  , original_id         number(16)
  , merchant_name       varchar2(200 byte)
  , oper_type           varchar2(8 byte)
  , terminal_number     varchar2(16)
  , oper_amount         number(22, 4)
  , card_mask           varchar2(24)
  , card_network_id     number(4)
  , dst_card_network_id number(4)
  , dst_card_mask       varchar2(24)
  , exponent            number(4)
  , oper_currency       varchar2(3 byte)
  , network_id_source   number(4)
)
/
