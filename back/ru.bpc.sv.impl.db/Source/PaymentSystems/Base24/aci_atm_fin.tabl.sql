create table aci_atm_fin (
    id                                 number(16)
    , file_id                          number(16)
    , headx_dat_tim                    varchar2(19)
    , headx_rec_typ                    varchar2(2)
    , headx_auth_ppd                   varchar2(4)
    , headx_term_ln                    varchar2(4)
    , headx_term_fiid                  varchar2(4)
    , headx_term_term_id               varchar2(16)
    , headx_crd_ln                     varchar2(4)
    , headx_crd_fiid                   varchar2(4)
    , headx_crd_pan                    varchar2(19)
    , headx_crd_mbr_num                varchar2(3)
    , headx_branch_id                  varchar2(4)
    , headx_region_id                  varchar2(4)
    , authx_type_cde                   varchar2(2)
    , authx_type                       varchar2(4)
    , authx_rte_stat                   varchar2(2)
    , authx_originator                 varchar2(1)
    , authx_responder                  varchar2(1)
    , authx_entry_time                 varchar2(19)
    , authx_exit_time                  varchar2(19)
    , authx_re_entry_tim               varchar2(19)
    , authx_tran_date                  varchar2(6)
    , authx_tran_time                  varchar2(8)
    , authx_post_date                  varchar2(6)
    , authx_acq_ichg_setl_date         varchar2(6)
    , authx_iss_ichg_setl_date         varchar2(6)
    , authx_seq_num                    varchar2(12)
    , authx_term_typ                   varchar2(2)
    , authx_tim_ofst                   varchar2(5)
    , authx_acq_inst_id                varchar2(11)
    , authx_rcv_inst_id                varchar2(11)
    , authx_tran_cde                   varchar2(6)
    , authx_from_acct                  varchar2(19)
    , authx_to_acct                    varchar2(19)
    , authx_mult_acct                  varchar2(1)
    , authx_amt_1                      varchar2(19)
    , authx_amt_2                      varchar2(19)
    , authx_amt_3                      varchar2(19)
    , authx_dep_bal_cr                 varchar2(10)
    , authx_dep_typ                    varchar2(1)
    , authx_resp_cde                   varchar2(3)
    , authx_term_name_loc              varchar2(25)
    , authx_term_owner_name            varchar2(22)
    , authx_term_city                  varchar2(13)
    , authx_term_st                    varchar2(3)
    , authx_term_cntry                 varchar2(2)
    , authx_orig_oseq_num              varchar2(12)
    , authx_orig_otran_dat             varchar2(4)
    , authx_orig_otran_tim             varchar2(8)
    , authx_orig_b24_post_dat          varchar2(4)
    , authx_orig_crncy_cde             varchar2(3)
    , authx_mult_crncy_auth_crncy_cd  varchar2(3)
    , authx_mult_crncy_auth_conv_rat  varchar2(8)
    , authx_mult_crncy_setl_crncy_cd  varchar2(3)
    , authx_mult_crncy_setl_conv_rat  varchar2(8)
    , authx_mult_crncy_conv_dat_tim    varchar2(19)
    , authx_rvsl_rsn                   varchar2(2)
    , authx_pin_ofst                   varchar2(16)
    , authx_shrg_grp                   varchar2(1)
    , authx_dest_order                 varchar2(1)
    , authx_auth_id_resp               varchar2(6)
    , authx_refr_imp_ind               varchar2(2)
    , authx_refr_avail_imp             varchar2(2)
    , authx_refr_ledg_imp              varchar2(2)
    , authx_refr_hld_amt_imp           varchar2(2)
    , authx_refr_caf_refr_ind          varchar2(1)
    , authx_dep_setl_imp_flg           varchar2(1)
    , authx_adj_setl_imp_flg           varchar2(1)
    , authx_refr_ind                   varchar2(4)
    , authx_frwd_inst_id_num           varchar2(11)
    , authx_crd_accpt_id_num           varchar2(11)
    , authx_crd_iss_id_num             varchar2(11)
)
/
comment on table aci_atm_fin is 'ATM financial transaction records'
/
comment on column aci_atm_fin.id is 'Primary key. Contain same value as in corresponding record in OPR_OPERATION table.'
/
comment on column aci_atm_fin.file_id is 'Reference to file.'
/
comment on column aci_atm_fin.headx_dat_tim is 'The date and time the record was logged.'
/
comment on column aci_atm_fin.headx_rec_typ is 'The type of TLF record logged.'
/
comment on column aci_atm_fin.headx_auth_ppd is 'The PPD name of the Authorization process that logged the record to the TLF.'
/
comment on column aci_atm_fin.headx_term_ln is 'The logical network associated with the terminal.'
/
comment on column aci_atm_fin.headx_term_fiid is 'The FIID of the financial institution owning the terminal.'
/
comment on column aci_atm_fin.headx_term_term_id is 'The terminal ID of the terminal originating the transaction.'
/
comment on column aci_atm_fin.headx_crd_ln is 'The logical network associated with the card issuer.'
/
comment on column aci_atm_fin.headx_crd_fiid is 'The FIID of the card issuer.'
/
comment on column aci_atm_fin.headx_crd_pan is 'The cardholder''s Primary Account Number (PAN) for card initiated transactions.'
/
comment on column aci_atm_fin.headx_crd_mbr_num is 'The member number associated with the cardholder''s account number.'
/
comment on column aci_atm_fin.headx_branch_id is 'The branch ID associated with the terminal originating the transaction.'
/
comment on column aci_atm_fin.headx_region_id is 'The region ID associated with the terminal originating the transaction.'
/
comment on column aci_atm_fin.authx_type_cde is 'A code used to determine whether an envelope or a check was involved in the transaction.'
/
comment on column aci_atm_fin.authx_type is 'The type of message associated with this record.'
/
comment on column aci_atm_fin.authx_rte_stat is 'A code used to determine the status of a message at the system level.'
/
comment on column aci_atm_fin.authx_originator is 'An indicator identifying where the transaction originated.'
/
comment on column aci_atm_fin.authx_responder is 'An indicator identifying where the response message'
/
comment on column aci_atm_fin.authx_entry_time is 'The time the transaction entered the BASE24 system.'
/
comment on column aci_atm_fin.authx_exit_time is 'The time the Host Interface or Interchange Interface transmitted the request to the authorizing entity.'
/
comment on column aci_atm_fin.authx_re_entry_tim is 'The time the Host Interface or Interchange Interface received a response to its original request from the authorizing entity.'
/
comment on column aci_atm_fin.authx_tran_date is 'The date (YYMMDD) on which the transaction began.'
/
comment on column aci_atm_fin.authx_tran_time is 'The time (HHMMSSHH) the transaction entered the BASE24 system from a device, interchange, or acquirer host.'
/
comment on column aci_atm_fin.authx_post_date is 'The date (YYMMDD) on which the transaction will be settled.'
/
comment on column aci_atm_fin.authx_acq_ichg_setl_date is 'The date (YYMMDD) this transaction will be settled by the interchange originating the transaction, if the transaction originates through an interchange.'
/
comment on column aci_atm_fin.authx_iss_ichg_setl_date is 'The date (YYMMDD) this transaction will be settled by the interchange authorizing the transaction, if an interchange was involved in processing.'
/
comment on column aci_atm_fin.authx_seq_num is 'The sequence number associated with this transaction.'
/
comment on column aci_atm_fin.authx_term_typ is 'The type of terminal at which this transaction initiated.'
/
comment on column aci_atm_fin.authx_tim_ofst is 'The time difference (plus or minus in minutes) between the terminal location and the Tandem processor location.'
/
comment on column aci_atm_fin.authx_acq_inst_id is 'The routing or transit number of the terminal owner.'
/
comment on column aci_atm_fin.authx_rcv_inst_id is 'The card-issuer routing or identification number.'
/
comment on column aci_atm_fin.authx_tran_cde is 'The values in the following fields define the transaction code.'
/
comment on column aci_atm_fin.authx_from_acct is 'The account number of the from account for the transaction. If the from account is not needed or known, this field contains zeros.'
/
comment on column aci_atm_fin.authx_to_acct is 'The account number of the to account of the transaction. If the to account is not needed or known, this field contains zeros.'
/
comment on column aci_atm_fin.authx_mult_acct is 'An indicator used to determine whether the transaction is a primary-account transaction, a multiple-account transaction, or a fast cash transaction. '
/
comment on column aci_atm_fin.authx_amt_1 is 'Amount 1 of the transaction'
/
comment on column aci_atm_fin.authx_amt_2 is 'Amount 2 of the transaction.'
/
comment on column aci_atm_fin.authx_amt_3 is 'Amount 3 of the transaction.'
/
comment on column aci_atm_fin.authx_dep_bal_cr is 'The amount of credit given on a deposit.'
/
comment on column aci_atm_fin.authx_dep_typ is 'An indicator used to determine the type of depository used at the terminal.'
/
comment on column aci_atm_fin.authx_resp_cde is 'The values in the following fields define the response code assigned by the transaction authorizer.'
/
comment on column aci_atm_fin.authx_term_name_loc is 'The terminal name and location of the terminal that acquired the transaction.'
/
comment on column aci_atm_fin.authx_term_owner_name is 'The name of the financial institution that owns the terminal that acquired the transaction.'
/
comment on column aci_atm_fin.authx_term_city is 'The city in which the terminal that acquired the transaction is located.'
/
comment on column aci_atm_fin.authx_term_st is 'The state in which the terminal that acquired the transaction is located.'
/
comment on column aci_atm_fin.authx_term_cntry is 'A code indicating the country in which the terminal that acquired the transaction is located.'
/
comment on column aci_atm_fin.authx_orig_oseq_num is 'The sequence number that identifies the original transaction.'
/
comment on column aci_atm_fin.authx_orig_otran_dat is 'The date of the original transaction.'
/
comment on column aci_atm_fin.authx_orig_otran_tim is 'The time of the original transaction.'
/
comment on column aci_atm_fin.authx_orig_b24_post_dat is 'The BASE24 posting date of the original transaction.'
/
comment on column aci_atm_fin.authx_orig_crncy_cde is 'The type of currency involved in the original transaction.'
/
comment on column aci_atm_fin.authx_mult_crncy_auth_crncy_cd is 'A code identifying the type of currency used in the authorization response.'
/
comment on column aci_atm_fin.authx_mult_crncy_auth_conv_rat is 'The exchange rate of the authorizing institution.'
/
comment on column aci_atm_fin.authx_mult_crncy_setl_crncy_cd is 'A code identifying the type of currency used by thesettlement entity.'
/
comment on column aci_atm_fin.authx_mult_crncy_setl_conv_rat is 'The exchange rate of the settlement entity. '
/
comment on column aci_atm_fin.authx_mult_crncy_conv_dat_tim is 'The day and time when the exchange rate was applied. The value in this field is generated via a call to Tandem''s JULIANTIMESTAMP utility.'
/
comment on column aci_atm_fin.authx_rvsl_rsn is 'An indicator used to identify the reason for a reversal (0420) or adjustment (5400) message type.'
/
comment on column aci_atm_fin.authx_pin_ofst is 'The PIN offset value for the PIN.'
/
comment on column aci_atm_fin.authx_shrg_grp is 'An indicator used to identify the sharing group used to allow the transaction, if it was a not-on-us transaction; otherwise, this field contains a zero.'
/
comment on column aci_atm_fin.authx_dest_order is 'An indicator used to determine which destination performed the final authorization.'
/
comment on column aci_atm_fin.authx_auth_id_resp is 'The host-generated transaction sequence number used for logging and extract purposes only.'
/
comment on column aci_atm_fin.authx_refr_imp_ind is 'An indicator used to determine whether this record should be considered when impacting a newly refreshed set of account records. '
/
comment on column aci_atm_fin.authx_refr_avail_imp is 'An indicator used to define how the value in the AVAIL-BAL field is impacted in the PBF account records. The first occurrence defines impacting on the from account and the second occurrence defines impacting on the to account.'
/
comment on column aci_atm_fin.authx_refr_ledg_imp is 'An indicator used to define how the value in the LEDG-BAL field is impacted in the PBF account records. The first occurrence defines impacting on the from account and the second occurrence defines impacting on the to account.'
/
comment on column aci_atm_fin.authx_refr_hld_amt_imp is 'An indicator used to define how the value in the AMT-ON-HLD field is impacted in the PBF account records.'
/
comment on column aci_atm_fin.authx_refr_caf_refr_ind is 'An indicator used to determine when transaction impacting can be terminated.'
/
comment on column aci_atm_fin.authx_dep_setl_imp_flg is 'An indicator identifying how deposits at an ATM impact settlement.'
/
comment on column aci_atm_fin.authx_adj_setl_imp_flg is 'An indicator used to determine whether adjustments impact settlement.'
/
comment on column aci_atm_fin.authx_refr_ind is 'An indicator used to determine when transaction impacting can be terminated.'
/
comment on column aci_atm_fin.authx_frwd_inst_id_num is 'An identification number used to identify the forwarding institution.'
/
comment on column aci_atm_fin.authx_crd_accpt_id_num is 'An identification number used to identify the card acceptor for a request message (0200) originating from an acquirer host.'
/
comment on column aci_atm_fin.authx_crd_iss_id_num is 'An identification number used to identify the card issuer for a response message (0210) originating from an authorizing host.'
/
comment on column aci_atm_fin.authx_resp_cde is 'The response code for the transaction.'
/
alter table aci_atm_fin add record_number number(16)
/
comment on column aci_atm_fin.record_number is 'Number of record in clearing file.'
/
