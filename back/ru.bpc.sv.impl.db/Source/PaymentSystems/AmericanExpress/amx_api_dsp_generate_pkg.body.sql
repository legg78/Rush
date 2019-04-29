create or replace package body amx_api_dsp_generate_pkg as

procedure make_first_chargeback is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_trans_amount            com_api_type_pkg.t_money;
    l_trans_currency          com_api_type_pkg.t_name;
    l_reason_code             com_api_type_pkg.t_name;
    l_chbck_reason_text       com_api_type_pkg.t_name;
    l_is_edit                 com_api_type_pkg.t_boolean;
    l_func_code               com_api_type_pkg.t_name;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_trans_amount := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'TRANS_AMOUNT'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_trans_currency := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'TRANS_CURRENCY'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_reason_code := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'REASON_CODE'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_chbck_reason_text := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'CHBCK_REASON_TEXT'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_func_code := dsp_api_shared_data_pkg.get_param_char (
        i_name     => 'FUNC_CODE'
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    l_is_edit := nvl(dsp_api_shared_data_pkg.get_param_num(
                         i_name          => 'EDITING'
                       , i_mask_error  => com_api_type_pkg.TRUE
                     ), com_api_type_pkg.FALSE);

    if l_is_edit = com_api_type_pkg.FALSE then

        amx_api_dispute_pkg.gen_first_chargeback (
            o_fin_id                 => l_fin_id
            , i_original_fin_id      => l_oper_id
            , i_func_code            => l_func_code
            , i_trans_amount         => l_trans_amount
            , i_trans_currency       => l_trans_currency
            , i_reason_code          => l_reason_code
            , i_chbck_reason_text    => l_chbck_reason_text
        );

        dsp_api_shared_data_pkg.set_param(
            i_name   => 'OPERATION_ID'
          , i_value  => l_fin_id
        );
    else
        amx_api_dispute_pkg.modify_first_chargeback (
            i_fin_id                 => l_oper_id
            , i_func_code            => l_func_code
            , i_trans_amount         => l_trans_amount
            , i_trans_currency       => l_trans_currency
            , i_reason_code          => l_reason_code
            , i_chbck_reason_text    => l_chbck_reason_text
        );

    end if;
end;

procedure gen_second_presentment is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_trans_amount            com_api_type_pkg.t_money;
    l_trans_currency          com_api_type_pkg.t_name;
    l_reason_code             com_api_type_pkg.t_name;
    l_itemized_doc_code       com_api_type_pkg.t_byte_char;
    l_itemized_doc_ref_number com_api_type_pkg.t_name;
    l_is_edit                 com_api_type_pkg.t_boolean;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_trans_amount := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'TRANS_AMOUNT'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_trans_currency := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'TRANS_CURRENCY'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_reason_code := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'REASON_CODE'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_itemized_doc_code := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'ITEMIZED_DOC_CODE'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_itemized_doc_ref_number := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'ITEMIZED_DOC_REF_NUMBER'
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    l_is_edit := nvl(dsp_api_shared_data_pkg.get_param_num(
                         i_name          => 'EDITING'
                       , i_mask_error  => com_api_type_pkg.TRUE
                     ), com_api_type_pkg.FALSE);

    if l_is_edit = com_api_type_pkg.FALSE then

        amx_api_dispute_pkg.gen_second_presentment (
            o_fin_id                 => l_fin_id
            , i_original_fin_id      => l_oper_id
            , i_trans_amount         => l_trans_amount
            , i_trans_currency       => l_trans_currency
            , i_reason_code          => l_reason_code
            , i_itemized_doc_code    => l_itemized_doc_code
            , i_itemized_doc_ref_number => l_itemized_doc_ref_number
        );

        dsp_api_shared_data_pkg.set_param(
            i_name   => 'OPERATION_ID'
          , i_value  => l_fin_id
        );
    else
        amx_api_dispute_pkg.modify_second_presentment (
            i_fin_id                 => l_oper_id
            , i_trans_amount         => l_trans_amount
            , i_trans_currency       => l_trans_currency
            , i_reason_code          => l_reason_code
            , i_itemized_doc_code    => l_itemized_doc_code
            , i_itemized_doc_ref_number => l_itemized_doc_ref_number
        );

    end if;

end;

procedure gen_first_chargeback is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'FUNC_CODE'
        , i_value  => amx_api_const_pkg.FUNC_CODE_FIRST_CHARGEBACK
    );
    make_first_chargeback;
end;

procedure gen_final_chargeback is
begin
    dsp_api_shared_data_pkg.set_param (
        i_name     => 'FUNC_CODE'
        , i_value  => amx_api_const_pkg.FUNC_CODE_FINAL_CHARGEBACK
    );
    make_first_chargeback;
end;

procedure gen_retrieval_request is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_func_code               com_api_type_pkg.t_name;
    l_reason_code             com_api_type_pkg.t_name;
    l_chbck_reason_code       com_api_type_pkg.t_name;
    l_itemized_doc_code       com_api_type_pkg.t_name;
    l_is_edit                 com_api_type_pkg.t_boolean;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_func_code := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'FUNC_CODE'
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    l_reason_code := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'REASON_CODE'
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    l_chbck_reason_code := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'CHBCK_REASON_CODE'
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    l_itemized_doc_code := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'ITEMIZED_DOC_CODE'
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    l_is_edit := nvl(dsp_api_shared_data_pkg.get_param_num(
                         i_name          => 'EDITING'
                       , i_mask_error  => com_api_type_pkg.TRUE
                     ), com_api_type_pkg.FALSE);

    if l_is_edit = com_api_type_pkg.FALSE then

        amx_api_dispute_pkg.gen_retrieval_request (
            o_fin_id                 => l_fin_id
            , i_original_fin_id      => l_oper_id
            , i_func_code            => l_func_code
            , i_reason_code          => l_reason_code
            , i_chbck_reason_code    => l_chbck_reason_code
            , i_itemized_doc_code    => l_itemized_doc_code
        );

        dsp_api_shared_data_pkg.set_param(
            i_name   => 'OPERATION_ID'
          , i_value  => l_fin_id
        );
    else
        amx_api_dispute_pkg.modify_retrieval_request (
            i_fin_id                 => l_oper_id
            , i_func_code            => l_func_code
            , i_reason_code          => l_reason_code
            , i_chbck_reason_code    => l_chbck_reason_code
            , i_itemized_doc_code    => l_itemized_doc_code
        );

    end if;

end;

procedure gen_fulfillment is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_func_code               com_api_type_pkg.t_name;
    l_reason_code             com_api_type_pkg.t_name;
    l_itemized_doc_code       com_api_type_pkg.t_name;
    l_itemized_doc_ref_number com_api_type_pkg.t_name;
    l_is_edit                 com_api_type_pkg.t_boolean;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
    l_func_code := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'FUNC_CODE'
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    l_reason_code := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'REASON_CODE'
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    l_itemized_doc_code := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'ITEMIZED_DOC_CODE'
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    l_itemized_doc_ref_number := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'ITEMIZED_DOC_REF_NUMBER'
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    l_is_edit := nvl(dsp_api_shared_data_pkg.get_param_num(
                         i_name          => 'EDITING'
                       , i_mask_error  => com_api_type_pkg.TRUE
                     ), com_api_type_pkg.FALSE);

    if l_is_edit = com_api_type_pkg.FALSE then

        amx_api_dispute_pkg.gen_fulfillment (
            o_fin_id                    => l_fin_id
            , i_original_fin_id         => l_oper_id
            , i_func_code               => l_func_code
            , i_reason_code             => l_reason_code
            , i_itemized_doc_code       => l_itemized_doc_code
            , i_itemized_doc_ref_number => l_itemized_doc_ref_number
        );

        dsp_api_shared_data_pkg.set_param(
            i_name   => 'OPERATION_ID'
          , i_value  => l_fin_id
        );
    else
        amx_api_dispute_pkg.modify_fulfillment (
            i_fin_id                    => l_oper_id
            , i_func_code               => l_func_code
            , i_reason_code             => l_reason_code
            , i_itemized_doc_code       => l_itemized_doc_code
            , i_itemized_doc_ref_number => l_itemized_doc_ref_number
        );

    end if;

end;

procedure gen_first_presentment_reversal is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_trans_amount            com_api_type_pkg.t_money;
    l_trans_currency          com_api_type_pkg.t_name;
    l_is_edit                 com_api_type_pkg.t_boolean;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_trans_amount := dsp_api_shared_data_pkg.get_param_num (
        i_name          => 'TRANS_AMOUNT'
        , i_mask_error  => com_api_type_pkg.TRUE
    );
    l_trans_currency := dsp_api_shared_data_pkg.get_param_char (
        i_name          => 'TRANS_CURRENCY'
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    l_is_edit := nvl(dsp_api_shared_data_pkg.get_param_num(
                         i_name          => 'EDITING'
                       , i_mask_error  => com_api_type_pkg.TRUE
                     ), com_api_type_pkg.FALSE);

    if l_is_edit = com_api_type_pkg.FALSE then

        amx_api_dispute_pkg.gen_first_presentment_rvs(
            o_fin_id                => l_fin_id
            , i_original_fin_id     => l_oper_id
            , i_trans_amount        => l_trans_amount
            , i_trans_currency      => l_trans_currency
        );

        dsp_api_shared_data_pkg.set_param(
            i_name   => 'OPERATION_ID'
          , i_value  => l_fin_id
        );
    else
        amx_api_dispute_pkg.modify_first_presentment_rvs(
            i_fin_id                => l_oper_id
            , i_trans_amount        => l_trans_amount
            , i_trans_currency      => l_trans_currency
        );

    end if;
end;

end;
/

