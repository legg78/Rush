create table cst_ibbl_acc_checkbook(
    id                      number(16)
  , part_key        as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
  , checkbook_number        varchar2(32)
  , checkbook_status        varchar2(8)
  , delivery_branch_number  varchar2(200)
  , leaflet_count           number(8)
  , reg_date                date
  , spent_date              date
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition cst_ibbl_acc_cb_lf_p01 values less than (to_date('1-1-2017','DD-MM-YYYY')) -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table cst_ibbl_acc_checkbook is 'Checkbook table'
/
comment on column cst_ibbl_acc_checkbook.id is 'Primary key'
/
comment on column cst_ibbl_acc_checkbook.checkbook_number is 'Number of a checkbook'
/
comment on column cst_ibbl_acc_checkbook.checkbook_status is 'Status of a checkbook. Dictionary CHBS'
/
comment on column cst_ibbl_acc_checkbook.delivery_branch_number is 'Delivery branch number (ost_agent.agent_number)'
/
comment on column cst_ibbl_acc_checkbook.leaflet_count is 'Count of leaflets of a checkbook'
/
comment on column cst_ibbl_acc_checkbook.reg_date is 'Date of a checkbook registration'
/
comment on column cst_ibbl_acc_checkbook.spent_date is 'Checkbook all leaflets using date'
/
