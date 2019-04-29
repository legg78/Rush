create table aup_atm  (
    auth_id         number(16)
  , part_key        as (to_date('1970.01.01 00:00:00','YYYY.MM.DD HH24:Mi:SS')+(to_number(time_mark)/(24*60*60*1000000))) virtual -- [@skip patch]
  , tech_id         varchar2(36)
  , message_type    number(2)
  , collection_id   number(12)
  , terminal_id     number(8)
  , time_mark       varchar2(16)
  , tvn             varchar2(8)
  , msg_coord_num   varchar2(1)
  , atm_part_type   varchar2(8)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition aup_atm_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on table aup_atm is 'Table is used to store authorization messages information received from NCR ATM.'
/
comment on column aup_atm.auth_id is 'Identifier of authorization to which the message belongs to.'
/
comment on column aup_atm.collection_id is 'Identifier of collection cycle to which authorization belongs to.'
/
comment on column aup_atm.message_type is 'Type of message, involved into authorization. The most common values are: 11 - request or ITR response, 40 - response, 30 - ITR, 22 - solicited status.'
/
comment on column aup_atm.msg_coord_num is 'Message Coordination Number (NCR protocol parameter) value. '
/
comment on column aup_atm.tech_id is 'Technical identifier of the messages, unique among overal system.'
/
comment on column aup_atm.terminal_id is 'Identifier of terminal that initiates authorization.'
/
comment on column aup_atm.time_mark is 'Date and time aggregate to control message sequence.'
/
comment on column aup_atm.tvn is 'Time Variant Number (NCR protocol parameter) value. '
/
comment on column aup_atm.atm_part_type is 'Type of ATM parts (Printer, Dispenser, Screen etc).'
/

alter table aup_atm add tsn varchar2(4)
/
comment on column aup_atm.tsn is 'Transaction sequence number.'
/

