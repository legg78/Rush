create or replace force view acc_api_balance_reserv_vw as
select
    account_id
    , balance_type
    , sum(balance_impact * amount) reserv_amount
    , split_hash
from
    acc_entry_buffer
where
    status = 'BUSTRSRV'
    and posting_date > get_sysdate
group by
    account_id
    , balance_type
    , split_hash
/