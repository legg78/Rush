create or replace force view acq_ui_account_customer_vw as
select
    customer_id
  , scheme_id
from acq_account_customer
/
