create or replace package body iss_ui_reissue_reason_pkg is
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
  , i_reiss_start_date_rule     in      com_api_type_pkg.t_dict_value
  , i_reiss_expir_date_rule     in      com_api_type_pkg.t_dict_value
  , i_perso_priority            in      com_api_type_pkg.t_dict_value
  , i_clone_optional_services   in      com_api_type_pkg.t_boolean          default null
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_reason: ';
begin
    o_id := iss_reissue_reason_seq.nextval;

    insert into iss_reissue_reason_vw(
        id
      , seqnum
      , inst_id
      , reissue_reason
      , reissue_command
      , pin_request
      , pin_mailer_request
      , embossing_request
      , reiss_start_date_rule
      , reiss_expir_date_rule
      , perso_priority
      , clone_optional_services
    ) values (
        o_id
      , 1
      , i_inst_id
      , i_reissue_reason
      , i_reissue_command
      , i_pin_request
      , i_pin_mailer_request
      , i_embossing_request
      , i_reiss_start_date_rule
      , i_reiss_expir_date_rule
      , i_perso_priority
      , i_clone_optional_services
    );

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
           i_error      => 'DUPLICATE_REISSUE_REASON'
         , i_env_param1 => i_reissue_reason
         , i_env_param2 => i_inst_id
        );
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with o_id[#2], i_inst_id[#3], i_reissue_reason[#4], i_reissue_command[#5], sqlerrm[#1]'
          , i_env_param1 => substr(sqlerrm, 1, 2000)
          , i_env_param2 => o_id
          , i_env_param3 => i_inst_id
          , i_env_param4 => i_reissue_reason
          , i_env_param5 => i_reissue_command
        );
        raise;
end add_reason;

procedure modify_reason(
    i_id                        in      com_api_type_pkg.t_medium_id
  , io_seqnum                   in out  com_api_type_pkg.t_seqnum
  , i_reissue_command           in      com_api_type_pkg.t_dict_value
  , i_pin_request               in      com_api_type_pkg.t_dict_value
  , i_pin_mailer_request        in      com_api_type_pkg.t_dict_value
  , i_embossing_request         in      com_api_type_pkg.t_dict_value
  , i_reiss_start_date_rule     in      com_api_type_pkg.t_dict_value
  , i_reiss_expir_date_rule     in      com_api_type_pkg.t_dict_value
  , i_perso_priority            in      com_api_type_pkg.t_dict_value
  , i_clone_optional_services   in      com_api_type_pkg.t_boolean          default null
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.modify_reason: ';
begin
    update iss_reissue_reason_vw v
       set v.seqnum = io_seqnum
         , v.reissue_command            = coalesce(i_reissue_command, v.reissue_command)
         , v.pin_request                = coalesce(i_pin_request, v.pin_request)
         , v.pin_mailer_request         = coalesce(i_pin_mailer_request, v.pin_mailer_request)
         , v.embossing_request          = coalesce(i_embossing_request, v.embossing_request)
         , v.reiss_start_date_rule      = i_reiss_start_date_rule
         , v.reiss_expir_date_rule      = i_reiss_expir_date_rule
         , v.perso_priority             = i_perso_priority
         , v.clone_optional_services    = coalesce(i_clone_optional_services, v.clone_optional_services)
     where v.id = i_id;

    io_seqnum := io_seqnum + 1;

exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with i_id[#2], io_seqnum[#3], i_reissue_command[#4], sqlerrm[#1]'
          , i_env_param1 => substr(sqlerrm, 1, 2000)
          , i_env_param2 => i_id
          , i_env_param3 => io_seqnum
          , i_env_param4 => i_reissue_command
        );
        raise;
end modify_reason;

procedure remove_reason(
    i_id                  in      com_api_type_pkg.t_medium_id
  , i_seqnum              in      com_api_type_pkg.t_seqnum
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.remove_reason: ';
    l_inst_id                     com_api_type_pkg.t_inst_id;
    l_reissue_reason              com_api_type_pkg.t_dict_value;
begin
       update iss_reissue_reason_vw v
          set v.seqnum = i_seqnum
        where v.id = i_id
    returning v.inst_id, v.reissue_reason
         into l_inst_id, l_reissue_reason;

    delete from iss_reissue_reason_vw v where v.id = i_id;

    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'completed with i_id[#1], i_seqnum[#2], l_inst_id[#3]; l_reissue_reason[#4]'
      , i_env_param1  => i_id
      , i_env_param2  => i_seqnum
      , i_env_param3  => l_inst_id
      , i_env_param4  => l_reissue_reason
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'FAILED with i_id[#2], i_seqnum[#3], l_inst_id[#4]; l_reissue_reason[#5], sqlerrm[#1]'
          , i_env_param1  => substr(sqlerrm, 1, 2000)
          , i_env_param2  => i_id
          , i_env_param3  => i_seqnum
          , i_env_param4  => l_inst_id
          , i_env_param5  => l_reissue_reason
        );
        raise;
end remove_reason;

end;
/
