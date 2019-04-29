create or replace package prs_ui_key_schema_pkg is
/************************************************************
 * User interface for personalization schema of keys <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.08.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_key_schema_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Register key schema
 * @param  o_id           - Scema identifier
 * @param  o_seqnum       - Sequential number of record version
 * @param  i_inst_id      - Owner institution identifier
 * @param  i_lang         - Language
 * @param  i_name         - Scema name
 * @param  i_description  - Scema description
 */
    procedure add (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    );

/*
 * Modify key schema
 * @param  o_id           - Scema identifier
 * @param  io_seqnum      - Sequential number of record version
 * @param  i_lang         - Language
 * @param  i_name         - Scema name
 * @param  i_description  - Scema description 
 */
    procedure modify (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    );

/*
 * Remove key schema
 * @param  i_id           - Scema identifier
 * @param  i_seqnum       - Sequential number of record version
 */
    procedure remove (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

end; 
/
