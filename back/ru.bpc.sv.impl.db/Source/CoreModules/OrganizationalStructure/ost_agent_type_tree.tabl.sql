create table ost_agent_type_tree
(
    id                 number(4)
  , seqnum             number(4)
  , agent_type         varchar2(8)
  , parent_agent_type  varchar2(8)
  , inst_id            number(4)
)
/

comment on table ost_agent_type_tree is 'Rules of agent hierarhy.'
/

comment on column ost_agent_type_tree.id is 'Primary key.'
/

comment on column ost_agent_type_tree.seqnum is 'Sequence number. Describe data version.'
/

comment on column ost_agent_type_tree.agent_type is 'Head division type.'
/

comment on column ost_agent_type_tree.parent_agent_type is 'Filiale of head division.'
/

comment on column ost_agent_type_tree.inst_id is 'Institution identifier.'
/