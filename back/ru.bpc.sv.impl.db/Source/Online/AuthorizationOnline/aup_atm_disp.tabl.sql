create table aup_atm_disp(
    auth_id         number(16)
  , tech_id         varchar2(36)
  , disp_number     number(4)
  , face            number(22, 4)
  , currency        varchar2(3)
  , note_dispensed  number(4)
  , note_remained   number(4)
  , time_mark       varchar2(16)
  , part_key        as (to_date('1970.01.01 00:00:00','YYYY.MM.DD HH24:Mi:SS')+(to_number(time_mark)/(24*60*60*1000000))) virtual -- [@skip patch]
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition aup_atm_disp_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on table aup_atm_disp is 'Table is used to store authorization dispense information.'
/
comment on column aup_atm_disp.tech_id is 'Technical identifier of the messages, unique among overal system.'
/
comment on column aup_atm_disp.auth_id is 'Authorization identifier'
/
comment on column aup_atm_disp.currency is 'ISO currency code for notes which are loaded into cassette at the moment of authorization'
/
comment on column aup_atm_disp.disp_number is 'Identifier of dispenser cassette within dispenser hardware set.'
/
comment on column aup_atm_disp.face is 'Currency face value for notes which are loaded into cassette at the moment of authorization.'
/
comment on column aup_atm_disp.note_dispensed is 'Number of notes dispensed from cassette during transaction.'
/
comment on column aup_atm_disp.note_remained is 'Number of notes remained in cassette after transaction.'
/
comment on column aup_atm_disp.time_mark is 'Date and time aggregate to control message sequence.'
/
