create or replace package aap_api_application_pkg as
/*********************************************************
*  Application API for acquiring <br />
*  Created by filimonov A.(filimonov@bpc.ru)  at 14.09.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: AAP_API_APPLICATION_PKG <br />
*  @headcom
**********************************************************/

procedure process_application(
    i_appl_id              in            com_api_type_pkg.t_long_id          default null
);

end;
/
