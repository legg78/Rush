alter table com_array_conv_elem add constraint com_array_conv_elem_pk primary key(id)
/
alter table com_array_conv_elem add constraint com_array_conv_elem_uk unique(conv_id, in_element_value)
/