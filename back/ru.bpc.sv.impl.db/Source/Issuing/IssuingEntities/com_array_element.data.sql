insert into com_array_element (id, seqnum, array_id, element_value, element_number) values (10001182, 2, 10000001, '1428', 1)
/
insert into com_array_element (id, seqnum, array_id, element_value, element_number) values (10001183, 1, 10000001, '1989', 2)
/
insert into com_array_element (id, seqnum, array_id, element_value, element_number) values (10001184, 1, 10000001, '1177', 3)
/
update com_array_element set numeric_value = element_value where array_id = 10000001
/
