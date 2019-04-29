create or replace package body acc_ui_bunch_type_pkg is
/************************************************************
 * UI for bunch types <br />
 * Created by Khougaev  A.  (khougaev@bpcbt.com)  at 20.11.2009 <br />
 * Last changed by $Author: fomichev$ <br />
 * $LastChangedDate::                           $<br />
 * Revision: $LastChangedRevision$ <br />
 * Module: acc_ui_bunch_type_pkg <br />
 * @headcom
 *************************************************************/

procedure add (
    o_id             out  com_api_type_pkg.t_tiny_id
  , o_seqnum         out  com_api_type_pkg.t_seqnum
  , i_short_desc  in      com_api_type_pkg.t_short_desc
  , i_full_desc   in      com_api_type_pkg.t_full_desc  := null
  , i_details     in      com_api_type_pkg.t_full_desc  := null
  , i_lang        in      com_api_type_pkg.t_dict_value := null
  , i_inst_id     in      com_api_type_pkg.t_inst_id    := null
) is
begin
    select acc_bunch_type_seq.nextval into o_id from dual;
    o_seqnum := 1;
        
    insert into acc_bunch_type_vw (
        id
      , seqnum
      , inst_id
    ) values (
        o_id
      , o_seqnum
      , i_inst_id
    );

    if i_short_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name            => 'ACC_BUNCH_TYPE' 
          , i_column_name           => 'NAME' 
          , i_object_id             => o_id
          , i_lang                  => i_lang
          , i_text                  => i_short_desc
          , i_check_unique          => com_api_const_pkg.TRUE              
        );
    end if;

    if i_full_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name            => 'ACC_BUNCH_TYPE' 
          , i_column_name           => 'DESCRIPTION' 
          , i_object_id             => o_id
          , i_lang                  => i_lang
          , i_text                  => i_full_desc
        );
    end if;
        
    if i_details is not null then
        com_api_i18n_pkg.add_text(
            i_table_name            => 'ACC_BUNCH_TYPE' 
          , i_column_name           => 'DETAILS' 
          , i_object_id             => o_id
          , i_lang                  => i_lang
          , i_text                  => i_details
        );
    end if;
end;
    
procedure modify (
    i_id          in      com_api_type_pkg.t_tiny_id
  , io_seqnum     in out  com_api_type_pkg.t_seqnum
  , i_short_desc  in      com_api_type_pkg.t_short_desc
  , i_full_desc   in      com_api_type_pkg.t_full_desc := null
  , i_details     in      com_api_type_pkg.t_full_desc := null
  , i_lang        in      com_api_type_pkg.t_dict_value := null
) is
begin
    if i_short_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name            => 'ACC_BUNCH_TYPE' 
          , i_column_name           => 'NAME' 
          , i_object_id             => i_id
          , i_lang                  => i_lang
          , i_text                  => i_short_desc
          , i_check_unique          => com_api_const_pkg.TRUE
        );
    end if;

    if i_full_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name            => 'ACC_BUNCH_TYPE' 
          , i_column_name           => 'DESCRIPTION' 
          , i_object_id             => i_id
          , i_lang                  => i_lang
          , i_text                  => i_full_desc
        );
    end if;

    if i_details is not null then
        com_api_i18n_pkg.add_text(
            i_table_name            => 'ACC_BUNCH_TYPE' 
          , i_column_name           => 'DETAILS' 
          , i_object_id             => i_id
          , i_lang                  => i_lang
          , i_text                  => i_details
        );
    end if;

    if i_short_desc is not null or i_full_desc is not null then
        update acc_bunch_type_vw
           set seqnum = io_seqnum
         where id = i_id;
                
        io_seqnum := io_seqnum + 1;    
    end if;
end;
    
procedure remove (
    i_id          in      com_api_type_pkg.t_tiny_id
  , i_seqnum      in      com_api_type_pkg.t_seqnum
) is
    l_count           pls_integer;
    l_macros_list     com_api_type_pkg.t_text;
begin
    select count(*)
         , stragg(id)
      into l_count
         , l_macros_list
      from acc_macros_type_vw
     where bunch_type_id = i_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'UNABLE_TO_DELETE_TRANS_TEMPLATE'
          , i_env_param1 => i_id
          , i_env_param2 => l_macros_list
        );
    end if;

    update  acc_bunch_type_vw
        set seqnum = i_seqnum
      where id     = i_id;
        
    delete from acc_bunch_type_vw
     where id      = i_id;        

    if sql%rowcount > 0 then
        com_api_i18n_pkg.remove_text(
            i_table_name  => 'ACC_BUNCH_TYPE' 
          , i_object_id   => i_id
        );
    end if;
    
    --entry_tpl
    delete from acc_entry_tpl_vw
      where bunch_type_id = i_id;
end;

end;
/