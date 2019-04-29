insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard) values (1001, 'CYTP1001', 0, 1)
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard) values (1003, 'CYTP1003', 0, 1)
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard) values (1002, 'CYTP1002', 0, 1)
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard) values (1004, 'CYTP1004', 0, 1)
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard) values (1005, 'CYTP1005', 0, 1)
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard) values (1008, 'CYTP1006', 1, 1)
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard) values (1025, 'CYTP1007', 1, 1)
/
update fcl_cycle_type set cycle_calc_start_date = 'CYSD0001' where id in (1002, 1003, 1004)
/
update fcl_cycle_type set cycle_calc_start_date = 'CYSD0002' where id in (1001, 1005)
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard, cycle_calc_start_date, cycle_calc_date_type) values (1097, 'CYTP1008', 0, 1, 'CYSD0001', NULL)
/
update fcl_cycle_type set is_repeating = 0 where id = 1005
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard, cycle_calc_start_date, cycle_calc_date_type) values (1108, 'CYTP0406', 0, 1, NULL, NULL)
/
delete from fcl_cycle_type where id = 1108
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard, cycle_calc_start_date, cycle_calc_date_type) values (1121, 'CYTP0406', 1, 1, NULL, NULL)
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard, cycle_calc_start_date, cycle_calc_date_type) values (1123, 'CYTP0407', 0, 1, NULL, NULL)
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard, cycle_calc_start_date, cycle_calc_date_type) values (1125, 'CYTP0408', 0, 1, NULL, NULL)
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard, cycle_calc_start_date, cycle_calc_date_type) values (1130, 'CYTP0411', 0, 1, NULL, NULL)
/
update fcl_cycle_type set cycle_type = 'CYTP1010' where id = 1123
/
update fcl_cycle_type set cycle_type = 'CYTP1011' where id = 1125
/
update fcl_cycle_type set cycle_type = 'CYTP1012' where id = 1121
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard, cycle_calc_start_date, cycle_calc_date_type) values (1131, 'CYTP1009', 0, 1, NULL, NULL)
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard, cycle_calc_start_date, cycle_calc_date_type) values (1132, 'CYTP1014', 0, 1, NULL, NULL)
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard, cycle_calc_start_date, cycle_calc_date_type) values (1133, 'CYTP1015', 0, 1, NULL, NULL)
/
update fcl_cycle_type set cycle_type = 'CYTP1013' where id = 1130
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard, cycle_calc_start_date, cycle_calc_date_type) values (1134, 'CYTP1016', 0, 1, NULL, NULL)
/
update fcl_cycle_type set cycle_calc_start_date = 'CYSD0001' where id = 1130
/
update fcl_cycle_type set is_repeating = 1, cycle_calc_start_date = 'CYSD0001' where id = 1134
/
update fcl_cycle_type set is_repeating = 1 where id = 1132
/
insert into fcl_cycle_type (id, cycle_type, is_repeating, is_standard, cycle_calc_start_date, cycle_calc_date_type) values (1157, 'CYTP1018', 0, 1, NULL, NULL)
/
delete from fcl_cycle_type where id = 1130
/
update fcl_cycle_type set is_repeating = 0 where id = 1134
/
