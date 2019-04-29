create global temporary table crd_reserve_tmp (
    account_id              number(12)
    , currency              varchar2(3)
    , product_id            number(8)
    , credit_rating         varchar2(8)
    , guarantee_category    varchar2(8)
    , reserve_amount        number(22,4)
)
on commit preserve rows
/

comment on table crd_reserve_tmp is 'This table contains all amount of reserved of accounts in institution.'
/

comment on column crd_reserve_tmp.account_id is 'Account identifier.'
/

comment on column crd_reserve_tmp.currency is 'Currency of account.'
/

comment on column crd_reserve_tmp.product_id is 'Product identifier.'
/

comment on column crd_reserve_tmp.credit_rating is 'Credit rating.'
/

comment on column crd_reserve_tmp.guarantee_category is 'Providing category.'
/

comment on column crd_reserve_tmp.reserve_amount is 'Calculated reserved amount of account.'
/
