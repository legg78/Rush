create table cst_woo_import_f78(
    seq_id                      varchar2(10)
    , approved_date             varchar2(10)
    , tele_mess_num             varchar2(10)
    , trans_num                 varchar2(20)
    , card_num                  varchar2(20)
    , card_revenue_type         varchar2(10)
    , approved_amt              number(22,4)
    , cash_id_code              varchar2(10)
    , card_approved_code        varchar2(10)
    , approved_time             varchar2(10)
    , terminal_id               varchar2(20)
    , terminal_agent_id         varchar2(10)
    , response_code             varchar2(10)
    , import_date               date
    , file_name                 varchar2(100)
)
/
comment on table cst_woo_import_f78 is 'Cash Advance Approval'
/
comment on column cst_woo_import_f78.approved_date       is 'Date of approval  '
/
comment on column cst_woo_import_f78.tele_mess_num       is 'A telegraphic message NUMBER '
/
comment on column cst_woo_import_f78.trans_num           is 'Transaction number  '
/
comment on column cst_woo_import_f78.card_num            is 'card number '
/
comment on column cst_woo_import_f78.card_revenue_type   is 'Card revenue type'
/
comment on column cst_woo_import_f78.approved_amt        is 'Approved amount '
/
comment on column cst_woo_import_f78.cash_id_code        is 'Cash data identification code'
/
comment on column cst_woo_import_f78.card_approved_code  is 'Card transaction approval processing code'
/
comment on column cst_woo_import_f78.approved_time       is 'Approval Time'
/
comment on column cst_woo_import_f78.terminal_id         is 'Authorization terminal number'
/
comment on column cst_woo_import_f78.terminal_agent_id   is 'Handling branch code '
/
comment on column cst_woo_import_f78.response_code       is 'Response code'
/
alter table cst_woo_import_f78 add (sv_amount number(22,4), rcn_status number(1))
/
comment on column cst_woo_import_f78.sv_amount           is 'Amount in SV'
/
comment on column cst_woo_import_f78.rcn_status          is 'Reconciliation status. 1: Data only in CBS, 2: Data only in SV, 3: matched other conditions but amount not matched, 4: matched all conditions'
/
