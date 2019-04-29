create table ecm_3ds_message
(
    id                  number(16)
  , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
  , message_type        varchar2(8)
  , message_date        date
  , message_body        clob
  , session_uuid        varchar2(36)
  , message_uuid        varchar2(36)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition ecm_3ds_message_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))    -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table ecm_3ds_message is '3DS messages'
/

comment on column ecm_3ds_message.id is 'Primary key'
/
comment on column ecm_3ds_message.message_type is 'Message type (VEReq, VERes, PAReq, PARes)'
/
comment on column ecm_3ds_message.message_date is 'Date when message was recieved or sent'
/
comment on column ecm_3ds_message.message_body is 'Message content'
/
comment on column ecm_3ds_message.session_uuid is '3DS session unique identifier'
/
comment on column ecm_3ds_message.message_uuid is '3DS message unique identifier'
/
alter table ecm_3ds_message add (status varchar2(8), account_id number(12))
/
comment on column ecm_3ds_message.status is 'Message status.'
/
comment on column ecm_3ds_message.account_id is 'Account identifier.'
/
alter table ecm_3ds_message add card_id number(12)
/
comment on column ecm_3ds_message.card_id is 'Card identifier.'
/
alter table ecm_3ds_message modify account_id varchar2(200)
/
comment on column ecm_3ds_message.account_id is '3DS account identifier.'
/
alter table ecm_3ds_message add (version varchar2(8), message_originator varchar2(3))
/
comment on column ecm_3ds_message.version is 'Stores the message version.'
/
comment on column ecm_3ds_message.message_originator is 'Determining who added entry.'
/
