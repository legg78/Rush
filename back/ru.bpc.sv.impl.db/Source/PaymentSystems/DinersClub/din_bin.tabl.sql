create table din_bin(
    id                           number(19)
  , bin_length                   number(10)
  , start_bin                    varchar2(255)
  , end_bin                      varchar2(255)
  , agent_code                   varchar2(255)
  , agent_name                   varchar2(255)
  , country                      varchar2(255)
  , country_code                 varchar2(255)
  , session_id                   number(19)
)
/

comment on table din_bin is 'Diners Club BIN ranges table'
/
comment on column din_bin.id is 'Primary key'
/
comment on column din_bin.start_bin is 'Beginning of a BIN range'
/
comment on column din_bin.end_bin is 'Ending of a BIN range'
/
comment on column din_bin.agent_code is 'Agent code that is associated with a BIN range. It uses as Diners Club sending/reciving institution code.'
/
