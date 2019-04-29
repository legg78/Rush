create table acq_mcc_selection(
    id            number(12) not null
  , terminal_id   number(8)
  , oper_type     varchar2(8)
  , priority      number(4) not null
  , mcc           varchar2(4)   not null
)
/

comment on table acq_mcc_selection is 'Acquiring MCC selection.'
/

comment on column acq_mcc_selection.id is 'Primary key.'
/
comment on column acq_mcc_selection.terminal_id is 'Reference to terminal'
/
comment on column acq_mcc_selection.oper_type is 'Operation type (cash, sale, payment etc.)'
/
comment on column acq_mcc_selection.priority is 'Oper type priority.'
/
comment on column acq_mcc_selection.mcc is 'Merchant category code.'
/
alter table acq_mcc_selection add (
    mcc_template_id       number(12)
    , purpose_id          number(8)
    , oper_reason         varchar2(8)
    , merchant_name_spec  clob
)
/
comment on column acq_mcc_selection.mcc_template_id is 'MCC template identifier'
/
comment on column acq_mcc_selection.purpose_id is 'Payment purpose'
/
comment on column acq_mcc_selection.oper_reason is 'Operation reason (fee type or adjustment type)'
/
comment on column acq_mcc_selection.merchant_name_spec is 'Merchant name'
/
comment on column acq_mcc_selection.terminal_id is 'Unused column'
/
