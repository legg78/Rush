create or replace package aup_api_tag_pkg is

function find_tag_by_reference(
    i_reference             in     com_api_type_pkg.t_name
  , i_mask_error            in     com_api_type_pkg.t_boolean         default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id;

function get_tag_value(
    i_auth_id               in     com_api_type_pkg.t_long_id
  , i_tag_id                in     com_api_type_pkg.t_short_id   -- equal to aup_tag.tag
  , i_seq_number            in     com_api_type_pkg.t_short_id        default null
) return com_api_type_pkg.t_full_desc;

function get_tag_value(
    i_auth_id               in     com_api_type_pkg.t_long_id
  , i_tag_reference         in     com_api_type_pkg.t_name
  , i_seq_number            in     com_api_type_pkg.t_short_id        default null
) return com_api_type_pkg.t_full_desc;

procedure get_tag_value(
    i_auth_id               in      com_api_type_pkg.t_long_id
  , i_seq_number            in      com_api_type_pkg.t_tiny_id        default null
  , o_aup_tag_tab              out  aup_api_type_pkg.t_aup_tag_tab
);

procedure save_tag(
    i_auth_id               in     com_api_type_pkg.t_long_id
  , i_tags                  in     aup_api_type_pkg.t_aup_tag_tab
);

procedure save_tag(
    i_auth_id               in     com_api_type_pkg.t_long_id
  , i_tags                  in     aup_tag_value_tpt
);

procedure insert_tag(
    i_auth_id               in     com_api_type_pkg.t_long_id
  , i_tags                  in     aup_api_type_pkg.t_aup_tag_tab
);

procedure copy_tag_value(
    i_source_auth_id        in     com_api_type_pkg.t_long_id
  , i_target_auth_id        in     com_api_type_pkg.t_long_id
);

end;
/
