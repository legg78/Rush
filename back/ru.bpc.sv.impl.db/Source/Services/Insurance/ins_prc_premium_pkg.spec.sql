create or replace package ins_prc_premium_pkg is
/********************************************************* 
 *  process for insurance premium  <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 26.12.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: ins_prc_premium_pkg  <br /> 
 *  @headcom 
 **********************************************************/

procedure process(
    i_inst_id           in      com_api_type_pkg.t_inst_id      default null
);

end;
/
