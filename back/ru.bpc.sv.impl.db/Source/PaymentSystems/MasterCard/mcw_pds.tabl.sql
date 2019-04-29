create table mcw_pds (
    pds_number          number(4) not null
    , name              varchar2(200)
    , format            varchar2(8)
    , min_length        number(4)
    , max_length        number(4)
    , subfield_count    number(4)
)
/


comment on table mcw_pds is 'This table contains the number, name, format requirements for the overall PDS, length requirements, and number of subfields within each PDS.'
/

comment on column mcw_pds.pds_number is 'PDS number defined in this record.'
/

comment on column mcw_pds.name is 'Name of the PDS defined in this record.'
/

comment on column mcw_pds.format is 'Attribute convention describing the format of the PDS defined in this record.'
/

comment on column mcw_pds.min_length is 'The minimum length of the PDS.'
/

comment on column mcw_pds.max_length is 'Maximum length of this PDS.'
/

comment on column mcw_pds.subfield_count is 'Total count of subfields within the PDS.'
/
 