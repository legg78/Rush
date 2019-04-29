create or replace package asc_api_scenario_pkg as
/*********************************************************
 *  API for Authorization scenarios <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 19.03.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: asc_api_scenario_pkg <br />
 *  @headcom
 **********************************************************/
procedure get_scenario_id(
    i_param_tab         in      com_api_type_pkg.t_param_tab
  , o_scenario_id          out  com_api_type_pkg.t_tiny_id
);

end;
/
