create or replace package iss_ui_reissue_reason_pkg is
/**************************************************
 * UI for working with reasons of reissuing <br />
 *
 * Created by A. Alalykin (alalykin@bpcbt.com) at 13.03.2014 <br />
 * Last changed by $Author: alalykin$
 * Revision: $LastChangedRevision: $ <br />
 * Module: @headcom <br/> 
 ****************************************************/

procedure add_reason(
    o_id                       out      com_api_type_pkg.t_medium_id
  , i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_reissue_reason            in      com_api_type_pkg.t_dict_value
  , i_reissue_command           in      com_api_type_pkg.t_dict_value
  , i_pin_request               in      com_api_type_pkg.t_dict_value
  , i_pin_mailer_request        in      com_api_type_pkg.t_dict_value
  , i_embossing_request         in      com_api_type_pkg.t_dict_value
  , i_reiss_start_date_rule     in      com_api_type_pkg.t_dict_value   default null
  , i_reiss_expir_date_rule     in      com_api_type_pkg.t_dict_value   default null
  , i_perso_priority            in      com_api_type_pkg.t_dict_value   default null
  , i_clone_optional_services   in      com_api_type_pkg.t_boolean      default null 
);

procedure modify_reason(
    i_id                        in      com_api_type_pkg.t_medium_id
  , io_seqnum                   in out  com_api_type_pkg.t_seqnum
  , i_reissue_command           in      com_api_type_pkg.t_dict_value
  , i_pin_request               in      com_api_type_pkg.t_dict_value
  , i_pin_mailer_request        in      com_api_type_pkg.t_dict_value
  , i_embossing_request         in      com_api_type_pkg.t_dict_value
  , i_reiss_start_date_rule     in      com_api_type_pkg.t_dict_value   default null
  , i_reiss_expir_date_rule     in      com_api_type_pkg.t_dict_value   default null
  , i_perso_priority            in      com_api_type_pkg.t_dict_value   default null
  , i_clone_optional_services   in      com_api_type_pkg.t_boolean      default null
);

procedure remove_reason(
    i_id                  in      com_api_type_pkg.t_medium_id
  , i_seqnum              in      com_api_type_pkg.t_seqnum
);

end;
/
