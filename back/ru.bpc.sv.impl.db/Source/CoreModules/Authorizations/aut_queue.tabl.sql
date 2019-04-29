create table aut_queue(
    auth_id             number(16),
    host_id             number(4),
    channel_id          number(8),
    is_advice_needed    number(1)   not null,
    is_reversal_needed  number(1)   not null,
    send_count          number(8),
    max_send_count      number(8)   not null,
    send_status         varchar2(8) not null)
/
comment on table aut_queue is 'SAF-messages queues managing which needed to be sent in outside networks'
/
comment on column aut_queue.auth_id is 'Reference on authorization record (aut_auth.id)'
/
comment on column aut_queue.host_id is 'Host id (net_member.id)'
/
comment on column aut_queue.channel_id is 'Sending channel id (net_device.device_id)'
/
comment on column aut_queue.is_advice_needed is 'Flag of necessity of advice sending'
/
comment on column aut_queue.is_reversal_needed is 'Flag of necessity of reversal advice sending'
/
comment on column aut_queue.send_count is 'Number of attempts of sending'
/
comment on column aut_queue.max_send_count is 'Maximum number of attempts of sending'
/
comment on column aut_queue.send_status is 'Status of auth sending: needs to be sent(SNDS0001), sended successfully (SNDS0002), not sended(SNDS0003)'
/
