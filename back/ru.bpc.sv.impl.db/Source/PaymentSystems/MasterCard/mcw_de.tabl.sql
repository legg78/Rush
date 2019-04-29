create table mcw_de (
    de_number           number(4) not null
    , name              varchar2(200)
    , format            varchar2(8)
    , min_length        number(4)
    , max_length        number(4)
    , prefix_length     number(4)
    , subfield_count    number(4)
)
/

comment on table mcw_de is 'MasterCard data elements definitions.'
/

comment on column mcw_de.de_number is 'Data element number defined in this record.'
/

comment on column mcw_de.name is 'Name of the data element defined in this record.'
/

comment on column mcw_de.format is 'Attribute convention describing the format of the data element defined in this record.'
/

comment on column mcw_de.min_length is 'The minimum length of the data element.'
/

comment on column mcw_de.max_length is 'Maximum length of this data element, as defined by MasterCard.'
/

comment on column mcw_de.prefix_length is 'Value that describes the data element length field size.'
/

comment on column mcw_de.subfield_count is 'Total count of subfields within the data element or PDS.'
/
