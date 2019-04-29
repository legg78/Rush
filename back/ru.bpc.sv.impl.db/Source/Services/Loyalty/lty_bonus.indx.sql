create index lty_bonus_account_ndx  on lty_bonus(account_id, status)
/****************** partition start ********************
    local
******************** partition end ********************/
/

create index lty_bonus_status_ndx  on lty_bonus(decode(status, 'BNST0100', status, null))
/

