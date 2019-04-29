create or replace package com_ui_flex_field_standard_pkg is

procedure add_flex_field_standard(
    i_standard_id        in     com_api_type_pkg.t_tiny_id
  , i_field_id           in     com_api_type_pkg.t_short_id
  , o_id                    out com_api_type_pkg.t_short_id
  , o_seqnum                out com_api_type_pkg.t_seqnum
);

procedure modify_flex_field_standard(
    i_id                 in     com_api_type_pkg.t_short_id
  , i_standard_id        in     com_api_type_pkg.t_tiny_id
  , i_field_id           in     com_api_type_pkg.t_short_id
  , io_seqnum            in out com_api_type_pkg.t_seqnum
);

procedure remove_flex_field_standard(
    i_id                 in     com_api_type_pkg.t_short_id
);

end com_ui_flex_field_standard_pkg;
/
