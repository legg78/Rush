create or replace package acm_ui_widget_param_pkg is
/************************************************************
 * User interface for widget parameters type <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 10.05.2012 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: acm_ui_widget_param_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add widget parameter
 */
    procedure add_widget_param (
        o_id                    out com_api_type_pkg.t_short_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_param_name          in com_api_type_pkg.t_name
        , i_label               in com_api_type_pkg.t_name
        , i_data_type           in com_api_type_pkg.t_dict_value
        , i_lov_id              in com_api_type_pkg.t_tiny_id
        , i_widget_id           in com_api_type_pkg.t_tiny_id
        , i_lang                in com_api_type_pkg.t_dict_value
    );

/*
 * Modify widget parameter
 */
    procedure modify_widget_param (
        i_id                    in com_api_type_pkg.t_short_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_param_name          in com_api_type_pkg.t_name
        , i_label               in com_api_type_pkg.t_name
        , i_data_type           in com_api_type_pkg.t_dict_value
        , i_lov_id              in com_api_type_pkg.t_tiny_id
        , i_widget_id           in com_api_type_pkg.t_tiny_id
        , i_lang                in com_api_type_pkg.t_dict_value
    );

/*
 * Remove widget parameter
 */
    procedure remove_widget_param (
        i_id                    in com_api_type_pkg.t_short_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );

/*
 * Set widget parameter char value
 */    
    procedure set_widget_param_value_char (
        io_id                   in out com_api_type_pkg.t_short_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_widget_param_id     in com_api_type_pkg.t_short_id
        , i_dashboard_widget_id in com_api_type_pkg.t_short_id
        , i_param_value         in com_api_type_pkg.t_name
    );

/*
 * Set widget parameter number value
 */
    procedure set_widget_param_value_num (
        io_id                   in out com_api_type_pkg.t_short_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_widget_param_id     in com_api_type_pkg.t_short_id
        , i_dashboard_widget_id in com_api_type_pkg.t_short_id
        , i_param_value         in number
    );

/*
 * Set widget parameter date value
 */
    procedure set_widget_param_value_date (
        io_id                   in out com_api_type_pkg.t_short_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_widget_param_id     in com_api_type_pkg.t_short_id
        , i_dashboard_widget_id in com_api_type_pkg.t_short_id
        , i_param_value         in date
    );

/*
 * Remove widget parameter value
 */
    procedure remove_widget_param_value (
        i_id                    in com_api_type_pkg.t_short_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );
    
end;
/
