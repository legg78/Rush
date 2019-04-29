alter table vis_bin_range add (constraint vis_bin_range_pk primary key (pan_low, pan_high))
/
alter table vis_bin_range drop constraint vis_bin_range_pk
/
alter table vis_bin_range add (constraint vis_bin_range_pk primary key (pan_low, pan_high, pan_length))
/
