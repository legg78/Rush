create table frp_suite_object
(
    id                  number(16)
  , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual        -- [@skip patch]
  , seqnum              number(4)
  , suite_id            number(4)
  , entity_type         varchar2(8)
  , object_id           number(16)
  , start_date          date
  , end_date            date
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition frp_suite_obj_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))      -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table frp_suite_object is 'Suites linked with business entities.'
/

comment on column frp_suite_object.id is 'Primary key.'
/
comment on column frp_suite_object.seqnum is 'Sequential number of data version'
/
comment on column frp_suite_object.suite_id is 'Suite identifier'
/
comment on column frp_suite_object.entity_type is 'Entity type '
/
comment on column frp_suite_object.object_id is 'Object identifier'
/
comment on column frp_suite_object.start_date is 'Start date of suite for that object.'
/
comment on column frp_suite_object.end_date is 'End date of suite for that object.'
/
