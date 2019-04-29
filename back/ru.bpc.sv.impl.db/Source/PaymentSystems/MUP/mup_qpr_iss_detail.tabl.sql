create table mup_qpr_iss_detail(  
    id             number(16)
  ,	inst_id        number(4)
  , agent_id       number(8)
  , subsection     number(1)
  , card_bin       varchar2(8)
  , card_number    varchar2(23)
  , column_type    varchar2(20)
  , is_rf          number(1)
  , is_internet    number(1)
  , oper_sign      number(1)
  , oper_amount    number(22, 4)
  , oper_currency  varchar2(3)
)
/
comment on table mup_qpr_iss_detail is 'Report form MIR Issuing details'
/
comment on column mup_qpr_iss_detail.id            is 'Operation ID'
/
comment on column mup_qpr_iss_detail.inst_id       is 'Institution ID'
/
comment on column mup_qpr_iss_detail.agent_id      is 'Agent ID'
/
comment on column mup_qpr_iss_detail.subsection    is 'Subsection'
/
comment on column mup_qpr_iss_detail.card_bin      is 'Card BIN'     
/
comment on column mup_qpr_iss_detail.card_number   is 'Card number'
/
comment on column mup_qpr_iss_detail.column_type   is 'Column type'
/
comment on column mup_qpr_iss_detail.is_rf         is 'Is Russian'        
/
comment on column mup_qpr_iss_detail.is_internet   is 'Is Internet transaction'
/
comment on column mup_qpr_iss_detail.oper_sign     is 'Operation sign'
/
comment on column mup_qpr_iss_detail.oper_amount   is 'Operation amount'
/
comment on column mup_qpr_iss_detail.oper_currency is 'Operation currency'
/
