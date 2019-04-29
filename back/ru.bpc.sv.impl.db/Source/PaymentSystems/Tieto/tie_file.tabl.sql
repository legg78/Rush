create table tie_file(
    id                  number(16)
  , is_incoming         number(1)
  , network_id          number(4)
  , rec_centr           number(2)
  , send_centr          number(2)
  , file_name           varchar2(8)
  , card_id             varchar2(15)
  , file_version        varchar2(4)
  , inst_id             number(4)
  , records_count       number(8)
  , tran_sum            number(14)
  , control_sum         number(14)             
  , session_file_id     number(16)
)
/

comment on table tie_file is 'TIETO Clearing files'
/
comment on column tie_file.id is 'Primary key'
/
comment on column tie_file.is_incoming is 'Incoming flag'
/
comment on column tie_file.network_id is 'Network identifier'
/
comment on column tie_file.rec_centr is 'Receiver center code'
/
comment on column tie_file.send_centr is 'ender center code'
/
comment on column tie_file.file_name is 'File name(without extension)'
/
comment on column tie_file.card_id is 'Card type'
/
comment on column tie_file.file_version is 'File version'
/
comment on column tie_file.records_count is 'File records count'
/
comment on column tie_file.tran_sum is 'Sum of transactions(by Pr_amount field) taking into account an impact of transaction type'
/
comment on column tie_file.control_sum is 'Sum of transactions(by Sb_amount field)without taking into account an impact of transaction type'
/
comment on column tie_file.inst_id is 'Institution identifier'
/
comment on column tie_file.session_file_id is 'File object identifier(prc_session_file.id)'
/
