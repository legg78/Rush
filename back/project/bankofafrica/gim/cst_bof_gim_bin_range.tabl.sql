create table cst_bof_gim_bin_range
(
    id                  number(16)
  , issuer_bin          varchar2(10)
  , pan_low             varchar2(22)
  , pan_high            varchar2(22)
  , country             varchar2(3)
  , region              varchar2(2)
  , bin_type            varchar2(10)
)
/

comment on table cst_bof_gim_bin_range is 'GIM Account Range Table. This Table contains the list of valid GIM BINs and account range details. The content of this table is replaced as new GIM BIN report comes from GIM.'
/

comment on column cst_bof_gim_bin_range.id is 'IDENTIFIER.'
/
comment on column cst_bof_gim_bin_range.issuer_bin is 'BIN EMISSION.'
/
comment on column cst_bof_gim_bin_range.pan_low is 'TRANCHE DEBUT.'
/
comment on column cst_bof_gim_bin_range.pan_high is 'TRANCHE FIN.'
/
comment on column cst_bof_gim_bin_range.country is 'CODE PAYS.'
/
comment on column cst_bof_gim_bin_range.region is 'CODE REGION NUMBER.'
/
comment on column cst_bof_gim_bin_range.bin_type is 'TYPE BIN.'
/
