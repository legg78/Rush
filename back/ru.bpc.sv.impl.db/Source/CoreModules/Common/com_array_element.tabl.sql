create table com_array_element (
    id              number(8)
  , seqnum          number(4)
  , array_id        number(8)
  , element_value   varchar2(200)
  , element_number  number(4)
)
/

comment on table com_array_element is 'Array elements.'
/

comment on column com_array_element.id is 'Primary key'
/

comment on column com_array_element.seqnum is 'Sequence number. Describe data version.'
/

comment on column com_array_element.array_id is 'Array identifier.'
/

comment on column com_array_element.element_value is 'Element value converted to char in predefined format.'
/

comment on column com_array_element.element_number is 'Element sequential number. Unique in array.'
/

alter table com_array_element add (numeric_value number(16))
/

comment on column com_array_element.numeric_value is 'Numeric value of the array element.'
/
