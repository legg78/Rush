create or replace package iss_api_reissue_reason_pkg is
/**************************************************
 * API for working with reasons of reissuing <br />
 *
 * Created by A. Alalykin (alalykin@bpcbt.com) at 13.03.2014 <br />
 * Last changed by $Author: alalykin$
 * Revision: $LastChangedRevision: $ <br />
 * Module: @headcom <br/> 
 ****************************************************/

/**************************************************
 * Passes into out parameters reissue command and flags that are defined by reissuing reason <i_reissue_reason>
 ***************************************************/
procedure get_command_and_flags(
    i_reissue_reason             in com_api_type_pkg.t_dict_value
  , i_inst_id                    in com_api_type_pkg.t_inst_id
  , o_reissue_command           out com_api_type_pkg.t_dict_value
  , o_pin_request               out com_api_type_pkg.t_dict_value
  , o_pin_mailer_request        out com_api_type_pkg.t_dict_value
  , o_embossing_request         out com_api_type_pkg.t_dict_value
  , o_reiss_start_date_rule     out com_api_type_pkg.t_dict_value
  , o_reiss_expir_date_rule     out com_api_type_pkg.t_dict_value
  , o_perso_priority            out com_api_type_pkg.t_dict_value
  , o_clone_optional_services   out com_api_type_pkg.t_boolean
);

end;
/
