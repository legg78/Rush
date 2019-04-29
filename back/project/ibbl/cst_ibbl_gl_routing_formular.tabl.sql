create table cst_ibbl_gl_routing_formular(
    operation_id   number(16) not null
  , sttl_date      date
  , src_bin        varchar2(6)
  , dst_bin        varchar2(6)
  , f9_intl        number(22,4)
  , f9_dom         number(22,4)
  , c9_intl        number(22,4)
  , c9_dom         number(22,4)
  , i9_intl        number(22,4)
  , bdt_conv_rate  number
  , sttl_currency  varchar2(3)
  , net_commission number(22,4)
)
/

comment on table cst_ibbl_gl_routing_formular is 'Values for calculation of NET commission formular for GL routing'
/

comment on column cst_ibbl_gl_routing_formular.src_bin        is 'Source BIN'
/
comment on column cst_ibbl_gl_routing_formular.sttl_date      is 'Settlement date'
/
comment on column cst_ibbl_gl_routing_formular.dst_bin        is 'Destination BIN'
/
comment on column cst_ibbl_gl_routing_formular.operation_id   is 'Operation ID'
/
comment on column cst_ibbl_gl_routing_formular.f9_intl        is 'Total reimbursement fees (international)'
/
comment on column cst_ibbl_gl_routing_formular.f9_dom         is 'Total reimbursement fees (domestic)'
/
comment on column cst_ibbl_gl_routing_formular.c9_intl        is 'Total visa charges (international)'
/
comment on column cst_ibbl_gl_routing_formular.c9_dom         is 'Total visa charges (domestic)'
/
comment on column cst_ibbl_gl_routing_formular.i9_intl        is 'Total interchange (international)'
/
comment on column cst_ibbl_gl_routing_formular.bdt_conv_rate  is 'Conversion rate to BDT'
/
comment on column cst_ibbl_gl_routing_formular.sttl_currency  is 'Currency'
/
comment on column cst_ibbl_gl_routing_formular.net_commission is 'Calculated value of NET commission in currency of 050 (BDT - Taka)'
/
