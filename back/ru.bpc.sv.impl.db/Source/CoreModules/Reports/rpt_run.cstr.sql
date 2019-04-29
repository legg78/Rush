alter table rpt_run add constraint rpt_run_uk unique(run_hash) using index    -- [@skip patch]
/
alter table rpt_run add constraint rpt_run_pk primary key (id) using index    -- [@skip patch]
/
