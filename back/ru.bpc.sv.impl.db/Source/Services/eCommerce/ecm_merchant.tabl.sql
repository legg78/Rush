create table ecm_merchant
(
    id                  number(8)
  , merchant_login      varchar2(200)
  , merchant_password   varchar2(200)
  , internet_store_url  varchar2(200)
  , ip_address          varchar2(200)
  , success_url         varchar2(200)
  , fail_url            varchar2(200)
  , split_hash          number(4)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/

comment on table ecm_merchant is 'Merchants registred as internet stores'
/

comment on column ecm_merchant.id is 'Merchant identifier. Equal with identifier in ACQ_MERCHANT.'
/

comment on column ecm_merchant.merchant_login is 'Merchant login for authentification in eCommerce module'
/

comment on column ecm_merchant.merchant_password is 'Merchant password for authentification in eCommerce module'
/

comment on column ecm_merchant.internet_store_url is 'URL of site'
/

comment on column ecm_merchant.ip_address is 'Store IP address'
/

comment on column ecm_merchant.success_url is 'URL for success payment'
/

comment on column ecm_merchant.fail_url is 'URL for failed payment.'
/

comment on column ecm_merchant.split_hash is 'Hash value to split further processing'
/
