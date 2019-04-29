create table jcb_fin_p3005 (
    msg_id              number(16) not null
    , p3005_1           varchar2(5)
    , p3005_2           varchar2(3)
    , p3005_3           varchar2(4)
    , p3005_4           number(10)
    , p3005_5           number(8)
    , p3005_6           varchar2(3)
    , p3005_7           number(8)
    , p3005_8           varchar2(1)
    , p3005_9           varchar2(3)
    , p3005_10          number(12)
)
/

comment on table jcb_fin_p3005 is 'Amounts, Transaction Fees (PDS 3005) presents all fee amounts associated with a transaction'
/

comment on column jcb_fin_p3005.msg_id is 'Message identifier'
/

comment on column jcb_fin_p3005.p3005_1 is 'Fee Code'
/

comment on column jcb_fin_p3005.p3005_2 is 'Product/Grade'
/

comment on column jcb_fin_p3005.p3005_3 is 'MCC'
/

comment on column jcb_fin_p3005.p3005_4 is 'Fee Incentive Info'
/

comment on column jcb_fin_p3005.p3005_5 is 'Fee Rate'
/

comment on column jcb_fin_p3005.p3005_6 is 'Currency Code, Fee Price'
/

comment on column jcb_fin_p3005.p3005_7 is 'Fee Price'
/

comment on column jcb_fin_p3005.p3005_8 is 'Credit/Debit Indicator'
/

comment on column jcb_fin_p3005.p3005_9 is 'Currency Code, Fee, Reconciliation'
/

comment on column jcb_fin_p3005.p3005_10 is 'Amount, fee, Reconciliation'
/
