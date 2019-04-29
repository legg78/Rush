create or replace package nbc_cst_fin_message_pkg as

procedure set_participant_type(
    i_auth_rec              in            aut_api_type_pkg.t_auth_rec
  , i_inst_id               in            com_api_type_pkg.t_inst_id
  , io_fin_rec              in out nocopy nbc_api_type_pkg.t_nbc_fin_mes_rec
  , i_bank_code             in            com_api_type_pkg.t_name
  , i_iss_inst_code_by_pan  in            com_api_type_pkg.t_name
);

end;
/
