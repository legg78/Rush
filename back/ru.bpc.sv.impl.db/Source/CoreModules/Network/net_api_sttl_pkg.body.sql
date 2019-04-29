create or replace package body net_api_sttl_pkg is

    procedure get_sttl_type (
        i_iss_inst_id               in com_api_type_pkg.t_inst_id
        , i_acq_inst_id             in com_api_type_pkg.t_inst_id
        , i_card_inst_id            in com_api_type_pkg.t_inst_id
        , i_iss_network_id          in com_api_type_pkg.t_tiny_id
        , i_acq_network_id          in com_api_type_pkg.t_tiny_id
        , i_card_network_id         in com_api_type_pkg.t_tiny_id
        , i_acq_inst_bin            in com_api_type_pkg.t_rrn
        , o_sttl_type               out com_api_type_pkg.t_dict_value
        , o_match_status            out com_api_type_pkg.t_dict_value
        , i_mask_error              in com_api_type_pkg.t_boolean
        , i_error_value             in com_api_type_pkg.t_dict_value
        , i_params                  in com_api_type_pkg.t_param_tab
        , i_oper_type               in com_api_type_pkg.t_dict_value    default null
    ) is
        LOG_PREFIX                  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_sttl_type: ';
        l_params                    com_api_type_pkg.t_param_tab;
    begin
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'i_iss_inst_id ['        || i_iss_inst_id
                                 || '], i_acq_inst_id ['     || i_acq_inst_id
                                 || '], i_card_inst_id ['    || i_card_inst_id
                                 || '], i_iss_network_id ['  || i_iss_network_id
                                 || '], i_acq_network_id ['  || i_acq_network_id
                                 || '], i_card_network_id [' || i_card_network_id
                                 || '], i_acq_inst_bin ['    || i_acq_inst_bin
                                 || '], i_mask_error ['      || i_mask_error
                                 || '], i_error_value ['     || i_error_value
                                 || '], i_oper_type ['       || i_oper_type
                                 || ']'
        );
        for rec in (
            select
                s.sttl_type
                , s.match_status
                , m.id mod_id
            from
                net_sttl_map s
                , rul_mod m
            where
                s.iss_inst_id in (nvl(i_iss_inst_id, ost_api_const_pkg.DEFAULT_INST), ost_api_const_pkg.DEFAULT_INST) 
                and s.acq_inst_id in (nvl(i_acq_inst_id, ost_api_const_pkg.DEFAULT_INST), ost_api_const_pkg.DEFAULT_INST)  
                and s.card_inst_id in (nvl(i_card_inst_id, ost_api_const_pkg.DEFAULT_INST), ost_api_const_pkg.DEFAULT_INST)  
                and s.iss_network_id in (nvl(i_iss_network_id, net_api_const_pkg.DEFAULT_NETWORK), net_api_const_pkg.DEFAULT_NETWORK)
                and s.acq_network_id in (nvl(i_acq_network_id, net_api_const_pkg.DEFAULT_NETWORK), net_api_const_pkg.DEFAULT_NETWORK)  
                and s.card_network_id in (nvl(i_card_network_id, net_api_const_pkg.DEFAULT_NETWORK), net_api_const_pkg.DEFAULT_NETWORK)
                and nvl(i_oper_type, '%') like nvl(s.oper_type, '%')
                and s.mod_id = m.id(+)
            order by 
                s.priority
                , m.priority
        ) loop
            if rec.mod_id is null then
                o_sttl_type := rec.sttl_type;
                o_match_status := rec.match_status;
                exit;
            else
                if l_params.count = 0 then
                    l_params    := i_params;
                    rul_api_param_pkg.set_param (
                        i_name          => 'ISS_INST_ID'
                        , i_value       => i_iss_inst_id
                        , io_params     => l_params
                    );
                    rul_api_param_pkg.set_param (
                        i_name          => 'ISS_NETWORK_ID'
                        , i_value       => i_iss_network_id
                        , io_params     => l_params
                    );
                    rul_api_param_pkg.set_param (
                        i_name          => 'ACQ_INST_ID'
                        , i_value       => i_acq_inst_id
                        , io_params     => l_params
                    );
                    rul_api_param_pkg.set_param (
                        i_name          => 'ACQ_NETWORK_ID'
                        , i_value       => i_acq_network_id
                        , io_params     => l_params
                    );
                    rul_api_param_pkg.set_param (
                        i_name          => 'CARD_INST_ID'
                        , i_value       => i_card_inst_id
                        , io_params     => l_params
                    );
                    rul_api_param_pkg.set_param (
                        i_name          => 'CARD_NETWORK_ID'
                        , i_value       => i_card_network_id
                        , io_params     => l_params
                    );
                    rul_api_param_pkg.set_param (
                        i_value         => i_acq_inst_bin
                        , i_name        => 'ACQ_BIN'
                        , io_params     => l_params
                    );
                end if;
                
                if rul_api_mod_pkg.check_condition (
                    i_mod_id        => rec.mod_id
                    , i_params      => l_params
                ) = com_api_type_pkg.TRUE then
                    o_sttl_type := rec.sttl_type;
                    o_match_status := rec.match_status;
                    exit;
                end if; 
            end if;
        end loop;
        
        if o_sttl_type is null then
            raise no_data_found;
        end if;
    exception
        when no_data_found then
            if i_mask_error = com_api_const_pkg.TRUE then
                trc_log_pkg.debug (
                    i_text          => 'UNABLE_TO_DEFINE_SETTLEMENT_TYPE'
                    , i_env_param1  => i_iss_inst_id
                    , i_env_param2  => i_acq_inst_id
                    , i_env_param3  => i_card_inst_id
                    , i_env_param4  => i_iss_network_id
                    , i_env_param5  => i_acq_network_id
                    , i_env_param6  => i_card_network_id
                );
            
                o_sttl_type := i_error_value;
                o_match_status := null;
            else
                com_api_error_pkg.raise_error (
                    i_error         => 'UNABLE_TO_DEFINE_SETTLEMENT_TYPE'
                    , i_env_param1  => i_iss_inst_id
                    , i_env_param2  => i_acq_inst_id
                    , i_env_param3  => i_card_inst_id
                    , i_env_param4  => i_iss_network_id
                    , i_env_param5  => i_acq_network_id
                    , i_env_param6  => i_card_network_id
                );
            end if; 
    end;
    
    procedure get_sttl_type (
        i_iss_inst_id               in com_api_type_pkg.t_inst_id
        , i_acq_inst_id             in com_api_type_pkg.t_inst_id
        , i_card_inst_id            in com_api_type_pkg.t_inst_id
        , i_iss_network_id          in com_api_type_pkg.t_tiny_id
        , i_acq_network_id          in com_api_type_pkg.t_tiny_id
        , i_card_network_id         in com_api_type_pkg.t_tiny_id
        , i_acq_inst_bin            in com_api_type_pkg.t_rrn
        , o_sttl_type               out com_api_type_pkg.t_dict_value
        , o_match_status            out com_api_type_pkg.t_dict_value
        , i_mask_error              in com_api_type_pkg.t_boolean
        , i_error_value             in com_api_type_pkg.t_dict_value
        , i_oper_type               in com_api_type_pkg.t_dict_value    default null
    ) is
        l_params                    com_api_type_pkg.t_param_tab;
    begin
        get_sttl_type (
            i_iss_inst_id       => i_iss_inst_id
            , i_acq_inst_id     => i_acq_inst_id
            , i_card_inst_id    => i_card_inst_id
            , i_iss_network_id  => i_iss_network_id
            , i_acq_network_id  => i_acq_network_id
            , i_card_network_id => i_card_network_id
            , i_acq_inst_bin    => i_acq_inst_bin
            , o_sttl_type       => o_sttl_type
            , o_match_status    => o_match_status
            , i_mask_error      => i_mask_error
            , i_error_value     => i_error_value
            , i_params          => l_params
            , i_oper_type       => i_oper_type
        );
        
    end;    

end;
/
