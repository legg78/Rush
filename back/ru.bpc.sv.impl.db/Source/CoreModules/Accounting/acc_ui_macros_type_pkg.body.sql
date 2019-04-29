create or replace package body acc_ui_macros_type_pkg is

procedure add (
    o_id                out  com_api_type_pkg.t_tiny_id
  , o_seqnum            out  com_api_type_pkg.t_seqnum
  , i_bunch_type_id  in      com_api_type_pkg.t_tiny_id
  , i_status         in      com_api_type_pkg.t_dict_value
  , i_short_desc     in      com_api_type_pkg.t_short_desc
  , i_full_desc      in      com_api_type_pkg.t_full_desc    default null
  , i_details        in      com_api_type_pkg.t_full_desc    default null
  , i_lang           in      com_api_type_pkg.t_dict_value   default null
  , i_inst_id        in      com_api_type_pkg.t_inst_id      default null
) is
begin
    select acc_macros_type_seq.nextval into o_id from dual;
    o_seqnum := 1;

    if i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST then
        insert into acc_macros_type_vw (
            id
          , seqnum
          , bunch_type_id
          , status      
        ) values (
            o_id
          , o_seqnum
          , i_bunch_type_id
          , i_status
        );
    else
        insert into acc_macros_bunch_type_vw (
            id
          , seqnum
          , bunch_type_id
          , inst_id      
          , status      
        ) values (
            o_id
          , o_seqnum
          , i_bunch_type_id
          , i_inst_id
          , i_status
        );
    end if;
    
    if i_short_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'ACC_MACROS_TYPE'
          , i_column_name   => 'NAME'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_short_desc
          , i_check_unique  => com_api_type_pkg.TRUE 
        );
    end if;

    if i_full_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'ACC_MACROS_TYPE'
          , i_column_name   => 'DESCRIPTION'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_full_desc
        );
    end if;

    if i_details is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'ACC_MACROS_TYPE'
          , i_column_name   => 'DETAILS'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_details
        );
    end if;
end;

procedure modify (
    i_id             in      com_api_type_pkg.t_tiny_id
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_bunch_type_id  in      com_api_type_pkg.t_tiny_id
  , i_status         in      com_api_type_pkg.t_dict_value
  , i_short_desc     in      com_api_type_pkg.t_short_desc
  , i_full_desc      in      com_api_type_pkg.t_full_desc    default null
  , i_details        in      com_api_type_pkg.t_full_desc    default null
  , i_lang           in      com_api_type_pkg.t_dict_value   default null
) is
    l_macros_type_id         com_api_type_pkg.t_tiny_id;
begin
    begin
        select id
          into l_macros_type_id
          from acc_macros_type_vw
         where id = i_id;
         
        update acc_macros_type_vw t
           set t.seqnum        = io_seqnum
             , t.bunch_type_id = i_bunch_type_id
             , t.status        = i_status
         where t.id            = i_id;
    exception
        when no_data_found then
            update acc_macros_bunch_type_vw t
               set t.seqnum        = io_seqnum
                 , t.bunch_type_id = i_bunch_type_id
                 , t.status        = i_status
             where t.id            = i_id;
    end;

    if i_short_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'ACC_MACROS_TYPE'
          , i_column_name   => 'NAME'
          , i_object_id     => i_id
          , i_lang          => i_lang
          , i_text          => i_short_desc
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_full_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'ACC_MACROS_TYPE'
          , i_column_name   => 'DESCRIPTION'
          , i_object_id     => i_id
          , i_lang          => i_lang
          , i_text          => i_full_desc
        );
    end if;

    if i_details is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'ACC_MACROS_TYPE'
          , i_column_name   => 'DETAILS'
          , i_object_id     => i_id
          , i_lang          => i_lang
          , i_text          => i_details
        );
    end if;

    io_seqnum := io_seqnum + 1;
end;

procedure remove (
    i_id             in     com_api_type_pkg.t_tiny_id
  , i_seqnum         in     com_api_type_pkg.t_seqnum
) is
    l_rule_id                com_api_type_pkg.t_short_id;
    l_macros_type_id         com_api_type_pkg.t_tiny_id;
begin
    select min(r.id)
      into l_rule_id
      from rul_rule_param_value_vw v
         , rul_proc_param_Vw p
         , rul_rule_vw r
         , acc_macros_type_vw t
     where p.param_name    = 'MACROS_TYPE'
       and v.proc_param_id = p.id
       and r.id            = v.rule_id 
       and t.id            = i_id
       and to_char(t.id, get_number_format) = v.param_value;

    if l_rule_id is not null then
        com_api_error_pkg.raise_error(
            i_error      => 'MACROS_TYPE_IN_USE'
          , i_env_param1 => i_id
          , i_env_param2 => l_rule_id
        );
    end if;

    begin
        select id
          into l_macros_type_id
          from acc_macros_type_vw
         where id = i_id;
         
        update acc_macros_type_vw
           set seqnum = i_seqnum
         where id     = i_id;

        delete from acc_macros_type_vw
         where id     = i_id;

        if sql%rowcount > 0 then
            com_api_i18n_pkg.remove_text(
                i_table_name            => 'ACC_MACROS_TYPE'
              , i_object_id             => i_id
            );
        end if;
    exception
        when no_data_found then
            update acc_macros_bunch_type_vw t
               set t.seqnum        = i_seqnum
             where t.id            = i_id;

            delete from acc_macros_bunch_type_vw
             where id              = i_id;

            if sql%rowcount > 0 then
                com_api_i18n_pkg.remove_text(
                    i_table_name            => 'ACC_MACROS_TYPE'
                  , i_object_id             => i_id
                );
            end if;
    end;
end;

end;
/
