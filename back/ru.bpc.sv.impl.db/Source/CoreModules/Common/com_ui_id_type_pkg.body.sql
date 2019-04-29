create or replace package body com_ui_id_type_pkg as
/************************************************************
 * Provides an interface for managing document types. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 13.05.2011 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: COM_UI_ID_TYPE_PKG <br />
 * @headcom
 *************************************************************/

procedure check_type(
    i_entity_type  in     com_api_type_pkg.t_dict_value
  , i_id_type      in     com_api_type_pkg.t_dict_value
  , i_inst_id      in     com_api_type_pkg.t_inst_id
  , i_id           in     com_api_type_pkg.t_tiny_id    default null -- for modify record
) is
    l_id                  com_api_type_pkg.t_tiny_id;
begin
    select a.id 
      into l_id 
      from com_id_type_vw a
     where a.inst_id     = i_inst_id
       and a.entity_type = i_entity_type
       and a.id_type     = i_id_type;
    
    if l_id != nvl(i_id, 0) then -- This check should not trigger when record is updated with its own values 
        com_api_error_pkg.raise_error(
            i_error      => 'ID_TYPE_ALREADY_EXIST'
          , i_env_param1 => i_id_type
          , i_env_param2 => i_entity_type
          , i_env_param3 => i_inst_id
        );
    end if;
exception
    when no_data_found then
        null;
end check_type;

procedure add(
    o_id              out com_api_type_pkg.t_tiny_id
  , o_seqnum          out com_api_type_pkg.t_seqnum
  , i_entity_type  in     com_api_type_pkg.t_dict_value
  , i_inst_id      in     com_api_type_pkg.t_inst_id
  , i_id_type      in     com_api_type_pkg.t_dict_value
) is
begin
    check_type(
        i_entity_type => i_entity_type
      , i_id_type     => i_id_type
      , i_inst_id     => i_inst_id
    );

    o_id := com_id_type_seq.nextval;
    o_seqnum := 1;
    insert into com_id_type_vw(
        id
      , seqnum
      , entity_type
      , inst_id
      , id_type
    ) values (
        o_id
      , o_seqnum
      , i_entity_type
      , i_inst_id
      , i_id_type
    );
end add;

procedure modify(
    i_id           in     com_api_type_pkg.t_tiny_id
  , io_seqnum      in out com_api_type_pkg.t_seqnum
  , i_entity_type  in     com_api_type_pkg.t_dict_value
  , i_id_type      in     com_api_type_pkg.t_dict_value
) is
    l_inst_id             com_api_type_pkg.t_inst_id;
begin
    select a.inst_id
      into l_inst_id
      from com_id_type_vw a
     where a.id = i_id;

    check_type(
        i_entity_type => i_entity_type
      , i_id_type     => i_id_type
      , i_inst_id     => l_inst_id
      , i_id          => i_id
    );

    update com_id_type_vw
       set seqnum      = io_seqnum
         , entity_type = i_entity_type
         , id_type     = i_id_type
     where id          = i_id;

    io_seqnum := io_seqnum + 1;
end modify;

procedure remove(
    i_id           in     com_api_type_pkg.t_tiny_id
  , i_seqnum       in     com_api_type_pkg.t_seqnum
) is
    l_count        pls_integer;
    l_types        com_api_type_pkg.t_text;
    l_inst_id      com_api_type_pkg.t_inst_id; 
begin
    select count(*)
         , min(id_type)
      into l_count
         , l_types
      from(
        select x.id_type
             , x.inst_id
             , ost_api_institution_pkg.get_object_inst_id(
                   i_entity_type => x.entity_type
                 , i_object_id   => x.object_id
                 , i_mask_errors => com_api_const_pkg.TRUE
               ) as object_inst_id
          from (select o.id_type
                     , t.inst_id
                     , o.entity_type
                     , o.object_id
                  from com_id_object_vw o
                     , com_id_type_vw t
                 where t.id_type = o.id_type
                   and t.id      = i_id) x
          )
    where inst_id = object_inst_id; 
    
    if l_count > 0 then
        select inst_id
          into l_inst_id
          from com_id_type
         where id = i_id;
            
        com_api_error_pkg.raise_error(
            i_error      => 'ID_TYPE_ALREADY_USED'
          , i_env_param1 => l_types
          , i_env_param2 => l_inst_id
        );
    end if;

    for rec in (select id from com_id_type_vw where id = i_id)
    loop
        update com_id_type_vw set seqnum = i_seqnum where id = rec.id;
        delete from com_id_type_vw where id = rec.id;
    end loop;

end remove;

end com_ui_id_type_pkg;
/
