create or replace package ost_api_application_pkg as
/************************************************************
 * API for institution applications <br />
 * Created by Gerbeev I.(gerbeev@bpcbt.com)  at 07.02.2018  <br />
 * Module: ost_api_application_pkg <br />
 * @headcom
 ************************************************************/
procedure process_application(
    i_appl_id      in      com_api_type_pkg.t_long_id
);

procedure process_institution(
    i_appl_data_id  in     com_api_type_pkg.t_long_id
  , i_appl_id       in     com_api_type_pkg.t_long_id
);

procedure process_agent(
    i_appl_data_id  in     com_api_type_pkg.t_long_id
  , i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_appl_id       in     com_api_type_pkg.t_long_id
);

end;
/
