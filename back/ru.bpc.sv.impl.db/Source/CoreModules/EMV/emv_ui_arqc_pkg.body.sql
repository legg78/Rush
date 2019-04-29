create or replace package body emv_ui_arqc_pkg is
/************************************************************
 * User interface for Authorization request cryptogram <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.06.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_ui_arqc_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_arqc (
        o_id                        out com_api_type_pkg.t_long_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_object_id               in com_api_type_pkg.t_long_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_tag                     in com_api_type_pkg.t_tag
        , i_tag_order               in com_api_type_pkg.t_tiny_id
    ) is
    begin
        o_id := emv_arqc_seq.nextval;
        o_seqnum := 1;
        
        insert into emv_arqc_vw (
            id
            , seqnum
            , object_id
            , entity_type
            , tag
            , tag_order
        ) values (
            o_id
            , o_seqnum
            , i_object_id
            , i_entity_type
            , i_tag
            , i_tag_order
        );
        
    end;

    procedure modify_arqc (
        i_id                        in com_api_type_pkg.t_long_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_object_id               in com_api_type_pkg.t_long_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_tag                     in com_api_type_pkg.t_tag
        , i_tag_order               in com_api_type_pkg.t_tiny_id
    ) is
    begin
        update
            emv_arqc_vw
        set
            seqnum = io_seqnum
            , object_id = i_object_id
            , entity_type = i_entity_type
            , tag = i_tag
            , tag_order = i_tag_order
        where
            id = i_id;
        
        io_seqnum := io_seqnum + 1;
        
    end;

    procedure remove_arqc (
        i_id                        in com_api_type_pkg.t_long_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            emv_arqc_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        delete from
            emv_arqc_vw
        where
            id = i_id;
        
    end;

end;
/
