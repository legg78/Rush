create or replace package com_ui_appearance_pkg is
/************************************************************
 * User interface for Appearance object <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 22.30.2013 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2012-12-20 16:16:11 +0400#$ <br />
 * Revision: $LastChangedRevision: 26384 $ <br />
 * Module: com_ui_appearance_pkg <br />
 * @headcom
 ************************************************************/
 
    procedure add_appearance (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_object_id               in com_api_type_pkg.t_long_id
        , i_css_class               in com_api_type_pkg.t_name
        , i_object_reference        in com_api_type_pkg.t_name
    );

    procedure modify_appearance (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_object_id               in com_api_type_pkg.t_long_id
        , i_css_class               in com_api_type_pkg.t_name
        , i_object_reference        in com_api_type_pkg.t_name
    );

    procedure remove_appearance (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

end;
/
