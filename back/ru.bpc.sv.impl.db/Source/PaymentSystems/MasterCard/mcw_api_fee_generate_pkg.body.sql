create or replace package body mcw_api_fee_generate_pkg is

    procedure gen_fee (
        i_card_number    in com_api_type_pkg.t_card_number
        , i_reason_code  in com_api_type_pkg.t_dict_value
        , i_amount       in com_api_type_pkg.t_medium_id
        , i_currency     in com_api_type_pkg.t_curr_code
        , i_oper_date    in date default get_sysdate
    )
    is
        l_fin_id                   com_api_type_pkg.t_long_id;
        l_de003                    mcw_api_type_pkg.t_de003;
        l_de072                    mcw_api_type_pkg.t_de072;
        l_de093                    mcw_api_type_pkg.t_de093;
        l_de094                    mcw_api_type_pkg.t_de094;
        l_standard_id              com_api_type_pkg.t_tiny_id;
        l_host_id                  com_api_type_pkg.t_tiny_id;
        l_inst_id                  com_api_type_pkg.t_tiny_id;
        l_bin_rec                  iss_api_type_pkg.t_bin_rec;
        l_param_tab                com_api_type_pkg.t_param_tab;
    begin
        l_bin_rec := iss_api_bin_pkg.get_bin (i_card_number => i_card_number);
        
        l_inst_id := net_api_network_pkg.get_inst_id(i_network_id => l_bin_rec.network_id);

        select de003, de072
          into l_de003, l_de072
          from mcw_reason_code
         where mti = mcw_api_const_pkg.MSG_TYPE_FEE
           and de024 = mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE
           and de025 = i_reason_code
           and rownum = 1;

        l_host_id := net_api_network_pkg.get_member_id (
            i_inst_id       => l_inst_id
            , i_network_id  => l_bin_rec.network_id
        );

        l_standard_id := net_api_network_pkg.get_offline_standard (
            i_host_id       => l_host_id
        );

        l_de094 := 
            cmn_api_standard_pkg.get_varchar_value (
                i_inst_id     => l_bin_rec.inst_id
              , i_standard_id => l_standard_id
              , i_object_id   => l_host_id
              , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name  => mcw_api_const_pkg.CMID
              , i_param_tab   => l_param_tab
            );

        mcw_api_dispute_pkg.gen_member_fee (
            o_fin_id             => l_fin_id
            , i_network_id       => l_bin_rec.network_id
            , i_de004            => i_amount
            , i_de049            => i_currency
            , i_de025            => i_reason_code
            , i_de003            => l_de003
            , i_de072            => l_de072
            , i_de073            => i_oper_date
            , i_de093            => l_de093
            , i_de094            => l_de094
            , i_de002            => i_card_number
            , i_original_fin_id  => null
        );
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'MCW_UNKNOWN_REASON'
                , i_env_param1  => mcw_api_const_pkg.MSG_TYPE_FEE
                , i_env_param2  => mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE
                , i_env_param3  => i_reason_code
            );
    end;

end;
/
 