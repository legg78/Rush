create or replace package body rul_ui_algorithm_pkg is

procedure check_algorithm_parameters(
    i_proc_id               in     com_api_type_pkg.t_tiny_id
  , i_algorithm             in     com_api_type_pkg.t_dict_value
  , i_entry_point           in     com_api_type_pkg.t_dict_value
) is
    l_rule_category                com_api_type_pkg.t_dict_value;
    l_article_id                   com_api_type_pkg.t_short_id;
begin
    -- Check that incoming algorithm and entry point are dictionary articles
    l_article_id := com_api_dictionary_pkg.get_article_id(
                        i_article  => i_algorithm
                      , i_lang     => com_api_const_pkg.DEFAULT_LANGUAGE
                    );

    if i_entry_point is not null then
        l_article_id := com_api_dictionary_pkg.get_article_id(
                            i_article  => i_entry_point
                          , i_lang     => com_api_const_pkg.DEFAULT_LANGUAGE
                        );
    end if;

    begin
        select category
          into l_rule_category
          from rul_proc u
         where id = i_proc_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'PROCEDURE_IDENTIFIER_NOT_FOUND'
              , i_env_param1  => i_proc_id
            );
    end;

    if l_rule_category != rul_api_const_pkg.RULE_CATEGORY_ALGORITHM then
        com_api_error_pkg.raise_error(
            i_error       => 'PROCEDURE_INCORRECT_CATEGORY'
          , i_env_param1  => i_proc_id
          , i_env_param2  => l_rule_category
          , i_env_param3  => rul_api_const_pkg.RULE_CATEGORY_ALGORITHM
        );
    end if;
end;

procedure add(
    o_id                       out com_api_type_pkg.t_tiny_id
  , o_seqnum                   out com_api_type_pkg.t_seqnum
  , i_proc_id               in     com_api_type_pkg.t_tiny_id
  , i_algorithm             in     com_api_type_pkg.t_dict_value
  , i_entry_point           in     com_api_type_pkg.t_dict_value
) is
begin
    check_algorithm_parameters(
        i_proc_id      => i_proc_id
      , i_algorithm    => i_algorithm
      , i_entry_point  => i_entry_point
    );

    o_id     := rul_algorithm_seq.nextval;
    o_seqnum := 1;

    insert into rul_algorithm_vw(
        id
      , seqnum
      , algorithm
      , entry_point
      , proc_id
    ) values (
        o_id
      , o_seqnum
      , i_algorithm
      , i_entry_point
      , i_proc_id
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error       => 'ALGORITHM_WITH_ENTRY_POINT_IS_NOT_UNIQUE'
          , i_env_param1  => i_algorithm
          , i_env_param2  => i_entry_point
        );
end add;

procedure modify(
    i_id                    in     com_api_type_pkg.t_tiny_id
  , io_seqnum               in out com_api_type_pkg.t_seqnum
  , i_proc_id               in     com_api_type_pkg.t_tiny_id
  , i_algorithm             in     com_api_type_pkg.t_dict_value
  , i_entry_point           in     com_api_type_pkg.t_dict_value
) is
begin
    check_algorithm_parameters(
        i_proc_id      => i_proc_id
      , i_algorithm    => i_algorithm
      , i_entry_point  => i_entry_point
    );

    update rul_algorithm_vw
       set algorithm   = nvl(i_algorithm, algorithm)
         , entry_point = i_entry_point
         , proc_id     = nvl(i_proc_id, proc_id)
         , seqnum      = io_seqnum
     where id = i_id;

    io_seqnum := io_seqnum + 1;
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error       => 'ALGORITHM_WITH_ENTRY_POINT_IS_NOT_UNIQUE'
          , i_env_param1  => i_algorithm
          , i_env_param2  => i_entry_point
        );
end modify;

procedure remove(
    i_id                    in     com_api_type_pkg.t_tiny_id
) is
begin
    delete from rul_algorithm_vw
     where id = i_id;
end;

end;
/
