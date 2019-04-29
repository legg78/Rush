create or replace package acq_api_mcc_selection_pkg as
/*********************************************************
 *  API for MCC selection <br />
 *  Created by Krukov E.(krukov@bpcbt.com)  at 13.12.2011 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: ACQ_API_MCC_SELECTION_PKG  <br />
 *  @headcom
 **********************************************************/

function get_mcc (
    i_oper_type                 in com_api_type_pkg.t_dict_value
    , i_mcc_template_id         in com_api_type_pkg.t_medium_id := null
    , i_purpose_id              in com_api_type_pkg.t_short_id := null
    , i_oper_reason             in com_api_type_pkg.t_dict_value := null
) return com_api_type_pkg.t_mcc;

end;
/
