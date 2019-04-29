create table mup_form_1_trans (
    inst_id       number(4) not null
  , agent_id      number(8) 
  , oper_id       number(16)
  , subsection    number(1)
  , card_bin      varchar2(8 byte)
  , card_number   varchar2(23 byte)
  , column_type   varchar2(20 byte)
  , is_rf         number(1)
  , is_internet   number(1)
  , oper_sign     number(1)
  , oper_amount   number(22,4)
  , oper_currency varchar2(3 byte)
)
/

comment on table mup_form_1_trans is 'MUP form 1 - card emission'
/

comment on column mup_form_1_trans.inst_id is 'Institution ID'
/

comment on column mup_form_1_trans.agent_id      is 'Agent ID'
/
comment on column mup_form_1_trans.oper_id       is 'Operation ID'
/
comment on column mup_form_1_trans.subsection    is 'Sub section'
/
comment on column mup_form_1_trans.card_bin      is 'Card BIN'
/
comment on column mup_form_1_trans.card_number   is 'Card number'
/
comment on column mup_form_1_trans.column_type   is 'Column type'
/
comment on column mup_form_1_trans.is_rf         is 'Is RF'
/
comment on column mup_form_1_trans.is_internet   is 'Is internet'
/
comment on column mup_form_1_trans.oper_sign     is 'Operation sign'
/
comment on column mup_form_1_trans.oper_amount   is 'Operation amount'
/
comment on column mup_form_1_trans.oper_currency is 'Operation currency'
/

alter table mup_form_1_trans add merchant_number varchar2(15 char)
/
comment on column mup_form_1_trans.merchant_number is 'Merchant number for Virtual Office operation filter'
/
