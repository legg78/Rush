create table cst_ap_synt
(
    id                 number(16) not null
  , part_key        as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , session_file_id    number(16)
  , file_type          varchar2(5)
  , session_day        date
  , opr_type           number(3)
  , bank_id            varchar2(3)
  , oper_cnt           number(16)
  , oper_amount        number(16)
  , balance_impact     number(1)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition cst_ap_synt_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))        -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/
comment on table cst_ap_synt is 'Table contains data of SYNTI, SYNTO and SYNTR files'
/
comment on column cst_ap_synt.id is 'ID'
/
comment on column cst_ap_synt.session_file_id is 'Ref on prc_session_file.id'
/
comment on column cst_ap_synt.file_type is 'Type of file: SYNTI, SYNTO, SYNTR'
/
comment on column cst_ap_synt.session_day is 'Session date of the file'
/
comment on column cst_ap_synt.opr_type is 'Operation type'
/
comment on column cst_ap_synt.bank_id is 'Identifier of bank'
/
comment on column cst_ap_synt.oper_cnt is 'Count of operations'
/
comment on column cst_ap_synt.oper_amount is 'Total amount of operation'
/
comment on column cst_ap_synt.balance_impact is 'For SYNTR -1/1 (DEBIT/CREDIT)'
/
