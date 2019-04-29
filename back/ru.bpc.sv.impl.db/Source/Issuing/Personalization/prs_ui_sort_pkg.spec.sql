create or replace package prs_ui_sort_pkg is
/************************************************************
 * User interface for personalization sort <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 28.09.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_sort_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add sort
 * @param o_id                Sort identifier
 * @param o_seqnum            Sequential number
 * @param i_inst_id           Owner institution identifier
 * @param i_condition         Order condition
 * @param i_lang              Language
 * @param i_label             Label sort
 * @param i_description       Description sort
 */
    procedure add_sort (
        o_id                           out com_api_type_pkg.t_tiny_id
        , o_seqnum                     out com_api_type_pkg.t_seqnum
        , i_inst_id                 in     com_api_type_pkg.t_inst_id
        , i_condition               in     com_api_type_pkg.t_full_desc
        , i_lang                    in     com_api_type_pkg.t_dict_value
        , i_label                   in     com_api_type_pkg.t_name
        , i_description             in     com_api_type_pkg.t_full_desc
    );

/*
 * Modify sort
 * @param i_id                Sort identifier
 * @param io_seqnum           Sequential number
 * @param i_condition         Order condition
 * @param i_lang              Language
 * @param i_label             Label sort
 * @param i_description       Description sort
 */
    procedure modify_sort (
        i_id                        in     com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_condition               in     com_api_type_pkg.t_full_desc
        , i_lang                    in     com_api_type_pkg.t_dict_value
        , i_label                   in     com_api_type_pkg.t_name
        , i_description             in     com_api_type_pkg.t_full_desc
    );

/*
 * Remove sort
 * @param i_id                Sort identifier
 * @param i_seqnum            Sequential number
 */
    procedure remove_sort (
        i_id                        in     com_api_type_pkg.t_tiny_id
        , i_seqnum                  in     com_api_type_pkg.t_seqnum
    );

end;
/
