create table aci_atm_setl (
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
    , term_setl_admin_dat       varchar2(6)
    , term_setl_admin_tim       varchar2(8)
    , term_setl_admin_cde       varchar2(2)
    , term_setl_num_dep         varchar2(5)
    , term_setl_amt_dep         varchar2(19)
    , term_setl_num_cmrcl_dep   varchar2(5)
    , term_setl_amt_cmrcl_dep   varchar2(19)
    , term_setl_num_pay         varchar2(5)
    , term_setl_amt_pay         varchar2(19)
    , term_setl_num_msg         varchar2(5)
    , term_setl_num_chk         varchar2(5)
    , term_setl_amt_chk         varchar2(19)
    , term_setl_num_logonly     varchar2(5)
    , term_setl_ttl_env         varchar2(5)
    , term_setl_crds_ret        varchar2(5)
    , term_setl_setl_crncy_cde  varchar2(3)
    , term_setl_tim_ofst        varchar2(5)
)
/

comment on table aci_atm_setl is 'ATM terminal balancing records'
/

comment on column aci_atm_setl.id is 'Primary key. Contain same value as in corresponding record in OPR_OPERATION table.'
/
comment on column aci_atm_setl.file_id is 'Reference to file.'
/
comment on column aci_atm_setl.headx_dat_tim is 'The date and time the record was logged.'
/
comment on column aci_atm_setl.headx_rec_typ is 'The type of TLF record logged.'
/
comment on column aci_atm_setl.headx_auth_ppd is 'The PPD name of the Authorization process that logged the record to the TLF.'
/
comment on column aci_atm_setl.headx_term_ln is 'The logical network associated with the terminal.'
/
comment on column aci_atm_setl.headx_term_fiid is 'The FIID of the financial institution owning the terminal.'
/
comment on column aci_atm_setl.headx_term_term_id is 'The terminal ID of the terminal originating the transaction.'
/
comment on column aci_atm_setl.headx_crd_ln is 'The logical network associated with the card issuer.'
/
comment on column aci_atm_setl.headx_crd_fiid is 'The FIID of the card issuer.'
/
comment on column aci_atm_setl.headx_crd_pan is 'The cardholder''s Primary Account Number (PAN) for card initiated transactions.'
/
comment on column aci_atm_setl.headx_crd_mbr_num is 'The member number associated with the cardholder''s account number.'
/
comment on column aci_atm_setl.headx_branch_id is 'The branch ID associated with the terminal originating the transaction.'
/
comment on column aci_atm_setl.headx_region_id is 'The region ID associated with the terminal originating the transaction.'
/
comment on column aci_atm_setl.term_setl_admin_dat is 'The date (YYMMDD) the administrative transaction occurred.'
/
comment on column aci_atm_setl.term_setl_admin_tim is 'The time (HHMMSSTT) the administrative transaction occurred.'
/
comment on column aci_atm_setl.term_setl_admin_cde is 'An indicator used to determine how the terminal was cutover.'
/
comment on column aci_atm_setl.term_setl_num_dep is 'The number of envelope deposits accepted at the terminal since the last terminal balancing transaction.'
/
comment on column aci_atm_setl.term_setl_amt_dep is 'The unverified amount of the deposits accepted at the terminal since the last terminal balancing transaction.'
/
comment on column aci_atm_setl.term_setl_num_cmrcl_dep is 'The number of envelope deposits accepted in the commercial (e.g., Securomatic) depository since the last terminal balancing transaction.'
/
comment on column aci_atm_setl.term_setl_amt_cmrcl_dep is 'The unverified amount of the deposits accepted in the commercial (e.g., Securomatic) depository since the last terminal balancing transaction.'
/
comment on column aci_atm_setl.term_setl_num_pay is 'The number of envelope payments accepted at the terminal since the last terminal balancing transaction.'
/
comment on column aci_atm_setl.term_setl_amt_pay is 'The unverified amount of payments accepted at the terminal since the last terminal balancing transaction.'
/
comment on column aci_atm_setl.term_setl_num_msg is 'The number of messages-to-institution transaction envelopes accepted since the last terminal balancing transaction.'
/
comment on column aci_atm_setl.term_setl_num_chk is 'The total number of checks received (i.e. cashed or deposited) since the terminal was last balanced.'
/
comment on column aci_atm_setl.term_setl_amt_chk is 'The unverified total amount of checks received (i.e. cashed or deposited) since the terminal was last balanced.'
/
comment on column aci_atm_setl.term_setl_num_logonly is 'The number of log-only transactions performed since the last terminal balancing transaction.'
/
comment on column aci_atm_setl.term_setl_ttl_env is 'The estimated number of envelopes deposited at the terminal.'
/
comment on column aci_atm_setl.term_setl_crds_ret is 'The number of cards retained since the last terminal balancing transaction.'
/
comment on column aci_atm_setl.term_setl_setl_crncy_cde is 'A code indicating the type of currency used to represent the terminals amount fields (i.e., the nation that printed the currency).'
/
comment on column aci_atm_setl.term_setl_tim_ofst is 'The time difference (plus or minus in minutes) between the terminal location and the Tandem processor location.'
/

alter table aci_atm_setl add record_number number(16)
/
comment on column aci_atm_setl.record_number is 'Number of record in clearing file.'
/
