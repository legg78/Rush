create table ntf_channel (
    id              number(4)
  , address_pattern varchar2(200)
  , mess_max_length number(4)
  , address_source  varchar2(2000)
)
/

comment on table ntf_channel is 'Possible channels of message delivery.'
/

comment on column ntf_channel.id is 'Primary key.'
/

comment on column ntf_channel.address_pattern is 'Pattern to validate delivery address.'
/

comment on column ntf_channel.mess_max_length is 'Maximum length of message text.'
/

comment on column ntf_channel.address_source is 'Procedure name returning address string. Address extracting from notified entity.'
/