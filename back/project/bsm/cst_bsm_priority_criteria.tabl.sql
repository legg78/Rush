create table cst_bsm_priority_criteria(
    application_id           number(16)
  , seqnum                   number(4)
  , total_customer_balance   number(22,4)
  , priority_flag            number(1)
  , product_count            number(4)
  , reissue_command          varchar2(8)
  , card_count               number(4)
  , priority_appl_count      number(4)
)
/

comment on table cst_bsm_priority_criteria is 'Priority product details'
/
comment on column cst_bsm_priority_criteria.application_id is 'Primary key.'
/
comment on column cst_bsm_priority_criteria.seqnum is 'Sequence number. Describes data version.'
/
comment on column cst_bsm_priority_criteria.total_customer_balance is 'Total customer Balance (from MIS table).'
/
comment on column cst_bsm_priority_criteria.priority_flag is 'Priority Flag (from MIS table).'
/
comment on column cst_bsm_priority_criteria.product_count is 'Count of different Products (product_code) (from MIS table).'
/
comment on column cst_bsm_priority_criteria.reissue_command is 'Reissue command (Dictionary RCMD).'
/
comment on column cst_bsm_priority_criteria.card_count is 'Count of Active Priority Card attached to the CIF (Customer number)'
/
comment on column cst_bsm_priority_criteria.priority_appl_count is 'Count of Active Priority Application attached to the CIF (Customer number)'
/
