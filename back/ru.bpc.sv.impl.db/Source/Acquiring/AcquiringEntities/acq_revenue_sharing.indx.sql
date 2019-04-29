create index acq_revenue_shar_customer_ndx on acq_revenue_sharing(customer_id)
/

create index acq_revenue_shar_terminal_ndx on acq_revenue_sharing(terminal_id)
/

drop index acq_revenue_shar_customer_ndx
/
drop index acq_revenue_shar_terminal_ndx
/

create index acq_revenue_shar_customer_ndx on acq_revenue_sharing(nvl(customer_id, 0))
/
create index acq_revenue_shar_provider_ndx on acq_revenue_sharing(nvl(provider_id, 0))
/
create index acq_revenue_shar_terminal_ndx on acq_revenue_sharing(nvl(terminal_id, 0))
/
create index acq_revenue_shar_purpose_ndx on acq_revenue_sharing(nvl(purpose_id, 0))
/
create index acq_revenue_shar_fee_type_ndx on acq_revenue_sharing(fee_type)
/
drop index acq_revenue_shar_provider_ndx
/
drop index acq_revenue_shar_terminal_ndx
/
create index acq_revenue_shar_terminal_ndx on acq_revenue_sharing(terminal_id)
/

