create index app_application_appl_num_ndx on app_application (appl_number)
/
create index app_application_flw_st_rj_ndx on app_application (flow_id, appl_status, reject_code)
/
create index app_application_user_id_ndx on app_application (user_id)
/
create index app_application_APST0006_ndx on app_application (decode(appl_status, 'APST0006', 'APST0006', null))
/
