create table vis_bin_range
(
    pan_low             varchar2(9)
  , pan_high            varchar2(9)
  , pan_length          number(2)
  , issuer_bin          varchar2(6)
  , processor_bin       varchar2(6)
  , check_digit         number(1)
  , card_type           varchar2(1)
  , card_usage          varchar2(1)
  , region              varchar2(8)
  , country             varchar2(3)
  , valid               number(1)
  , inst_id             number(4)
  , network_id          number(4)
)
/

comment on table vis_bin_range is 'VISA Account Range Table. This Table contains the list of valid VISA BINs and account range details. The content of this table is replaced as new VISA ARDEF report comes from Edit Package.'
/

comment on column vis_bin_range.inst_id is 'ID of the financial institution the record belongs to.'
/

comment on column vis_bin_range.issuer_bin is 'Issuer BIN.'
/

comment on column vis_bin_range.processor_bin is 'Member processing center BIN.'
/

comment on column vis_bin_range.pan_low is 'Starting account number.'
/

comment on column vis_bin_range.pan_high is 'Highest account number.'
/

comment on column vis_bin_range.pan_length is 'Account length for this BIN 00 - means a mixture of 13 - 16 account numbers.'
/

comment on column vis_bin_range.check_digit is 'Check digit algorithm. 0 - no check digit, 1 - Mod 10 algorithm.'
/

comment on column vis_bin_range.card_type is 'Card type. A - ATM B - Visa Business C - Visa Classic E - Electron M - MasterCard P - VISA Gold Q - Proprietary Card R - Corporate T and E Card S - Purchasing Card T - Travel Voucher X - Reserved.'
/

comment on column vis_bin_range.card_usage is 'Credit or Debit usage. C - Credit Card D - Debit Card SP - Unspecified'
/

comment on column vis_bin_range.region is 'VISA Region Code: 1 - US 2 - Canada 3 - EU 4 - Asia - Pacific 5 - Latin America and Caribbean 6 - CEMEA'
/

comment on column vis_bin_range.country is 'VISA Country Code. 2 - Digit VISA country code.'
/

comment on column vis_bin_range.valid is 'Contains True by default. The value of False allows customers to lock certain BINs.'
/

comment on column vis_bin_range.network_id is 'Network identifier - BIN owner.'
/

alter table vis_bin_range add (product_id varchar2(8 byte))
/

comment on column vis_bin_range.product_id is 'Product ID. VCPCL_ - Electron, VCPC__ - not define, VCPCF_ - Classic, VCPCA_ - Traditional, VCPCI_ -Infinite, VCPCN_ -Platinum, VCPCP_ - Gold, VCPCS_ - Purchasing'
/

alter table vis_bin_range add (token_indicator  varchar2(1))
/
comment on column vis_bin_range.token_indicator is 'Token indicator'
/

alter table vis_bin_range add (account_funding_source  varchar2(1))
/
comment on column vis_bin_range.account_funding_source is 'Account Funding Source. C = Credit, D = Debit, P = Prepaid, H = Charge, R = Deferred Debit'
/
comment on column vis_bin_range.product_id is 'Product ID. L - Electron, Spaces - not define, F - Classic, A - Traditional, I -Infinite, N -Platinum, P - Gold, S - Purchasing etc'
/

alter table vis_bin_range  add (fast_funds  varchar2(1))
/
alter table vis_bin_range  add (technology_indicator  varchar2(1))
/
comment on column vis_bin_range.fast_funds is 'Fast Funds. Y = Domestic and cross-border Fast Funds; C = Cross-border only; D = Domestic Fast Funds only; Space = Does not participate in Fast Funds'
/
comment on column vis_bin_range.technology_indicator is 'A - Chip Card'
/
 