create table iss_card_token (
    id                        number(12)
    , card_id                 number(12)
    , card_instance_id        number(12)
    , token                   varchar2(24)
    , status                  varchar2(8)
    , split_hash              number(4)
    , init_oper_id            number(16)
    , close_session_file_id   number(16)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table iss_card_token is 'Tokens'
/
comment on column iss_card_token.id is 'Token identifier'
/
comment on column iss_card_token.card_id is 'Card identifier'
/
comment on column iss_card_token.card_instance_id is 'Card instance identifier'
/
comment on column iss_card_token.token is 'Token value'
/
comment on column iss_card_token.status is 'Token status'
/
comment on column iss_card_token.split_hash is 'Hash value to split further processing'
/
comment on column iss_card_token.init_oper_id is 'Operation identifier which create token'
/
comment on column iss_card_token.close_session_file_id is 'Session identifier which suspend token'
/
alter table iss_card_token enable row movement
/ 

alter table iss_card_token add wallet_provider varchar2(8)
/
comment on column iss_card_token.wallet_provider is 'Wallet provider (WLPR dictionary)'
/
alter table iss_card_token add update_oper_id number(16)
/
comment on column iss_card_token.update_oper_id is 'Reference to opr_operation.id  which update token for oper_type (suspend/resume)'
/
alter table iss_card_token add event_type varchar2(8)
/
comment on column iss_card_token.event_type is 'Type of last event, which modified the token status.'
/
