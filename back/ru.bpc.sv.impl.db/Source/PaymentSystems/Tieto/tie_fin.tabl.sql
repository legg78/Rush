create table tie_fin (
    id                       number(16)
  , split_hash               number(4)
  , status                   varchar2(8)
  , inst_id                  number(4)
  , network_id               number(4)
  , file_id                  number(16)
  , is_incoming              number(1)
  , is_reversal              number(1)
  , is_invalid               number(1)
  , is_rejected              number(1)
  , reject_id                number(16)
  , dispute_id               number(16)
  , impact                   number(1)
  , mtid                     varchar2(2)
  , rec_centr                number(2)
  , send_centr               number(2)
  , iss_cmi                  varchar2(8)
  , send_cmi                 varchar2(8)
  , settl_cmi                varchar2(8)
  , acq_bank                 number(2)
  , acq_branch               number(3)
  , member                   number(1)
  , clearing_group           varchar2(2)
  , sender_ica               varchar2(4)
  , receiver_ica             varchar2(4)
  , merchant                 varchar2(7)
  , batch_nr                 varchar2(7)
  , slip_nr                  varchar2(7)
  , card                     varchar2(19)
  , exp_date                 date
  , tran_date_time           date
  , tran_type                varchar2(2)
  , appr_code                varchar2(6)
  , appr_src                 varchar2(1)
  , stan                     varchar2(6)
  , ref_number               varchar2(12)
  , amount                   number(12)
  , cash_back                number(12)
  , fee                      number(10)
  , currency                 varchar2(3)
  , ccy_exp                  number(1)
  , sb_amount                number(12)
  , sb_cshback               number(12)
  , sb_fee                   number(10)
  , sbnk_ccy                 varchar2(3)
  , sb_ccyexp                number(1)
  , sb_cnvrate               number(14,9)
  , sb_cnvdate               date
  , i_amount                 number(12)
  , i_cshback                number(12)
  , i_fee                    number(10)
  , ibnk_ccy                 varchar2(3)
  , i_ccyexp                 number(1)
  , i_cnvrate                number(14,9)
  , i_cnvdate                date
  , abvr_name                varchar2(27)
  , city                     varchar2(15)
  , country                  varchar2(3)
  , point_code               varchar2(12)
  , mcc_code                 varchar2(4)
  , terminal                 varchar2(1)
  , batch_id                 number(11)
  , settl_nr                 varchar2(11)
  , settl_date               date
  , acqref_nr                varchar2(23)
  , clr_file_id              number(18)
  , ms_number                number(8)
  , file_date                date
  , source_algorithm         varchar2(1)
  , err_code                 varchar2(2)
  , term_nr                  varchar2(8)
  , ecmc_fee                 number(8)
  , tran_info                varchar2(6)
  , pr_amount                number(12)
  , pr_cshback               number(12)
  , pr_fee                   number(10)
  , prnk_ccy                 varchar2(3)
  , pr_ccyexp                number(1)
  , pr_cnvrate               number(14,9)
  , pr_cnvdate               date
  , region                   varchar2(1)
  , card_type                varchar2(1)
  , proc_class               varchar2(4)
  , card_seq_nr              number(3)
  , msg_type                 varchar2(4)
  , org_msg_type             varchar2(4)
  , proc_code                varchar2(2)
  , msg_category             varchar2(1)
  , merchant_code            varchar2(15)
  , moto_ind                 varchar2(1)
  , susp_status              varchar2(1)
  , transact_row             varchar2(11)
  , authoriz_row             varchar2(11)
  , fld_043                  varchar2(99)
  , fld_098                  varchar2(25)
  , fld_102                  varchar2(28)
  , fld_103                  varchar2(28)
  , fld_104                  varchar2(100)
  , fld_039                  varchar2(3)
  , fld_sh6                  varchar2(4)
  , batch_date               date
  , tr_fee                   number(10)
  , fld_040                  varchar2(3)
  , fld_123_1                varchar2(1)
  , epi_42_48                varchar2(1)
  , fld_003                  varchar2(6)
  , msc                      number(10)
  , account_nr               varchar2(35)
  , epi_42_48_full           varchar2(3)
  , other_code               varchar2(20)
  , fld_015                  date
  , fld_095                  varchar2(99)
  , audit_date               date
  , other_fee1               number(10)
  , other_fee2               number(10)
  , other_fee3               number(10)
  , other_fee4               number(10)
  , other_fee5               number(10)
  , fld_030a                 number(12)
  , fld_055                  varchar2(999)
  , fld_126                  varchar2(4000)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table tie_fin is 'Local clearing financial messages in KONTS format'
/
comment on column tie_fin.id is 'Identifier'
/
comment on column tie_fin.split_hash is 'Hash value to split further processing'
/
comment on column tie_fin.status is 'Clearing message status'
/
comment on column tie_fin.inst_id is 'Institution identifier'
/
comment on column tie_fin.network_id is 'Network identifier'
/
comment on column tie_fin.file_id is 'Logical file identifier'
/
comment on column tie_fin.is_incoming is 'Incoming indicator'
/
comment on column tie_fin.is_reversal is 'Reversal indicator'
/
comment on column tie_fin.is_invalid is 'Invalid indicator'
/
comment on column tie_fin.is_rejected is 'Rejected indicator'
/
comment on column tie_fin.reject_id  is 'Reject message identifier'
/
comment on column tie_fin.dispute_id is 'Dispute identifier'
/
comment on column tie_fin.impact is 'Message impact'
/
comment on column tie_fin.mtid is 'Message type'
/
comment on column tie_fin.rec_centr is 'Receiver center code'
/
comment on column tie_fin.send_centr is 'Sender center code'
/
comment on column tie_fin.iss_cmi is 'Issuer bank`s CMI'
/
comment on column tie_fin.send_cmi is 'Acquirer bank`s CMI'
/
comment on column tie_fin.settl_cmi is 'CMI of settlement bank of the Issuer bank�s center'
/
comment on column tie_fin.acq_bank is '(W-File only) Acquirer bank'
/
comment on column tie_fin.acq_branch is '(W-File only) Acquirer bank branch'
/
comment on column tie_fin.member is '(W-File only) Acquirer bank member indicator'
/
comment on column tie_fin.clearing_group is '(W-File only) Local clearing group'
/
comment on column tie_fin.sender_ica is '(L-File only) Sender ICA'
/
comment on column tie_fin.receiver_ica is '(L-File only) Receiver ICA'
/
comment on column tie_fin.merchant is 'Card acceptor - merchant code'
/
comment on column tie_fin.batch_nr is 'Batch No. (last 7 symbols from batch_id)'
/
comment on column tie_fin.slip_nr is 'Transaction No. (must be unique in one batch)'
/
comment on column tie_fin.card is 'Card No.'
/
comment on column tie_fin.exp_date is 'Card expiry date'
/
comment on column tie_fin.tran_date_time is 'Transaction date'
/
comment on column tie_fin.tran_type is 'Transaction type'
/
comment on column tie_fin.appr_code is 'Authorization code'
/
comment on column tie_fin.appr_src is 'Source of authorization code'
/
comment on column tie_fin.stan is 'System Trace Audit Number'
/
comment on column tie_fin.ref_number is 'Retrieval Reference Number'
/
comment on column tie_fin.amount is 'Transaction amount in minor currency units'
/
comment on column tie_fin.cash_back is 'Cash back = 0'
/
comment on column tie_fin.fee is 'Processing fee'
/
comment on column tie_fin.currency is 'Transaction currency code - symbolic'
/
comment on column tie_fin.ccy_exp is 'Number of decimals in transaction currency'
/
comment on column tie_fin.sb_amount is 'Transaction amount in inter-center settlement currency'
/
comment on column tie_fin.sb_cshback is 'Cash back in inter-center settlement currency'
/
comment on column tie_fin.sb_fee is 'Processing fee in inter-center settlement currency'
/
comment on column tie_fin.sbnk_ccy is 'Inter-center settlement currency'
/
comment on column tie_fin.sb_ccyexp is 'Number of decimal fractions in inter-center settlement currency'
/
comment on column tie_fin.sb_cnvrate is 'Conversion rate from transaction currency to inter-center settlement currency'
/
comment on column tie_fin.sb_cnvdate is 'Conversion date'
/
comment on column tie_fin.i_amount is 'Transaction amount in issuer bank`s currency'
/
comment on column tie_fin.i_cshback is 'Cash back in issuer bank`s currency'
/
comment on column tie_fin.i_fee is 'Processing fee in issuer bank`s currency'
/
comment on column tie_fin.ibnk_ccy is 'Issuer bank`s currency code'
/
comment on column tie_fin.i_ccyexp is 'Number of decimal fractions in issuer bank`s currency'
/
comment on column tie_fin.i_cnvrate is 'Conversion rate from sender`s processing center currency to issuer bank`s currency'
/
comment on column tie_fin.i_cnvdate is 'Conversion date'
/
comment on column tie_fin.abvr_name is 'Merchant name'
/
comment on column tie_fin.city is 'Merchant city'
/
comment on column tie_fin.country is 'Merchant country code'
/
comment on column tie_fin.point_code is 'Point of Service Data Code'
/
comment on column tie_fin.mcc_code is 'Merchant category code'
/
comment on column tie_fin.terminal is 'Terminal type (A - ATM, P - POS, N - imprinter, space - use MCC instead to determine terminal type)'
/
comment on column tie_fin.batch_id is 'Batch identifier'
/
comment on column tie_fin.settl_nr is 'Settlement identifier'
/
comment on column tie_fin.settl_date is 'Settlement date'
/
comment on column tie_fin.acqref_nr is 'Acq Reference number'
/
comment on column tie_fin.clr_file_id is 'File identifier'
/
comment on column tie_fin.ms_number is 'The sequence number of the record within the file'
/
comment on column tie_fin.file_date is 'File date'
/
comment on column tie_fin.source_algorithm is 'Processing algorithm (1 - DOMESTIC, 2 - ECMC, 3 - VISA)'
/
comment on column tie_fin.err_code is 'Reserved'
/
comment on column tie_fin.term_nr is 'Terminal identifier'
/
comment on column tie_fin.ecmc_fee is 'EUROPAY fee'
/
comment on column tie_fin.tran_info is 'Additional transaction information:'
/
comment on column tie_fin.pr_amount is 'Transaction amount in acquirer bank`s center currency'
/
comment on column tie_fin.pr_cshback is 'Cash back in acquirer bank`s center currency'
/
comment on column tie_fin.pr_fee is 'Processing fee in acquirer bank`s center currency'
/
comment on column tie_fin.prnk_ccy is 'Code of acquirer bank`s center currency'
/
comment on column tie_fin.pr_ccyexp is 'Number of decimal fractions in the currency'
/
comment on column tie_fin.pr_cnvrate is 'Conversion rate from transaction currency to acquirer bank`s center currency'
/
comment on column tie_fin.pr_cnvdate is 'Conversion date'
/
comment on column tie_fin.region is 'VISA region of reporting BIN'
/
comment on column tie_fin.card_type is 'VISA Card Type'
/
comment on column tie_fin.proc_class is 'O ECMC Processing Class'
/
comment on column tie_fin.card_seq_nr is 'Card Sequence No.'
/
comment on column tie_fin.msg_type is 'Transaction message type'
/
comment on column tie_fin.org_msg_type is 'The type of original transaction'
/
comment on column tie_fin.proc_code is 'Processing code'
/
comment on column tie_fin.msg_category is 'Single/Dual'
/
comment on column tie_fin.merchant_code is 'Full merchant code'
/
comment on column tie_fin.moto_ind is 'Mail/Telephone or Electronic Commerce Indicator'
/
comment on column tie_fin.susp_status is 'Suspected status of transaction'
/
comment on column tie_fin.transact_row is 'RTPS transaction reference (N11)'
/
comment on column tie_fin.authoriz_row is 'RTPS authorization reference (N11)'
/
comment on column tie_fin.fld_043 is 'Card acceptor name / location'
/
comment on column tie_fin.fld_098 is 'Payee  - girocode + account no'
/
comment on column tie_fin.fld_102 is 'Account identification 1'
/
comment on column tie_fin.fld_103 is 'Account identification 2'
/
comment on column tie_fin.fld_104 is 'Transaction description - contains receiver name'
/
comment on column tie_fin.fld_039 is 'Response code - authorization response code'
/
comment on column tie_fin.fld_sh6 is 'Transaction Fee Rule'
/
comment on column tie_fin.batch_date is 'Batch date'
/
comment on column tie_fin.tr_fee is 'On-line commission'
/
comment on column tie_fin.fld_040 is 'Service Code'
/
comment on column tie_fin.fld_123_1 is 'CVC2 result code'
/
comment on column tie_fin.epi_42_48 is 'Electronic Commerce Security Level Indicator/UCAF Status'
/
comment on column tie_fin.fld_003 is 'Full processing code'
/
comment on column tie_fin.msc is 'Merchant Service Charge'
/
comment on column tie_fin.account_nr is 'Merchant Account Number'
/
comment on column tie_fin.epi_42_48_full is 'Full Electronic Commerce Security Level Indicator/UCAF Status'
/
comment on column tie_fin.other_code is 'Departments other_code'
/
comment on column tie_fin.fld_015 is 'FLD_015'
/
comment on column tie_fin.fld_095 is 'Issuer Reference Data (TLV - Tag 4 ASCII symbols, Length 3 DEC symbols, Value; Sample - 0003002AB1111004XXXX)'
/
comment on column tie_fin.audit_date is 'Audit date and time (YYYYMMDDHH24MISS) from FLD_031'
/
comment on column tie_fin.other_fee1 is 'Another acquirer surcharge 1 from FLD_046'
/
comment on column tie_fin.other_fee2 is 'Another acquirer surcharge 2 from FLD_046'
/
comment on column tie_fin.other_fee3 is 'Another acquirer surcharge 3 from FLD_046'
/
comment on column tie_fin.other_fee4 is 'Another acquirer surcharge 4 from FLD_046'
/
comment on column tie_fin.other_fee5 is 'Another acquirer surcharge 5 from FLD_046'
/
comment on column tie_fin.fld_030a is 'Original transaction amount in minor currency units'
/
comment on column tie_fin.fld_055 is 'Integrated Circuit Card (ICC) System-Related Data'
/
comment on column tie_fin.fld_126 is 'Acquirer reference data'
/
