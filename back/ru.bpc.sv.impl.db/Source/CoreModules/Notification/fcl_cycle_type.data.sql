insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard) values (1084, 'CYTP0132', 1, 1)
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard) values (1090, 'CYTP0902', 1, 1)
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard, cycle_calc_start_date, cycle_calc_date_type) values (1152, 'CYTP0417', 1, 1, NULL, NULL)
/
update fcl_cycle_type set cycle_type = 'CYTP1417' where id = 1152
/
update fcl_cycle_type set cycle_type = 'CYTP1017' where id = 1152
/
