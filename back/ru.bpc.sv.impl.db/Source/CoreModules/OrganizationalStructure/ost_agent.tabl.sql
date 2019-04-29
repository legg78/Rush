create table ost_agent
(
    id                number(8)
  , inst_id           number(4)
  , seqnum            number(4)
  , parent_id         number(8)
  , agent_type        varchar2(8)
  , is_default        number(1)
)
/

comment on table ost_agent is 'Agents. Institution''s subdivisions.'
/

comment on column ost_agent.id is 'Primary key.'
/

comment on column ost_agent.seqnum is 'Sequence number. Describe data version.'
/

comment on column ost_agent.inst_id is 'Referenece to institution.'
/

comment on column ost_agent.parent_id is 'Reference to parent agent.'
/

comment on column ost_agent.agent_type is 'Agent type. Describe level and/or size of subdivision.'
/

comment on column ost_agent.is_default is 'Default agent flag. If true agent using in processing if exact agent not defined but needed. Could be only one default agent for one institution.'
/

alter table ost_agent add(agent_number varchar2(200))
/
comment on column ost_agent.agent_number is 'External agent number'
/
