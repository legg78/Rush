create or replace package prc_api_type_pkg as

type t_sess_file_rec_count is record(
    session_file_id         com_api_type_pkg.t_long_id
  , record_count            com_api_type_pkg.t_short_id
);

type t_sess_file_rec_count_tab is table of t_sess_file_rec_count index by binary_integer;


end;
/