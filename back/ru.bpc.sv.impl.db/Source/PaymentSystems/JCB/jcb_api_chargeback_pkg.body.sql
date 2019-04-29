create or replace package body jcb_api_chargeback_pkg is

    procedure gen_first_chargeback (
        o_fin_id                  out com_api_type_pkg.t_long_id
        , i_original_fin_id       in com_api_type_pkg.t_long_id
        , i_de004                 in jcb_api_type_pkg.t_de004
        , i_de049                 in jcb_api_type_pkg.t_de049
        , i_de024                 in jcb_api_type_pkg.t_de024
        , i_de025                 in jcb_api_type_pkg.t_de025
        , i_p3250                 in jcb_api_type_pkg.t_p3250
        , i_de072                 in jcb_api_type_pkg.t_de072
        , i_cashback_amount       in jcb_api_type_pkg.t_de004
    ) is
        l_original_fin_rec        jcb_api_type_pkg.t_fin_rec;
        l_buffer                  com_api_type_pkg.t_name;
        l_current                 com_api_type_pkg.t_name;
        l_amount                  com_api_type_pkg.t_money;
        l_fin_rec                 jcb_api_type_pkg.t_fin_rec;
        l_standard_id             com_api_type_pkg.t_tiny_id;
        l_standard_version        com_api_type_pkg.t_tiny_id;
        l_host_id                 com_api_type_pkg.t_tiny_id;
        l_stage                   varchar2(100);
         
    begin
        trc_log_pkg.debug (
            i_text         => 'Generating first chargeback'
        );
        
        l_stage := 'load original fin';
        jcb_api_fin_pkg.get_fin (
            i_id         => i_original_fin_id
            , o_fin_rec  => l_original_fin_rec
        );

        l_standard_version :=
            cmn_api_standard_pkg.get_current_version(
                i_network_id  => l_original_fin_rec.network_id
            );

        if l_original_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_PRESENTMENT
           and l_original_fin_rec.de024 = jcb_api_const_pkg.FUNC_CODE_FIRST_PRES
           and l_original_fin_rec.is_reversal = com_api_type_pkg.FALSE
           and l_original_fin_rec.is_incoming = com_api_type_pkg.TRUE
        then
            l_stage := 'init';
            -- init
            o_fin_id := opr_api_create_pkg.get_id;
            l_fin_rec.id := o_fin_id;

            l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
            l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
            l_fin_rec.is_reversal := com_api_type_pkg.FALSE;
            
            l_fin_rec.is_rejected := com_api_type_pkg.FALSE;

            l_fin_rec.inst_id    := l_original_fin_rec.inst_id;
            l_fin_rec.network_id := l_original_fin_rec.network_id;
            
            jcb_api_dispute_pkg.sync_dispute_id (
                io_fin_rec      => l_original_fin_rec
                , o_dispute_id  => l_fin_rec.dispute_id
                , o_dispute_rn  => l_fin_rec.dispute_rn
            );

            l_fin_rec.mti := jcb_api_const_pkg.MSG_TYPE_CHARGEBACK;

            l_fin_rec.de024 := i_de024;

            l_fin_rec.de002 := l_original_fin_rec.de002;
            l_fin_rec.de003_1 := l_original_fin_rec.de003_1;
            l_fin_rec.de003_2 := l_original_fin_rec.de003_2;
            l_fin_rec.de003_3 := jcb_api_const_pkg.DEFAULT_DE003_3;

            l_stage := 'get_message_impact';
            l_fin_rec.impact := jcb_utl_pkg.get_message_impact (
                i_mti           => l_fin_rec.mti
                , i_de024       => l_fin_rec.de024
                , i_de003_1     => l_fin_rec.de003_1
                , i_is_reversal => l_fin_rec.is_reversal
                , i_is_incoming => l_fin_rec.is_incoming
            );

            l_fin_rec.de004 := i_de004;
            l_fin_rec.de049 := i_de049;
            
            l_stage := 'add_curr_exp';
            jcb_utl_pkg.add_curr_exp (
                io_p3002       => l_fin_rec.p3002
                , i_curr_code  => l_fin_rec.de049
            );

            l_fin_rec.de012 := l_original_fin_rec.de012;
            l_fin_rec.de014 := l_original_fin_rec.de014;

            l_fin_rec.de022_1 := l_original_fin_rec.de022_1;
            l_fin_rec.de022_2 := l_original_fin_rec.de022_2;
            l_fin_rec.de022_3 := l_original_fin_rec.de022_3;
            l_fin_rec.de022_4 := l_original_fin_rec.de022_4;
            l_fin_rec.de022_5 := l_original_fin_rec.de022_5;
            l_fin_rec.de022_6 := l_original_fin_rec.de022_6;
            l_fin_rec.de022_7 := l_original_fin_rec.de022_7;
            l_fin_rec.de022_8 := l_original_fin_rec.de022_8;
            l_fin_rec.de022_9 := l_original_fin_rec.de022_9;
            l_fin_rec.de022_10 := l_original_fin_rec.de022_10;
            l_fin_rec.de022_11 := l_original_fin_rec.de022_11;
            l_fin_rec.de022_12 := l_original_fin_rec.de022_12;

            l_fin_rec.de023 := l_original_fin_rec.de023;
            l_fin_rec.de025 := i_de025;
            l_fin_rec.de026 := l_original_fin_rec.de026;
            l_fin_rec.de030_1 := l_original_fin_rec.de004;
            l_fin_rec.de030_2 := 0;
            l_fin_rec.de031 := l_original_fin_rec.de031;
            l_fin_rec.de032 := l_original_fin_rec.de032;
            l_fin_rec.de033 := l_original_fin_rec.de100;
            l_fin_rec.de037 := l_original_fin_rec.de037;
            l_fin_rec.de038 := l_original_fin_rec.de038;
            l_fin_rec.de040 := l_original_fin_rec.de040;
            l_fin_rec.de041 := l_original_fin_rec.de041;
            l_fin_rec.de042 := l_original_fin_rec.de042;
            l_fin_rec.de043_1 := l_original_fin_rec.de043_1;
            l_fin_rec.de043_2 := l_original_fin_rec.de043_2;
            l_fin_rec.de043_3 := l_original_fin_rec.de043_3;
            l_fin_rec.de043_4 := l_original_fin_rec.de043_4;
            l_fin_rec.de043_5 := l_original_fin_rec.de043_5;
            l_fin_rec.de043_6 := l_original_fin_rec.de043_6;

            if  (l_fin_rec.de024 in (jcb_api_const_pkg.FUNC_CODE_SECOND_PRES_PART
                                   , jcb_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                                   , jcb_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART
                                    )
                 or nvl(substr(l_original_fin_rec.de054, 9, 20), '000000000000') = '000000000000'
                )
                and l_standard_version >= jcb_api_const_pkg.STANDARD_ID_VERISON_18Q2
            then
                l_fin_rec.de054 := null;

            elsif   l_fin_rec.de004 = i_de004
                and l_standard_version >= jcb_api_const_pkg.STANDARD_ID_VERISON_18Q2
            then 
                l_fin_rec.de054  := l_original_fin_rec.de054;

            elsif l_original_fin_rec.de054 is not null then
                -- get de054
                l_buffer := l_original_fin_rec.de054;
                loop
                    -- next 20
                    l_current := substr(l_buffer, 1, 20);
                    -- after 20
                    l_buffer  := substr(l_buffer, 21);

                    -- if original currency not the same as chargeback currency
                    if substr(l_current, 5, 3) != l_fin_rec.de049 then
                        l_amount := round(com_api_rate_pkg.convert_amount(
                                                substr(l_current, 9)
                                              , substr(l_current, 5, 3)
                                              , l_fin_rec.de049
                                              , jcb_api_const_pkg.JCB_RATE_TYPE
                                              , l_fin_rec.inst_id
                                              , get_sysdate
                                              , 1
                                              , null
                                            ));
                        l_fin_rec.de054 := l_fin_rec.de054 || substr(l_current, 1, 4) || l_fin_rec.de049 || substr(l_current, 8, 1) || lpad(nvl(l_amount, 0), 12, '0'); 
                    else
                        l_fin_rec.de054 := l_fin_rec.de054 || l_current;
                    end if;

                    l_stage := 'add_curr_exp';
                    jcb_utl_pkg.add_curr_exp (
                        io_p3002       => l_fin_rec.p3002
                        , i_curr_code  => l_fin_rec.de049
                    );
                    
                    exit when l_buffer is null;
                    
                end loop;
            end if;

            l_stage := 'de055';
            l_fin_rec.de055 := l_original_fin_rec.de055;

            l_stage := 'de072 - de095';
            l_fin_rec.de072 := i_de072;
            l_fin_rec.de094 := l_original_fin_rec.de093;

            if l_standard_version < jcb_api_const_pkg.STANDARD_ID_VERISON_18Q2 then
                l_stage := 'add_curr_exp';
                jcb_utl_pkg.add_curr_exp(
                    io_p3002       => l_fin_rec.p3002
                    , i_curr_code  => null
                );
            end if;

            l_fin_rec.p3009 := l_original_fin_rec.p3009;
            l_fin_rec.p3250 := i_p3250;
            
            l_stage := 'put_message';
            jcb_api_fin_pkg.put_message (
                i_fin_rec  => l_fin_rec
            );

            l_stage := 'create_operation';
            l_host_id := net_api_network_pkg.get_default_host(
                i_network_id  => l_fin_rec.network_id
            );

            l_standard_id := 
                net_api_network_pkg.get_offline_standard(
                    i_host_id     => l_host_id
                );

            jcb_api_fin_pkg.create_operation (
                 i_fin_rec          => l_fin_rec
                , i_standard_id     => l_standard_id
            );

            l_stage := 'done';
        end if;
        
        trc_log_pkg.debug (
            i_text         => 'Generating first chargeback. Assigned id[#1]'
            , i_env_param1 => l_fin_rec.id
        );
        
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error generating first chargeback on stage ' || l_stage || ': ' || sqlerrm
            );

            raise;
     end;
     
    procedure gen_second_chargeback (
        o_fin_id                  out com_api_type_pkg.t_long_id
        , i_original_fin_id       in com_api_type_pkg.t_long_id
        , i_de004                 in jcb_api_type_pkg.t_de004
        , i_de049                 in jcb_api_type_pkg.t_de049
        , i_de024                 in jcb_api_type_pkg.t_de024
        , i_de025                 in jcb_api_type_pkg.t_de025
        , i_p3250                 in jcb_api_type_pkg.t_p3250
        , i_de072                 in jcb_api_type_pkg.t_de072
    ) is
        l_original_fin_rec        jcb_api_type_pkg.t_fin_rec;
        l_buffer                  com_api_type_pkg.t_name;
        l_current                 com_api_type_pkg.t_name;
        l_fin_rec                 jcb_api_type_pkg.t_fin_rec;
        l_standard_id             com_api_type_pkg.t_tiny_id;
        l_standard_version        com_api_type_pkg.t_tiny_id;
        l_host_id                 com_api_type_pkg.t_tiny_id;
        l_stage                   varchar2(100);

    begin
        trc_log_pkg.debug (
            i_text         => 'Generating second chargeback'
        );
        
        l_stage := 'load original fin';
        jcb_api_fin_pkg.get_fin (
            i_id         => i_original_fin_id
            , o_fin_rec  => l_original_fin_rec
        );

        l_standard_version :=
            cmn_api_standard_pkg.get_current_version(
                i_network_id  => l_original_fin_rec.network_id
            );

        if l_original_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_PRESENTMENT
           and l_original_fin_rec.de024 in (jcb_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
               , jcb_api_const_pkg.FUNC_CODE_SECOND_PRES_PART)
           and l_original_fin_rec.is_reversal = com_api_type_pkg.FALSE
           and l_original_fin_rec.is_incoming = com_api_type_pkg.TRUE
        then

            l_stage := 'init';
            -- init
            o_fin_id := opr_api_create_pkg.get_id;
            l_fin_rec.id := o_fin_id;

            l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
            l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
            l_fin_rec.is_reversal := com_api_type_pkg.FALSE;
            
            l_fin_rec.is_rejected := com_api_type_pkg.FALSE;

            l_fin_rec.inst_id := l_original_fin_rec.inst_id;
            l_fin_rec.network_id := l_original_fin_rec.network_id;

            jcb_api_dispute_pkg.sync_dispute_id (
                io_fin_rec      => l_original_fin_rec
                , o_dispute_id  => l_fin_rec.dispute_id
                , o_dispute_rn  => l_fin_rec.dispute_rn
            );

            l_fin_rec.mti := jcb_api_const_pkg.MSG_TYPE_CHARGEBACK;
            l_fin_rec.de024 := i_de024;
            
            l_fin_rec.de002 := l_original_fin_rec.de002;
            l_fin_rec.de003_1 := l_original_fin_rec.de003_1;
            l_fin_rec.de003_2 := l_original_fin_rec.de003_2;
            l_fin_rec.de003_3 := l_original_fin_rec.de003_3;

            l_stage := 'get_message_impact';
            l_fin_rec.impact := jcb_utl_pkg.get_message_impact (
                i_mti           => l_fin_rec.mti
                , i_de024       => l_fin_rec.de024
                , i_de003_1     => l_fin_rec.de003_1
                , i_is_reversal => l_fin_rec.is_reversal
                , i_is_incoming => l_fin_rec.is_incoming
            );

            l_fin_rec.de004 := i_de004;
            l_fin_rec.de049 := i_de049;
            
            l_stage := 'add_curr_exp';
            jcb_utl_pkg.add_curr_exp (
                io_p3002       => l_fin_rec.p3002
                , i_curr_code  => l_fin_rec.de049
            );

            l_fin_rec.de012 := l_original_fin_rec.de012;
            l_fin_rec.de014 := l_original_fin_rec.de014;

            l_fin_rec.de022_1 := l_original_fin_rec.de022_1;
            l_fin_rec.de022_2 := l_original_fin_rec.de022_2;
            l_fin_rec.de022_3 := l_original_fin_rec.de022_3;
            l_fin_rec.de022_4 := l_original_fin_rec.de022_4;
            l_fin_rec.de022_5 := l_original_fin_rec.de022_5;
            l_fin_rec.de022_6 := l_original_fin_rec.de022_6;
            l_fin_rec.de022_7 := l_original_fin_rec.de022_7;
            l_fin_rec.de022_8 := l_original_fin_rec.de022_8;
            l_fin_rec.de022_9 := l_original_fin_rec.de022_9;
            l_fin_rec.de022_10 := l_original_fin_rec.de022_10;
            l_fin_rec.de022_11 := l_original_fin_rec.de022_11;
            l_fin_rec.de022_12 := l_original_fin_rec.de022_12;

            l_fin_rec.de023 := l_original_fin_rec.de023;
            l_fin_rec.de025 := i_de025;
            l_fin_rec.de026 := l_original_fin_rec.de026;
            l_fin_rec.de030_1 := l_original_fin_rec.de030_1;
            l_fin_rec.de030_2 := 0;
            l_fin_rec.de031 := l_original_fin_rec.de031;
            l_fin_rec.de032 := l_original_fin_rec.de032;
            l_fin_rec.de033 := l_original_fin_rec.de100;
            l_fin_rec.de037 := l_original_fin_rec.de037;
            l_fin_rec.de038 := l_original_fin_rec.de038;
            l_fin_rec.de040 := l_original_fin_rec.de040;
            l_fin_rec.de041 := l_original_fin_rec.de041;
            l_fin_rec.de042 := l_original_fin_rec.de042;
            l_fin_rec.de043_1 := l_original_fin_rec.de043_1;
            l_fin_rec.de043_2 := l_original_fin_rec.de043_2;
            l_fin_rec.de043_3 := l_original_fin_rec.de043_3;
            l_fin_rec.de043_4 := l_original_fin_rec.de043_4;
            l_fin_rec.de043_5 := l_original_fin_rec.de043_5;
            l_fin_rec.de043_6 := l_original_fin_rec.de043_6;

            if  (l_fin_rec.de024 in (jcb_api_const_pkg.FUNC_CODE_SECOND_PRES_PART
                                   , jcb_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                                   , jcb_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART
                                    )
                 or nvl(substr(l_original_fin_rec.de054, 9, 20), '000000000000') = '000000000000'
                )
                and l_standard_version >= jcb_api_const_pkg.STANDARD_ID_VERISON_18Q2
            then
                l_fin_rec.de054 := null;

            elsif   l_fin_rec.de004 = i_de004
                and l_standard_version >= jcb_api_const_pkg.STANDARD_ID_VERISON_18Q2
            then
                l_fin_rec.de054  := l_original_fin_rec.de054;

            elsif l_original_fin_rec.de054 is not null then
                -- get de054
                l_buffer := l_original_fin_rec.de054;
                loop
                    -- next 20
                    l_current := substr(l_buffer, 1, 20);
                    -- after 20
                    l_buffer  := substr(l_buffer, 21);

                    l_fin_rec.de054 := l_fin_rec.de054 || l_current;
            
                    l_stage := 'add_curr_exp';
                    jcb_utl_pkg.add_curr_exp (
                        io_p3002       => l_fin_rec.p3002
                        , i_curr_code  => substr(l_current, 5, 3)
                    );
                    exit when l_buffer is null;
                end loop;
            end if;

            l_fin_rec.de055 := l_original_fin_rec.de055;
            
            l_stage := 'de072 - de095';
            l_fin_rec.de072 := i_de072;
            l_fin_rec.de094 := l_original_fin_rec.de093;

            l_stage := 'p3250';
            l_fin_rec.p3250 := i_p3250;

            l_stage := 'put_message';
            jcb_api_fin_pkg.put_message (
                i_fin_rec  => l_fin_rec
            );

            l_stage := 'create_operation';
            l_host_id := net_api_network_pkg.get_default_host(
                i_network_id  => l_fin_rec.network_id
            );
            l_standard_id := net_api_network_pkg.get_offline_standard (
                i_host_id       => l_host_id
            );
                
            jcb_api_fin_pkg.create_operation (
                i_fin_rec       => l_fin_rec
              , i_standard_id   => l_standard_id
            );

            l_stage := 'done';
        end if;
        
        trc_log_pkg.debug (
            i_text         => 'Generating second chargeback. Assigned id[#1]'
            , i_env_param1 => l_fin_rec.id
        );
        
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error generating second chargeback on stage ' || l_stage || ': ' || sqlerrm
            );

            raise;
    end;
     
    procedure gen_second_presentment (
        o_fin_id                  out com_api_type_pkg.t_long_id
        , i_original_fin_id       in com_api_type_pkg.t_long_id
        , i_de004                 in jcb_api_type_pkg.t_de004
        , i_de049                 in jcb_api_type_pkg.t_de049
        , i_de024                 in jcb_api_type_pkg.t_de024
        , i_de025                 in jcb_api_type_pkg.t_de025
        , i_p3250                 in jcb_api_type_pkg.t_p3250
        , i_de072                 in jcb_api_type_pkg.t_de072
    ) is
        l_original_fin_rec        jcb_api_type_pkg.t_fin_rec;
        l_first_pres_fin_rec      jcb_api_type_pkg.t_fin_rec;
        l_buffer                  com_api_type_pkg.t_name;
        l_current                 com_api_type_pkg.t_name;
        l_fin_rec                 jcb_api_type_pkg.t_fin_rec;
        l_standard_id             com_api_type_pkg.t_tiny_id;
        l_standard_version        com_api_type_pkg.t_tiny_id;
        l_host_id                 com_api_type_pkg.t_tiny_id;
        l_stage                   varchar2(100);
        l_auth                    aut_api_type_pkg.t_auth_rec;
    begin
        trc_log_pkg.debug (
            i_text         => 'Generating second presentment'
        );
        
        l_stage := 'load original fin';
        jcb_api_fin_pkg.get_fin (
            i_id         => i_original_fin_id
            , o_fin_rec  => l_original_fin_rec
        );

        l_standard_version :=
            cmn_api_standard_pkg.get_current_version(
                i_network_id  => l_original_fin_rec.network_id
            );

        if l_original_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_CHARGEBACK
           and l_original_fin_rec.de024 in (jcb_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
               , jcb_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART)
           and l_original_fin_rec.is_reversal = com_api_type_pkg.FALSE
           and l_original_fin_rec.is_incoming = com_api_type_pkg.TRUE
        then
            l_stage := 'init';
            -- init
            o_fin_id := opr_api_create_pkg.get_id;
            l_fin_rec.id := o_fin_id;

            l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
            l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
            l_fin_rec.is_reversal := com_api_type_pkg.FALSE;
            
            l_fin_rec.is_rejected := com_api_type_pkg.FALSE;

            l_fin_rec.inst_id := l_original_fin_rec.inst_id;
            l_fin_rec.network_id := l_original_fin_rec.network_id;

            jcb_api_dispute_pkg.sync_dispute_id (
                io_fin_rec      => l_original_fin_rec
                , o_dispute_id  => l_fin_rec.dispute_id
                , o_dispute_rn  => l_fin_rec.dispute_rn
            );

            l_fin_rec.mti := jcb_api_const_pkg.MSG_TYPE_PRESENTMENT;
            l_fin_rec.de024 := i_de024;
            
            l_fin_rec.de002 := l_original_fin_rec.de002;
            l_fin_rec.de003_1 := l_original_fin_rec.de003_1;
            l_fin_rec.de003_2 := l_original_fin_rec.de003_2;
            l_fin_rec.de003_3 := l_original_fin_rec.de003_3;

            l_stage := 'get_message_impact';
            l_fin_rec.impact := jcb_utl_pkg.get_message_impact (
                i_mti           => l_fin_rec.mti
                , i_de024       => l_fin_rec.de024
                , i_de003_1     => l_fin_rec.de003_1
                , i_is_reversal => l_fin_rec.is_reversal
                , i_is_incoming => l_fin_rec.is_incoming
            );

            l_fin_rec.de004 := i_de004;
            l_fin_rec.de049 := i_de049;
            
            l_stage := 'add_curr_exp';
            jcb_utl_pkg.add_curr_exp (
                io_p3002       => l_fin_rec.p3002
                , i_curr_code  => l_fin_rec.de049
            );

            l_fin_rec.de012 := l_original_fin_rec.de012;
            l_fin_rec.de014 := l_original_fin_rec.de014;

            l_fin_rec.de022_1 := l_original_fin_rec.de022_1;
            l_fin_rec.de022_2 := l_original_fin_rec.de022_2;
            l_fin_rec.de022_3 := l_original_fin_rec.de022_3;
            l_fin_rec.de022_4 := l_original_fin_rec.de022_4;
            l_fin_rec.de022_5 := l_original_fin_rec.de022_5;
            l_fin_rec.de022_6 := l_original_fin_rec.de022_6;
            l_fin_rec.de022_7 := l_original_fin_rec.de022_7;
            l_fin_rec.de022_8 := l_original_fin_rec.de022_8;
            l_fin_rec.de022_9 := l_original_fin_rec.de022_9;
            l_fin_rec.de022_10 := l_original_fin_rec.de022_10;
            l_fin_rec.de022_11 := l_original_fin_rec.de022_11;
            l_fin_rec.de022_12 := l_original_fin_rec.de022_12;

            l_fin_rec.de023 := l_original_fin_rec.de023;
            l_fin_rec.de025 := i_de025;
            l_fin_rec.de026 := l_original_fin_rec.de026;
            l_fin_rec.de030_1 := l_original_fin_rec.de030_1;
            l_fin_rec.de030_2 := 0;
            l_fin_rec.de031 := l_original_fin_rec.de031;
            l_fin_rec.de032 := l_original_fin_rec.de032;
            l_fin_rec.de033 := l_original_fin_rec.de100;
            l_fin_rec.de037 := l_original_fin_rec.de037;
            l_fin_rec.de038 := l_original_fin_rec.de038;
            l_fin_rec.de040 := l_original_fin_rec.de040;
            l_fin_rec.de041 := l_original_fin_rec.de041;
            l_fin_rec.de042 := l_original_fin_rec.de042;
            l_fin_rec.de043_1 := l_original_fin_rec.de043_1;
            l_fin_rec.de043_2 := l_original_fin_rec.de043_2;
            l_fin_rec.de043_3 := l_original_fin_rec.de043_3;
            l_fin_rec.de043_4 := l_original_fin_rec.de043_4;
            l_fin_rec.de043_5 := l_original_fin_rec.de043_5;
            l_fin_rec.de043_6 := l_original_fin_rec.de043_6;

            if  (l_fin_rec.de024 in (jcb_api_const_pkg.FUNC_CODE_SECOND_PRES_PART
                                   , jcb_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                                   , jcb_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART
                                    )
                 or nvl(substr(l_original_fin_rec.de054, 9, 20), '000000000000') = '000000000000' 
                )
                and l_standard_version >= jcb_api_const_pkg.STANDARD_ID_VERISON_18Q2
            then
                l_fin_rec.de054 := null;

            elsif   l_fin_rec.de004 = i_de004
                and l_standard_version >= jcb_api_const_pkg.STANDARD_ID_VERISON_18Q2
            then
                l_fin_rec.de054  := l_original_fin_rec.de054;

            elsif l_original_fin_rec.de054 is not null then
                -- get de054
                l_buffer := l_original_fin_rec.de054;
                loop
                    -- next 20
                    l_current := substr(l_buffer, 1, 20);
                    -- after 20
                    l_buffer  := substr(l_buffer, 21);

                    l_fin_rec.de054 := l_fin_rec.de054 || l_current;
            
                    l_stage := 'add_curr_exp';
                    jcb_utl_pkg.add_curr_exp (
                        io_p3002       => l_fin_rec.p3002
                        , i_curr_code  => substr(l_current, 5, 3)
                    );
                    exit when l_buffer is null;
                end loop;
            end if;

            l_stage := 'de055 - de094';
            l_fin_rec.de055 := l_original_fin_rec.de055;
            l_fin_rec.de072 := i_de072;
            l_fin_rec.de094 := l_original_fin_rec.de093;

            l_stage := 'p3250';
            l_fin_rec.p3250 := i_p3250;

            l_stage := 'put_message';
            jcb_api_fin_pkg.put_message (
                i_fin_rec  => l_fin_rec
            );
            
            l_stage := 'create_operation';
            l_host_id := net_api_network_pkg.get_default_host(
                i_network_id  => l_fin_rec.network_id
            );
            l_standard_id := net_api_network_pkg.get_offline_standard (
                i_host_id       => l_host_id
            );
                           
            jcb_api_fin_pkg.create_operation (
                i_fin_rec       => l_fin_rec
              , i_standard_id   => l_standard_id
            );

            l_stage := 'done';
        end if;
        
        trc_log_pkg.debug (
            i_text         => 'Generating second presentment. Assigned id[#1]'
            , i_env_param1 => l_fin_rec.id
        );
        
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error generating second presentment on stage ' || l_stage || ': ' || sqlerrm
            );

            raise;
    end;
    
end;
/

