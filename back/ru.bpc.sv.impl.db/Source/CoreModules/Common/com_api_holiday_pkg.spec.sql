create or replace package com_api_holiday_pkg as

function is_holiday(
    i_day               in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_boolean;

function get_prev_working_day (
    i_day               in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) return date;

function get_next_working_day (
    i_day               in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) return date;

function get_shifted_working_day(
    i_day               in      date
  , i_forward           in      com_api_type_pkg.t_boolean
  , i_day_shift         in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) return date;

end;
/
