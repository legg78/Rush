create table com_array_conv_elem (
    id                 number(8)
  , conv_id            number(4)
  , in_element_value   varchar2(200)
  , out_element_value  varchar2(200)
)
/

comment on table com_array_conv_elem is 'Conversion elements.'
/

comment on column com_array_conv_elem.id is 'Primary key'
/

comment on column com_array_conv_elem.conv_id is 'Reference to array correspondence.'
/

comment on column com_array_conv_elem.in_element_value is 'Incoming value.'
/

comment on column com_array_conv_elem.out_element_value is 'Outgoing value.'
/