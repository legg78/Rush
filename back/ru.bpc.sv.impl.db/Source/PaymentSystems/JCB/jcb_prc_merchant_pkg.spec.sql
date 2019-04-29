create or replace package jcb_prc_merchant_pkg as
/*********************************************************
 *  Visa outgoing files API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 21.10.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: vis_api_incoming_pkg <br />
 *  @headcom
 **********************************************************/

procedure process (
    i_inst_id              in  com_api_type_pkg.t_inst_id
  , i_full_export          in  com_api_type_pkg.t_boolean         default com_api_type_pkg.FALSE
  , i_lang                 in  com_api_type_pkg.t_dict_value      default null
);

function get_merchant_commission_rate (
    i_merchant_rec         in  jcb_api_type_pkg.t_merchant_rec
  , i_inst_id              in  com_api_type_pkg.t_inst_id         default null
  , i_fee_type             in  com_api_type_pkg.t_dict_value      default null
) return com_api_type_pkg.t_tag;

end;
/
