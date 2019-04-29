create or replace package cpn_api_application_pkg is

/*
 * Processing block CAMPAIGN of an issuing/acquiring application, it doesn't relate to campaign application;
 * the procedure activate/deactivate promo campaign for all appropriate entity objects of incoming customer.
 */
procedure process_campaign(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
);

procedure process_application(
    i_appl_id              in            com_api_type_pkg.t_long_id
);

end;
/
