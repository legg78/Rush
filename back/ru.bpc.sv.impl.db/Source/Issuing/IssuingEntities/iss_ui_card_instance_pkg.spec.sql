create or replace package iss_ui_card_instance_pkg is
/************************************************************
 * User interface for card instance <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.12.2013 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: iss_ui_card_instance_pkg <br />
 * @headcom
 ************************************************************/
    
/*
 * Modify card instance requesting action
 * @param  i_card_instance_id     - Card instance identifier
 * @param  i_pin_request          - Requesting action about PIN generation
 * @param  i_pin_mailer_request   - Requesting action about PIN mailer printing
 * @param  i_embossing_request    - Requesting action about plastic embossing
 * @param  i_perso_priority       - Personalization priority
 * @ param i_request_type         - Request type (dictiorany RQTP0001)
 */
    -- single update
    procedure modify_requesting_action (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
        , i_pin_request         in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_perso_priority      in com_api_type_pkg.t_dict_value
        , i_request_type        in com_api_type_pkg.t_dict_value
        , o_message             out com_api_type_pkg.t_text
    );

/*
 * Modify card instance requesting action
 * @param  i_card_instance_id_tab - Card instance identifier array
 * @param  i_pin_request          - Requesting action about PIN generation
 * @param  i_pin_mailer_request   - Requesting action about PIN mailer printing
 * @param  i_embossing_request    - Requesting action about plastic embossing
 * @param  i_perso_priority       - Personalization priority
 */
    -- group update with common settings
    procedure modify_requesting_action (
        i_card_instance_id_tab  in num_tab_tpt
        , i_pin_request         in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_perso_priority      in com_api_type_pkg.t_dict_value
    );

/*
 * Modify card instance requesting action
 * @param  i_card_instance_id_tab - Card instance identifier array
 * @param  i_pin_request          - Requesting action about PIN generation array
 * @param  i_pin_mailer_request   - Requesting action about PIN mailer printing array
 * @param  i_embossing_request    - Requesting action about plastic embossing array
 * @param  i_perso_priority       - Personalization priority
 */
    -- group update with individual settings
    procedure modify_requesting_action (
        i_card_instance_id_tab  in num_tab_tpt
        , i_pin_request         in raw_data_tpt
        , i_pin_mailer_request  in raw_data_tpt
        , i_embossing_request   in raw_data_tpt
        , i_perso_priority      in raw_data_tpt
    );
    
    procedure change_card_security_data (
         i_card_id                in com_api_type_pkg.t_medium_id
       , i_card_number            in com_api_type_pkg.t_card_number
       , i_expiration_date        in date
       , i_card_sequental_number  in com_api_type_pkg.t_tiny_id
       , i_card_instance_id       in com_api_type_pkg.t_medium_id
       , i_state                  in com_api_type_pkg.t_dict_value
       , i_pvv                    in com_api_type_pkg.t_tiny_id
       , i_pin_offset             in com_api_type_pkg.t_cmid
       , i_pin_block              in com_api_type_pkg.t_pin_block
       , i_key_index              in com_api_type_pkg.t_tiny_id
       , i_pin_block_format       in com_api_type_pkg.t_dict_value
       , i_issue_date             in date                              default null
    );

    procedure update_delivery_ref_number(
        i_inst_id               in com_api_type_pkg.t_inst_id
      , i_agent_id              in com_api_type_pkg.t_agent_id
      , i_card_type_id          in com_api_type_pkg.t_tiny_id
      , i_card_instance_id_tab  in num_tab_tpt 
      , i_delivery_ref_number   in com_api_type_pkg.t_name
      , i_lang                  in com_api_type_pkg.t_dict_value    default com_api_const_pkg.DEFAULT_LANGUAGE
      , i_max_name_size         in com_api_type_pkg.t_tiny_id       default 200
    );

    procedure modify_delivery_status(
        i_card_instance_id_tab  in num_tab_tpt
      , i_delivery_status       in com_api_type_pkg.t_dict_value
      , i_event_date            in date
    );

    procedure modify_delivery_status(
        i_delivery_ref_number   in com_api_type_pkg.t_name
      , i_delivery_status       in com_api_type_pkg.t_dict_value
      , i_event_date            in date
    );

end iss_ui_card_instance_pkg;
/
