create or replace package body mup_api_dsp_generate_pkg is
/************************************************************
 * API for dispute generate <br />
 * Created by Maslov I.(maslov@bpcbt.com) at 01.06.2013 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-10-20 16:58:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: mup_api_dsp_generate_pkg <br />
 * @headcom
 ************************************************************/

procedure make_first_chargeback is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   mup_api_type_pkg.t_de004;
    l_de049                   mup_api_type_pkg.t_de049;
    l_de024                   mup_api_type_pkg.t_de024;
    l_de025                   mup_api_type_pkg.t_de025;
    l_p0262                   mup_api_type_pkg.t_p0262;
    l_de072                   mup_api_type_pkg.t_de072;
    l_p2072_1                 mup_api_type_pkg.t_p2072_1;
    l_p2072_2                 mup_api_type_pkg.t_p2072_2;
    l_cashback_amount         mup_api_type_pkg.t_de004;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_004'
        , i_mask_error  => get_true
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => get_true
    );
    l_de024 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_024'
        , i_mask_error  => get_true
    );
    l_de025 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_025'
        , i_mask_error  => get_true
    );
    l_p0262 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'PDS_0262'
        , i_mask_error  => get_true
    );
    l_de072 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_072'
        , i_mask_error  => get_true
    );
    l_p2072_1 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'PDS_2072_1'
        , i_mask_error  => get_true
    );
    l_p2072_2 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'PDS_2072_2'
        , i_mask_error  => get_true
    );
    l_cashback_amount := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'CASHBACK_AMOUNT'
        , i_mask_error  => get_true
    );

    mup_api_chargeback_pkg.gen_first_chargeback (
        o_fin_id             => l_fin_id
        , i_original_fin_id  => l_oper_id
        , i_de004            => l_de004
        , i_de049            => l_de049
        , i_de024            => l_de024
        , i_de025            => l_de025
        , i_p0262            => l_p0262
        , i_de072            => l_de072
        , i_p2072_1          => l_p2072_1
        , i_p2072_2          => l_p2072_2
        , i_cashback_amount  => l_cashback_amount
    );
end;

procedure gen_first_chargeback_part is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
        , i_value  => mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
    );
    make_first_chargeback;
end;

procedure gen_first_chargeback_full is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
        , i_value  => mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
    );
    make_first_chargeback;
end;


procedure make_second_presentment is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   mup_api_type_pkg.t_de004;
    l_de049                   mup_api_type_pkg.t_de049;
    l_de024                   mup_api_type_pkg.t_de024;
    l_de025                   mup_api_type_pkg.t_de025;
    l_p0262                   mup_api_type_pkg.t_p0262;
    l_de072                   mup_api_type_pkg.t_de072;
    l_p2072_1                 mup_api_type_pkg.t_p2072_1;
    l_p2072_2                 mup_api_type_pkg.t_p2072_2;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_004'
        , i_mask_error  => get_true
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => get_true
    );
    l_de024 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_024'
        , i_mask_error  => get_true
    );
    l_de025 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_025'
        , i_mask_error  => get_true
    );
    l_p0262 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'PDS_0262'
        , i_mask_error  => get_true
    );
    l_de072 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_072'
        , i_mask_error  => get_true
    );
    l_p2072_1 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'PDS_2072_1'
        , i_mask_error  => get_true
    );
    l_p2072_2 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'PDS_2072_2'
        , i_mask_error  => get_true
    );

    mup_api_chargeback_pkg.gen_second_presentment (
        o_fin_id             => l_fin_id
        , i_original_fin_id  => l_oper_id
        , i_de004            => l_de004
        , i_de049            => l_de049
        , i_de024            => l_de024
        , i_de025            => l_de025
        , i_p0262            => l_p0262
        , i_de072            => l_de072
        , i_p2072_1          => l_p2072_1
        , i_p2072_2          => l_p2072_2
    );
end make_second_presentment;


procedure gen_second_pres_full is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
        , i_value  => mup_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
    );
    make_second_presentment;
end;

procedure gen_second_pres_part is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
        , i_value  => mup_api_const_pkg.FUNC_CODE_SECOND_PRES_PART
    );
    make_second_presentment;
end;

procedure make_gen_second_chbk is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   mup_api_type_pkg.t_de004;
    l_de049                   mup_api_type_pkg.t_de049;
    l_de024                   mup_api_type_pkg.t_de024;
    l_de025                   mup_api_type_pkg.t_de025;
    l_p0262                   mup_api_type_pkg.t_p0262;
    l_de072                   mup_api_type_pkg.t_de072;
    l_p2072_1                 mup_api_type_pkg.t_p2072_1;
    l_p2072_2                 mup_api_type_pkg.t_p2072_2;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_004'
        , i_mask_error  => get_true
    );
    l_de024 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_024'
        , i_mask_error  => get_true
    );
    l_de025 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_025'
        , i_mask_error  => get_true
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => get_true
    );
    l_de072 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_072'
        , i_mask_error  => get_true
    );
    l_p0262 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'PDS_0262'
        , i_mask_error  => get_true
    );
    l_p2072_1 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'PDS_2072_1'
        , i_mask_error  => get_true
    );
    l_p2072_2 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'PDS_2072_2'
        , i_mask_error  => get_true
    );

    mup_api_chargeback_pkg.gen_second_chargeback (
        o_fin_id             => l_fin_id
        , i_original_fin_id  => l_oper_id
        , i_de004            => l_de004
        , i_de049            => l_de049
        , i_de024            => l_de024
        , i_de025            => l_de025
        , i_p0262            => l_p0262
        , i_de072            => l_de072
        , i_p2072_1          => l_p2072_1
        , i_p2072_2          => l_p2072_2
    );
end;

procedure gen_second_chbk_full is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
        , i_value  => mup_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
    );

    make_gen_second_chbk;
end;

procedure gen_second_chbk_part is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
        , i_value  => mup_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART
    );

    make_gen_second_chbk;
end;

procedure gen_member_fee is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de002                   mup_api_type_pkg.t_de002;
    l_de003                   mup_api_type_pkg.t_de003;
    l_de004                   mup_api_type_pkg.t_de004;
    l_de049                   mup_api_type_pkg.t_de049;
    l_de025                   mup_api_type_pkg.t_de025;
    l_de072                   mup_api_type_pkg.t_de072;
    l_de073                   mup_api_type_pkg.t_de073;
    l_de093                   mup_api_type_pkg.t_de093;
    l_de094                   mup_api_type_pkg.t_de094;
    l_network_id              com_api_type_pkg.t_network_id;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_network_id := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'NETWORK_ID'
        , i_mask_error  => get_true
    );
    l_de002 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_002'
        , i_mask_error  => get_true
    );
    l_de003 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_003_1'
        , i_mask_error  => get_true
    );
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
         i_name          => 'DE_004'
         , i_mask_error  => get_true
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => get_true
    );
    l_de025 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_025'
        , i_mask_error  => get_true
    );
    l_de072 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_072'
        , i_mask_error  => get_true
    );
    l_de073 := dsp_api_shared_data_pkg.get_param_date (
        i_name          => 'DE_073'
        , i_mask_error  => get_true
    );
    l_de093 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_093'
        , i_mask_error  => get_true
    );
    l_de094 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_094'
        , i_mask_error  => get_true
    );
    l_de093 := mup_utl_pkg.pad_number (
        i_data          => l_de093
        , i_max_length  => 11
        , i_min_length  => 6
    );
    l_de094 := mup_utl_pkg.pad_number (
        i_data          => l_de094
        , i_max_length  => 11
        , i_min_length  => 6
    );

    mup_api_dispute_pkg.gen_member_fee (
        o_fin_id             => l_fin_id
        , i_network_id       => l_network_id
        , i_de004            => l_de004
        , i_de049            => l_de049
        , i_de025            => l_de025
        , i_de003            => l_de003
        , i_de072            => l_de072
        , i_de073            => l_de073
        , i_de093            => l_de093
        , i_de094            => l_de094
        , i_de002            => l_de002
        , i_original_fin_id  => l_oper_id
    );
end;

procedure gen_retrieval_fee is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   mup_api_type_pkg.t_de004;
    l_de049                   mup_api_type_pkg.t_de049;
    l_de072                   mup_api_type_pkg.t_de072;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_004'
        , i_mask_error  => get_true
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => get_true
    );
    l_de072 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_072'
        , i_mask_error  => get_true
    );

    mup_api_dispute_pkg.gen_retrieval_fee (
        o_fin_id             => l_oper_id
        , i_original_fin_id  => l_fin_id
        , i_de004            => l_de004
        , i_de049            => l_de049
        , i_de072            => l_de072
    );
end;

procedure gen_retrieval_request is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de025                   mup_api_type_pkg.t_de025;
    l_p0228                   mup_api_type_pkg.t_p0228;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de025 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_025'
        , i_mask_error  => get_true
    );
    l_p0228 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'PDS_0228'
        , i_mask_error  => get_true
    );

    mup_api_dispute_pkg.gen_retrieval_request (
        o_fin_id             => l_fin_id
        , i_original_fin_id  => l_oper_id
        , i_de025            => l_de025
        , i_p0228            => l_p0228
    );
end;

procedure gen_common_reversal is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   mup_api_type_pkg.t_de004;
    l_de049                   mup_api_type_pkg.t_de049;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_004'
        , i_mask_error  => com_api_const_pkg.TRUE
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => com_api_const_pkg.TRUE
    );
    mup_api_reversal_pkg.gen_common_reversal (
        o_fin_id             => l_fin_id
        , i_de004            => l_de004
        , i_de049            => l_de049
        , i_original_fin_id  => l_oper_id
    );
end;

procedure gen_first_pres_reversal is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   mup_api_type_pkg.t_de004;
    l_de049                   mup_api_type_pkg.t_de049;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_004'
        , i_mask_error  => get_true
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => get_true
    );

    mup_api_reversal_pkg.gen_common_reversal (
        o_fin_id             => l_fin_id
        , i_de004            => l_de004
        , i_de049            => l_de049
        , i_original_fin_id  => l_oper_id
    );
end;

procedure gen_chargeback_fee is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   mup_api_type_pkg.t_de004;
    l_de049                   mup_api_type_pkg.t_de049;
    l_de072                   mup_api_type_pkg.t_de072;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_004'
        , i_mask_error  => get_true
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => get_true
    );
    l_de072 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_072'
        , i_mask_error  => get_true
    );

    mup_api_dispute_pkg.gen_chargeback_fee (
        i_original_fin_id  => l_oper_id
        , i_de004          => l_de004
        , i_de049          => l_de049
        , i_de072          => l_de072
        , o_fin_id         => l_fin_id
    );
end;

procedure gen_second_presentment_fee is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   mup_api_type_pkg.t_de004;
    l_de049                   mup_api_type_pkg.t_de049;
    l_de072                   mup_api_type_pkg.t_de072;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_004'
        , i_mask_error  => get_true
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => get_true
    );
    l_de072 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_072'
        , i_mask_error  => get_true
    );

    mup_api_dispute_pkg.gen_second_presentment_fee (
        i_original_fin_id  => l_oper_id
        , i_de004          => l_de004
        , i_de049          => l_de049
        , i_de072          => l_de072
        , o_fin_id         => l_fin_id
    );
end;

procedure gen_fee_return is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   mup_api_type_pkg.t_de004;
    l_de025                   mup_api_type_pkg.t_de025;
    l_de049                   mup_api_type_pkg.t_de049;
    l_de072                   mup_api_type_pkg.t_de072;
    l_de073                   mup_api_type_pkg.t_de073;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_004'
        , i_mask_error  => get_true
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => get_true
    );
    l_de072 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_072'
        , i_mask_error  => get_true
    );
    l_de025 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_025'
        , i_mask_error  => get_true
    );
    l_de073 := dsp_api_shared_data_pkg.get_param_date (
        i_name          => 'DE_073'
        , i_mask_error  => get_true
    );

    mup_api_dispute_pkg.gen_fee_return (
        i_original_fin_id  => l_oper_id
        , i_de004          => l_de004
        , i_de049          => l_de049
        , i_de025          => l_de025
        , i_de072          => l_de072
        , i_de073          => l_de073
        , o_fin_id         => l_fin_id
    );
end;

procedure gen_fee_resubmition is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   mup_api_type_pkg.t_de004;
    l_de025                   mup_api_type_pkg.t_de025;
    l_de049                   mup_api_type_pkg.t_de049;
    l_de072                   mup_api_type_pkg.t_de072;
    l_de073                   mup_api_type_pkg.t_de073;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_004'
        , i_mask_error  => get_true
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => get_true
    );
    l_de072 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_072'
        , i_mask_error  => get_true
    );
    l_de025 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_025'
        , i_mask_error  => get_true
    );
    l_de073 := dsp_api_shared_data_pkg.get_param_date (
        i_name          => 'DE_073'
        , i_mask_error  => get_true
    );

    mup_api_dispute_pkg.gen_fee_resubmition (
        i_original_fin_id  => l_oper_id
        , i_de004          => l_de004
        , i_de049          => l_de049
        , i_de025          => l_de025
        , i_de072          => l_de072
        , i_de073          => l_de073
        , o_fin_id         => l_fin_id
    );
end;

procedure gen_fee_second_return is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   mup_api_type_pkg.t_de004;
    l_de025                   mup_api_type_pkg.t_de025;
    l_de049                   mup_api_type_pkg.t_de049;
    l_de072                   mup_api_type_pkg.t_de072;
    l_de073                   mup_api_type_pkg.t_de073;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_004'
        , i_mask_error  => get_true
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => get_true
    );
    l_de072 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_072'
        , i_mask_error  => get_true
    );
    l_de025 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_025'
        , i_mask_error  => get_true
    );
    l_de073 := dsp_api_shared_data_pkg.get_param_date (
        i_name          => 'DE_073'
        , i_mask_error  => get_true
    );

    mup_api_dispute_pkg.gen_fee_second_return (
        i_original_fin_id  => l_oper_id
        , i_de004          => l_de004
        , i_de049          => l_de049
        , i_de025          => l_de025
        , i_de072          => l_de072
        , i_de073          => l_de073
        , o_fin_id         => l_fin_id
    );
end;

procedure gen_writeoff
is
begin
    null;
end;

end;
/
