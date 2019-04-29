create or replace package body cln_ui_action_pkg is

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
) is
    l_split_hash    com_api_type_pkg.t_short_id;
    l_sysdate       date;

begin
    l_split_hash := coalesce(i_split_hash, com_api_hash_pkg.get_split_hash(
                                               i_entity_type  => cln_api_const_pkg.ENTITY_TYPE_COLLECTION_CASE
                                             , i_object_id    => i_case_id
                                           )
                    );

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;
    cln_api_action_pkg.add_action(
        o_id                 => o_id
      , o_seqnum             => o_seqnum
      , i_case_id            => i_case_id
      , i_split_hash         => l_split_hash
      , i_activity_category  => i_activity_category
      , i_activity_type      => i_activity_type
      , i_user_id            => nvl(i_user_id, get_user_id) 
      , i_action_date        => nvl(i_action_date, l_sysdate)
      , i_eff_date           => nvl(i_eff_date, l_sysdate)
      , i_status             => i_status
      , i_resolution         => i_resolution
      , i_commentary         => i_commentary
    );

end add_action;

procedure modify_action(
    i_id                   in     com_api_type_pkg.t_long_id
  , io_seqnum              in out com_api_type_pkg.t_seqnum
  , i_activity_type        in     com_api_type_pkg.t_dict_value
  , i_user_id              in     com_api_type_pkg.t_short_id
  , i_action_date          in     date
  , i_status               in     com_api_type_pkg.t_dict_value
  , i_resolution           in     com_api_type_pkg.t_dict_value
  , i_commentary           in     com_api_type_pkg.t_full_desc
) is
begin
    cln_api_action_pkg.modify_action(
        i_id                => i_id
      , io_seqnum           => io_seqnum
      , i_activity_type     => i_activity_type
      , i_user_id           => nvl(i_user_id, get_user_id) 
      , i_action_date       => nvl(i_action_date, com_api_sttl_day_pkg.get_sysdate)
      , i_status            => i_status
      , i_resolution        => i_resolution
      , i_commentary        => i_commentary
    );

end modify_action;

procedure remove_action(
    i_id                   in     com_api_type_pkg.t_long_id
  , i_seqnum               in     com_api_type_pkg.t_seqnum
) is
begin
    cln_api_action_pkg.remove_action(
        i_id               => i_id
      , i_seqnum           => i_seqnum
    );

end remove_action;

end cln_ui_action_pkg;
/
