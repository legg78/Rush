create or replace package com_ui_holiday_pkg as

procedure add_state_holday(
    o_state_holiday_id     out  com_api_type_pkg.t_tiny_id
  , i_cycle_id          in      com_api_type_pkg.t_short_id
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
);

procedure modify_state_holday(
    i_state_holiday_id  in      com_api_type_pkg.t_tiny_id
  , i_cycle_id          in      com_api_type_pkg.t_short_id         default null
  , i_short_desc        in      com_api_type_pkg.t_short_desc       default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
);

procedure remove_state_holday(
    i_state_holiday_id  in      com_api_type_pkg.t_tiny_id
);

procedure add_remove_holiday(
    i_holiday_date      in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
);

end;
/