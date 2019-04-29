create index prc_session_file_file_name_ndx on prc_session_file(decode(status, 'FLSTACPT', upper(file_name), null))
/

create index prc_sesson_file_sess_id_ndx on prc_session_file(session_id)
/