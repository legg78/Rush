create or replace package acc_prc_member_export is

procedure unload_member_turnover(
    i_mbr_version         in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_date_type           in     com_api_type_pkg.t_dict_value
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
  , i_start_date          in     date                             default null
  , i_end_date            in     date                             default null
  , i_array_trans_type_id in     com_api_type_pkg.t_medium_id     default null
  , i_array_settl_type_id in     com_api_type_pkg.t_medium_id     default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
);

end;
/
