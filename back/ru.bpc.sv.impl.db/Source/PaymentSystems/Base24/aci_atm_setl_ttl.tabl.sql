create table aci_atm_setl_ttl (
    id                          number(16)
    , part_key                  as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
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
    , setl_ttl_admin_dat        varchar2(6)
    , setl_ttl_admin_tim        varchar2(8)
    , setl_ttl_admin_cde        varchar2(2)
    , setl_ttl_term_db          varchar2(12)
    , setl_ttl_term_cr          varchar2(12)
    , setl_ttl_on_us_db         varchar2(12)
    , setl_ttl_on_us_cr         varchar2(12)
    , setl_ttl_crncy_cde        varchar2(3)
    , setl_ttl_tim_ofst         varchar2(5)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition aci_atm_setl_ttl_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table aci_atm_setl_ttl is 'ATM terminal settlement records'
/

comment on column aci_atm_setl_ttl.id is 'Primary key. Contain same value as in corresponding record in OPR_OPERATION table.'
/
comment on column aci_atm_setl_ttl.file_id is 'Reference to file.'
/
comment on column aci_atm_setl_ttl.setl_ttl_admin_dat is 'The date (YYMMDD) the administrative transaction occurred.'
/
comment on column aci_atm_setl_ttl.setl_ttl_admin_tim is 'The time (HHMMSSTT) the administrative transaction occurred.'
/
comment on column aci_atm_setl_ttl.setl_ttl_admin_cde is 'An indicator used to determine the type of settlement transaction and originator of the transaction.'
/
comment on column aci_atm_setl_ttl.setl_ttl_term_db is 'The unverified amount of terminal debits since the terminal was last balanced.'
/
comment on column aci_atm_setl_ttl.setl_ttl_term_cr is 'The total amount of terminal credits since the terminal was last balanced.'
/
comment on column aci_atm_setl_ttl.setl_ttl_on_us_db is 'The total amount of on-us debits since the terminal was last balanced.'
/
comment on column aci_atm_setl_ttl.setl_ttl_on_us_cr is 'The total amount of on-us credits since the terminal was last balanced.'
/
comment on column aci_atm_setl_ttl.setl_ttl_crncy_cde is 'A code indicating the type of currency used during settlement.'
/
comment on column aci_atm_setl_ttl.setl_ttl_tim_ofst is 'The time difference (plus or minus in minutes) between the terminal location and the Tandem processor location.'
/
comment on column aci_atm_setl_ttl.headx_dat_tim is 'The date and time the record was logged.'
/
comment on column aci_atm_setl_ttl.headx_rec_typ is 'The type of TLF record logged.'
/
comment on column aci_atm_setl_ttl.headx_auth_ppd is 'The PPD name of the Authorization process that logged the record to the TLF.'
/
comment on column aci_atm_setl_ttl.headx_term_ln is 'The logical network associated with the terminal.'
/
comment on column aci_atm_setl_ttl.headx_term_fiid is 'The FIID of the financial institution owning the terminal.'
/
comment on column aci_atm_setl_ttl.headx_term_term_id is 'The terminal ID of the terminal originating the transaction.'
/
comment on column aci_atm_setl_ttl.headx_crd_ln is 'The logical network associated with the card issuer.'
/
comment on column aci_atm_setl_ttl.headx_crd_fiid is 'The FIID of the card issuer.'
/
comment on column aci_atm_setl_ttl.headx_crd_pan is 'The cardholder''s Primary Account Number (PAN) for card initiated transactions.'
/
comment on column aci_atm_setl_ttl.headx_crd_mbr_num is 'The member number associated with the cardholder''s account number.'
/
comment on column aci_atm_setl_ttl.headx_branch_id is 'The branch ID associated with the terminal originating the transaction.'
/
comment on column aci_atm_setl_ttl.headx_region_id is 'The region ID associated with the terminal originating the transaction.'
/
alter table aci_atm_setl_ttl add record_number number(16)
/
comment on column aci_atm_setl_ttl.record_number is 'Number of record in clearing file.'
/

