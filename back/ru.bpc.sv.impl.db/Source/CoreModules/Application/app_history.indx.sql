create index app_history_appl_id_ndx on app_history (appl_id)
/
create index app_history_status_reject_ndx on app_history (appl_status, reject_code)
/
create index app_history_change_date on app_history (change_date)
/

