create or replace package way_api_fin_message_pkg as
/*********************************************************
 *  API for VISA financial message <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 21.10.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: VIS_API_FIN_MESSAGE_PKG   <br />
 *  @headcom
 **********************************************************/
PROGRAM_REG_ID_C01    constant    com_api_type_pkg.t_dict_value := 'C01';
PROGRAM_REG_ID_C07    constant    com_api_type_pkg.t_dict_value := 'C07';

g_way_mcc_group_references        com_api_type_pkg.t_array_element_cache_tab;
g_way_message_codes               com_api_type_pkg.t_array_element_cache_tab;

/*
procedure get_fin_mes (
    i_id                    in com_api_type_pkg.t_long_id
    , o_fin_rec             out vis_api_type_pkg.t_visa_fin_mes_rec
    , i_mask_error          in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
);

function estimate_messages_for_upload (
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_start_date          in date default null
    , i_end_date            in date default null
) return number;
*/
function estimate_fin_for_upload (
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_start_date          in date default null
    , i_end_date            in date default null
) return number;
/*
procedure enum_messages_for_upload (
    o_fin_cur               in out sys_refcursor
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_start_date          in date default null
    , i_end_date            in date default null
);
*/
/*
procedure enum_fin_msg_for_upload (
    o_fin_cur               in out sys_refcursor
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_start_date          in date default null
    , i_end_date            in date default null
) ;
*/
/*
function get_original_id (
    i_fin_rec               in vis_api_type_pkg.t_visa_fin_mes_rec
  , i_fee_rec               in vis_api_type_pkg.t_fee_rec          default null
) return com_api_type_pkg.t_long_id;

procedure get_fee (
    i_id                    in com_api_type_pkg.t_long_id
    , o_fee_rec             out vis_api_type_pkg.t_fee_rec
);

procedure get_retrieval (
    i_id                    in com_api_type_pkg.t_long_id
    , o_retrieval_rec       out vis_api_type_pkg.t_retrieval_rec
);
*/
procedure process_auth(
    i_auth_rec            in aut_api_type_pkg.t_auth_rec
  , i_inst_id             in com_api_type_pkg.t_inst_id     default null
  , i_network_id          in com_api_type_pkg.t_tiny_id     default null
  , i_collect_only        in varchar2                       default null
  , i_status              in com_api_type_pkg.t_dict_value  default null
  , io_fin_mess_id    in out com_api_type_pkg.t_long_id
);
/*
procedure create_operation (
    i_fin_rec             in     vis_api_type_pkg.t_visa_fin_mes_rec
  , i_standard_id         in     com_api_type_pkg.t_tiny_id
  , i_fee_rec             in     vis_api_type_pkg.t_fee_rec          default null
  , i_status              in     com_api_type_pkg.t_dict_value       default null
  , i_create_disp_case    in     com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , i_incom_sess_file_id  in     com_api_type_pkg.t_long_id          default null
  , i_oper_type           in     com_api_type_pkg.t_dict_value       default null
);
*/
function put_message (
    i_fin_rec               in vis_api_type_pkg.t_visa_fin_mes_rec
) return com_api_type_pkg.t_long_id;
/*
procedure put_retrieval (
    i_retrieval_rec         in vis_api_type_pkg.t_retrieval_rec
);

procedure put_fee (
    i_fee_rec               in vis_api_type_pkg.t_fee_rec
);

procedure put_fraud (
    i_fraud_rec             in vis_api_type_pkg.t_visa_fraud_rec
);

function is_collection_allow (
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id 
    , i_mcc                 in com_api_type_pkg.t_mcc
) return com_api_type_pkg.t_boolean;

function get_original_id (
    i_fin_rec               in vis_api_type_pkg.t_visa_fin_mes_rec
  , i_fee_rec               in vis_api_type_pkg.t_fee_rec          default null
  , o_need_original_id     out com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_long_id;


 -- Function parses incoming value card_data_input_mode and returns POS entry mode.
*/ 
function get_pos_entry_mode(
    i_card_data_input_mode  in com_api_type_pkg.t_dict_value
) return aut_api_type_pkg.t_pos_entry_mode;
/*
function is_visa (
    i_id                      in    com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

function is_visa_sms(
    i_id    in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;
*/
end way_api_fin_message_pkg;
/
