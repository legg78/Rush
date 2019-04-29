create table qpr_detail_visa_bin(
    visa_bin                varchar2(24)
  , account_funding_source  varchar2(100)
  , product_id              varchar2(8)
)
/
comment on table qpr_detail_visa_bin                         is 'VISA BIN which is used in table qpr_detail'
/
comment on column qpr_detail_visa_bin.visa_bin               is 'Full BIN for Visa network'
/
comment on column qpr_detail_visa_bin.account_funding_source is 'Account Funding Source. C = Credit, D = Debit, P = Prepaid, H = Charge, R = Deferred Debit'
/
comment on column qpr_detail_visa_bin.product_id             is 'Product ID. L - Electron, Spaces - not define, F - Classic, A - Traditional, I -Infinite, N -Platinum, P - Gold, S - Purchasing etc'
/
