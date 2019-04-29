create table cmp_file (
    id                      number(16) not null
    , part_key              as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
    , is_incoming           number(1)
    , is_rejected           number(1)
    , network_id            number(4)
    , trans_date            date
    , inst_id               number(4)
    , inst_name             varchar2(200) --??? com_i18
    , action_code           number(1)
    , file_number           number(2)
    , pack_no               varchar2(9)
    , version               varchar2(10)
    , crc                   number(20)
    , encoding              varchar2(6)
    , file_type             varchar2(10)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition cmp_file_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))           -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table cmp_file is 'All clearing files'
/

comment on column cmp_file.id is 'Primary key. Equal to ID in PRC_SESSION_FILE'
/
comment on column cmp_file.is_incoming is '0 - incoming file, 1 � outgoing file'
/
comment on column cmp_file.is_rejected is '1 � rejected file'
/
comment on column cmp_file.network_id is 'Network identifier'
/
comment on column cmp_file.trans_date is 'Transmittal date'
/
comment on column cmp_file.inst_id is 'Institution identifier'
/
comment on column cmp_file.inst_name is 'Institution name'
/
comment on column cmp_file.action_code is 'Action code'
/
comment on column cmp_file.file_number is 'File Sequence Number'
/
comment on column cmp_file.pack_no is 'Serial number of the packet'
/
comment on column cmp_file.version is 'Protocol Version'
/
comment on column cmp_file.crc is 'Check sum'
/
comment on column cmp_file.encoding is 'File encoding'
/
comment on column cmp_file.file_type is 'File type'
/
alter table cmp_file add (session_file_id  number(16))
/
comment on column cmp_file.session_file_id is 'File object identifier (prc_session_file.id).'
/
