create index fcl_cycle_counter_object_ndx on fcl_cycle_counter (object_id, entity_type, cycle_type)
/****************** partition start ********************
    local
******************** partition end ********************/
/

create index fcl_cycle_counter_date_ndx on fcl_cycle_counter (next_date)
/****************** partition start ********************
    local
******************** partition end ********************/
/