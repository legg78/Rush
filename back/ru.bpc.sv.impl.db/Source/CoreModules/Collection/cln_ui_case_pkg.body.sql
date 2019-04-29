create or replace package body cln_ui_case_pkg is

procedure add_case(
    o_id                    out com_api_type_pkg.t_long_id
  , o_seqnum                out com_api_type_pkg.t_seqnum
  , i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_split_hash         in     com_api_type_pkg.t_short_id      default null
  , i_case_number        in     com_api_type_pkg.t_name
  , i_creation_date      in     date                             default null
  , i_customer_id        in     com_api_type_pkg.t_medium_id
  , i_status             in     com_api_type_pkg.t_dict_value    default null
  , i_resolution         in     com_api_type_pkg.t_dict_value    default null
) is
    l_action_id                 com_api_type_pkg.t_long_id;
    l_split_hash                com_api_type_pkg.t_short_id;
    l_status                    com_api_type_pkg.t_dict_value;
    l_sysdate                   date;
    l_creation_date             date;

begin
    trc_log_pkg.debug(
        i_text        => 'cln_ui_case_pkg.add_case Start: i_inst_id=' || i_inst_id || ', i_split_hash=' || i_split_hash ||
                         ', i_case_number=' || i_case_number || ', i_creation_date=' || to_char(i_creation_date, com_api_const_pkg.LOG_DATE_FORMAT) ||
                         ', i_customer_id=' || i_customer_id || ', i_status=' || i_status || ', i_resolution=' || i_resolution
    );

    l_split_hash := coalesce(i_split_hash, com_api_hash_pkg.get_split_hash(
                                               i_entity_type  => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                             , i_object_id    => i_customer_id
                                           )
                    );

    l_sysdate       := com_api_sttl_day_pkg.get_sysdate;
    l_creation_date := nvl(i_creation_date, l_sysdate);
    l_status        := nvl(i_status, cln_api_const_pkg.COLLECTION_CASE_STATUS_NEW);

    cln_api_case_pkg.add_case(
        o_id               => o_id
      , o_seqnum           => o_seqnum
      , i_inst_id          => i_inst_id
      , i_split_hash       => l_split_hash
      , i_case_number      => i_case_number
      , i_creation_date    => l_creation_date
      , i_customer_id      => i_customer_id
      , i_user_id          => get_user_id -- Case is created manually, so send user_id = Current user
      , i_status           => l_status
      , i_resolution       => null
    );

    cln_api_action_pkg.add_action(
        o_id                => l_action_id
      , o_seqnum            => o_seqnum
      , i_case_id           => o_id
      , i_split_hash        => l_split_hash
      , i_activity_category => cln_api_const_pkg.COLL_ACTIVITY_CATEG_COLLECTOR
      , i_activity_type     => cln_api_const_pkg.EVENT_TYPE_CASE_CREATED
      , i_user_id           => get_user_id -- Case is created manually, so send user_id = Current user
      , i_action_date       => l_creation_date
      , i_eff_date          => l_sysdate
      , i_status            => l_status
      , i_resolution        => i_resolution
      , i_commentary        => null
    );

    trc_log_pkg.debug(
        i_text        => 'cln_ui_case_pkg.add_case Finished'
    );

end add_case;

procedure modify_case(
    i_id                 in     com_api_type_pkg.t_long_id
  , io_seqnum            in out com_api_type_pkg.t_seqnum
  , i_status             in     com_api_type_pkg.t_dict_value
  , i_resolution         in     com_api_type_pkg.t_dict_value
) is
    l_eff_date                  date;
    l_action_id                 com_api_type_pkg.t_long_id;
    l_split_hash                com_api_type_pkg.t_short_id;
    l_case_rec                  cln_api_type_pkg.t_case_rec;
    l_param_tab                 com_api_type_pkg.t_param_tab;

begin
    trc_log_pkg.debug(
        i_text        => 'cln_ui_case_pkg.modify_case Start: i_id=' || i_id || ', io_seqnum=' || io_seqnum ||
                         ', i_status=' || i_status || ', i_resolution=' || i_resolution
    );

    if cln_api_case_pkg.check_case_not_closed(i_id => i_id) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_error(
            i_error      => 'COLLECTION_CASE_NOT_CLOSED'
          , i_env_param1 => i_id
        );
    end if;

    l_eff_date := com_api_sttl_day_pkg.get_sysdate;
    l_case_rec := cln_api_case_pkg.get_case(i_id  => i_id);

    cln_api_case_pkg.modify_case(
        i_id           => i_id
      , io_seqnum      => io_seqnum
      , i_user_id      => get_user_id -- Case is created manually, so send user_id = Current user
      , i_status       => i_status
      , i_resolution   => i_resolution
    );

    l_split_hash := com_api_hash_pkg.get_split_hash(
                        i_entity_type  => cln_api_const_pkg.ENTITY_TYPE_COLLECTION_CASE
                      , i_object_id    => i_id
                    );

    cln_api_action_pkg.add_action(
        o_id                => l_action_id
      , o_seqnum            => io_seqnum
      , i_case_id           => i_id
      , i_split_hash        => l_split_hash
      , i_activity_category => cln_api_const_pkg.COLL_ACTIVITY_CATEG_COLLECTOR
      , i_activity_type     => cln_api_const_pkg.EVENT_TYPE_CASE_MODIFIED
      , i_user_id           => get_user_id -- Case is created manually, so send user_id = Current user
      , i_action_date       => l_eff_date
      , i_eff_date          => l_eff_date
      , i_status            => i_status
      , i_resolution        => i_resolution
      , i_commentary        => null
    );

    evt_api_event_pkg.register_event(
        i_event_type      => cln_api_const_pkg.EVENT_TYPE_CASE_MODIFIED
      , i_eff_date        => l_eff_date
      , i_entity_type     => cln_api_const_pkg.ENTITY_TYPE_COLLECTION_CASE
      , i_object_id       => i_id
      , i_inst_id         => l_case_rec.inst_id
      , i_split_hash      => l_split_hash
      , i_param_tab       => l_param_tab
    );

    trc_log_pkg.debug(
        i_text        => 'cln_ui_case_pkg.modify_case Finished'
    );

end modify_case;

procedure assign_user(
    i_case_id            in     com_api_type_pkg.t_long_id
  , i_user_id            in     com_api_type_pkg.t_long_id
  , i_comments           in     com_api_type_pkg.t_full_desc
)
is
    l_seqnum                    com_api_type_pkg.t_seqnum;
    l_id                        com_api_type_pkg.t_long_id;
    l_date                      date := get_sysdate;
begin
    trc_log_pkg.debug('cln_ui_case_pkg.assign_user START');
    
    cln_api_case_pkg.modify_case(
        i_id         => i_case_id
      , io_seqnum    => l_seqnum
      , i_user_id    => i_user_id
      , i_status     => null
      , i_resolution => null
    );
    l_seqnum := 1;

    cln_api_action_pkg.add_action(
        o_id                => l_id
      , o_seqnum            => l_seqnum
      , i_case_id           => i_case_id
      , i_split_hash        => com_api_hash_pkg.get_split_hash(acm_api_const_pkg.ENTITY_TYPE_USER,i_user_id)
      , i_activity_category => cln_api_const_pkg.COLL_ACTIVITY_CATEG_SYSTEM
      , i_activity_type     => cln_api_const_pkg.EVENT_TYPE_CASE_REASSIGNED
      , i_user_id           => i_user_id
      , i_action_date       => l_date
      , i_eff_date          => l_date
      , i_status            => cln_api_const_pkg.COLLECTION_CASE_STATUS_NEW
      , i_resolution        => null
      , i_commentary        => i_comments
    );
    
    trc_log_pkg.debug('cln_ui_case_pkg.assign_user FINISHED');
end;

end cln_ui_case_pkg;
/
