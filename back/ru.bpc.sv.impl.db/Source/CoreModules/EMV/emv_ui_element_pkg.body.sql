create or replace package body emv_ui_element_pkg is
/************************************************************
 * User interface for EMV element <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.06.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_ui_element_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_element (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_parent_id               in com_api_type_pkg.t_short_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_object_id               in com_api_type_pkg.t_short_id
        , i_element_order           in com_api_type_pkg.t_tiny_id
        , i_code                    in com_api_type_pkg.t_name
        , i_tag                     in com_api_type_pkg.t_tag
        , i_value                   in com_api_type_pkg.t_name
        , i_is_optional             in com_api_type_pkg.t_boolean
        , i_add_length              in com_api_type_pkg.t_boolean
        , i_start_position          in com_api_type_pkg.t_tiny_id
        , i_length                  in com_api_type_pkg.t_tiny_id
        , i_profile                 in com_api_type_pkg.t_dict_value
    ) is
    begin
        o_id := emv_element_seq.nextval;
        o_seqnum := 1;
        
        insert into emv_element_vw (
            id
            , seqnum
            , parent_id
            , entity_type
            , object_id
            , element_order
            , code
            , tag
            , value
            , is_optional
            , add_length
            , start_position
            , length
            , profile
        ) values (
            o_id
            , o_seqnum
            , i_parent_id
            , i_entity_type
            , i_object_id
            , i_element_order
            , i_code
            , i_tag
            , i_value
            , i_is_optional
            , i_add_length
            , i_start_position
            , i_length
            , i_profile
        );

    end;

    procedure modify_element (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_parent_id               in com_api_type_pkg.t_short_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_object_id               in com_api_type_pkg.t_short_id
        , i_element_order           in com_api_type_pkg.t_tiny_id
        , i_code                    in com_api_type_pkg.t_name
        , i_tag                     in com_api_type_pkg.t_tag
        , i_value                   in com_api_type_pkg.t_name
        , i_is_optional             in com_api_type_pkg.t_boolean
        , i_add_length              in com_api_type_pkg.t_boolean
        , i_start_position          in com_api_type_pkg.t_tiny_id
        , i_length                  in com_api_type_pkg.t_tiny_id
        , i_profile                 in com_api_type_pkg.t_dict_value
    ) is
    begin
        update
            emv_element_vw
        set
            seqnum = io_seqnum
            , element_order = i_element_order
            , code = i_code
            , tag = i_tag
            , value = i_value
            , is_optional = i_is_optional
            , add_length = i_add_length
            , start_position = i_start_position
            , length = i_length
            , profile = i_profile
        where
            id = i_id;
        
        io_seqnum := io_seqnum + 1;
    end;

    procedure remove_element (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            emv_element_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        -- delete element
        delete from
            emv_element_vw
        where
            id in (
                select
                    id
                from
                    emv_element_vw
                connect by
                    prior id = parent_id
                start with id = i_id
        );
    
    end;

end;
/
