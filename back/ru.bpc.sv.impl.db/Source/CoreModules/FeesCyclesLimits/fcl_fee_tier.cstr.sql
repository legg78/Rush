alter table fcl_fee_tier add (constraint fcl_fee_tier_pk primary key(id))
/
alter table fcl_fee_tier add constraint fcl_fee_tier_uk unique (fee_id, sum_threshold, count_threshold)
/
