create or replace package cpn_api_attribute_value_pkg is

function get_attribute_value_id(
    i_campaign_id          in     com_api_type_pkg.t_short_id
  , i_entity_type          in     com_api_type_pkg.t_dict_value
  , i_object_id            in     com_api_type_pkg.t_long_id
  , i_split_hash           in     com_api_type_pkg.t_tiny_id       default null
) return com_api_type_pkg.t_medium_tab;

procedure add_attribute_value(
    i_campaign             in     cpn_api_type_pkg.t_campaign_rec
  , i_entity_type          in     com_api_type_pkg.t_dict_value
  , i_object_id            in     com_api_type_pkg.t_long_id
  , i_split_hash           in     com_api_type_pkg.t_tiny_id       default null
  , i_start_date           in     date
);

procedure update_attribute_value(
    i_id_tab               in     com_api_type_pkg.t_medium_tab
  , i_end_date             in     date
);

end;
/
