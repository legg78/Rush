create or replace package prs_api_print_pkg is
/************************************************************
 * API for print PIN Mailer <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.09.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_print_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Format print data
 * @param  i_params  - Parameters
 */
    function format_print_data (
        i_params                in rul_api_type_pkg.t_param_tab
        , i_pin_length          in com_api_type_pkg.t_tiny_id := prs_api_const_pkg.PIN_LENGTH
    ) return prs_api_type_pkg.t_print_data_tab;

/*
 * Format print text
 * @param  i_print_data  - Print data
 */
    function format_print_text (
        i_print_data            in prs_api_type_pkg.t_print_data_tab
    ) return com_api_type_pkg.t_text;

/*
 * Generation print format
 * @param  i_print_data  - Print data
 */
    function generate_print_format (
        i_print_data            in prs_api_type_pkg.t_print_data_tab
    ) return com_api_type_pkg.t_text;

/*
 * Print PIN Mailer
 * @param  i_print_data     - Print data
 * @param  i_card_number    - Card number
 * @param  i_pin_block      - PIN block
 * @param  i_hsm_device_id  - HSM device identifier
 */
    procedure print_pin_mailer (
        i_print_data            in prs_api_type_pkg.t_print_data_tab
        , i_card_number         in com_api_type_pkg.t_card_number
        , i_pin_block           in com_api_type_pkg.t_pin_block
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
    );
    
end;
/
