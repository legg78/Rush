create or replace package net_ui_device_pkg is

procedure add (
    i_host_member_id    in      com_api_type_pkg.t_tiny_id 
  , i_device_id         in      com_api_type_pkg.t_short_id
);

procedure remove (
    i_device_id         in      com_api_type_pkg.t_short_id
);

procedure remove_device (
    i_host_member_id    in      com_api_type_pkg.t_tiny_id
);

end; 
/
