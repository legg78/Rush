create or replace package body mup_api_fpd_pkg is

    procedure put_message (
        i_fpd_rec             in mup_api_type_pkg.t_fpd_rec
    ) is
    begin
        insert into mup_fpd (
              id
            , network_id
            , inst_id
            , file_id
            , status
            , mti
            , de024
            , de025
            , de026
            , de049
            , de050
            , de071
            , de093
            , de100
            , p0148
            , p0165
            , p0300
            , p0302
            , p0369
            , p0370_1
            , p0370_2
            , p0372_1
            , p0372_2
            , p0374
            , p0375
            , p0378
            , p0380_1
            , p0380_2
            , p0381_1
            , p0381_2
            , p0384_1
            , p0384_2
            , p0390_1
            , p0390_2
            , p0391_1
            , p0391_2
            , p0392
            , p0393
            , p0394_1
            , p0394_2
            , p0395_1
            , p0395_2
            , p0396_1
            , p0396_2
            , p0400
            , p0401
            , p0402
            , p2358_1
            , p2358_2
            , p2358_3
            , p2358_4
            , p2358_5
            , p2358_6
            , p2359_1
            , p2359_2
            , p2359_3
            , p2359_4
            , p2359_5
            , p2359_6         
        ) values (
              i_fpd_rec.id
            , i_fpd_rec.network_id
            , i_fpd_rec.inst_id
            , i_fpd_rec.file_id
            , i_fpd_rec.status
            , i_fpd_rec.mti
            , i_fpd_rec.de024
            , i_fpd_rec.de025
            , i_fpd_rec.de026
            , i_fpd_rec.de049
            , i_fpd_rec.de050
            , i_fpd_rec.de071
            , i_fpd_rec.de093
            , i_fpd_rec.de100
            , i_fpd_rec.p0148
            , i_fpd_rec.p0165
            , i_fpd_rec.p0300
            , i_fpd_rec.p0302
            , i_fpd_rec.p0369
            , i_fpd_rec.p0370_1
            , i_fpd_rec.p0370_2
            , i_fpd_rec.p0372_1
            , i_fpd_rec.p0372_2
            , i_fpd_rec.p0374
            , i_fpd_rec.p0375
            , i_fpd_rec.p0378
            , i_fpd_rec.p0380_1
            , i_fpd_rec.p0380_2
            , i_fpd_rec.p0381_1
            , i_fpd_rec.p0381_2
            , i_fpd_rec.p0384_1
            , i_fpd_rec.p0384_2
            , i_fpd_rec.p0390_1
            , i_fpd_rec.p0390_2
            , i_fpd_rec.p0391_1
            , i_fpd_rec.p0391_2
            , i_fpd_rec.p0392
            , i_fpd_rec.p0393
            , i_fpd_rec.p0394_1
            , i_fpd_rec.p0394_2
            , i_fpd_rec.p0395_1
            , i_fpd_rec.p0395_2
            , i_fpd_rec.p0396_1
            , i_fpd_rec.p0396_2
            , i_fpd_rec.p0400
            , i_fpd_rec.p0401
            , i_fpd_rec.p0402
            , i_fpd_rec.p2358_1
            , i_fpd_rec.p2358_2
            , i_fpd_rec.p2358_3
            , i_fpd_rec.p2358_4
            , i_fpd_rec.p2358_5
            , i_fpd_rec.p2358_6
            , i_fpd_rec.p2359_1
            , i_fpd_rec.p2359_2
            , i_fpd_rec.p2359_3
            , i_fpd_rec.p2359_4
            , i_fpd_rec.p2359_5
            , i_fpd_rec.p2359_6         
        );
    end;
    
    procedure put_message (
        i_fsum_rec             in mup_api_type_pkg.t_fsum_rec
    ) is
    begin
        insert into mup_fsum (
            id
            , network_id
            , inst_id
            , file_id
            , status
            , mti
            , de024
            , de025
            , de049
            , de071
            , de093
            , de100
            , p0148
            , p0300
            , p0380_1
            , p0380_2
            , p0381_1
            , p0381_2
            , p0384_1
            , p0384_2
            , p0400
            , p0401
            , p0402
        ) values (
            i_fsum_rec.id
            , i_fsum_rec.network_id
            , i_fsum_rec.inst_id
            , i_fsum_rec.file_id
            , i_fsum_rec.status
            , i_fsum_rec.mti
            , i_fsum_rec.de024
            , i_fsum_rec.de025
            , i_fsum_rec.de049
            , i_fsum_rec.de071
            , i_fsum_rec.de093
            , i_fsum_rec.de100
            , i_fsum_rec.p0148
            , i_fsum_rec.p0300
            , i_fsum_rec.p0380_1
            , i_fsum_rec.p0380_2
            , i_fsum_rec.p0381_1
            , i_fsum_rec.p0381_2
            , i_fsum_rec.p0384_1
            , i_fsum_rec.p0384_2
            , i_fsum_rec.p0400
            , i_fsum_rec.p0401
            , i_fsum_rec.p0402
        );
    end;
    
    procedure create_incoming_fpd (
        i_mes_rec               in mup_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
    ) is
        l_fpd_rec               mup_api_type_pkg.t_fpd_rec;
        l_pds_tab               mup_api_type_pkg.t_pds_tab;
        l_pds_body              mup_api_type_pkg.t_pds_body;
        
        l_stage                 varchar2(100);
    begin
        trc_log_pkg.debug (
            i_text         => 'Processing incoming detail position' 
        );
        l_fpd_rec := null;
        
        l_stage := 'init';
        -- init
        l_fpd_rec.id := opr_api_create_pkg.get_id;
        l_fpd_rec.file_id := i_file_id;
        l_fpd_rec.network_id := i_network_id;
        l_fpd_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;

        l_stage := 'mti & de24 - de100';
        l_fpd_rec.mti := i_mes_rec.mti;
        l_fpd_rec.de024 := i_mes_rec.de024;
        l_fpd_rec.de025 := i_mes_rec.de025;
        l_fpd_rec.de026 := i_mes_rec.de026;
        l_fpd_rec.de049 := i_mes_rec.de049;
        l_fpd_rec.de050 := i_mes_rec.de050;
        l_fpd_rec.de071 := i_mes_rec.de071;
        l_fpd_rec.de093 := i_mes_rec.de093;
        l_fpd_rec.de100 := i_mes_rec.de100;
        
        l_fpd_rec.inst_id := cmn_api_standard_pkg.find_value_owner (
            i_standard_id         => i_standard_id
            , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_object_id         => i_host_id
            , i_param_name        => mup_api_const_pkg.CMID
            , i_value_char        => l_fpd_rec.de093
        );

        if l_fpd_rec.inst_id is null then
            com_api_error_pkg.raise_error (
                i_error         => 'MUP_CMID_NOT_REGISTRED'
                , i_env_param1  => l_fpd_rec.de093
                , i_env_param2  => i_network_id
            );
        end if;
        
        l_stage := 'extract_pds';
        mup_api_pds_pkg.extract_pds (
            de048       => i_mes_rec.de048
            , de062     => i_mes_rec.de062
            , de123     => i_mes_rec.de123
            , de124     => i_mes_rec.de124
            , de125     => i_mes_rec.de125
            , pds_tab   => l_pds_tab
        );
        l_stage := 'p0148';
        l_fpd_rec.p0148 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0148
        );
        l_stage := 'p0165';
        l_fpd_rec.p0165 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0165
        );
        l_stage := 'p0300';
        l_fpd_rec.p0300 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0300
        );
        l_stage := 'p0302';
        l_fpd_rec.p0302 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0302
        );

        l_stage := 'p0369';
        l_fpd_rec.p0369 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0369
        );
        l_stage := 'p0370';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0370
        );
        l_stage := 'parse_p0370';
        mup_api_pds_pkg.parse_p0370 (
            i_p0370           => l_pds_body
            , o_p0370_1       => l_fpd_rec.p0370_1
            , o_p0370_2       => l_fpd_rec.p0370_2
        );
        l_stage := 'p0372';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0372
        );
        l_stage := 'parse_p0372';
        mup_api_pds_pkg.parse_p0372 (
            i_p0372           => l_pds_body
            , o_p0372_1       => l_fpd_rec.p0372_1
            , o_p0372_2       => l_fpd_rec.p0372_2
        );
        l_stage := 'p0374';
        l_fpd_rec.p0374 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0374
        );
        l_stage := 'p0375';
        l_fpd_rec.p0375 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0375
        );
        l_stage := 'p0378';
        l_fpd_rec.p0378 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0378
        );
        l_stage := 'p0380';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0380
        );
        mup_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0380'
            , o_p0380_1       => l_fpd_rec.p0380_1
            , o_p0380_2       => l_fpd_rec.p0380_2
        );
        l_stage := 'p0381';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0381
        );
        mup_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0381'
            , o_p0380_1       => l_fpd_rec.p0381_1
            , o_p0380_2       => l_fpd_rec.p0381_2
        );
        l_stage := 'p0384';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0384
        );
        mup_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0384'
            , o_p0380_1       => l_fpd_rec.p0384_1
            , o_p0380_2       => l_fpd_rec.p0384_2
        );
        l_stage := 'p0390';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0390
        );
        mup_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0390'
            , o_p0380_1       => l_fpd_rec.p0390_1
            , o_p0380_2       => l_fpd_rec.p0390_2
        );
        l_stage := 'p0391';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0391
        );
        mup_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0391'
            , o_p0380_1       => l_fpd_rec.p0391_1
            , o_p0380_2       => l_fpd_rec.p0391_2
        );

        l_stage := 'p0392';
        l_fpd_rec.p0392 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0392
        );
        l_stage := 'p0393';
        l_fpd_rec.p0393 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0393
        );
        l_stage := 'p0394';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0394
        );
        mup_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0394'
            , o_p0380_1       => l_fpd_rec.p0394_1
            , o_p0380_2       => l_fpd_rec.p0394_2
        );
        l_stage := 'p0395';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0395
        );
        mup_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0395'
            , o_p0380_1       => l_fpd_rec.p0395_1
            , o_p0380_2       => l_fpd_rec.p0395_2
        );
        l_stage := 'p0396';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0396
        );
        mup_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0396'
            , o_p0380_1       => l_fpd_rec.p0396_1
            , o_p0380_2       => l_fpd_rec.p0396_2
        );
        l_stage := 'p0400';
        l_fpd_rec.p0400 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0400
        );
        l_stage := 'p0401';
        l_fpd_rec.p0401 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0401
        );
        l_stage := 'p0402';
        l_fpd_rec.p0402 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0402
        );
        l_stage := 'p2358';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_2358
        );
        l_stage := 'parse_p2158';
        mup_api_pds_pkg.parse_p2158 (
            i_p2158            => l_pds_body
            , o_p2158_1        => l_fpd_rec.p2358_1
            , o_p2158_2        => l_fpd_rec.p2358_2
            , o_p2158_3        => l_fpd_rec.p2358_3
            , o_p2158_4        => l_fpd_rec.p2358_4
            , o_p2158_5        => l_fpd_rec.p2358_5
            , o_p2158_6        => l_fpd_rec.p2358_6
        );

        l_stage := 'p2359';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_2359
        );
        l_stage := 'parse_p2159';
        mup_api_pds_pkg.parse_p2159 (
            i_p2159            => l_pds_body
            , o_p2159_1        => l_fpd_rec.p2359_1
            , o_p2159_2        => l_fpd_rec.p2359_2
            , o_p2159_3        => l_fpd_rec.p2359_3
            , o_p2159_4        => l_fpd_rec.p2359_4
            , o_p2159_5        => l_fpd_rec.p2359_5
            , o_p2159_6        => l_fpd_rec.p2359_6
        );

        l_stage := 'put_message';
        put_message (
            i_fpd_rec   => l_fpd_rec
        );

        l_stage := 'save_pds';
        mup_api_pds_pkg.save_pds (
            i_msg_id     => l_fpd_rec.id
            , i_pds_tab  => l_pds_tab
        );
        
        trc_log_pkg.debug (
            i_text         => 'Incoming detail position processed. Assigned id[#1]' 
            , i_env_param1 => l_fpd_rec.id
        );
        
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error generating IPM detail position on stage ' || l_stage || ': ' || sqlerrm 
            );
            
            raise;
    end;
    
    procedure create_incoming_fsum (
        i_mes_rec               in mup_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
    ) is
        l_fsum_rec              mup_api_type_pkg.t_fsum_rec;
        l_pds_tab               mup_api_type_pkg.t_pds_tab;
        l_pds_body              mup_api_type_pkg.t_pds_body;
        
        l_stage                 varchar2(100);
    begin
        trc_log_pkg.debug (
            i_text         => 'Processing incoming file summary' 
        );
        l_fsum_rec := null;
        
        l_stage := 'init';
        -- init
        l_fsum_rec.id := opr_api_create_pkg.get_id;
        l_fsum_rec.file_id := i_file_id;
        l_fsum_rec.network_id := i_network_id;
        l_fsum_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;

        l_stage := 'mti & de24 - de100';
        l_fsum_rec.mti := i_mes_rec.mti;
        l_fsum_rec.de024 := i_mes_rec.de024;
        l_fsum_rec.de025 := i_mes_rec.de025;
        l_fsum_rec.de049 := i_mes_rec.de049;
        l_fsum_rec.de071 := i_mes_rec.de071;
        l_fsum_rec.de093 := i_mes_rec.de093;
        l_fsum_rec.de100 := i_mes_rec.de100;
        
        l_fsum_rec.inst_id := cmn_api_standard_pkg.find_value_owner (
            i_standard_id         => i_standard_id
            , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_object_id         => i_host_id
            , i_param_name        => mup_api_const_pkg.CMID
            , i_value_char        => l_fsum_rec.de093
        );

        if l_fsum_rec.inst_id is null then
            com_api_error_pkg.raise_error (
                i_error         => 'MUP_CMID_NOT_REGISTRED'
                , i_env_param1  => l_fsum_rec.de093
                , i_env_param2  => i_network_id
            );
        end if;
        
        l_stage := 'extract_pds';
        mup_api_pds_pkg.extract_pds (
            de048       => i_mes_rec.de048
            , de062     => i_mes_rec.de062
            , de123     => i_mes_rec.de123
            , de124     => i_mes_rec.de124
            , de125     => i_mes_rec.de125
            , pds_tab   => l_pds_tab
        );
        l_stage := 'p0148';
        l_fsum_rec.p0148 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0148
        );
        l_stage := 'p0300';
        l_fsum_rec.p0300 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0300
        );
        l_stage := 'p0380';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0380
        );
        mup_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0380'
            , o_p0380_1       => l_fsum_rec.p0380_1
            , o_p0380_2       => l_fsum_rec.p0380_2
        );
        l_stage := 'p0381';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0381
        );
        mup_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0381'
            , o_p0380_1       => l_fsum_rec.p0381_1
            , o_p0380_2       => l_fsum_rec.p0381_2
        );
        l_stage := 'p0384';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0384
        );
        mup_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0384'
            , o_p0380_1       => l_fsum_rec.p0384_1
            , o_p0380_2       => l_fsum_rec.p0384_2
        );
        l_stage := 'p0400';
        l_fsum_rec.p0400 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0400
        );
        l_stage := 'p0401';
        l_fsum_rec.p0401 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0401
        );
        l_stage := 'p0402';
        l_fsum_rec.p0402 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0402
        );
        
        l_stage := 'put_message';
        put_message (
            i_fsum_rec   => l_fsum_rec
        );

        l_stage := 'save_pds';
        mup_api_pds_pkg.save_pds (
            i_msg_id     => l_fsum_rec.id
            , i_pds_tab  => l_pds_tab
        );
        
        trc_log_pkg.debug (
            i_text         => 'Incoming settlment file summary. Assigned id[#1]' 
            , i_env_param1 => l_fsum_rec.id
        );
        
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error generating IPM file summary on stage ' || l_stage || ': ' || sqlerrm 
            );
            
            raise;
    end;
    
end; 
/
