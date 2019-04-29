create table adt_trail
(
    id           number(16)
  , part_key     as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , entity_type  varchar2(8)
  , object_id    number(16)
  , action_type  varchar2(8)
  , action_time  timestamp(6)
  , user_id      number(8)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition adt_trail_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/
comment on table adt_trail is 'Audit trail.'
/
comment on column adt_trail.id is 'Primary key.'
/
comment on column adt_trail.entity_type is 'Business-entity type.'
/
comment on column adt_trail.object_id is 'Object identifier.'
/
comment on column adt_trail.action_type is 'Action type - INSERT, UPDATE, DELETE.'
/
comment on column adt_trail.action_time is 'Action timestamp'
/
comment on column adt_trail.user_id is 'User identifier.'
/
alter table adt_trail add (priv_id number(8), session_id  number(16), status varchar2(8))
/
comment on column adt_trail.priv_id    is 'Reference to priviledge.'
/
comment on column adt_trail.session_id is 'Session identifier.'
/
comment on column adt_trail.status     is 'Status.'
/

