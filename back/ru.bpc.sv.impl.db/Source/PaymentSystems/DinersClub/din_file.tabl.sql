create table din_file(
    id                           number(16)
  , is_incoming                  number(1)
  , network_id                   number(4)
  , inst_id                      number(4)
  , recap_total                  number(8)
  , file_date                    date
  , is_rejected                  number(1)
)
/

comment on table din_file is 'Diners Club clearing files'
/
comment on column din_file.id is 'Primary key. It is equal to primary key (ID) of table PRC_SESSION_FILE'
/
comment on column din_file.is_incoming is 'Incoming/outgouing message flag (1 — incoming, 0 — outgoing)'
/
comment on column din_file.network_id is 'Network ID (as usual Diners Club network ID)'
/
comment on column din_file.inst_id is 'Institution ID that generates (ACQ) an outgoing message or receives (ISS) an incoming message'
/
comment on column din_file.recap_total is 'Total amount of recaps in the file'
/
comment on column din_file.file_date is 'Date of file generating'
/
comment on column din_file.is_rejected is 'Rejected flag (reserved)'
/
comment on column din_file.is_incoming is 'Incoming/outgouing message flag (1 - incoming, 0 - outgoing)'
/
