create or replace package body com_ui_array_pkg is
/*********************************************************
*  UI for array <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 01.07.2011 <br />
*  Last changed by $Author: fomichev$ <br />
*  $LastChangedDate:: 2011-07-01 13:31:16 +0400#$ <br />
*  Revision: $LastChangedRevision: 10600 $ <br />
*  Module: com_ui_array_pkg <br />
*  @headcom
**********************************************************/
procedure add_array (
    o_id                out  com_api_type_pkg.t_short_id
  , o_seqnum            out  com_api_type_pkg.t_seqnum
  , i_array_type_id  in      com_api_type_pkg.t_tiny_id
  , i_inst_id        in      com_api_type_pkg.t_inst_id
  , i_lang           in      com_api_type_pkg.t_dict_value
  , i_label          in      com_api_type_pkg.t_name
  , i_description    in      com_api_type_pkg.t_full_desc
  , i_mod_id         in      com_api_type_pkg.t_tiny_id
  , i_agent_id       in      com_api_type_pkg.t_agent_id
  , i_is_private     in      com_api_type_pkg.t_boolean
) is
begin
    o_id := com_array_seq.nextval;
    o_seqnum := 1;

    insert into com_array_vw (
        id
      , seqnum
      , array_type_id
      , inst_id
      , mod_id
      , agent_id
      , is_private
    ) values (
        o_id
      , o_seqnum
      , i_array_type_id
      , i_inst_id
      , i_mod_id
      , i_agent_id
      , i_is_private
    );

    if i_label is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'com_array'
          , i_column_name  => 'label'
          , i_object_id    => o_id
          , i_lang         => i_lang
          , i_text         => i_label
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'com_array'
          , i_column_name  => 'description'
          , i_object_id    => o_id
          , i_lang         => i_lang
          , i_text         => i_description
        );
    end if;
    
end;

procedure modify_array (
    i_id             in      com_api_type_pkg.t_short_id
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_array_type_id  in      com_api_type_pkg.t_tiny_id
  , i_inst_id        in      com_api_type_pkg.t_inst_id
  , i_lang           in      com_api_type_pkg.t_dict_value
  , i_label          in      com_api_type_pkg.t_name
  , i_description    in      com_api_type_pkg.t_full_desc
  , i_mod_id         in      com_api_type_pkg.t_tiny_id
  , i_agent_id       in      com_api_type_pkg.t_agent_id
  , i_is_private     in      com_api_type_pkg.t_boolean
) is
begin
    update com_array_vw
       set seqnum        = io_seqnum
         , array_type_id = i_array_type_id
         , inst_id       = i_inst_id
         , mod_id        = i_mod_id
         , agent_id      = i_agent_id
         , is_private    = i_is_private
     where id = i_id;

    io_seqnum := io_seqnum + 1;

    if i_label is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'com_array'
          , i_column_name  => 'label'
          , i_object_id    => i_id
          , i_lang         => i_lang
          , i_text         => i_label
        );
    end if;
    
    if i_description is not null then    
        com_api_i18n_pkg.add_text (
            i_table_name   => 'com_array'
          , i_column_name  => 'description'
          , i_object_id    => i_id
          , i_lang         => i_lang
          , i_text         => i_description
        );
    end if;
end;

procedure remove_array (
    i_id                    in com_api_type_pkg.t_short_id
  , i_seqnum              in com_api_type_pkg.t_seqnum
) is
    l_count                 com_api_type_pkg.t_tiny_id;
begin
    select count(*)
      into l_count
      from com_array_conversion_vw
     where in_array_id = i_id 
        or out_array_id = i_id;
        
    select count(*)+ l_count
      into l_count
      from com_array_element_vw  
     where array_id = i_id;
     
    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'ARRAY_IS_ALREADY_USED'
          , i_env_param1  => i_id
        );
    end if;

    com_api_i18n_pkg.remove_text (
        i_table_name => 'com_array'
      , i_object_id  => i_id
    );

    update com_array_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from com_array_vw
    where id = i_id;
end;

procedure get_array_elements (
    o_ref_cur           out sys_refcursor
    , i_array_id        in com_api_type_pkg.t_short_id
) is
    l_sql_source        com_api_type_pkg.t_full_desc;
    l_data_type         com_api_type_pkg.t_dict_value;
begin
    begin
        select
            t.data_type
        into
            l_data_type
        from
            com_array_vw a
            , com_array_type_vw t
        where
            a.id = i_array_id
            and t.id = a.array_type_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'ARRAY_NOT_FOUND'
                , i_env_param1  => i_array_id
            );
    end;
    
    case l_data_type
        when com_api_const_pkg.DATA_TYPE_CHAR then
            l_sql_source := 'select element_value code, label name from com_ui_array_element_vw where array_id = :i_array_id and lang = com_ui_user_env_pkg.get_user_lang';
        
        when com_api_const_pkg.DATA_TYPE_NUMBER then
            l_sql_source := 'select to_number(element_value, '''||com_api_const_pkg.NUMBER_FORMAT||''') code, label name from com_ui_array_element_vw where array_id = :i_array_id and lang = com_ui_user_env_pkg.get_user_lang';
        
        when com_api_const_pkg.DATA_TYPE_DATE then
            l_sql_source := 'select to_date(element_value, '''||com_api_const_pkg.DATE_FORMAT||''') code, label name from com_ui_array_element_vw where array_id = :i_array_id and lang = com_ui_user_env_pkg.get_user_lang';
    else 
        com_api_error_pkg.raise_error (
            i_error         => 'WRONG_ARRAY_ELEMENT_DATA_TYPE'
            , i_env_param1  => l_data_type
        );
    end case;
    
    open o_ref_cur
    for l_sql_source
    using i_array_id;
end;

procedure get_elements_where(
    i_array_id_list     in     num_tab_tpt
  , o_sql_where         out    com_api_type_pkg.t_full_desc  
)is
    l_id_list           com_api_type_pkg.t_full_desc;
begin

    select stragg(t_id)
      into l_id_list 
    from(select column_value as t_id from table(cast(i_array_id_list as num_tab_tpt)));

    o_sql_where := ' where id in (select numeric_value from com_array_element where array_id in (' || l_id_list || '))';
        
end;

end;
/
