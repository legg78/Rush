create or replace package prs_ui_batch_pkg is
/************************************************************
 * User interface for perso batches <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.08.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_batch_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add batch
 * @param o_id                Batch identifier
 * @param o_seqnum            Sequential number
 * @param i_inst_id           institution identifier
 * @param i_agent_id          Agent identifier
 * @param i_product_id        Issuing product identifier
 * @param i_card_type_id      Card type identifier
 * @param i_blank_type_id     Blank type identifier
 * @param i_card_count        Card count for embossing
 * @param i_hsm_device_id     HSM device identifier
 * @param i_status            Batch status
 * @param i_sort_id           Sort identifier
 * @param i_perso_priority    Priority
 * @param i_lang              Language
 * @param i_description       Description of batch
 * @param i_reissue_reason    Reissue reason
 * @param i_force             Force run (default false)
 */
    procedure add_batch (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_agent_id                in com_api_type_pkg.t_agent_id
        , i_product_id              in com_api_type_pkg.t_short_id
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , i_blank_type_id           in com_api_type_pkg.t_tiny_id
        , i_card_count              in com_api_type_pkg.t_short_id
        , i_hsm_device_id           in com_api_type_pkg.t_tiny_id
        , i_status                  in com_api_type_pkg.t_dict_value
        , i_sort_id                 in com_api_type_pkg.t_tiny_id := null
        , i_perso_priority          in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_batch_name              in com_api_type_pkg.t_name
        , i_reissue_reason          in com_api_type_pkg.t_dict_value := null
        , i_force                   in com_api_type_pkg.t_boolean    := com_api_const_pkg.FALSE
    );

/*
 * Modify batch
 * @param o_id                Batch identifier
 * @param o_seqnum            Sequential number
 * @param i_product_id        Issuing product identifier
 * @param i_card_type_id      Card type identifier
 * @param i_blank_type_id     Blank type identifier
 * @param i_card_count        Card count for embossing
 * @param i_hsm_device_id     HSM device identifier
 * @param i_sort_id           Sort identifier
 * @param i_perso_priority    Priority
 * @param i_lang              Language
 * @param i_description       Description of batch
 * @param i_status            Batch status
 * @param i_reissue_reason    Reissue reason
 */
    procedure modify_batch (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_product_id              in com_api_type_pkg.t_short_id
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , i_blank_type_id           in com_api_type_pkg.t_tiny_id
        , i_card_count              in com_api_type_pkg.t_short_id
        , i_hsm_device_id           in com_api_type_pkg.t_tiny_id
        , i_sort_id                 in com_api_type_pkg.t_tiny_id := null
        , i_perso_priority          in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_batch_name              in com_api_type_pkg.t_name
        , i_status                  in com_api_type_pkg.t_dict_value := null
        , i_reissue_reason          in com_api_type_pkg.t_dict_value := null
    );

/*
 * Add batch
 * @param o_id                Batch identifier
 * @param o_seqnum            Sequential number
 */
    procedure remove_batch (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );
    
/*
 * Clone batch with all card instance
 * @param o_id                New batch identifier
 * @param o_seqnum            New batch sequential number
 * @param i_batch_id          Cloned batch identifier
 * @param i_batch_name        New batch name
 * @param i_pin_request       Pin request
 * @param i_pin_mailer_request Pin mailer request
 * @param i_embossing_request Embossing request  
 */    
    procedure clone_batch (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_batch_id                in com_api_type_pkg.t_short_id
        , i_batch_name              in com_api_type_pkg.t_name        
        , i_pin_request             in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request      in com_api_type_pkg.t_dict_value
        , i_embossing_request       in com_api_type_pkg.t_dict_value
    );   
/*
 * Clone batch with selected card instance
 * @param o_id                New batch identifier
 * @param o_seqnum            New batch sequential number
 * @param i_batch_id          Cloned batch identifier
 * @param i_batch_name        New batch name
 * @param i_instance_list     Selected card instance identifier
 * @param i_pin_request       Pin request
 * @param i_pin_mailer_request Pin mailer request
 * @param i_embossing_request Embossing request  
 */ 
    procedure clone_batch (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_batch_id                in com_api_type_pkg.t_short_id
        , i_batch_name              in com_api_type_pkg.t_name        
        , i_instance_list           in num_tab_tpt 
        , i_pin_request             in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request      in com_api_type_pkg.t_dict_value
        , i_embossing_request       in com_api_type_pkg.t_dict_value
    );

/*
 * Clone batch by range card instance
 * @param o_id                New batch identifier
 * @param o_seqnum            New batch sequential number
 * @param i_batch_id          Cloned batch identifier
 * @param i_batch_name        New batch name
 * @param i_first_row         First row
 * @param i_last_row          Last row
 * @param i_pin_request       Pin request
 * @param i_pin_mailer_request Pin mailer request
 * @param i_embossing_request Embossing request  
 */ 
    procedure clone_batch (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_batch_id                in com_api_type_pkg.t_short_id
        , i_batch_name              in com_api_type_pkg.t_name        
        , i_first_row               in com_api_type_pkg.t_tiny_id
        , i_last_row                in com_api_type_pkg.t_tiny_id default null
        , i_pin_request             in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request      in com_api_type_pkg.t_dict_value
        , i_embossing_request       in com_api_type_pkg.t_dict_value
    );
    
end; 
/
