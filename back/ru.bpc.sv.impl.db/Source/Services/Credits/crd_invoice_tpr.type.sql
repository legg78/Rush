create or replace type crd_invoice_tpr as object (
    id                  number(12)
  , account_id          number(12)
  , serial_number       number(4)
  , invoice_type        varchar2(8)
  , exceed_limit        number(22,4)
  , total_amount_due    number(22,4)
  , own_funds           number(22,4)
  , min_amount_due      number(22,4)
  , invoice_date        date
  , grace_date          date
  , due_date            date
  , penalty_date        date
  , aging_period        number(4)
  , is_tad_paid         number(1)
  , is_mad_paid         number(1)
  , inst_id             number(4)
  , agent_id            number(8)
  , split_hash          number(4)
)
/
