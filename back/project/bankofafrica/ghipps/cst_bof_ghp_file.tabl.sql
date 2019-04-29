create table cst_bof_ghp_file(
    id                  number(16)
  , is_incoming         number(1)
  , is_returned         number(1)
  , network_id          number(4)
  , proc_bin            varchar2(6)
  , proc_date           date
  , release_number      varchar2(15)
  , ghp_file_id         varchar2(3)
  , file_status_ind     varchar2(1)
  , inst_id             number(4)
  , session_file_id     number(16)
  , originator_bin      varchar2(6)
  , total_phys_records  number(16)
)
/

comment on table cst_bof_ghp_file is 'Clearing files.'
/
comment on column cst_bof_ghp_file.id is 'Primary key. Equal to ID in PRC_SESSION_FILE.'
/
