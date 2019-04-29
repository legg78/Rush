begin
insert into fcl_cycle_counter (id, entity_type, object_id, cycle_type, prev_date, next_date, period_number, split_hash, inst_id) select fcl_cycle_counter_seq.nextval, entity_type, object_id, 'CYTP1008', prev_date, next_date, period_number, split_hash, inst_id from fcl_cycle_counter where cycle_type = 'CYTP1004' and next_date is not null;
end;
