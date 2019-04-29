create or replace package iss_ui_application_pkg as
/*******************************************************************
*  API for application's flow <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 03.08.2010 <br />
*  Last changed by $Author: filimonov $ <br />
*  $LastChangedDate:: 2011-12-09 19:19:12 +0400#$ <br />
*  Revision: $LastChangedRevision: 14428 $ <br />
*  Module: app_ui_flow_pkg <br />
*  @headcom
******************************************************************/

procedure get_customer_xml (
    o_xml               out  clob
  , i_customer_id       in   com_api_type_pkg.t_long_id
  , i_contract_id       in   com_api_type_pkg.t_long_id
);

end iss_ui_application_pkg;
/
