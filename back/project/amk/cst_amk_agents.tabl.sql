create table cst_amk_agents (
    id                        number(12)
  , split_hash                number(4)
  , agent_type                varchar2(8)
  , agent_account_number      varchar2(32)
  , inst_id                   number(4)
  , agent_id                  varchar2(12) 
  , agent_name                varchar2(200)
  , currency                  varchar2(3)
  , awarding_amount           number(22, 4)
  , open_date                 date 
  , account_id                number(12)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table cst_amk_agents is 'Agents with awarding are stored here.'
/
comment on column cst_amk_agents.id is 'Primary key.'
/
comment on column cst_amk_agents.split_hash is 'Hash value to split further processing'
/
comment on column cst_amk_agents.agent_type is 'Agent type (SAP or SSAP).'
/
comment on column cst_amk_agents.agent_account_number is 'Agent account number.'
/
comment on column cst_amk_agents.inst_id is 'Institution which owns agent.'
/
comment on column cst_amk_agents.agent_id is 'Agent which owns account.'
/
comment on column cst_amk_agents.agent_name is 'Agent name.'
/
comment on column cst_amk_agents.currency is 'Currency of Agent awarding.'
/
comment on column cst_amk_agents.awarding_amount is 'Agent awarding.'
/
comment on column cst_amk_agents.open_date is 'Date when agent registred new account.'
/
comment on column cst_amk_agents.account_id is 'Customer account identifier.'
/
alter table cst_amk_agents modify (agent_id varchar2(24))
/
alter table cst_amk_agents add (accounts_count number(12))
/
comment on column cst_amk_agents.accounts_count is 'Counts of new accounts concluded by the agent / subagent'
/
alter table cst_amk_agents add (accounts_balances number(22, 4))
/
comment on column cst_amk_agents.accounts_balances is 'Available balance of new accounts concluded by the agent / subagent'
/
alter table cst_amk_agents add (bonus number(22, 4))
/
comment on column cst_amk_agents.bonus is 'Bonus for agent / subagent'
/
