create or replace package body svy_api_parameter_pkg as

function get_parameter_rec(
    i_param_name         in com_api_type_pkg.t_oracle_name
  , i_is_system_param    in com_api_type_pkg.t_boolean             default com_api_const_pkg.FALSE
  , i_table_name         in com_api_type_pkg.t_attr_name           default null
) return t_parameter_value is
    l_param_rec             t_parameter_value;
begin
    select id
         , seqnum
         , param_name
         , data_type
         , display_order
         , lov_id
         , is_multi_select
         , is_system_param
         , table_name
      into l_param_rec.id
         , l_param_rec.seqnum
         , l_param_rec.param_name
         , l_param_rec.data_type
         , l_param_rec.display_order
         , l_param_rec.lov_id
         , l_param_rec.is_multi_select
         , l_param_rec.is_system_param
         , l_param_rec.table_name
      from svy_parameter
     where param_name      = upper(i_param_name)
       and is_system_param = i_is_system_param
       and table_name      = nvl(upper(i_table_name), table_name);

    return l_param_rec;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'PARAM_NOT_FOUND'
          , i_env_param1    => upper(i_param_name)
        );
end get_parameter_rec;

function get_parameter_name_lang(
    i_param_name               in com_api_type_pkg.t_oracle_name
  , i_is_system_param          in com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_table_name               in com_api_type_pkg.t_attr_name     default null
  , i_lang                     in com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_name is
    l_name_lang                   com_api_type_pkg.t_name;
begin
    select com_api_i18n_pkg.get_text(
               i_table_name  => 'svy_parameter'
             , i_column_name => 'name'
             , i_object_id   => id
             , i_lang        => i_lang
           )
      into l_name_lang
      from svy_parameter
     where param_name      = upper(i_param_name)
       and is_system_param = i_is_system_param
       and table_name      = nvl(upper(i_table_name), table_name);

    return l_name_lang;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'PARAM_NOT_FOUND'
          , i_env_param1    => upper(i_param_name)
        );
end get_parameter_name_lang;

end svy_api_parameter_pkg;
/
