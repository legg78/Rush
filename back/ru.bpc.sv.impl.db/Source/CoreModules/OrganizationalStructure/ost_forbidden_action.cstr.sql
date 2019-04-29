create unique index ost_forbidden_action_pk on ost_forbidden_action(id)
/

alter table ost_forbidden_action add (constraint ost_forbidden_action_pk primary key(id))
/

alter table ost_forbidden_action add (constraint ost_forbidden_action_uk unique(inst_status, data_action))
/
