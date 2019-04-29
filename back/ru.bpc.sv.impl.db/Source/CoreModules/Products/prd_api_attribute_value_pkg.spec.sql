create or replace package prd_api_attribute_value_pkg is

procedure set_attr_value_num (
    io_id               in out  com_api_type_pkg.t_medium_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_start_date        in      date     default null
  , i_end_date          in      date
  , i_value             in      number
  , i_check_start_date  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_inst_id           in      com_api_type_pkg.t_inst_id    default null
  , i_campaign_id       in      com_api_type_pkg.t_short_id   default null
);

procedure set_attr_value_date (
    io_id              in out  com_api_type_pkg.t_medium_id
  , i_service_id       in      com_api_type_pkg.t_short_id
  , i_entity_type      in      com_api_type_pkg.t_dict_value
  , i_object_id        in      com_api_type_pkg.t_long_id
  , i_attr_name        in      com_api_type_pkg.t_name
  , i_mod_id           in      com_api_type_pkg.t_tiny_id
  , i_start_date       in      date     default null
  , i_end_date         in      date
  , i_value            in      date
  , i_check_start_date in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_inst_id          in      com_api_type_pkg.t_inst_id    default null
  , i_campaign_id      in      com_api_type_pkg.t_short_id   default null
);

procedure set_attr_value_char (
    io_id              in out  com_api_type_pkg.t_medium_id
  , i_service_id       in      com_api_type_pkg.t_short_id
  , i_entity_type      in      com_api_type_pkg.t_dict_value
  , i_object_id        in      com_api_type_pkg.t_long_id
  , i_attr_name        in      com_api_type_pkg.t_name
  , i_mod_id           in      com_api_type_pkg.t_tiny_id
  , i_start_date       in      date     default null
  , i_end_date         in      date
  , i_value            in      com_api_type_pkg.t_text
  , i_check_start_date in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_inst_id          in      com_api_type_pkg.t_inst_id    default null
  , i_campaign_id      in      com_api_type_pkg.t_short_id   default null
);

procedure set_attr_value_fee (
    io_attr_value_id   in out  com_api_type_pkg.t_medium_id
  , i_service_id       in      com_api_type_pkg.t_short_id
  , i_entity_type      in      com_api_type_pkg.t_dict_value
  , i_object_id        in      com_api_type_pkg.t_long_id
  , i_attr_name        in      com_api_type_pkg.t_name
  , i_mod_id           in      com_api_type_pkg.t_tiny_id
  , i_start_date       in      date     default null
  , i_end_date         in      date
  , i_fee_id           in      com_api_type_pkg.t_short_id
  , i_check_start_date in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_inst_id          in      com_api_type_pkg.t_inst_id    default null   
  , i_campaign_id      in      com_api_type_pkg.t_short_id   default null
);

procedure set_attr_value_cycle (
    io_attr_value_id   in out  com_api_type_pkg.t_medium_id
  , i_service_id       in      com_api_type_pkg.t_short_id
  , i_entity_type      in      com_api_type_pkg.t_dict_value
  , i_object_id        in      com_api_type_pkg.t_long_id
  , i_attr_name        in      com_api_type_pkg.t_name
  , i_mod_id           in      com_api_type_pkg.t_tiny_id
  , i_start_date       in      date     default null
  , i_end_date         in      date
  , i_cycle_id         in      com_api_type_pkg.t_short_id
  , i_check_start_date in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_inst_id          in      com_api_type_pkg.t_inst_id    default null   
  , i_campaign_id      in      com_api_type_pkg.t_short_id   default null
);

procedure set_attr_value_limit (
    io_attr_value_id   in out  com_api_type_pkg.t_medium_id
  , i_service_id       in      com_api_type_pkg.t_short_id
  , i_entity_type      in      com_api_type_pkg.t_dict_value
  , i_object_id        in      com_api_type_pkg.t_long_id
  , i_attr_name        in      com_api_type_pkg.t_name
  , i_mod_id           in      com_api_type_pkg.t_tiny_id
  , i_start_date       in      date                          default null
  , i_end_date         in      date
  , i_limit_id         in      com_api_type_pkg.t_long_id
  , i_check_start_date in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_inst_id          in      com_api_type_pkg.t_inst_id    default null   
  , i_is_cyclic        in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_campaign_id      in      com_api_type_pkg.t_short_id   default null
);

procedure set_attr_value(
    io_id               in out  com_api_type_pkg.t_medium_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_start_date        in      date     default null
  , i_end_date          in      date
  , i_value_num         in      number
  , i_value_char        in      com_api_type_pkg.t_text
  , i_value_date        in      date
  , i_data_type         in      com_api_type_pkg.t_dict_value
  , i_check_start_date  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_inst_id           in      com_api_type_pkg.t_inst_id    default null
  , i_campaign_id       in      com_api_type_pkg.t_short_id   default null
);

end;
/
