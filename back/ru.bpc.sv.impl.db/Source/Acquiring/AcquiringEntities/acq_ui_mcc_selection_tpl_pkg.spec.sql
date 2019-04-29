create or replace package acq_ui_mcc_selection_tpl_pkg is
/************************************************************
 * User interface for MCC selection template <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 29.01.2013 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: acq_ui_mcc_selection_tpl_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add MCC selection template
 */
    procedure add_selection_tpl (
        o_id                        out com_api_type_pkg.t_medium_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    );

/*
 * Modify MCC selection template
 */
    procedure modify_selection_tpl(
        i_id                        in com_api_type_pkg.t_medium_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    );

/*
 * Remove MCC selection template
 */
    procedure remove_selection_tpl (
        i_id                        in com_api_type_pkg.t_medium_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

end;
/
