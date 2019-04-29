create or replace package cmn_ui_device_pkg as

/**************************************************
*
* Last changed by $Author$
* $LastChangedDate::                           $
* $LastChangedRevision$
*
***************************************************/

    procedure add_device(
        o_device_id            out  com_api_type_pkg.t_short_id
      , i_comm_plugin       in      com_api_type_pkg.t_dict_value
      , i_standard_id       in      com_api_type_pkg.t_tiny_id
      , i_inst_id           in      com_api_type_pkg.t_inst_id
      , i_caption           in      com_api_type_pkg.t_short_desc
      , i_description       in      com_api_type_pkg.t_full_desc        default null
      , i_lang              in      com_api_type_pkg.t_dict_value       default null
    );

    procedure modify_device(
        i_device_id         in      com_api_type_pkg.t_short_id
      , i_comm_plugin       in      com_api_type_pkg.t_dict_value
      , i_standard_id       in      com_api_type_pkg.t_tiny_id
      , io_seqnum           in out  com_api_type_pkg.t_seqnum
      , i_caption           in      com_api_type_pkg.t_short_desc
      , i_description       in      com_api_type_pkg.t_full_desc        default null
      , i_lang              in      com_api_type_pkg.t_dict_value       default null
    );

    procedure remove_device(
        i_device_id         in      com_api_type_pkg.t_short_id
      , i_seqnum            in      com_api_type_pkg.t_seqnum
    );

    procedure set_is_enabled (
        i_device_id           in     com_api_type_pkg.t_short_id
      , i_is_enabled          in     com_api_type_pkg.t_boolean
      , io_seqnum             in out com_api_type_pkg.t_seqnum
    );

end;
/