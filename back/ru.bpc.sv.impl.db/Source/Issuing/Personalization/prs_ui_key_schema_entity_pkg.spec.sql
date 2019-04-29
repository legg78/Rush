create or replace package prs_ui_key_schema_entity_pkg is
/************************************************************
 * User interface for personalization detalization of key schema <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.08.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_key_schema_entity_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Register key schema entity
 */
    procedure add (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_key_schema_id           in com_api_type_pkg.t_tiny_id
        , i_key_type                in com_api_type_pkg.t_dict_value
        , i_entity_type             in com_api_type_pkg.t_dict_value
    );

/*
 * Modify key schema entity
 */
    procedure modify (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_key_schema_id           in com_api_type_pkg.t_tiny_id
        , i_key_type                in com_api_type_pkg.t_dict_value
        , i_entity_type             in com_api_type_pkg.t_dict_value
    );

/*
 * Remove key schema entity
 */
    procedure remove (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

end; 
/
