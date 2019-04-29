create table cst_smt_msstrxn_map_tmp
(
  id                 number(16) not null,
  input_file_name    varchar2(100),
  original_file_name varchar2(100),
  load_date          date,
  card_number        varchar2(24),
  oper_amount        number(22,4),
  iss_auth_code      varchar2(6),
  host_date          date,
  external_auth_id   varchar2(30)
)
/
comment on table cst_smt_msstrxn_map_tmp is 'Table containe data of the msstrxn files for maping MNO operations'
/
comment on column cst_smt_msstrxn_map_tmp.id is 'ID'
/
comment on column cst_smt_msstrxn_map_tmp.input_file_name is 'Name of the input file'
/
comment on column cst_smt_msstrxn_map_tmp.original_file_name is 'Name of the original file which was be extracted'
/
comment on column cst_smt_msstrxn_map_tmp.load_date is 'Date of the loading'
/
comment on column cst_smt_msstrxn_map_tmp.card_number is 'Number of card'
/
comment on column cst_smt_msstrxn_map_tmp.oper_amount is 'Operation amount in operation currency'
/
comment on column cst_smt_msstrxn_map_tmp.iss_auth_code is 'Authorization code'
/
comment on column cst_smt_msstrxn_map_tmp.host_date is 'Source system date'
/
comment on column cst_smt_msstrxn_map_tmp.external_auth_id is 'External authorization identifier'
/
