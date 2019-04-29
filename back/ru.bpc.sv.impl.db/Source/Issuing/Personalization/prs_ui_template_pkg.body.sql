create or replace package body prs_ui_template_pkg is
/************************************************************
 * User interface for personalization templates <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.08.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_template_pkg <br />
 * @headcom
 ************************************************************/

    procedure add (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_method_id               in com_api_type_pkg.t_tiny_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_format_id               in com_api_type_pkg.t_tiny_id
        , i_mod_id                  in com_api_type_pkg.t_tiny_id
    ) is
    begin
        o_id := prs_template_seq.nextval;
        o_seqnum := 1;
            
        insert into prs_template_vw (
            id
            , seqnum
            , method_id
            , entity_type
            , format_id
            , mod_id
        ) values (
            o_id
            , o_seqnum
            , i_method_id
            , i_entity_type
            , i_format_id
            , i_mod_id
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'DUPLICATE_ENTITY_TYPE_METHOD'
                , i_env_param1  => i_entity_type
            );        
    end;

    procedure modify (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_method_id               in com_api_type_pkg.t_tiny_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_format_id               in com_api_type_pkg.t_tiny_id
        , i_mod_id                  in com_api_type_pkg.t_tiny_id
    ) is
    begin
        update
            prs_template_vw
        set
            seqnum = io_seqnum
            , method_id = i_method_id
            , entity_type = i_entity_type
            , format_id = i_format_id
            , mod_id = i_mod_id
        where
            id = i_id;
            
        io_seqnum := io_seqnum + 1;
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'DUPLICATE_ENTITY_TYPE_METHOD'
                , i_env_param1  => i_entity_type
            );        
    end;

    procedure remove (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            prs_template_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        delete from
            prs_template_vw
        where
            id = i_id;
    end;

end; 
/
