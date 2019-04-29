create table prc_directory(
    id number(4,0)
  , seqnum number(4)
  , encryption_type varchar2(8) 
  , directory_path varchar2(200)
)
/

comment on table prc_directory  is 'Directory settings.'
/

comment on column prc_directory.id IS 'Identifier.'
/
comment on column prc_directory.seqnum IS 'Data version sequence number.'
/
comment on column prc_directory.encryption_type is 'Encryption type'
/
comment on column prc_directory.directory_path is 'Directory path'
/
