create or replace package body cst_ibbl_opr_rule_proc_pkg is

procedure load_visa_vss2_params is
    l_source_bin    com_api_type_pkg.t_bin;
    l_sre_id        com_api_type_pkg.t_bin;
    l_oper_id       com_api_type_pkg.t_long_id;
    l_selector      com_api_type_pkg.t_name;
begin

    l_selector := opr_api_shared_data_pkg.get_param_char(
                      i_name            => 'OPERATION_SELECTOR'
                    , i_mask_error      => com_api_type_pkg.TRUE
                    , i_error_value     => opr_api_const_pkg.OPER_SELECTOR_CURRENT
                  );
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id(
                     i_selector => l_selector
                 );

    select src_bin
         , sre_id
      into l_source_bin
         , l_sre_id
      from vis_vss2
     where operation_id = l_oper_id;

    opr_api_shared_data_pkg.set_param(
        i_name    => 'SOURCE_BIN'
      , i_value   => l_source_bin
    );

    opr_api_shared_data_pkg.set_param(
        i_name    => 'SRE_ID'
      , i_value   => l_sre_id
    );
exception
    when too_many_rows
    then
        select src_bin
             , sre_id
          into l_source_bin
             , l_sre_id
          from vis_vss2
         where operation_id = l_oper_id
           and id = (select max(id)
                       from vis_vss2
                      where operation_id = l_oper_id
                    );

        opr_api_shared_data_pkg.set_param(
            i_name    => 'SOURCE_BIN'
          , i_value   => l_source_bin
        );

        opr_api_shared_data_pkg.set_param(
            i_name    => 'SRE_ID'
          , i_value   => l_sre_id
        );
    when no_data_found
    then
        null;
end load_visa_vss2_params;

end cst_ibbl_opr_rule_proc_pkg;
/
