create or replace package body vis_api_fee_generate_pkg is

    procedure gen_fee (
        i_card_number    in com_api_type_pkg.t_card_number
        , i_reason_code  in com_api_type_pkg.t_dict_value
        , i_amount       in com_api_type_pkg.t_medium_id
        , i_currency     in com_api_type_pkg.t_curr_code
        , i_oper_date    in date default get_sysdate
    )
    is
        l_fin_id                   com_api_type_pkg.t_long_id;
        l_destin_bin               com_api_type_pkg.t_name;
        l_reason_code              com_api_type_pkg.t_name;
        l_member_msg_text          com_api_type_pkg.t_name;
        l_standard_id              com_api_type_pkg.t_tiny_id;
        l_host_id                  com_api_type_pkg.t_tiny_id;
        l_inst_id                  com_api_type_pkg.t_tiny_id;
        l_bin_rec                  iss_api_type_pkg.t_bin_rec;
        l_param_tab                com_api_type_pkg.t_param_tab;
    begin
        l_bin_rec := iss_api_bin_pkg.get_bin (i_card_number => i_card_number);
        
        l_inst_id := net_api_network_pkg.get_inst_id(i_network_id => l_bin_rec.network_id);

        l_host_id := net_api_network_pkg.get_member_id (
            i_inst_id       => l_inst_id
            , i_network_id  => l_bin_rec.network_id
        );

        l_standard_id := net_api_network_pkg.get_offline_standard (
            i_host_id       => l_host_id
        );

        l_destin_bin := 
            cmn_api_standard_pkg.get_varchar_value (
                i_inst_id     => l_bin_rec.inst_id
              , i_standard_id => l_standard_id
              , i_object_id   => l_host_id
              , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name  => vis_api_const_pkg.CMID
              , i_param_tab   => l_param_tab
            );

        vis_api_dispute_pkg.gen_message_fee (
            o_fin_id             => l_fin_id
            , i_original_fin_id  => null
            , i_trans_code       => vis_api_const_pkg.TC_FEE_COLLECTION
            , i_inst_id          => l_bin_rec.inst_id
            , i_network_id       => l_bin_rec.network_id
            , i_destin_bin       => l_destin_bin
            , i_source_bin       => l_bin_rec.bin
            , i_reason_code      => i_reason_code
            , i_event_date       => i_oper_date
            , i_card_number      => i_card_number
            , i_oper_amount      => i_amount
            , i_oper_currency    => i_currency
            , i_country_code     => l_bin_rec.country
            , i_member_msg_text  => l_member_msg_text
        );
    end;

end;
/
 