create table cst_woo_import_cif(
    cif_number  varchar2(20)
  , cus_type    varchar2(1)
  , sav_acct    varchar2(30)
  , crd_acct    varchar2(30)
  , card_number varchar2(30)
  , is_used     varchar2(1)
)
/
comment on table cst_woo_import_cif is 'This table contains the customer CIF from CBS'
/
comment on column cst_woo_import_cif.cif_number is 'Customer CIF number from CBS'
/
comment on column cst_woo_import_cif.cus_type is 'Customer type. C: Corporation, I: Individual'
/
comment on column cst_woo_import_cif.sav_acct is 'Saving account'
/
comment on column cst_woo_import_cif.crd_acct is 'Credit account'
/
comment on column cst_woo_import_cif.card_number is 'Card number'
/
comment on column cst_woo_import_cif.is_used is 'Y: Yes, N: No'
/
