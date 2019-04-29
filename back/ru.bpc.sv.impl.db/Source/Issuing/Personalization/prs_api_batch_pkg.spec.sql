CREATE OR REPLACE package prs_api_batch_pkg is
/************************************************************
 * API for batch batch <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 10.12.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_batch_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Get batch record
 * @param  i_id  - Batch identifier
 */
    function get_batch (
        i_id                    in com_api_type_pkg.t_short_id
    ) return prs_api_type_pkg.t_batch_rec;

/*
 * Mark ok batch card
 * @param  i_id      - Batch identifier
 * @param  i_status  - Batch status
 */
    procedure mark_ok_batch (
        i_id                    in com_api_type_pkg.t_short_id
        , i_status              in com_api_type_pkg.t_dict_value
    );

/*
 * Bulk mark ok batchs card
 * @param  i_id                  - Batch cards identifier
 * @param  i_pin_generated       - PIN generated
 * @param  i_pin_mailer_printed  - PIN mailer printed
 * @param  i_embossing_done      - Plastic embossing
 */
    procedure mark_ok_batch_card (
        i_id                    in com_api_type_pkg.t_number_tab
        , i_pin_generated       in com_api_type_pkg.t_number_tab
        , i_pin_mailer_printed  in com_api_type_pkg.t_number_tab
        , i_embossing_done      in com_api_type_pkg.t_number_tab
    );

/*
 * Bulk mark error batchs card
 * @param  i_id  - Batch cards identifier
 */
    procedure mark_error_batch_card (
        i_id                    in com_api_type_pkg.t_number_tab
    );

/*
 * Mark status of batch and its card instances
 * @param  i_batch_id - Batch identifier
 * @param  i_status  - Batch status
 */
    procedure set_batch_status_delivered (
        i_batch_id              in com_api_type_pkg.t_short_id
        , i_agent_id            in com_api_type_pkg.t_agent_id      default null
    );
    
    procedure set_batch_instance_state (
        i_batch_id              in com_api_type_pkg.t_short_id
        , i_agent_id            in com_api_type_pkg.t_agent_id      default null
        , i_state               in com_api_type_pkg.t_dict_value    default null
        , i_event_type          in com_api_type_pkg.t_dict_value    default null    
    );
    
    procedure change_card_instances_status (
        i_batch_id              in com_api_type_pkg.t_short_id
        , i_agent_id            in com_api_type_pkg.t_agent_id      default null
        , i_event_type          in com_api_type_pkg.t_dict_value    default null
    );

end;
/
