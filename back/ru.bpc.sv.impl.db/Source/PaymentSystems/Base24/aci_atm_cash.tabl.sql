create table aci_atm_cash (
    id                          number(16)
    , file_id                   number(16)
    , headx_dat_tim             varchar2(19)
    , headx_rec_typ             varchar2(2)
    , headx_auth_ppd            varchar2(4)
    , headx_term_ln             varchar2(4)
    , headx_term_fiid           varchar2(4)
    , headx_term_term_id        varchar2(16)
    , headx_crd_ln              varchar2(4)
    , headx_crd_fiid            varchar2(4)
    , headx_crd_pan             varchar2(19)
    , headx_crd_mbr_num         varchar2(3)
    , headx_branch_id           varchar2(4)
    , headx_region_id           varchar2(4)
    , term_cash_admin_dat       varchar2(6)
    , term_cash_admin_tim       varchar2(8)
    , term_cash_admin_cde       varchar2(2)
    , term_cash_hopr_num        varchar2(1)
    , term_cash_hopr_contents   varchar2(2)
    , term_cash_amt             varchar2(12)
    , term_cash_crncy_cde       varchar2(3)
    , term_cash_user_fld8       varchar2(1)
    , term_cash_tim_ofst        varchar2(5)
    , term_cash_cash_area       varchar2(21)
)
/
comment on table aci_atm_cash is 'ATM terminal cash adjustment records'
/
comment on column aci_atm_cash.id is 'Primary key. Contain same value as in corresponding record in OPR_OPERATION table.'
/
comment on column aci_atm_cash.file_id is 'Reference to file.'
/
comment on column aci_atm_cash.headx_dat_tim is 'The date and time the record was logged.'
/
comment on column aci_atm_cash.headx_rec_typ is 'The type of TLF record logged.'
/
comment on column aci_atm_cash.headx_auth_ppd is 'The PPD name of the Authorization process that logged the record to the TLF.'
/
comment on column aci_atm_cash.headx_term_ln is 'The logical network associated with the terminal.'
/
comment on column aci_atm_cash.headx_term_fiid is 'The FIID of the financial institution owning the terminal.'
/
comment on column aci_atm_cash.headx_term_term_id is 'The terminal ID of the terminal originating the transaction.'
/
comment on column aci_atm_cash.headx_crd_ln is 'The logical network associated with the card issuer.'
/
comment on column aci_atm_cash.headx_crd_fiid is 'The FIID of the card issuer.'
/
comment on column aci_atm_cash.headx_crd_pan is 'The cardholder''s Primary Account Number (PAN) for card initiated transactions.'
/
comment on column aci_atm_cash.headx_crd_mbr_num is 'The member number associated with the cardholder''s account number.'
/
comment on column aci_atm_cash.headx_branch_id is 'The branch ID associated with the terminal originating the transaction.'
/
comment on column aci_atm_cash.headx_region_id is 'The region ID associated with the terminal originating the transaction.'
/
comment on column aci_atm_cash.term_cash_admin_dat is 'The date (YYMMDD) the administrative transaction occurred.'
/
comment on column aci_atm_cash.term_cash_admin_tim is 'The time (HHMMSSTT) the administrative transaction occurred.'
/
comment on column aci_atm_cash.term_cash_admin_cde is 'A code indicating a transaction type that involves increases and decreases of currency.'
/
comment on column aci_atm_cash.term_cash_hopr_num is 'The number of the hopper being affected by the administrative transaction.'
/
comment on column aci_atm_cash.term_cash_hopr_contents is 'The contents contained in the hopper.'
/
comment on column aci_atm_cash.term_cash_amt is 'The amount of increase or decrease to the hopper because of the administrative transaction.'
/
comment on column aci_atm_cash.term_cash_crncy_cde is 'A code identifying the type of currency used for the administrative transaction.'
/
comment on column aci_atm_cash.term_cash_tim_ofst is 'The time difference (plus or minus in minutes) between the terminal location and the Tandem processor location.'
/

alter table aci_atm_cash add record_number number(16)
/
comment on column aci_atm_cash.record_number is 'Number of record in clearing file.'
/
