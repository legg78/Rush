CREATE OR REPLACE package aut_api_queue_pkg is
/************************************************************
* Store-And-Forward mechanism works with queues of authorizations for sending into external networks<br />
* Created by Mashonkin V.(mashonkin@bpcbt.com)  at 29.01.2014  <br />
* Last changed by $Author: mashonkin $  <br />
* $LastChangedDate:: 2014-01-29 19:32:51 +0400#$ <br />
* Revision: $LastChangedRevision: 10879 $ <br />
* Module: AUT_API_QUEUE_PKG <br />
* @headcom
************************************************************/

    C_MAX_SEND_COUNT            CONSTANT com_api_type_pkg.t_short_id   := 5;
    C_NEED_SENDING              CONSTANT com_api_type_pkg.t_dict_value := 'SNDS0001'; -- Needs to be sended
    C_SENDED_SUCCESS            CONSTANT com_api_type_pkg.t_dict_value := 'SNDS0002'; -- Sended successfully
    C_SENDING_FAILED            CONSTANT com_api_type_pkg.t_dict_value := 'SNDS0003'; -- Sending failed
    C_SENDED_AWAITS_CONFIRM     CONSTANT com_api_type_pkg.t_dict_value := 'SNDS0004'; -- Sended, awaits confirmation
    
    -- put new transaction into queue
    procedure put_aut_queue (
        i_auth_id                   in com_api_type_pkg.t_long_id
        , i_host_id                 in com_api_type_pkg.t_tiny_id
        , i_channel_id              in com_api_type_pkg.t_short_id default null
        , i_is_advice_needed        in com_api_type_pkg.t_boolean  default com_api_type_pkg.false
        , i_is_reversal_needed      in com_api_type_pkg.t_boolean  default com_api_type_pkg.false
        , i_max_send_count          in com_api_type_pkg.t_short_id default aut_api_queue_pkg.C_MAX_SEND_COUNT
        , i_description             in com_api_type_pkg.t_text     default null
    );
    
    -- changes transaction parameters in queue
    procedure change_aut_queue (
        i_auth_id                   in com_api_type_pkg.t_long_id
        , i_host_id                 in com_api_type_pkg.t_tiny_id
        , i_channel_id              in com_api_type_pkg.t_short_id   default null
        , i_is_advice_needed        in com_api_type_pkg.t_boolean    default null
        , i_is_reversal_needed      in com_api_type_pkg.t_boolean    default null
        , i_send_count              in com_api_type_pkg.t_short_id   default null
        , i_send_status             in com_api_type_pkg.t_dict_value default null
        , i_description             in com_api_type_pkg.t_text       default null
    );
    
    -- read transaction parameters from queue
    procedure get_aut_queue (
        i_auth_id                   in com_api_type_pkg.t_long_id
        , i_host_id                 in com_api_type_pkg.t_tiny_id
        , i_channel_id              in com_api_type_pkg.t_short_id   default null
        , o_is_advice_needed        out com_api_type_pkg.t_boolean
        , o_is_reversal_needed      out com_api_type_pkg.t_boolean
        , o_send_count              out com_api_type_pkg.t_short_id
        , o_max_send_count          out com_api_type_pkg.t_short_id
        , o_send_status             out com_api_type_pkg.t_dict_value
    );

    -- read count of transaction by send status
    function get_aut_queue_cnt (
        i_send_status   in com_api_type_pkg.t_dict_value
        , i_host_id     in com_api_type_pkg.t_tiny_id
        , i_channel_id  in com_api_type_pkg.t_short_id
    ) return com_api_type_pkg.t_long_id;

end aut_api_queue_pkg;
/