create table aci_file (
    id                 number(16)
    , part_key         as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , is_incoming      number(1)
    , session_file_id  number(16)
    , network_id       varchar2(4)
    , extract_date     date
    , release_number   number(4)
    , name             varchar2(200)
    , file_type        varchar2(8)
    , total            number(8)
    , amount           number(22,4)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition aci_file_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))           -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table aci_file is 'ACI Base24 files.'
/

comment on column aci_file.id is 'Primary key.'
/
comment on column aci_file.is_incoming is 'Incoming flag'
/
comment on column aci_file.session_file_id is 'Session file identifier'
/
comment on column aci_file.network_id is 'Network identifier.'
/
comment on column aci_file.extract_date is 'The date of the extracted file.'
/
comment on column aci_file.release_number is 'The BASE24 software release number indicating the release of the software with which the extracted file is compatible.'
/
comment on column aci_file.name is 'The fully expanded file name ofthe extracted file.'
/
comment on column aci_file.file_type is 'A file mnemonic indicating the file that was extracted.'
/
comment on column aci_file.total is 'A total kept by the Super Extract process during the processing of the records.'
/
comment on column aci_file.amount is 'The number of file records extracted.'
/
alter table aci_file add impact_timestamp timestamp
/
comment on column aci_file.amount is 'The last record extracted from the file'
/
