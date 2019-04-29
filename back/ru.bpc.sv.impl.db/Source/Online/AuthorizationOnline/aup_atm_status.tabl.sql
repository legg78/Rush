create table aup_atm_status (
    tech_id varchar2(36)
    , time_mark timestamp
    , device_id varchar2(8)
    , device_status varchar2(256)
    , error_severity varchar2(14)
    , diag_status varchar2(256)
    , supplies_status varchar2(8)
)
/

comment on table aup_atm_status is 'Table of ATM status.'
/
comment on column aup_atm_status.tech_id is 'Technical identifier of message.'
/
comment on column aup_atm_status.time_mark is 'Time of processing by switch'
/
comment on column aup_atm_status.device_id is 'Identifier ATM device that initiates status message.'
/
comment on column aup_atm_status.device_status is 'Identifier ATM device status.'
/
comment on column aup_atm_status.error_severity is 'Identifier error severity.'
/
comment on column aup_atm_status.diag_status is 'Identifier diagnostic status.'
/
comment on column aup_atm_status.supplies_status is 'Identifier supplies status.'
/

alter table aup_atm_status add (id number(16))
/
comment on column aup_atm_status.id is 'Primary key.'
/
