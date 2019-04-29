create or replace package cln_api_action_pkg is

procedure add_action(
    o_id                      out com_api_type_pkg.t_long_id
  , o_seqnum                  out com_api_type_pkg.t_seqnum
  , i_case_id              in     com_api_type_pkg.t_long_id
  , i_split_hash           in     com_api_type_pkg.t_short_id
  , i_activity_category    in     com_api_type_pkg.t_dict_value
  , i_activity_type        in     com_api_type_pkg.t_dict_value
  , i_user_id              in     com_api_type_pkg.t_short_id
  , i_action_date          in     date
  , i_eff_date             in     date
  , i_status               in     com_api_type_pkg.t_dict_value
  , i_resolution           in     com_api_type_pkg.t_dict_value
  , i_commentary           in     com_api_type_pkg.t_full_desc
);

procedure modify_action(
    i_id                   in     com_api_type_pkg.t_long_id
  , io_seqnum              in out com_api_type_pkg.t_seqnum
  , i_activity_type        in     com_api_type_pkg.t_dict_value
  , i_user_id              in     com_api_type_pkg.t_short_id
  , i_action_date          in     date
  , i_status               in     com_api_type_pkg.t_dict_value
  , i_resolution           in     com_api_type_pkg.t_dict_value
  , i_commentary           in     com_api_type_pkg.t_full_desc
);

procedure remove_action(
    i_id                   in     com_api_type_pkg.t_long_id
  , i_seqnum               in     com_api_type_pkg.t_seqnum
);

end cln_api_action_pkg;
/
