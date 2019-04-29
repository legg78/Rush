create table ecm_payment_method
(
    id              number(8)
  , merchant_id     number(8)
  , purpose_id      number(8)
)
/

comment on table ecm_payment_method is 'Payment method available for certain merchant'
/

comment on column ecm_payment_method.id is 'Primary key'
/

comment on column ecm_payment_method.merchant_id is 'Reference to merchant'
/

comment on column ecm_payment_method.purpose_id is 'Available purpose of payment'
/
