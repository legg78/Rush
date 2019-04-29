create or replace package prs_prc_perso_pkg is
/************************************************************
 * API for personalization process <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 22.10.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2010-05-20 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_prc_perso_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Personalization process with batch
 * @param  i_batch_id            - Batch identifier
 * @param  i_embossing_request   - Requesting action about plastic embossing
 * @param  i_pin_mailer_request  - Requesting action about PIN mailer printing
 * @param  i_lang                - Language pin mailer
 * @param  i_charset             - Convert data in file to character set 
 */    
    procedure generate_with_batch (
        i_batch_id              in com_api_type_pkg.t_short_id
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_lang                in com_api_type_pkg.t_dict_value := null
        , i_charset             in com_api_type_pkg.t_oracle_name := null
    );

/*
 * Personalization process without batch
 * @param  i_embossing_request   - Requesting action about plastic embossing
 * @param  i_pin_mailer_request  - Requesting action about PIN mailer printing
 * @param  i_inst_id             - Institution identifier
 * @param  i_agent_id            - Agent identifier
 * @param  i_product_id          - Product identifier
 * @param  i_card_type_id        - Card type identifier
 * @param  i_perso_priority      - Personalization priority
 * @param  i_sort_id             - Personalization sorting
 * @param  i_hsm_device_id       - HSM device identifier
 * @param  i_lang                - Language pin mailer
 * @param  i_charset             - Convert data in file to character set
 */    
    procedure generate_without_batch (
        i_embossing_request     in com_api_type_pkg.t_dict_value := null
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value := null
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_agent_id            in com_api_type_pkg.t_agent_id := null
        , i_product_id          in com_api_type_pkg.t_short_id := null
        , i_card_type_id        in com_api_type_pkg.t_tiny_id := null
        , i_perso_priority      in com_api_type_pkg.t_dict_value := null
        , i_sort_id             in com_api_type_pkg.t_tiny_id
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id := null
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_charset             in com_api_type_pkg.t_oracle_name := null
    );

end; 
/
