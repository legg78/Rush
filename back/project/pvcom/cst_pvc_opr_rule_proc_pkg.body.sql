create or replace package body cst_pvc_opr_rule_proc_pkg is

procedure load_iss_acq_agents_equal_flag
is
    l_account_id              com_api_type_pkg.t_account_id;
    l_aging_period            com_api_type_pkg.t_tiny_id;
    l_result_param_name       com_api_type_pkg.t_name;
begin
    opr_api_shared_data_pkg.set_param(
        i_name    => 'CST_PVC_ISS_ACQ_AGENTS_SAME'
      , i_value   => cst_pvc_com_pkg.iss_and_acq_agents_are_same(opr_api_shared_data_pkg.get_operation().id)
    );
end load_iss_acq_agents_equal_flag;

end cst_pvc_opr_rule_proc_pkg;
/
