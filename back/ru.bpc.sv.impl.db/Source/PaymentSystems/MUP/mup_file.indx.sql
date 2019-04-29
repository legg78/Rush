create index mup_file_visa_ndx on mup_file (proc_date, visa_file_id, proc_bin)
/
create index mup_file_proc_date_ndx on mup_file (proc_date)
/
drop index mup_file_visa_ndx
/
