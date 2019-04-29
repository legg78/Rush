create table vis_multipurpose
(
  id               number(16) not null,
  file_id          number(16),
  record_number    number(6),
  status           varchar2(8),  
  iss_acq          varchar2(1),
  mvv_code         varchar2(10),
  remote_terminal  varchar2(1),
  charge_ind       varchar2(1),
  account_prod_id  varchar2(2),
  bus_app_ind      varchar2(2),
  funds_source     varchar2(1),
  affiliate_bin    varchar2(10),
  sttl_date        date,
  trxn_ind         varchar2(15),
  val_code         varchar2(4),
  refnum           varchar2(12),
  trace_num        varchar2(6),
  batch_num        varchar2(4),
  req_msg_type     number(4),
  resp_code        varchar2(2),
  proc_code        varchar2(6),
  card_number      varchar2(19),
  trxn_amount      number(12),
  currency_code    number(3),
  match_auth_id    number(16),
  inst_id          number(4)
)
/
comment on table vis_multipurpose
  is 'Table is used to store Visa TC33 Multipurpose Messages - parsed from TCR0 ''Report text'' field, for record type: Financial Transaction Record 1 (V22200)'
/
comment on column vis_multipurpose.id is 'Unique internal message number'
/
comment on column vis_multipurpose.file_id is 'Unique internal file number'
/  
comment on column vis_multipurpose.record_number is 'Record number'
/
comment on column vis_multipurpose.iss_acq is 'Issuer-Acquirer Indicator. I = Issuer, A = Acquirer'
/   
comment on column vis_multipurpose.mvv_code is 'MVV Code. Field 64.4'
/
comment on column vis_multipurpose.remote_terminal is 'Remote Terminal Indicator. Field 126.12'
/
comment on column vis_multipurpose.charge_ind is 'Charge Indicator'
/
comment on column vis_multipurpose.account_prod_id is 'Account Product ID'
/  
comment on column vis_multipurpose.bus_app_ind is 'Business Application Identifier. Field 104, usage 2'
/   
comment on column vis_multipurpose.funds_source is 'Business Application Identifier. Field 104'
/  
comment on column vis_multipurpose.affiliate_bin is 'Affiliate BIN. If ''I'', the BIN is for the acquirer. If ''A'', the BIN is for the issuer'
/  
comment on column vis_multipurpose.sttl_date is 'Settlement Date'
/
comment on column vis_multipurpose.trxn_ind is 'Transaction Identifier. Field 62.2'
/  
comment on column vis_multipurpose.val_code is 'Validation Code. Field 62.3'
/  
comment on column vis_multipurpose.refnum is 'Retrieval Reference Number. Field 37'
/  
comment on column vis_multipurpose.trace_num is 'Trace Number. Field 11'
/  
comment on column vis_multipurpose.batch_num is 'Batch Number. Header Field 10'
/     
comment on column vis_multipurpose.req_msg_type is 'Request Message Type'
/  
comment on column vis_multipurpose.resp_code is 'Response Code. Field 39'
/  
comment on column vis_multipurpose.proc_code is 'Processing Code. Field 3'
/     
comment on column vis_multipurpose.card_number is 'Card Number. Field 2'
/  
comment on column vis_multipurpose.trxn_amount is 'Transaction Amount. For transaction originator: Field 4'
/    
comment on column vis_multipurpose.currency_code is 'Currency Code. For transaction originator: Field 49'
/    
comment on column vis_multipurpose.match_auth_id is 'Id of matched authorization. Ref to opr_operation.id'
/  
comment on column vis_multipurpose.inst_id is 'ID of the financial institution the record belongs to'
/             
  


















 
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
