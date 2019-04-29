create or replace force view aut_ui_queue_vw as
select
    auth_id
  , host_id
  , channel_id
  , is_advice_needed
  , is_reversal_needed
  , send_count
  , max_send_count
  , send_status
  from aut_queue
/

