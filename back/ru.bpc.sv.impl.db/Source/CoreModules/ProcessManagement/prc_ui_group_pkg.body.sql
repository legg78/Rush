create or replace package body prc_ui_group_pkg is
/*************************************************************
* UI for grouping processes <br />
* Created by Kryukov E.(krukov@bpc.ru)  at 04.10.2009 <br />
* Last changed by $Author: krukov $ <br />
* $LastChangedDate:: 2010-06-30 15:04:48 +040#$ <br />
* Revision: $LastChangedRevision: 3792 $ <br />
* Module: PRC_UI_GROUP_PKG <br />
* @headcom
*************************************************************/

procedure check_text(
    i_object_id             in com_api_type_pkg.t_inst_id
    , i_text                in com_api_type_pkg.t_name
)is
l_count                 com_api_type_pkg.t_tiny_id;
    
begin       
    if i_object_id is null then
       select count(1)    
          into l_count
          from com_i18n_vw i 
             , prc_group_vw c  
         where i.table_name = 'PRC_GROUP'
           and i.column_name = 'NAME'  
           and i.text = i_text
           and c.id = i.object_id;
    else
        select count(1)
          into l_count
          from com_i18n_vw i
             , prc_group_vw c  
         where i.table_name = 'PRC_GROUP'
           and i.column_name = 'NAME'  
           and i.text        = i_text
           and c.id = i.object_id
           and i.object_id   != i_object_id;
    end if;
        
    trc_log_pkg.debug (
        i_text          => 'l_count ' || l_count
    );
        
    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error         => 'SEMAPHORE_ALREADY_EXISTS'
            , i_env_param1  => i_object_id
            , i_env_param2  => i_text
        );
    end if;         
end;

procedure add_group (
    o_id                  out com_api_type_pkg.t_tiny_id
  , i_semaphore_name   in     com_api_type_pkg.t_semaphore_name
  , i_short_desc       in     com_api_type_pkg.t_short_desc
  , i_full_desc        in     com_api_type_pkg.t_full_desc
  , i_lang             in     com_api_type_pkg.t_dict_value
) is
begin
    check_text(
        i_object_id     => o_id
        , i_text        => i_short_desc
    );
    
    o_id := prc_group_seq.nextval;

    insert into prc_group_vw (
        id
      , semaphore_name
    ) values (
        o_id
      , upper(i_semaphore_name)
    );
        
    -- add/edit description
    com_api_i18n_pkg.add_text (
        i_table_name   => 'prc_group'
      , i_column_name  => 'name'
      , i_object_id    => o_id
      , i_text         => i_short_desc
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.FALSE
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prc_group'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_full_desc
      , i_lang         => i_lang
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error (
            i_error         => 'SEMAPHORE_ALREADY_EXISTS'
            , i_env_param1  => o_id
            , i_env_param2  => i_semaphore_name
        );
            
end;

procedure modify_group (
    i_id               in    com_api_type_pkg.t_tiny_id
  , i_semaphore_name   in    com_api_type_pkg.t_semaphore_name
  , i_short_desc       in    com_api_type_pkg.t_short_desc
  , i_full_desc        in    com_api_type_pkg.t_full_desc
  , i_lang             in    com_api_type_pkg.t_dict_value
) is
begin
    check_text(
        i_object_id     => i_id
        , i_text        => i_short_desc
    );

    update prc_group_vw
       set semaphore_name = upper(i_semaphore_name)
     where id             = i_id;
        
    -- add/edit description
    com_api_i18n_pkg.add_text (
        i_table_name   => 'prc_group'
      , i_column_name  => 'name'
      , i_object_id    => i_id
      , i_text         => i_short_desc
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.FALSE
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prc_group'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_text         => i_full_desc
      , i_lang         => i_lang
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error (
            i_error       => 'SEMAPHORE_ALREADY_EXISTS'
          , i_env_param1  => i_id
          , i_env_param2  => i_semaphore_name
        );
            
end;

procedure remove_group (
    i_id                    in com_api_type_pkg.t_tiny_id
) is
begin
    -- check group
    for rec in (
        select id
             , semaphore_name
          from prc_group_vw
         where id = i_id
    ) loop
        -- check is semaphore active
        for rec2 in (
            select 1
              from prc_active_semaphore_vw a
             where a.semaphore_name = rec.semaphore_name
        ) loop
            com_api_error_pkg.raise_error (
                i_error       => 'CANT_REMOVE_ACTIVE_SEMAPHORE'
              , i_env_param1  => rec.semaphore_name
            );
        end loop;

        -- remove description
        com_api_i18n_pkg.remove_text (
            i_table_name => 'prc_group'
          , i_object_id  => rec.id
        );

        -- remove procedure from group
        delete prc_group_process_vw a
         where a.group_id = i_id;

        -- remove group
        delete prc_group_vw b
         where b.id = i_id;

        -- remove descriptions
        com_api_i18n_pkg.remove_text (
            i_table_name => 'prc_group'
          , i_object_id  => i_id
        );
    end loop;
end;

procedure add_group_process (
    o_id                out com_api_type_pkg.t_short_id
  , i_group_id       in     com_api_type_pkg.t_tiny_id
  , i_process_id     in     com_api_type_pkg.t_short_id
) is
    l_count          com_api_type_pkg.t_tiny_id;

begin
    o_id := prc_group_process_seq.nextval;

    -- check unique
    select count(1)
      into l_count
      from prc_group_process_vw a
     where a.group_id   = i_group_id
       and a.process_id = i_process_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'GROUP_PROCESS_ALREADY_EXISTS'
          , i_env_param1 => i_group_id
          , i_env_param2 => i_process_id
        );
    end if;

    insert into prc_group_process_vw (
        id
      , group_id
      , process_id
    ) values(
        o_id
      , i_group_id
      , i_process_id
    );
end;

procedure remove_group_process (
    i_id                    in com_api_type_pkg.t_short_id
) is
begin
    delete prc_group_process_vw
     where id = i_id;
end;

end;
/
