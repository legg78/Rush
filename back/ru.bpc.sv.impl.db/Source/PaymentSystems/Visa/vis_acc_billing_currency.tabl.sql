create table vis_acc_billing_currency (
    low_range       number(24)
    , high_range    number(24)
    , currency      varchar2(3)
    , load_date     date
)
/
comment on table vis_acc_billing_currency is 'Account billing currencies assist to correctly determine the cardholder''s billing currency by card number.'
/
comment on column vis_acc_billing_currency.low_range is 'Low range of card number'
/
comment on column vis_acc_billing_currency.high_range is 'High range of card number'
/
comment on column vis_acc_billing_currency.currency is 'Currency of the card'
/
comment on column vis_acc_billing_currency.load_date is 'Date when the record was loaded'
/
