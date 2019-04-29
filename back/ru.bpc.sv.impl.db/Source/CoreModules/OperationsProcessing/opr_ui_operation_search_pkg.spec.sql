create or replace package opr_ui_operation_search_pkg is

type t_search_param_rec is record (
    -- Global search mode:
    tab_name                  com_api_type_pkg.t_name
  , participant_mode          com_api_type_pkg.t_name
  , is_h2h_operations         com_api_type_pkg.t_name
  , host_id_from              com_api_type_pkg.t_long_id
  , host_id_till              com_api_type_pkg.t_long_id
  , records_limit             com_api_type_pkg.t_tiny_id
  , privil_limitation         com_api_type_pkg.t_full_desc

    -- Common search values (left column):
  , host_date_from            date
  , host_date_till            date
  , status                    com_api_type_pkg.t_dict_value
  , status_reason             com_api_type_pkg.t_dict_value
  , msg_type                  com_api_type_pkg.t_dict_value
  , sttl_type                 com_api_type_pkg.t_dict_value
  , sttl_types                com_api_type_pkg.t_full_desc
  , auth_code                 com_api_type_pkg.t_auth_code
  , is_reversal               com_api_type_pkg.t_boolean
  , terminal_type             com_api_type_pkg.t_dict_value
  , external_auth_id          com_api_type_pkg.t_attr_name

    -- Common search values (right column):
  , oper_id                   com_api_type_pkg.t_long_id
  , terminal_number           com_api_type_pkg.t_name
  , oper_type                 com_api_type_pkg.t_dict_value
  , session_id                com_api_type_pkg.t_long_id
  , originator_refnum         com_api_type_pkg.t_rrn         -- RRN
  , network_refnum            com_api_type_pkg.t_rrn         -- ARN
  , mcc                       com_api_type_pkg.t_mcc
  , oper_date_from            date
  , oper_date_till            date
  , oper_reason               com_api_type_pkg.t_dict_value

    -- Participant search values:
  , participant_type          com_api_type_pkg.t_dict_value
  , card_mask                 com_api_type_pkg.t_card_number
  , card_mask_postfix         com_api_type_pkg.t_card_number
  , reversed_card_mask        com_api_type_pkg.t_card_number
  , encoded_card_mask         com_api_type_pkg.t_card_number
  , client_id_value           com_api_type_pkg.t_name
  , merchant_name             com_api_type_pkg.t_name
  , acq_inst_bin              com_api_type_pkg.t_bin
  , inst_id                   com_api_type_pkg.t_tiny_id
  , account_number            com_api_type_pkg.t_account_number
  , client_id_type            com_api_type_pkg.t_dict_value
  , merchant_number           com_api_type_pkg.t_name
  , card_token                com_api_type_pkg.t_card_number

    -- Tags search values:
  , tag_value                 com_api_type_pkg.t_full_desc
  , tag_id                    com_api_type_pkg.t_short_id

    -- Payment order search values:
  , purpose_id                com_api_type_pkg.t_long_id
  , sender_customer_number    com_api_type_pkg.t_name
  , order_status              com_api_type_pkg.t_dict_value
  , reciever_customer_number  com_api_type_pkg.t_name

    -- Document search values:
  , document_number           com_api_type_pkg.t_name
  , document_date             date
  , document_type             com_api_type_pkg.t_dict_value

    -- Customer search values:
  , customer_number           com_api_type_pkg.t_name
  , customer_id               com_api_type_pkg.t_long_id

    -- Card search values:
  , card_id                   com_api_type_pkg.t_medium_id
  , card_expir_date           date

    -- Account search values:
  , account_id                com_api_type_pkg.t_medium_id
  , split_hash                com_api_type_pkg.t_tiny_id
);


procedure get_ref_cur(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , i_first_row         in      com_api_type_pkg.t_short_id
  , i_last_row          in      com_api_type_pkg.t_short_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt := null
  , i_force_search      in      com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE
  , i_one_step_search   in      com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE
  , io_oper_id_tab      in out  nocopy num_tab_tpt
);

procedure get_row_count(
    o_row_count            out  com_api_type_pkg.t_short_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_force_search      in      com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE
  , o_oper_id_tab          out  nocopy num_tab_tpt
);

procedure get_opr_account_row_count(
    o_row_count            out  com_api_type_pkg.t_short_id
  , i_param_tab         in      com_param_map_tpt
);

procedure get_opr_account_ref_cur(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , i_first_row         in      com_api_type_pkg.t_short_id
  , i_last_row          in      com_api_type_pkg.t_short_id
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt := null
);

procedure get_query_statement(
    io_param_rec        in out  nocopy t_search_param_rec
  , o_sql_statement        out  nocopy com_api_type_pkg.t_sql_statement
);

function get_cached_object_id return num_tab_tpt;

function get_cached_object_list return opr_ui_operation_list_tpt;

end opr_ui_operation_search_pkg;
/
