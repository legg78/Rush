create or replace package emv_ui_variable_pkg is
/************************************************************
 * User interface for EMV data variables <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 20.09.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_ui_variable_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add variable
 * @param  o_id                  - Variable identifier
 * @param  o_seqnum              - Variable sequence number
 * @param  i_application_id      - Application indentifier
 * @param  i_variable_type       - Variable type (EVTP dictionary)
 * @param  i_profile             - Profile of EMV application (EPFL dictionary)
 * @param  i_lang                - Variable language
 * @param  i_name                - Variable name
 */
    procedure add_variable (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_application_id          in com_api_type_pkg.t_short_id
        , i_variable_type           in com_api_type_pkg.t_dict_value
        , i_profile                 in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
    );

/*
 * Modify variable
 * @param  o_id                  - Variable identifier
 * @param  io_seqnum             - Variable sequence number
 * @param  i_application_id      - Application indentifier
 * @param  i_variable_type       - Variable type (EVTP dictionary)
 * @param  i_profile             - Profile of EMV application (EPFL dictionary)
 * @param  i_lang                - Variable language
 * @param  i_name                - Variable name 
 */
    procedure modify_variable (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_application_id          in com_api_type_pkg.t_short_id
        , i_variable_type           in com_api_type_pkg.t_dict_value
        , i_profile                 in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
    );

/*
 * Remove variable
 * @param  o_id                  - Variable identifier
 * @param  i_seqnum              - Variable sequence number
 */
    procedure remove_variable (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

end;
/
