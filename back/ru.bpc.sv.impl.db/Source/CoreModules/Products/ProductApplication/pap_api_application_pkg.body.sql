create or replace package body pap_api_application_pkg as

procedure process_application(
    i_appl_id              in            com_api_type_pkg.t_long_id  default null
) is
    l_root_id               com_api_type_pkg.t_long_id;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_appl_id               com_api_type_pkg.t_long_id;
    l_product_data_id       com_api_type_pkg.t_long_id;
    l_product_id            com_api_type_pkg.t_short_id;
begin

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'APPLICATION'
      , i_parent_id     => null
      , o_appl_data_id  => l_root_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'APPLICATION_ID'
      , i_parent_id     => l_root_id
      , o_element_value => l_appl_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'INSTITUTION_ID'
      , i_parent_id     => l_root_id
      , o_element_value => l_inst_id
    );

    rul_api_param_pkg.set_param(
        i_value         => l_inst_id
      , i_name          => 'INST_ID'
      , io_params       => app_api_application_pkg.g_params
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'PRODUCT'
      , i_parent_id     => l_root_id
      , o_appl_data_id  => l_product_data_id
    );

    if l_product_data_id is not null then
        app_api_product_pkg.process_product(
            i_appl_data_id  => l_product_data_id
          , i_inst_id       => l_inst_id
          , o_product_id    => l_product_id
        );
    end if;

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => l_root_id
          , i_element_name  => 'APPLICATION'
        );
end;

end;
/
