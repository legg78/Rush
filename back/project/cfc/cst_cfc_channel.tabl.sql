create table cst_cfc_channel (
    id                number(8) not null
  , channel_name      varchar2(32)
  , terminal_number   varchar2(16)
)
/
comment on table cst_cfc_channel is 'Link between channel name and terminal number'
/
comment on column cst_cfc_channel.id is 'Primary key'
/
comment on column cst_cfc_channel.channel_name is 'Channel name'
/
comment on column cst_cfc_channel.terminal_number is 'Terminal number'
/
