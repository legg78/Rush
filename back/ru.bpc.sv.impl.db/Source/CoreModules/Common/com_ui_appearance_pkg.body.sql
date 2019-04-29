create or replace package body com_ui_appearance_pkg is
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
    ) is
    begin
        o_id := com_appearance_seq.nextval;
        o_seqnum := 1;

        insert into com_appearance_vw (
            id
            , seqnum
            , entity_type
            , object_id
            , css_class
            , object_reference
        ) values (
            o_id
            , o_seqnum
            , i_entity_type
            , i_object_id
            , i_css_class
            , i_object_reference
        );

    end;

    procedure modify_appearance (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_object_id               in com_api_type_pkg.t_long_id
        , i_css_class               in com_api_type_pkg.t_name
        , i_object_reference        in com_api_type_pkg.t_name
    ) is
    begin
        update
            com_appearance_vw
        set
            seqnum = io_seqnum
            , entity_type = i_entity_type
            , object_id = i_object_id
            , css_class = i_css_class
            , object_reference = i_object_reference
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;

    end;

    procedure remove_appearance (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            com_appearance_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        -- delete appearance
        delete from
            com_appearance_vw
        where
            id = i_id;

    end;

end;
/
