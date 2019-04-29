create or replace package itf_dwh_prc_card_export_pkg as

procedure export_cards_status(
    i_dwh_version         in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
);

procedure export_cards_numbers(
    i_dwh_version         in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
);

end;
/
