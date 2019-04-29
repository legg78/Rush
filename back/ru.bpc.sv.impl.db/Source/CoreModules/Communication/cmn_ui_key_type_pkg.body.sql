create or replace package body cmn_ui_key_type_pkg is
/*********************************************************
 *  Communication UI key types <br />
 *  Created by Kopachev D. (kopachev@bpcbt.com)  at 14.07.2011 <br />
 *  Last changed by $Author: fomichev $ <br />
 *  $LastChangedDate:: 2011-08-05 10:31:14 +0400#$ <br />
 *  Revision: $LastChangedRevision: 11190 $ <br />
 *  Module: CMN_UI_KEY_TYPE_PKG <br />
 *  @headcom
 **********************************************************/
 
procedure check_using_key(
    i_id                        in com_api_type_pkg.t_short_id
) is
    l_count                     com_api_type_pkg.t_short_id;
begin
    select count(1)
      into l_count 
      from cmn_key_type k
         , cmn_standard s 
         , cmn_standard_object o
         , net_member m
         , sec_des_key d
     where k.id = i_id 
       and k.standard_id = s.id
       and o.standard_id = s.id 
       and o.entity_type = net_api_const_pkg.ENTITY_TYPE_HOST
       and m.id = o.object_id
       and d.object_id = m.id
       and d.entity_type = net_api_const_pkg.ENTITY_TYPE_HOST
       and d.standard_key_type = k.standard_key_type;
    
    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'KEY_ALREADY_USED'
          , i_env_param1 => i_id
        );
    end if;
end;
 
procedure add_key_type (
    o_id                        out com_api_type_pkg.t_short_id
    , o_seqnum                  out com_api_type_pkg.t_seqnum
    , i_standard_id             in com_api_type_pkg.t_tiny_id
    , i_key_type                in com_api_type_pkg.t_dict_value
    , i_standard_key_type       in com_api_type_pkg.t_dict_value
) is
    l_count             com_api_type_pkg.t_tiny_id;            
begin
    select count(1)
      into l_count  
      from cmn_key_type_vw
     where standard_id = i_standard_id  
       and key_type = i_key_type
       and standard_key_type = i_standard_key_type;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_MAPPING_KEY_TYPE'
          , i_env_param1 => i_key_type
          , i_env_param2 => i_standard_key_type
        );            
    end if;

    o_id := cmn_key_type_seq.nextval;
    o_seqnum := 1;

    insert into cmn_key_type_vw(
        id
        , seqnum
        , standard_id
        , key_type
        , standard_key_type
    ) values (
        o_id
        , o_seqnum
        , i_standard_id
        , i_key_type
        , i_standard_key_type
    );
        
end;

procedure modify_key_type (
    i_id                        in com_api_type_pkg.t_short_id
    , io_seqnum                 in out com_api_type_pkg.t_seqnum
    , i_standard_id             in com_api_type_pkg.t_tiny_id
    , i_key_type                in com_api_type_pkg.t_dict_value
    , i_standard_key_type       in com_api_type_pkg.t_dict_value
) is
    l_count             com_api_type_pkg.t_tiny_id;
begin
    check_using_key(
        i_id      => i_id
    );
    
    select count(1)
      into l_count  
      from cmn_key_type_vw
     where standard_id = i_standard_id  
       and key_type = i_key_type
       and standard_key_type = i_standard_key_type
       and id != i_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_MAPPING_KEY_TYPE'
          , i_env_param1 => i_key_type
          , i_env_param2 => i_standard_key_type
        );            
    end if;

    update
        cmn_key_type_vw
    set
        seqnum = io_seqnum
        , standard_id = i_standard_id
        , key_type = i_key_type
        , standard_key_type = i_standard_key_type
    where
        id = i_id;
            
    io_seqnum := io_seqnum + 1;
end;
    
procedure remove_key_type (
    i_id                        in com_api_type_pkg.t_short_id
    , i_seqnum                  in com_api_type_pkg.t_seqnum
) is
begin       
    check_using_key(
        i_id      => i_id
    );
        
    update
        cmn_key_type_vw
    set
        seqnum = i_seqnum
    where
        id = i_id;
                
    delete from
        cmn_key_type_vw
    where
        id = i_id;
      
end;

function get_key_type(
    i_standard_id              in com_api_type_pkg.t_tiny_id
  , i_standard_key_type        in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value is
begin
    for rec in (
        select
            a.key_type
        from
            cmn_key_type_vw a
        where
            a.standard_id = i_standard_id
        and
            a.standard_key_type = i_standard_key_type
    ) loop
        return rec.key_type;
    end loop;

    -- not found
    com_api_error_pkg.raise_error(
        i_error      => 'KEY_TYPE_FOR_KEY_STANDARD_NOT_FOUND'
      , i_env_param1 => i_standard_id
      , i_env_param2 => i_standard_key_type
    );

end;

function get_standard_key_type (
    i_standard_id              in com_api_type_pkg.t_tiny_id
    , i_key_type               in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value is
begin
    for r in (
        select
            standard_key_type
        from
            cmn_key_type_vw
        where
            standard_id = i_standard_id
            and key_type = i_key_type
    ) loop
        return r.standard_key_type;
    end loop;

    -- not found
    com_api_error_pkg.raise_error (
        i_error      => 'STANDARD_KEY_TYPE_FOR_SYSTEM_KEY_NOT_FOUND'
        , i_env_param1 => i_standard_id
        , i_env_param2 => i_key_type
    );

end;

end;
/
