create or replace package cst_bnv_napas_api_fin_msg_pkg as

function put_message(
    i_fin_rec              in     cst_bnv_napas_api_type_pkg.t_bnv_napas_fin_mes_rec
) return com_api_type_pkg.t_long_id;

procedure create_operation(
    i_fin_rec              in     cst_bnv_napas_api_type_pkg.t_bnv_napas_fin_mes_rec
  , i_standard_id          in     com_api_type_pkg.t_tiny_id
  , i_status               in     com_api_type_pkg.t_dict_value                 default null
  , i_create_disp_case     in     com_api_type_pkg.t_boolean                    default com_api_const_pkg.FALSE
  , i_incom_sess_file_id   in     com_api_type_pkg.t_long_id                    default null
);

end;
/
