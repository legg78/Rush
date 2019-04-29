create or replace package itf_prc_cardgen_pkg is
/************************************************************
 * CardGen processes <br />
 * Created by Kolodkina Y. (kolodkina@bpcbt.com) at 02.10.2014 <br />
 * Module: ITF_PRC_CARDGEN_PKG <br />
 * @headcom
 ************************************************************/

/*
 * Personalization process without batch.
 * @param  i_pin_mailer_request         - Requesting action about PIN mailer printing
 * @param  i_inst_id                    - Institution identifier
 * @param  i_agent_id                   - Agent identifier
 * @param  i_product_id                 - Product identifier
 * @param  i_card_type_id               - Card type identifier
 * @param  i_perso_priority             - Personalization priority
 * @param  i_sort_id                    - Personalization sorting
 * @param  i_lang                       - Language pin mailer
 * @param  i_empty_address              - Export without address
 * @param  i_check_cardholder_name      - Check cardholder name
 * @param  i_card_count                 - Count of generated cards
 * @param  i_include_limits             - Export with limits
 * @param  i_include_service            - Export with services
 * @param  i_include_flexible_fields    - Export with flexible fields
 * @param  i_ocg_version                - OCG file version
 * @param  i_replace_inst_id_by_number  - Replace institution id with institution number
 * @param  i_session_id                 - Export with sessdion identifier
 * @param  i_start_date                 - Export from date
 * @param  i_end_date                   - Export to date
 * @param  i_flow_id                    - Export with flow identifier
*/
procedure generate_without_batch(
    i_pin_mailer_request        in     com_api_type_pkg.t_dict_value  default null
  , i_inst_id                   in     com_api_type_pkg.t_inst_id
  , i_agent_id                  in     com_api_type_pkg.t_agent_id    default null
  , i_product_id                in     com_api_type_pkg.t_short_id    default null
  , i_card_type_id              in     com_api_type_pkg.t_tiny_id     default null
  , i_perso_priority            in     com_api_type_pkg.t_dict_value  default null
  , i_sort_id                   in     com_api_type_pkg.t_tiny_id
  , i_lang                      in     com_api_type_pkg.t_dict_value
  , i_empty_address             in     com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
  , i_check_cardholder_name     in     com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
  , i_card_count                in     com_api_type_pkg.t_tiny_id     default null
  , i_include_limits            in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_include_service           in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_include_flexible_fields   in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_ocg_version               in     com_api_type_pkg.t_name        default null
  , i_replace_inst_id_by_number in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_session_id                in     com_api_type_pkg.t_long_id     default null
  , i_start_date                in     date                           default null
  , i_end_date                  in     date                           default null
  , i_flow_id                   in     com_api_type_pkg.t_tiny_id     default null
);

/*
 * Loading cardGen file into SV2
 * @param  i_state               - State of card
 */
procedure load_cardgen_file(
    i_card_state               in     com_api_type_pkg.t_dict_value
);

end;
/
