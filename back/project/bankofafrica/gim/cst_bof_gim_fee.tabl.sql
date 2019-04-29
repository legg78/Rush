create table cst_bof_gim_fee (
    id                  number(16)
  , file_id             number(16)
  , fee_type_ind           varchar2(1)
  , forw_inst_country_code varchar2(3)
  , reason_code            varchar2(4)
  , collection_branch_code varchar2(4)
  , trans_count            varchar2(8)
  , unit_fee               varchar2(9)
  , event_date             date
  , source_amount_cfa      number(22,4)
  , control_number         varchar2(14)
  , message_text           varchar2(100)
)
/

comment on table cst_bof_gim_fee is 'Financial Messages Table. This contains financial records TC 10, 20.'
/
comment on column cst_bof_gim_fee.id is 'Primary Key.'
/
comment on column cst_bof_gim_fee.file_id is 'Reference to clearing file.'
/
