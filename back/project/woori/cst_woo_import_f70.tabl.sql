create table cst_woo_import_f70(
    seq_id                      varchar2(10)
    , bank_code                 varchar2(10)
    , staff_num                 varchar2(10)
    , staff_name                varchar2(200)
    , branch_code               varchar2(10)
    , r_branch_code             varchar2(10)
    , gender                    varchar2(10)
    , eng_name                  varchar2(50)
    , chn_name                  varchar2(50)
    , cus_number                varchar2(10)
    , cus_iden_code             varchar2(10)
    , cus_iden_num              varchar2(100)
    , item_value_1              varchar2(10)
    , rank_level                varchar2(10)
    , salary_level              varchar2(10)
    , first_bank_date           varchar2(10)
    , move_depart_date          varchar2(10)
    , attend_depart_date        varchar2(10)
    , promote_date              varchar2(10)
    , nexn_promote_date         varchar2(10)
    , position_code             varchar2(10)
    , devision_code             varchar2(10)
    , birth_date                varchar2(10)
    , sal_acc_num               varchar2(20)
    , is_married                varchar2(10)
    , wed_anniver_date          varchar2(10)
    , phone_num                 varchar2(20)
    , address                   varchar2(500)
    , cell_phone_num            varchar2(20)
    , emer_contact_num          varchar2(20)
    , security_num              varchar2(20)
    , email                     varchar2(50)
    , internal_phone_num        varchar2(20)
    , is_retired                varchar2(10)
    , retire_code               varchar2(10)
    , retire_date               varchar2(10)
    , retire_reason             varchar2(100)
    , before_branch             varchar2(10)
    , item_value_2              varchar2(50)
    , item_value_3              varchar2(10)
    , item_value_4              varchar2(10)
    , import_date               date
    , file_name                 varchar2(100)
)
/
comment on table cst_woo_import_f70 is 'Customer information '
/
comment on column cst_woo_import_f70.bank_code is 'Bank code'
/
comment on column cst_woo_import_f70.staff_num is 'Staff number '
/
comment on column cst_woo_import_f70.staff_name is 'Staff name  '
/
comment on column cst_woo_import_f70.branch_code is 'branch code (Use when verifying staff information)  '
/
comment on column cst_woo_import_f70.r_branch_code is 'real belong brach code  '
/
comment on column cst_woo_import_f70.gender is 'F: Female, M: Male  '
/
comment on column cst_woo_import_f70.eng_name is 'English name '
/
comment on column cst_woo_import_f70.chn_name is 'Chinese name '
/
comment on column cst_woo_import_f70.cus_number is 'customer number '
/
comment on column cst_woo_import_f70.cus_iden_code is 'customer identification number  '
/
comment on column cst_woo_import_f70.cus_iden_num is 'customer identification number  '
/
comment on column cst_woo_import_f70.rank_level is 'corporate rank level name'
/
comment on column cst_woo_import_f70.salary_level is 'salary level name'
/
comment on column cst_woo_import_f70.first_bank_date is 'Date of bank first work '
/
comment on column cst_woo_import_f70.move_depart_date is 'Date of moving other department '
/
comment on column cst_woo_import_f70.attend_depart_date is 'Date of attendance other department '
/
comment on column cst_woo_import_f70.promote_date is 'Date of promotion'
/
comment on column cst_woo_import_f70.nexn_promote_date is 'Date of next promotion  '
/
comment on column cst_woo_import_f70.position_code is 'Position code'
/
comment on column cst_woo_import_f70.devision_code is 'Staff devision code '
/
comment on column cst_woo_import_f70.birth_date is 'Birthday '
/
comment on column cst_woo_import_f70.sal_acc_num is 'Salary account number'
/
comment on column cst_woo_import_f70.is_married is 'whether marry or not '
/
comment on column cst_woo_import_f70.wed_anniver_date is 'wedding anniversary date '
/
comment on column cst_woo_import_f70.phone_num is 'telephone number '
/
comment on column cst_woo_import_f70.address is 'staff address'
/
comment on column cst_woo_import_f70.cell_phone_num is 'Cell Phone Number'
/
comment on column cst_woo_import_f70.emer_contact_num is 'Emergency contact number '
/
comment on column cst_woo_import_f70.security_num is 'Social Security Number  '
/
comment on column cst_woo_import_f70.email is 'Staff email address '
/
comment on column cst_woo_import_f70.internal_phone_num is 'internal telephone number'
/
comment on column cst_woo_import_f70.is_retired is 'select one of 1: employment 2: retirement'
/
comment on column cst_woo_import_f70.retire_code is 'retirement devision code '
/
comment on column cst_woo_import_f70.retire_date is 'retirement date '
/
comment on column cst_woo_import_f70.retire_reason is 'retirement reason detail '
/
comment on column cst_woo_import_f70.before_branch is 'before working branch code  '
/
