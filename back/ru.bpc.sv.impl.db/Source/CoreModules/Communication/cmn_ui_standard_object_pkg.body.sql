create or replace package body cmn_ui_standard_object_pkg is
/********************************************************* 
 *  UI for standard objects <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 14.03.2012 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: cmn_ui_standard_object_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_standard_object (
    i_entity_type       in com_api_type_pkg.t_dict_value
    , i_object_id       in com_api_type_pkg.t_long_id
    , i_standard_id     in com_api_type_pkg.t_tiny_id
) is
begin
    trc_log_pkg.debug (
        i_text          => 'add_standard_object: [#1][#2][#3]'
        , i_env_param1  => i_entity_type
        , i_env_param2  => i_object_id
        , i_env_param3  => i_standard_id
    );

    for src in (
        select
            i_entity_type       entity_type
            , i_object_id       object_id
            , id                standard_id
            , standard_type     standard_type
        from
            cmn_standard_vw
        where
            id = i_standard_id
    ) loop
        update
            cmn_standard_object_vw dst
        set
            dst.standard_id = src.standard_id
            , dst.standard_type = src.standard_type
        where
            src.entity_type = dst.entity_type
            and src.object_id = dst.object_id
            and decode(src.standard_type, 'STDT0001', 'STDT0002', src.standard_type) = decode(dst.standard_type, 'STDT0001', 'STDT0002', dst.standard_type);
        
        if sql%rowcount = 0 then
            insert into cmn_standard_object_vw dst (
                dst.id
                , dst.entity_type
                , dst.object_id
                , dst.standard_id
                , dst.standard_type
            ) values (
                cmn_standard_object_seq.nextval
                , src.entity_type
                , src.object_id
                , src.standard_id
                , src.standard_type
            );
        end if;
    end loop;
end;

procedure remove_standard_object (
    i_id                in com_api_type_pkg.t_short_id
) is
begin
    delete from 
        cmn_standard_object_vw
    where 
        id = i_id;
end;
    
procedure remove_standard_object (
    i_entity_type       in com_api_type_pkg.t_dict_value
    , i_object_id       in com_api_type_pkg.t_long_id
) is
begin
    delete from 
        cmn_standard_object_vw
    where 
        object_id = i_object_id
        and entity_type = i_entity_type;
end;

procedure remove_standard_object (
    i_entity_type       in com_api_type_pkg.t_dict_value
    , i_object_id       in com_api_type_pkg.t_long_id
    , i_standard_type   in com_api_type_pkg.t_dict_value
) is
begin
    delete from 
        cmn_standard_object_vw
    where 
        object_id = i_object_id
        and entity_type = i_entity_type
        and standard_type = i_standard_type;
end;

procedure add_standard_version_object (
    o_id              out  com_api_type_pkg.t_short_id
  , i_entity_type  in      com_api_type_pkg.t_dict_value
  , i_object_id    in      com_api_type_pkg.t_long_id
  , i_version_id   in      com_api_type_pkg.t_tiny_id
  , i_start_date   in      date
) is
    l_count        com_api_type_pkg.t_long_id;
begin
    select count(id)
      into l_count
      from cmn_standard_version_obj_vw
     where entity_type = i_entity_type
       and object_id   = i_object_id
       and version_id  = i_version_id;
    
    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'STANDARD_VERSION_OBJ_ALREADY_EXISTS'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_object_id
          , i_env_param3 => i_version_id
        );
    end if;

    o_id := cmn_standard_version_obj_seq.nextval;
        
    insert into cmn_standard_version_obj_vw(
        id
      , entity_type
      , object_id
      , version_id
      , start_date
    ) values (
        o_id
      , i_entity_type
      , i_object_id
      , i_version_id
      , i_start_date
    );
end;

procedure modify_standard_version_object (
    i_id          in      com_api_type_pkg.t_short_id
  , i_start_date  in      date
) is
begin
    update cmn_standard_version_obj
       set start_date = i_start_date
     where id         = i_id;
end;

procedure remove_standard_version_object (
    i_id          in      com_api_type_pkg.t_short_id
) is
begin
    delete from cmn_standard_version_obj
     where id = i_id;
end;

end;
/
