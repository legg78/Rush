create table cst_ibbl_acc_checkbook_leaflet(
    id              number(16)
  , part_key        as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
  , checkbook_id    number(16)
  , leaflet_number  varchar2(32)
  , leaflet_status  varchar2(8)
  , reg_date        date
  , used_date       date
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition cst_ibbl_acc_cb_lf_p01 values less than (to_date('1-1-2017','DD-MM-YYYY')) -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table cst_ibbl_acc_checkbook_leaflet is 'Checkbook leaflet'
/
comment on column cst_ibbl_acc_checkbook_leaflet.id is 'Identity of a leaflet. Sequence.'
/
comment on column cst_ibbl_acc_checkbook_leaflet.checkbook_id is 'Reference to table cst_ibbl_acc_checkbook'
/
comment on column cst_ibbl_acc_checkbook_leaflet.leaflet_number is 'Number of a leaflet'
/
comment on column cst_ibbl_acc_checkbook_leaflet.leaflet_status is 'Status of a leaflet. Dictionary CBLS.'
/
comment on column cst_ibbl_acc_checkbook_leaflet.reg_date is 'Date of a leaflet registration'
/
comment on column cst_ibbl_acc_checkbook_leaflet.used_date is 'Leaflet using date'
/
