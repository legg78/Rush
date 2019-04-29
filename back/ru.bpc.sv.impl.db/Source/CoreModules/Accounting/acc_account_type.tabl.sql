create table acc_account_type (
    id               number(4)
  , seqnum           number(4)
  , account_type     varchar2(8)
  , inst_id          number(4)
  , number_format_id number(4)
  , number_prefix    varchar2(200)
  , product_type     varchar2(8))
/

comment on table acc_account_type is 'List of account types'
/

comment on column acc_account_type.seqnum is 'Data version number'
/

comment on column acc_account_type.account_type is 'Account type'
/

comment on column acc_account_type.inst_id is 'Institution identifier'
/

comment on column acc_account_type.number_format_id is 'Name format identifier'
/

comment on column acc_account_type.number_prefix is 'Naming part'
/

comment on column acc_account_type.product_type is 'Product type'
/

comment on column acc_account_type.id is 'Record identifier'
/
