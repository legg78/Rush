create table cst_vis_arr0100 (
       trans_code             varchar2(2),
       trans_code_qualifier   varchar2(1),
       acc_num               varchar2(16),
       acc_num_exten         varchar2(3),
       pcas_ind              varchar2(1),
       status                varchar2(8),
       fin_id                number(16),
       arn                   varchar2(23),
       acq_business_d        varchar2(8),
       mcc_name              varchar2(25),
       purchase_date         varchar2(4),
       acq_irf               varchar2(16),
       dist_amount           number(15,3),
       dist_currency         number(3),
       source_amount         number(15,3),
       source_currency       number(3),
       card_acceptor_id      number,
       mcc                   number(4),
       usage_code            number(1),
       sett_flag             number(1),
       ac_ind                varchar2(1),
       auth_code             varchar2(6),
       pos_term_cap          varchar2(1),
       cardholder_method     varchar2(1),
       pos_entry_mode        varchar2(2),
       proc_date             varchar2(4),
       reim_attr             varchar2(1),
       moto_eci              varchar2(1),
       cashback_amount       number(15,3),
       fpi                   varchar2(3),
       authorized_amount     number(15,3),
       inter_fee_amount      number(15,3),
       inter_fee_sign        varchar2(1),
       iss_country_code      number(3),
       file_name             varchar2(200),
       file_id number(16)
)
/
comment on table cst_vis_arr0100  is 'VISA TC 33.Support loading ARR0100(Acquirer Reconciliation Report)'
/   
comment on column cst_vis_arr0100.TRANS_CODE            is 'Transaction code'
/
comment on column cst_vis_arr0100.TRANS_CODE_QUALIFIER  is 'Transaction code qualifier'
/
comment on column cst_vis_arr0100.ACC_NUM               is 'Account Number'
/
comment on column cst_vis_arr0100.ACC_NUM_EXTEN         is 'Account number extension'
/
comment on column cst_vis_arr0100.PCAS_IND              is 'Positive Cardholder Authorization Service'
/
comment on column cst_vis_arr0100.ARN                   is 'Acquirer reference number'
/
comment on column cst_vis_arr0100.ACQ_BUSINESS_D        is 'Acquirer business ID'
/
comment on column cst_vis_arr0100.MCC_NAME              is 'Merchant Descriptor Name'
/
comment on column cst_vis_arr0100.PURCHASE_DATE         is 'Purchase Date'
/
comment on column cst_vis_arr0100.ACQ_IRF               is 'Acquirer IRF Descriptor'
/
comment on column cst_vis_arr0100.DIST_AMOUNT           is 'Destination Amount'
/
comment on column cst_vis_arr0100.DIST_CURRENCY         is 'Destination Currency code'
/
comment on column cst_vis_arr0100.SOURCE_AMOUNT         is 'Source amount'
/
comment on column cst_vis_arr0100.SOURCE_CURRENCY       is 'Source currency code'
/
comment on column cst_vis_arr0100.CARD_ACCEPTOR_ID      is 'Card Acceptor ID'
/
comment on column cst_vis_arr0100.MCC                   is 'Merchant category code'
/
comment on column cst_vis_arr0100.USAGE_CODE            is 'Usage code'
/
comment on column cst_vis_arr0100.SETT_FLAG             is 'Settlement flag'
/
comment on column cst_vis_arr0100.AC_IND                is 'Authorization characteristics indicator'
/
comment on column cst_vis_arr0100.AUTH_CODE             is 'Authorization code'
/
comment on column cst_vis_arr0100.POS_TERM_CAP          is 'POS terminal capability'
/
comment on column cst_vis_arr0100.CARDHOLDER_METHOD     is 'Cardholder ID method'
/
comment on column cst_vis_arr0100.POS_ENTRY_MODE        is 'POS entry mode'
/
comment on column cst_vis_arr0100.PROC_DATE             is 'Central processing date '
/
comment on column cst_vis_arr0100.REIM_ATTR             is 'Reimbursement Attribute'
/
comment on column cst_vis_arr0100.MOTO_ECI              is 'Mail/Phone/Ecom and Payment Indicator'
/
comment on column cst_vis_arr0100.CASHBACK_AMOUNT       is 'Cashback Amount'
/
comment on column cst_vis_arr0100.FPI                   is 'Fee Program Indicator'
/
comment on column cst_vis_arr0100.AUTHORIZED_AMOUNT     is 'Authorized amount'
/
comment on column cst_vis_arr0100.INTER_FEE_AMOUNT      is 'fee amount with sign'
/
comment on column cst_vis_arr0100.INTER_FEE_SIGN        is 'Interchange fee sign'
/
comment on column cst_vis_arr0100.ISS_COUNTRY_CODE      is 'Issuer Country Code'
/
