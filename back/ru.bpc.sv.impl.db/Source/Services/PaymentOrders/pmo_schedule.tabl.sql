create table pmo_schedule (
    id               number(16)
  , part_key         as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , seqnum           number(4)
  , order_id         number(16)
  , event_type       varchar2(8)
  , entity_type      varchar2(8)
  , object_id        number(16)
  , attempt_limit    number(4)
  , amount_algorithm varchar2(8)
  , cycle_id         number(16)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition pmo_schedule_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on table pmo_schedule is 'Schedule of payment template automatic implementation'
/
comment on column pmo_schedule.id is 'Primary key'
/
comment on column pmo_schedule.seqnum is 'Data version sequence number'
/
comment on column pmo_schedule.order_id is 'Template to implemetation'
/
comment on column pmo_schedule.event_type is 'System event triggers the template implementation.'
/
comment on column pmo_schedule.entity_type is 'Type of entity assigned with event raising payment order generation.'
/
comment on column pmo_schedule.object_id is 'Object identifier assigned with event.'
/
comment on column pmo_schedule.attempt_limit is 'Limit of attempts to process payment order'
/
comment on column pmo_schedule.amount_algorithm is 'Algorithm to define amount of autimatic payment'
/
comment on column pmo_schedule.cycle_id is 'Individual payment order cycle for periodic execution'
/
