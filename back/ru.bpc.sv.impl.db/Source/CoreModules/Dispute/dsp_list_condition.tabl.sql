create table dsp_list_condition (
    id              number(4) not null
    , init_rule     number(8)
    , gen_rule      number(8)
    , func_order    number(4)
    , mod_id        number(4)
)
/
comment on table dsp_list_condition is 'Dispute list condition'
/
comment on column dsp_list_condition.id is 'Primary key'
/
comment on column dsp_list_condition.init_rule is 'Initialization rule'
/
comment on column dsp_list_condition.gen_rule is 'Generation rule'
/
comment on column dsp_list_condition.func_order is 'Order within function'
/
comment on column dsp_list_condition.mod_id is 'Modifier identifier'
/
alter table dsp_list_condition add is_online number(1)
/
comment on column dsp_list_condition.is_online is 'Online/offline dispute'
/
alter table dsp_list_condition add msg_type varchar2(8 char)
/
comment on column dsp_list_condition.msg_type is 'Message type (MSGT dictionary)'
/
