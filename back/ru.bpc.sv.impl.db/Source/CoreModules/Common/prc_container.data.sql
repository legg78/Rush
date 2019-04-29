insert into prc_container (id, container_process_id, process_id, exec_order, is_parallel, error_limit, track_threshold, parallel_degree) values (10000001, 10000905, 10000874, 10, 0, 1, 100, NULL)
/
insert into prc_container (id, container_process_id, process_id, exec_order, is_parallel, error_limit, track_threshold, parallel_degree) values (10000002, 10000905, 10000899, 20, 0, 1, 100, NULL)
/
insert into prc_container (id, container_process_id, process_id, exec_order, is_parallel, error_limit, track_threshold, parallel_degree) values (10000003, 10000906, 10000904, 10, 0, 1, 100, NULL)
/
insert into prc_container (id, container_process_id, process_id, exec_order, is_parallel, error_limit, track_threshold, parallel_degree) values (10000004, 10000906, 10000026, 20, 0, 1, 100, NULL)
/
insert into prc_container (id, container_process_id, process_id, exec_order, is_parallel, error_limit, track_threshold, parallel_degree) values (10000005, 10000907, 10000891, 10, 0, 1, 100, NULL)
/
insert into prc_container (id, container_process_id, process_id, exec_order, is_parallel, error_limit, track_threshold, parallel_degree) values (10000006, 10000907, 10000892, 20, 0, 1, 100, NULL)
/
delete prc_container where id = 10000003
/
delete prc_container where id = 10000004
/
insert into prc_container (id, container_process_id, process_id, exec_order, is_parallel, error_limit, track_threshold, parallel_degree) values (10000003, 10000906, 10000933, 10, 0, 1, 100, NULL)
/
insert into prc_container (id, container_process_id, process_id, exec_order, is_parallel, error_limit, track_threshold, parallel_degree, stop_on_fatal) values (10000010, 10000944, 10000943, 10, 0, 1, 100, NULL, 0)
/
insert into prc_container (id, container_process_id, process_id, exec_order, is_parallel, error_limit, track_threshold, parallel_degree, stop_on_fatal) values (10000012, 10000945, 10000900, 10, 0, 1, 100, NULL, 0)
/
update prc_container set exec_order=20 where id=10000001
/
update prc_container set exec_order=10 where id=10000002
/
insert into prc_container (id, container_process_id, process_id, exec_order, is_parallel, error_limit, track_threshold, parallel_degree, stop_on_fatal) values (10000016, 10000905, 10000951, 15, 0, 1, 100, NULL, 0)
/
insert into prc_container (id, container_process_id, process_id, exec_order, is_parallel, error_limit, track_threshold, parallel_degree, stop_on_fatal) values (10000017, 10000905, 10000952, 25, 0, 1, 100, NULL, 0)
/
delete prc_container where id = 10000022
/
insert into prc_container (id, container_process_id, process_id, exec_order, is_parallel, error_limit, track_threshold, parallel_degree, stop_on_fatal, trace_level, debug_writing_mode, start_trace_size, error_trace_size) values (10000022, 10001017, 10000898, 10, 0, 1, 1, NULL, 1, 6, 'LGMDIMDT', NULL, NULL)
/

