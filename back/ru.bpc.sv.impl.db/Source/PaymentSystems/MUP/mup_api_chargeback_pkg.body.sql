create or replace package body mup_api_chargeback_pkg is

    procedure get_chargback_pds(
        i_id                      in     com_api_type_pkg.t_long_id
      , i_id_new                  in     com_api_type_pkg.t_long_id
    ) is
        l_pds_tab_orig            mup_api_type_pkg.t_pds_tab;
        l_pds_tab                 mup_api_type_pkg.t_pds_tab;
    begin
        mup_api_pds_pkg.read_pds(
            i_msg_id   => i_id
          , o_pds_tab  => l_pds_tab_orig
        );
            
        mup_api_pds_pkg.set_pds_body(
            io_pds_tab => l_pds_tab
          , i_pds_tag  => 58
          , i_pds_body => mup_api_pds_pkg.get_pds_body(
                              i_pds_tab => l_pds_tab_orig
                            , i_pds_tag => 58 
                          )
        );

        mup_api_pds_pkg.set_pds_body(
            io_pds_tab => l_pds_tab
          , i_pds_tag  => 59
          , i_pds_body => mup_api_pds_pkg.get_pds_body(
                              i_pds_tab => l_pds_tab_orig
                            , i_pds_tag => 59 
                          )
        ); 
           
        mup_api_pds_pkg.save_pds(
            i_msg_id   => i_id_new
          , i_pds_tab  => l_pds_tab
        );
    end;

    procedure gen_first_chargeback (
        o_fin_id              out com_api_type_pkg.t_long_id
      , i_original_fin_id  in     com_api_type_pkg.t_long_id
      , i_de004            in     mup_api_type_pkg.t_de004
      , i_de049            in     mup_api_type_pkg.t_de049
      , i_de024            in     mup_api_type_pkg.t_de024
      , i_de025            in     mup_api_type_pkg.t_de025
      , i_p0262            in     mup_api_type_pkg.t_p0262
      , i_de072            in     mup_api_type_pkg.t_de072
      , i_p2072_1          in     mup_api_type_pkg.t_p2072_1
      , i_p2072_2          in     mup_api_type_pkg.t_p2072_2
      , i_cashback_amount  in     mup_api_type_pkg.t_de004
    ) is
        l_original_fin_rec        mup_api_type_pkg.t_fin_rec;
        l_buffer                  com_api_type_pkg.t_name;
        l_current                 com_api_type_pkg.t_name;
        l_amount                  com_api_type_pkg.t_money;
        l_fin_rec                 mup_api_type_pkg.t_fin_rec;
        l_standard_id             com_api_type_pkg.t_tiny_id;
        l_host_id                 com_api_type_pkg.t_tiny_id;
        l_stage                   com_api_type_pkg.t_name;
         
    begin
        trc_log_pkg.debug (
            i_text         => 'Generating first chargeback'
        );
        
        l_stage := 'load original fin';
        mup_api_fin_pkg.get_fin (
            i_id       => i_original_fin_id
          , o_fin_rec  => l_original_fin_rec
        );

        if l_original_fin_rec.mti             = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
           and l_original_fin_rec.de024       = mup_api_const_pkg.FUNC_CODE_FIRST_PRES
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
            l_fin_rec.is_fpd_matched := com_api_type_pkg.FALSE;
            l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;

            l_fin_rec.inst_id := l_original_fin_rec.inst_id;
            l_fin_rec.network_id := l_original_fin_rec.network_id;

            l_host_id := net_api_network_pkg.get_default_host(
                i_network_id  => l_fin_rec.network_id
            );
            l_standard_id := net_api_network_pkg.get_offline_standard (
                i_host_id     => l_host_id
            );

            mup_api_dispute_pkg.sync_dispute_id (
                io_fin_rec    => l_original_fin_rec
              , o_dispute_id  => l_fin_rec.dispute_id
              , o_dispute_rn  => l_fin_rec.dispute_rn
            );

            l_fin_rec.mti := mup_api_const_pkg.MSG_TYPE_CHARGEBACK;
            l_fin_rec.de024 := i_de024;

            l_fin_rec.de002 := l_original_fin_rec.de002;
            l_fin_rec.de003_1 := l_original_fin_rec.de003_1;
            l_fin_rec.de003_2 := l_original_fin_rec.de003_2;
            l_fin_rec.de003_3 := mup_api_const_pkg.DEFAULT_DE003_3;

            if i_de024 = mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL then
                l_fin_rec.de004 := l_original_fin_rec.de005;
                l_fin_rec.de049 := l_original_fin_rec.de050;
            else
                l_fin_rec.de004 := i_de004;
                l_fin_rec.de049 := i_de049;
            end if;
            
            l_stage := 'add_curr_exp';
            mup_utl_pkg.add_curr_exp (
                io_p0148     => l_fin_rec.p0148
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
            
            if l_original_fin_rec.de054 is not null then
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
                                              , 'RTTPCBRF'
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
                    mup_utl_pkg.add_curr_exp (
                        io_p0148       => l_fin_rec.p0148
                        , i_curr_code  => l_fin_rec.de049
                    );
                    exit when l_buffer is null;
                end loop;
            end if;

            l_fin_rec.de055 := l_original_fin_rec.de055;

            l_stage := 'emv';
            l_fin_rec.emv_9f26 := l_original_fin_rec.emv_9f26;
            l_fin_rec.emv_9f02 := l_original_fin_rec.emv_9f02;
            l_fin_rec.emv_9f27 := l_original_fin_rec.emv_9f27;
            l_fin_rec.emv_9F10 := l_original_fin_rec.emv_9F10;
            l_fin_rec.emv_9F36 := l_original_fin_rec.emv_9F36;
            l_fin_rec.emv_95 := l_original_fin_rec.emv_95;
            l_fin_rec.emv_82 := l_original_fin_rec.emv_82;
            l_fin_rec.emv_9a := l_original_fin_rec.emv_9a;
            l_fin_rec.emv_9c := l_original_fin_rec.emv_9c;
            l_fin_rec.emv_9f37 := l_original_fin_rec.emv_9f37;
            l_fin_rec.emv_5f2a := l_original_fin_rec.emv_5f2a;
            l_fin_rec.emv_9f33 := l_original_fin_rec.emv_9f33;
            l_fin_rec.emv_9f34 := l_original_fin_rec.emv_9f34;
            l_fin_rec.emv_9f1a := l_original_fin_rec.emv_9f1a;
            l_fin_rec.emv_9f35 := l_original_fin_rec.emv_9f35;
            l_fin_rec.emv_9f53 := l_original_fin_rec.emv_9f53;
            l_fin_rec.emv_84 := l_original_fin_rec.emv_84;
            l_fin_rec.emv_9f09 := l_original_fin_rec.emv_9f09;
            l_fin_rec.emv_9f03 := l_original_fin_rec.emv_9f03;
            l_fin_rec.emv_9f1e := l_original_fin_rec.emv_9f1e;
            l_fin_rec.emv_9f41 := l_original_fin_rec.emv_9f41;
            l_fin_rec.emv_9f4C := l_original_fin_rec.emv_9f4C;
            l_fin_rec.emv_91 := l_original_fin_rec.emv_91;

            l_stage := 'de063 - de095';
            l_fin_rec.de063 := l_original_fin_rec.de063;
            l_fin_rec.de072 := i_de072;
            l_fin_rec.de093 := l_original_fin_rec.de094;
            l_fin_rec.de094 := l_original_fin_rec.de093;
            l_fin_rec.de095 := mup_utl_pkg.build_irn;

            l_stage := 'p0149_1 - p0149_2';
            l_fin_rec.p0149_1 := l_original_fin_rec.de049;
            l_fin_rec.p0149_2 := 0;
            
            l_stage := 'add_curr_exp';
            mup_utl_pkg.add_curr_exp (
                io_p0148       => l_fin_rec.p0148
                , i_curr_code  => l_fin_rec.p0149_1
            );

            l_fin_rec.p2158_1 := l_original_fin_rec.p2158_1;
            l_fin_rec.p2158_2 := l_original_fin_rec.p2158_2;
            l_fin_rec.p2158_3 := l_original_fin_rec.p2158_3;
            l_fin_rec.p2158_4 := l_original_fin_rec.p2158_4;
            l_fin_rec.p2158_5 := l_original_fin_rec.p2158_5;
            l_fin_rec.p2158_6 := l_original_fin_rec.p2158_6;
            l_fin_rec.p0165 := l_original_fin_rec.p0165;
            
            l_fin_rec.p0262 := i_p0262;
            l_fin_rec.p2002 := l_original_fin_rec.p2002;
            l_fin_rec.p2063 := l_original_fin_rec.p2063;
            if i_p2072_2 is not null then
                l_fin_rec.p2072_1 := nvl(i_p2072_1,'CYR');
            else
                l_fin_rec.p2072_1 := null;
            end if;
            l_fin_rec.p2072_2 := i_p2072_2;

            l_fin_rec.p2175_1 := l_original_fin_rec.p2175_1;
            l_fin_rec.p2175_2 := l_original_fin_rec.p2175_2;
    
            if l_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL then
                l_fin_rec.p0268_1 := l_fin_rec.de030_1;
                l_fin_rec.p0268_2 := l_fin_rec.p0149_1;
                
            elsif i_de049 = l_fin_rec.p0149_1 then
                l_fin_rec.p0268_1 := i_de004;
                l_fin_rec.p0268_2 := i_de049;
                
            end if;
            
            l_stage := 'add_curr_exp';
            mup_utl_pkg.add_curr_exp (
                io_p0148       => l_fin_rec.p0148
                , i_curr_code  => l_fin_rec.p0268_2
            );
            
            l_stage := 'put_message';
            mup_api_fin_pkg.put_message (
                i_fin_rec  => l_fin_rec
            );

            get_chargback_pds(
                i_id => l_original_fin_rec.id
                , i_id_new => l_fin_rec.id
            );

            l_stage := 'create_operation';

            mup_api_fin_pkg.create_operation (
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
        o_fin_id              out com_api_type_pkg.t_long_id
      , i_original_fin_id  in     com_api_type_pkg.t_long_id
      , i_de004            in     mup_api_type_pkg.t_de004
      , i_de049            in     mup_api_type_pkg.t_de049
      , i_de024            in     mup_api_type_pkg.t_de024
      , i_de025            in     mup_api_type_pkg.t_de025
      , i_p0262            in     mup_api_type_pkg.t_p0262
      , i_de072            in     mup_api_type_pkg.t_de072
      , i_p2072_1          in     mup_api_type_pkg.t_p2072_1
      , i_p2072_2          in     mup_api_type_pkg.t_p2072_2
    ) is
        l_original_fin_rec        mup_api_type_pkg.t_fin_rec;
        l_buffer                  com_api_type_pkg.t_name;
        l_current                 com_api_type_pkg.t_name;
        l_fin_rec                 mup_api_type_pkg.t_fin_rec;
        l_standard_id             com_api_type_pkg.t_tiny_id;
        l_host_id                 com_api_type_pkg.t_tiny_id;
        l_stage                   com_api_type_pkg.t_name;

    begin
        trc_log_pkg.debug (
            i_text         => 'Generating second chargeback'
        );
        
        l_stage := 'load original fin';
        mup_api_fin_pkg.get_fin (
            i_id       => i_original_fin_id
          , o_fin_rec  => l_original_fin_rec
        );
        
        if l_original_fin_rec.mti             = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
           and l_original_fin_rec.de024     in (mup_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
                                              , mup_api_const_pkg.FUNC_CODE_SECOND_PRES_PART)
           and l_original_fin_rec.is_reversal = com_api_type_pkg.FALSE
           and l_original_fin_rec.is_incoming = com_api_type_pkg.TRUE
        then
            l_stage := 'init';
            -- init
            o_fin_id := opr_api_create_pkg.get_id;
            l_fin_rec.id := o_fin_id;

            l_fin_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
            l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
            l_fin_rec.is_reversal := com_api_type_pkg.FALSE;
            
            l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
            l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
            l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;

            l_fin_rec.inst_id    := l_original_fin_rec.inst_id;
            l_fin_rec.network_id := l_original_fin_rec.network_id;
         
            l_host_id := net_api_network_pkg.get_default_host(
                i_network_id  => l_fin_rec.network_id
            );
            l_standard_id := net_api_network_pkg.get_offline_standard (
                i_host_id       => l_host_id
            );

            mup_api_dispute_pkg.sync_dispute_id (
                io_fin_rec      => l_original_fin_rec
                , o_dispute_id  => l_fin_rec.dispute_id
                , o_dispute_rn  => l_fin_rec.dispute_rn
            );

            l_fin_rec.mti := mup_api_const_pkg.MSG_TYPE_CHARGEBACK;
            l_fin_rec.de024 := i_de024;
            
            l_fin_rec.de002 := l_original_fin_rec.de002;
            l_fin_rec.de003_1 := l_original_fin_rec.de003_1;
            l_fin_rec.de003_2 := l_original_fin_rec.de003_2;
            l_fin_rec.de003_3 := l_original_fin_rec.de003_3;

            if i_de024 = mup_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL then
                l_fin_rec.de004 := l_original_fin_rec.de005;
                l_fin_rec.de049 := l_original_fin_rec.de050;
            else
                l_fin_rec.de004 := i_de004;
                l_fin_rec.de049 := i_de049;
            end if;

            l_stage := 'add_curr_exp';
            mup_utl_pkg.add_curr_exp (
                io_p0148       => l_fin_rec.p0148
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

            if l_original_fin_rec.de054 is not null then
                -- get de054
                l_buffer := l_original_fin_rec.de054;
                loop
                    -- next 20
                    l_current := substr(l_buffer, 1, 20);
                    -- after 20
                    l_buffer  := substr(l_buffer, 21);

                    l_fin_rec.de054 := l_fin_rec.de054 || l_current;
            
                    l_stage := 'add_curr_exp';
                    mup_utl_pkg.add_curr_exp (
                        io_p0148       => l_fin_rec.p0148
                        , i_curr_code  => substr(l_current, 5, 3)
                    );
                    exit when l_buffer is null;
                end loop;
            end if;

            l_fin_rec.de055 := l_original_fin_rec.de055;
            
            l_stage := 'emv';
            l_fin_rec.emv_9f26 := l_original_fin_rec.emv_9f26;
            l_fin_rec.emv_9f02 := l_original_fin_rec.emv_9f02;
            l_fin_rec.emv_9f27 := l_original_fin_rec.emv_9f27;
            l_fin_rec.emv_9F10 := l_original_fin_rec.emv_9F10;
            l_fin_rec.emv_9F36 := l_original_fin_rec.emv_9F36;
            l_fin_rec.emv_95 := l_original_fin_rec.emv_95;
            l_fin_rec.emv_82 := l_original_fin_rec.emv_82;
            l_fin_rec.emv_9a := l_original_fin_rec.emv_9a;
            l_fin_rec.emv_9c := l_original_fin_rec.emv_9c;
            l_fin_rec.emv_9f37 := l_original_fin_rec.emv_9f37;
            l_fin_rec.emv_5f2a := l_original_fin_rec.emv_5f2a;
            l_fin_rec.emv_9f33 := l_original_fin_rec.emv_9f33;
            l_fin_rec.emv_9f34 := l_original_fin_rec.emv_9f34;
            l_fin_rec.emv_9f1a := l_original_fin_rec.emv_9f1a;
            l_fin_rec.emv_9f35 := l_original_fin_rec.emv_9f35;
            l_fin_rec.emv_9f53 := l_original_fin_rec.emv_9f53;
            l_fin_rec.emv_84 := l_original_fin_rec.emv_84;
            l_fin_rec.emv_9f09 := l_original_fin_rec.emv_9f09;
            l_fin_rec.emv_9f03 := l_original_fin_rec.emv_9f03;
            l_fin_rec.emv_9f1e := l_original_fin_rec.emv_9f1e;
            l_fin_rec.emv_9f41 := l_original_fin_rec.emv_9f41;
            l_fin_rec.emv_9f4C := l_original_fin_rec.emv_9f4C;
            l_fin_rec.emv_91 := l_original_fin_rec.emv_91;

            l_stage := 'de063 - de095';
            l_fin_rec.de063 := l_original_fin_rec.de063;
            l_fin_rec.de072 := i_de072;
            l_fin_rec.de093 := l_original_fin_rec.de094;
            l_fin_rec.de094 := l_original_fin_rec.de093;
            l_fin_rec.de095 := l_original_fin_rec.de095;

            l_stage := 'p0149_1 - p0149_2';
            l_fin_rec.p0149_1 := l_original_fin_rec.p0149_1;
            l_fin_rec.p0149_2 := l_original_fin_rec.p0149_2;
            
            l_stage := 'add_curr_exp';
            mup_utl_pkg.add_curr_exp (
                io_p0148       => l_fin_rec.p0148
                , i_curr_code  => l_fin_rec.p0149_1
            );

            l_fin_rec.p2158_1 := l_original_fin_rec.p2158_1;
            l_fin_rec.p2158_2 := l_original_fin_rec.p2158_2;
            l_fin_rec.p2158_3 := l_original_fin_rec.p2158_3;
            l_fin_rec.p2158_4 := l_original_fin_rec.p2158_4;
            l_fin_rec.p2158_5 := l_original_fin_rec.p2158_5;
            l_fin_rec.p2158_6 := l_original_fin_rec.p2158_6;
            l_fin_rec.p0165 := l_original_fin_rec.p0165;

            l_fin_rec.p2002 := l_original_fin_rec.p2002;
            l_fin_rec.p2063 := l_original_fin_rec.p2063;

            l_fin_rec.p0262 := i_p0262;
            if i_p2072_2 is not null then
                l_fin_rec.p2072_1 := nvl(i_p2072_1,'CYR');
            else
                l_fin_rec.p2072_1 := null;
            end if;
            l_fin_rec.p2072_2 := i_p2072_2;
          
            l_fin_rec.p2175_1 := l_original_fin_rec.p2175_1;
            l_fin_rec.p2175_2 := l_original_fin_rec.p2175_2;
        
            if l_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL then
                l_fin_rec.p0268_1 := l_fin_rec.de030_1;
                l_fin_rec.p0268_2 := l_fin_rec.p0149_1;
                
            elsif l_fin_rec.p0149_1 = i_de049 then
                l_fin_rec.p0268_1 := i_de004;
                l_fin_rec.p0268_2 := i_de049;
                
            end if;
            
            l_stage := 'add_curr_exp';
            mup_utl_pkg.add_curr_exp (
                io_p0148       => l_fin_rec.p0148
                , i_curr_code  => l_fin_rec.p0268_2
            );
            
            l_stage := 'put_message';
            mup_api_fin_pkg.put_message (
                i_fin_rec  => l_fin_rec
            );

            get_chargback_pds(
                i_id     => l_original_fin_rec.id
              , i_id_new => l_fin_rec.id
            );            
            
            l_stage := 'create_operation';
            mup_api_fin_pkg.create_operation (
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
        o_fin_id              out com_api_type_pkg.t_long_id
      , i_original_fin_id  in     com_api_type_pkg.t_long_id
      , i_de004            in     mup_api_type_pkg.t_de004
      , i_de049            in     mup_api_type_pkg.t_de049
      , i_de024            in     mup_api_type_pkg.t_de024
      , i_de025            in     mup_api_type_pkg.t_de025
      , i_p0262            in     mup_api_type_pkg.t_p0262
      , i_de072            in     mup_api_type_pkg.t_de072
      , i_p2072_1          in     mup_api_type_pkg.t_p2072_1
      , i_p2072_2          in     mup_api_type_pkg.t_p2072_2
    ) is
        l_original_fin_rec        mup_api_type_pkg.t_fin_rec;
        l_first_pres_fin_rec      mup_api_type_pkg.t_fin_rec;
        l_buffer                  com_api_type_pkg.t_name;
        l_current                 com_api_type_pkg.t_name;
        l_fin_rec                 mup_api_type_pkg.t_fin_rec;
        l_standard_id             com_api_type_pkg.t_tiny_id;
        l_host_id                 com_api_type_pkg.t_tiny_id;
        l_stage                   com_api_type_pkg.t_name;
        l_auth                    aut_api_type_pkg.t_auth_rec;     
    begin
        trc_log_pkg.debug (
            i_text         => 'Generating second presentment'
        );
        
        l_stage := 'load original fin';
        mup_api_fin_pkg.get_fin (
            i_id       => i_original_fin_id
          , o_fin_rec  => l_original_fin_rec
        );
   
        if l_original_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_CHARGEBACK
           and l_original_fin_rec.de024 in (mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
               , mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART)
           and l_original_fin_rec.is_reversal = com_api_type_pkg.FALSE
           and l_original_fin_rec.is_incoming = com_api_type_pkg.TRUE
        then
            l_stage := 'init';
            -- init
            o_fin_id     := opr_api_create_pkg.get_id;
            l_fin_rec.id := o_fin_id;

            l_fin_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
            l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
            l_fin_rec.is_reversal := com_api_type_pkg.FALSE;
            
            l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
            l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
            l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;

            l_fin_rec.inst_id    := l_original_fin_rec.inst_id;
            l_fin_rec.network_id := l_original_fin_rec.network_id;
       
            l_host_id := net_api_network_pkg.get_default_host(
                i_network_id  => l_fin_rec.network_id
            );
            l_standard_id := net_api_network_pkg.get_offline_standard (
                i_host_id       => l_host_id
            );
      
            mup_api_dispute_pkg.sync_dispute_id (
                io_fin_rec    => l_original_fin_rec
              , o_dispute_id  => l_fin_rec.dispute_id
              , o_dispute_rn  => l_fin_rec.dispute_rn
            );

            l_fin_rec.mti   := mup_api_const_pkg.MSG_TYPE_PRESENTMENT;
            l_fin_rec.de024 := i_de024;
            
            l_fin_rec.de002   := l_original_fin_rec.de002;
            l_fin_rec.de003_1 := l_original_fin_rec.de003_1;
            l_fin_rec.de003_2 := l_original_fin_rec.de003_2;
            l_fin_rec.de003_3 := l_original_fin_rec.de003_3;

            l_fin_rec.de004 := i_de004;
            l_fin_rec.de049 := i_de049;
            
            l_stage := 'add_curr_exp';
            mup_utl_pkg.add_curr_exp (
                io_p0148       => l_fin_rec.p0148
                , i_curr_code  => l_fin_rec.de049
            );

            l_fin_rec.de012 := l_original_fin_rec.de012;
            l_fin_rec.de014 := l_original_fin_rec.de014;

            l_fin_rec.de022_1  := l_original_fin_rec.de022_1;
            l_fin_rec.de022_2  := l_original_fin_rec.de022_2;
            l_fin_rec.de022_3  := l_original_fin_rec.de022_3;
            l_fin_rec.de022_4  := l_original_fin_rec.de022_4;
            l_fin_rec.de022_5  := l_original_fin_rec.de022_5;
            l_fin_rec.de022_6  := l_original_fin_rec.de022_6;
            l_fin_rec.de022_7  := l_original_fin_rec.de022_7;
            l_fin_rec.de022_8  := l_original_fin_rec.de022_8;
            l_fin_rec.de022_9  := l_original_fin_rec.de022_9;
            l_fin_rec.de022_10 := l_original_fin_rec.de022_10;
            l_fin_rec.de022_11 := l_original_fin_rec.de022_11;

            l_fin_rec.de023   := l_original_fin_rec.de023;
            l_fin_rec.de025   := i_de025;
            l_fin_rec.de026   := l_original_fin_rec.de026;
            l_fin_rec.de030_1 := l_original_fin_rec.de030_1;
            l_fin_rec.de030_2 := 0;
            l_fin_rec.de031   := l_original_fin_rec.de031;
            l_fin_rec.de032   := l_original_fin_rec.de032;
            l_fin_rec.de033   := l_original_fin_rec.de100;
            l_fin_rec.de037   := l_original_fin_rec.de037;
            l_fin_rec.de038   := l_original_fin_rec.de038;
            l_fin_rec.de040   := l_original_fin_rec.de040;
            l_fin_rec.de041   := l_original_fin_rec.de041;
            l_fin_rec.de042   := l_original_fin_rec.de042;
            l_fin_rec.de043_1 := l_original_fin_rec.de043_1;
            l_fin_rec.de043_2 := l_original_fin_rec.de043_2;
            l_fin_rec.de043_3 := l_original_fin_rec.de043_3;
            l_fin_rec.de043_4 := l_original_fin_rec.de043_4;
            l_fin_rec.de043_5 := l_original_fin_rec.de043_5;
            l_fin_rec.de043_6 := l_original_fin_rec.de043_6;

            if l_original_fin_rec.de054 is not null then
                -- get de054
                l_buffer := l_original_fin_rec.de054;
                loop
                    -- next 20
                    l_current := substr(l_buffer, 1, 20);
                    -- after 20
                    l_buffer  := substr(l_buffer, 21);

                    l_fin_rec.de054 := l_fin_rec.de054 || l_current;
            
                    l_stage := 'add_curr_exp';
                    mup_utl_pkg.add_curr_exp (
                        io_p0148       => l_fin_rec.p0148
                        , i_curr_code  => substr(l_current, 5, 3)
                    );
                    exit when l_buffer is null;
                end loop;
            end if;

            l_fin_rec.de055 := l_original_fin_rec.de055;
            l_stage := 'emv';
            mup_api_fin_pkg.get_fin (
                i_mti          => mup_api_const_pkg.MSG_TYPE_PRESENTMENT
              , i_de024        => mup_api_const_pkg.FUNC_CODE_FIRST_PRES
              , i_is_reversal  => l_original_fin_rec.is_reversal
              , i_dispute_id   => l_original_fin_rec.dispute_id
              , o_fin_rec      => l_first_pres_fin_rec
              , i_mask_error   => com_api_const_pkg.TRUE
            );
            if l_first_pres_fin_rec.id is not null then
                l_fin_rec.emv_9f26 := l_first_pres_fin_rec.emv_9f26;
                l_fin_rec.emv_9f02 := l_first_pres_fin_rec.emv_9f02;
                l_fin_rec.emv_9f27 := l_original_fin_rec.emv_9f27;
                l_fin_rec.emv_9F10 := l_first_pres_fin_rec.emv_9F10;
                l_fin_rec.emv_9F36 := l_first_pres_fin_rec.emv_9F36;
                l_fin_rec.emv_95   := l_first_pres_fin_rec.emv_95;
                l_fin_rec.emv_82   := l_first_pres_fin_rec.emv_82;
                l_fin_rec.emv_9a   := l_first_pres_fin_rec.emv_9a;
                l_fin_rec.emv_9c   := l_first_pres_fin_rec.emv_9c;
                l_fin_rec.emv_9f37 := l_first_pres_fin_rec.emv_9f37;
                l_fin_rec.emv_5f2a := l_first_pres_fin_rec.emv_5f2a;
                l_fin_rec.emv_9f33 := l_first_pres_fin_rec.emv_9f33;
                l_fin_rec.emv_9f34 := l_first_pres_fin_rec.emv_9f34;
                l_fin_rec.emv_9f1a := l_first_pres_fin_rec.emv_9f1a;
                l_fin_rec.emv_9f35 := l_first_pres_fin_rec.emv_9f35;
                l_fin_rec.emv_9f53 := l_first_pres_fin_rec.emv_9f53;
                l_fin_rec.emv_84   := l_first_pres_fin_rec.emv_84;
                l_fin_rec.emv_9f09 := l_first_pres_fin_rec.emv_9f09;
                l_fin_rec.emv_9f03 := l_first_pres_fin_rec.emv_9f03;
                l_fin_rec.emv_9f1e := l_first_pres_fin_rec.emv_9f1e;
                l_fin_rec.emv_9f41 := l_first_pres_fin_rec.emv_9f41;
                l_fin_rec.emv_9f4C := l_original_fin_rec.emv_9f4C;
                l_fin_rec.emv_91   := l_original_fin_rec.emv_91;
            else
                l_fin_rec.emv_9f26 := l_original_fin_rec.emv_9f26;
                l_fin_rec.emv_9f02 := l_original_fin_rec.emv_9f02;
                l_fin_rec.emv_9f27 := l_original_fin_rec.emv_9f27;
                l_fin_rec.emv_9F10 := l_original_fin_rec.emv_9F10;
                l_fin_rec.emv_9F36 := l_original_fin_rec.emv_9F36;
                l_fin_rec.emv_95   := l_original_fin_rec.emv_95;
                l_fin_rec.emv_82   := l_original_fin_rec.emv_82;
                l_fin_rec.emv_9a   := l_original_fin_rec.emv_9a;
                l_fin_rec.emv_9c   := l_original_fin_rec.emv_9c;
                l_fin_rec.emv_9f37 := l_original_fin_rec.emv_9f37;
                l_fin_rec.emv_5f2a := l_original_fin_rec.emv_5f2a;
                l_fin_rec.emv_9f33 := l_original_fin_rec.emv_9f33;
                l_fin_rec.emv_9f34 := l_original_fin_rec.emv_9f34;
                l_fin_rec.emv_9f1a := l_original_fin_rec.emv_9f1a;
                l_fin_rec.emv_9f35 := l_original_fin_rec.emv_9f35;
                l_fin_rec.emv_9f53 := l_original_fin_rec.emv_9f53;
                l_fin_rec.emv_84   := l_original_fin_rec.emv_84;
                l_fin_rec.emv_9f09 := l_original_fin_rec.emv_9f09;
                l_fin_rec.emv_9f03 := l_original_fin_rec.emv_9f03;
                l_fin_rec.emv_9f1e := l_original_fin_rec.emv_9f1e;
                l_fin_rec.emv_9f41 := l_original_fin_rec.emv_9f41;
                l_fin_rec.emv_9f4C := l_original_fin_rec.emv_9f4C;
                l_fin_rec.emv_91   := l_original_fin_rec.emv_91;
            end if;

            l_stage         := 'de063 - de095';
            l_fin_rec.de063 := l_original_fin_rec.de063;
            l_fin_rec.de072 := i_de072;
            l_fin_rec.de093 := l_original_fin_rec.de094;
            l_fin_rec.de094 := l_original_fin_rec.de093;
            l_fin_rec.de095 := l_original_fin_rec.de095;

            l_stage           := 'p0149_1 - p0149_2';
            l_fin_rec.p0149_1 := l_original_fin_rec.p0149_1;
            l_fin_rec.p0149_2 := l_original_fin_rec.p0149_2;
            
            l_stage := 'add_curr_exp';
            mup_utl_pkg.add_curr_exp (
                io_p0148     => l_fin_rec.p0148
              , i_curr_code  => l_fin_rec.p0149_1
            );

            l_fin_rec.p2158_1 := l_original_fin_rec.p2158_1;
            l_fin_rec.p2158_2 := l_original_fin_rec.p2158_2;
            l_fin_rec.p2158_3 := l_original_fin_rec.p2158_3;
            l_fin_rec.p2158_4 := l_original_fin_rec.p2158_4;
            l_fin_rec.p2158_5 := l_original_fin_rec.p2158_5;
            l_fin_rec.p2158_6 := l_original_fin_rec.p2158_6;
            
            l_fin_rec.p0165   := l_original_fin_rec.p0165;
            l_fin_rec.p0190   := l_original_fin_rec.p0190;

            l_fin_rec.p2002 := l_original_fin_rec.p2002;
            l_fin_rec.p2063 := l_original_fin_rec.p2063;
            
            l_fin_rec.p0262 := i_p0262;
            if i_p2072_2 is not null then
                l_fin_rec.p2072_1 := nvl(i_p2072_1,'CYR');
            else
                l_fin_rec.p2072_1 := null;
            end if;
            l_fin_rec.p2072_2 := i_p2072_2;
    
            l_fin_rec.p2175_1 := l_original_fin_rec.p2175_1;
            l_fin_rec.p2175_2 := l_original_fin_rec.p2175_2;

            if l_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL then
                l_fin_rec.p0268_1 := l_fin_rec.de030_1;
                l_fin_rec.p0268_2 := l_fin_rec.p0149_1;
                
            elsif l_fin_rec.p0149_1 = i_de049 then
                l_fin_rec.p0268_1 := i_de004;
                l_fin_rec.p0268_2 := i_de049;
                
            end if;
            
            l_stage := 'add_curr_exp';
            mup_utl_pkg.add_curr_exp (
                io_p0148     => l_fin_rec.p0148
              , i_curr_code  => l_fin_rec.p0268_2
            );
            
            l_stage := 'put_message';
            mup_api_fin_pkg.put_message (
                i_fin_rec  => l_fin_rec
            );

            get_chargback_pds(
                i_id     => l_original_fin_rec.id
              , i_id_new => l_fin_rec.id
            );     
            
            l_stage := 'create_operation';
                            
            mup_api_dispute_pkg.load_auth (
                i_id     => l_first_pres_fin_rec.id
              , io_auth  => l_auth
            );
            
            mup_api_fin_pkg.create_operation (
                i_fin_rec      => l_fin_rec
              , i_standard_id  => l_standard_id
              , i_auth         => l_auth
            );

            l_stage := 'done';
        end if;
        
        trc_log_pkg.debug (
            i_text       => 'Generating second presentment. Assigned id[#1]'
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
