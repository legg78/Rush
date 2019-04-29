create or replace package body rul_ui_proc_pkg is
/*********************************************************
*  User interface for Rules procedures <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 14.05.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: RUL_UI_PROC_PKG <br />
*  @headcom
**********************************************************/
procedure add (
    o_id                 out com_api_type_pkg.t_tiny_id
  , i_proc_name       in     com_api_type_pkg.t_name
  , i_category        in     com_api_type_pkg.t_dict_value
  , i_lang            in     com_api_type_pkg.t_dict_value
  , i_name            in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_text
) is
    l_check_cnt                 com_api_type_pkg.t_count := 0;
begin
    select count(*)
      into l_check_cnt
      from user_procedures u 
     where subprogram_id > 0
       and object_name||nvl2(procedure_name, '.','')||procedure_name = upper(i_proc_name);

    if l_check_cnt = 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'PROCEDURE_NOT_FOUND'
          , i_env_param1  => i_proc_name
        );
    end if;
    
    select count(*)
      into l_check_cnt
      from (select 1
              from rul_proc
             where proc_name = i_proc_name
               and category = i_category
               and rownum = 1
      );
    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'RULE_PROCEDURE_ALREADY_EXISTS'
          , i_env_param1  => i_proc_name
          , i_env_param2  => i_category
        );
    end if;
    
    o_id := rul_proc_seq.nextval;
    insert into rul_proc_vw (
        id
      , proc_name
      , category
    ) values (
        o_id
      , i_proc_name
      , i_category
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'rul_proc'
      , i_column_name  => 'name'
      , i_object_id    => o_id
      , i_text         => i_name
      , i_lang         => i_lang
      , i_check_unique  => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'rul_proc'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
    );
end;

procedure modify (
    i_id              in     com_api_type_pkg.t_tiny_id
  , i_proc_name       in     com_api_type_pkg.t_name
  , i_category        in     com_api_type_pkg.t_dict_value
  , i_lang            in     com_api_type_pkg.t_dict_value
  , i_name            in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_text
) is
    l_check_cnt                 com_api_type_pkg.t_count := 0;
begin
    select count(*)
      into l_check_cnt
      from (
        select 1
          from rul_rule_vw r
             , rul_proc p
         where r.proc_id = p.id
           and p.id = i_id
           and p.proc_name != i_proc_name
           and rownum = 1
    );
    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'PROCEDURE_ALREADY_USED'
        );
    end if;
    
    select count(*)
      into l_check_cnt
      from user_procedures u
     where subprogram_id > 0
       and object_name||nvl2(procedure_name, '.','')||procedure_name = upper(i_proc_name);

    if l_check_cnt =0 then
        com_api_error_pkg.raise_error(
            i_error       => 'PROCEDURE_NOT_FOUND'
          , i_env_param1  => i_proc_name
        );
    end if;
    
    select count(1)
      into l_check_cnt
      from rul_rule_vw
     where proc_id = i_id;
        
    if l_check_cnt > 0 then
        for rec in (
            select category
              from rul_proc_vw
             where id = i_id
        ) loop
            if i_category <> rec.category then
                com_api_error_pkg.raise_error (
                    i_error         => 'CATEGORY_PROCEDURES_NOT_CHANGE'
                );
            end if;
        end loop;
    end if;

    select count(*)
      into l_check_cnt
      from (select 1
              from rul_proc
             where proc_name = i_proc_name
               and category = i_category
               and id != i_id
               and rownum = 1
      );
    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'RULE_PROCEDURE_ALREADY_EXISTS'
          , i_env_param1  => i_proc_name
          , i_env_param2  => i_category
        );
    end if;
    
    update rul_proc_vw
       set proc_name = i_proc_name
         , category  = i_category
     where id = i_id;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'rul_proc'
      , i_column_name  => 'name'
      , i_object_id    => i_id
      , i_text         => i_name
      , i_lang         => i_lang
      , i_check_unique  => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'rul_proc'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_text         => i_description
      , i_lang         => i_lang
    );

end;

procedure remove (
    i_id           in      com_api_type_pkg.t_tiny_id
) is
    l_check_cnt         number;
begin
    select count(*)
      into l_check_cnt
      from (select 1
              from rul_proc_param_vw p
                 , rul_rule_param_value_vw v
             where p.proc_id       = i_id
               and v.proc_param_id = p.id
               and rownum          = 1
        union all
        select 1 from rul_rule_vw where proc_id = i_id and rownum = 1
    );

    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'PROCEDURE_ALREADY_USED'
        );
    end if;

    -- delete rule param value
    for rec in (
        select id
          from rul_proc_param_vw
         where proc_id = i_id
    ) loop
        remove_param (
            i_id  => rec.id
        );
    end loop;

    -- delete rule procedure
    delete from rul_proc_vw
     where id = i_id;

    com_api_i18n_pkg.remove_text (
        i_table_name => 'rul_proc'
      , i_object_id  => i_id
    );
end;

procedure add_param (
    o_id                 out com_api_type_pkg.t_short_id
  , i_proc_id         in     com_api_type_pkg.t_tiny_id
  , i_param_name      in     com_api_type_pkg.t_name
  , i_lov_id          in     com_api_type_pkg.t_tiny_id
  , i_order           in     com_api_type_pkg.t_tiny_id
  , i_is_mandatory    in     com_api_type_pkg.t_boolean
  , i_param_id        in     com_api_type_pkg.t_short_id
  , i_lang            in     com_api_type_pkg.t_dict_value
  , i_name            in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_text
) is
    l_check_cnt                 com_api_type_pkg.t_count := 0;
begin
    o_id := rul_proc_param_seq.nextval;

    select count(id)
      into l_check_cnt
      from rul_proc_param_vw
     where proc_id    = i_proc_id
       and (param_name = i_param_name
         or param_id   = i_param_id);

    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'PARAMETER_ALREADY_EXIST'
          , i_env_param1 => i_param_name
        );
    end if;

    select count(id)
      into l_check_cnt
      from rul_proc_param_vw
     where proc_id        = i_proc_id
       and display_order  = i_order;

    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error(
            i_error      =>  'PROC_PARAMETER_ORDER_NOT_UNIQUE'
          , i_env_param1 => i_proc_id
          , i_env_param2 => i_order
        );
    end if;

    insert into rul_proc_param_vw (
        id
      , proc_id
      , param_name
      , lov_id
      , display_order
      , is_mandatory
      , param_id
    ) values (
        o_id
      , i_proc_id
      , i_param_name
      , i_lov_id
      , i_order
      , i_is_mandatory
      , i_param_id
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'rul_proc_param'
      , i_column_name  => 'name'
      , i_object_id    => o_id
      , i_text         => i_name
      , i_lang         => i_lang
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'rul_proc_param'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
    );

end;

procedure modify_param (
    i_id              in     com_api_type_pkg.t_short_id
  , i_lov_id          in     com_api_type_pkg.t_tiny_id
  , i_order           in     com_api_type_pkg.t_tiny_id
  , i_is_mandatory    in     com_api_type_pkg.t_boolean
  , i_lang            in     com_api_type_pkg.t_dict_value
  , i_name            in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_text
) is
    l_check_cnt       com_api_type_pkg.t_count := 0;
    l_proc_id         com_api_type_pkg.t_tiny_id;
begin
    for proc_param in (
        select proc_id
          from rul_proc_param_vw
         where id = i_id
    ) loop
        l_proc_id := proc_param.proc_id;
    end loop;
    
    select count(id)
      into l_check_cnt
      from rul_proc_param_vw
     where proc_id        = l_proc_id
       and display_order  = i_order
       and id != i_id;

    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error(
            i_error      =>  'PROC_PARAMETER_ORDER_NOT_UNIQUE'
          , i_env_param1 => l_proc_id
          , i_env_param2 => i_order
        );
    end if;
    
    update rul_proc_param_vw
       set lov_id        = i_lov_id
         , display_order = i_order
         , is_mandatory  = i_is_mandatory
     where id            = i_id;

    if i_name is not null  or i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'rul_proc_param'
          , i_column_name  => 'name'
          , i_object_id    => i_id
          , i_text         => i_name
          , i_lang         => i_lang
        );

        com_api_i18n_pkg.add_text(
            i_table_name   => 'rul_proc_param'
          , i_column_name  => 'description'
          , i_object_id    => i_id
          , i_text         => i_description
          , i_lang         => i_lang
        );
    else
        com_api_i18n_pkg.remove_text(
            i_table_name => 'rul_proc_param'
          , i_object_id  => i_id
        );
    end if;

end;

procedure remove_param (
    i_id           in      com_api_type_pkg.t_short_id
) is
    l_check_cnt         number;
begin
    select count(*)
      into l_check_cnt
      from (select 1 
              from rul_rule_param_value_vw
             where proc_param_id = i_id
               and rownum        = 1
           );
        
    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error (
            i_error         => 'RULE_PARAMETER_ALREADY_USED'
            , i_env_param1  => i_id
        );
    end if;

    delete from rul_proc_param_vw
     where id = i_id;

    com_api_i18n_pkg.remove_text (
        i_table_name  => 'rul_proc_param'
      , i_object_id   => i_id
    );
end;

end;
/
