create table vis_fin_message(
    id                      number(16)
  , status                  varchar2(8)
  , file_id                 number(16)
  , batch_id                number(12)
  , record_number           number(8)
  , is_reversal             number(1)
  , is_incoming             number(1)
  , is_returned             number(1)
  , is_invalid              number(1)
  , dispute_id              number(16)
  , rrn                     varchar2(12)
  , inst_id                 number(4)
  , network_id              number(4)
  , trans_code              varchar2(2)
  , trans_code_qualifier    varchar2(1)
  , card_id                 number(12)
  , card_mask               varchar2(24)
  , card_hash               number(12)
  , oper_amount             number(22,4)
  , oper_currency           varchar2(3)
  , oper_date               date
  , sttl_amount             number(22,4)
  , sttl_currency           varchar2(3)
  , network_amount          number(22,4)
  , network_currency        varchar2(3)
  , floor_limit_ind         varchar2(1)
  , exept_file_ind          varchar2(1)
  , pcas_ind                varchar2(1)
  , arn                     varchar2(23)
  , acquirer_bin            varchar2(12)
  , acq_business_id         varchar2(8)
  , merchant_name           varchar2(25)
  , merchant_city           varchar2(13)
  , merchant_country        varchar2(3)
  , merchant_postal_code    varchar2(10)
  , merchant_region         varchar2(3)
  , merchant_street         varchar2(200)
  , mcc                     varchar2(4)
  , req_pay_service         varchar2(8)
  , usage_code              varchar2(1)
  , reason_code             varchar2(2)
  , settlement_flag         varchar2(1)
  , auth_char_ind           varchar2(8)
  , auth_code               varchar2(6)
  , pos_terminal_cap        varchar2(8)
  , inter_fee_ind           varchar2(1)
  , crdh_id_method          varchar2(1)
  , collect_only_flag       varchar2(1)
  , pos_entry_mode          varchar2(2)
  , central_proc_date       varchar2(4)
  , reimburst_attr          varchar2(1)
  , iss_workst_bin          varchar2(6)
  , acq_workst_bin          varchar2(6)
  , chargeback_ref_num      varchar2(6)
  , docum_ind               varchar2(1)
  , member_msg_text         varchar2(50)
  , spec_cond_ind           varchar2(2)
  , fee_program_ind         varchar2(3)
  , issuer_charge           varchar2(1)
  , merchant_number         varchar2(15)
  , terminal_number         varchar2(8)
  , national_reimb_fee      varchar2(12)
  , electr_comm_ind         varchar2(1)
  , spec_chargeback_ind     varchar2(1)
  , interface_trace_num     varchar2(6)
  , unatt_accept_term_ind   varchar2(1)
  , prepaid_card_ind        varchar2(1)
  , service_development     varchar2(1)
  , avs_resp_code           varchar2(1)
  , auth_source_code        varchar2(1)
  , purch_id_format         varchar2(1)
  , account_selection       varchar2(1)
  , installment_pay_count   varchar2(2)
  , purch_id                varchar2(25)
  , cashback                varchar2(9)
  , chip_cond_code          varchar2(1)
  , pos_environment         varchar2(1)
  , transaction_type        varchar2(2)
  , card_seq_number         varchar2(3)
  , terminal_profile        varchar2(6)
  , unpredict_number        varchar2(8)
  , appl_trans_counter      varchar2(4)
  , appl_interch_profile    varchar2(4)
  , cryptogram              varchar2(16)
  , term_verif_result       varchar2(10)
  , cryptogram_amount       varchar2(12)
  , card_verif_result       varchar2(8)
  , issuer_appl_data        varchar2(64)
  , issuer_script_result    varchar2(10)
  , card_expir_date         varchar2(4)
  , cryptogram_version      varchar2(2)
  , cvv2_result_code        varchar2(1)
  , auth_resp_code          varchar2(2)
  , cryptogram_info_data    varchar2(2)
  , transaction_id          varchar2(15)
  , merchant_verif_value    varchar2(10)
)
/
comment on table vis_fin_message is 'VISA financial mesages. Contains VISA TCs: 05, 06, 07, 15, 16, 17, 25, 26, 27, 35, 36, 37.'
/
comment on column vis_fin_message.record_number is 'Number of record in clearing file.'
/
comment on column vis_fin_message.card_id is 'Reference to card dictionary.'
/
comment on column vis_fin_message.id is 'Primary key. Contain same value as in corresponding record in OPR_OPERATION table.'
/
comment on column vis_fin_message.status is 'Message status.'
/
comment on column vis_fin_message.is_reversal is 'Reversal flag.'
/
comment on column vis_fin_message.is_incoming is 'Incoming/Outgouing message flag. 1- incoming, 0- outgoing.'
/
comment on column vis_fin_message.is_returned is 'Rejected message flag.'
/
comment on column vis_fin_message.inst_id is 'Institution identifier.'
/
comment on column vis_fin_message.trans_code is 'VISA transaction code.'
/
comment on column vis_fin_message.card_mask is 'Masked card number'
/
comment on column vis_fin_message.card_hash is 'Card number hash value'
/
comment on column vis_fin_message.oper_amount is 'Source Amount.'
/
comment on column vis_fin_message.oper_currency is 'Source Currency Code.'
/
comment on column vis_fin_message.oper_date is 'Purchase Date.'
/
comment on column vis_fin_message.sttl_amount is 'Destination Amount.'
/
comment on column vis_fin_message.sttl_currency is 'Destination currency code.'
/
comment on column vis_fin_message.arn is 'Acquiring reference number.'
/
comment on column vis_fin_message.acq_business_id is 'Acquirer business identifier.'
/
comment on column vis_fin_message.merchant_name is 'Merchant name.'
/
comment on column vis_fin_message.merchant_city is 'Merchant city.'
/
comment on column vis_fin_message.merchant_country is 'Merchant country code (3 digits ISO code).'
/
comment on column vis_fin_message.merchant_postal_code is 'Merchant postal code.'
/
comment on column vis_fin_message.merchant_region is 'Merchant region code.'
/
comment on column vis_fin_message.mcc is 'Merchant category code.'
/
comment on column vis_fin_message.req_pay_service is 'Requested payment service.'
/
comment on column vis_fin_message.usage_code is 'Usage code.'
/
comment on column vis_fin_message.reason_code is 'Reason code.'
/
comment on column vis_fin_message.settlement_flag is 'Settlement flag.'
/
comment on column vis_fin_message.auth_char_ind is 'Authorization characteristics indicator.'
/
comment on column vis_fin_message.auth_code is 'Authorization code.'
/
comment on column vis_fin_message.pos_terminal_cap is 'POS terminal capability.'
/
comment on column vis_fin_message.inter_fee_ind is 'International fee indicator.'
/
comment on column vis_fin_message.crdh_id_method is 'Cardholder ID method.'
/
comment on column vis_fin_message.collect_only_flag is 'Collection-only flag.'
/
comment on column vis_fin_message.pos_entry_mode is 'POS entry mode.'
/
comment on column vis_fin_message.central_proc_date is 'Central processing date (YDDD).'
/
comment on column vis_fin_message.reimburst_attr is 'Reimbursement attribute.'
/
comment on column vis_fin_message.iss_workst_bin is 'Issuer workstation BIN.'
/
comment on column vis_fin_message.acq_workst_bin is 'Acquirer workstation BIN.'
/
comment on column vis_fin_message.chargeback_ref_num is 'Chargeback reference number.'
/
comment on column vis_fin_message.docum_ind is 'Documentation indicator.'
/
comment on column vis_fin_message.member_msg_text is 'Member message text.'
/
comment on column vis_fin_message.spec_cond_ind is 'Special condition indicators.'
/
comment on column vis_fin_message.fee_program_ind is 'Fee program indicator.'
/
comment on column vis_fin_message.issuer_charge is 'Issuer charge.'
/
comment on column vis_fin_message.merchant_number is 'Card Acceptor ID (Merchant ISO number).'
/
comment on column vis_fin_message.terminal_number is 'Terminal ISO ID.'
/
comment on column vis_fin_message.national_reimb_fee is 'National reimbursement fee.'
/
comment on column vis_fin_message.electr_comm_ind is 'Mail/Telephone or Electronic commerce Indicator.'
/
comment on column vis_fin_message.spec_chargeback_ind is 'Special chargeback indicator.'
/
comment on column vis_fin_message.interface_trace_num is 'Interface trace number.'
/
comment on column vis_fin_message.unatt_accept_term_ind is 'Unattended acceptance terminal indicator.'
/
comment on column vis_fin_message.prepaid_card_ind is 'Prepaid card indicator.'
/
comment on column vis_fin_message.service_development is 'Service development field.'
/
comment on column vis_fin_message.avs_resp_code is 'AVS response code.'
/
comment on column vis_fin_message.auth_source_code is 'Authorization source code.'
/
comment on column vis_fin_message.purch_id_format is 'Purchase identifier format.'
/
comment on column vis_fin_message.account_selection is 'Account selection.'
/
comment on column vis_fin_message.installment_pay_count is 'Installment payment count.'
/
comment on column vis_fin_message.purch_id is 'Purchase identifier.'
/
comment on column vis_fin_message.cashback is 'Cashback.'
/
comment on column vis_fin_message.chip_cond_code is 'Chip condition code.'
/
comment on column vis_fin_message.pos_environment is 'POS environment.'
/
comment on column vis_fin_message.card_seq_number is 'Card sequence number.'
/
comment on column vis_fin_message.terminal_profile is 'Terminal capability profile.'
/
comment on column vis_fin_message.unpredict_number is 'Unpredictable number.'
/
comment on column vis_fin_message.appl_trans_counter is 'Application transaction counter.'
/
comment on column vis_fin_message.appl_interch_profile is 'Application interchange profile.'
/
comment on column vis_fin_message.cryptogram is 'Cryptogram.'
/
comment on column vis_fin_message.term_verif_result is 'Terminal verification results.'
/
comment on column vis_fin_message.cryptogram_amount is 'Cryptogram amount.'
/
comment on column vis_fin_message.card_expir_date is 'Card expiration date. (MMYY)'
/
comment on column vis_fin_message.cryptogram_version is 'Cryptogram version.'
/
comment on column vis_fin_message.cvv2_result_code is 'CVV2 result code.'
/
comment on column vis_fin_message.auth_resp_code is 'Authorization response code.'
/
comment on column vis_fin_message.card_verif_result is 'Card verification results.'
/
comment on column vis_fin_message.floor_limit_ind is 'Floor limit indicator.'
/
comment on column vis_fin_message.exept_file_ind is 'CRB/Exception file indicator.'
/
comment on column vis_fin_message.pcas_ind is 'Positive Cardholder Authorization Service (PCAS) indicator.'
/
comment on column vis_fin_message.transaction_type is 'Transaction Type.'
/
comment on column vis_fin_message.issuer_appl_data is 'Issuer application data.'
/
comment on column vis_fin_message.issuer_script_result is 'Issuer script 1 results.'
/
comment on column vis_fin_message.is_invalid is 'Is financial message loaded with errors.'
/
comment on column vis_fin_message.network_amount is 'Amount in network settlement currency.'
/
comment on column vis_fin_message.network_currency is 'Network settlement currency.'
/
comment on column vis_fin_message.dispute_id is 'Reference to the dispute message group.'
/
comment on column vis_fin_message.trans_code_qualifier is 'Transaction code qualifier.'
/
comment on column vis_fin_message.batch_id is 'Identifier of batch  in clearing file.'
/
comment on column vis_fin_message.file_id is 'Reference to clearing file.'
/
comment on column vis_fin_message.network_id is 'Payment network identifier.'
/
comment on column vis_fin_message.rrn is 'Retrieval reference number.'
/
comment on column vis_fin_message.merchant_street is 'Merchant Street.'
/
comment on column vis_fin_message.acquirer_bin is 'Acquirer Bank Identification Number.'
/
comment on column vis_fin_message.cryptogram_info_data is 'Cryptogram Information Data.'
/
comment on column vis_fin_message.transaction_id is 'Network Transaction Identifier'
/
comment on column vis_fin_message.merchant_verif_value is 'Merchant Verification Value'
/
alter table vis_fin_message add (
    host_inst_id number(4)
)
/
comment on column vis_fin_message.host_inst_id is 'Host institution identifier'
/
alter table vis_fin_message add (
    proc_bin varchar2(6)
)
/
comment on column vis_fin_message.proc_bin is 'Processing BIN'
/

alter table vis_fin_message
 add (chargeback_reason_code  varchar2(4))
/
alter table vis_fin_message
 add (destination_channel  varchar2(1))
/
alter table vis_fin_message
 add (source_channel  varchar2(1))
/


comment on column vis_fin_message.chargeback_reason_code is 'Chargeback Reason Code'
/
comment on column vis_fin_message.destination_channel is 'Destination Channel'
/
comment on column vis_fin_message.source_channel is 'Source Channel'
/
alter table vis_fin_message add acq_inst_bin varchar2(12)
/
comment on column vis_fin_message.acq_inst_bin is 'Acquirer institution BIN'
/
comment on column vis_fin_message.card_expir_date is 'Card expiration date. (YYMM)'
/

alter table vis_fin_message add (spend_qualified_ind  varchar2(1))
/
comment on column vis_fin_message.spend_qualified_ind is 'Spend Qualified Indicator.'
/

alter table vis_fin_message add (clearing_sequence_num  number(2))
/
alter table vis_fin_message add (clearing_sequence_count number(2))
/
comment on column vis_fin_message.clearing_sequence_num is 'Multiple Clearing Sequence Number '
/
comment on column vis_fin_message.clearing_sequence_count is 'Multiple Clearing Sequence Count'
/

alter table vis_fin_message add (service_code varchar2(3))
/
comment on column vis_fin_message.service_code is 'Service code '
/


alter table vis_fin_message add (business_format_code  varchar2(1))
/
alter table vis_fin_message add (token_assurance_level  varchar2(2))
/
alter table vis_fin_message add (pan_token  number(16))
/
comment on column vis_fin_message.business_format_code is 'Business Format Code'
/
comment on column vis_fin_message.token_assurance_level is 'Token Assurance Level '
/
comment on column vis_fin_message.pan_token IS 'PAN Token'
/
alter table vis_fin_message add validation_code  varchar2(4)
/
comment on column vis_fin_message.validation_code is 'A unique value that Visa Europe includes as part of the Custom Payment Service programs in each Authorization Response to ensure that key authorization fields are preserved in the Clearing Record'
/

alter table vis_fin_message add (payment_forms_num  varchar2(1))
/
comment on column vis_fin_message.payment_forms_num is 'Number of Payment Forms'
/

alter table vis_fin_message add business_format_code_e varchar2(2)
/
comment on column vis_fin_message.business_format_code is 'Business Format Code for TCR E'
/
alter table vis_fin_message add agent_unique_id  varchar2(5)
/
comment on column vis_fin_message.agent_unique_id is 'Agent Unique ID'
/
alter table vis_fin_message add additional_auth_method  varchar2(2)
/
comment on column vis_fin_message.additional_auth_method is 'Additional Authentication Method'
/
alter table vis_fin_message add additional_reason_code  varchar2(2)
/
comment on column vis_fin_message.additional_reason_code is 'Additional Authentication Reason Code'
/
alter table vis_fin_message add product_id varchar2(2)
/
comment on column vis_fin_message.product_id is 'Product ID'
/
alter table vis_fin_message add (auth_amount number(22,4), auth_currency varchar2(3))
/
comment on column vis_fin_message.auth_amount is 'Authorized Amount'
/
comment on column vis_fin_message.auth_currency is 'Authorization Currency Code'
/
alter table vis_fin_message add form_factor_indicator varchar2(8)
/
comment on column vis_fin_message.form_factor_indicator is 'Form Factor Indicator'
/

alter table vis_fin_message add fast_funds_indicator varchar2(1)
/
comment on column vis_fin_message.fast_funds_indicator is 'Fast Funds Indicator'
/
alter table vis_fin_message add business_format_code_3 varchar2(2)
/
comment on column vis_fin_message.business_format_code_3 is 'Business Format Code TCR3'
/
alter table vis_fin_message add business_application_id varchar2(2)
/
comment on column vis_fin_message.business_application_id is 'Business Application Identifier'
/
alter table vis_fin_message add source_of_funds varchar2(1)
/
comment on column vis_fin_message.source_of_funds is 'Source of Funds'
/
alter table vis_fin_message add payment_reversal_code varchar2(2)
/
comment on column vis_fin_message.payment_reversal_code is 'Payment Reversal Code'
/
alter table vis_fin_message add sender_reference_number varchar2(16)
/
comment on column vis_fin_message.sender_reference_number is 'Sender Reference Number'
/
alter table vis_fin_message add sender_account_number varchar2(34)
/
comment on column vis_fin_message.sender_account_number is 'Sender Account Number'
/
alter table vis_fin_message add sender_name varchar2(30)
/
comment on column vis_fin_message.sender_name is 'Sender Name'
/
alter table vis_fin_message add sender_address varchar2(35)
/
comment on column vis_fin_message.sender_address is 'Sender Address'
/
alter table vis_fin_message add sender_city varchar2(25)
/
comment on column vis_fin_message.sender_city is 'Sender City'
/
alter table vis_fin_message add sender_state varchar2(2)
/
comment on column vis_fin_message.sender_state is 'Sender State'
/
alter table vis_fin_message add sender_country varchar2(3)
/
comment on column vis_fin_message.sender_country is 'Sender Country'
/

alter table vis_fin_message add (network_code  varchar2(4))
/
comment on column vis_fin_message.network_code is 'Network Identification Code (0002 - Visa,  0004 - Plus, 0006 - MasterCard, 0040 - American Express, 0043 - Diner''s Club )'
/
alter table vis_fin_message modify (rrn varchar2(36 char))
/

begin
  for rec in (select 1 from dual where not exists(
      select 1 from user_tab_cols
      where table_name = upper('vis_fin_message')
            and column_name = upper('is_rejected')) )
  loop
    execute immediate 'alter table vis_fin_message add (is_rejected number (1))';
  end loop;
end;
/

comment on column vis_fin_message.is_rejected is 'Rejected message flag.'
/
alter table vis_fin_message add program_id varchar2(6)
/
comment on column vis_fin_message.program_id is 'Program identifier'
/
alter table vis_fin_message add dcc_indicator varchar2(1)
/
comment on column vis_fin_message.dcc_indicator is 'DCC has been performed. (1 = DCC performed, 0 = no DCC has been performed)'
/
alter table vis_fin_message add terminal_country varchar2(3)
/
comment on column vis_fin_message.terminal_country is 'Terminal country from tcr7'
/
begin
  for rec in (select 1 from dual where not exists(
      select 1 from user_tab_cols
      where table_name = upper('vis_fin_message')
            and column_name = upper('fee_interchange_amount')) )
  loop
    execute immediate 'alter table vis_fin_message add (fee_interchange_amount number (22,4))';
  end loop;
end;
/

comment on column vis_fin_message.fee_interchange_amount is 'Amount of interchange fee'
/

begin
  for rec in (select 1 from dual where not exists(
      select 1 from user_tab_cols
      where table_name = upper('vis_fin_message')
            and column_name = upper('fee_interchange_sign')) )
  loop
    execute immediate 'alter table vis_fin_message add (fee_interchange_sign number (1))';
  end loop;
end;
/

comment on column vis_fin_message.fee_interchange_sign is 'Sign of interchange fee. (1 = credit, -1 = debit)'
/

alter table vis_fin_message add recipient_name varchar2(30)
/
comment on column vis_fin_message.recipient_name is 'Name of recipient'
/
comment on column vis_fin_message.dcc_indicator is 'DCC has been performed. ("1" = DCC performed, " " = no DCC has been performed)'
/

alter table vis_fin_message add terminal_trans_date date
/
comment on column vis_fin_message.terminal_trans_date is 'Terminal Transaction Date (TC 6 TCR 7)'
/
alter table vis_fin_message add conv_date varchar2(4)
/
comment on column vis_fin_message.conv_date is 'Conversion Date in format "yddd"'
/
comment on column vis_fin_message.interface_trace_num is 'The field is obsolete'
/
