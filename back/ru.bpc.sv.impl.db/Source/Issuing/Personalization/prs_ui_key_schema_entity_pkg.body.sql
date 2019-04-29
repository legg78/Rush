create or replace package body prs_ui_key_schema_entity_pkg is
/************************************************************
 * User interface for personalization detalization of key schema <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.08.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_key_schema_entity_pkg <br />
 * @headcom
 ************************************************************/

    procedure add (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_key_schema_id           in com_api_type_pkg.t_tiny_id
        , i_key_type                in com_api_type_pkg.t_dict_value
        , i_entity_type             in com_api_type_pkg.t_dict_value
    ) is
    begin
        o_id := prs_key_schema_entity_seq.nextval;
        o_seqnum := 1;
        
        insert into prs_key_schema_entity_vw (
            id
            , seqnum
            , key_schema_id
            , key_type
            , entity_type
        ) values (
            o_id
            , o_seqnum
            , i_key_schema_id
            , i_key_type
            , i_entity_type
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'DUPLICATE_KEY_SCHEMA_ENTITY'
                , i_env_param1  => i_key_type
            );
    end;

    procedure modify (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_key_schema_id           in com_api_type_pkg.t_tiny_id
        , i_key_type                in com_api_type_pkg.t_dict_value
        , i_entity_type             in com_api_type_pkg.t_dict_value
    ) is
    begin
        update
            prs_key_schema_entity_vw
        set
            seqnum = io_seqnum
            , key_schema_id = i_key_schema_id
            , key_type = i_key_type
            , entity_type = i_entity_type
        where
            id = i_id;
            
        io_seqnum := io_seqnum + 1;
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'DUPLICATE_KEY_SCHEMA_ENTITY'
                , i_env_param1  => i_key_type
            );
    end;

    procedure remove (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
        l_check_cnt                 pls_integer;
    begin
      
        select
            count(1)
        into
            l_check_cnt
        from    
            prs_method_vw m
            , prs_key_schema_entity_vw e
        where
            m.key_schema_id = e.key_schema_id
            and e.id = i_id
            and (
                (e.key_type = 'ENKTCVK'  and m.cvv_required = 1) or
                (e.key_type = 'ENKTCVK2' and m.cvv2_required = 1) or
                (e.key_type = 'ENKTCVK'  and m.icvv_required = 1) or
                (e.key_type = 'ENKTPVK'  and m.pin_verify_method in ('PNVM0010', 'PNVM0020'))
           );
        
        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error        => 'KEY_SCHEMA_ENTITY_ALREADY_USED'
            );
        end if;
       
        update
            prs_key_schema_entity_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        delete from
            prs_key_schema_entity_vw
        where
            id = i_id;
    end;

end; 
/
