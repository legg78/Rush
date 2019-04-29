create or replace package prs_ui_template_pkg is
/************************************************************
 * User interface for personalization templates <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.08.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_template_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add template
 * @param o_id                Template identifier
 * @param o_seqnum            Sequential number
 * @param i_method_id         Personalization method identifier
 * @param i_entity_type       Entity type which format relates to
 * @param i_format_id         Format identifier
 * @param i_mod_id            Modifier identifier
 */
    procedure add (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_method_id               in com_api_type_pkg.t_tiny_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_format_id               in com_api_type_pkg.t_tiny_id
        , i_mod_id                  in com_api_type_pkg.t_tiny_id := null
    );
/*
 * Modify template
 * @param i_id                Template identifier
 * @param io_seqnum           Sequential number
 * @param i_method_id         Personalization method identifier
 * @param i_entity_type       Entity type which format relates to
 * @param i_format_id         Format identifier
 * @param i_mod_id            Modifier identifier
 */
    procedure modify (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_method_id               in com_api_type_pkg.t_tiny_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_format_id               in com_api_type_pkg.t_tiny_id
        , i_mod_id                  in com_api_type_pkg.t_tiny_id := null
    );
/*
 * Remove template
 * @param i_id                Template identifier
 * @param i_seqnum            Sequential number
 */
    procedure remove (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

end; 
/
