create table cst_cab_acc_mig(
    cif             varchar2(16)
  , cardholder_no   varchar2(16)
  , line_lmt        varchar2(25)
  , sv_acc          varchar2(25)
  , dpp_acc         varchar2(25)
  , autopay_acc     varchar2(25)
)
/
comment on table cst_cab_acc_mig is 'This table contains the migration cards and accounts from CBS'
/
comment on column cst_cab_acc_mig.cif is 'Customer CIF in CBS'
/
comment on column cst_cab_acc_mig.cardholder_no is 'Cardholder number'
/
comment on column cst_cab_acc_mig.line_lmt is 'Line limit value'
/
comment on column cst_cab_acc_mig.sv_acc is 'Credit account number in SV'
/
comment on column cst_cab_acc_mig.dpp_acc is 'DPP account number in SV'
/
comment on column cst_cab_acc_mig.autopay_acc is 'Autopay account number in CBS'
/
