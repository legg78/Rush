create or replace package jcb_api_fin_pkg is
/********************************************************* 
 *  API for JCB finance message  <br /> 
 *  Created by Khougaev (khougaev@bpcbt.com)  at 05.11.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: jcb_api_fin_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

    procedure get_processing_date (
        i_id                    in com_api_type_pkg.t_long_id
      , i_file_id               in com_api_type_pkg.t_short_id
      , o_p3007_2               out jcb_api_type_pkg.t_p3007_2
    );

    function estimate_messages_for_upload (
        i_network_id            in      com_api_type_pkg.t_tiny_id
      , i_cmid                  in      jcb_api_type_pkg.t_de033
      , i_start_date            in      date default null
      , i_end_date              in      date default null
      , i_inst_id               in      com_api_type_pkg.t_inst_id default null
      , i_include_affiliate     in      com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    ) return number;

    procedure enum_messages_for_upload (
        o_fin_cur               in out sys_refcursor
      , i_network_id            in     com_api_type_pkg.t_tiny_id
      , i_cmid                  in     jcb_api_type_pkg.t_de033
      , i_start_date            in     date                       default null
      , i_end_date              in     date                       default null
      , i_inst_id               in     com_api_type_pkg.t_inst_id default null
      , i_include_affiliate     in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    );

    procedure get_fin (
        i_id                    in com_api_type_pkg.t_long_id
        , o_fin_rec             out jcb_api_type_pkg.t_fin_rec
        , i_mask_error          in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    );

    procedure get_fin (
        i_mti                   in jcb_api_type_pkg.t_mti
        , i_de024               in jcb_api_type_pkg.t_de024
        , i_is_reversal         in com_api_type_pkg.t_boolean
        , i_dispute_id          in com_api_type_pkg.t_long_id
        , o_fin_rec             out jcb_api_type_pkg.t_fin_rec
        , i_mask_error          in com_api_type_pkg.t_boolean
    );

    procedure get_original_fin (
        i_mti                   in jcb_api_type_pkg.t_mti
        , i_de002               in jcb_api_type_pkg.t_de002
        , i_de024               in jcb_api_type_pkg.t_de024
        , i_de031               in jcb_api_type_pkg.t_de031
        , i_id                  in com_api_type_pkg.t_long_id := null
        , o_fin_rec             out jcb_api_type_pkg.t_fin_rec
    );

    procedure get_original_fee (
        i_mti                   in jcb_api_type_pkg.t_mti
        , i_de002               in jcb_api_type_pkg.t_de002
        , i_de024               in jcb_api_type_pkg.t_de024
        , i_de031               in jcb_api_type_pkg.t_de031
        , i_de094               in jcb_api_type_pkg.t_de094 := null
        , i_p3201               in jcb_api_type_pkg.t_p3201
        , o_fin_rec             out jcb_api_type_pkg.t_fin_rec
    );

    function pack_message (
        i_fin_rec               in jcb_api_type_pkg.t_fin_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_de071               in jcb_api_type_pkg.t_de071
        , i_with_rdw            in com_api_type_pkg.t_boolean     := null
    ) return blob;

    procedure mark_ok_uploaded (
        i_rowid                 in com_api_type_pkg.t_rowid_tab
        , i_id                  in com_api_type_pkg.t_number_tab
        , i_de071               in com_api_type_pkg.t_number_tab
        , i_file_id             in com_api_type_pkg.t_number_tab
    );

    procedure mark_error_uploaded (
        i_rowid                 in com_api_type_pkg.t_rowid_tab
    );

    procedure create_operation(
        i_fin_rec             in jcb_api_type_pkg.t_fin_rec
      , i_standard_id         in com_api_type_pkg.t_tiny_id
      , i_auth                in aut_api_type_pkg.t_auth_rec    :=          null
      , i_status              in com_api_type_pkg.t_dict_value  :=          null
      , i_incom_sess_file_id  in com_api_type_pkg.t_long_id     :=          null
      , i_host_id             in com_api_type_pkg.t_tiny_id     default     null
    );

    procedure put_message (
        i_fin_rec               in jcb_api_type_pkg.t_fin_rec
    );

    procedure create_from_auth (
        i_auth_rec              in aut_api_type_pkg.t_auth_rec
        , i_id                  in com_api_type_pkg.t_long_id
        , i_inst_id             in com_api_type_pkg.t_inst_id := null
        , i_network_id          in com_api_type_pkg.t_tiny_id := null
        , i_status              in com_api_type_pkg.t_dict_value := null
        , i_collection_only     in com_api_type_pkg.t_boolean := null
    );

    procedure create_incoming_first_pres (
        i_mes_rec               in jcb_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
        , o_fin_ref_id         out com_api_type_pkg.t_long_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_create_operation    in com_api_type_pkg.t_boolean := null
        , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    );

    procedure create_incoming_second_pres (
        i_mes_rec               in jcb_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_create_operation    in com_api_type_pkg.t_boolean := null
        , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    );

    procedure create_incoming_retrieval (
        i_mes_rec               in jcb_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_create_operation    in com_api_type_pkg.t_boolean := null
        , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    );

    procedure create_incoming_req_acknowl (
        i_mes_rec               in jcb_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_create_operation    in com_api_type_pkg.t_boolean
        , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    );

    procedure create_incoming_chargeback (
        i_mes_rec               in jcb_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_create_operation    in com_api_type_pkg.t_boolean := null
        , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    );

    procedure create_incoming_fee (
        i_mes_rec               in jcb_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_create_operation    in com_api_type_pkg.t_boolean := null
        , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    );
   
    procedure init_no_original_id_tab;

    procedure process_no_original_id_tab;

    function set_de054(
        i_amount                in com_api_type_pkg.t_money
      , i_currency              in com_api_type_pkg.t_curr_code
      , i_type                  in com_api_type_pkg.t_dict_value
    ) return jcb_api_type_pkg.t_de054;

end;
/
