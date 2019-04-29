create or replace package body mcw_api_dsp_generate_pkg is
/************************************************************
 * API for dispute generate <br />
 * Created by Maslov I.(maslov@bpcbt.com) at 01.06.2013 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-10-20 16:58:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: mcw_api_dsp_generate_pkg <br />
 * @headcom
 ************************************************************/

procedure make_first_chargeback is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   mcw_api_type_pkg.t_de004;
    l_de049                   mcw_api_type_pkg.t_de049;
    l_de024                   mcw_api_type_pkg.t_de024;
    l_de025                   mcw_api_type_pkg.t_de025;
    l_p0262                   mcw_api_type_pkg.t_p0262;
    l_de072                   mcw_api_type_pkg.t_de072;
    l_cashback_amount         mcw_api_type_pkg.t_de004;
    l_ext_claim_id            mcw_api_type_pkg.t_ext_claim_id;
    l_ext_message_id          mcw_api_type_pkg.t_ext_message_id;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_de004           := dsp_api_shared_data_pkg.get_masked_param_num ('DE_004');
    l_de049           := dsp_api_shared_data_pkg.get_masked_param_char('DE_049');
    l_de024           := dsp_api_shared_data_pkg.get_masked_param_char('DE_024');
    l_de025           := dsp_api_shared_data_pkg.get_masked_param_char('DE_025');
    l_p0262           := dsp_api_shared_data_pkg.get_masked_param_num ('PDS_0262');
    l_de072           := dsp_api_shared_data_pkg.get_masked_param_char('DE_072');
    l_cashback_amount := dsp_api_shared_data_pkg.get_masked_param_num ('CASHBACK_AMOUNT');
    l_ext_claim_id    := dsp_api_shared_data_pkg.get_masked_param_char('EXT_CLAIM_ID');
    l_ext_message_id  := dsp_api_shared_data_pkg.get_masked_param_char('EXT_MESSAGE_ID');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        mcw_api_chargeback_pkg.gen_first_chargeback(
            o_fin_id           => l_fin_id
          , i_original_fin_id  => l_oper_id
          , i_de004            => l_de004
          , i_de049            => l_de049
          , i_de024            => l_de024
          , i_de025            => l_de025
          , i_p0262            => l_p0262
          , i_de072            => l_de072
          , i_cashback_amount  => l_cashback_amount
          , i_ext_claim_id     => l_ext_claim_id
          , i_ext_message_id   => l_ext_message_id
        );
    
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else
        mcw_api_chargeback_pkg.modify_first_chargeback(
            i_fin_id               => l_oper_id
          , i_de004                => l_de004
          , i_de049                => l_de049
          , i_de024                => l_de024
          , i_de025                => l_de025
          , i_p0262                => l_p0262
          , i_de072                => l_de072
          , i_cashback_amount      => l_cashback_amount
        );
    end if;
    
end make_first_chargeback;

procedure gen_first_chargeback_part is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
      , i_value    => mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
    );
    make_first_chargeback;

end gen_first_chargeback_part;

procedure gen_first_chargeback_full is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
      , i_value    => mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
    );
    make_first_chargeback;

end gen_first_chargeback_full;


procedure make_second_presentment is
    l_fin_id          com_api_type_pkg.t_long_id;
    l_oper_id         com_api_type_pkg.t_long_id;
    l_de004           mcw_api_type_pkg.t_de004;
    l_de049           mcw_api_type_pkg.t_de049;
    l_de024           mcw_api_type_pkg.t_de024;
    l_de025           mcw_api_type_pkg.t_de025;
    l_p0262           mcw_api_type_pkg.t_p0262;
    l_de072           mcw_api_type_pkg.t_de072;
    l_ext_claim_id    mcw_api_type_pkg.t_ext_claim_id;
    l_ext_message_id  mcw_api_type_pkg.t_ext_claim_id;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_de004   := dsp_api_shared_data_pkg.get_masked_param_num ('DE_004');
    l_de049   := dsp_api_shared_data_pkg.get_masked_param_char('DE_049');
    l_de024   := dsp_api_shared_data_pkg.get_masked_param_char('DE_024');
    l_de025   := dsp_api_shared_data_pkg.get_masked_param_char('DE_025');
    l_p0262   := dsp_api_shared_data_pkg.get_masked_param_num ('PDS_0262');
    l_de072   := dsp_api_shared_data_pkg.get_masked_param_char('DE_072');
    l_ext_claim_id    := dsp_api_shared_data_pkg.get_masked_param_char('EXT_CLAIM_ID');
    l_ext_message_id  := dsp_api_shared_data_pkg.get_masked_param_char('EXT_MESSAGE_ID');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
    
        mcw_api_chargeback_pkg.gen_second_presentment(
            o_fin_id           => l_fin_id
          , i_original_fin_id  => l_oper_id
          , i_de004            => l_de004
          , i_de049            => l_de049
          , i_de024            => l_de024
          , i_de025            => l_de025
          , i_p0262            => l_p0262
          , i_de072            => l_de072
          , i_ext_claim_id     => l_ext_claim_id
          , i_ext_message_id   => l_ext_message_id
        );

        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );
    else
        mcw_api_chargeback_pkg.modify_second_presentment(
            i_fin_id  => l_oper_id
          , i_de004   => l_de004
          , i_de049   => l_de049
          , i_de024   => l_de024
          , i_de025   => l_de025
          , i_p0262   => l_p0262
          , i_de072   => l_de072
        );
    end if;
    
end make_second_presentment;

procedure gen_second_pres_full is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
      , i_value    => mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
    );
    make_second_presentment;

end gen_second_pres_full;

procedure gen_second_pres_part is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
      , i_value    => mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_PART
    );
    make_second_presentment;

end gen_second_pres_part;

procedure make_gen_second_chbk is
    l_fin_id          com_api_type_pkg.t_long_id;
    l_oper_id         com_api_type_pkg.t_long_id;
    l_de004           mcw_api_type_pkg.t_de004;
    l_de049           mcw_api_type_pkg.t_de049;
    l_de024           mcw_api_type_pkg.t_de024;
    l_de025           mcw_api_type_pkg.t_de025;
    l_p0262           mcw_api_type_pkg.t_p0262;
    l_de072           mcw_api_type_pkg.t_de072;
    l_ext_claim_id    mcw_api_type_pkg.t_ext_claim_id;
    l_ext_message_id  mcw_api_type_pkg.t_ext_message_id;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_de004   := dsp_api_shared_data_pkg.get_masked_param_num ('DE_004');
    l_de024   := dsp_api_shared_data_pkg.get_masked_param_char('DE_024');
    l_de025   := dsp_api_shared_data_pkg.get_masked_param_char('DE_025');
    l_de049   := dsp_api_shared_data_pkg.get_masked_param_char('DE_049');
    l_de072   := dsp_api_shared_data_pkg.get_masked_param_char('DE_072');
    l_p0262   := dsp_api_shared_data_pkg.get_masked_param_num ('PDS_0262');
    l_ext_claim_id    := dsp_api_shared_data_pkg.get_masked_param_char('EXT_CLAIM_ID');
    l_ext_message_id  := dsp_api_shared_data_pkg.get_masked_param_char('EXT_MESSAGE_ID');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        mcw_api_chargeback_pkg.gen_second_chargeback(
            o_fin_id           => l_fin_id
          , i_original_fin_id  => l_oper_id
          , i_de004            => l_de004
          , i_de049            => l_de049
          , i_de024            => l_de024
          , i_de025            => l_de025
          , i_p0262            => l_p0262
          , i_de072            => l_de072
          , i_ext_claim_id     => l_ext_claim_id
          , i_ext_message_id   => l_ext_message_id
        );
    
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else
        mcw_api_chargeback_pkg.modify_second_chargeback(
            i_fin_id               => l_oper_id
          , i_de004                => l_de004
          , i_de049                => l_de049
          , i_de024                => l_de024
          , i_de025                => l_de025
          , i_p0262                => l_p0262
          , i_de072                => l_de072
        );
    end if;
    
end make_gen_second_chbk;

procedure gen_second_chbk_full is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
      , i_value    => mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
    );

    make_gen_second_chbk;

end gen_second_chbk_full;

procedure gen_second_chbk_part is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'DE_024'
      , i_value    => mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART
    );

    make_gen_second_chbk;

end gen_second_chbk_part;

procedure gen_member_fee is
    l_fin_id          com_api_type_pkg.t_long_id;
    l_oper_id         com_api_type_pkg.t_long_id;
    l_de002           mcw_api_type_pkg.t_de002;
    l_de003           mcw_api_type_pkg.t_de003;
    l_de004           mcw_api_type_pkg.t_de004;
    l_de049           mcw_api_type_pkg.t_de049;
    l_de025           mcw_api_type_pkg.t_de025;
    l_de072           mcw_api_type_pkg.t_de072;
    l_de073           mcw_api_type_pkg.t_de073;
    l_de093           mcw_api_type_pkg.t_de093;
    l_de094           mcw_api_type_pkg.t_de094;
    l_network_id      com_api_type_pkg.t_network_id;
    l_ext_claim_id    mcw_api_type_pkg.t_ext_claim_id;
    l_ext_message_id  mcw_api_type_pkg.t_ext_message_id;
begin
    l_oper_id    := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_network_id := dsp_api_shared_data_pkg.get_masked_param_num ('NETWORK_ID');
    l_de002      := dsp_api_shared_data_pkg.get_masked_param_char('DE_002');
    l_de003      := dsp_api_shared_data_pkg.get_masked_param_char('DE_003_1');
    l_de004      := dsp_api_shared_data_pkg.get_masked_param_num ('DE_004');
    l_de049      := dsp_api_shared_data_pkg.get_masked_param_char('DE_049');
    l_de025      := dsp_api_shared_data_pkg.get_masked_param_char('DE_025');
    l_de072      := dsp_api_shared_data_pkg.get_masked_param_char('DE_072');
    l_de073      := dsp_api_shared_data_pkg.get_masked_param_date('DE_073');
    l_de093      := dsp_api_shared_data_pkg.get_masked_param_char('DE_093');
    l_de094      := dsp_api_shared_data_pkg.get_masked_param_char('DE_094');
    l_ext_claim_id   := dsp_api_shared_data_pkg.get_masked_param_char('EXT_CLAIM_ID');
    l_ext_message_id := dsp_api_shared_data_pkg.get_masked_param_char('EXT_MESSAGE_ID');

    l_de093 := mcw_utl_pkg.pad_number (
                   i_data        => l_de093
                 , i_max_length  => 6
                 , i_min_length  => 6
               );
    l_de094 := mcw_utl_pkg.pad_number (
                   i_data        => l_de094
                 , i_max_length  => 6
                 , i_min_length  => 6
               );

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
        
        mcw_api_dispute_pkg.gen_member_fee(
            o_fin_id           => l_fin_id
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
          , i_ext_claim_id     => l_ext_claim_id
          , i_ext_message_id   => l_ext_message_id
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else
        mcw_api_dispute_pkg.modify_member_fee(
            i_fin_id               => l_oper_id
          , i_network_id           => l_network_id
          , i_de004                => l_de004
          , i_de049                => l_de049
          , i_de025                => l_de025
          , i_de003                => l_de003
          , i_de072                => l_de072
          , i_de073                => l_de073
          , i_de093                => l_de093
          , i_de094                => l_de094
          , i_de002                => l_de002
        );
    end if;
    
end gen_member_fee;

procedure gen_retrieval_fee is
    l_fin_id          com_api_type_pkg.t_long_id;
    l_oper_id         com_api_type_pkg.t_long_id;
    l_de004           mcw_api_type_pkg.t_de004;
    l_de049           mcw_api_type_pkg.t_de049;
    l_de072           mcw_api_type_pkg.t_de072;
    l_ext_claim_id    mcw_api_type_pkg.t_ext_claim_id;
    l_ext_message_id  mcw_api_type_pkg.t_ext_message_id;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_de004          := dsp_api_shared_data_pkg.get_masked_param_num ('DE_004');
    l_de049          := dsp_api_shared_data_pkg.get_masked_param_char('DE_049');
    l_de072          := dsp_api_shared_data_pkg.get_masked_param_char('DE_072');
    l_ext_claim_id   := dsp_api_shared_data_pkg.get_masked_param_char('EXT_CLAIM_ID');
    l_ext_message_id := dsp_api_shared_data_pkg.get_masked_param_char('EXT_MESSAGE_ID');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
    
        mcw_api_dispute_pkg.gen_retrieval_fee(
            o_fin_id          => l_fin_id
          , i_original_fin_id => l_oper_id
          , i_de004           => l_de004
          , i_de030_1         => null
          , i_de049           => l_de049
          , i_de072           => l_de072
          , i_p0149_1         => null
          , i_p0149_2         => null
          , i_ext_claim_id    => l_ext_claim_id
          , i_ext_message_id  => l_ext_message_id
        );
    
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else
        mcw_api_dispute_pkg.modify_retrieval_fee(
            i_fin_id               => l_oper_id
          , i_de004                => l_de004
          , i_de049                => l_de049
          , i_de072                => l_de072
        );
    end if;
    
end gen_retrieval_fee;

procedure gen_retrieval_request is
    l_fin_id         com_api_type_pkg.t_long_id;
    l_oper_id        com_api_type_pkg.t_long_id;
    l_de025          mcw_api_type_pkg.t_de025;
    l_p0228          mcw_api_type_pkg.t_p0228;
    l_ext_claim_id   mcw_api_type_pkg.t_ext_claim_id;
    l_ext_message_id mcw_api_type_pkg.t_ext_message_id;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_de025          := dsp_api_shared_data_pkg.get_masked_param_char('DE_025');
    l_p0228          := dsp_api_shared_data_pkg.get_masked_param_num ('PDS_0228');
    l_ext_claim_id   := dsp_api_shared_data_pkg.get_masked_param_char('EXT_CLAIM_ID');
    l_ext_message_id := dsp_api_shared_data_pkg.get_masked_param_char('EXT_MESSAGE_ID');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
    
        mcw_api_dispute_pkg.gen_retrieval_request(
            o_fin_id           => l_fin_id
          , i_original_fin_id  => l_oper_id
          , i_de025            => l_de025
          , i_p0228            => l_p0228
          , i_ext_claim_id     => l_ext_claim_id
          , i_ext_message_id   => l_ext_message_id
        );
    
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else
        mcw_api_dispute_pkg.modify_retrieval_request(
            i_fin_id               => l_oper_id
          , i_de025                => l_de025
          , i_p0228                => l_p0228
        );
    end if;
    
end gen_retrieval_request;

procedure gen_common_reversal is
    l_fin_id           com_api_type_pkg.t_long_id;
    l_oper_id          com_api_type_pkg.t_long_id;
    l_ext_claim_id     mcw_api_type_pkg.t_ext_claim_id;
    l_ext_message_id   mcw_api_type_pkg.t_ext_message_id;
begin
    l_oper_id        := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_ext_claim_id   := dsp_api_shared_data_pkg.get_param_char('EXT_CLAIM_ID');
    l_ext_message_id := dsp_api_shared_data_pkg.get_param_char('EXT_MESSAGE_ID');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
        mcw_api_reversal_pkg.gen_common_reversal(
            o_fin_id           => l_fin_id
          , i_original_fin_id  => l_oper_id
          , i_ext_claim_id     => l_ext_claim_id
          , i_ext_message_id   => l_ext_message_id
        );

        dsp_ui_process_pkg.set_operation_id(
            i_oper_id => l_fin_id
        );
    else
        null;
    end if;

end gen_common_reversal;

procedure gen_first_pres_reversal is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   mcw_api_type_pkg.t_de004;
    l_de049                   mcw_api_type_pkg.t_de049;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_de004   := dsp_api_shared_data_pkg.get_masked_param_num ('DE_004');
    l_de049   := dsp_api_shared_data_pkg.get_masked_param_char('DE_049');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        mcw_api_reversal_pkg.gen_common_reversal (
            o_fin_id               => l_fin_id
          , i_de004                => l_de004
          , i_de049                => l_de049
          , i_original_fin_id      => l_oper_id
        );

        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else
        mcw_api_dispute_pkg.modify_first_pres_reversal(
            i_fin_id               => l_oper_id
          , i_de004                => l_de004
          , i_de049                => l_de049
        );
    end if;

end gen_first_pres_reversal;

procedure gen_chargeback_fee is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   mcw_api_type_pkg.t_de004;
    l_de049                   mcw_api_type_pkg.t_de049;
    l_de072                   mcw_api_type_pkg.t_de072;
    l_ext_claim_id            mcw_api_type_pkg.t_ext_claim_id;
    l_ext_message_id          mcw_api_type_pkg.t_ext_message_id;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_de004   := dsp_api_shared_data_pkg.get_masked_param_num ('DE_004');
    l_de049   := dsp_api_shared_data_pkg.get_masked_param_char('DE_049');
    l_de072   := dsp_api_shared_data_pkg.get_masked_param_char('DE_072');
    l_ext_claim_id    := dsp_api_shared_data_pkg.get_masked_param_char('EXT_CLAIM_ID');
    l_ext_message_id  := dsp_api_shared_data_pkg.get_masked_param_char('EXT_MESSAGE_ID');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
    
        mcw_api_dispute_pkg.gen_chargeback_fee(
            i_original_fin_id  => l_oper_id
          , i_de004            => l_de004
          , i_de049            => l_de049
          , i_de072            => l_de072
          , o_fin_id           => l_fin_id
          , i_ext_claim_id     => l_ext_claim_id
          , i_ext_message_id   => l_ext_message_id
        );

        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else
        mcw_api_dispute_pkg.modify_chargeback_fee(
            i_fin_id               => l_oper_id
          , i_de004                => l_de004
          , i_de049                => l_de049
          , i_de072                => l_de072
        );
    end if;

end gen_chargeback_fee;

procedure gen_second_presentment_fee is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_de004                   mcw_api_type_pkg.t_de004;
    l_de049                   mcw_api_type_pkg.t_de049;
    l_de072                   mcw_api_type_pkg.t_de072;
    l_ext_claim_id            mcw_api_type_pkg.t_ext_claim_id;
    l_ext_message_id          mcw_api_type_pkg.t_ext_message_id;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_de004   := dsp_api_shared_data_pkg.get_masked_param_num ('DE_004');
    l_de049   := dsp_api_shared_data_pkg.get_masked_param_char('DE_049');
    l_de072   := dsp_api_shared_data_pkg.get_masked_param_char('DE_072');
    l_ext_claim_id    := dsp_api_shared_data_pkg.get_masked_param_char('EXT_CLAIM_ID');
    l_ext_message_id  := dsp_api_shared_data_pkg.get_masked_param_char('EXT_MESSAGE_ID');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        mcw_api_dispute_pkg.gen_second_presentment_fee(
            i_original_fin_id  => l_oper_id
          , i_de004            => l_de004
          , i_de049            => l_de049
          , i_de072            => l_de072
          , o_fin_id           => l_fin_id
          , i_ext_claim_id     => l_ext_claim_id
          , i_ext_message_id   => l_ext_message_id
        );
    
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else
        mcw_api_dispute_pkg.modify_second_presentment_fee(
            i_fin_id               => l_oper_id
          , i_de004                => l_de004
          , i_de049                => l_de049
          , i_de072                => l_de072
        );
    end if;

end gen_second_presentment_fee;

procedure gen_fee_return is
    l_fin_id          com_api_type_pkg.t_long_id;
    l_oper_id         com_api_type_pkg.t_long_id;
    l_de004           mcw_api_type_pkg.t_de004;
    l_de025           mcw_api_type_pkg.t_de025;
    l_de049           mcw_api_type_pkg.t_de049;
    l_de072           mcw_api_type_pkg.t_de072;
    l_de073           mcw_api_type_pkg.t_de073;
    l_ext_claim_id    mcw_api_type_pkg.t_ext_claim_id;
    l_ext_message_id  mcw_api_type_pkg.t_ext_message_id;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_de004   := dsp_api_shared_data_pkg.get_masked_param_num ('DE_004');
    l_de049   := dsp_api_shared_data_pkg.get_masked_param_char('DE_049');
    l_de072   := dsp_api_shared_data_pkg.get_masked_param_char('DE_072');
    l_de025   := dsp_api_shared_data_pkg.get_masked_param_char('DE_025');
    l_de073   := dsp_api_shared_data_pkg.get_masked_param_date('DE_073');
    l_ext_claim_id   := dsp_api_shared_data_pkg.get_param_char('EXT_CLAIM_ID');
    l_ext_message_id := dsp_api_shared_data_pkg.get_param_char('EXT_MESSAGE_ID');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        mcw_api_dispute_pkg.gen_fee_return(
            i_original_fin_id => l_oper_id
          , i_de004           => l_de004
          , i_de049           => l_de049
          , i_de025           => l_de025
          , i_de072           => l_de072
          , i_de073           => l_de073
          , o_fin_id          => l_fin_id
          , i_ext_claim_id    => l_ext_claim_id
          , i_ext_message_id  => l_ext_message_id
        );
    
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else
        mcw_api_dispute_pkg.modify_fee_return(
            i_fin_id               => l_oper_id
          , i_de004                => l_de004
          , i_de049                => l_de049
          , i_de025                => l_de025
          , i_de072                => l_de072
          , i_de073                => l_de073
        );
    end if;

end gen_fee_return;

procedure gen_fee_resubmition is
    l_fin_id          com_api_type_pkg.t_long_id;
    l_oper_id         com_api_type_pkg.t_long_id;
    l_de004           mcw_api_type_pkg.t_de004;
    l_de025           mcw_api_type_pkg.t_de025;
    l_de049           mcw_api_type_pkg.t_de049;
    l_de072           mcw_api_type_pkg.t_de072;
    l_de073           mcw_api_type_pkg.t_de073;
    l_ext_claim_id    mcw_api_type_pkg.t_ext_claim_id;
    l_ext_message_id  mcw_api_type_pkg.t_ext_message_id;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_de004   := dsp_api_shared_data_pkg.get_masked_param_num ('DE_004');
    l_de049   := dsp_api_shared_data_pkg.get_masked_param_char('DE_049');
    l_de072   := dsp_api_shared_data_pkg.get_masked_param_char('DE_072');
    l_de025   := dsp_api_shared_data_pkg.get_masked_param_char('DE_025');
    l_de073   := dsp_api_shared_data_pkg.get_masked_param_date('DE_073');
    l_ext_claim_id   := dsp_api_shared_data_pkg.get_param_char('EXT_CLAIM_ID');
    l_ext_message_id := dsp_api_shared_data_pkg.get_param_char('EXT_MESSAGE_ID');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
    
        mcw_api_dispute_pkg.gen_fee_resubmition(
            i_original_fin_id  => l_oper_id
          , i_de004            => l_de004
          , i_de049            => l_de049
          , i_de025            => l_de025
          , i_de072            => l_de072
          , i_de073            => l_de073
          , o_fin_id           => l_fin_id
          , i_ext_claim_id     => l_ext_claim_id
          , i_ext_message_id   => l_ext_message_id
        );
    
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else
        mcw_api_dispute_pkg.modify_fee_resubmition(
            i_fin_id               => l_oper_id
          , i_de004                => l_de004
          , i_de049                => l_de049
          , i_de025                => l_de025
          , i_de072                => l_de072
          , i_de073                => l_de073
        );
    end if;

end gen_fee_resubmition;

procedure gen_fee_second_return is
    l_fin_id          com_api_type_pkg.t_long_id;
    l_oper_id         com_api_type_pkg.t_long_id;
    l_de004           mcw_api_type_pkg.t_de004;
    l_de025           mcw_api_type_pkg.t_de025;
    l_de049           mcw_api_type_pkg.t_de049;
    l_de072           mcw_api_type_pkg.t_de072;
    l_de073           mcw_api_type_pkg.t_de073;
    l_ext_claim_id    mcw_api_type_pkg.t_ext_claim_id;
    l_ext_message_id  mcw_api_type_pkg.t_ext_message_id;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_de004   := dsp_api_shared_data_pkg.get_masked_param_num ('DE_004');
    l_de049   := dsp_api_shared_data_pkg.get_masked_param_char('DE_049');
    l_de072   := dsp_api_shared_data_pkg.get_masked_param_char('DE_072');
    l_de025   := dsp_api_shared_data_pkg.get_masked_param_char('DE_025');
    l_de073   := dsp_api_shared_data_pkg.get_masked_param_date('DE_073');
    l_ext_claim_id   := dsp_api_shared_data_pkg.get_param_char('EXT_CLAIM_ID');
    l_ext_message_id := dsp_api_shared_data_pkg.get_param_char('EXT_MESSAGE_ID');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        mcw_api_dispute_pkg.gen_fee_second_return(
            i_original_fin_id  => l_oper_id
          , i_de004            => l_de004
          , i_de049            => l_de049
          , i_de025            => l_de025
          , i_de072            => l_de072
          , i_de073            => l_de073
          , o_fin_id           => l_fin_id
          , i_ext_claim_id     => l_ext_claim_id
          , i_ext_message_id   => l_ext_message_id
        );
    
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else
        mcw_api_dispute_pkg.modify_fee_second_return(
            i_fin_id               => l_oper_id
          , i_de004                => l_de004
          , i_de049                => l_de049
          , i_de025                => l_de025
          , i_de072                => l_de072
          , i_de073                => l_de073
        );
    end if;

end gen_fee_second_return;

procedure gen_fraud_reporting is
    l_oper_id         com_api_type_pkg.t_long_id;
    l_c14             mcw_api_type_pkg.t_de004;
    l_c15             mcw_api_type_pkg.t_de049;
    l_c04             com_api_type_pkg.t_medium_id;--mcw_api_type_pkg.t_de093;
    l_c02             com_api_type_pkg.t_medium_id;--mcw_api_type_pkg.t_de094;
    l_c01             com_api_type_pkg.t_dict_value;
    l_c28             com_api_type_pkg.t_dict_value;
    l_c29             com_api_type_pkg.t_dict_value;
    l_c30             com_api_type_pkg.t_dict_value;
    l_c31             com_api_type_pkg.t_dict_value;
    l_c44             com_api_type_pkg.t_dict_value;
    l_ext_claim_id    mcw_api_type_pkg.t_ext_claim_id;
    l_ext_message_id  mcw_api_type_pkg.t_ext_message_id;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_c14     := dsp_api_shared_data_pkg.get_masked_param_num('C_14');
    -- l_c15  := dsp_api_shared_data_pkg.get_masked_param_char('C_15');
    l_c15     := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_c04     := dsp_api_shared_data_pkg.get_masked_param_char('C_04');
    l_c02     := dsp_api_shared_data_pkg.get_masked_param_num ('C_02');
    l_c01     := dsp_api_shared_data_pkg.get_masked_param_char('C_01');
    l_c28     := dsp_api_shared_data_pkg.get_masked_param_char('C_28');
    l_c29     := dsp_api_shared_data_pkg.get_masked_param_char('C_29');
    l_c30     := dsp_api_shared_data_pkg.get_masked_param_char('C_30');
    l_c44     := dsp_api_shared_data_pkg.get_masked_param_char('C_44');
    l_ext_claim_id   := dsp_api_shared_data_pkg.get_param_char('EXT_CLAIM_ID');
    l_ext_message_id := dsp_api_shared_data_pkg.get_param_char('EXT_MESSAGE_ID');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        mcw_api_dispute_pkg.gen_fraud(
            i_original_fin_id  => l_oper_id
          , i_c01              => l_c01
          , i_c02              => to_char(l_c02)
          , i_c04              => to_char(l_c04)
          , i_c14              => l_c14
          , i_c15              => l_c15
          , i_c28              => l_c28
          , i_c29              => l_c29
          , i_c30              => l_c30
          , i_c31              => l_c31
          , i_c44              => l_c44
          , i_ext_claim_id     => l_ext_claim_id
          , i_ext_message_id   => l_ext_message_id
        ) ;

        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_oper_id
        );        
    else
        mcw_api_dispute_pkg.modify_fraud(
            i_fin_id               => l_oper_id
          , i_c01                  => l_c01
          , i_c02                  => to_char(l_c02)
          , i_c04                  => to_char(l_c04)
          , i_c14                  => l_c14
          , i_c15                  => l_c15
          , i_c28                  => l_c28
          , i_c29                  => l_c29
          , i_c30                  => l_c30
          , i_c31                  => l_c31
          , i_c44                  => l_c44
        ) ;
    end if;

end gen_fraud_reporting;

procedure gen_writeoff
is
begin
    null;
end gen_writeoff;

procedure gen_retrieval_request_acknowl is
    l_fin_id          com_api_type_pkg.t_long_id;
    l_oper_id         com_api_type_pkg.t_long_id;
    l_ext_claim_id    mcw_api_type_pkg.t_ext_claim_id;
    l_ext_message_id  mcw_api_type_pkg.t_ext_message_id;
begin
    l_oper_id        := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_ext_claim_id   := dsp_api_shared_data_pkg.get_param_char('EXT_CLAIM_ID');
    l_ext_message_id := dsp_api_shared_data_pkg.get_param_char('EXT_MESSAGE_ID');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
    
        mcw_api_dispute_pkg.gen_retrieval_request_acknowl (
            o_fin_id           => l_fin_id
          , i_original_fin_id  => l_oper_id
          , i_ext_claim_id     => l_ext_claim_id
          , i_ext_message_id   => l_ext_message_id
        );
    
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else
        null;
    end if;

end gen_retrieval_request_acknowl;

end mcw_api_dsp_generate_pkg;
/
