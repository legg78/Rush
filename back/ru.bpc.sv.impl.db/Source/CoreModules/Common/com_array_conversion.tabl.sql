create table com_array_conversion (
    id            number(4)
  , seqnum        number(4)
  , in_array_id   number(8)
  , in_lov_id     number(4)
  , out_array_id  number(8)
  , out_lov_id    number(4)
  , conv_type     varchar2(8)
)
/

comment on table com_array_conversion is 'Array conversion pairs'
/

comment on column com_array_conversion.id is 'Primary key'
/

comment on column com_array_conversion.seqnum is 'Sequence number of data version.'
/

comment on column com_array_conversion.in_array_id is 'Reference to array with incoming values for conversion.'
/

comment on column com_array_conversion.in_lov_id is 'Reference to LOV with incoming values for conversion. Using if incoming array does not set.'
/

comment on column com_array_conversion.out_array_id is 'Reference to array with outgoing values for conversion.'
/

comment on column com_array_conversion.out_lov_id is 'Reference to LOV with outgoing values for conversion. Using if outgoing array does not set.'
/

comment on column com_array_conversion.conv_type is 'Conversion type (One-to-Many, One-to-One etc.).'
/