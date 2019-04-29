create index opr_participant_customer_ndx on opr_participant (customer_id)
/****************** partition start ********************
    local
******************** partition end ********************/
/

create index opr_participant_card_ndx on opr_participant (reverse(card_mask))
/****************** partition start ********************
    global
******************** partition end ********************/
/

create index opr_participant_acct_ndx on opr_participant (reverse(account_number))
/****************** partition start ********************
    global
******************** partition end ********************/
/

create index opr_participant_card_hash_ndx on opr_participant (card_hash)
/****************** partition start ********************
    global
******************** partition end ********************/
/

create index opr_participant_terminal_ndx on opr_participant (terminal_id)
/****************** partition start ********************
    local
******************** partition end ********************/
/

create index opr_participant_merchant_ndx on opr_participant (merchant_id)
/****************** partition start ********************
    local
******************** partition end ********************/
/

create index opr_participant_card_id_ndx on opr_participant (card_id)
/****************** partition start ********************
    local
******************** partition end ********************/
/

create index opr_participant_acct_id_ndx on opr_participant (account_id)
/****************** partition start ********************
    local
******************** partition end ********************/
/

drop index opr_participant_card_hash_ndx
/
drop index opr_participant_card_ndx
/
drop index opr_participant_acct_ndx
/
