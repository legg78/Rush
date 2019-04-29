create or replace package body fcl_ui_fee_pkg as

-- This parameter is calculated in the initialization section
g_instance_type                 com_api_type_pkg.t_sign;

procedure add_fee_type(
    io_fee_type         in out  com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_cycle_type        in      com_api_type_pkg.t_dict_value       default null
  , i_limit_type        in      com_api_type_pkg.t_dict_value       default null
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc        default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_need_length_type  in      com_api_type_pkg.t_boolean          default null
  , o_seqnum               out  com_api_type_pkg.t_seqnum
) is
    l_count        pls_integer;
begin
    if io_fee_type is null then
        select max(to_number(substr(fee_type, 5, 4))) + 1
          into io_fee_type
          from fcl_fee_type
         where regexp_like(fee_type, 'FETP' || g_instance_type || '\d{3}');

        io_fee_type := 'FETP' || lpad(to_char(greatest(nvl(io_fee_type, 0)
                                                     , g_instance_type * 1000 + 1)
                                            , 'TM9')
                                    , 4, '0');
    end if;

    select count(1)
      into l_count
      from fcl_fee_type_vw
     where fee_type = io_fee_type;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'FEE_TYPE_ALREADY_EXIST'
          , i_env_param1  => io_fee_type
        );
    end if;

    if i_entity_type is not null then
        com_api_dictionary_pkg.check_article('ENTT', i_entity_type);
    end if;

    if i_cycle_type is not null then
        com_api_dictionary_pkg.check_article('CYTP', i_cycle_type);

        select count(1)
          into l_count
          from fcl_fee_type_vw
         where cycle_type = i_cycle_type;

        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error       => 'CYCLE_TYPE_DEFINED_FOR_ANOTHER_FEE_TYPE'
              , i_env_param1  => i_cycle_type
            );
        end if;
    end if;

    if i_limit_type is not null then
        com_api_dictionary_pkg.check_article('LMTP', i_limit_type);

        select count(1)
          into l_count
          from fcl_fee_type_vw
         where limit_type = i_limit_type;

        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error             => 'LIMIT_TYPE_DEFINED_FOR_ANOTHER_FEE_TYPE'
              , i_env_param1        => i_limit_type
            );
        end if;
    end if;

    select count(*)
      into l_count
      from com_dictionary_vw
     where dict = 'FETP'
       and code = lpad(substr(io_fee_type, 5), 4, '0');

    if l_count = 0 then
        com_ui_dictionary_pkg.add_article(
            i_dict        => 'FETP'
          , i_code        => lpad(substr(io_fee_type, 5), 4, '0')
          , i_short_desc  => i_short_desc
          , i_full_desc   => i_full_desc
          , i_is_editable => com_api_type_pkg.TRUE
          , i_lang        => i_lang
        );
    end if;

    o_seqnum := 1;

    insert into fcl_fee_type_vw(
        id
      , seqnum
      , fee_type
      , entity_type
      , cycle_type
      , limit_type
      , need_length_type
    ) values (
        fcl_fee_type_seq.nextval
      , o_seqnum
      , io_fee_type
      , i_entity_type
      , i_cycle_type
      , i_limit_type
      , i_need_length_type
    );
end;

procedure modify_fee_type(
    i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_need_length_type  in      com_api_type_pkg.t_boolean          default null
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
) is
    l_count             pls_integer;
begin
    if i_fee_type is null then
        com_api_error_pkg.raise_error(
            i_error             => 'FEE_TYPE_NOT_DEFINED'
        );
    end if;

    select count(1)
      into l_count
      from fcl_fee_vw
     where fee_type = i_fee_type;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error             => 'FEES_FOR_FEE_TYPE_EXIST'
          , i_env_param1        => i_fee_type
        );
    end if;

    if i_entity_type is not null then
        com_api_dictionary_pkg.check_article('ENTT', i_entity_type);
    end if;

    if i_cycle_type is not null then
        com_api_dictionary_pkg.check_article('CYTP', i_cycle_type);

        select count(1)
          into l_count
          from fcl_fee_type_vw
         where cycle_type = i_cycle_type
           and fee_type != i_fee_type;

        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error             => 'CYCLE_TYPE_DEFINED_FOR_ANOTHER_FEE_TYPE'
              , i_env_param1        => i_cycle_type
            );
        end if;
    end if;

    if i_limit_type is not null then
        com_api_dictionary_pkg.check_article('LMTP', i_limit_type);

        select count(1)
          into l_count
          from fcl_fee_type_vw
         where limit_type = i_limit_type
           and fee_type != i_fee_type;

        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error             => 'LIMIT_TYPE_DEFINED_FOR_ANOTHER_FEE_TYPE'
              , i_env_param1        => i_limit_type
            );
        end if;
    end if;

    update fcl_fee_type_vw
       set entity_type      = i_entity_type
         , cycle_type       = i_cycle_type
         , limit_type       = i_limit_type
         , need_length_type = nvl(i_need_length_type, need_length_type)
         , seqnum           = io_seqnum
     where fee_type  = i_fee_type;

    io_seqnum := io_seqnum + 1;
end;

procedure remove_fee_type(
    i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
    l_count             pls_integer;
begin
    select count(1)
      into l_count
      from fcl_fee_vw
     where fee_type = i_fee_type;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error             => 'FEES_FOR_FEE_TYPE_EXIST'
          , i_env_param1        => i_fee_type
        );
    end if;

    update fcl_fee_type_vw
       set seqnum = i_seqnum
     where fee_type = i_fee_type;

    delete from fcl_fee_type_vw where fee_type = i_fee_type;

    com_ui_dictionary_pkg.remove_article(
        i_dict              => 'FETP'
      , i_code              => lpad(substr(i_fee_type, 5), 4, '0')
      , i_is_leaf           => com_api_const_pkg.TRUE
    );
end;

procedure add_fee_rate(
    i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_rate_type         in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , o_fee_rate_id          out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
) is
    l_count             com_api_type_pkg.t_tiny_id;
    l_limit_type        com_api_type_pkg.t_dict_value;
    l_limit_rate_id     com_api_type_pkg.t_tiny_id;
    l_seqnum            com_api_type_pkg.t_seqnum;
begin
    select count(*)
      into l_count
      from fcl_fee_rate_vw
     where inst_id = i_inst_id
       and fee_type = i_fee_type;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error       =>  'FEE_RATE_ALREADY_EXISTS'
          , i_env_param1  =>  i_fee_type
          , i_env_param2  =>  ost_ui_institution_pkg.get_inst_name(i_inst_id)
        );
    end if;

    select fcl_fee_rate_seq.nextval into o_fee_rate_id from dual;

    o_seqnum := 1;

    insert into fcl_fee_rate_vw(
        id
      , seqnum
      , fee_type
      , rate_type
      , inst_id
    ) values (
        o_fee_rate_id
      , o_seqnum
      , i_fee_type
      , i_rate_type
      , i_inst_id
    );

    -- check if fee has limit, then add rate type to limit type
    begin
        select limit_type
          into l_limit_type
          from fcl_fee_type
         where fee_type = i_fee_type;
        
        if l_limit_type is not null then
            fcl_ui_limit_pkg.add_limit_rate(
                i_limit_type     => l_limit_type
              , i_rate_type      => i_rate_type
              , i_inst_id        => i_inst_id
              , o_limit_rate_id  => l_limit_rate_id
              , o_seqnum         => l_seqnum
            );
        end if;
    exception
        when no_data_found then
            null;
    end;
end;

procedure get_fee_rate_param(
    i_fee_rate_id       in      com_api_type_pkg.t_tiny_id
  , o_rate_type         out     com_api_type_pkg.t_dict_value
  , o_fee_type          out     com_api_type_pkg.t_dict_value
  , o_inst_id           out     com_api_type_pkg.t_inst_id
  , o_seqnum            out     com_api_type_pkg.t_inst_id
) is
begin
    select rate_type
         , fee_type
         , inst_id
         , seqnum
      into o_rate_type
         , o_fee_type
         , o_inst_id
         , o_seqnum
      from fcl_fee_rate_vw
     where id        = i_fee_rate_id;
end;

function get_limit_rate_id(
  i_rate_type           in     com_api_type_pkg.t_dict_value
  , i_fee_type          in     com_api_type_pkg.t_dict_value
  , i_inst_id           in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_tiny_id is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_limit_rate_id: ';
    l_limit_rate_id            com_api_type_pkg.t_tiny_id;
begin
    begin
        select r.id
          into l_limit_rate_id
          from fcl_fee_type t
             , fcl_limit_rate r
         where t.limit_type = r.limit_type
           and t.fee_type = i_fee_type
           and r.rate_type  = i_rate_type
           and r.inst_id = i_inst_id;
    exception
        when no_data_found then
            l_limit_rate_id := null;
    end;

    return l_limit_rate_id;
exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with i_rate_type [#1], i_fee_type [#2], i_inst_id [#3]'
          , i_env_param1 => i_rate_type
          , i_env_param2 => i_fee_type
          , i_env_param3 => i_inst_id
        );
        raise;
end;

procedure modify_fee_rate(
    i_fee_rate_id       in      com_api_type_pkg.t_tiny_id
  , i_rate_type         in      com_api_type_pkg.t_dict_value
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
) is
    l_limit_rate_id     com_api_type_pkg.t_tiny_id;
    l_seqnum            com_api_type_pkg.t_seqnum;
    l_rate_type         com_api_type_pkg.t_dict_value;
    l_fee_type          com_api_type_pkg.t_dict_value;
    l_inst_id           com_api_type_pkg.t_inst_id;

begin
    -- update limit rate
    get_fee_rate_param(
        i_fee_rate_id       => i_fee_rate_id
      , o_rate_type         => l_rate_type
      , o_fee_type          => l_fee_type
      , o_inst_id           => l_inst_id
      , o_seqnum            => l_seqnum
    );

    l_limit_rate_id := get_limit_rate_id(
                           i_rate_type => l_rate_type
                         , i_fee_type  => l_fee_type
                         , i_inst_id   => l_inst_id
                       );
    if l_limit_rate_id is not null then
        fcl_ui_limit_pkg.modify_limit_rate(
            i_limit_rate_id     => l_limit_rate_id
          , i_rate_type         => i_rate_type
          , io_seqnum           => l_seqnum
        );
    end if;

    update fcl_fee_rate_vw
       set rate_type = i_rate_type
         , seqnum    = io_seqnum
     where id        = i_fee_rate_id;

    io_seqnum := io_seqnum + 1;
end;

procedure remove_fee_rate(
    i_fee_rate_id       in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
    l_limit_rate_id     com_api_type_pkg.t_tiny_id;
    l_rate_type         com_api_type_pkg.t_dict_value;
    l_fee_type          com_api_type_pkg.t_dict_value;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_seqnum            com_api_type_pkg.t_seqnum;
begin
    --remome limit rate
    get_fee_rate_param(
        i_fee_rate_id       => i_fee_rate_id
      , o_rate_type         => l_rate_type
      , o_fee_type          => l_fee_type
      , o_inst_id           => l_inst_id
      , o_seqnum            => l_seqnum
    );
    l_limit_rate_id := get_limit_rate_id(
                           i_rate_type => l_rate_type
                         , i_fee_type  => l_fee_type
                         , i_inst_id   => l_inst_id
                       );
    if l_limit_rate_id is not null then
        fcl_ui_limit_pkg.remove_limit_rate(
            i_limit_rate_id     => l_limit_rate_id
          , i_seqnum            => l_seqnum
        );
    end if;

    update fcl_fee_rate_vw
       set seqnum    = i_seqnum
     where id        = i_fee_rate_id;

    delete fcl_fee_rate_vw
     where id        = i_fee_rate_id;

end;

procedure add_fee (
    i_fee_type            in com_api_type_pkg.t_dict_value
    , i_currency          in com_api_type_pkg.t_curr_code
    , i_fee_rate_calc     in com_api_type_pkg.t_dict_value
    , i_fee_base_calc     in com_api_type_pkg.t_dict_value
    , i_limit_id          in com_api_type_pkg.t_long_id         default null
    , i_cycle_id          in com_api_type_pkg.t_short_id        default null
    , i_inst_id           in com_api_type_pkg.t_inst_id
    , o_fee_id            out com_api_type_pkg.t_short_id
    , o_seqnum            out com_api_type_pkg.t_seqnum
) is
    l_cycle_type        com_api_type_pkg.t_dict_value;
    l_limit_type        com_api_type_pkg.t_dict_value;
    l_cycle_type2       com_api_type_pkg.t_dict_value;
    l_limit_type2       com_api_type_pkg.t_dict_value;
begin
    if i_fee_type is null then
        com_api_error_pkg.raise_error(
            i_error             => 'FEE_TYPE_NOT_DEFINED'
        );
    end if;

    begin
        select cycle_type
             , limit_type
          into l_cycle_type
             , l_limit_type
          from fcl_fee_type_vw
         where fee_type = i_fee_type;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error             => 'FEE_TYPE_NOT_FOUND'
              , i_env_param1        => i_fee_type
            );
    end;

    if i_currency is null then
        com_api_error_pkg.raise_error(
            i_error             => 'CURRENCY_NOT_DEFINED'
        );
    end if;

    if i_fee_rate_calc is null then
        com_api_error_pkg.raise_error(
            i_error             => 'RATE_CALC_NOT_DEFINED'
        );
    else
        com_api_dictionary_pkg.check_article('FEEM', i_fee_rate_calc);
    end if;

    if i_fee_base_calc is null then
        com_api_error_pkg.raise_error(
            i_error             => 'BASE_CALC_NOT_DEFINED'
        );
    else
        com_api_dictionary_pkg.check_article('FEEB', i_fee_base_calc);
    end if;

    if l_cycle_type is not null then
        if i_cycle_id is not null then
            begin
                select cycle_type
                  into l_cycle_type2
                  from fcl_cycle_vw
                 where id = i_cycle_id;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error             => 'CYCLE_NOT_FOUND'
                      , i_env_param1        => i_cycle_id
                    );
            end;

            if l_cycle_type != l_cycle_type2 then
                com_api_error_pkg.raise_error(
                    i_error             => 'CYCLE_HAS_WRONG_TYPE_FOR_FEE'
                  , i_env_param1        => i_cycle_id
                  , i_env_param2        => l_cycle_type2
                  , i_env_param3        => l_cycle_type
                );
            end if;
        else
            com_api_error_pkg.raise_error(
                i_error             => 'CYCLE_MANDATORY_FOR_FEE'
              , i_env_param1        => i_fee_type
            );
        end if;
    elsif i_cycle_id is not null then
        com_api_error_pkg.raise_error(
            i_error             => 'CYCLE_NOT_NEEDED_FOR_FEE'
          , i_env_param1        => i_fee_type
        );
    end if;

    if l_limit_type is not null then
        if i_limit_id is not null then
            begin
                select limit_type
                  into l_limit_type2
                  from fcl_limit_vw
                 where id = i_limit_id;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error             => 'LIMIT_NOT_FOUND'
                      , i_env_param1        => i_limit_id
                    );
            end;

            if l_limit_type != l_limit_type2 then
                com_api_error_pkg.raise_error(
                    i_error             => 'LIMIT_HAS_WRONG_TYPE_FOR_FEE'
                  , i_env_param1        => i_limit_id
                  , i_env_param2        => l_limit_type2
                  , i_env_param3        => l_limit_type
                );
            end if;
        end if;
    elsif i_limit_id is not null then
        com_api_error_pkg.raise_error(
            i_error             => 'LIMIT_NOT_NEEDED_FOR_FEE'
          , i_env_param1        => i_fee_type
        );
    end if;

    if i_inst_id is null then
        com_api_error_pkg.raise_error(
            i_error             => 'INSTITUTION_NOT_DEFINED'
        );
    end if;

    select fcl_fee_seq.nextval into o_fee_id from dual;

    o_seqnum := 1;

    insert into fcl_fee_vw(
        id
      , seqnum
      , fee_type
      , currency
      , fee_rate_calc
      , fee_base_calc
      , cycle_id
      , limit_id
      , inst_id
    ) values (
        o_fee_id
      , o_seqnum
      , i_fee_type
      , i_currency
      , i_fee_rate_calc
      , i_fee_base_calc
      , i_cycle_id
      , i_limit_id
      , i_inst_id
    );
end;

procedure modify_fee(
    i_fee_id            in      com_api_type_pkg.t_short_id
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_fee_rate_calc     in      com_api_type_pkg.t_dict_value
  , i_fee_base_calc     in      com_api_type_pkg.t_dict_value
  , i_limit_id          in      com_api_type_pkg.t_long_id
  , i_cycle_id          in      com_api_type_pkg.t_short_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
) is
    l_fee_type          com_api_type_pkg.t_dict_value;
    l_cycle_type        com_api_type_pkg.t_dict_value;
    l_limit_type        com_api_type_pkg.t_dict_value;
    l_cycle_type2       com_api_type_pkg.t_dict_value;
    l_limit_type2       com_api_type_pkg.t_dict_value;
begin
    if i_fee_id is null then
        com_api_error_pkg.raise_error(
            i_error             => 'FEE_ID_NOT_DEFINED'
        );
    end if;

    begin
        select cycle_type
             , limit_type
             , b.fee_type
          into l_cycle_type
             , l_limit_type
             , l_fee_type
          from fcl_fee_type_vw a
             , fcl_fee_vw      b
         where a.fee_type = b.fee_type
           and b.id = i_fee_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error             => 'FEE_NOT_FOUND'
              , i_env_param1        => i_fee_id
            );
    end;

    if i_currency is null then
        com_api_error_pkg.raise_error(
            i_error             => 'CURRENCY_NOT_DEFINED'
        );
    end if;

    if i_fee_rate_calc is null then
        com_api_error_pkg.raise_error(
            i_error             => 'RATE_CALC_NOT_DEFINED'
        );
    else
        com_api_dictionary_pkg.check_article('FEEM', i_fee_rate_calc);
    end if;

    if i_fee_base_calc is null then
        com_api_error_pkg.raise_error(
            i_error             => 'BASE_CALC_NOT_DEFINED'
        );
    else
        com_api_dictionary_pkg.check_article('FEEB', i_fee_base_calc);
    end if;

    if l_cycle_type is not null then
        if i_cycle_id is not null then
            begin
                select cycle_type
                  into l_cycle_type2
                  from fcl_cycle_vw
                 where id = i_cycle_id;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error             => 'CYCLE_NOT_FOUND'
                      , i_env_param1        => i_cycle_id
                    );
            end;

            if l_cycle_type != l_cycle_type2 then
                com_api_error_pkg.raise_error(
                    i_error             => 'CYCLE_HAS_WRONG_TYPE_FOR_FEE'
                  , i_env_param1        => i_cycle_id
                  , i_env_param2        => l_cycle_type2
                  , i_env_param3        => l_cycle_type
                );
            end if;
        else
            com_api_error_pkg.raise_error(
                i_error             => 'CYCLE_MANDATORY_FOR_FEE'
              , i_env_param1        => l_fee_type
            );
        end if;
    elsif i_limit_id is not null then
        com_api_error_pkg.raise_error(
            i_error             => 'CYCLE_NOT_NEEDED_FOR_FEE'
          , i_env_param1        => l_fee_type
        );
    end if;

    if l_limit_type is not null then
        if i_limit_id is not null then
            begin
                select limit_type
                  into l_limit_type2
                  from fcl_limit_vw
                 where id = i_limit_id;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error             => 'LIMIT_NOT_FOUND'
                      , i_env_param1        => i_limit_id
                    );
            end;

            if l_limit_type != l_limit_type2 then
                com_api_error_pkg.raise_error(
                    i_error             => 'LIMIT_HAS_WRONG_TYPE_FOR_FEE'
                  , i_env_param1        => i_limit_id
                  , i_env_param2        => l_limit_type2
                  , i_env_param3        => l_limit_type
                );
            end if;
        end if;
    elsif i_limit_id is not null then
        com_api_error_pkg.raise_error(
            i_error             => 'LIMIT_NOT_NEEDED_FOR_FEE'
          , i_env_param1        => l_fee_type
        );
    end if;

    update fcl_fee_vw
       set currency        = i_currency
         , fee_rate_calc   = i_fee_rate_calc
         , fee_base_calc   = i_fee_base_calc
         , cycle_id        = i_cycle_id
         , limit_id        = i_limit_id
         , seqnum          = io_seqnum
     where id              = i_fee_id;

    io_seqnum := io_seqnum + 1;

end;

procedure remove_fee(
    i_fee_id            in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update fcl_fee_vw
       set seqnum = i_seqnum
     where id     = i_fee_id;

    delete from fcl_fee_tier_vw where fee_id = i_fee_id;

    delete from fcl_fee_vw where id = i_fee_id;
end;

procedure add_fee_tier(
    i_fee_id                in      com_api_type_pkg.t_short_id
  , i_fixed_rate            in      com_api_type_pkg.t_money
  , i_percent_rate          in      com_api_type_pkg.t_money
  , i_min_value             in      com_api_type_pkg.t_money
  , i_max_value             in      com_api_type_pkg.t_money
  , i_length_type           in      com_api_type_pkg.t_dict_value
  , i_sum_threshold         in      com_api_type_pkg.t_money
  , i_count_threshold       in      com_api_type_pkg.t_long_id
  , i_length_type_algorithm in      com_api_type_pkg.t_dict_value      default null
  , o_fee_tier_id           out     com_api_type_pkg.t_short_id
  , o_seqnum                out     com_api_type_pkg.t_seqnum
) is
    l_count                 pls_integer;
begin

    select fcl_fee_tier_seq.nextval into o_fee_tier_id from dual;

    o_seqnum := 1;

    insert into fcl_fee_tier_vw(
        id
      , seqnum
      , fee_id
      , fixed_rate
      , percent_rate
      , min_value
      , max_value
      , length_type
      , sum_threshold
      , count_threshold
      , length_type_algorithm
    ) values (
        o_fee_tier_id
      , o_seqnum
      , i_fee_id
      , nvl(i_fixed_rate, 0)
      , nvl(i_percent_rate, 0)
      , nvl(i_min_value, 0)
      , nvl(i_max_value, 0)
      , i_length_type
      , nvl(i_sum_threshold, 0)
      , nvl(i_count_threshold, 0)
      , i_length_type_algorithm
    );

    select count(1)
      into l_count
      from fcl_fee_tier_vw
     where fee_id = i_fee_id
       and sum_threshold = 0
       and count_threshold = 0;

    if l_count < 1 then
        com_api_error_pkg.raise_error(
            i_error             => 'FEE_MUST_HAVE_INITIAL_TIER'
        );
    end if;

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_FEE_TIER'
          , i_env_param1 => i_fee_id
          , i_env_param2 => i_sum_threshold
          , i_env_param3 => i_count_threshold
        );
end;

procedure modify_fee_tier(
    i_fee_tier_id           in      com_api_type_pkg.t_short_id
  , i_fixed_rate            in      com_api_type_pkg.t_money
  , i_percent_rate          in      com_api_type_pkg.t_money
  , i_min_value             in      com_api_type_pkg.t_money
  , i_max_value             in      com_api_type_pkg.t_money
  , i_length_type           in      com_api_type_pkg.t_dict_value
  , i_sum_threshold         in      com_api_type_pkg.t_money
  , i_count_threshold       in      com_api_type_pkg.t_long_id
  , i_length_type_algorithm in      com_api_type_pkg.t_dict_value      default null
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
) is
    l_count                 pls_integer;
    l_fee_id                com_api_type_pkg.t_short_id;
begin

    update fcl_fee_tier_vw
       set fixed_rate            = nvl(i_fixed_rate, 0)
         , percent_rate          = nvl(i_percent_rate, 0)
         , min_value             = nvl(i_min_value, 0)
         , max_value             = nvl(i_max_value, 0)
         , length_type           = i_length_type
         , sum_threshold         = nvl(i_sum_threshold, 0)
         , count_threshold       = nvl(i_count_threshold, 0)
         , seqnum                = io_seqnum
         , length_type_algorithm = i_length_type_algorithm
     where id = i_fee_tier_id
    returning fee_id into l_fee_id;

    select count(1)
      into l_count
      from fcl_fee_tier_vw
     where fee_id = l_fee_id
       and sum_threshold = 0
       and count_threshold = 0;

    if l_count < 1 then
        com_api_error_pkg.raise_error(
            i_error             => 'FEE_MUST_HAVE_INITIAL_TIER'
        );
    end if;

    io_seqnum := io_seqnum + 1;

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_FEE_TIER'
          , i_env_param1 => l_fee_id
          , i_env_param2 => i_sum_threshold
          , i_env_param3 => i_count_threshold
        );
end;

procedure remove_fee_tier(
    i_fee_tier_id       in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update fcl_fee_tier_vw
       set seqnum = i_seqnum
     where id     = i_fee_tier_id;

    delete from fcl_fee_tier_vw
     where id = i_fee_tier_id;
end;

function get_fee_desc(
    i_fee_id            in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_full_desc is

    l_result                    com_api_type_pkg.t_full_desc;
    l_currency                  com_api_type_pkg.t_curr_name;
    l_fee_rate_calc             com_api_type_pkg.t_dict_value;
    l_fee_base_calc             com_api_type_pkg.t_dict_value;
    l_sum_threshold             com_api_type_pkg.t_money;
    l_count_threshold           com_api_type_pkg.t_money;
    l_exponent                  com_api_type_pkg.t_money;
    l_format                    com_api_type_pkg.t_name;
    l_nls_numeric_characters    com_api_type_pkg.t_name := com_ui_user_env_pkg.get_nls_numeric_characters;

    function get_rate_desc (
        p_fixed_rate        in      com_api_type_pkg.t_money
      , p_percent_rate      in      com_api_type_pkg.t_money
      , p_length_type       in      com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_full_desc is
        l_rate_desc                 com_api_type_pkg.t_full_desc;
        l_format_number             com_api_type_pkg.t_name := com_api_const_pkg.get_number_f_format_with_sep;
    begin
        if l_fee_rate_calc = fcl_api_const_pkg.FEE_RATE_FIXED_VALUE then
            l_rate_desc := to_char(p_fixed_rate, l_format, l_nls_numeric_characters) || ' ' || l_currency;
        elsif l_fee_rate_calc = fcl_api_const_pkg.FEE_RATE_FLAT_PERCENTAGE then
            l_rate_desc := to_char(p_percent_rate, l_format_number, l_nls_numeric_characters) || '%';
            if p_length_type is not null then
                l_rate_desc := l_rate_desc || ' ' || com_api_dictionary_pkg.get_article_text(p_length_type);
            end if;
        elsif l_fee_rate_calc = fcl_api_const_pkg.FEE_RATE_MIN_FIXED_PERCENT then
            l_rate_desc := 'MIN(' || to_char(p_fixed_rate, l_format, l_nls_numeric_characters) || ' ' 
                                  || l_currency || ', ' || to_char(p_percent_rate, l_format_number, l_nls_numeric_characters) || '%)';
        elsif l_fee_rate_calc = fcl_api_const_pkg.FEE_RATE_MAX_FIXED_PERCENT then
            l_rate_desc := 'MAX(' || to_char(p_fixed_rate, l_format, l_nls_numeric_characters) || ' ' 
                                  || l_currency || ', ' || to_char(p_percent_rate, l_format_number, l_nls_numeric_characters) || '%)';
        elsif l_fee_rate_calc = fcl_api_const_pkg.FEE_RATE_SUM_FIXED_PERCENT then
            l_rate_desc := to_char(p_fixed_rate, l_format, l_nls_numeric_characters) || ' ' || 
                           l_currency || ' + ' || to_char(p_percent_rate, l_format_number, l_nls_numeric_characters) || '%';
        end if;

        return '['||l_rate_desc||']';
    end;

begin
    select b.name
         , a.fee_rate_calc
         , a.fee_base_calc
         , 1/power(10, b.exponent)
         , com_api_const_pkg.get_number_i_format_with_sep || case when b.exponent > 0 then 'D' || rpad('0', b.exponent, '0') else '' end
      into l_currency
         , l_fee_rate_calc
         , l_fee_base_calc
         , l_exponent
         , l_format
      from fcl_fee_vw a
         , com_ui_currency_vw b
     where a.id       = i_fee_id
       and a.currency = b.code(+)
       and rownum     = 1;

    select count(distinct sum_threshold)
         , count(distinct count_threshold)
      into l_sum_threshold
         , l_count_threshold
      from fcl_fee_tier_vw
     where fee_id = i_fee_id;

    if l_sum_threshold = 1 and l_count_threshold = 1 then
        for r in (
            select fixed_rate*l_exponent fixed_rate
                 , percent_rate
                 , length_type
              from fcl_fee_tier_vw
             where fee_id = i_fee_id
        ) loop
            l_result := get_rate_desc(r.fixed_rate, r.percent_rate, r.length_type);
            exit;
        end loop;
    elsif l_sum_threshold = 1 and l_count_threshold > 1 then
        for r in (
            select count_threshold
                 , fixed_rate*l_exponent fixed_rate
                 , percent_rate
                 , lead(count_threshold) over (order by count_threshold) next_count_threshold
                 , length_type
              from fcl_fee_tier_vw
             where fee_id = i_fee_id
             order by count_threshold
        ) loop
            if r.count_threshold = 0 then
                l_result := l_result || ' < ' || r.next_count_threshold || ': '|| get_rate_desc(r.fixed_rate, r.percent_rate, r.length_type);
            elsif r.next_count_threshold is null then
                l_result := l_result || '; >= ' || r.count_threshold || ': '|| get_rate_desc(r.fixed_rate, r.percent_rate, r.length_type);
            else
                l_result := l_result || '; '|| r.count_threshold || '-' || (r.next_count_threshold - 1) || ': '|| get_rate_desc(r.fixed_rate, r.percent_rate, r.length_type);
            end if;
        end loop;
    elsif l_sum_threshold > 1 and l_count_threshold = 1 then
        for r in (
            select sum_threshold*l_exponent sum_threshold
                 , fixed_rate*l_exponent fixed_rate
                 , percent_rate
                 , lead(sum_threshold*l_exponent) over (order by sum_threshold) next_sum_threshold
                 , length_type
              from fcl_fee_tier_vw
             where fee_id = i_fee_id
             order by sum_threshold
        ) loop
            if r.sum_threshold = 0 then
                l_result := l_result || ' < ' || to_char(r.next_sum_threshold, l_format, l_nls_numeric_characters) || ' ' || 
                            l_currency || ': '|| get_rate_desc(r.fixed_rate, r.percent_rate, r.length_type);
            elsif r.next_sum_threshold is null then
                l_result := l_result || '; >= ' || to_char(r.sum_threshold, l_format, l_nls_numeric_characters) || ' ' || 
                            l_currency || ': '|| get_rate_desc(r.fixed_rate, r.percent_rate, r.length_type);
            else
                l_result := l_result || '; '|| to_char(r.sum_threshold, l_format, l_nls_numeric_characters) || ' ' || 
                            l_currency || '-' || to_char(r.next_sum_threshold - l_exponent, l_format, l_nls_numeric_characters) || ' ' || 
                            l_currency || ': '|| get_rate_desc(r.fixed_rate, r.percent_rate, r.length_type);
            end if;
        end loop;
    else
        null;
    end if;

    return l_result;

exception
    when no_data_found then
        return null;
end;

-- Define instance's type for correct generating numeric dictionary articles
begin
    select substr(to_char(min_value), 1, 1)
      into g_instance_type
      from user_sequences
     where sequence_name = 'FCL_FEE_TYPE_SEQ';

    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '~initialization: g_instance_type [#1]'
      , i_env_param1 => g_instance_type
    );
exception
    when no_data_found then
        g_instance_type := utl_deploy_pkg.INSTANCE_TYPE_CUSTOM1;
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT)
                         || '~initialization: g_instance_type [#1] BY DEFAULT'
          , i_env_param1 => g_instance_type
        );
end;
/
