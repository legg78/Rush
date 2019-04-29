create table aut_queue_log(
    auth_log_id number(16),
    auth_id             number(16)  not null,
    host_id             number(4)   not null,
    channel_id          number(8),
    is_advice_needed    number(1),
    is_reversal_needed  number(1),
    send_count          number(8),
    max_send_count      number(8),
    send_status         varchar2(8),
    log_date            timestamp(9)    not null,
    description         varchar2(255)
)
/
comment on table aut_queue_log is 'History of SAF-messages queues processing'
/
comment on column aut_queue_log.auth_log_id is 'Primary key'
/
comment on column aut_queue_log.auth_id is 'Reference on authorization record (aut_auth.id)'
/
comment on column aut_queue_log.host_id is 'Host id (net_member.id)'
/
comment on column aut_queue_log.send_status is 'Status of auth sending: needs to be sent(SNDS0001), sended successfully (SNDS0002), not sended(SNDS0003)'
/
comment on column aut_queue_log.log_date is 'Date of message processing'
/
comment on column aut_queue_log.description is 'Description of exceuted operation'
/
alter table aut_queue_log rename column auth_log_id to id
/

