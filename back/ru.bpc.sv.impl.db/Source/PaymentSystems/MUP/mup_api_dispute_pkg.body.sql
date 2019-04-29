create or replace package body mup_api_dispute_pkg is
/********************************************************* 
 *  MasterCard dispute API  <br /> 
 *  Created by Kopachev (kopachev@bpcbt.com)  at 11.04.2013 <br /> 
 *  Last changed by $Author: truschelev $ <br /> 
 *  $LastChangedDate:: 2015-10-20 18:02:00 +0300#$ <br /> 
 *  Revision: $LastChangedRevision: 59935 $ <br /> 
 *  Module: mup_api_dispute_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

    procedure gen_member_fee (
        o_fin_id             out com_api_type_pkg.t_long_id
      , i_network_id      in     com_api_type_pkg.t_tiny_id
      , i_de004           in     mup_api_type_pkg.t_de004
      , i_de049           in     mup_api_type_pkg.t_de049
      , i_de025           in     mup_api_type_pkg.t_de025
      , i_de003           in     mup_api_type_pkg.t_de003
      , i_de072           in     mup_api_type_pkg.t_de072
      , i_de073           in     mup_api_type_pkg.t_de073
      , i_de093           in     mup_api_type_pkg.t_de093
      , i_de094           in     mup_api_type_pkg.t_de094
      , i_de002           in     mup_api_type_pkg.t_de002
      , i_original_fin_id in     com_api_type_pkg.t_long_id
    ) is
        l_fin_rec                 mup_api_type_pkg.t_fin_rec;
        l_host_id                 com_api_type_pkg.t_tiny_id;
        l_standard_id             com_api_type_pkg.t_tiny_id;
        l_original_fin_rec        mup_api_type_pkg.t_fin_rec;
        l_param_tab               com_api_type_pkg.t_param_tab;
        l_stage                   varchar2(100);
        l_flag                    com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    begin
        trc_log_pkg.debug (
            i_text         => 'Generating member fee'
        );

        l_stage := 'get network communication standard';
        -- get network communication standard
        l_host_id := net_api_network_pkg.get_default_host(i_network_id);
        l_standard_id := net_api_network_pkg.get_offline_standard (
            i_host_id           => l_host_id
        );

        if i_original_fin_id is not null then
            mup_api_fin_pkg.get_fin (
                i_id         => i_original_fin_id
                , o_fin_rec  => l_original_fin_rec
            );

            l_fin_rec.de031 := l_original_fin_rec.de031;
            l_fin_rec.de030_1 := l_original_fin_rec.de030_1;
            if l_original_fin_rec.p0149_1 is null and l_original_fin_rec.p0149_2 is null then 
                l_fin_rec.de030_2 := null;                
            else
                l_fin_rec.de030_2 := 0;
            end if;    
            l_fin_rec.p0149_1 := l_original_fin_rec.p0149_1;
            l_fin_rec.p0149_2 := l_original_fin_rec.p0149_2;
            l_flag := com_api_const_pkg.TRUE;
        end if;

        l_stage := 'init';
        -- init
        o_fin_id := opr_api_create_pkg.get_id;
        l_fin_rec.id := o_fin_id;

        l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal := com_api_type_pkg.FALSE;
        l_fin_rec.is_rejected := com_api_type_pkg.FALSE;
        l_fin_rec.is_fpd_matched := com_api_type_pkg.FALSE;
        l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
        l_fin_rec.file_id := null;
        l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

        l_stage := 'mti & de24';
        l_fin_rec.mti := mup_api_const_pkg.MSG_TYPE_FEE;
        l_fin_rec.de024 := mup_api_const_pkg.FUNC_CODE_MEMBER_FEE;

        l_stage := 'network_id & inst_id';
        l_fin_rec.network_id := i_network_id;
        l_fin_rec.inst_id := cmn_api_standard_pkg.find_value_owner (
            i_standard_id    => l_standard_id
            , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_object_id    => l_host_id
            , i_param_name   => mup_api_const_pkg.CMID
            , i_value_char   => i_de094
        );
        if l_fin_rec.inst_id is null then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_CMID_NOT_REGISTRED'
                , i_env_param1  => i_de094
                , i_env_param2  => i_network_id
            );
        end if;

        l_stage := 'de002 - de004';
        l_fin_rec.de002 := i_de002;
        l_fin_rec.de003_1 := i_de003;
        l_fin_rec.de003_2 := mup_api_const_pkg.DEFAULT_DE003_2;
        l_fin_rec.de003_3 := mup_api_const_pkg.DEFAULT_DE003_3;
        l_fin_rec.de004 := i_de004;

        l_stage := 'impact';
        l_fin_rec.impact := mup_utl_pkg.get_message_impact (
            i_mti           => l_fin_rec.mti
            , i_de024       => l_fin_rec.de024
            , i_de003_1     => l_fin_rec.de003_1
            , i_is_reversal => l_fin_rec.is_reversal
            , i_is_incoming => l_fin_rec.is_incoming
        );

        l_stage := 'de033';
        l_fin_rec.de033 := cmn_api_standard_pkg.get_varchar_value (
            i_inst_id       => l_fin_rec.inst_id
            , i_standard_id => l_standard_id
            , i_object_id   => l_host_id
            , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_param_name  => mup_api_const_pkg.FORW_INST_ID
            , i_param_tab   => l_param_tab
        );

        l_stage := 'de025 & de049';
        l_fin_rec.de025 := i_de025;
        l_fin_rec.de049 := i_de049;

        l_stage := 'add_curr_exp';
        mup_utl_pkg.add_curr_exp (
            io_p0148       => l_fin_rec.p0148
            , i_curr_code  => l_fin_rec.de049
        );

        l_fin_rec.de072 := i_de072;
        l_fin_rec.de073 := i_de073;

        if l_flag = com_api_const_pkg.TRUE then
            if l_original_fin_rec.is_incoming = com_api_const_pkg.TRUE then
                l_fin_rec.de094 := l_original_fin_rec.de093;
                l_fin_rec.de093 := l_original_fin_rec.de094;
            else
                l_fin_rec.de094 := l_original_fin_rec.de094;
                l_fin_rec.de093 := l_original_fin_rec.de093;
            end if;    
        else
            l_fin_rec.de094 := i_de094;
            l_fin_rec.de093 := i_de093;
        end if;

        l_fin_rec.p0137 := lpad(to_char(l_fin_rec.id), 17, '0');
        l_fin_rec.p0165 := mup_api_const_pkg.SETTLEMENT_TYPE_MUP;

        l_fin_rec.p2158_1 := 1;

        l_stage := 'put_message';
        mup_api_fin_pkg.put_message (
            i_fin_rec  => l_fin_rec
        );

        l_stage := 'create_operation';
        mup_api_fin_pkg.create_operation (
             i_fin_rec          => l_fin_rec
            , i_standard_id     => l_standard_id
        );

        l_stage := 'done';

        trc_log_pkg.debug (
            i_text         => 'Generating member fee. Assigned id[#1]'
            , i_env_param1 => l_fin_rec.id
        );
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error generating member fee on stage ' || l_stage || ': ' || sqlerrm
            );

            raise;
    end;

    procedure gen_retrieval_fee (
        o_fin_id                  out com_api_type_pkg.t_long_id
        , i_original_fin_id       in com_api_type_pkg.t_long_id
        , i_de004                 in mup_api_type_pkg.t_de004
        , i_de030_1               in mup_api_type_pkg.t_de030s
        , i_de049                 in mup_api_type_pkg.t_de049
        , i_de072                 in mup_api_type_pkg.t_de072
        , i_p0149_1               in mup_api_type_pkg.t_p0149_1
        , i_p0149_2               in mup_api_type_pkg.t_p0149_2
    ) is
        l_original_fin_rec        mup_api_type_pkg.t_fin_rec;
        l_fin_rec                 mup_api_type_pkg.t_fin_rec;
        l_standard_id             com_api_type_pkg.t_tiny_id;
        l_host_id                 com_api_type_pkg.t_tiny_id;
        l_stage                   varchar2(100);
    begin
        trc_log_pkg.debug (
            i_text         => 'Generating retrieval fee'
        );

        l_stage := 'load original fin';

        mup_api_fin_pkg.get_fin (
            i_id         => i_original_fin_id
            , o_fin_rec  => l_original_fin_rec
        );

        if l_original_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
           and l_original_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
           and l_original_fin_rec.is_reversal = com_api_const_pkg.FALSE
           and l_original_fin_rec.is_incoming = com_api_const_pkg.TRUE
        then
            l_stage := 'init';
            -- init
            o_fin_id := opr_api_create_pkg.get_id;
            l_fin_rec.id := o_fin_id;
            l_fin_rec.inst_id := l_original_fin_rec.inst_id;
            l_fin_rec.network_id := l_original_fin_rec.network_id;

            l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
            l_fin_rec.is_reversal := com_api_type_pkg.FALSE;
            l_fin_rec.is_rejected := com_api_type_pkg.FALSE;
            l_fin_rec.is_fpd_matched := com_api_type_pkg.FALSE;
            l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
            l_fin_rec.file_id := null;
            l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

            l_stage := 'mti & de24';
            l_fin_rec.mti := mup_api_const_pkg.MSG_TYPE_FEE;
            l_fin_rec.de024 := mup_api_const_pkg.FUNC_CODE_MEMBER_FEE;

            l_stage := 'sync_dispute_id';
            mup_api_dispute_pkg.sync_dispute_id (
                io_fin_rec      => l_original_fin_rec
                , o_dispute_id  => l_fin_rec.dispute_id
                , o_dispute_rn  => l_fin_rec.dispute_rn
            );

            l_stage := 'de002 - de003_1';
            l_fin_rec.de002 := l_original_fin_rec.de002;
            l_fin_rec.de003_1 := mup_api_const_pkg.PROC_CODE_CREDIT_FEE;

            l_fin_rec.de004 := i_de004;

            l_stage := 'de014 - de043_6';
            l_fin_rec.de014 := l_original_fin_rec.de014;
            l_fin_rec.de023 := l_original_fin_rec.de023;
            l_fin_rec.de026 := l_original_fin_rec.de026;
            l_fin_rec.de030_1 := nvl(i_de030_1, l_original_fin_rec.de030_1);
            l_fin_rec.de030_2 := 0;
            l_fin_rec.de031 := l_original_fin_rec.de031;
            l_fin_rec.de033 := l_original_fin_rec.de100;
            l_fin_rec.de037 := l_original_fin_rec.de037;
            l_fin_rec.de038 := l_original_fin_rec.de038;
            l_fin_rec.de041 := l_original_fin_rec.de041;
            l_fin_rec.de042 := l_original_fin_rec.de042;
            l_fin_rec.de043_1 := l_original_fin_rec.de043_1;
            l_fin_rec.de043_2 := l_original_fin_rec.de043_2;
            l_fin_rec.de043_3 := l_original_fin_rec.de043_3;
            l_fin_rec.de043_4 := l_original_fin_rec.de043_4;
            l_fin_rec.de043_5 := l_original_fin_rec.de043_5;
            l_fin_rec.de043_6 := l_original_fin_rec.de043_6;

            l_stage := 'de049';
            l_fin_rec.de049 := i_de049;

            l_stage := 'de063';
            l_fin_rec.de063 := l_original_fin_rec.de063;
            l_stage := 'de072';
            l_fin_rec.de072 := i_de072;

            l_stage := 'de072';
            l_fin_rec.de073 := trunc(l_original_fin_rec.de012);
            if l_fin_rec.de073 is null then
                mup_api_fin_pkg.get_processing_date (
                    i_id                 => null
                    , i_is_fpd_matched   => com_api_type_pkg.FALSE
                    , i_is_fsum_matched  => com_api_type_pkg.FALSE
                    , i_file_id          => l_original_fin_rec.file_id
                    , o_p0025_2          => l_fin_rec.de073
                );
            end if;

            l_stage := 'de094 - de095';
            l_fin_rec.de094 := l_original_fin_rec.de093;
            l_fin_rec.de095 := l_original_fin_rec.de095;

            l_stage := 'p0137';
            l_fin_rec.p0137 := lpad(to_char(l_fin_rec.id), 17, '0');

            l_stage := 'p0149';
            l_fin_rec.p0149_1 := nvl(i_p0149_1, l_original_fin_rec.p0149_1);
            l_fin_rec.p0149_2 := nvl(i_p0149_2, l_original_fin_rec.p0149_2);

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
            l_fin_rec.p0228 := l_original_fin_rec.p0228;

            l_stage := 'put_message';
            mup_api_fin_pkg.put_message (
                i_fin_rec  => l_fin_rec
            );

            l_stage := 'create_operation';
            l_host_id := net_api_network_pkg.get_default_host (
                i_network_id  => l_fin_rec.network_id
            );
            l_standard_id := net_api_network_pkg.get_offline_standard (
                i_host_id       => l_host_id
            );

            mup_api_fin_pkg.create_operation (
                 i_fin_rec          => l_fin_rec
                , i_standard_id     => l_standard_id
            );

            l_stage := 'done';
        end if;

        trc_log_pkg.debug (
            i_text         => 'Generating retrieval fee. Assigned id[#1]'
            , i_env_param1 => l_fin_rec.id
        );
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error generating retrieval fee on stage ' || l_stage || ': ' || sqlerrm
            );

            raise;
    end;

    procedure gen_retrieval_request (
        o_fin_id                  out com_api_type_pkg.t_long_id
        , i_original_fin_id       in com_api_type_pkg.t_long_id
        , i_de025                 in mup_api_type_pkg.t_de025
        , i_p0228                 in mup_api_type_pkg.t_p0228
    ) is
        l_original_fin_rec        mup_api_type_pkg.t_fin_rec;
        l_fin_rec                 mup_api_type_pkg.t_fin_rec;
        l_standard_id             com_api_type_pkg.t_tiny_id;
        l_host_id                 com_api_type_pkg.t_tiny_id;
        l_stage                   varchar2(100);
    begin
        trc_log_pkg.debug (
            i_text         => 'Generating retrieval request'
        );

        l_stage := 'load original fin';

        mup_api_fin_pkg.get_fin (
            i_id         => i_original_fin_id
            , o_fin_rec  => l_original_fin_rec
        );

        if l_original_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
           and l_original_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_FIRST_PRES
           and l_original_fin_rec.is_reversal = com_api_type_pkg.FALSE
           and l_original_fin_rec.is_incoming = com_api_type_pkg.TRUE
        then
            l_stage := 'init';
            -- init
            o_fin_id := opr_api_create_pkg.get_id;
            l_fin_rec.id := o_fin_id;
            l_fin_rec.inst_id := l_original_fin_rec.inst_id;
            l_fin_rec.network_id := l_original_fin_rec.network_id;

            l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
            l_fin_rec.is_reversal := com_api_type_pkg.FALSE;
            l_fin_rec.is_rejected := com_api_type_pkg.FALSE;
            l_fin_rec.is_fpd_matched := com_api_type_pkg.FALSE;
            l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
            l_fin_rec.file_id := null;
            l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

            l_stage := 'mti & de24';
            l_fin_rec.mti := mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
            l_fin_rec.de024 := mup_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST;

            mup_api_dispute_pkg.sync_dispute_id (
                io_fin_rec      => l_original_fin_rec
                , o_dispute_id  => l_fin_rec.dispute_id
                , o_dispute_rn  => l_fin_rec.dispute_rn
            );

            l_stage := 'de002 - de022';
            l_fin_rec.de002 := l_original_fin_rec.de002;
            l_fin_rec.de003_1 := l_original_fin_rec.de003_1;
            l_fin_rec.de003_2 := l_original_fin_rec.de003_2;
            l_fin_rec.de003_3 := l_original_fin_rec.de003_3;
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

            l_stage := 'de023 - de094';
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
            l_fin_rec.de041 := l_original_fin_rec.de041;
            l_fin_rec.de042 := l_original_fin_rec.de042;
            l_fin_rec.de043_1 := l_original_fin_rec.de043_1;
            l_fin_rec.de043_2 := l_original_fin_rec.de043_2;
            l_fin_rec.de043_3 := l_original_fin_rec.de043_3;
            l_fin_rec.de043_4 := l_original_fin_rec.de043_4;
            l_fin_rec.de043_5 := l_original_fin_rec.de043_5;
            l_fin_rec.de043_6 := l_original_fin_rec.de043_6;
            l_fin_rec.de063 := l_original_fin_rec.de063;
            l_fin_rec.de094 := l_original_fin_rec.de093;

            l_stage := 'build_irn';
            l_fin_rec.de095 := mup_utl_pkg.build_irn;

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

            l_fin_rec.p0228 := i_p0228;

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

            l_stage := 'put_message';
            mup_api_fin_pkg.put_message (
                i_fin_rec  => l_fin_rec
            );

            l_stage := 'create_operation';
            l_host_id := net_api_network_pkg.get_default_host (
                i_network_id  => l_fin_rec.network_id
            );
            l_standard_id := net_api_network_pkg.get_offline_standard (
                i_host_id       => l_host_id
            );

            mup_api_fin_pkg.create_operation (
                 i_fin_rec          => l_fin_rec
                , i_standard_id     => l_standard_id
            );
            l_stage := 'done';
        end if;

        trc_log_pkg.debug (
            i_text         => 'Generating retrieval request. Assigned id[#1]'
            , i_env_param1 => l_fin_rec.id
        );
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error generating retrieval request on stage ' || l_stage || ': ' || sqlerrm
            );

            raise;
    end;

    procedure update_dispute_id (
        i_id                      in com_api_type_pkg.t_long_id
        , i_dispute_id            in com_api_type_pkg.t_long_id
    ) is
    begin
        update
            mup_fin
        set
            dispute_id = i_dispute_id
        where
            id = i_id;
            
        update 
            opr_operation     
        set
            dispute_id = i_dispute_id
        where
            id = i_id;            
    end;

    procedure fetch_dispute_id (
        i_fin_cur                 in sys_refcursor
        , o_fin_rec               out mup_api_type_pkg.t_fin_rec
    ) is
        l_fin_tab               mup_api_type_pkg.t_fin_tab;
    begin
        savepoint fetch_dispute_id;

        if i_fin_cur%isopen then
            fetch i_fin_cur bulk collect into l_fin_tab;

            for i in 1..l_fin_tab.count loop
                if i = 1 then
                    if l_fin_tab(i).dispute_id is null then
                        l_fin_tab(i).dispute_id := dsp_api_shared_data_pkg.get_id;
                        update_dispute_id (
                            i_id            => l_fin_tab(i).id
                            , i_dispute_id  => l_fin_tab(i).dispute_id
                        );
                    end if;

                    o_fin_rec := l_fin_tab(i);
                else
                    if l_fin_tab(i).dispute_id is null then
                        update_dispute_id (
                            i_id            => l_fin_tab(i).id
                            , i_dispute_id  => o_fin_rec.dispute_id
                        );

                    elsif l_fin_tab(i).dispute_id != o_fin_rec.dispute_id then
                        trc_log_pkg.debug (
                            i_text => 'TOO_MANY_DISPUTES_FOUND'
                        );
                        o_fin_rec := null;
                        rollback to savepoint fetch_dispute_id;
                        return;

                    end if;

                end if;
            end loop;

            if l_fin_tab.count = 0 then
                trc_log_pkg.debug (
                    i_text  => 'NO_DISPUTE_FOUND'
                );
                o_fin_rec := null;
                rollback to savepoint fetch_dispute_id;
            end if;
        end if;
    exception
        when others then
            rollback to savepoint fetch_dispute_id;
            raise;
    end;

    procedure sync_dispute_id (
        io_fin_rec                in out nocopy mup_api_type_pkg.t_fin_rec
        , o_dispute_id            out com_api_type_pkg.t_long_id
        , o_dispute_rn            out com_api_type_pkg.t_long_id
    ) is
    begin
        if io_fin_rec.dispute_id is null then
            io_fin_rec.dispute_id := dsp_api_shared_data_pkg.get_id;

            update_dispute_id (
                i_id            => io_fin_rec.id
                , i_dispute_id  => io_fin_rec.dispute_id
            );
        end if;

        o_dispute_id := io_fin_rec.dispute_id;
        o_dispute_rn := io_fin_rec.id;
    end;

    procedure load_auth (
        i_id                    in com_api_type_pkg.t_long_id
        , io_auth               in out nocopy aut_api_type_pkg.t_auth_rec
    ) is
    begin
        select
            min(o.id) id
            , min(o.sttl_type) sttl_type
            , min(o.match_status) match_status
            , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.inst_id, null)) iss_inst_id
            , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.network_id, null)) iss_network_id
            , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.inst_id, null)) acq_inst_id
            , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.network_id, null)) acq_network_id
        into
            io_auth.id
            , io_auth.sttl_type
            , io_auth.match_status
            , io_auth.iss_inst_id
            , io_auth.iss_network_id
            , io_auth.acq_inst_id
            , io_auth.acq_network_id
        from
            opr_operation o
            , opr_participant p
            , opr_card c
        where
            o.id = i_id
            and p.oper_id = o.id
            and p.oper_id = c.oper_id(+)
            and p.participant_type = c.participant_type(+);
    end;

    procedure assign_dispute_id (
        io_fin_rec     in out nocopy mup_api_type_pkg.t_fin_rec
      , o_auth            out aut_api_type_pkg.t_auth_rec
      , i_need_repeat  in     com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE
    ) is
        l_original_fin_rec    mup_api_type_pkg.t_fin_rec;
        l_need_original_rec   com_api_type_pkg.t_boolean;
    begin
        io_fin_rec.dispute_id := null;
        l_need_original_rec   := com_api_type_pkg.TRUE;

        if io_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
           and io_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_FIRST_PRES
           and io_fin_rec.is_reversal = com_api_type_pkg.FALSE
        then
            mup_api_fin_pkg.get_original_fin (
                i_mti      => mup_api_const_pkg.MSG_TYPE_PRESENTMENT
              , i_de002    => io_fin_rec.de002
              , i_de024    => mup_api_const_pkg.FUNC_CODE_FIRST_PRES
              , i_de031    => io_fin_rec.de031
              , i_id       => io_fin_rec.id
              , o_fin_rec  => l_original_fin_rec
            );
            
            if l_original_fin_rec.id is not null then
                io_fin_rec.dispute_id := l_original_fin_rec.dispute_id;
            end if;
            l_need_original_rec := com_api_type_pkg.FALSE;

        elsif io_fin_rec.mti         = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
          and io_fin_rec.de024       = mup_api_const_pkg.FUNC_CODE_ADJUSTMENT
          and io_fin_rec.is_reversal = com_api_type_pkg.FALSE
        then
            mup_api_fin_pkg.get_original_fin (
                i_mti      => mup_api_const_pkg.MSG_TYPE_PRESENTMENT
              , i_de002    => io_fin_rec.de002
              , i_de024    => mup_api_const_pkg.FUNC_CODE_FIRST_PRES
              , i_de031    => io_fin_rec.p0375
              , o_fin_rec  => l_original_fin_rec
            );

            if l_original_fin_rec.id is not null then
                if io_fin_rec.is_incoming = com_api_type_pkg.FALSE then
                    load_auth(
                        i_id    => l_original_fin_rec.id
                      , io_auth => o_auth
                    );
                end if;
                io_fin_rec.dispute_id := l_original_fin_rec.dispute_id;
                io_fin_rec.inst_id    := l_original_fin_rec.inst_id;
                io_fin_rec.network_id := l_original_fin_rec.network_id;

            else
                trc_log_pkg.warn(
                    i_text       => 'MUP_FIN_MESSAGE_NF_FOR_P0375 [#1]'
                  , i_env_param1 => io_fin_rec.p0375
                );
            end if;

            l_need_original_rec := com_api_type_pkg.FALSE;
        elsif
           (io_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
            and io_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_FIRST_PRES
            and io_fin_rec.is_reversal != com_api_type_pkg.FALSE
            ) or
            (io_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
             and io_fin_rec.de024 != mup_api_const_pkg.FUNC_CODE_FIRST_PRES
            ) or
            (io_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_CHARGEBACK
            ) or
            (io_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
             and io_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
            ) or
            (io_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_FEE
             and io_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_MEMBER_FEE
             and io_fin_rec.de025 = mup_api_const_pkg.FEE_REASON_RETRIEVAL_RESP
            )
        then
            mup_api_fin_pkg.get_original_fin (
                i_mti      => mup_api_const_pkg.MSG_TYPE_PRESENTMENT
              , i_de002    => io_fin_rec.de002
              , i_de024    => mup_api_const_pkg.FUNC_CODE_FIRST_PRES
              , i_de031    => io_fin_rec.de031
              , o_fin_rec  => l_original_fin_rec
            );
            if l_original_fin_rec.id is not null then
                io_fin_rec.dispute_id := l_original_fin_rec.dispute_id;
                io_fin_rec.inst_id := l_original_fin_rec.inst_id;
                io_fin_rec.network_id := l_original_fin_rec.network_id;
                
                load_auth (
                    i_id       => l_original_fin_rec.id
                    , io_auth  => o_auth
                );
            end if;

        elsif
            io_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_FEE
            and io_fin_rec.de024 in (
                mup_api_const_pkg.FUNC_CODE_MEMBER_FEE
                , mup_api_const_pkg.FUNC_CODE_FEE_RETURN
            )
            and io_fin_rec.de025 in (
                mup_api_const_pkg.FEE_REASON_HANDL_ISS_CHBK
                , mup_api_const_pkg.FEE_REASON_HANDL_ACQ_PRES2
                , mup_api_const_pkg.FEE_REASON_HANDL_ISS_CHBK2
                , mup_api_const_pkg.FEE_REASON_HANDL_ISS_ADVICE
            )
        then
            mup_api_fin_pkg.get_original_fin (
                i_mti        => mup_api_const_pkg.MSG_TYPE_PRESENTMENT
                , i_de002    => io_fin_rec.de002
                , i_de024    => mup_api_const_pkg.FUNC_CODE_FIRST_PRES
                , i_de031    => io_fin_rec.de031
                , o_fin_rec  => l_original_fin_rec
            );
            if l_original_fin_rec.id is null then
                trc_log_pkg.debug (
                    i_text => 'Handling fee received, but original presentment not found - probably, you have the right to return the message'
                );

                mup_api_fin_pkg.get_original_fee (
                    i_mti        => io_fin_rec.mti
                    , i_de002    => io_fin_rec.de002
                    , i_de024    => mup_api_const_pkg.FUNC_CODE_FIRST_PRES
                    , i_de031    => io_fin_rec.de031
                    , i_de094    => case when io_fin_rec.de024 in (mup_api_const_pkg.FUNC_CODE_FEE_RETURN) then io_fin_rec.de093 else io_fin_rec.de094 end
                    , i_p0137    => io_fin_rec.p0137
                    , o_fin_rec  => l_original_fin_rec
                );
            end if;
            
            if l_original_fin_rec.id is not null then
                io_fin_rec.dispute_id := l_original_fin_rec.dispute_id;
                io_fin_rec.inst_id := l_original_fin_rec.inst_id;
                io_fin_rec.network_id := l_original_fin_rec.network_id;
                
                load_auth (
                    i_id       => l_original_fin_rec.id
                    , io_auth  => o_auth
                );
            end if;

        elsif
            io_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_FEE
            and io_fin_rec.de024 in (
                mup_api_const_pkg.FUNC_CODE_FEE_RETURN
            )
        then
            mup_api_fin_pkg.get_original_fee (
                i_mti        => io_fin_rec.mti
                , i_de002    => io_fin_rec.de002
                , i_de024    => mup_api_const_pkg.FUNC_CODE_FIRST_PRES
                , i_de031    => io_fin_rec.de031
                , i_de094    => case when io_fin_rec.de024 in (mup_api_const_pkg.FUNC_CODE_FEE_RETURN) then io_fin_rec.de093 else io_fin_rec.de094 end
                , i_p0137    => io_fin_rec.p0137
                , o_fin_rec  => l_original_fin_rec
            );
            
            if l_original_fin_rec.id is not null then
                io_fin_rec.dispute_id := l_original_fin_rec.dispute_id;
                io_fin_rec.inst_id := l_original_fin_rec.inst_id;
                io_fin_rec.network_id := l_original_fin_rec.network_id;
                
                load_auth (
                    i_id       => l_original_fin_rec.id
                    , io_auth  => o_auth
                );
            end if;

        else
            trc_log_pkg.debug (
                i_text          => 'No neccesseriry to assign dispute_id. [#1]'
                , i_env_param1  => io_fin_rec.id
            );
            l_need_original_rec := com_api_type_pkg.FALSE;

        end if;

        if io_fin_rec.dispute_id is not null then
            trc_log_pkg.debug (
                i_text          => 'Dispute id assigned [#1][#2]'
                , i_env_param1  => io_fin_rec.id
                , i_env_param2  => io_fin_rec.dispute_id
            );

        elsif io_fin_rec.dispute_id is null
              and l_need_original_rec = com_api_type_pkg.TRUE
              and i_need_repeat       = com_api_type_pkg.TRUE
        then
            trc_log_pkg.debug (
                i_text          => 'Need repeat for dispute id'
            );
            raise e_need_original_record;

        end if;
    exception
        when others then
            raise;
    end;

    procedure assign_dispute_id (
        io_fin_rec                in out nocopy mup_api_type_pkg.t_fin_rec
    ) is
        l_auth                    aut_api_type_pkg.t_auth_rec;
    begin
        assign_dispute_id (
            io_fin_rec  => io_fin_rec
            , o_auth    => l_auth
        );
    end;

    procedure gen_handling_fee (
        i_original_fin_rec        in mup_api_type_pkg.t_fin_rec
        , i_de004                 in mup_api_type_pkg.t_de004
        , i_de049                 in mup_api_type_pkg.t_de049
        , i_de072                 in mup_api_type_pkg.t_de072
        , i_de025                 in mup_api_type_pkg.t_de025
        , i_de093                 in mup_api_type_pkg.t_de093
        , o_fin_id                out com_api_type_pkg.t_long_id
    ) is
        l_original_fin_rec        mup_api_type_pkg.t_fin_rec := i_original_fin_rec;
        l_fin_rec                 mup_api_type_pkg.t_fin_rec;
        l_standard_id             com_api_type_pkg.t_tiny_id;
        l_host_id                 com_api_type_pkg.t_tiny_id;
        l_stage                   varchar2(100);
    begin
        o_fin_id := opr_api_create_pkg.get_id;
        l_fin_rec.id := o_fin_id;

        l_fin_rec.inst_id := i_original_fin_rec.inst_id;
        l_fin_rec.network_id := i_original_fin_rec.network_id;

        l_fin_rec.is_rejected := com_api_type_pkg.FALSE;
        l_fin_rec.is_fpd_matched := com_api_type_pkg.FALSE;
        l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
        l_fin_rec.file_id := null;
        l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

        sync_dispute_id (
            io_fin_rec      => l_original_fin_rec
            , o_dispute_id  => l_fin_rec.dispute_id
            , o_dispute_rn  => l_fin_rec.dispute_rn
        );

        l_fin_rec.mti := mup_api_const_pkg.MSG_TYPE_FEE;
        l_fin_rec.de024 := mup_api_const_pkg.FUNC_CODE_MEMBER_FEE;
        l_fin_rec.is_reversal := com_api_const_pkg.FALSE;
        l_fin_rec.is_incoming := com_api_type_pkg.FALSE;

        l_fin_rec.de002 := l_original_fin_rec.de002;
        l_fin_rec.de003_1 := mup_api_const_pkg.PROC_CODE_CREDIT_FEE;
        l_fin_rec.de003_2 := mup_api_const_pkg.DEFAULT_DE003_2;
        l_fin_rec.de003_3 := mup_api_const_pkg.DEFAULT_DE003_3;

        l_fin_rec.de004 := i_de004;
        l_fin_rec.de049 := i_de049;
        mup_utl_pkg.add_curr_exp (
            io_p0148       => l_fin_rec.p0148
            , i_curr_code  => l_fin_rec.de049
        );


        l_fin_rec.de025 := i_de025;

        l_fin_rec.de026 := l_original_fin_rec.de026;
        l_fin_rec.de031 := l_original_fin_rec.de031;

        l_fin_rec.de033 := l_original_fin_rec.de033;

        l_fin_rec.de038 := l_original_fin_rec.de038;
        l_fin_rec.de041 := i_original_fin_rec.de041;
        l_fin_rec.de042 := i_original_fin_rec.de042;
        l_fin_rec.de043_1 := l_original_fin_rec.de043_1;
        l_fin_rec.de043_2 := l_original_fin_rec.de043_2;
        l_fin_rec.de043_3 := l_original_fin_rec.de043_3;
        l_fin_rec.de043_4 := l_original_fin_rec.de043_4;
        l_fin_rec.de043_5 := l_original_fin_rec.de043_5;
        l_fin_rec.de043_6 := l_original_fin_rec.de043_6;
        l_fin_rec.de063 := l_original_fin_rec.de063;

        l_fin_rec.de073 := com_api_sttl_day_pkg.get_sysdate();

        l_fin_rec.de093 := i_de093;
        l_fin_rec.de094 := l_original_fin_rec.de094;

        l_fin_rec.p0137 := lpad(to_char(l_fin_rec.id), 17, '0');

        l_fin_rec.p2158_1 := l_original_fin_rec.p2158_1;
        l_fin_rec.p2158_2 := l_original_fin_rec.p2158_2;
        l_fin_rec.p2158_3 := l_original_fin_rec.p2158_3;
        l_fin_rec.p2158_4 := l_original_fin_rec.p2158_4;
        l_fin_rec.p2158_5 := l_original_fin_rec.p2158_5;
        l_fin_rec.p2158_6 := l_original_fin_rec.p2158_6;

        l_fin_rec.p0165 := l_original_fin_rec.p0165;

        mup_api_fin_pkg.put_message (
            i_fin_rec  => l_fin_rec
        );

        l_host_id := net_api_network_pkg.get_default_host(
            i_network_id  => l_fin_rec.network_id
        );
        l_standard_id := net_api_network_pkg.get_offline_standard (
            i_host_id       => l_host_id
        );

        mup_api_fin_pkg.create_operation (
             i_fin_rec          => l_fin_rec
            , i_standard_id     => l_standard_id
        );
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error generating handling fee on stage ' || l_stage || ': ' || sqlerrm
            );

            raise;
    end;

    procedure gen_chargeback_fee (
        i_original_fin_id         in com_api_type_pkg.t_long_id
        , i_de004                 in mup_api_type_pkg.t_de004
        , i_de049                 in mup_api_type_pkg.t_de049
        , i_de072                 in mup_api_type_pkg.t_de072
        , o_fin_id                out com_api_type_pkg.t_long_id
    ) is
        l_original_fin_rec        mup_api_type_pkg.t_fin_rec;
        l_pres_fin_rec            mup_api_type_pkg.t_fin_rec;
        l_de025                   mup_api_type_pkg.t_de025;
    begin
        mup_api_fin_pkg.get_fin (
            i_id         => i_original_fin_id
            , o_fin_rec  => l_original_fin_rec
        );

        if  l_original_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_CHARGEBACK and
            l_original_fin_rec.is_incoming = com_api_const_pkg.FALSE and
            l_original_fin_rec.is_reversal = com_api_const_pkg.FALSE and
            l_original_fin_rec.de025 in (
               mup_api_const_pkg.CHBK_REASON_WARN_BULLETIN,
                mup_api_const_pkg.CHBK_REASON_NO_AUTH,
                mup_api_const_pkg.CHBK_REASON_NO_AUTH_FLOOR
            ) then

            mup_api_fin_pkg.get_fin (
                i_id         => l_original_fin_rec.dispute_rn
                , o_fin_rec  => l_pres_fin_rec
            );

            if l_original_fin_rec.de024 in
            (   mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL,
                mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
            ) then
                l_de025 := mup_api_const_pkg.FEE_REASON_HANDL_ISS_CHBK;
            else
                l_de025 := mup_api_const_pkg.FEE_REASON_HANDL_ISS_CHBK2;
            end if;

        end if;
    end;

    procedure gen_second_presentment_fee (
        i_original_fin_id         in com_api_type_pkg.t_long_id
        , i_de004                 in mup_api_type_pkg.t_de004
        , i_de049                 in mup_api_type_pkg.t_de049
        , i_de072                 in mup_api_type_pkg.t_de072
        , o_fin_id                out com_api_type_pkg.t_long_id
    ) is
        l_original_fin_rec        mup_api_type_pkg.t_fin_rec;
        l_chbk_fin_rec            mup_api_type_pkg.t_fin_rec;
    begin

        mup_api_fin_pkg.get_fin (
            i_id         => i_original_fin_id
            , o_fin_rec  => l_original_fin_rec
        );

        if
        (   l_original_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT and
            l_original_fin_rec.de024 in
            (   mup_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL,
                mup_api_const_pkg.FUNC_CODE_SECOND_PRES_PART
            ) and
            l_original_fin_rec.is_incoming = com_api_const_pkg.FALSE and
            l_original_fin_rec.is_reversal = com_api_const_pkg.FALSE and
            l_original_fin_rec.dispute_rn is not null
        ) then

            mup_api_fin_pkg.get_fin (
                i_id         => l_original_fin_rec.dispute_rn
                , o_fin_rec  =>l_chbk_fin_rec
            );

            if
            (   l_chbk_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_CHARGEBACK and
                l_chbk_fin_rec.is_incoming = com_api_const_pkg.TRUE and
                l_chbk_fin_rec.is_reversal = com_api_const_pkg.FALSE and
                l_chbk_fin_rec.de024 in
                (   mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL,
                    mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                ) and
                l_chbk_fin_rec.de025 in
                (   mup_api_const_pkg.CHBK_REASON_WARN_BULLETIN,
                    mup_api_const_pkg.CHBK_REASON_NO_AUTH,
                    mup_api_const_pkg.CHBK_REASON_NO_AUTH_FLOOR
                )
            ) then

                gen_handling_fee (
                    i_de004               => i_de004
                    , i_de049             => i_de049
                    , i_de072             => i_de072
                    , i_de025             => mup_api_const_pkg.FEE_REASON_HANDL_ACQ_PRES2
                    , i_de093             => l_chbk_fin_rec.de094
                    , i_original_fin_rec  => l_original_fin_rec
                    , o_fin_id            => o_fin_id
                );

            end if;
        end if;
    end;

    procedure gen_fee_dispute (
        i_original_fin_id         in com_api_type_pkg.t_long_id
        , i_de004                 in mup_api_type_pkg.t_de004
        , i_de049                 in mup_api_type_pkg.t_de049
        , i_de025                 in mup_api_type_pkg.t_de025
        , i_de072                 in mup_api_type_pkg.t_de072
        , i_de073                 in mup_api_type_pkg.t_de073
        , o_fin_id                out com_api_type_pkg.t_long_id
        , i_de024_check           in mup_api_type_pkg.t_de024
    ) is
        l_fin_rec                 mup_api_type_pkg.t_fin_rec;
        l_standard_id             com_api_type_pkg.t_tiny_id;
        l_host_id                 com_api_type_pkg.t_tiny_id;
        l_original_fin_rec        mup_api_type_pkg.t_fin_rec;
        l_stage                   varchar2(100);
    begin
        mup_api_fin_pkg.get_fin (
            i_id         => i_original_fin_id
            , o_fin_rec  => l_original_fin_rec
        );

        if  l_original_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_FEE
            and l_original_fin_rec.de024 = i_de024_check
            and l_original_fin_rec.is_reversal = com_api_const_pkg.FALSE
            and l_original_fin_rec.is_incoming = com_api_const_pkg.TRUE
        then
            o_fin_id := opr_api_create_pkg.get_id;
            l_fin_rec.id := o_fin_id;

            l_fin_rec.inst_id := l_original_fin_rec.inst_id;
            l_fin_rec.network_id := l_original_fin_rec.network_id;

            l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
            l_fin_rec.is_rejected := com_api_type_pkg.FALSE;
            l_fin_rec.is_fpd_matched := com_api_type_pkg.FALSE;
            l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
            l_fin_rec.file_id := null;
            l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

            sync_dispute_id (
                io_fin_rec      => l_original_fin_rec
                , o_dispute_id  => l_fin_rec.dispute_id
                , o_dispute_rn  => l_fin_rec.dispute_rn
            );

            l_fin_rec.mti := mup_api_const_pkg.MSG_TYPE_FEE;
            l_fin_rec.de024 := mup_api_const_pkg.FUNC_CODE_FEE_RETURN;
            l_fin_rec.is_reversal := com_api_const_pkg.FALSE;

            l_fin_rec.de003_1 := l_original_fin_rec.de003_1;
            l_fin_rec.de003_2 := mup_api_const_pkg.DEFAULT_DE003_2;
            l_fin_rec.de003_3 := mup_api_const_pkg.DEFAULT_DE003_3;


            l_fin_rec.de004 := i_de004;
            l_fin_rec.de049 := i_de049;
            mup_utl_pkg.add_curr_exp (
                io_p0148       => l_fin_rec.p0148
                , i_curr_code  => l_fin_rec.de049
            );

            l_fin_rec.de025 := i_de025;

            l_fin_rec.de026 := l_original_fin_rec.de026;

            if l_fin_rec.de004 != l_original_fin_rec.de004 then
                l_fin_rec.de030_1 := l_original_fin_rec.de004;
                l_fin_rec.de030_2 := 0;
                l_fin_rec.p0149_1 := l_original_fin_rec.de049;
                l_fin_rec.p0149_2 := 0;

                mup_utl_pkg.add_curr_exp (
                    io_p0148       => l_fin_rec.p0148
                    , i_curr_code  => l_fin_rec.p0149_1
                );

            end if;

            l_fin_rec.de031 := l_original_fin_rec.de031;
            l_fin_rec.de033 := l_original_fin_rec.de100;
            l_fin_rec.de038 := l_original_fin_rec.de038;
            l_fin_rec.de041 := l_original_fin_rec.de041;
            l_fin_rec.de042 := l_original_fin_rec.de042;

            l_fin_rec.de043_1 := l_original_fin_rec.de043_1;
            l_fin_rec.de043_2 := l_original_fin_rec.de043_2;
            l_fin_rec.de043_3 := l_original_fin_rec.de043_3;
            l_fin_rec.de043_4 := l_original_fin_rec.de043_4;
            l_fin_rec.de043_5 := l_original_fin_rec.de043_5;
            l_fin_rec.de043_6 := l_original_fin_rec.de043_6;


            l_fin_rec.de072 := i_de072;
            l_fin_rec.de073 := i_de073;

            l_fin_rec.de093 := l_original_fin_rec.de094;
            l_fin_rec.de094 := l_original_fin_rec.de093;

            l_fin_rec.p0137 := l_original_fin_rec.p0137;

            l_fin_rec.p2158_1 := l_original_fin_rec.p2158_1;
            l_fin_rec.p2158_2 := l_original_fin_rec.p2158_2;
            l_fin_rec.p2158_3 := l_original_fin_rec.p2158_3;
            l_fin_rec.p2158_4 := l_original_fin_rec.p2158_4;
            l_fin_rec.p2158_5 := l_original_fin_rec.p2158_5;
            l_fin_rec.p2158_6 := l_original_fin_rec.p2158_6;

            l_fin_rec.p0165 := l_original_fin_rec.p0165;

            l_fin_rec.p0262 := l_original_fin_rec.p0262;

            if i_de024_check  = mup_api_const_pkg.FUNC_CODE_MEMBER_FEE then
                if
                (   l_original_fin_rec.de025 is not null or
                    l_original_fin_rec.p2158_5 is not null or
                    l_original_fin_rec.de072 is not null
                ) then
                    l_fin_rec.p0265 :=
                    (   lpad(nvl(to_char(l_original_fin_rec.de025), '0'), 4, '0') ||
                        lpad(nvl(to_char(l_original_fin_rec.p2158_5, mup_api_const_pkg.P2158_DATE_FORMAT), '0'), 6, '0') ||
                        l_fin_rec.p0265
                    );
                else
                    l_fin_rec.p0265 := null;
                end if;

            elsif i_de024_check = mup_api_const_pkg.FUNC_CODE_FEE_RETURN then

                if
                (   l_original_fin_rec.de025 is not null or
                    l_original_fin_rec.p2158_5 is not null or
                    l_original_fin_rec.de004 is not null or
                    l_original_fin_rec.de049 is not null or
                    l_original_fin_rec.de072 is not null
                ) then
                    l_fin_rec.p0266 :=
                    (   lpad(nvl(to_char(l_original_fin_rec.de025), '0'), 4, '0') ||
                        lpad(nvl(to_char(l_original_fin_rec.p2158_2, mup_api_const_pkg.P2158_DATE_FORMAT), '0'), 6, '0') ||
                        '  ' ||
                        lpad(nvl(to_char(l_original_fin_rec.de004), '0'), 12, '0') ||
                        lpad(nvl(to_char(l_original_fin_rec.de049), '0'), 3, '0') ||
                        l_original_fin_rec.de072
                    );
                else
                    l_fin_rec.p0266 := null;
                end if;

            elsif  i_de024_check = mup_api_const_pkg.FUNC_CODE_FEE_RESUBMITION  then
                if
                (   l_original_fin_rec.de025 is not null or
                    l_original_fin_rec.p2158_5 is not null or
                    l_original_fin_rec.de004 is not null or
                    l_original_fin_rec.de049 is not null or
                    l_original_fin_rec.de072 is not null
                ) then
                    l_fin_rec.p0267 :=
                    (   lpad(nvl(to_char(l_original_fin_rec.de025), '0'), 4, '0') ||
                        lpad(nvl(to_char(l_original_fin_rec.p2158_5, mup_api_const_pkg.P2158_DATE_FORMAT), '0'), 6, '0') ||
                        '  ' ||
                        lpad(nvl(to_char(l_original_fin_rec.de004), '0'), 12, '0') ||
                        lpad(nvl(to_char(l_original_fin_rec.de049), '0'), 3, '0') ||
                        l_original_fin_rec.de072
                    );
                else
                    l_fin_rec.p0267 := null;
                end if;
            end if;

            mup_api_fin_pkg.put_message (
                i_fin_rec  => l_fin_rec
            );

            l_host_id := net_api_network_pkg.get_default_host (
                i_network_id  => l_fin_rec.network_id
            );
            l_standard_id := net_api_network_pkg.get_offline_standard (
                i_host_id       => l_host_id
            );

            mup_api_fin_pkg.create_operation (
                 i_fin_rec          => l_fin_rec
                , i_standard_id     => l_standard_id
            );

        end if;
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error generating fee dispute on stage ' || l_stage || ': ' || sqlerrm
            );

            raise;
    end;

    procedure gen_fee_return (
        i_original_fin_id         in com_api_type_pkg.t_long_id
        , i_de004                 in mup_api_type_pkg.t_de004
        , i_de049                 in mup_api_type_pkg.t_de049
        , i_de025                 in mup_api_type_pkg.t_de025
        , i_de072                 in mup_api_type_pkg.t_de072
        , i_de073                 in mup_api_type_pkg.t_de073
        , o_fin_id                out com_api_type_pkg.t_long_id
    ) is
    begin
        gen_fee_dispute (
            i_original_fin_id  => i_original_fin_id
            , i_de004          => i_de004
            , i_de049          => i_de049
            , i_de025          => i_de025
            , i_de072          => i_de072
            , i_de073          => i_de073
            , o_fin_id         => o_fin_id
            , i_de024_check    => mup_api_const_pkg.FUNC_CODE_MEMBER_FEE
        );
    end;

    procedure gen_fee_resubmition (
        i_original_fin_id         in com_api_type_pkg.t_long_id
        , i_de004                 in mup_api_type_pkg.t_de004
        , i_de049                 in mup_api_type_pkg.t_de049
        , i_de025                 in mup_api_type_pkg.t_de025
        , i_de072                 in mup_api_type_pkg.t_de072
        , i_de073                 in mup_api_type_pkg.t_de073
        , o_fin_id                out com_api_type_pkg.t_long_id
    ) is
    begin
        gen_fee_dispute (
            i_original_fin_id  => i_original_fin_id
            , i_de004          => i_de004
            , i_de049          => i_de049
            , i_de025          => i_de025
            , i_de072          => i_de072
            , i_de073          => i_de073
            , o_fin_id         => o_fin_id
            , i_de024_check    => mup_api_const_pkg.FUNC_CODE_FEE_RETURN
        );
    end;

    procedure gen_fee_second_return (
        i_original_fin_id         in com_api_type_pkg.t_long_id
        , i_de004                 in mup_api_type_pkg.t_de004
        , i_de049                 in mup_api_type_pkg.t_de049
        , i_de025                 in mup_api_type_pkg.t_de025
        , i_de072                 in mup_api_type_pkg.t_de072
        , i_de073                 in mup_api_type_pkg.t_de073
        , o_fin_id                out com_api_type_pkg.t_long_id
    ) is
    begin
        gen_fee_dispute (
            i_original_fin_id  => i_original_fin_id
            , i_de004          => i_de004
            , i_de049          => i_de049
            , i_de025          => i_de025
            , i_de072          => i_de072
            , i_de073          => i_de073
            , o_fin_id         => o_fin_id
            , i_de024_check    => mup_api_const_pkg.FUNC_CODE_FEE_RESUBMITION
        );
    end;

end;
/
