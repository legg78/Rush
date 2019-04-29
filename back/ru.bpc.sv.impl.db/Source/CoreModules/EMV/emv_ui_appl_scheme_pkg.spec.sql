create or replace package emv_ui_appl_scheme_pkg is
/************************************************************
 * User interface for scheme of EMV card applications <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 04.10.2011 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: emv_ui_appl_scheme_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add EMV application scheme
 */
    procedure add_appl_scheme (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_type                    in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    );

/*
 * Modify EMV application scheme
 */
    procedure modify_appl_scheme (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_type                    in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    );

/*
 * Remove EMV application scheme
 */
    procedure remove_appl_scheme (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

end;
/
