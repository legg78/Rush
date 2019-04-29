create or replace package pmo_api_application_pkg as
/************************************************************
 * API for payment applications <br />
 * Created by Fomichev A.(fomichev@bpcbt.com)  at 04.03.2013  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: pmo_api_application_pkg <br />
 * @headcom
 ************************************************************/
procedure process_application(
    i_appl_id      in      com_api_type_pkg.t_long_id          default null
);

end;
/
