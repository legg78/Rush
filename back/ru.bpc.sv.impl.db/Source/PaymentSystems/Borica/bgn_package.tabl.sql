create table bgn_package(
    id                  number(12)
  , sender_code         varchar2(5)
  , receiver_code       varchar2(5)
  , creation_date       date
  , package_type        varchar2(3)
  , record_total        number(6)
  , control_amount      number(13)
)
/

comment on table bgn_package is 'BORICA clearing FO file packages'
/

comment on column bgn_package.id is 'Primary key'
/
comment on column bgn_package.sender_code is 'BORICA''s code of file sender'
/
comment on column bgn_package.receiver_code is 'BORICA''s code of file receiver'
/
comment on column bgn_package.creation_date is 'File creation date'
/
comment on column bgn_package.package_type is 'Type of data package'
/
comment on column bgn_package.record_total is 'Total count of records in data package'
/
comment on column bgn_package.control_amount is 'Control amount'
/
alter table bgn_package add (package_number number(6), file_id number(16))
/
comment on column bgn_package.package_number is 'Sequence number of package'
/
comment on column bgn_package.file_id is 'Reference to bgn_file'
/
