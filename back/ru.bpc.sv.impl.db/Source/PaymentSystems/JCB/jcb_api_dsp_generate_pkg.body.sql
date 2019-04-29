create or replace package body jcb_api_dsp_generate_pkg is
/************************************************************
 * API for dispute generate <br />
 * Created by Maslov I.(maslov@bpcbt.com) at 01.06.2013 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-10-20 16:58:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: jcb_api_dsp_generate_pkg <br />
 * @headcom
 ************************************************************/

procedure make_first_chargeback is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   jcb_api_type_pkg.t_de004;
    l_de049                   jcb_api_type_pkg.t_de049;
    l_de024                   jcb_api_type_pkg.t_de024;
    l_de025                   jcb_api_type_pkg.t_de025;
    l_p3250                   jcb_api_type_pkg.t_p3250;
    l_de072                   jcb_api_type_pkg.t_de072;
    l_cashback_amount         jcb_api_type_pkg.t_de004;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_004'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_de024 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_024'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_de025 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_025'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_p3250 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'PDS_3250'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_de072 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_072'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_cashback_amount := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'CASHBACK_AMOUNT'
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    jcb_api_chargeback_pkg.gen_first_chargeback (
        o_fin_id             => l_fin_id
        , i_original_fin_id  => l_oper_id
        , i_de004            => l_de004
        , i_de049            => l_de049
        , i_de024            => l_de024
        , i_de025            => l_de025
        , i_p3250            => l_p3250
        , i_de072            => l_de072
        , i_cashback_amount  => l_cashback_amount
    );
end;

procedure gen_first_chargeback_part is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
        , i_value  => jcb_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
    );
    make_first_chargeback;
end;

procedure gen_first_chargeback_full is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
        , i_value  => jcb_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
    );
    make_first_chargeback;
end;

procedure make_second_presentment is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   jcb_api_type_pkg.t_de004;
    l_de049                   jcb_api_type_pkg.t_de049;
    l_de024                   jcb_api_type_pkg.t_de024;
    l_de025                   jcb_api_type_pkg.t_de025;
    l_p3250                   jcb_api_type_pkg.t_p3250;
    l_de072                   jcb_api_type_pkg.t_de072;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_004'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_de024 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_024'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_de025 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_025'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_p3250 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'PDS_3250'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_de072 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_072'
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    jcb_api_chargeback_pkg.gen_second_presentment (
        o_fin_id             => l_fin_id
        , i_original_fin_id  => l_oper_id
        , i_de004            => l_de004
        , i_de049            => l_de049
        , i_de024            => l_de024
        , i_de025            => l_de025
        , i_p3250            => l_p3250
        , i_de072            => l_de072
    );
end;

procedure gen_second_pres_full is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
        , i_value  => jcb_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
    );
    make_second_presentment;
end;

procedure gen_second_pres_part is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
        , i_value  => jcb_api_const_pkg.FUNC_CODE_SECOND_PRES_PART
    );
    make_second_presentment;
end;

procedure make_gen_second_chbk is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   jcb_api_type_pkg.t_de004;
    l_de049                   jcb_api_type_pkg.t_de049;
    l_de024                   jcb_api_type_pkg.t_de024;
    l_de025                   jcb_api_type_pkg.t_de025;
    l_p3250                   jcb_api_type_pkg.t_p3250;
    l_de072                   jcb_api_type_pkg.t_de072;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_004'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_de024 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_024'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_de025 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_025'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_de072 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_072'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_p3250 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'PDS_3250'
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    jcb_api_chargeback_pkg.gen_second_chargeback (
        o_fin_id             => l_fin_id
        , i_original_fin_id  => l_oper_id
        , i_de004            => l_de004
        , i_de049            => l_de049
        , i_de024            => l_de024
        , i_de025            => l_de025
        , i_p3250            => l_p3250
        , i_de072            => l_de072
    );
end;

procedure gen_second_chbk_full is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
        , i_value  => jcb_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
    );
    make_gen_second_chbk;
end;

procedure gen_second_chbk_part is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
        , i_value  => jcb_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART
    );
    make_gen_second_chbk;
end;

procedure gen_first_pres_reversal is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   jcb_api_type_pkg.t_de004;
    l_de049                   jcb_api_type_pkg.t_de049;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de004 := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'DE_004'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_de049 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_049'
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    jcb_api_reversal_pkg.gen_common_reversal (
        o_fin_id             => l_fin_id
        , i_de004            => l_de004
        , i_de049            => l_de049
        , i_original_fin_id  => l_oper_id
    );
end;

procedure gen_retrieval_request is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de025                   jcb_api_type_pkg.t_de025;
    l_p3203                   jcb_api_type_pkg.t_p3203;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_de025 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'DE_025'
        , i_mask_error  => get_true
    );
    l_p3203 := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'PDS_3203'
        , i_mask_error  => get_true
    );

    jcb_api_retrieval_pkg.gen_retrieval_request (
        o_fin_id             => l_fin_id
        , i_original_fin_id  => l_oper_id
        , i_de025            => l_de025
        , i_p3203            => l_p3203
    );
end;

end;
/
