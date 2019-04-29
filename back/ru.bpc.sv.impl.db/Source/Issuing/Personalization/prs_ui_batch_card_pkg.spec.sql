create or replace package prs_ui_batch_card_pkg is
/************************************************************
 * User interface for batch for personalisation <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 10.12.2010 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-08-28 12:43:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_batch_card_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add card into batch
 */
    procedure add_batch_card (
        i_batch_id                  in com_api_type_pkg.t_short_id
        , i_card_instance_id        in com_api_type_pkg.t_medium_id
        , o_warning_msg             out com_api_type_pkg.t_text
    );

/*
 * Remove card from batch
 */
    procedure remove_batch_card (
        i_batch_id                  in com_api_type_pkg.t_short_id
        , i_card_instance_id        in com_api_type_pkg.t_medium_id
    );

/*
 * Include cards into batch by filters
 */
    procedure mark_batch_card (
        i_batch_id                  in com_api_type_pkg.t_short_id
        , i_agent_id                in com_api_type_pkg.t_agent_id
        , i_product_id              in com_api_type_pkg.t_short_id
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , i_blank_type_id           in com_api_type_pkg.t_tiny_id
        , i_perso_priority          in com_api_type_pkg.t_dict_value
        , i_pin_request             in com_api_type_pkg.t_dict_value
        , i_embossing_request       in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request      in com_api_type_pkg.t_dict_value
        , o_warning_msg             out com_api_type_pkg.t_text
        , i_lang                    in com_api_type_pkg.t_dict_value  default null
        , i_card_count              in com_api_type_pkg.t_tiny_id     default null
        , i_session_id              in com_api_type_pkg.t_long_id     default null
        , i_start_date              in date                           default null
        , i_end_date                in date                           default null
        , i_flow_id                 in com_api_type_pkg.t_tiny_id     default null
    );

/*
 * Remove all cards from batch
 */
    procedure unmark_batch_card (
        i_batch_id                  in com_api_type_pkg.t_short_id
    );

    procedure get_batch_cards (
        o_ref_cursor           out sys_refcursor
        , i_batch_id           in com_api_type_pkg.t_short_id
    );

end;
/
