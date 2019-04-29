alter table ost_agent_type_tree add (
    constraint ost_agent_type_tree_pk primary key (id),
    constraint ost_agent_type_tree_uk unique (parent_agent_type, agent_type, inst_id)
)
/
