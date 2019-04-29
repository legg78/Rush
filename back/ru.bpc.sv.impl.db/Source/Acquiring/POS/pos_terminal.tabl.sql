create table pos_terminal
(
  id                number(8),
  current_batch_id  number(12)
)
/
comment on table pos_terminal is 'POS terminal specific parameters.'
/
comment on column pos_terminal.id is 'POS terminal identifier.'
/
comment on column pos_terminal.current_batch_id is 'Current batch identifier.'
/

alter table pos_terminal add (pos_batch_method  varchar2(8))
/
alter table pos_terminal add (partial_approval  number)
/
alter table pos_terminal add (purchase_amount  number)
/

comment on column pos_terminal.pos_batch_method is 'POS batch using methods'
/
comment on column pos_terminal.partial_approval is 'Partial Approval Terminal Support Indicator'
/
comment on column pos_terminal.purchase_amount is 'Purchase Amount Only Terminal Support Indicator'
/
alter table pos_terminal add instalment_support number(1)
/
comment on column pos_terminal.instalment_support is 'Instalment Terminal Support Indicator'
/

