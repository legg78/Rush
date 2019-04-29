create or replace package body mcw_api_fpd_pkg is

    procedure put_message (
        i_fpd_rec             in mcw_api_type_pkg.t_fpd_rec
    ) is
    begin
        insert into mcw_fpd (
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
            , p0358_1
            , p0358_2
            , p0358_3
            , p0358_4
            , p0358_5
            , p0358_6
            , p0358_7
            , p0358_8
            , p0358_9
            , p0358_10
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
            , p0397
            , p0398
            , p0399_1
            , p0399_2
            , p0400
            , p0401
            , p0402
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
            , i_fpd_rec.p0358_1
            , i_fpd_rec.p0358_2
            , i_fpd_rec.p0358_3
            , i_fpd_rec.p0358_4
            , i_fpd_rec.p0358_5
            , i_fpd_rec.p0358_6
            , i_fpd_rec.p0358_7
            , i_fpd_rec.p0358_8
            , i_fpd_rec.p0358_9
            , i_fpd_rec.p0358_10
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
            , i_fpd_rec.p0397
            , i_fpd_rec.p0398
            , i_fpd_rec.p0399_1
            , i_fpd_rec.p0399_2
            , i_fpd_rec.p0400
            , i_fpd_rec.p0401
            , i_fpd_rec.p0402
        );
    end;
    
    procedure put_message (
        i_spd_rec             in mcw_api_type_pkg.t_spd_rec
    ) is
    begin
        insert into mcw_spd (
            id
            , network_id
            , inst_id
            , file_id
            , status
            , mti
            , de024
            , de025
            , de049
            , de050
            , de071
            , de093
            , de100
            , p0148
            , p0300
            , p0302
            , p0359
            , p0367
            , p0368
            , p0369
            , p0370_1
            , p0370_2
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
            , p0397
            , p0398
            , p0399_1
            , p0399_2
        ) values (
            i_spd_rec.id
            , i_spd_rec.network_id
            , i_spd_rec.inst_id
            , i_spd_rec.file_id
            , i_spd_rec.status
            , i_spd_rec.mti
            , i_spd_rec.de024
            , i_spd_rec.de025
            , i_spd_rec.de049
            , i_spd_rec.de050
            , i_spd_rec.de071
            , i_spd_rec.de093
            , i_spd_rec.de100
            , i_spd_rec.p0148
            , i_spd_rec.p0300
            , i_spd_rec.p0302
            , i_spd_rec.p0359
            , i_spd_rec.p0367
            , i_spd_rec.p0368
            , i_spd_rec.p0369
            , i_spd_rec.p0370_1
            , i_spd_rec.p0370_2
            , i_spd_rec.p0390_1
            , i_spd_rec.p0390_2
            , i_spd_rec.p0391_1
            , i_spd_rec.p0391_2
            , i_spd_rec.p0392
            , i_spd_rec.p0393
            , i_spd_rec.p0394_1
            , i_spd_rec.p0394_2
            , i_spd_rec.p0395_1
            , i_spd_rec.p0395_2
            , i_spd_rec.p0396_1
            , i_spd_rec.p0396_2
            , i_spd_rec.p0397
            , i_spd_rec.p0398
            , i_spd_rec.p0399_1
            , i_spd_rec.p0399_2
       
        );
    end;
    
    procedure put_message (
        i_fsum_rec             in mcw_api_type_pkg.t_fsum_rec
    ) is
    begin
        insert into mcw_fsum (
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
        i_mes_rec               in mcw_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
    ) is
        l_fpd_rec               mcw_api_type_pkg.t_fpd_rec;
        l_pds_tab               mcw_api_type_pkg.t_pds_tab;
        l_pds_body              mcw_api_type_pkg.t_pds_body;
        
        l_stage                 varchar2(100);
        l_current_version       com_api_type_pkg.t_tiny_id;
    begin
        l_current_version := 
            cmn_api_standard_pkg.get_current_version(
                i_network_id => i_network_id
            );
        trc_log_pkg.debug (
            i_text         => 'Processing incoming detail position, current_version='||l_current_version 
        );
        l_fpd_rec := null;
        
        l_stage := 'init';
        -- init
        l_fpd_rec.id := opr_api_create_pkg.get_id;
        l_fpd_rec.file_id := i_file_id;
        l_fpd_rec.network_id := i_network_id;
        l_fpd_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;

        l_stage := 'mti and de24 - de100';
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
            , i_param_name        => mcw_api_const_pkg.CMID
            , i_value_char        => l_fpd_rec.de093
        );

        if l_fpd_rec.inst_id is null then
            com_api_error_pkg.raise_error (
                i_error         => 'MCW_CMID_NOT_REGISTRED'
                , i_env_param1  => l_fpd_rec.de093
                , i_env_param2  => i_network_id
            );
        end if;
        
        l_stage := 'extract_pds';
        mcw_api_pds_pkg.extract_pds (
            de048     => i_mes_rec.de048
          , de062     => i_mes_rec.de062
          , de123     => i_mes_rec.de123
          , de124     => i_mes_rec.de124
          , de125     => i_mes_rec.de125
          , pds_tab   => l_pds_tab
        );
        l_stage := 'p0014';
        l_fpd_rec.p0014 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab => l_pds_tab
          , i_pds_tag => mcw_api_const_pkg.PDS_TAG_0014
        );
        l_stage := 'p0148';
        l_fpd_rec.p0148 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0148
        );
        l_stage := 'p0165';
        l_fpd_rec.p0165 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0165
        );
        l_stage := 'p0300';
        l_fpd_rec.p0300 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0300
        );
        l_stage := 'p0302';
        l_fpd_rec.p0302 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0302
        );
        l_stage := 'p0358';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0358
        );
        l_stage := 'parse_p0158';
        mcw_api_pds_pkg.parse_p0158 (
            i_p0158            => l_pds_body
            , o_p0158_1        => l_fpd_rec.p0358_1
            , o_p0158_2        => l_fpd_rec.p0358_2
            , o_p0158_3        => l_fpd_rec.p0358_3
            , o_p0158_4        => l_fpd_rec.p0358_4
            , o_p0158_5        => l_fpd_rec.p0358_5
            , o_p0158_6        => l_fpd_rec.p0358_6
            , o_p0158_7        => l_fpd_rec.p0358_7
            , o_p0158_8        => l_fpd_rec.p0358_8
            , o_p0158_9        => l_fpd_rec.p0358_9
            , o_p0158_10       => l_fpd_rec.p0358_10
            , o_p0158_11       => l_fpd_rec.p0358_11
            , o_p0158_12       => l_fpd_rec.p0358_12
            , o_p0158_13       => l_fpd_rec.p0358_13
            , o_p0158_14       => l_fpd_rec.p0358_14
        );
        l_stage := 'p0370';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0370
        );
        l_stage := 'parse_p0370';
        mcw_api_pds_pkg.parse_p0370 (
            i_p0370           => l_pds_body
            , o_p0370_1       => l_fpd_rec.p0370_1
            , o_p0370_2       => l_fpd_rec.p0370_2
        );
        l_stage := 'p0372';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0372
        );
        l_stage := 'parse_p0372';
        mcw_api_pds_pkg.parse_p0372 (
            i_p0372           => l_pds_body
            , o_p0372_1       => l_fpd_rec.p0372_1
            , o_p0372_2       => l_fpd_rec.p0372_2
        );
        l_stage := 'p0374';
        l_fpd_rec.p0374 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0374
        );
        l_stage := 'p0375';
        l_fpd_rec.p0375 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0375
        );
        l_stage := 'p0378';
        l_fpd_rec.p0378 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0378
        );
        l_stage := 'p0380';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0380
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0380'
            , o_p0380_1       => l_fpd_rec.p0380_1
            , o_p0380_2       => l_fpd_rec.p0380_2
        );
        l_stage := 'p0381';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0381
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0381'
            , o_p0380_1       => l_fpd_rec.p0381_1
            , o_p0380_2       => l_fpd_rec.p0381_2
        );
        l_stage := 'p0384';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0384
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0384'
            , o_p0380_1       => l_fpd_rec.p0384_1
            , o_p0380_2       => l_fpd_rec.p0384_2
        );
        l_stage := 'p0390';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0390
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0390'
            , o_p0380_1       => l_fpd_rec.p0390_1
            , o_p0380_2       => l_fpd_rec.p0390_2
        );
        l_stage := 'p0391';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0391
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0391'
            , o_p0380_1       => l_fpd_rec.p0391_1
            , o_p0380_2       => l_fpd_rec.p0391_2
        );
        l_stage := 'p0392';
        l_fpd_rec.p0392 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0392
        );
        l_stage := 'p0393';
        l_fpd_rec.p0393 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0393
        );
        l_stage := 'p0394';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0394
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0394'
            , o_p0380_1       => l_fpd_rec.p0394_1
            , o_p0380_2       => l_fpd_rec.p0394_2
        );
        l_stage := 'p0395';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0395
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0395'
            , o_p0380_1       => l_fpd_rec.p0395_1
            , o_p0380_2       => l_fpd_rec.p0395_2
        );
        l_stage := 'p0396';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0396
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0396'
            , o_p0380_1       => l_fpd_rec.p0396_1
            , o_p0380_2       => l_fpd_rec.p0396_2
        );

        l_stage := 'p0397';
        l_fpd_rec.p0397 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
          , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0397
        );
        l_stage := 'p0398';
        l_fpd_rec.p0398 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
          , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0398
        );
        l_stage := 'p0399';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
          , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0399
        );
        mcw_api_pds_pkg.parse_p0399 (
            i_pds_body        => l_pds_body
          , i_pds_name        => 'p0399'
          , o_p0399_1         => l_fpd_rec.p0399_1
          , o_p0399_2         => l_fpd_rec.p0399_2
        );

        l_stage := 'p0400';
        l_fpd_rec.p0400 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0400
        );
        l_stage := 'p0401';
        l_fpd_rec.p0401 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0401
        );
        l_stage := 'p0402';
        l_fpd_rec.p0402 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0402
        );

        l_stage := 'put_message';
        put_message (
            i_fpd_rec   => l_fpd_rec
        );

        l_stage := 'save_pds';
        mcw_api_pds_pkg.save_pds (
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
    
    procedure create_incoming_spd (
        i_mes_rec               in mcw_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
    ) is
        l_spd_rec               mcw_api_type_pkg.t_spd_rec;
        l_pds_tab               mcw_api_type_pkg.t_pds_tab;
        l_pds_body              mcw_api_type_pkg.t_pds_body;
        
        l_stage                 varchar2(100);
        l_current_version       com_api_type_pkg.t_tiny_id;
    begin
        l_current_version := 
            cmn_api_standard_pkg.get_current_version(
                i_network_id => i_network_id
            );
        trc_log_pkg.debug (
            i_text         => 'Processing incoming settlment position detail, current_version='||l_current_version 
        );
        l_spd_rec := null;
        
        l_stage := 'init';
        -- init
        l_spd_rec.id := opr_api_create_pkg.get_id;
        l_spd_rec.file_id := i_file_id;
        l_spd_rec.network_id := i_network_id;
        l_spd_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;

        l_stage := 'mti and de24 - de100';
        l_spd_rec.mti := i_mes_rec.mti;
        l_spd_rec.de024 := i_mes_rec.de024;
        l_spd_rec.de025 := i_mes_rec.de025;
        l_spd_rec.de049 := i_mes_rec.de049;
        l_spd_rec.de050 := i_mes_rec.de050;
        l_spd_rec.de071 := i_mes_rec.de071;
        l_spd_rec.de093 := i_mes_rec.de093;
        l_spd_rec.de100 := i_mes_rec.de100;
        
        l_spd_rec.inst_id := cmn_api_standard_pkg.find_value_owner (
            i_standard_id         => i_standard_id
            , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_object_id         => i_host_id
            , i_param_name        => mcw_api_const_pkg.CMID
            , i_value_char        => l_spd_rec.de093
        );

        if l_spd_rec.inst_id is null then
            com_api_error_pkg.raise_error (
                i_error         => 'MCW_CMID_NOT_REGISTRED'
                , i_env_param1  => l_spd_rec.de093
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
        l_stage := 'p0148';
        l_spd_rec.p0148 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0148
        );
        l_stage := 'p0300';
        l_spd_rec.p0300 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0300
        );
        l_stage := 'p0302';
        l_spd_rec.p0302 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0302
        );
        l_stage := 'p0359';
        l_spd_rec.p0359 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0359
        );
        l_stage := 'p0367';
        l_spd_rec.p0367 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0367
        );
        l_stage := 'p0368';
        l_spd_rec.p0368 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0368
        );
        l_stage := 'p0369';
        l_spd_rec.p0369 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0369
        );
        l_stage := 'p0370';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0370
        );
        l_stage := 'parse_p0370';
        mcw_api_pds_pkg.parse_p0370 (
            i_p0370           => l_pds_body
            , o_p0370_1       => l_spd_rec.p0370_1
            , o_p0370_2       => l_spd_rec.p0370_2
        );
        l_stage := 'p0390';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0390
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0390'
            , o_p0380_1       => l_spd_rec.p0390_1
            , o_p0380_2       => l_spd_rec.p0390_2
        );
        l_stage := 'p0391';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0391
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0391'
            , o_p0380_1       => l_spd_rec.p0391_1
            , o_p0380_2       => l_spd_rec.p0391_2
        );
        l_stage := 'p0392';
        l_spd_rec.p0392 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0392
        );
        l_stage := 'p0393';
        l_spd_rec.p0393 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0393
        );
        l_stage := 'p0394';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0394
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0394'
            , o_p0380_1       => l_spd_rec.p0394_1
            , o_p0380_2       => l_spd_rec.p0394_2
        );
        l_stage := 'p0395';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0395
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0395'
            , o_p0380_1       => l_spd_rec.p0395_1
            , o_p0380_2       => l_spd_rec.p0395_2
        );
        l_stage := 'p0396';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0396
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0396'
            , o_p0380_1       => l_spd_rec.p0396_1
            , o_p0380_2       => l_spd_rec.p0396_2
        );

        l_stage := 'p0397';
        l_spd_rec.p0397 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
          , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0397
        );

        l_stage := 'p0398';
        l_spd_rec.p0398 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
          , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0398
        );

        l_stage := 'p0399';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
          , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0399
        );
        mcw_api_pds_pkg.parse_p0399 (
            i_pds_body        => l_pds_body
          , i_pds_name        => 'p0399'
          , o_p0399_1         => l_spd_rec.p0399_1
          , o_p0399_2         => l_spd_rec.p0399_2
        );
        
        l_stage := 'put_message';
        put_message (
            i_spd_rec   => l_spd_rec
        );

        l_stage := 'save_pds';
        mcw_api_pds_pkg.save_pds (
            i_msg_id     => l_spd_rec.id
            , i_pds_tab  => l_pds_tab
        );
        
        trc_log_pkg.debug (
            i_text         => 'Incoming settlment position detail processed. Assigned id[#1]' 
            , i_env_param1 => l_spd_rec.id
        );
        
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error generating IPM settlment position detail on stage ' || l_stage || ': ' || sqlerrm 
            );
            
            raise;
    end;
    
    procedure create_incoming_fsum (
        i_mes_rec               in mcw_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
    ) is
        l_fsum_rec              mcw_api_type_pkg.t_fsum_rec;
        l_pds_tab               mcw_api_type_pkg.t_pds_tab;
        l_pds_body              mcw_api_type_pkg.t_pds_body;
        
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

        l_stage := 'mti and de24 - de100';
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
            , i_param_name        => mcw_api_const_pkg.CMID
            , i_value_char        => l_fsum_rec.de093
        );

        if l_fsum_rec.inst_id is null then
            com_api_error_pkg.raise_error (
                i_error         => 'MCW_CMID_NOT_REGISTRED'
                , i_env_param1  => l_fsum_rec.de093
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
        l_stage := 'p0148';
        l_fsum_rec.p0148 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0148
        );
        l_stage := 'p0300';
        l_fsum_rec.p0300 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0300
        );
        l_stage := 'p0380';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0380
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0380'
            , o_p0380_1       => l_fsum_rec.p0380_1
            , o_p0380_2       => l_fsum_rec.p0380_2
        );
        l_stage := 'p0381';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0381
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0381'
            , o_p0380_1       => l_fsum_rec.p0381_1
            , o_p0380_2       => l_fsum_rec.p0381_2
        );
        l_stage := 'p0384';
        l_pds_body := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0384
        );
        mcw_api_pds_pkg.parse_p0380 (
            i_pds_body        => l_pds_body
            , i_pds_name      => 'p0384'
            , o_p0380_1       => l_fsum_rec.p0384_1
            , o_p0380_2       => l_fsum_rec.p0384_2
        );
        l_stage := 'p0400';
        l_fsum_rec.p0400 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0400
        );
        l_stage := 'p0401';
        l_fsum_rec.p0401 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0401
        );
        l_stage := 'p0402';
        l_fsum_rec.p0402 := mcw_api_pds_pkg.get_pds_body (
            i_pds_tab         => l_pds_tab
            , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0402
        );
        
        l_stage := 'put_message';
        put_message (
            i_fsum_rec   => l_fsum_rec
        );

        l_stage := 'save_pds';
        mcw_api_pds_pkg.save_pds (
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
