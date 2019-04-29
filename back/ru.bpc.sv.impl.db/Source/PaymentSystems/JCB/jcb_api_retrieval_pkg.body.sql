create or replace package body jcb_api_retrieval_pkg is

procedure gen_retrieval_request (
    o_fin_id                  out com_api_type_pkg.t_long_id
    , i_original_fin_id       in com_api_type_pkg.t_long_id
    , i_de025                 in jcb_api_type_pkg.t_de025
    , i_p3203                 in jcb_api_type_pkg.t_p3203
) is 
    l_original_fin_rec        jcb_api_type_pkg.t_fin_rec;
    l_fin_rec                 jcb_api_type_pkg.t_fin_rec;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_stage                   varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Generating retrieval request'
    );

    l_stage := 'load original fin';

    jcb_api_fin_pkg.get_fin (
        i_id         => i_original_fin_id
        , o_fin_rec  => l_original_fin_rec
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
        l_fin_rec.inst_id := l_original_fin_rec.inst_id;
        l_fin_rec.network_id := l_original_fin_rec.network_id;

        l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal := com_api_type_pkg.FALSE;
        l_fin_rec.is_rejected := com_api_type_pkg.FALSE;
        l_fin_rec.file_id := null;
        l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

        l_stage := 'mti & de24';
        l_fin_rec.mti := jcb_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
        l_fin_rec.de024 := jcb_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST;

        jcb_api_dispute_pkg.sync_dispute_id (
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
        l_fin_rec.de022_11 := l_original_fin_rec.de022_11;
        l_fin_rec.de022_12 := l_original_fin_rec.de022_12;

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
        l_fin_rec.de049   := l_original_fin_rec.de049;
        l_fin_rec.de094 := l_original_fin_rec.de093;

        l_stage := 'add_curr_exp';
        jcb_utl_pkg.add_curr_exp (
            io_p3002       => l_fin_rec.p3002
            , i_curr_code  => l_fin_rec.de049
        );

        l_fin_rec.p3203 := i_p3203;

        l_stage := 'put_message';
        jcb_api_fin_pkg.put_message (
            i_fin_rec  => l_fin_rec
        );

        l_stage := 'create_operation';
        l_host_id := net_api_network_pkg.get_default_host (
            i_network_id  => l_fin_rec.network_id
        );
        l_standard_id := net_api_network_pkg.get_offline_standard (
            i_host_id       => l_host_id
        );

        jcb_api_fin_pkg.create_operation (
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
    
end;
/
