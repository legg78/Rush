create or replace package opr_api_reversal_pkg is
/********************************************************* 
 *  Operation reversal API <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com) at 01.01.2013 <br />
 *  Last changed by $Author: kopachev $ <br />
 *  $LastChangedDate:: 2013-09-27 16:53:04 +0400#$ <br />
 *  Revision: $LastChangedRevision: 35108 $ <br />
 *  Module:  opr_api_reversal_pkg  <br />
 *  @headcom
 **********************************************************/

    function reversal_exists (
        i_id                        in com_api_type_pkg.t_long_id
        , o_oper_amount             out com_api_type_pkg.t_money
        , o_oper_currency           out com_api_type_pkg.t_curr_code
        , i_mask_error              in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    ) return com_api_type_pkg.t_boolean;
   
    function reversal_exists (
        i_id                        in com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_boolean;

    function get_reversals_amount(
        i_original_id               in com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_money;

end;
/
