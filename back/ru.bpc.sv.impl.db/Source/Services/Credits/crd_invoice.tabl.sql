create table crd_invoice (
    id                  number(12)
    , account_id        number(12)
    , serial_number     number(4)
    , invoice_type      varchar2(8)
    , exceed_limit      number(22,4)
    , total_amount_due  number(22,4)
    , own_funds         number(22,4)
    , min_amount_due    number(22,4)
    , start_date        date
    , invoice_date      date
    , grace_date        date
    , due_date          date
    , penalty_date      date
    , aging_period      number(4)
    , is_tad_paid       number(1)
    , is_mad_paid       number(1)
    , inst_id           number(4)
    , agent_id          number(8)
    , split_hash        number(4)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table crd_invoice is 'Credit invoices.'
/
comment on column crd_invoice.id is 'Primary key.'
/
comment on column crd_invoice.account_id is 'Account identifier.'
/
comment on column crd_invoice.serial_number is 'Serial number of invoice for exact account.'
/
comment on column crd_invoice.invoice_type is 'Invoice type'
/
comment on column crd_invoice.exceed_limit is 'Current exceed limit value.'
/
comment on column crd_invoice.total_amount_due is 'Total amount due.'
/
comment on column crd_invoice.own_funds is 'Amount of own funds.'
/
comment on column crd_invoice.min_amount_due is 'Minimum amount due.'
/
comment on column crd_invoice.start_date is 'Billing period start date.'
/
comment on column crd_invoice.invoice_date is 'Invoice create date.'
/
comment on column crd_invoice.grace_date is 'Date of ending of grace period.'
/
comment on column crd_invoice.due_date is 'Due date.'
/
comment on column crd_invoice.penalty_date is 'Date when penalty provision will apply in case minimum amount is not paid.'
/
comment on column crd_invoice.aging_period is 'Number of aging period.'
/
comment on column crd_invoice.is_tad_paid is 'Is total amount paid in grace period.'
/
comment on column crd_invoice.is_mad_paid is 'Is minimum amount paid in due date.'
/
comment on column crd_invoice.inst_id is 'Insitution identifier.'
/
comment on column crd_invoice.agent_id is 'Agent identifier.'
/
comment on column crd_invoice.split_hash is 'Hash value to split further processing.'
/

alter table crd_invoice add overlimit_amount number(22,4)
/
comment on column crd_invoice.overlimit_amount is 'Amount of overlimit balance.'
/
alter table crd_invoice add overdue_amount number(22,4)
/
comment on column crd_invoice.overdue_amount is 'Amount of overdue balance.'
/
alter table crd_invoice add overdue_intr_amount number(22,4)
/
comment on column crd_invoice.overdue_intr_amount is 'Amount of overdue interest balance.'
/
alter table crd_invoice add overdraft_amount number(22,4)
/
comment on column crd_invoice.overdraft_amount is 'Amount of overdraft balance.'
/
alter table crd_invoice add hold_amount number(22,4)
/
comment on column crd_invoice.hold_amount is 'Amount of hold balance.'
/
alter table crd_invoice add available_amount number(22,4)
/
comment on column crd_invoice.available_amount is 'Amount of available balance.'
/
alter table crd_invoice add postal_code varchar2(10)
/
comment on column crd_invoice.postal_code is 'Postal code.'
/
alter table crd_invoice add agent_number varchar2(200)
/
comment on column crd_invoice.agent_number is 'Agent number.'
/
alter table crd_invoice add overdue_date date
/
comment on column crd_invoice.overdue_date is 'Overdue date.'
/

alter table crd_invoice rename column overlimit_amount to overlimit_balance
/
alter table crd_invoice rename column overdue_amount to overdue_balance
/
alter table crd_invoice rename column overdue_intr_amount to overdue_intr_balance
/
alter table crd_invoice rename column overdraft_amount to overdraft_balance
/
alter table crd_invoice rename column hold_amount to hold_balance
/
alter table crd_invoice rename column available_amount to available_balance
/
alter table crd_invoice add interest_balance number(22,4)
/
comment on column crd_invoice.interest_balance is 'Total interest balance.'
/
alter table crd_invoice add interest_amount number(22,4)
/
comment on column crd_invoice.interest_amount is 'Interest amount charged in last period.'
/
alter table crd_invoice add payment_amount number(22,4)
/
comment on column crd_invoice.payment_amount is 'Payments amount made in last period.'
/
alter table crd_invoice add expense_amount number(22,4)
/
comment on column crd_invoice.expense_amount is 'Debit operations amount made in last period.'
/
alter table crd_invoice add fee_amount number(22,4)
/
comment on column crd_invoice.fee_amount is 'Fees charged in last period.'
/
alter table crd_invoice add last_entry_id number(16)
/
comment on column crd_invoice.last_entry_id is 'Last entry by account.'
/
alter table crd_invoice drop column last_entry_id
/
alter table crd_invoice add last_entry_timestamp timestamp
/
comment on column crd_invoice.last_entry_timestamp is 'Last entry timestamp by account.'
/
alter table crd_invoice drop column last_entry_timestamp
/
alter table crd_invoice add last_entry_id number(16)
/
comment on column crd_invoice.last_entry_id is 'Last entry by account.'
/
alter table crd_invoice add irr number(22, 4)
/
alter table crd_invoice add apr number(22, 4)
/
comment on column crd_invoice.irr is 'Internal rate of return (IRR).'
/
comment on column crd_invoice.apr is 'Annual Percentage Rate (APR).'
/
alter table crd_invoice add waive_interest_amount number(22, 4)
/
comment on column crd_invoice.waive_interest_amount is 'Interest amount waived in last period.'
/

