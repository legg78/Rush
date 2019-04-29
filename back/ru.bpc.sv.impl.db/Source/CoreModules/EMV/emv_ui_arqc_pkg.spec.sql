create or replace package emv_ui_arqc_pkg is
/************************************************************
 * User interface for Authorization request cryptogram <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.06.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_ui_arqc_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add authorization request cryptogram
 */
    procedure add_arqc (
        o_id                        out com_api_type_pkg.t_long_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_object_id               in com_api_type_pkg.t_long_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_tag                     in com_api_type_pkg.t_tag
        , i_tag_order               in com_api_type_pkg.t_tiny_id
    );

/*
 * Modify authorization request cryptogram
 */
    procedure modify_arqc (
        i_id                        in com_api_type_pkg.t_long_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_object_id               in com_api_type_pkg.t_long_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_tag                     in com_api_type_pkg.t_tag
        , i_tag_order               in com_api_type_pkg.t_tiny_id
    );

/*
 * Remove authorization request cryptogram
 */
    procedure remove_arqc (
        i_id                        in com_api_type_pkg.t_long_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );
    
end;
/
