create table aup_atm_bna(
    auth_id           number(16)
  , part_key          as (to_date('1970.01.01 00:00:00','YYYY.MM.DD HH24:Mi:SS')+(to_number(time_mark)/(24*60*60*1000000))) virtual -- [@skip patch]
  , tech_id           varchar2(36)
  , face_value        number(22, 4)
  , currency          varchar2(3)
  , denomination_code varchar2(3)
  , note_encashed     number(5)
  , time_mark         varchar2(16)
)
/****************** partition start ********************
partition by range (time_mark)
(
    partition aup_atm_bna_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
/

comment on table aup_atm_bna is 'Table is used to store Bunch Note Acceptor (Cash-In) authorization information.'
/
comment on column aup_atm_bna.tech_id is 'Technical identifier of message, unique within the system'
/
comment on column aup_atm_bna.auth_id is 'Authorization identifier'
/
comment on column aup_atm_bna.currency is 'ISO currency code for notes being encashed'
/
comment on column aup_atm_bna.face_value is 'Currency face value for notes being encashed'
/
comment on column aup_atm_bna.denomination_code is 'Denomination code reported by ATM at the moment of authorization'
/
comment on column aup_atm_bna.note_encashed is 'Number of notes encashed in transaction'
/
comment on column aup_atm_bna.time_mark is 'Date and time aggregate to control message sequence'
/
