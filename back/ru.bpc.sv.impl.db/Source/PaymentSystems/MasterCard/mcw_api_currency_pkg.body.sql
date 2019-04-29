create or replace package body mcw_api_currency_pkg is

    procedure put_message (
        i_cur_update_rec             in mcw_api_type_pkg.t_cur_update_rec
    ) is
    begin
        insert into mcw_currency_update (
            id
            , network_id
            , inst_id
            , file_id
            , mti
            , de024
            , de050
            , de071
            , de093
            , de094
            , de100
        ) values (
            i_cur_update_rec.id
            , i_cur_update_rec.network_id
            , i_cur_update_rec.inst_id
            , i_cur_update_rec.file_id
            , i_cur_update_rec.mti
            , i_cur_update_rec.de024
            , i_cur_update_rec.de050
            , i_cur_update_rec.de071
            , i_cur_update_rec.de093
            , i_cur_update_rec.de094
            , i_cur_update_rec.de100
        );
    end;

    procedure put_currency_rate (
        i_msg_id                in com_api_type_pkg.t_long_id
        , i_cur_rate_tab        in mcw_api_type_pkg.t_cur_rate_tab
    ) is
    begin
        forall i in 1 .. i_cur_rate_tab.count
            insert into mcw_currency_rate (
                id
                , p0164_1
                , p0164_2
                , p0164_3
                , p0164_4
                , p0164_5
                , de050
            ) values (
                i_msg_id
                , i_cur_rate_tab(i).p0164_1
                , i_cur_rate_tab(i).p0164_2
                , i_cur_rate_tab(i).p0164_3
                , i_cur_rate_tab(i).p0164_4
                , i_cur_rate_tab(i).p0164_5
                , i_cur_rate_tab(i).de050
            );
    end;
    
    procedure create_incoming_currency (
        i_mes_rec               in mcw_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
    ) is
        l_cur_update_rec        mcw_api_type_pkg.t_cur_update_rec;
        l_pds_tab               mcw_api_type_pkg.t_pds_tab;
        l_pds_body              mcw_api_type_pkg.t_pds_body;
        l_cur_rate_tab          mcw_api_type_pkg.t_cur_rate_tab;
        
        l_stage                 varchar2(100);
    begin
        trc_log_pkg.debug (
            i_text         => 'Processing incoming currency update' 
        );
        l_cur_update_rec := null;
        
        l_stage := 'init';
        -- init
        l_cur_update_rec.id := opr_api_create_pkg.get_id;
        l_cur_update_rec.file_id := i_file_id;
        l_cur_update_rec.network_id := i_network_id;

        l_stage := 'mti & de24 - de100';
        l_cur_update_rec.mti := i_mes_rec.mti;
        l_cur_update_rec.de024 := i_mes_rec.de024;
        l_cur_update_rec.de050 := i_mes_rec.de050;
        l_cur_update_rec.de071 := i_mes_rec.de071;
        l_cur_update_rec.de093 := i_mes_rec.de093;
        l_cur_update_rec.de094 := i_mes_rec.de094;
        l_cur_update_rec.de100 := i_mes_rec.de100;

        l_cur_update_rec.inst_id := cmn_api_standard_pkg.find_value_owner (
            i_standard_id         => i_standard_id
            , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_object_id         => i_host_id
            , i_param_name        => mcw_api_const_pkg.CMID
            , i_value_char        => l_cur_update_rec.de093
        );

        if l_cur_update_rec.inst_id is null then
            com_api_error_pkg.raise_error (
                i_error         => 'MCW_CMID_NOT_REGISTRED'
                , i_env_param1  => l_cur_update_rec.de093
                , i_env_param2  => i_network_id
            );
        end if;
        
        l_stage := 'extract_pds';
        mcw_api_pds_pkg.extract_pds (
            de048       => i_mes_rec.de048
            , de062     => i_mes_rec.de062
            , de123     => i_mes_rec.de123
            , de124     => i_mes_rec.de124
            , de125     => i_mes_rec.de125
            , pds_tab   => l_pds_tab
        );

        l_stage := 'get_pds_body';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0164
        );
        l_stage := 'parse_p0164';
        mcw_api_pds_pkg.parse_p0164
        (   i_p0164             => l_pds_body
            , i_de050           => i_mes_rec.de050
            , o_cur_rate_tab    => l_cur_rate_tab
        );
        
        -- determine internal institution number
        l_cur_update_rec.inst_id := cmn_api_standard_pkg.find_value_owner (
            i_standard_id    => i_standard_id
            , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_object_id    => i_host_id
            , i_param_name   => mcw_api_const_pkg.CMID
            , i_value_char   => l_cur_update_rec.de093
        );

        l_stage := 'put_message';
        put_message (
            i_cur_update_rec   => l_cur_update_rec
        );

        l_stage := 'save p0164';
        put_currency_rate (
            i_msg_id     => l_cur_update_rec.id
            , i_cur_rate_tab => l_cur_rate_tab
        );
        
        trc_log_pkg.debug (
            i_text         => 'Incoming currency update processed. Assigned id[#1]' 
            , i_env_param1 => l_cur_update_rec.id
        );
        
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error generating IPM currency update on stage ' || l_stage || ': ' || sqlerrm 
            );
            
            raise;
    end;

end; 
/
