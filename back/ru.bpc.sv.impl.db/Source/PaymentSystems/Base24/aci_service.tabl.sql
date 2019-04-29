create table aci_service (
    id                             number(16)
    , part_key                     as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , file_id                      number(16)
    , headx_dat_tim                varchar2(19)
    , headx_rec_typ                varchar2(2)
    , headx_crd_ln                 varchar2(4)
    , headx_crd_fiid               varchar2(4)
    , headx_crd_card_crd_num       varchar2(19)
    , headx_crd_card_mbr_num       varchar2(3)
    , headx_retl_ky_ln             varchar2(4)
    , headx_retl_ky_rdfkey_fiid    varchar2(4)
    , headx_retl_ky_rdfkey_grp     varchar2(4)
    , headx_retl_ky_rdfkey_regn    varchar2(4)
    , headx_retl_ky_rdfkey_id      varchar2(19)
    , headx_retl_term_id           varchar2(16)
    , headx_retl_shift_num         varchar2(3)
    , headx_retl_batch_num         varchar2(3)
    , headx_term_ln                varchar2(4)
    , headx_term_fiid              varchar2(4)
    , headx_term_term_id           varchar2(16)
    , headx_term_tim               varchar2(8)
    , headx_tkey_term_id           varchar2(16)
    , headx_tkey_rkey_rec_frmt     varchar2(1)
    , headx_tkey_rkey_retailer_id  varchar2(19)
    , headx_tkey_rkey_clerk_id     varchar2(6)
    , headx_data_flag              varchar2(1)
    , set_rec1d_typ                varchar2(4)
    , set_rec1d_post_dat           varchar2(6)
    , set_rec1d_prod_id            varchar2(2)
    , set_rec1d_rel_num            varchar2(2)
    , set_rec1d_dpc_num            varchar2(4)
    , set_rec1d_term_tim_ofst      varchar2(5)
    , set_rec1d_term_id            varchar2(16)
    , set_rec1d_retl_rttn          varchar2(11)
    , set_rec1d_retl_acct          varchar2(19)
    , set_rec1d_retl_nam           varchar2(40)
    , set_rec1d_setl_typ           varchar2(1)
    , set_rec1d_bal_flg            varchar2(1)
    , set_rec1d_tran_dat           varchar2(6)
    , set_rec1d_tran_tim           varchar2(6)
    , set_rec1d_ob_flg             varchar2(1)
    , set_rec1d_ach_comp_id        varchar2(10)
    , set_rec1d_billing_info       varchar2(10)
    , set_rec1d_auth_crncy_cde     varchar2(3)
    , set_rec1d_auth_conv_rate     varchar2(8)
    , set_rec1d_setl_crncy_cde     varchar2(3)
    , set_rec1d_setl_conv_rate     varchar2(8)
    , user_data_d_len              varchar2(4)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition aci_service_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))        -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table aci_service is 'Services supported by this terminal records'
/

comment on column aci_service.id is 'Primary key. Contain same value as in corresponding record in OPR_OPERATION table.'
/
comment on column aci_service.file_id is 'Reference to file.'
/
comment on column aci_service.headx_dat_tim is 'The date and time the record was logged. The value in this field is generated via a call to Tandem``s JULIANTIMESTAMP utility.'
/
comment on column aci_service.headx_rec_typ is 'A code indicating the type of record.'
/
comment on column aci_service.headx_crd_ln is 'The logical network with which the institution that issued the card is associated.'
/
comment on column aci_service.headx_crd_fiid is 'The FIID of the institution that issued the card.'
/
comment on column aci_service.headx_crd_card_crd_num is 'The card number identifying the card used in the transaction.'
/
comment on column aci_service.headx_crd_card_mbr_num is 'The member number associated with the card used in the transaction.'
/
comment on column aci_service.headx_retl_ky_ln is 'The logical network with which the retailer is associated.'
/
comment on column aci_service.headx_retl_ky_rdfkey_fiid is 'The FIID of the institution with which the retailer is associated.'
/
comment on column aci_service.headx_retl_ky_rdfkey_grp is 'The group to which the retailer belongs.'
/
comment on column aci_service.headx_retl_ky_rdfkey_regn is 'The retailer region group to which the retailer belongs.'
/
comment on column aci_service.headx_retl_ky_rdfkey_id is 'The retailer ID identifying the retailer.'
/
comment on column aci_service.headx_retl_term_id is 'The terminal ID of the terminal at which the transaction occurred.'
/
comment on column aci_service.headx_retl_shift_num is 'The shift number with which the transaction is associated.'
/
comment on column aci_service.headx_retl_batch_num is 'The batch number with which the transaction is associated.'
/
comment on column aci_service.headx_term_ln is 'The logical network with which the terminal is associated.'
/
comment on column aci_service.headx_term_fiid is 'The FIID of the institution with which the terminal is associated.'
/
comment on column aci_service.headx_term_term_id is 'The terminal ID of the terminal at which the transaction occurred.'
/
comment on column aci_service.headx_term_tim is 'The time the transaction occurred.'
/
comment on column aci_service.headx_tkey_term_id is 'The terminal ID of the terminal at which the transaction occurred.'
/
comment on column aci_service.headx_tkey_rkey_rec_frmt is 'A code indicating the type of information in this record.'
/
comment on column aci_service.headx_tkey_rkey_retailer_id is 'The retailer ID identifying the retailer.'
/
comment on column aci_service.headx_tkey_rkey_clerk_id is 'The clerk identification number.'
/
comment on column aci_service.headx_data_flag is 'Indicates whether the user-data field is appended to the PTLF record.'
/
comment on column aci_service.set_rec1d_typ is 'A code indicating the type of PTLF record.'
/
comment on column aci_service.set_rec1d_post_dat is 'The posting date (YYMMDD) for the settlement record.'
/
comment on column aci_service.set_rec1d_prod_id is 'A code identifying the BASE24 product.'
/
comment on column aci_service.set_rec1d_rel_num is 'A code identifying the current version of the product.'
/
comment on column aci_service.set_rec1d_dpc_num is 'The number of the institutions Data Processing Center (DPC).'
/
comment on column aci_service.set_rec1d_term_tim_ofst is 'The time difference between the terminal and the Tandem processor location.'
/
comment on column aci_service.set_rec1d_term_id is 'The terminal ID of the terminal on which the settlement occurred.'
/
comment on column aci_service.set_rec1d_retl_rttn is 'The institutions route and transit number, transit/routing number, or issuer identification number of the terminal owner.'
/
comment on column aci_service.set_rec1d_retl_acct is 'The account number at the retailers financial institution for the retailer associated with the settlement record.'
/
comment on column aci_service.set_rec1d_retl_nam is 'The name of the retailer associated with the settlement record.'
/
comment on column aci_service.set_rec1d_setl_typ is 'A code identifying the type of settlement record being displayed.'
/
comment on column aci_service.set_rec1d_bal_flg is 'A code identifying the method used to perform the most recent balancing of this terminal.'
/
comment on column aci_service.set_rec1d_tran_dat is 'The date (YYMMDD) of the transaction.'
/
comment on column aci_service.set_rec1d_tran_tim is 'The time (HHMMSS) of the transaction.'
/
comment on column aci_service.set_rec1d_ob_flg is 'A flag indicating whether this balancing record has an associated balancing record if a terminal is out-of-balance with BASE24-pos.'
/
comment on column aci_service.set_rec1d_ach_comp_id is 'This field is reserved for Automated Clearinghouse (ACH) information that may be required for processing transactions from this retailer.'
/
comment on column aci_service.set_rec1d_billing_info is 'A free-form informational field used at the discretion of the institution.'
/
comment on column aci_service.set_rec1d_auth_crncy_cde is 'A code indicating the type of currency used for the transactions pertaining to this terminal.'
/
comment on column aci_service.set_rec1d_auth_conv_rate is 'The exchange rate of the authorizing entity.'
/
comment on column aci_service.set_rec1d_setl_crncy_cde is 'A code indicating the type of currency used in the settlement of the transaction.'
/
comment on column aci_service.set_rec1d_setl_conv_rate is 'The exchange rate of the settlement entity.'
/
comment on column aci_service.user_data_d_len is 'User data information loaded from the PSTM for the transaction.'
/
alter table aci_service add record_number number(16)
/
comment on column aci_service.record_number is 'Number of record in clearing file.'
/
