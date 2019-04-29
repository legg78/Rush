create or replace package body rcn_ui_reconciliation_pkg is

procedure add_condition(
    o_id                       out com_api_type_pkg.t_tiny_id
  , o_seqnum                   out com_api_type_pkg.t_seqnum
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_recon_type            in     com_api_type_pkg.t_dict_value
  , i_cond_type             in     com_api_type_pkg.t_dict_value
  , i_name                  in     com_api_type_pkg.t_name
  , i_condition             in     com_api_type_pkg.t_param_value
  , i_lang                  in     com_api_type_pkg.t_dict_value
  , i_provider_id           in     com_api_type_pkg.t_short_id      default null
  , i_purpose_id            in     com_api_type_pkg.t_short_id      default null
) is
begin
    o_id     := rcn_condition_seq.nextval;
    o_seqnum := 1;
    
    insert into rcn_condition(
        id
      , inst_id
      , recon_type
      , condition
      , condition_type
      , seqnum
      , provider_id
      , purpose_id
    ) values (
        o_id
      , i_inst_id
      , i_recon_type
      , i_condition
      , i_cond_type
      , o_seqnum
      , i_provider_id
      , i_purpose_id
    );

    if i_name is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'rcn_condition'
          , i_column_name   => 'label'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_name
        );
    end if;
end add_condition;

procedure modify_condition(
    i_id                    in     com_api_type_pkg.t_tiny_id
  , io_seqnum               in out com_api_type_pkg.t_seqnum
  , i_recon_type            in     com_api_type_pkg.t_dict_value
  , i_cond_type             in     com_api_type_pkg.t_dict_value
  , i_name                  in     com_api_type_pkg.t_name
  , i_condition             in     com_api_type_pkg.t_param_value
  , i_lang                  in     com_api_type_pkg.t_dict_value
  , i_provider_id           in     com_api_type_pkg.t_short_id      default null
  , i_purpose_id            in     com_api_type_pkg.t_short_id      default null
) is
begin
    update rcn_condition
       set recon_type     = i_recon_type
         , condition      = i_condition
         , condition_type = i_cond_type
         , seqnum         = io_seqnum
         , provider_id    = i_provider_id
         , purpose_id     = i_purpose_id
     where id = i_id;

    io_seqnum := io_seqnum + 1;

    if i_name is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'rcn_condition'
          , i_column_name   => 'label'
          , i_object_id     => i_id
          , i_lang          => i_lang
          , i_text          => i_name
        );
    end if;
end modify_condition;

procedure remove_match_condition (
    i_id                    in     com_api_type_pkg.t_tiny_id
  , io_seqnum               in out com_api_type_pkg.t_seqnum
) is
begin
    update rcn_condition
       set seqnum = io_seqnum
     where id = i_id;

    io_seqnum := io_seqnum + 1;

    delete from rcn_condition_vw
     where id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name        => 'rcn_condition'
      , i_object_id         => i_id
    );

end remove_match_condition;

procedure modify_reconciliation(
    i_id                    in     com_api_type_pkg.t_long_id
  , i_recon_status          in     com_api_type_pkg.t_dict_value
) is
begin
    update rcn_cbs_msg_vw
       set recon_status = i_recon_status
     where id = i_id;
end modify_reconciliation;

procedure modify_reconciliation_atm(
    i_id                    in     com_api_type_pkg.t_long_id
  , i_recon_status          in     com_api_type_pkg.t_dict_value
) is
begin
    update rcn_atm_msg_vw
       set recon_status = i_recon_status
     where id = i_id;
end modify_reconciliation_atm;

procedure modify_reconciliation_host(
    i_id                    in     com_api_type_pkg.t_long_id
  , i_recon_status          in     com_api_type_pkg.t_dict_value
) is
begin
    update rcn_host_msg_vw
       set recon_status = i_recon_status
     where id = i_id;
end modify_reconciliation_host;

procedure add_recon_parameter(
    o_id                       out com_api_type_pkg.t_long_id
  , o_seqnum                   out com_api_type_pkg.t_seqnum
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_provider_id           in     com_api_type_pkg.t_short_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , i_param_id              in     com_api_type_pkg.t_short_id
) is
begin
    o_id     := rcn_srvp_parameter_seq.nextval;
    o_seqnum := 1;
    
    insert into rcn_srvp_parameter(
        id
      , inst_id
      , seqnum
      , provider_id
      , purpose_id
      , param_id
    ) values (
        o_id
      , i_inst_id
      , o_seqnum
      , i_provider_id
      , i_purpose_id
      , i_param_id
    );
end add_recon_parameter;

procedure modify_recon_parameter(
    i_id                    in     com_api_type_pkg.t_long_id
  , io_seqnum               in out com_api_type_pkg.t_seqnum
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_provider_id           in     com_api_type_pkg.t_short_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , i_param_id              in     com_api_type_pkg.t_short_id
) is
begin
    update rcn_srvp_parameter
       set inst_id          = i_inst_id
         , seqnum           = io_seqnum
         , provider_id      = i_provider_id
         , purpose_id       = i_purpose_id
         , param_id         = i_param_id
     where id               = i_id;

    io_seqnum := io_seqnum + 1;

end modify_recon_parameter;

procedure remove_recon_parameter(
    i_id                    in     com_api_type_pkg.t_short_id
  , io_seqnum               in out com_api_type_pkg.t_seqnum
) is
begin
    delete from rcn_srvp_parameter
     where id = i_id;

    io_seqnum := io_seqnum + 1;
end remove_recon_parameter;

procedure modify_msg_recon_status(
    i_id                    in     com_api_type_pkg.t_long_id
  , i_recon_status          in     com_api_type_pkg.t_dict_value
) is
begin
    update rcn_srvp_msg
       set recon_status     = i_recon_status
     where id               = i_id;
end modify_msg_recon_status;

procedure modify_message(
    i_id                    in     com_api_type_pkg.t_long_id
  , i_recon_status          in     com_api_type_pkg.t_dict_value
  , i_module                in     com_api_type_pkg.t_attr_name
) is
    l_view_name                    com_api_type_pkg.t_attr_name := null;
    l_update                       com_api_type_pkg.t_text      := 'update ';
    l_request                      com_api_type_pkg.t_text      := ' set recon_status = :i_recon_status where id = :i_id';
begin
    if i_module = 'CBS' then
        l_view_name := 'rcn_cbs_msg_vw';
    elsif i_module = 'ATM' then
        l_view_name := 'rcn_atm_msg_vw';
    elsif i_module = 'HOST' then
        l_view_name := 'rcn_host_msg_vw';
    elsif i_module = 'SRVP' then
        l_view_name := 'rcn_srvp_msg_vw';
    end if;

    execute immediate l_update || l_view_name || l_request
      using i_recon_status
          , i_id;
end modify_message;

end;
/
