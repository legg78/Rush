create table aci_pos_fin (
    id                            number(16)
    , file_id                     number(16)
    , headx_dat_tim               varchar2(19)
    , headx_rec_typ               varchar2(2)
    , headx_crd_ln                varchar2(4)
    , headx_crd_fiid              varchar2(4)
    , headx_crd_card_crd_num      varchar2(19)
    , headx_crd_card_mbr_num      varchar2(3)
    , headx_retl_ky_ln            varchar2(4)
    , headx_retl_ky_rdfkey_fiid   varchar2(4)
    , headx_retl_ky_rdfkey_grp    varchar2(4)
    , headx_retl_ky_rdfkey_regn   varchar2(4)
    , headx_retl_ky_rdfkey_id     varchar2(19)
    , headx_retl_term_id          varchar2(16)
    , headx_retl_shift_num        varchar2(3)
    , headx_retl_batch_num        varchar2(3)
    , headx_term_ln               varchar2(4)
    , headx_term_fiid             varchar2(4)
    , headx_term_term_id          varchar2(16)
    , headx_term_tim              varchar2(8)
    , headx_tkey_term_id          varchar2(16)
    , headx_tkey_rkey_rec_frmt    varchar2(1)
    , headx_tkey_rkey_retailer_id varchar2(19)
    , headx_tkey_rkey_clerk_id    varchar2(6)
    , headx_data_flag             varchar2(1)
    , authx_typ                   varchar2(4)
    , authx_rte_stat              varchar2(2)
    , authx_originator            varchar2(1)
    , authx_responder             varchar2(1)
    , authx_iss_cde               varchar2(2)
    , authx_entry_tim             varchar2(19)
    , authx_exit_tim              varchar2(19)
    , authx_re_entry_tim          varchar2(19)
    , authx_tran_dat              varchar2(6)
    , authx_tran_tim              varchar2(8)
    , authx_post_dat              varchar2(6)
    , authx_acq_ichg_setl_dat     varchar2(6)
    , authx_iss_ichg_setl_dat     varchar2(6)
    , authx_seq_num               varchar2(12)
    , authx_term_name_loc         varchar2(25)
    , authx_term_owner_name       varchar2(22)
    , authx_term_city             varchar2(13) 
    , authx_term_st               varchar2(3)
    , authx_term_cntry_cde        varchar2(2)
    , authx_brch_id               varchar2(4)
    , authx_term_tim_ofst         varchar2(5)
    , authx_acq_inst_id_num       varchar2(11)
    , authx_rcv_inst_id_num       varchar2(11)
    , authx_term_typ              varchar2(2)
    , authx_clerk_id              varchar2(6)
    , authx_crt_auth_grp          varchar2(4)
    , authx_crt_auth_user_id      varchar2(8)
    , authx_retl_sic_cde          varchar2(4)
    , authx_orig                  varchar2(4)
    , authx_dest                  varchar2(4)
    , authx_tran_cde_tc           varchar2(2)
    , authx_tran_cde_t            varchar2(1)
    , authx_tran_cde_aa           varchar2(2)
    , authx_tran_cde_c            varchar2(1)
    , authx_crd_typ               varchar2(2)
    , authx_acct                  varchar2(19)
    , authx_resp_cde              varchar2(3)
    , authx_amt_1                 varchar2(19)
    , authx_amt_2                 varchar2(19)
    , authx_exp_dat               varchar2(4)
    , authx_track2                varchar2(40)
    , authx_pin_ofst              varchar2(16)
    , authx_pre_auth_seq_num      varchar2(12)
    , authx_invoice_num           varchar2(10)
    , authx_orig_invoice_num      varchar2(10)
    , authx_authorizer            varchar2(16)
    , authx_auth_ind              varchar2(1)
    , authx_shift_num             varchar2(3)
    , authx_batch_seq_num         varchar2(3)
    , authx_apprv_cde             varchar2(8)
    , authx_apprv_cde_lgth        varchar2(1)
    , authx_ichg_resp             varchar2(8)
    , authx_pseudo_term_id        varchar2(4)
    , authx_rfrl_phone            varchar2(20)
    , authx_dft_capture_flg       varchar2(1)
    , authx_setl_flag             varchar2(1)
    , authx_rvrl_cde              varchar2(2)
    , authx_rea_for_chrgbck       varchar2(2)
    , authx_num_of_chrgbck        varchar2(1)
    , authx_pt_srv_cond_cde       varchar2(2)
    , authx_pt_srv_entry_mde      varchar2(3)
    , authx_auth_ind2             varchar2(1)
    , authx_orig_crncy_cde        varchar2(3)
    , authx_mult_crncy_auth_crncy_cd  varchar2(3)
    , authx_mult_crncy_auth_conv_rat  varchar2(8)
    , authx_mult_crncy_setl_crncy_cd  varchar2(3)
    , authx_mult_crncy_setl_conv_rat  varchar2(8)
    , authx_mult_crncy_conv_dat_tim   varchar2(19)
    , authx_refr_imp_ind          varchar2(1)
    , authx_refr_avail_bal        varchar2(1)
    , authx_refr_ledg_bal         varchar2(1)
    , authx_refr_amt_on_hold      varchar2(1)
    , authx_refr_ttl_float        varchar2(1)
    , authx_refr_cur_float        varchar2(1)
    , authx_adj_setl_impact_flg   varchar2(1)
    , authx_refr_ind              varchar2(4)
    , authx_frwd_inst_id_num      varchar2(11)
    , authx_crd_accpt_id_num      varchar2(11)
    , authx_crd_iss_id_num        varchar2(11)
    , authx_orig_msg_typ          varchar2(4)
    , authx_orig_tran_tim         varchar2(8)
    , authx_orig_tran_dat         varchar2(4)
    , authx_orig_seq_num          varchar2(12)
    , authx_orig_b24_post_dat     varchar2(4)
    , authx_excp_rsn_cde          varchar2(3)
    , authx_ovrrde_flg            varchar2(1)
    , authx_addr                  varchar2(20)
    , authx_zip_cde               varchar2(9)
    , authx_addr_vrfy_stat        varchar2(1)
    , authx_pin_ind               varchar2(1)
    , authx_pin_tries             varchar2(1)
    , authx_pre_auth_ts_dat       varchar2(6)
    , authx_pre_auth_ts_tim       varchar2(8)
    , authx_pre_auth_hlds_lvl     varchar2(1)
)
/
comment on table aci_pos_fin is 'ATM terminal settlement records'
/
comment on column aci_pos_fin.id is 'Primary key. Contain same value as in corresponding record in OPR_OPERATION table.'
/
comment on column aci_pos_fin.file_id is 'Reference to file.'
/
comment on column aci_pos_fin.headx_dat_tim is 'The date and time the record was logged. The value in this field is generated via a call to Tandem``s JULIANTIMESTAMP utility.'
/
comment on column aci_pos_fin.headx_rec_typ is 'A code indicating the type of record.'
/
comment on column aci_pos_fin.headx_crd_ln is 'The logical network with which the institution that issued the card is associated.'
/
comment on column aci_pos_fin.headx_crd_fiid is 'The FIID of the institution that issued the card.'
/
comment on column aci_pos_fin.headx_crd_card_crd_num is 'The card number identifying the card used in the transaction.'
/
comment on column aci_pos_fin.headx_crd_card_mbr_num is 'The member number associated with the card used in the transaction.'
/
comment on column aci_pos_fin.headx_retl_ky_ln is 'The logical network with which the retailer is associated.'
/
comment on column aci_pos_fin.headx_retl_ky_rdfkey_fiid is 'The FIID of the institution with which the retailer is associated.'
/
comment on column aci_pos_fin.headx_retl_ky_rdfkey_grp is 'The group to which the retailer belongs.'
/
comment on column aci_pos_fin.headx_retl_ky_rdfkey_regn is 'The retailer region group to which the retailer belongs.'
/
comment on column aci_pos_fin.headx_retl_ky_rdfkey_id is 'The retailer ID identifying the retailer.'
/
comment on column aci_pos_fin.headx_retl_term_id is 'The terminal ID of the terminal at which the transaction occurred.'
/
comment on column aci_pos_fin.headx_retl_shift_num is 'The shift number with which the transaction is associated.'
/
comment on column aci_pos_fin.headx_retl_batch_num is 'The batch number with which the transaction is associated.'
/
comment on column aci_pos_fin.headx_term_ln is 'The logical network with which the terminal is associated.'
/
comment on column aci_pos_fin.headx_term_fiid is 'The FIID of the institution with which the terminal is associated.'
/
comment on column aci_pos_fin.headx_term_term_id is 'The terminal ID of the terminal at which the transaction occurred.'
/
comment on column aci_pos_fin.headx_term_tim is 'The time the transaction occurred.'
/
comment on column aci_pos_fin.headx_tkey_term_id is 'The terminal ID of the terminal at which the transaction occurred.'
/
comment on column aci_pos_fin.headx_tkey_rkey_rec_frmt is 'A code indicating the type of information in this record.'
/
comment on column aci_pos_fin.headx_tkey_rkey_retailer_id is 'The retailer ID identifying the retailer.'
/
comment on column aci_pos_fin.headx_tkey_rkey_clerk_id is 'The clerk identification number.'
/
comment on column aci_pos_fin.headx_data_flag is 'Indicates whether the user-data field is appended to the PTLF record.'
/
comment on column aci_pos_fin.authx_typ is 'A code identifying the specific message type of this record.'
/
comment on column aci_pos_fin.authx_rte_stat is 'A code indicating the status of a message at the system level.'
/
comment on column aci_pos_fin.authx_originator is 'Indicates where the transaction originated.'
/
comment on column aci_pos_fin.authx_responder is 'Indicates where the response message to this transaction originated.'
/
comment on column aci_pos_fin.authx_iss_cde is 'An indicator used to determine the issuer of the transaction.'
/
comment on column aci_pos_fin.authx_entry_tim is 'The time at which the transaction entered into the BASE24 system.'
/
comment on column aci_pos_fin.authx_exit_tim is 'The time at which the Host Interface or Interchange Interface transmitted the authorization request to the authorizing entity.'
/
comment on column aci_pos_fin.authx_re_entry_tim is 'The time at which the Host Interface or Interchange Interface received a response to its original request from the authorizing entity.'
/
comment on column aci_pos_fin.authx_tran_dat is 'The date (YYMMDD) the transaction began.'
/
comment on column aci_pos_fin.authx_tran_tim is 'The time (HHMMSSTT) the transaction began.'
/
comment on column aci_pos_fin.authx_post_dat is 'The date (YYMMDD) the transaction is to be posted by BASE24.'
/
comment on column aci_pos_fin.authx_acq_ichg_setl_dat is 'The date (YYMMDD) the transaction is to be settled by the acquirer interchange, if an interchange is involved in processing this transaction. Otherwise, this field is zero-filled.'
/
comment on column aci_pos_fin.authx_iss_ichg_setl_dat is 'The date (YYMMDD) the transaction is to be settled by the issuer interchange, if an interchange is involved in processing this transaction. Otherwise, this field is zero-filled.'
/
comment on column aci_pos_fin.authx_seq_num is 'The transaction sequence number generated by the terminal or the Device Handler.'
/
comment on column aci_pos_fin.authx_term_name_loc is 'The terminal name and location as defined in the PTDF.'
/
comment on column aci_pos_fin.authx_term_owner_name is 'The name of the financial institution that owns the terminal, as defined in the PTDF.'
/
comment on column aci_pos_fin.authx_term_city is 'The city in which the terminal is located.'
/
comment on column aci_pos_fin.authx_term_st is 'The state in which the terminal is located.'
/
comment on column aci_pos_fin.authx_term_cntry_cde is 'A code indicating the country in which the terminal is located.'
/
comment on column aci_pos_fin.authx_brch_id is 'This field is not currently used.'
/
comment on column aci_pos_fin.authx_term_tim_ofst is 'The time difference between the terminal and the Tandem processor location.'
/
comment on column aci_pos_fin.authx_acq_inst_id_num is 'The route/transit number of the terminal owner as defined in the PTDF.'
/
comment on column aci_pos_fin.authx_rcv_inst_id_num is 'The route/transit number of the card issuer as defined in the Institution Definition File (IDF).'
/
comment on column aci_pos_fin.authx_term_typ is 'The terminal type as defined in the PTDF.'
/
comment on column aci_pos_fin.authx_clerk_id is 'The clerk ID, as defined in the PTDF, of the POS device operator who performed the transaction.'
/
comment on column aci_pos_fin.authx_crt_auth_grp is 'The PATHWAY operator group identification used for CRT Authorization.'
/
comment on column aci_pos_fin.authx_crt_auth_user_id is 'The PATHWAY operator user identification used for CRT Authorization.'
/
comment on column aci_pos_fin.authx_retl_sic_cde is 'The Standard Industrial Classification (SIC) code identifying the retailers line of business.'
/
comment on column aci_pos_fin.authx_orig is 'The originator of this transaction.'
/
comment on column aci_pos_fin.authx_dest is 'The destination of this transaction.'
/
comment on column aci_pos_fin.authx_tran_cde_tc is 'A code identifying the type of transaction.'
/
comment on column aci_pos_fin.authx_tran_cde_t is 'A code identifying the card type associated with the transaction.'
/
comment on column aci_pos_fin.authx_tran_cde_aa is 'A code identifying the type of account associated with the transaction.'
/
comment on column aci_pos_fin.authx_tran_cde_c is 'A code identifying the transaction category associated with the transaction.'
/
comment on column aci_pos_fin.authx_crd_typ is 'A code identifying the type of card used to initiate the transaction.'
/
comment on column aci_pos_fin.authx_acct is 'The account number of the affected account.'
/
comment on column aci_pos_fin.authx_resp_cde is 'The response code for the transaction.'
/
comment on column aci_pos_fin.authx_amt_1 is 'The transaction amount requested.'
/
comment on column aci_pos_fin.authx_amt_2 is 'The transaction amount 2.'
/
comment on column aci_pos_fin.authx_exp_dat is 'The expiration date (YYMM) of the card.'
/
comment on column aci_pos_fin.authx_track2 is 'The Track 2 information taken from the magnetic strip on the card or entered manually.'
/
comment on column aci_pos_fin.authx_pin_ofst is 'This field is currently not used.'
/
comment on column aci_pos_fin.authx_pre_auth_seq_num is 'The sequence number assigned to the preauthorization transaction.'
/
comment on column aci_pos_fin.authx_invoice_num is 'The transaction invoice number sent from the terminal, if used.'
/
comment on column aci_pos_fin.authx_orig_invoice_num is 'The invoice number of the original transaction sent from the terminal, if used.'
/
comment on column aci_pos_fin.authx_authorizer is 'The symbolic name of the authorizer of the transaction.'
/
comment on column aci_pos_fin.authx_auth_ind is 'A code indicating if the authorizer in the previous field'
/
comment on column aci_pos_fin.authx_shift_num is 'The number of the shift to which the transaction belongs.'
/
comment on column aci_pos_fin.authx_batch_seq_num is 'The batch sequence number for the transaction.'
/
comment on column aci_pos_fin.authx_apprv_cde is 'The approval code generated by the transaction authorizer.'
/
comment on column aci_pos_fin.authx_apprv_cde_lgth is 'The length of the approval code that the device can handle.'
/
comment on column aci_pos_fin.authx_ichg_resp is 'The interchange response'
/
comment on column aci_pos_fin.authx_pseudo_term_id is 'The pseudo identification associated with the terminal.'
/
comment on column aci_pos_fin.authx_rfrl_phone is 'The telephone number used for referral transactions.'
/
comment on column aci_pos_fin.authx_dft_capture_flg is 'A code indicating the action taken regarding the authorization and draft capture of this transaction.'
/
comment on column aci_pos_fin.authx_setl_flag is 'Indicates how the terminal is cut over if the terminal is directly-connected to BASE24.'
/
comment on column aci_pos_fin.authx_rvrl_cde is 'A code specifying the reason for reversal or adjustment transactions.'
/
comment on column aci_pos_fin.authx_rea_for_chrgbck is 'A code identifying the reason for the chargeback.'
/
comment on column aci_pos_fin.authx_num_of_chrgbck is 'The occurrence of the chargeback.'
/
comment on column aci_pos_fin.authx_pt_srv_cond_cde is 'A code identifying the transaction origin.'
/
comment on column aci_pos_fin.authx_pt_srv_entry_mde is 'A code indicating how the Primary Account Number (PAN) is entered into the system and the PIN entry capabilities when performing POS transactions.'
/
comment on column aci_pos_fin.authx_auth_ind2 is 'A code indicating if the authorizer in the AUTHORIZER field'
/
comment on column aci_pos_fin.authx_orig_crncy_cde is 'A code indicating the currency of the transaction.'
/
comment on column aci_pos_fin.authx_mult_crncy_auth_crncy_cd is 'A code indicating the type of currency used in the response from the authorizing entity.'
/
comment on column aci_pos_fin.authx_mult_crncy_auth_conv_rat is 'The exchange rate of the authorizing entity.'
/
comment on column aci_pos_fin.authx_mult_crncy_setl_crncy_cd is 'A code indicating the type of currency used in the settlement of the transaction.'
/
comment on column aci_pos_fin.authx_mult_crncy_setl_conv_rat is 'The exchange rate of the settlement entity.'
/
comment on column aci_pos_fin.authx_mult_crncy_conv_dat_tim is 'The time and day when the exchange rate was applied between the transaction amount and the currency of the database.'
/
comment on column aci_pos_fin.authx_refr_imp_ind is 'A code indicating whether this record should be considered when impacting a set of account records that has been refreshed.'
/
comment on column aci_pos_fin.authx_refr_avail_bal is 'A code indicating the manner in which this record impacts the amount in the AVAIL-BAL field in the PBF account records.'
/
comment on column aci_pos_fin.authx_refr_ledg_bal is 'A code indicating the manner in which this record impacts the amount in the LEDG-BAL field in the PBF account records.'
/
comment on column aci_pos_fin.authx_refr_amt_on_hold is 'A code indicating the manner in which this record impacts the amount in the AMT-ON-HOLD field in the PBF account records.'
/
comment on column aci_pos_fin.authx_refr_ttl_float is 'A code indicating the manner in which this record impacts the amount in the TOTAL FLOAT field in the PBF account records.'
/
comment on column aci_pos_fin.authx_refr_cur_float is 'A code indicating the manner in which this record impacts the amount in the CURRENT FLOAT field in the PBF account records.'
/
comment on column aci_pos_fin.authx_adj_setl_impact_flg is 'A code indicating whether adjustments impact settlement.'
/
comment on column aci_pos_fin.authx_refr_ind is 'An alphabetic indicator set by Authorization from the value a corresponding field in the IDF.'
/
comment on column aci_pos_fin.authx_frwd_inst_id_num is 'The identification of the forwarding institution for full fee accounting.'
/
comment on column aci_pos_fin.authx_crd_accpt_id_num is 'A code identifying the card acceptor on a 0200 transaction originating from an acquirer host.'
/
comment on column aci_pos_fin.authx_crd_iss_id_num is 'A code identifying the actual card issuer on a 0210 response from an authorizing host, if desired.'
/
comment on column aci_pos_fin.authx_orig_msg_typ is 'The original message type associated with the transaction.'
/
comment on column aci_pos_fin.authx_orig_tran_tim is 'The original time (HHMMSSTT) at which the transaction occurred.'
/
comment on column aci_pos_fin.authx_orig_tran_dat is 'The original date (MMDD) on which the transaction occurred.'
/
comment on column aci_pos_fin.authx_orig_seq_num is 'The original sequence number assigned to the transaction.'
/
comment on column aci_pos_fin.authx_orig_b24_post_dat is 'The original date (MMDD) on which the transaction posted to BASE24.'
/
comment on column aci_pos_fin.authx_excp_rsn_cde is 'A reason code indicating why the exception flag is set.'
/
comment on column aci_pos_fin.authx_ovrrde_flg is 'A code distinguishing between normal transactions and transactions handled through CRT Authorization.'
/
comment on column aci_pos_fin.authx_addr is 'The cardholder billing address received with the transaction when performing address verification.'
/
comment on column aci_pos_fin.authx_zip_cde is 'The cardholder billing ZIP code received with the transaction when performing address verification.'
/
comment on column aci_pos_fin.authx_addr_vrfy_stat is 'A code identifying the result of comparing address verification information received in the transaction and address verification information contained in the processors database.'
/
comment on column aci_pos_fin.authx_pin_ind is 'An indicator as to whether the PIN was present in the transaction.'
/
comment on column aci_pos_fin.authx_pin_tries is 'The number of PIN tries.'
/
comment on column aci_pos_fin.authx_pre_auth_ts_dat is 'The expiration date and time assigned to a pre-auth hold entry (yymmdd)'
/
comment on column aci_pos_fin.authx_pre_auth_ts_tim is 'The expiration date and time assigned to a pre-auth hold entry (hhmmsstt)'
/
comment on column aci_pos_fin.authx_pre_auth_hlds_lvl is 'A code identifying the file or files in which a pre-auth hold entry is stored.'
/
alter table aci_pos_fin drop column authx_tran_cde_tc
/
alter table aci_pos_fin drop column authx_tran_cde_t
/
alter table aci_pos_fin drop column authx_tran_cde_aa
/
alter table aci_pos_fin drop column authx_tran_cde_c
/
alter table aci_pos_fin add authx_tran_cde varchar2(6)
/
comment on column aci_pos_fin.authx_tran_cde is 'The values in the following fields identify the type of transaction in TCTAAC format.'
/
comment on column aci_pos_fin.authx_amt_2 is 'For adjustment transactions, this field contains the new amount.'
/
alter table aci_pos_fin add record_number number(16)
/
comment on column aci_pos_fin.record_number is 'Number of record in clearing file.'
/
