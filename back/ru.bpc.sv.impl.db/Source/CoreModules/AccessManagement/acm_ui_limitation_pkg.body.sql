create or replace package body acm_ui_limitation_pkg as

procedure add_limitation(
    o_limitation_id        out  com_api_type_pkg.t_short_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_priv_id           in      com_api_type_pkg.t_short_id
  , i_condition         in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_label             in      com_api_type_pkg.t_name
  , i_limitation_type   in      com_api_type_pkg.t_dict_value
)is
begin
    o_limitation_id := acm_priv_limitation_seq.nextval;
    o_seqnum := 1;

    insert into acm_priv_limitation_vw(
        id
      , seqnum
      , priv_id
      , condition
      , limitation_type
    ) values (
        o_limitation_id
      , o_seqnum
      , i_priv_id
      , i_condition
      , i_limitation_type
    );

    com_api_i18n_pkg.add_text(
        i_table_name    => 'acm_priv_limitation'
      , i_column_name   => 'label'
      , i_object_id     => o_limitation_id
      , i_lang          => i_lang
      , i_text          => i_label
    );
end add_limitation;

procedure modify_limitation(
    i_limitation_id     in      com_api_type_pkg.t_short_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_condition         in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_label             in      com_api_type_pkg.t_name
  , i_limitation_type   in      com_api_type_pkg.t_dict_value default null
)is
    l_count             com_api_type_pkg.t_count := 0;
    l_condition         com_api_type_pkg.t_full_desc := i_condition;
begin

    select count(1)
      into l_count
      from acm_role_privilege
     where i_limitation_id in (limit_id, filter_limit_id);

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error     => 'PRIVILEGE_LIMITATION_IN_USE'
        );
    end if;
      
    if i_limitation_type = acm_api_const_pkg.PRIV_LIMITATION_FILTER then
        l_condition := null;
    elsif i_limitation_type = acm_api_const_pkg.PRIV_LIMITATION_RESULT then
        select count(1)
          into l_count
          from acm_priv_limit_field
         where i_limitation_id = priv_limit_id;
        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error     => 'PRIV_LIMIT_FIELDS_EXISTS'
            );
        end if;
    end if;

    update acm_priv_limitation_vw
       set seqnum          = io_seqnum
         , condition       = l_condition
         , limitation_type = nvl(i_limitation_type, limitation_type)
     where id        = i_limitation_id;

    com_api_i18n_pkg.add_text(
        i_table_name    => 'acm_priv_limitation'
      , i_column_name   => 'label'
      , i_object_id     => i_limitation_id
      , i_lang          => i_lang
      , i_text          => i_label
    );

end modify_limitation;

procedure remove_limitation(
    i_limitation_id     in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
)is
    l_count             com_api_type_pkg.t_count := 0;
begin
    select count(1)
      into l_count
      from acm_role_privilege
     where i_limitation_id in (limit_id, filter_limit_id);

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error => 'PRIVILEGE_LIMITATION_IN_USE'
        );
    end if;

    select count(1)
      into l_count
      from acm_priv_limit_field
     where i_limitation_id = priv_limit_id;
  
    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error     => 'PRIV_LIMIT_FIELDS_EXISTS'
        );
    end if;
    
    update acm_priv_limitation_vw
       set seqnum = i_seqnum
     where id     = i_limitation_id;

    delete from acm_priv_limitation_vw
     where id = i_limitation_id;

    com_api_i18n_pkg.remove_text(
        i_table_name    => 'acm_priv_limitation'
      , i_object_id     => i_limitation_id
    );

end remove_limitation;

procedure add_field(
    o_id             out   com_api_type_pkg.t_short_id
  , i_priv_limit_id   in   com_api_type_pkg.t_short_id
  , i_field           in   com_api_type_pkg.t_name
  , i_condition       in   com_api_type_pkg.t_full_desc
  , i_label_id        in   com_api_type_pkg.t_large_id
) is
begin
    o_id := acm_priv_limit_field_seq.nextval;

    insert into acm_priv_limit_field_vw(
        id
      , priv_limit_id
      , field
      , condition
      , label_id
    ) values (
        o_id
      , i_priv_limit_id
      , i_field
      , i_condition
      , i_label_id
    );
end add_field;

procedure modify_field(
    i_id              in   com_api_type_pkg.t_short_id
  , i_priv_limit_id   in   com_api_type_pkg.t_short_id
  , i_field           in   com_api_type_pkg.t_name
  , i_condition       in   com_api_type_pkg.t_full_desc
  , i_label_id        in   com_api_type_pkg.t_large_id
) is
begin
    update acm_priv_limit_field_vw
       set priv_limit_id = i_priv_limit_id
         , field         = i_field
         , condition     = i_condition
         , label_id      = i_label_id
     where id = i_id;
end modify_field;

procedure remove_field(
    i_id  in   com_api_type_pkg.t_short_id 
) is
begin
    delete from acm_priv_limit_field_vw
     where id = i_id;
end remove_field;

end acm_ui_limitation_pkg;
/
