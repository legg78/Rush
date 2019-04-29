create or replace package hsm_ui_device_pkg is

/***********************************************************
*
* API for HSM device creation and management
*
* Created by Rashin G.(rashin@bpcbt.com)  at 18.02.2010
* Last changed by $Author$
* $LastChangedDate::                           $
* Revision: $LastChangedRevision$
* Module: hsm_ui_device_pkg
* @headcom
*
***********************************************************/

--
-- Add HSM device
-- @param  o_id             HSM device identifier
-- @param  o_seqnum         HSM object version number
-- @param  i_is_enabled     Flag shows if HSM is active and ready for work
-- @param  i_comm_protocol  HSM communication type
-- @param  i_plugin         HSM interchange plugin
-- @param  i_manufacturer   HSM manufacturer
-- @param  i_serial_number  Serial number of HSM device
-- @param  i_lang           Description language
-- @param  i_description    HSM user-defined description
-- @param  i_lmk_id         HSM LMK identifier
-- @param  i_model_number   HSM device model number
    procedure add_hsm_device (
         o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_is_enabled              in com_api_type_pkg.t_boolean
        , i_comm_protocol           in com_api_type_pkg.t_dict_value
        , i_plugin                  in com_api_type_pkg.t_dict_value
        , i_manufacturer            in com_api_type_pkg.t_dict_value
        , i_serial_number           in com_api_type_pkg.t_name
        , i_lang                    in com_api_type_pkg.t_dict_value default null
        , i_description             in com_api_type_pkg.t_full_desc default null
        , i_lmk_id                  in com_api_type_pkg.t_tiny_id
        , i_model_number            in com_api_type_pkg.t_dict_value
    );

--
-- Modify HSM device
-- @param  i_id             HSM device identifier
-- @param  io_seqnum        HSM object version number
-- @param  i_is_enabled     Flag shows if HSM is active and ready for work
-- @param  i_comm_protocol  HSM communication type
-- @param  i_plugin         HSM interchange plugin
-- @param  i_manufacturer   HSM manufacturer
-- @param  i_serial_number  Serial number of HSM device
-- @param  i_lang           Description language
-- @param  i_description    HSM user-defined description
-- @param  i_lmk_id         HSM LMK identifier
-- @param  i_model_number   HSM device model number
    procedure modify_hsm_device (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_is_enabled              in com_api_type_pkg.t_boolean
        , i_comm_protocol           in com_api_type_pkg.t_dict_value
        , i_plugin                  in com_api_type_pkg.t_dict_value
        , i_manufacturer            in com_api_type_pkg.t_dict_value
        , i_serial_number           in com_api_type_pkg.t_name
        , i_lang                    in com_api_type_pkg.t_dict_value default null
        , i_description             in com_api_type_pkg.t_full_desc default null
        , i_lmk_id                  in com_api_type_pkg.t_tiny_id
        , i_model_number            in com_api_type_pkg.t_dict_value
    );
--
-- Remove HSM device
-- @param  i_id             HSM device identifier
-- @param  i_seqnum         HSM object version number
    procedure remove_hsm_device (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

--
-- Add connection parameters for TCP/IP HSM
-- @param  i_hsm_device_id   HSM device identifier
-- @param  i_address         TCP/IP address
-- @param  i_port            TCP/IP port
    procedure add_hsm_tcp_ip (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , i_address                 in com_api_type_pkg.t_name
        , i_port                    in com_api_type_pkg.t_name
        , i_max_connection          in com_api_type_pkg.t_tiny_id
    );

--
-- Modify connection parameters for TCP/IP HSM
-- @param  i_hsm_device_id   HSM device identifier
-- @param  i_address         TCP/IP address
-- @param  i_port            TCP/IP port
    procedure modify_hsm_tcp_ip (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , i_address                 in com_api_type_pkg.t_name
        , i_port                    in com_api_type_pkg.t_name
        , i_max_connection          in com_api_type_pkg.t_tiny_id
    );

--
-- Remove connection parameters for TCP/IP HSM
-- @param  i_hsm_device_id   HSM device identifier
    procedure remove_hsm_tcp_ip (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
    );

-- To verify the LMK check value
-- @param i_hsm_device_id   HSM device identifier
-- @param o_responce_msg    Responce message verify the LMK check value
    procedure check_lmk (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , o_responce_msg            out com_api_type_pkg.t_text
    );

end;
/
