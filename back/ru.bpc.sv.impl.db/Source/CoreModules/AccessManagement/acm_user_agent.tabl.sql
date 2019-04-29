create table acm_user_agent(
    id         number(8) not null
  , user_id    number(8) not null
  , agent_id   number(8) not null
  , is_default number(1)
)
/
comment on table acm_user_agent is 'User agents.'
/
comment on column acm_user_agent.id is 'Primary key.'
/
comment on column acm_user_agent.user_id is 'Reference to user.'
/
comment on column acm_user_agent.agent_id is 'Reference to agent.'
/
comment on column acm_user_agent.is_default is 'Deafault agent flag.'
/
