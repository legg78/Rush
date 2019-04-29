create table acc_balance_type (
    id                      number(4)
    , seqnum                number(4)
    , account_type          varchar2(8)
    , balance_type          varchar2(8)
    , inst_id               number(4)
    , currency              varchar2(3)
    , rate_type             varchar2(8)
    , aval_impact           number(1)
    , status                varchar2(8)
    , number_format_id      number(4)    
    , number_prefix         varchar2(200)
    , update_macros_type    number(4)
)
/
comment on table acc_balance_type is 'list of available balances depending on account type'
/
comment on column acc_balance_type.account_type is 'account type'
/
comment on column acc_balance_type.balance_type is 'balance type'
/
comment on column acc_balance_type.inst_id is 'institution number in which this balance available'
/
comment on column acc_balance_type.currency is 'currency of balance of this type (if it should be exact independently of account currency)'
/
comment on column acc_balance_type.rate_type is 'Rate type which used to convert from balance currency to account currency'
/
comment on column acc_balance_type.aval_impact is 'impact of balance of this type on total available balance of account'
/
comment on column acc_balance_type.status is 'Balance status upon creation'
/
comment on column acc_balance_type.number_format_id is 'Name format identifier'
/
comment on column acc_balance_type.number_prefix is 'Number prefix component'
/
comment on column acc_balance_type.update_macros_type is 'Default macros type to update balance'
/
comment on column acc_balance_type.id is 'Record identifier'
/
comment on column acc_balance_type.seqnum is 'Sequence number. Describe data version.'
/

alter table acc_balance_type add balance_algorithm varchar2(8)
/
comment on column acc_balance_type.balance_algorithm is 'Algorithms for calculating the balance.'
/
