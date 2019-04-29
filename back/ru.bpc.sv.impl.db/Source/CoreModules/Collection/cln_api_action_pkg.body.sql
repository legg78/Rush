create or replace package body cln_api_action_pkg is

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
begin
    o_id := com_api_id_pkg.get_id(cln_case_seq.nextval, com_api_sttl_day_pkg.get_sysdate);
    o_seqnum := 1;

    insert into cln_action_vw (
        id
      , seqnum
      , case_id
      , split_hash
      , activity_category
      , activity_type
      , user_id
      , action_date
      , eff_date
      , status
      , resolution
      , commentary
    ) values (
        o_id
      , o_seqnum
      , i_case_id
      , i_split_hash
      , i_activity_category
      , i_activity_type
      , i_user_id
      , i_action_date
      , i_eff_date
      , i_status
      , i_resolution
      , i_commentary
    );

    trc_log_pkg.debug(
        i_text        => 'cln_api_action_pkg.add_action Added o_id=' || o_id || ', o_seqnum=' || o_seqnum
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
    l_seqnum                      com_api_type_pkg.t_tiny_id;
begin
    select seqnum
      into io_seqnum
      from cln_action
     where id = i_id;

    if l_seqnum > io_seqnum then
        com_api_error_pkg.raise_error(
            i_error => 'INCONSISTENT_DATA'
        );
    end if;

    io_seqnum := io_seqnum + 1;

    update cln_action_vw
       set seqnum          = io_seqnum
         , activity_type   = nvl(i_activity_type, activity_type)
         , user_id         = nvl(i_user_id,       user_id)
         , action_date     = nvl(i_action_date,   action_date)
         , status          = nvl(i_status,        status)
         , resolution      = nvl(i_resolution,    resolution)
         , commentary      = nvl(i_commentary,    commentary)
     where id              = i_id;

    trc_log_pkg.debug(
        i_text        => 'cln_api_action_pkg.modify_action Modified i_id=' || i_id || ', io_seqnum=' || io_seqnum
    );

end modify_action;

procedure remove_action(
    i_id                   in     com_api_type_pkg.t_long_id
  , i_seqnum               in     com_api_type_pkg.t_seqnum
) is
begin
    update cln_action_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from cln_action_vw where id = i_id;

    trc_log_pkg.debug(
        i_text        => 'cln_api_action_pkg.remove_action Removed i_id=' || i_id || ', i_seqnum=' || i_seqnum
    );

end remove_action;

end cln_api_action_pkg;
/
