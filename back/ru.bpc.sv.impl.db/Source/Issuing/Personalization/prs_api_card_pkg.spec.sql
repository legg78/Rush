create or replace package prs_api_card_pkg is
/************************************************************
 * API for cards <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 22.10.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_card_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Enum cards for personalization
 * @param  o_perso_cur          - Cursor
 * @param  i_batch_id           - Batch identifier 
 * @param  i_embossing_request  - Requesting action about plastic embossing
 * @param  i_pin_mailer_request - Requesting action about PIN mailer printing
 * @param  i_lang                - Language pin mailer
 * @param  i_order_clause       - Order clause
 */
    procedure enum_card_for_perso (
        o_perso_cur             out sys_refcursor
        , i_batch_id            in com_api_type_pkg.t_short_id
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_lang                in com_api_type_pkg.t_dict_value := null
        , i_order_clause        in com_api_type_pkg.t_text
        , i_ignore_slave_count  in com_api_type_pkg.t_boolean    := com_api_type_pkg.FALSE
    );

/*
 * Enum child cards for personalization
 * @param  o_perso_cur          - Cursor
 * @param  i_batch_id           - Batch identifier 
 * @param  i_embossing_request  - Requesting action about plastic embossing
 * @param  i_pin_mailer_request - Requesting action about PIN mailer printing
 * @param  i_lang                - Language pin mailer
 * @param  i_card_instance_id   - Parent icc card instance identifier
 */
    procedure enum_child_card_for_perso (
        o_perso_cur             out sys_refcursor
        , i_batch_id            in com_api_type_pkg.t_short_id
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_lang                in com_api_type_pkg.t_dict_value := null
        , i_card_instance_id    in com_api_type_pkg.t_medium_id
    );

/*
 * Estimate cards for personalization
 * @param  i_batch_id           - Batch identifier
 * @param  i_embossing_request  - Requesting action about plastic embossing
 * @param  i_pin_mailer_request - Requesting action about PIN mailer printing
 * @param  i_lang               - Language pin mailer
 */
    function estimate_card_for_perso (
        i_batch_id              in com_api_type_pkg.t_short_id
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_ignore_slave_count  in com_api_type_pkg.t_boolean    := com_api_type_pkg.FALSE
    ) return com_api_type_pkg.t_long_id;

/*
 * Get sorting condition
 * @param  i_sort_id  - Sort identifier
 * @return - field1 asc, field2 desc
 */
    function enum_sort_condition (
        i_sort_id               in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_text;

/*
 * Bulk mark ok personalization cards
 * @param  i_rowid               - Card instance rowid
 * @param  i_embossing_request   - Requesting action about plastic embossing
 * @param  i_pin_mailer_request  - Requesting action about PIN mailer printing
 * @param  i_id                  - Card instance identifier
 * @param  i_pvv                 - Pin offeset or PVV
 * @param  i_pin_offset          - Pin offeset
 * @param  i_pvk_index           - PVK Index used for PVV generation
 * @param  i_pin_block           - Pin block
 * @param  i_pin_block_format    - Format of PIN block generated
 */
    procedure mark_ok_perso (
        i_rowid                 in com_api_type_pkg.t_rowid_tab
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_id                  in com_api_type_pkg.t_number_tab
        , i_pvv                 in com_api_type_pkg.t_number_tab
        , i_pin_offset          in com_api_type_pkg.t_cmid_tab
        , i_pvk_index           in com_api_type_pkg.t_number_tab
        , i_pin_block           in com_api_type_pkg.t_varchar2_tab
        , i_pin_block_format    in com_api_type_pkg.t_dict_tab
        , i_iss_date            in com_api_type_pkg.t_date_tab
        , i_state               in com_api_type_pkg.t_dict_tab
    );

/*
 * Mark ok personalization card
 * @param  i_id                - Card instance identifier
 * @param  i_pvv               - Pin offeset or PVV
 * @param  i_pin_offset        - Pin offeset
 * @param  i_pvk_index         - PVK Index used for PVV generation
 * @param  i_pin_block         - Pin block
 * @param  i_pin_block_format  - Format of PIN block generated
 */
    procedure mark_ok_perso (
        i_id                    in com_api_type_pkg.t_medium_id
        , i_pvv                 in com_api_type_pkg.t_tiny_id
        , i_pin_offset          in com_api_type_pkg.t_cmid
        , i_pvk_index           in com_api_type_pkg.t_tiny_id
        , i_pin_block           in com_api_type_pkg.t_name
        , i_pin_block_format    in com_api_type_pkg.t_dict_value
    );

/*
 * Enum cards for personalization
 * @param  o_perso_cur          - Cursor
 * @param  i_batch_id           - Batch identifier 
 * @param  i_embossing_request  - Requesting action about plastic embossing
 * @param  i_pin_mailer_request - Requesting action about PIN mailer printing
 * @param  i_lang                - Language pin mailer
 * @param  i_order_clause       - Order clause
 */
    procedure get_batch_cards (
        o_perso_cur                out sys_refcursor
      , i_batch_id              in     com_api_type_pkg.t_short_id
      , i_pin_mailer_request    in     com_api_type_pkg.t_dict_value
      , i_lang                  in     com_api_type_pkg.t_dict_value
    );
    
end; 
/
