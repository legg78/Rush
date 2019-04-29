create or replace package body iss_api_reissue_reason_pkg is
/**************************************************
 * API for working with reasons of reissuing <br />
 *
 * Created by A. Alalykin (alalykin@bpcbt.com) at 13.03.2014 <br />
 * Last changed by $Author: alalykin$
 * Revision: $LastChangedRevision: $ <br />
 * Module: @headcom <br/> 
 ****************************************************/
 
-- Define package's name for using for logging
PACKAGE_NAME                constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.';

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
) is
begin
    trc_log_pkg.debug(
        i_text       => PACKAGE_NAME || 'get_command_and_flags: i_inst_id=[#1], i_reissue_reason=[#2]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_reissue_reason
    );

    select r.reissue_command
         , r.pin_request
         , r.pin_mailer_request
         , r.embossing_request
         , r.reiss_start_date_rule
         , r.reiss_expir_date_rule
         , r.perso_priority
         , r.clone_optional_services
      into o_reissue_command
         , o_pin_request
         , o_pin_mailer_request
         , o_embossing_request
         , o_reiss_start_date_rule
         , o_reiss_expir_date_rule
         , o_perso_priority
         , o_clone_optional_services
      from iss_reissue_reason r
     where r.inst_id = i_inst_id 
       and r.reissue_reason = i_reissue_reason;
       
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text       => PACKAGE_NAME || 'get_command_and_flags: no any reissuing reason has been found'
        );
end;

end;
/
