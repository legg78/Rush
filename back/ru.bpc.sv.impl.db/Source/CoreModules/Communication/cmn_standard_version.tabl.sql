create table cmn_standard_version (
    id                number(4)
    , seqnum          number(4)
    , standard_id     number(4)
    , version_number  varchar2(200)
    , version_order   number(4)
)
/
comment on table cmn_standard_version is 'Standard versions'
/
comment on column cmn_standard_version.id is 'Primary key'
/
comment on column cmn_standard_version.standard_id is 'Reference to communication standard'
/
comment on column cmn_standard_version.version_number is 'Version number in free form'
/
comment on column cmn_standard_version.seqnum is 'Sequence number. Describe data version.'
/
comment on column cmn_standard_version.version_order is 'Numeric order of standard version release.'
/

