create unique index ost_agent_pk on ost_agent(id)
/

alter table ost_agent add (constraint ost_agent_pk primary key(id))
/

alter table ost_agent add (constraint ost_agent_uk unique (agent_number, inst_id))
/
