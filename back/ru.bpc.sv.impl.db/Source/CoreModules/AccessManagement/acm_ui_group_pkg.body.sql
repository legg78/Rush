create or replace package body acm_ui_group_pkg as
/*********************************************************
 *  Interface for acm_group  <br />
 *  Created by Sergey Ivanov (sr.ivanov@bpcbt.com)  at 29.10.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: acm_ui_group_pkg <br />
 *  @headcom
 **********************************************************/
procedure check_unique(
    i_id            in     com_api_type_pkg.t_short_id
  , i_name          in     com_api_type_pkg.t_name
  , i_lang          in     com_api_type_pkg.t_dict_value
  
)
is
    l_count                pls_integer;
begin
    select count(1)
      into l_count
      from acm_ui_group_vw vv
     where upper(vv.description) = upper(i_name)
       and (vv.lang = i_lang
           or i_lang is null)
       and (vv.id != i_id 
           or i_id is null);
       
    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'USER_GROUP_ALREADY_EXISTS'
          , i_env_param1  => upper(i_name)
        );
    end if;
end check_unique;

procedure check_group_exists(
    i_id            in     com_api_type_pkg.t_short_id
)
is
    l_count                pls_integer;
begin
    select count(1)
      into l_count
      from acm_ui_group_vw vv
     where vv.id = i_id;

    if l_count = 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'GROUP_IS_NOT_FOUND'
          , i_env_param1  => i_id
        );
    end if;
end check_group_exists;

procedure add_group(
    o_id               out com_api_type_pkg.t_short_id
  , o_seqnum           out com_api_type_pkg.t_seqnum
  , i_inst_id       in     com_api_type_pkg.t_tiny_id
  , i_creation_date in     date                          default get_sysdate
  , i_name          in     com_api_type_pkg.t_name
  , i_lang          in     com_api_type_pkg.t_dict_value
)
is
begin
    check_unique(
        i_id   => null
      , i_name => i_name
      , i_lang => i_lang
    );

    o_id      := acm_group_seq.nextval;
    o_seqnum  := 1;

    insert into acm_group_vw(
        id
      , seqnum
      , inst_id
      , creation_date
    ) values (
        o_id
      , o_seqnum
      , i_inst_id
      , i_creation_date
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'acm_group'
      , i_column_name  => 'NAME'
      , i_object_id    => o_id
      , i_text         => i_name
      , i_lang         => i_lang
    );
end add_group;

procedure modify_group(
    i_id            in     com_api_type_pkg.t_short_id
  , io_seqnum       in out com_api_type_pkg.t_seqnum
  , i_inst_id       in     com_api_type_pkg.t_tiny_id
  , i_creation_date in     date                          default null
  , i_name          in     com_api_type_pkg.t_name
  , i_lang          in     com_api_type_pkg.t_dict_value
)
is
begin
    check_unique(
        i_id   => null
      , i_name => i_name
      , i_lang => i_lang
    );
    
    update acm_group_vw
       set seqnum        = io_seqnum
         , inst_id       = i_inst_id
         , creation_date = nvl(i_creation_date,creation_date)
     where id            = i_id;

    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'acm_group'
      , i_column_name  => 'NAME'
      , i_object_id    => i_id
      , i_text         => i_name
      , i_lang         => i_lang
    );
end modify_group;

procedure attach_user(
    o_id               out com_api_type_pkg.t_short_id
  , i_user_id       in     com_api_type_pkg.t_short_id
  , i_group_id      in     com_api_type_pkg.t_short_id
)
is
    l_count                pls_integer;
begin
    check_group_exists(i_group_id);

    select count(1)
      into l_count
      from acm_user_group_vw vv
     where vv.user_id  = i_user_id
       and vv.group_id = i_group_id;
    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error      => 'USER_ALREADY_EXISTS_IN_GROUP'
          , i_env_param1 => i_user_id
          , i_env_param2 => i_group_id
        );
    end if;

    o_id := acm_group_seq.nextval;

    insert into acm_user_group_vw(
        id
      , user_id
      , group_id
    ) values (
        o_id
      , i_user_id
      , i_group_id
    );

    trc_log_pkg.debug('Attaching user [' || i_user_id || '] to group [' || i_group_id || ']');
end attach_user;

procedure attach_user(
    i_user_id       in     com_api_type_pkg.t_short_id
  , i_group_id      in     com_api_type_pkg.t_short_id
)
is
    l_id                   com_api_type_pkg.t_short_id;
begin
    attach_user(
        o_id       => l_id
      , i_user_id  => i_user_id
      , i_group_id => i_group_id
    );

end attach_user;

procedure detach_user(
    i_id            in     com_api_type_pkg.t_short_id default null
  , i_user_id       in     com_api_type_pkg.t_short_id
  , i_group_id      in     com_api_type_pkg.t_short_id
)
is
begin
    delete from acm_user_group_vw ug
     where ug.id       = i_id
        or (ug.user_id  = i_user_id
            and ug.group_id = i_group_id)
        or (i_group_id is null
            and ug.user_id  = i_user_id)
        or (i_user_id is null
            and ug.group_id = i_group_id);

    trc_log_pkg.debug( 'Detaching user [' || i_user_id || '] to group [' || i_group_id || ']');
end detach_user;

end;
/
