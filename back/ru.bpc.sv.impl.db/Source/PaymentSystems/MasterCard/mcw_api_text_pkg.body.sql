create or replace package body mcw_api_text_pkg is

    procedure put_message (
        i_text_rec             in mcw_api_type_pkg.t_text_rec
    ) is
    begin
        insert into mcw_text (
            id
            , network_id
            , inst_id
            , file_id
            , mti
            , de024
            , de025
            , de071
            , de072
            , de093
            , de094
            , de100
        ) values (
            i_text_rec.id
            , i_text_rec.network_id
            , i_text_rec.inst_id
            , i_text_rec.file_id
            , i_text_rec.mti
            , i_text_rec.de024
            , i_text_rec.de025
            , i_text_rec.de071
            , i_text_rec.de072
            , i_text_rec.de093
            , i_text_rec.de094
            , i_text_rec.de100
        );
    end;
    
    procedure create_incoming_text (
        i_mes_rec               in mcw_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
    ) is
        l_text_rec              mcw_api_type_pkg.t_text_rec;
    begin
        trc_log_pkg.debug (
            i_text         => 'Processing incoming text message'
        );
        l_text_rec := null;
        
        -- init
        l_text_rec.id := opr_api_create_pkg.get_id;
        l_text_rec.file_id := i_file_id;
        l_text_rec.network_id := i_network_id;

        l_text_rec.mti := i_mes_rec.mti;
        l_text_rec.de024 := i_mes_rec.de024;
        l_text_rec.de025 := i_mes_rec.de025;
        l_text_rec.de071 := i_mes_rec.de071;
        l_text_rec.de072 := i_mes_rec.de072;
        l_text_rec.de093 := i_mes_rec.de093;
        l_text_rec.de094 := i_mes_rec.de094;
        l_text_rec.de100 := i_mes_rec.de100;

        -- determine internal institution number
        l_text_rec.inst_id := cmn_api_standard_pkg.find_value_owner (
            i_standard_id    => i_standard_id
            , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_object_id    => i_host_id
            , i_param_name   => mcw_api_const_pkg.CMID
            , i_value_char   => l_text_rec.de093
        );

        if l_text_rec.inst_id is null then
            com_api_error_pkg.raise_error(
                i_error         => 'MCW_CMID_NOT_REGISTRED'
                , i_env_param1  => l_text_rec.de093
                , i_env_param2  => i_network_id
            );
        end if;

        put_message (
            i_text_rec   => l_text_rec
        );

        trc_log_pkg.debug (
            i_text         => 'Incoming text message processed. Assigned id[#1]'
            , i_env_param1 => l_text_rec.id
        );
    end;

end; 
/
