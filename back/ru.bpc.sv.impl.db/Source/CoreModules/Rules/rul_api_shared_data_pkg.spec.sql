create or replace package rul_api_shared_data_pkg as
/*********************************************************
 *  API for rule shared data <br />
 *  Created by Fomichev E.(fomichev@bpcbt.com)  at 06.12.2011 <br />
 *  Module: rul_api_shared_data_pkg <br />
 *  @headcom
 **********************************************************/

procedure load_params(
    i_entity_type        in            com_api_type_pkg.t_dict_value
  , i_object_id          in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
  , i_full_set           in            com_api_type_pkg.t_boolean       default null
  , i_usage              in            com_api_type_pkg.t_dict_value    default null
);

procedure load_linked_object_params(
    i_dst_entity_type    in            com_api_type_pkg.t_dict_value
  , i_party_type         in            com_api_type_pkg.t_dict_value    default null
  , i_entity_type        in            com_api_type_pkg.t_dict_value
  , i_object_id          in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_card_params(
    i_card_id            in            com_api_type_pkg.t_medium_id
  , i_seq_number         in            com_api_type_pkg.t_tiny_id       default null
  , i_expir_date         in            date                             default null
  , i_card_instance_id   in            com_api_type_pkg.t_medium_id     default null
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_card_params(
    i_card               in            iss_api_type_pkg.t_card
  , i_card_instance      in            iss_api_type_pkg.t_card_instance
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_account_params(
    i_account_id         in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
  , i_usage              in            com_api_type_pkg.t_dict_value    default null
);

procedure load_account_params(
    i_account            in            acc_api_type_pkg.t_account_rec
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
  , i_usage              in            com_api_type_pkg.t_dict_value    default null
);

procedure load_contract_params(
    i_contract_id        in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_contract_params(
    i_contract           in            prd_api_type_pkg.t_contract
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_customer_params(
    i_customer_id        in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
  , i_usage              in            com_api_type_pkg.t_dict_value    default null
);

procedure load_customer_params(
    i_customer           in            prd_api_type_pkg.t_customer
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
  , i_usage              in            com_api_type_pkg.t_dict_value    default null
);

procedure load_terminal_params(
    i_terminal_id        in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
  , i_full_set           in            com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

procedure load_terminal_params(
    i_terminal           in            aap_api_type_pkg.t_terminal
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
  , i_full_set           in            com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

procedure load_merchant_params(
    i_merchant_id        in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_merchant_params(
    i_merchant           in            aap_api_type_pkg.t_merchant
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_oper_params(
    i_oper_id            in            com_api_type_pkg.t_long_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_payment_order_params(
    i_payment_order_id   in            com_api_type_pkg.t_long_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_extended_terminal_params(
    i_terminal_id        in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_object(
    i_entity_type        in            com_api_type_pkg.t_dict_value
  , i_object_id          in            com_api_type_pkg.t_long_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_application_params(
    i_application        in            app_api_type_pkg.t_application_rec
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_application_params(
    i_application_id     in            com_api_type_pkg.t_long_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_invoice_params(
    i_invoice_id         in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_entry_params(
    i_entry_id           in            com_api_type_pkg.t_long_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_flexible_fields(
    i_entity_type  in            com_api_type_pkg.t_dict_value
  , i_object_id    in            com_api_type_pkg.t_long_id
  , i_usage        in            com_api_type_pkg.t_dict_value
  , io_params      in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_id_object_params(
    i_id           in      com_api_type_pkg.t_long_id
);

procedure save_oper_params(
    io_params              in out nocopy com_api_type_pkg.t_param_tab
  , i_msg_type             in            com_api_type_pkg.t_dict_value
  , i_oper_type            in            com_api_type_pkg.t_dict_value
  , i_sttl_type            in            com_api_type_pkg.t_dict_value
  , i_status               in            com_api_type_pkg.t_dict_value
  , i_status_reason        in            com_api_type_pkg.t_dict_value
  , i_terminal_type        in            com_api_type_pkg.t_dict_value
  , i_mcc                  in            com_api_type_pkg.t_mcc
  , i_oper_currency        in            com_api_type_pkg.t_dict_value
  , i_is_reversal          in            com_api_type_pkg.t_boolean
  , i_iss_card_network_id  in            com_api_type_pkg.t_network_id
  , i_match_status         in            com_api_type_pkg.t_dict_value
  , i_merchant_number      in            com_api_type_pkg.t_merchant_number
  , i_auth_resp_code       in            com_api_type_pkg.t_dict_value
  , i_acq_resp_code        in            com_api_type_pkg.t_dict_value
  , i_payment_order_id     in            com_api_type_pkg.t_long_id
);

procedure load_dpp_params(
    i_dpp_id               in            com_api_type_pkg.t_long_id
  , io_params              in out nocopy com_api_type_pkg.t_param_tab
);

procedure load_document_params(
    i_documnet_id          in            com_api_type_pkg.t_long_id
  , io_params              in out nocopy com_api_type_pkg.t_param_tab
);

end rul_api_shared_data_pkg;
/
