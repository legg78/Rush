create table aup_card_status_resp (
    id              number(4)
    , seqnum        number(4)
    , inst_id       varchar2(8)
    , oper_type     varchar2(8)
    , card_state    varchar2(8)
    , card_status   varchar2(8)
    , pin_presence  varchar2(8)    
    , resp_code     varchar2(8)
    , priority      number(4)
)
/
comment on table aup_card_status_resp is 'Mapping of card statuses to authorization response'
/
comment on column aup_card_status_resp.id is 'Record identifier'
/
comment on column aup_card_status_resp.seqnum is 'Sequential version of data record'
/
comment on column aup_card_status_resp.inst_id is 'Institution identifier'
/
comment on column aup_card_status_resp.oper_type is 'Operation type'
/
comment on column aup_card_status_resp.card_state is 'Card state'
/
comment on column aup_card_status_resp.card_status is 'Card status'
/
comment on column aup_card_status_resp.pin_presence is 'Pin presence indicator (PINP)'
/
comment on column aup_card_status_resp.resp_code is 'Response code correspondence'
/
comment on column aup_card_status_resp.priority is 'Selection priority'
/
alter table aup_card_status_resp add (msg_type varchar2(8), participant_type varchar2(8))
/
comment on column aup_card_status_resp.msg_type is 'Message type (MSGT dictionary'
/
comment on column aup_card_status_resp.participant_type is 'Type of operation participant (Dictionary "PRTY" - Issuer, Acquirer, Destination)'
/
