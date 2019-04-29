create table cst_woo_import_f77(
    seq_id                      varchar2(10)
    , bank_code                 varchar2(10)
    , cif_no                    varchar2(10)
    , cus_eng_name              varchar2(30)
    , first_name                varchar2(30)
    , second_name               varchar2(30)
    , surname                   varchar2(30)
    , cus_local_name            varchar2(100)
    , nationality               varchar2(10)
    , id_type                   varchar2(10)
    , id_num                    varchar2(30)
    , birth_date                varchar2(8)
    , gender                    varchar2(1)
    , residence_type            varchar2(10)
    , job_code                  varchar2(10)
    , country_code              varchar2(10)
    , region                    varchar2(30)
    , city                      varchar2(30)
    , street                    varchar2(100)
    , home_phone                varchar2(30)
    , mobile_phone              varchar2(30)
    , email                     varchar2(30)
    , fax_num                   varchar2(30)
    , company_name              varchar2(400)
    , job_class_code            varchar2(10)
    , pos_class_code            varchar2(10)
    , company_phone             varchar2(30)
    , company_addr_country      varchar2(30)
    , company_addr_region       varchar2(30)
    , company_addr_city         varchar2(50)
    , company_addr_street       varchar2(30)
    , cus_rate_code             varchar2(10)   
    , employee_num              varchar2(10)
    , retirement_code           varchar2(10)
    , retirement_date           varchar2(8)
    , import_date               date
    , file_name                 varchar2(100)
)
/
comment on table cst_woo_import_f77 is 'Customer information'
/
comment on column cst_woo_import_f77.bank_code               is 'BANK CODE'
/
comment on column cst_woo_import_f77.cif_no                  is 'CIF no  '
/
comment on column cst_woo_import_f77.cus_eng_name            is 'Customer English name'
/
comment on column cst_woo_import_f77.first_name              is 'firstName'
/
comment on column cst_woo_import_f77.second_name             is 'secondName  '
/
comment on column cst_woo_import_f77.surname                 is 'surname '
/
comment on column cst_woo_import_f77.cus_local_name          is 'Customers local name '
/
comment on column cst_woo_import_f77.nationality             is 'nationality '
/
comment on column cst_woo_import_f77.id_type                 is 'idType  '
/
comment on column cst_woo_import_f77.id_num                  is 'idNumber '
/
comment on column cst_woo_import_f77.birth_date              is 'Date of birth'
/
comment on column cst_woo_import_f77.gender                  is 'Gender classification code  '
/
comment on column cst_woo_import_f77.residence_type          is 'Housing type identification code '
/
comment on column cst_woo_import_f77.job_code                is 'Job code '
/
comment on column cst_woo_import_f77.country_code            is 'Country code of residence'
/
comment on column cst_woo_import_f77.region                  is 'region  '
/
comment on column cst_woo_import_f77.city                    is 'city '
/
comment on column cst_woo_import_f77.street                  is 'streetName  '
/
comment on column cst_woo_import_f77.home_phone              is 'homePhone'
/
comment on column cst_woo_import_f77.mobile_phone            is 'mobilePhone '
/
comment on column cst_woo_import_f77.email                   is 'email'
/
comment on column cst_woo_import_f77.fax_num                 is 'faxNumber'
/
comment on column cst_woo_import_f77.company_name            is 'Company Name '
/
comment on column cst_woo_import_f77.job_class_code          is 'Job classification code '
/
comment on column cst_woo_import_f77.pos_class_code          is 'Position classification code '
/
comment on column cst_woo_import_f77.company_phone           is 'companyPhone '
/
comment on column cst_woo_import_f77.company_addr_country    is 'companyAddrCountry  '
/
comment on column cst_woo_import_f77.company_addr_region     is 'companyAddrRegion'
/
comment on column cst_woo_import_f77.company_addr_city       is 'companyAddrCity '
/
comment on column cst_woo_import_f77.company_addr_street     is 'companyAddrStreet'
/
comment on column cst_woo_import_f77.cus_rate_code           is 'Customer Rating Classification Code '
/
comment on column cst_woo_import_f77.employee_num            is 'Employee Number '
/
comment on column cst_woo_import_f77.retirement_code         is 'Retirement code '
/
comment on column cst_woo_import_f77.retirement_date         is 'Retirement date '
/
alter table cst_woo_import_f77 modify cus_eng_name varchar2(200)
/
alter table cst_woo_import_f77 modify first_name varchar2(200)
/
alter table cst_woo_import_f77 modify second_name varchar2(200)
/
alter table cst_woo_import_f77 modify surname varchar2(200)
/
alter table cst_woo_import_f77 modify cus_local_name varchar2(200)
/
alter table cst_woo_import_f77 modify company_addr_street varchar2(200)
/
