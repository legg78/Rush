create table aup_spdh (
      auth_id                number(16)
    , part_key               as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , tech_id                varchar2(36)
    , fidmap                 varchar2(54)
    , device_id              number(4)
    , transmission_number    number(3)
    , terminal_tech_id       varchar2(16)
    , employee_id            varchar2(6)
    , trms_datetime          date
    , message_type           number(3)
    , message_sub_type       number(3)
    , transaction_code       number(3)
    , processing_flag_1      number(1)
    , processing_flag_2      number(1)
    , processing_flag_3      number(1)
    , resp_code              number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                 -- [@skip patch]
(                                                                                   -- [@skip patch]
    partition aup_spdh_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))    -- [@skip patch]
)                                                                                   -- [@skip patch]
******************** partition end ********************/
/

comment on table aup_spdh is 'Table is used to store headers of SPDH messages'
/
comment on column aup_spdh.auth_id is 'Identifier authorization that causes message'
/
comment on column aup_spdh.tech_id is 'Technical identifier of message'
/
comment on column aup_spdh.fidmap is 'List of FIDs presents int message'
/
comment on column aup_spdh.device_id is 'Device number'
/
comment on column aup_spdh.transmission_number is 'Number of transmission type'
/
comment on column aup_spdh.terminal_tech_id is 'Terminal technical unique number'
/
comment on column aup_spdh.employee_id is 'Employee or retailer number'
/
comment on column aup_spdh.trms_datetime is 'Transmission date and time'
/
comment on column aup_spdh.message_type is 'Message type of SPDH protocol'
/
comment on column aup_spdh.message_sub_type is 'Message subtype of SPDH protocol'
/
comment on column aup_spdh.transaction_code is 'Local identifier number'
/
comment on column aup_spdh.processing_flag_1 is 'Local mandatory processing flag'
/
comment on column aup_spdh.processing_flag_2 is 'Local mandatory processing flag'
/
comment on column aup_spdh.processing_flag_3 is 'Local mandatory processing flag'
/
comment on column aup_spdh.resp_code is 'Response code'
/
