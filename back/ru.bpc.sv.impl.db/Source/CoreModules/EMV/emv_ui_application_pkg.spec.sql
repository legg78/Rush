create or replace package emv_ui_application_pkg is
/************************************************************
 * User interface for EMV card application <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 02.09.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_ui_application_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add EMV card application
 * @param  o_id                  - Application identifier
 * @param  o_seqnum              - Application sequence number
 * @param  i_aid                 - Application Identifier
 * @param  i_id_owner            - Identifier of the Application Specification Owner
 * @param  i_pix                 - Primary Application Identifier Extension
 * @param  i_appl_scheme_id      - EMV application scheme identifier
 * @param  i_lang                - Application language
 * @param  i_name                - Application name
 * @param  i_mod_id              - Modifier identifier
 */
    procedure add_application (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_aid                     in com_api_type_pkg.t_name
        , i_id_owner                in sec_api_type_pkg.t_subject_id
        , i_pix                     in com_api_type_pkg.t_name := null
        , i_appl_scheme_id          in com_api_type_pkg.t_tiny_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_mod_id                  in com_api_type_pkg.t_tiny_id := null
    );

/*
 * Modify EMV card application
 * @param  o_id                  - Application identifier
 * @param  io_seqnum             - Application sequence number
 * @param  i_aid                 - Application Identifier
 * @param  i_id_owner            - Identifier of the Application Specification Owner
 * @param  i_pix                 - Primary Application Identifier Extension
 * @param  i_appl_scheme_id      - EMV application scheme identifier
 * @param  i_lang                - Application language
 * @param  i_name                - Application name 
 * @param  i_mod_id              - Modifier identifier
 */
    procedure modify_application (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_aid                     in com_api_type_pkg.t_name
        , i_id_owner                in sec_api_type_pkg.t_subject_id
        , i_pix                     in com_api_type_pkg.t_name := null
        , i_appl_scheme_id          in com_api_type_pkg.t_tiny_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_mod_id                  in com_api_type_pkg.t_tiny_id := null
    );

/*
 * Remove EMV card application
 * @param  i_id                  - Application identifier
 * @param  i_seqnum              - Application sequence number
 */
    procedure remove_application (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

end;
/
