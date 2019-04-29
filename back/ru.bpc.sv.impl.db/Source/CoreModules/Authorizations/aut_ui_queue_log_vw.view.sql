create or replace force view aut_ui_queue_log_vw as
select
    id
  , auth_id
  , host_id
  , channel_id
  , is_advice_needed
  , is_reversal_needed
  , send_count
  , max_send_count
  , send_status
  , log_date
  , description
  from aut_queue_log
/

