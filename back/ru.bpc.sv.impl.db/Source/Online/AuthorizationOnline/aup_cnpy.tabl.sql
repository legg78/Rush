create table aup_cnpy
(
  auth_id           number(16,0)
  , part_key        as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual       -- [@skip patch]
  , tech_id         varchar2(36)                                                         -- [@skip patch]
  , time_mark       varchar2(16)                                                         -- [@skip patch]
  , resp_code       varchar2(20)                                                         -- [@skip patch]
  )
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition aup_cnpy_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))           -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on column aup_cnpy.auth_id is 'Identifier authorization that causes message'
/

comment on column aup_cnpy.tech_id is 'Technical identifier of message'
/
comment on column aup_cnpy.time_mark is 'Time of processing by switch'
/
comment on column aup_cnpy.resp_code is 'Response code'
/
comment on table aup_cnpy is 'Table is used to store history of messages between ChronoPay Gateway and switch'
/
alter table aup_cnpy add constraint aup_cnpy_pk primary key (auth_id, tech_id)
/
