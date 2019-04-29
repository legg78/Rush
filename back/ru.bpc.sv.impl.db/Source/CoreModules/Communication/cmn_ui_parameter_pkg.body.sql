create or replace package body cmn_ui_parameter_pkg as

procedure check_text(
    i_object_id             in com_api_type_pkg.t_inst_id
    , i_standard_id         in com_api_type_pkg.t_inst_id
    , i_text                in com_api_type_pkg.t_name
)is
l_count                 com_api_type_pkg.t_tiny_id;

begin
    if i_object_id is null then
        select count(1)
          into l_count
          from com_i18n_vw i
             , cmn_parameter_vw c
         where i.table_name = 'CMN_PARAMETER'
           and i.column_name = 'CAPTION'
           and i.text = i_text
           and c.id = i.object_id
           and c.standard_id = i_standard_id;
    else
        select count(1)
          into l_count
          from com_i18n_vw i
             , cmn_parameter_vw c
         where i.table_name = 'CMN_PARAMETER'
           and i.column_name = 'CAPTION'
           and i.text = i_text
           and c.id = i.object_id
           and i.object_id   != i_object_id
           and c.standard_id = i_standard_id;
    end if;

    trc_log_pkg.debug (
        i_text          => 'l_count ' || l_count
    );

    if l_count > 0 then
        com_api_error_pkg.raise_error(
              i_error           => 'DUPLICATE_STANDARD_PARAMETER_NAME'
            , i_env_param1      => i_text
            , i_env_param2      => i_standard_id
        );
    end if;
end;

procedure add_parameter(
    o_param_id              out com_api_type_pkg.t_short_id
  , i_standard              in com_api_type_pkg.t_tiny_id
  , i_param_name            in com_api_type_pkg.t_name
  , i_entity_type           in com_api_type_pkg.t_dict_value
  , i_data_type             in com_api_type_pkg.t_dict_value
  , i_lov_id                in com_api_type_pkg.t_tiny_id
  , i_default_value_char    in com_api_type_pkg.t_name
  , i_default_value_num     in com_api_type_pkg.t_rate
  , i_default_value_date    in date
  , i_scale_id              in com_api_type_pkg.t_tiny_id
  , i_caption               in com_api_type_pkg.t_name
  , i_description           in com_api_type_pkg.t_full_desc
  , i_lang                  in com_api_type_pkg.t_dict_value
  , i_pattern               in com_api_type_pkg.t_short_desc
  , i_pattern_desc          in com_api_type_pkg.t_full_desc   
) is
    l_default_value         com_api_type_pkg.t_name;
begin
    check_text(
        i_object_id             => o_param_id
        , i_standard_id         => i_standard
        , i_text                => i_caption
    );

    o_param_id := com_parameter_seq.nextval;

    l_default_value := com_api_type_pkg.convert_to_char(
                           i_data_type  => i_data_type
                         , i_value_char => i_default_value_char
                         , i_value_num  => i_default_value_num
                         , i_value_date => i_default_value_date
                       );
    begin

        insert into cmn_parameter_vw(
            id
          , standard_id
          , name
          , entity_type
          , data_type
          , lov_id
          , default_value
          , scale_id
          , pattern
        ) values (
            o_param_id
          , i_standard
          , upper(i_param_name)
          , i_entity_type
          , i_data_type
          , i_lov_id
          , l_default_value
          , i_scale_id
          , i_pattern
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error         => 'STANDARD_PARAMETER_ALREADY_EXIST'
              , i_env_param1    => upper(i_param_name)
            );
    end;

    if i_caption is not null then
        com_api_i18n_pkg.add_text(
            i_table_name            => 'cmn_parameter'
          , i_column_name           => 'caption'
          , i_object_id             => o_param_id
          , i_lang                  => i_lang
          , i_text                  => i_caption
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name            => 'cmn_parameter'
          , i_column_name           => 'description'
          , i_object_id             => o_param_id
          , i_lang                  => i_lang
          , i_text                  => i_description
        );
    end if;

    if i_pattern_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name            => 'cmn_parameter'
          , i_column_name           => 'pattern_desc'
          , i_object_id             => o_param_id
          , i_lang                  => i_lang
          , i_text                  => i_pattern_desc
        );
    end if;

end;

procedure modify_parameter(
    i_param_id              in com_api_type_pkg.t_short_id
  , i_entity_type           in com_api_type_pkg.t_dict_value
  , i_data_type             in com_api_type_pkg.t_dict_value
  , i_lov_id                in com_api_type_pkg.t_tiny_id
  , i_default_value_char    in com_api_type_pkg.t_name
  , i_default_value_num     in com_api_type_pkg.t_rate
  , i_default_value_date    in date
  , i_scale_id              in com_api_type_pkg.t_tiny_id
  , i_caption               in com_api_type_pkg.t_name
  , i_description           in com_api_type_pkg.t_full_desc
  , i_lang                  in com_api_type_pkg.t_dict_value
  , i_pattern               in com_api_type_pkg.t_short_desc
  , i_pattern_desc          in com_api_type_pkg.t_full_desc   
) is
    l_default_value         com_api_type_pkg.t_name;
    l_standard_id           com_api_type_pkg.t_tiny_id;

begin

    select standard_id
      into l_standard_id
      from cmn_parameter_vw
     where id = i_param_id;

    check_text(
        i_object_id             => i_param_id
        , i_standard_id         => l_standard_id
        , i_text                => i_caption
    );

    l_default_value := com_api_type_pkg.convert_to_char(
                           i_data_type  => i_data_type
                         , i_value_char => i_default_value_char
                         , i_value_num  => i_default_value_num
                         , i_value_date => i_default_value_date
                       );

    update cmn_parameter_vw
    set
        data_type       = i_data_type
        , lov_id        = i_lov_id
        , default_value = l_default_value
        , entity_type   = i_entity_type
        , scale_id      = i_scale_id
        , pattern       = i_pattern
     where
        id              = i_param_id;

    if i_caption is not null then
        com_api_i18n_pkg.add_text(
            i_table_name            => 'cmn_parameter'
          , i_column_name           => 'caption'
          , i_object_id             => i_param_id
          , i_lang                  => i_lang
          , i_text                  => i_caption
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name            => 'cmn_parameter'
          , i_column_name           => 'description'
          , i_object_id             => i_param_id
          , i_lang                  => i_lang
          , i_text                  => i_description
        );
    end if;

    if i_pattern_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name            => 'cmn_parameter'
          , i_column_name           => 'pattern_desc'
          , i_object_id             => i_param_id
          , i_lang                  => i_lang
          , i_text                  => i_pattern_desc
        );
    end if;

end;

procedure remove_parameter(
    i_param_id          in      com_api_type_pkg.t_short_id
) is
begin
    delete from cmn_parameter_value_vw where param_id = i_param_id;

    delete from cmn_parameter_vw where id = i_param_id;

    com_api_i18n_pkg.remove_text(
            i_table_name            => 'cmn_parameter'
          , i_object_id             => i_param_id
    );

end;

end;
/


