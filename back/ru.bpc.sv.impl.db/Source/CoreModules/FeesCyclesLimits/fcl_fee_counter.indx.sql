create index fcl_fee_counter_main_ndx on fcl_fee_counter
(fee_type, entity_type, object_id, nvl2("END_DATE",1,0))
/