create or replace package body iss_api_card_pkg as
/*********************************************************
*  Issuer API - card <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 14.10.2009 <br />
*  Module: ISS_API_CARD_PKG <br />
*  @headcom
**********************************************************/

g_card_number           com_api_type_pkg.t_card_number;
g_begin_char            com_api_type_pkg.t_tiny_id;
g_end_char              com_api_type_pkg.t_tiny_id;

function check_uid_unique (
    i_card_uid        in     com_api_type_pkg.t_name
  , i_card_id         in     com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_boolean
is
    l_check_cnt             com_api_type_pkg.t_count := 0;
begin
    select count(id)
      into l_check_cnt
      from iss_card_instance i
     where i.card_id          != i_card_id
       and reverse(i.card_uid) = reverse(i_card_uid);

    trc_log_pkg.debug(i_text => 'check_uid_unique = ' || l_check_cnt);

    if l_check_cnt > 0 then
        return com_api_type_pkg.FALSE;
    else
        return com_api_type_pkg.TRUE;
    end if;
end;

procedure generate_uid (
    i_card_id         in     com_api_type_pkg.t_medium_id
    , i_inst_id       in     com_api_type_pkg.t_inst_id
    , i_service_id    in     com_api_type_pkg.t_short_id
    , i_product_id    in     com_api_type_pkg.t_short_id
    , i_split_hash    in     com_api_type_pkg.t_tiny_id
    , i_uid_format_id in     com_api_type_pkg.t_tiny_id
    , i_params        in     com_api_type_pkg.t_param_tab
    , o_card_uid      out    com_api_type_pkg.t_name
) is
    l_format_id              com_api_type_pkg.t_tiny_id;
    l_uid_prefix             com_api_type_pkg.t_name;
    l_params                 com_api_type_pkg.t_param_tab;
    MAX_GEN_TRYING  constant com_api_type_pkg.t_count := 1000;
    l_gen_trying             com_api_type_pkg.t_count := 0;
    l_ret_val                com_api_type_pkg.t_sign;
    l_text                   com_api_type_pkg.t_text;
    l_index_range_id         com_api_type_pkg.t_medium_id;
begin
    l_params    := i_params;
    l_format_id := i_uid_format_id;

    if l_format_id is null then

        l_format_id :=
            set_ui_value_pkg.get_inst_param_n(
                i_param_name => iss_api_const_pkg.UID_NAME_FORMAT
              , i_inst_id    => i_inst_id
            );

        trc_log_pkg.debug(i_text => 'l_format_id for uid = ' || l_format_id);
    end if;

    if l_format_id is null then

        o_card_uid := i_card_id;

    else
        -- Need to generate UID
        l_uid_prefix :=
            prd_api_product_pkg.get_attr_value_char(
                i_product_id        => i_product_id
              , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id         => i_card_id
              , i_attr_name         => iss_api_const_pkg.ATTR_UID_PREFIX
              , i_split_hash        => i_split_hash
              , i_service_id        => i_service_id
              , i_params            => l_params
              , i_inst_id           => i_inst_id
              , i_use_default_value => com_api_const_pkg.TRUE
              , i_default_value     => null
            );

        rul_api_param_pkg.set_param (
            io_params     => l_params
          , i_name        => 'UID_PREFIX'
          , i_value       => l_uid_prefix
        );

        -- set index range
        select min(index_range_id)
          into l_index_range_id
          from rul_name_format
         where id = l_format_id;

        rul_api_param_pkg.set_param (
            io_params     => l_params
          , i_name        => 'INDEX'
          , i_value       => l_index_range_id
        );

        loop
            l_text := rul_api_name_pkg.get_name(
                i_format_id           => l_format_id
              , i_param_tab           => l_params
              , i_double_check_value  => o_card_uid
            );

            o_card_uid := l_text;
            trc_log_pkg.debug(i_text => 'o_card_uid = ' || o_card_uid);

            if com_api_lock_pkg.request_lock(
                   i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                 , i_object_key  => o_card_uid
               ) = 0
            then
                if check_uid_unique(
                       i_card_uid  => o_card_uid
                     , i_card_id   => i_card_id
                   ) = com_api_type_pkg.TRUE
                then
                    exit;
                else
                    trc_log_pkg.debug(i_text => 'check_uid_unique is not Ok');

                    l_ret_val    := com_api_lock_pkg.release_lock(
                                        i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                                      , i_object_key  => o_card_uid
                                    );
                    l_gen_trying := l_gen_trying + 1;
                end if;

            else
                l_gen_trying := l_gen_trying + 1;
            end if;

            if l_gen_trying > MAX_GEN_TRYING then
                com_api_error_pkg.raise_error(
                    i_error       => 'UNABLE_GENERATE_CARD_UID'
                  , i_env_param1  => MAX_GEN_TRYING
                );
            end if;
        end loop;
    end if;

    trc_log_pkg.debug(i_text => 'generated uid = ' || o_card_uid);
end;

function get_card_number
    return com_api_type_pkg.t_card_number
is
begin
    return g_card_number;
end;

procedure set_card_number(
    i_card_number       in com_api_type_pkg.t_card_number
) is
begin
    g_card_number := i_card_number;
end;

function get_card_number (
    i_card_id           in com_api_type_pkg.t_medium_id
  , i_inst_id           in com_api_type_pkg.t_inst_id        default null
  , i_mask_error        in com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_card_number is
begin
    return get_card(
               i_card_id    => i_card_id
             , i_inst_id    => i_inst_id
             , i_mask_error => i_mask_error
           ).card_number;
end;

function get_card (
    i_card_number       in com_api_type_pkg.t_card_number
  , i_inst_id           in com_api_type_pkg.t_inst_id        default null
  , i_mask_error        in com_api_type_pkg.t_boolean        := com_api_const_pkg.TRUE
) return iss_api_type_pkg.t_card_rec is
    l_result            iss_api_type_pkg.t_card_rec;
    l_card_number       com_api_type_pkg.t_card_number;
    l_card_hash         com_api_type_pkg.t_long_id;
begin
    -- For correct usage of the index we should use during the search a value that is stored in the table iss_card_number
    l_card_number := iss_api_token_pkg.encode_card_number(i_card_number => i_card_number);
    l_card_hash   := com_api_hash_pkg.get_card_hash(i_card_number);

    select c.id
         , c.split_hash
         , c.card_hash
         , c.card_mask
         , c.inst_id
         , c.card_type_id
         , c.country
         , c.customer_id
         , c.cardholder_id
         , c.contract_id
         , c.reg_date
         , c.category
         , i_card_number
      into l_result
      from iss_card c
         , iss_card_number cn
     where c.id                    = cn.card_id
       and c.card_hash             = l_card_hash
       and reverse(cn.card_number) = reverse(l_card_number)
       and (c.inst_id              = i_inst_id or i_inst_id is null);

    return l_result;
exception
    when no_data_found then
        if i_mask_error = com_api_const_pkg.TRUE then
            return null;
        else
            com_api_error_pkg.raise_error (
                i_error       => 'CARD_NOT_FOUND'
              , i_env_param1  => get_card_mask(i_card_number)
              , i_env_param2  => i_inst_id
            );
        end if;
end get_card; -- by i_card_number

function get_card (
    i_card_id           in com_api_type_pkg.t_medium_id
  , i_inst_id           in com_api_type_pkg.t_inst_id       default null
  , i_mask_error        in com_api_type_pkg.t_boolean       := com_api_const_pkg.TRUE
) return iss_api_type_pkg.t_card_rec is
    l_result            iss_api_type_pkg.t_card_rec;
begin
    select c.id
         , c.split_hash
         , c.card_hash
         , c.card_mask
         , c.inst_id
         , c.card_type_id
         , c.country
         , c.customer_id
         , c.cardholder_id
         , c.contract_id
         , c.reg_date
         , c.category
         , iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number
      into l_result
      from iss_card c
         , iss_card_number cn
     where cn.card_id = c.id
       and c.id       = i_card_id
       and (c.inst_id = i_inst_id or i_inst_id is null);

    return l_result;
exception
    when no_data_found then
        if i_mask_error = com_api_const_pkg.TRUE then
            return null;
        else
            com_api_error_pkg.raise_error (
                i_error       => 'CARD_NOT_FOUND'
              , i_env_param1  => i_card_id
              , i_env_param2  => i_inst_id
            );
        end if;
end get_card; -- by i_card_id

/*
 * Function returns undecoded card number. It should be used to prevent
 * useless sequential decoding and encoding of card number with enabled
 * tokenization. For example, if card number is requested by its identifier
 * card_id for successive saving in a table.
 */
function get_raw_card_number (
    i_card_id               in     com_api_type_pkg.t_medium_id
  , i_split_hash            in     com_api_type_pkg.t_tiny_id       default null
) return com_api_type_pkg.t_card_number
is
    l_result                com_api_type_pkg.t_card_number;
begin
    select cn.card_number -- undecoded with tokenizator card number
      into l_result
      from iss_card c
      join iss_card_number cn on cn.card_id = c.id
     where c.id = i_card_id
       and (i_split_hash is null or c.split_hash = i_split_hash);

    return l_result;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'CARD_NOT_FOUND'
          , i_env_param1 => i_card_id
        );
end get_raw_card_number;

/*
 * Function searches and returns a card by <i_card_id> if it isn't NULL (<i_card_number> is ignored in this case),
 * otherwise it use <i_card_number> to locate a card.
 * Exception CARD_NOT_FOUND is raised when searching is failed and <i_mask_error> is FALSE.
 */
function get_card (
    i_card_id           in com_api_type_pkg.t_medium_id
  , i_card_number       in com_api_type_pkg.t_card_number
  , i_inst_id           in com_api_type_pkg.t_inst_id           default null
  , i_mask_error        in com_api_type_pkg.t_boolean           default com_api_const_pkg.TRUE
) return iss_api_type_pkg.t_card_rec
is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_card[3th]: ';
    l_card_rec          iss_api_type_pkg.t_card_rec;
begin
    if i_card_id is null and i_card_number is null then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error       => 'CARD_NOT_FOUND'
              , i_env_param1  => i_inst_id
            );
        end if;
    elsif i_card_id is not null then
        if i_card_number is not null then
            trc_log_pkg.debug(LOG_PREFIX || 'i_card_number will be ignored because i_card_id is defined');
        end if;
        l_card_rec := get_card(
                          i_card_id     => i_card_id
                        , i_inst_id     => i_inst_id
                        , i_mask_error  => i_mask_error
                      );
    else
        l_card_rec := get_card(
                          i_card_number => i_card_number
                        , i_inst_id     => i_inst_id
                        , i_mask_error  => i_mask_error
                      );
    end if;

    return l_card_rec;

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX 
                         || 'i_card_id [' || i_card_id
                         || '], i_card_number  [' || get_card_mask(i_card_number) 
                         || '], i_inst_id  [' || i_inst_id
                         || '], i_mask_error [' || i_mask_error || ']'
        );
        raise;
end get_card; -- by i_card_id and i_card_number

function get_card_id(
    i_card_number       in      com_api_type_pkg.t_card_number
  , i_inst_id           in      com_api_type_pkg.t_inst_id           default null
) return com_api_type_pkg.t_medium_id is
begin
    return get_card(
               i_card_number => i_card_number
             , i_inst_id     => i_inst_id
           ).id;
end;

function get_card_id_by_uid(
    i_card_uid          in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id    default null
) return com_api_type_pkg.t_medium_id is
    l_result        com_api_type_pkg.t_medium_id;
begin
    -- The function min has been used because one card can have the several instances with same card_uid
    select first_value(i.card_id) over (partition by i.card_uid order by i.card_id)
      into l_result
      from iss_card_instance i
     where reverse(i.card_uid) = reverse(i_card_uid)
       and (i.inst_id = i_inst_id or i_inst_id is null)
       and rownum = 1;

    return l_result;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'INSTANCE_NOT_FOUND'
          , i_env_param1 => i_card_uid
        );
end;

function get_card_uid_by_id(
    i_card_id          in      com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_name is
    l_result           com_api_type_pkg.t_name;
begin
    select first_value(card_uid) over (partition by card_id order by card_uid)
      into l_result
      from iss_card_instance
     where card_id = i_card_id
       and rownum = 1;

    return l_result;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'INSTANCE_NOT_FOUND'
          , i_env_param1 => i_card_id
        );
end;

function get_customer_id (
    i_card_number           in com_api_type_pkg.t_card_number
  , i_inst_id               in com_api_type_pkg.t_inst_id       default null
) return com_api_type_pkg.t_medium_id is
begin
    return get_card(
               i_card_number => i_card_number
             , i_inst_id     => i_inst_id
           ).customer_id;
end;

function get_customer_id (
    i_card_id               in com_api_type_pkg.t_medium_id
  , i_inst_id               in com_api_type_pkg.t_inst_id       default null
) return com_api_type_pkg.t_medium_id is
begin
    return get_card(
               i_card_id  => i_card_id
             , i_inst_id  => i_inst_id
           ).customer_id;
end get_customer_id;

procedure get_card (
    i_card_number         in     com_api_type_pkg.t_card_number
  , i_inst_id             in     com_api_type_pkg.t_inst_id      default null
  , io_seq_number         in out com_api_type_pkg.t_tiny_id
  , io_expir_date         in out date
  , o_card_id                out com_api_type_pkg.t_medium_id
  , o_card_type_id           out com_api_type_pkg.t_tiny_id
  , o_card_country           out com_api_type_pkg.t_curr_code
  , o_card_inst_id           out com_api_type_pkg.t_tiny_id
  , o_card_network_id        out com_api_type_pkg.t_tiny_id
  , o_split_hash             out com_api_type_pkg.t_tiny_id
) is
    l_card_number           com_api_type_pkg.t_card_number;
    l_card_hash             com_api_type_pkg.t_long_id;
begin
    -- For correct usage of the index we should use during the search a value that is stored in the table iss_card_number
    l_card_number := iss_api_token_pkg.encode_card_number(i_card_number => i_card_number);
    l_card_hash   := com_api_hash_pkg.get_card_hash(i_card_number);

    if io_seq_number is null and io_expir_date is null then
        select *
          into o_card_id
             , o_card_type_id
             , o_card_country
             , o_card_inst_id
             , o_card_network_id
             , o_split_hash
             , io_expir_date
             , io_seq_number
          from (
              select c.id
                   , c.card_type_id
                   , c.country
                   , c.inst_id
                   , t.network_id
                   , c.split_hash
                   , i.expir_date
                   , i.seq_number
                from iss_card c
                   , iss_card_number cn
                   , net_card_type t
                   , iss_card_instance i
               where c.card_hash             = l_card_hash
                 and reverse(cn.card_number) = reverse(l_card_number)
                 and t.id                    = c.card_type_id
                 and i.card_id               = c.id
                 and cn.card_id              = c.id
                 and (c.inst_id              = i_inst_id or i_inst_id is null)
               order by i.seq_number desc
          )
         where rownum = 1;
    else
        select c.id
             , c.card_type_id
             , c.country
             , c.inst_id
             , t.network_id
             , c.split_hash
             , i.expir_date
             , i.seq_number
          into o_card_id
             , o_card_type_id
             , o_card_country
             , o_card_inst_id
             , o_card_network_id
             , o_split_hash
             , io_expir_date
             , io_seq_number
          from iss_card c
             , iss_card_number cn
             , net_card_type t
             , iss_card_instance i
         where c.card_hash             = l_card_hash
           and reverse(cn.card_number) = reverse(l_card_number)
           and t.id                    = c.card_type_id
           and i.card_id               = c.id
           and cn.card_id              = c.id
           and trunc(i.expir_date)     = trunc(nvl(io_expir_date, i.expir_date))
           and i.seq_number            = nvl(io_seq_number, i.seq_number)
           and (c.inst_id              = i_inst_id or i_inst_id is null);
    end if;
exception
    when no_data_found then
        o_card_id := null;
end;

function check_card_number_unique (
    i_card_number           in com_api_type_pkg.t_card_number
  , i_inst_id               in com_api_type_pkg.t_inst_id       default null
  , i_card_hash             in com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean is
    l_check_cnt             com_api_type_pkg.t_count := 0;
    l_card_number           com_api_type_pkg.t_card_number;
begin
    -- For correct usage of the index we should use during the search a value that is stored in the table iss_card_number
    l_card_number := iss_api_token_pkg.encode_card_number(i_card_number => i_card_number);

    select count(id)
      into l_check_cnt
      from iss_card c
         , iss_card_number cn
     where c.card_hash             = i_card_hash
       and cn.card_id              = c.id
       and reverse(cn.card_number) = reverse(l_card_number)
       and (c.inst_id              = i_inst_id or i_inst_id is null);

    if l_check_cnt > 0 then
        return com_api_type_pkg.TRUE;
    else
        return com_api_type_pkg.FALSE;
    end if;
end;

procedure generate_card_number (
    i_format_id      in      com_api_type_pkg.t_tiny_id
    , i_params       in      com_api_type_pkg.t_param_tab
    , i_inst_id      in      com_api_type_pkg.t_inst_id
    , i_customer_id  in      com_api_type_pkg.t_medium_id
    , o_card_number     out  com_api_type_pkg.t_card_number
    , o_card_hash       out  com_api_type_pkg.t_long_id
    , o_card_mask       out  com_api_type_pkg.t_card_number
) is
    MAX_GEN_TRYING  constant com_api_type_pkg.t_count := 1000;
    l_gen_trying             com_api_type_pkg.t_count := 0;
    l_ret_val                com_api_type_pkg.t_sign;
    l_text                   com_api_type_pkg.t_text;
begin
    loop
        l_text := rul_api_name_pkg.get_name (
            i_format_id           => i_format_id
          , i_param_tab           => i_params
          , i_double_check_value  => o_card_number
        );

        begin
            o_card_number := l_text;
        exception
            when value_error then
                com_api_error_pkg.raise_error(
                    i_error      => 'CARD_NUMBER_TOO_LONG'
                  , i_env_param1 => length(l_text)
                  , i_env_param2 => iss_api_const_pkg.MAX_CARD_NUMBER_LENGTH
                  , i_env_param3 => i_format_id
                );
        end;

        if com_api_lock_pkg.request_lock(
               i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
             , i_object_key  => iss_api_token_pkg.encode_card_number(i_card_number => o_card_number)
           ) = 0
        then
            o_card_hash := com_api_hash_pkg.get_card_hash(o_card_number);
            o_card_mask := get_card_mask(o_card_number);

            if  check_card_number_unique(
                    i_card_number     => o_card_number
                  , i_card_hash       => o_card_hash
                ) = com_api_type_pkg.FALSE
            then
                exit;
            else
                l_ret_val    := com_api_lock_pkg.release_lock(
                                    i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                                  , i_object_key  => iss_api_token_pkg.encode_card_number(i_card_number => o_card_number)
                                );
                l_gen_trying := l_gen_trying + 1;
            end if;

        else
            l_gen_trying := l_gen_trying + 1;
        end if;

        if l_gen_trying > MAX_GEN_TRYING then
            com_api_error_pkg.raise_error(
                i_error       => 'UNABLE_GENERATE_CARD_NUMBER'
              , i_env_param1  => MAX_GEN_TRYING
            );
        end if;
    end loop;
end;

procedure check_card_number(
    i_format_id    in      com_api_type_pkg.t_tiny_id
  , i_params       in      com_api_type_pkg.t_param_tab
  , i_inst_id      in      com_api_type_pkg.t_inst_id
  , i_customer_id  in      com_api_type_pkg.t_medium_id
  , i_card_number  in      com_api_type_pkg.t_card_number
  , o_card_hash       out  com_api_type_pkg.t_long_id
  , o_card_mask       out  com_api_type_pkg.t_card_number
) is
    l_ret_val               com_api_type_pkg.t_sign;
    l_count                 com_api_type_pkg.t_count := 0;
    l_card_number           com_api_type_pkg.t_card_number;
begin
    if rul_api_name_pkg.check_name(
           i_format_id   => i_format_id
         , i_name        => i_card_number
         , i_param_tab   => i_params
         , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
       ) = com_api_const_pkg.TRUE
    then
        null;
    else
        com_api_error_pkg.raise_error(
            i_error       => 'ENTITY_NAME_DONT_FIT_FORMAT'
          , i_env_param1  => i_inst_id
          , i_env_param2  => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_env_param3  => get_card_mask(i_card_number)
          , i_env_param4  => i_format_id
        );
    end if;

    l_ret_val := com_api_lock_pkg.request_lock(
                     i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                   , i_object_key  => iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
                 );

    if l_ret_val = 0 then
        o_card_hash := com_api_hash_pkg.get_card_hash(i_card_number);
        o_card_mask := get_card_mask(i_card_number);

        if  check_card_number_unique(
                i_card_number     => i_card_number
              , i_card_hash       => o_card_hash
            ) = com_api_type_pkg.TRUE
        then
            l_ret_val := com_api_lock_pkg.release_lock(
                             i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                           , i_object_key  => iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
                         );

            -- Card number [#1] violates uniqueness constraint for institution [#2] and customer [#3]
            com_api_error_pkg.raise_error(
                i_error       => 'CARD_NUMBER_NOT_UNIQUE'
              , i_env_param1  => get_card_mask(i_card_number)
              , i_env_param2  => i_inst_id
              , i_env_param3  => i_customer_id
            );
        end if;

        -- Check blacklist,
        -- for correct usage of the index we should use during the search
        -- a value that is stored in the table iss_black_list
        l_card_number := iss_api_token_pkg.encode_card_number(i_card_number => i_card_number);

        select count(a.id)
          into l_count
          from iss_black_list a
         where a.card_number = l_card_number;

        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error      => 'CARD_IN_BLACK_LIST'
              , i_env_param1 => o_card_mask
            );
        end if;

    else
        trc_log_pkg.debug(
            i_text       => 'check_card_number: request_lock() failed with l_ret_val [' || l_ret_val || ']'
        );

        com_api_error_pkg.raise_error(
            i_error      => 'UNABLE_LOCK_OBJECT'
          , i_env_param1 => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_env_param2 => get_card_mask(i_card_number)
        );
    end if;
end check_card_number;

function get_expir_date(
    i_contract_id            in com_api_type_pkg.t_medium_id
    , i_card_id              in com_api_type_pkg.t_medium_id
    , i_start_date           in date
    , i_service_id           in com_api_type_pkg.t_short_id
    , i_params               in com_api_type_pkg.t_param_tab
    , i_cycle_type           in com_api_type_pkg.t_dict_value   default   iss_api_const_pkg.CYCLE_EXPIRATION_DATE
) return date
is
    l_cycle_id               com_api_type_pkg.t_short_id;
    l_product_id             com_api_type_pkg.t_short_id;
    l_inst_id                com_api_type_pkg.t_inst_id;
    l_custom_expir_date      date;
    l_cycle_type             com_api_type_pkg.t_dict_value;
begin
    l_custom_expir_date :=
        iss_cst_card_pkg.get_expir_date(
            i_contract_id  => i_contract_id
          , i_card_id      => i_card_id
          , i_start_date   => i_start_date
          , i_service_id   => i_service_id
          , i_params       => i_params
        );
    if l_custom_expir_date is not null then
        return l_custom_expir_date;
    end if;

    if is_merchant_card(i_service_id => i_service_id) = com_api_const_pkg.TRUE then
        l_cycle_type := iss_api_const_pkg.CYCLE_MERCH_CARD_EXPIR_DATE;
    else
        l_cycle_type := i_cycle_type;
    end if;

    trc_log_pkg.debug('i_service_id = ' || i_service_id || ', l_cycle_type = ' || l_cycle_type);

    begin
        select product_id
             , inst_id
          into l_product_id
             , l_inst_id
          from prd_contract
         where id = i_contract_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'CONTRACT_NOT_FOUND'
              , i_env_param1  => i_contract_id
            );
    end;

    l_cycle_id :=
        prd_api_product_pkg.get_cycle_id(
            i_product_id      => l_product_id
          , i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id       => i_card_id
          , i_cycle_type      => l_cycle_type
          , i_params          => i_params
          , i_eff_date        => com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id)
          , i_service_id      => i_service_id
          , i_inst_id         => l_inst_id
        );
    trc_log_pkg.debug('found l_cycle_id=' || l_cycle_id);

    return
        fcl_api_cycle_pkg.calc_next_date(
            i_cycle_id     => l_cycle_id
          , i_start_date   => i_start_date
          , i_raise_error  => com_api_type_pkg.TRUE
        );
end;

function get_start_date(
    i_card_id       in  com_api_type_pkg.t_medium_id
  , i_eff_date      in  date
  , i_cycle_type    in  com_api_type_pkg.t_dict_value   default   iss_api_const_pkg.CYCLE_DELAY_START_DATE
  , i_inst_id       in  com_api_type_pkg.t_inst_id
  
) return date
is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_start_date: ';
    
    l_split_hash    com_api_type_pkg.t_tiny_id;
begin
    l_split_hash := 
        com_api_hash_pkg.get_split_hash(
            i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id   => i_card_id
          , i_mask_error  => com_api_const_pkg.FALSE
        );
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Start with params: card_id [#1], eff_date [#2], cycle_type [#3], inst_id [#4], split_has [#5]'
      , i_env_param1 => i_card_id
      , i_env_param2 => i_eff_date
      , i_env_param3 => i_cycle_type
      , i_env_param4 => i_inst_id
      , i_env_param5 => l_split_hash
    );
    return 
        fcl_api_cycle_pkg.calc_next_date(
            i_cycle_type        => i_cycle_type
          , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id         => i_card_id
          , i_split_hash        => l_split_hash
          , i_start_date        => i_eff_date
          , i_eff_date          => i_eff_date
          , i_inst_id           => i_inst_id
          , i_raise_error       => com_api_type_pkg.FALSE
        );

end get_start_date;

procedure remove_reissue_cycle(
    i_card_instance_id          in      com_api_type_pkg.t_long_id
  , i_split_hash                in      com_api_type_pkg.t_tiny_id
) is
begin
    fcl_api_cycle_pkg.remove_cycle_counter(
        i_cycle_type        => iss_api_const_pkg.CYCLE_AUTO_REISSUE
      , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
      , i_object_id         => i_card_instance_id
      , i_split_hash        => i_split_hash
    );
end;

procedure check_bin(
    i_card_number          in    com_api_type_pkg.t_card_number
    , i_product_id         in    com_api_type_pkg.t_short_id
    , i_inst_id            in    com_api_type_pkg.t_inst_id
) is
    l_bin_rec                iss_api_type_pkg.t_bin_rec;
begin
    l_bin_rec := iss_api_bin_pkg.get_bin(
        i_card_number => i_card_number
      , i_inst_id     => i_inst_id
    );

    select bin_id
      into l_bin_rec.id
      from iss_product_card_type
     where product_id = i_product_id
       and bin_id     = l_bin_rec.id
       and rownum     = 1;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error           => 'UNDEFINED_BIN_FOR_PRODUCT'
          , i_env_param1      => l_bin_rec.bin
          , i_env_param2      => i_product_id
          , i_env_param3      => get_card_mask(i_card_number)
          , i_env_param4      => sqlerrm
        );
end;

procedure create_card(
    o_id                               out com_api_type_pkg.t_medium_id
  , io_card_number                  in out com_api_type_pkg.t_card_number
  , o_card_instance_id                 out com_api_type_pkg.t_medium_id
  , i_inst_id                       in     com_api_type_pkg.t_inst_id
  , i_agent_id                      in     com_api_type_pkg.t_agent_id
  , i_contract_id                   in     com_api_type_pkg.t_medium_id
  , i_cardholder_id                 in     com_api_type_pkg.t_long_id
  , i_card_type_id                  in     com_api_type_pkg.t_tiny_id
  , i_customer_id                   in     com_api_type_pkg.t_long_id
  , i_category                      in     com_api_type_pkg.t_dict_value
  , i_start_date                    in     date
  , io_expir_date                   in out date
  , i_cardholder_name               in     com_api_type_pkg.t_name
  , i_company_name                  in     com_api_type_pkg.t_name
  , i_perso_priority                in     com_api_type_pkg.t_dict_value
  , i_pvv                           in     number := null
  , i_pin_block                     in     com_api_type_pkg.t_name := null
  , i_service_id                    in     com_api_type_pkg.t_short_id := null
  , i_icc_instance_id               in     com_api_type_pkg.t_medium_id := null
  , i_delivery_channel              in     com_api_type_pkg.t_dict_value    default null
  , i_blank_type_id                 in     com_api_type_pkg.t_tiny_id       default null
  , i_seq_number                    in     com_api_type_pkg.t_tiny_id       default null
  , i_status                        in     com_api_type_pkg.t_dict_value    default null
  , i_state                         in     com_api_type_pkg.t_dict_value    default null
  , i_iss_date                      in     date                             default null
  , i_preceding_instance_id         in     com_api_type_pkg.t_medium_id     default null
  , i_reissue_reason                in     com_api_type_pkg.t_dict_value    default null
  , i_reissue_date                  in     date                             default null
  , i_pin_request                   in     com_api_type_pkg.t_dict_value    default null
  , i_embossing_request             in     com_api_type_pkg.t_dict_value    default null
  , i_delivery_status               in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_surname              in     com_api_type_pkg.t_name          default null
  , i_embossed_first_name           in     com_api_type_pkg.t_name          default null
  , i_embossed_second_name          in     com_api_type_pkg.t_name          default null
  , i_embossed_title                in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_line_additional      in     com_api_type_pkg.t_name          default null
  , i_supplementary_info_1          in     com_api_type_pkg.t_name          default null
  , i_cardholder_photo_file_name    in     iss_api_type_pkg.t_file_name     default null
  , i_cardholder_sign_file_name     in     iss_api_type_pkg.t_file_name     default null
  , i_pin_mailer_request            in     com_api_type_pkg.t_dict_value    default null
  , i_card_uid                      in     com_api_type_pkg.t_name          default null
  , i_reissue_command               in     com_api_type_pkg.t_dict_value    default null
  , i_need_postponed_event          in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , io_postponed_event_tab          in out nocopy evt_api_type_pkg.t_postponed_event_tab
) is
    LOG_PREFIX     constant com_api_type_pkg.t_oracle_name := lower($$PLSQL_UNIT) || '.create_card';
    l_params                com_api_type_pkg.t_param_tab;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_card_hash             com_api_type_pkg.t_long_id;
    l_card_mask             com_api_type_pkg.t_card_number;
    l_state                 com_api_type_pkg.t_dict_value;
    l_pin_request           com_api_type_pkg.t_dict_value;
    l_pin_mailer_request    com_api_type_pkg.t_dict_value;
    l_embossing_request     com_api_type_pkg.t_dict_value;
    l_card_type             iss_api_type_pkg.t_product_card_type_rec;
    l_bin                   iss_api_type_pkg.t_bin_rec;
    l_iss_date              date;
    l_start_date            date;
    l_cardholder_name       com_api_type_pkg.t_name;
    l_company_name          com_api_type_pkg.t_name;
    l_perso_priority        com_api_type_pkg.t_dict_value;
    l_category              com_api_type_pkg.t_dict_value;
    l_object_id             com_api_type_pkg.t_long_id;
    l_entity_type           com_api_type_pkg.t_dict_value;
    l_card_instance         iss_api_type_pkg.t_card_instance;
    l_agent_number          com_api_type_pkg.t_name;
    l_product_number        com_api_type_pkg.t_name;
    l_uid_params            com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX 
                     || ' START: io_card_number [' || get_card_mask(io_card_number)
                     || '], i_inst_id [' || i_inst_id 
                     || '], i_agent_id [' || i_agent_id
                     || '], i_customer_id [' || i_customer_id 
                     || '], i_contract_id [' || i_contract_id
                     || '], i_card_type_id [' || i_card_type_id 
                     || '], i_cardholder_id [' || i_cardholder_id
                     || '], i_category [#1], i_start_date [#2], io_expir_date [#3], '
                     || 'i_perso_priority [#4], i_status [#5], i_state [#5]'
      , i_env_param1 => i_category
      , i_env_param2 => i_start_date
      , i_env_param3 => io_expir_date
      , i_env_param4 => i_perso_priority
      , i_env_param5 => i_status
      , i_env_param6 => i_state
    );

    ost_api_institution_pkg.check_status(
        i_inst_id     => i_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_CREATE
    );   

    savepoint sp_create_card;

    -- Before creating a new card (and its instance) it is necessary to change status of
    -- preceding card's instance by using i_reissue_reason to determine new status itself
    if i_preceding_instance_id is not null and i_reissue_reason is not null then
        evt_api_status_pkg.change_status(
            i_event_type     => i_reissue_reason
          , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id      => i_preceding_instance_id
          , i_reason         => null
          , i_params         => l_params
          , i_raise_error    => com_api_const_pkg.FALSE
        );
    end if;

    l_card_type := iss_api_product_pkg.get_product_card_type(
                       i_contract_id  => i_contract_id
                     , i_card_type_id => i_card_type_id
                     , i_service_id   => i_service_id
                   );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ': i_service_id [' || i_service_id || ']; '
                     || 'defined by contract''s product parameters are in l_card_type: '
                     ||    'service_id [' || l_card_type.service_id
                     || '], bin_id [' || l_card_type.bin_id
                     || '], number_format_id [' || l_card_type.number_format_id || ']'
                     || '], seq_number_low [' || l_card_type.seq_number_low || ']'
                     || '], blank_type_id [' || l_card_type.blank_type_id || ']'
                     || '], perso_method_id [' || l_card_type.perso_method_id
                     || '], status [#1], state [#2], pin_request [#3]'
                     ||  ', embossing_request [#4], pin_mailer_request [#5], perso_priority [#6]'
                     ||  ', i_cardholder_photo_file_name [' || i_cardholder_photo_file_name
                     || '], i_cardholder_sign_file_name [' || i_cardholder_sign_file_name
                     || '], i_pin_mailer_request [' || i_pin_mailer_request || ']'
      , i_env_param1 => l_card_type.status
      , i_env_param2 => l_card_type.state
      , i_env_param3 => l_card_type.pin_request
      , i_env_param4 => l_card_type.embossing_request
      , i_env_param5 => l_card_type.pin_mailer_request
      , i_env_param6 => l_card_type.perso_priority
    );

    if nvl(i_service_id, nvl(l_card_type.service_id, 0)) != nvl(l_card_type.service_id, 0) then
        com_api_error_pkg.raise_error (
            i_error       => 'SERVICE_PARAM_NOT_EQUAL'
          , i_env_param1  => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_env_param2  => i_service_id
          , i_env_param3  => l_card_type.service_id
          , i_env_param4  => i_contract_id
        );
    end if;

    l_bin := iss_api_bin_pkg.get_bin(i_bin_id => l_card_type.bin_id);

    o_id := iss_card_seq.nextval;
    -- Set name parameters
    rul_api_param_pkg.set_param (
        io_params     => l_params
      , i_name        => 'BIN'
      , i_value       => l_bin.bin
    );
    rul_api_param_pkg.set_param (
        io_params     => l_params
      , i_name        => 'INDEX'
      , i_value       => l_card_type.index_range_id
    );
    rul_api_param_pkg.set_param (
        io_params     => l_params
      , i_name        => 'INST_ID_CHAR'
      , i_value       => i_inst_id
    );
    rul_api_param_pkg.set_param (
        io_params     => l_params
      , i_name        => 'CARD_ID'
      , i_value       => o_id
    );

    l_agent_number := ost_ui_agent_pkg.get_agent_number(i_agent_id => i_agent_id);

    rul_api_param_pkg.set_param (
        io_params     => l_params
      , i_name        => 'AGENT_NUMBER'
      , i_value       => l_agent_number
    );

    l_product_number := prd_api_product_pkg.get_product_number(i_product_id => l_card_type.product_id);

    rul_api_param_pkg.set_param (
        io_params     => l_params
      , i_name        => 'PRODUCT_NUMBER'
      , i_value       => l_product_number
    );
    rul_api_param_pkg.set_param (
        io_params     => l_params
      , i_name        => 'CONTRACT_ID'
      , i_value       => i_contract_id
    );
    l_uid_params := l_params;

    if io_card_number is not null then
        check_card_number(
            i_format_id       => l_card_type.number_format_id
          , i_params          => l_params
          , i_inst_id         => i_inst_id
          , i_customer_id     => i_customer_id
          , i_card_number     => io_card_number
          , o_card_hash       => l_card_hash
          , o_card_mask       => l_card_mask
        );
    else
        generate_card_number(
            i_format_id       => l_card_type.number_format_id
          , i_params          => l_params
          , i_inst_id         => i_inst_id
          , i_customer_id     => i_customer_id
          , o_card_number     => io_card_number
          , o_card_hash       => l_card_hash
          , o_card_mask       => l_card_mask
        );
    end if;

    check_bin(
        i_card_number   => io_card_number
      , i_product_id    => l_card_type.product_id
      , i_inst_id       => i_inst_id
    );

    l_split_hash := com_api_hash_pkg.get_split_hash(
                        i_entity_type   => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      , i_object_id     => i_customer_id
                    );

    l_category := nvl(i_category, iss_api_const_pkg.CARD_CATEGORY_UNDEFINED);

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ': creating card with id [' || o_id
                                   || '], number (mask) [' || l_card_mask
                                   || '], l_split_hash [' || l_split_hash
                                   || '], l_bin.bin [' || l_bin.bin
                                   || '], l_bin.country [#1], l_category [#2]'
      , i_env_param1 => l_bin.country
      , i_env_param2 => l_category
    );

    insert into iss_card (
        id
      , split_hash
      , card_hash
      , card_mask
      , inst_id
      , card_type_id
      , country
      , customer_id
      , category
      , cardholder_id
      , contract_id
      , reg_date
    ) values (
        o_id
      , l_split_hash
      , l_card_hash
      , l_card_mask
      , i_inst_id
      , i_card_type_id
      , l_bin.country
      , i_customer_id
      , l_category
      , i_cardholder_id
      , i_contract_id
      , com_api_sttl_day_pkg.get_sysdate
    );

    insert into iss_card_number (
        card_id
      , card_number
    ) values (
        o_id
      , iss_api_token_pkg.encode_card_number(i_card_number => io_card_number)
    );

    l_start_date      := coalesce(i_start_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id));
    l_cardholder_name := i_cardholder_name;
    l_company_name    := i_company_name;

    if l_company_name is null then
        prd_api_customer_pkg.get_customer_object (
            i_customer_id  => i_customer_id
          , o_object_id    => l_object_id
          , o_entity_type  => l_entity_type
          , i_mask_error   => com_api_type_pkg.TRUE
        );

        case l_entity_type
            when com_api_const_pkg.ENTITY_TYPE_COMPANY then
                for c in (
                    select a.embossed_name
                      from com_company a
                     where a.id = l_object_id
                ) loop
                    l_company_name := c.embossed_name;
                end loop;

            else
                null;
        end case;
    end if;

    if io_expir_date is null then
        l_params.delete;
        rul_api_param_pkg.set_param(
            i_name     => 'CARD_TYPE_ID'
          , i_value    => i_card_type_id
          , io_params  => l_params
        );
        rul_api_param_pkg.set_param(
            i_name     => 'SEQ_NUMBER'
          , i_value    => nvl(i_seq_number, l_card_type.seq_number_low)
          , io_params  => l_params
        );
        rul_api_param_pkg.set_param(
            i_name     => 'CARD_CATEGORY'
          , i_value    => l_category
          , io_params  => l_params
        );
        io_expir_date := get_expir_date(
                             i_contract_id  => i_contract_id
                           , i_card_id      => o_id
                           , i_start_date   => l_start_date
                           , i_service_id   => i_service_id
                           , i_params       => l_params
                         );
    end if;

    if io_expir_date < l_start_date then
        com_api_error_pkg.raise_error (
            i_error       => 'EXPIRATION_DATE_LT_START_DATE'
          , i_env_param1  => com_api_type_pkg.convert_to_char(l_start_date)
          , i_env_param2  => com_api_type_pkg.convert_to_char(io_expir_date)
        );
    end if;

    l_pin_request       := nvl(i_pin_request, l_card_type.pin_request);
    l_embossing_request := nvl(i_embossing_request, l_card_type.embossing_request);
    l_perso_priority    := coalesce(
                               i_perso_priority
                             , l_card_type.perso_priority
                             , iss_api_const_pkg.PERSO_PRIORITY_NORMAL
                           );
    if l_pin_request = iss_api_const_pkg.PIN_REQUEST_DONT_GENERATE then
        l_pin_mailer_request := iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT;

    elsif l_pin_request = iss_api_const_pkg.PIN_REQUEST_GENERATE then
        l_pin_mailer_request := coalesce(i_pin_mailer_request, l_card_type.pin_mailer_request, iss_api_const_pkg.PIN_MAILER_REQUEST_PRINT);

    else
        com_api_error_pkg.raise_error(
            i_error       => 'INCONSISTENT_PIN_REQUEST_FOR_NEW_CARD'
          , i_env_param1  => l_pin_request
        );
    end if;

    if  l_pin_request = iss_api_const_pkg.PIN_REQUEST_DONT_GENERATE
        and
        l_embossing_request = iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS
    then
        l_state    := nvl(i_state, l_card_type.state);
        l_iss_date := coalesce(i_iss_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id));
    else
        l_state    := nvl(i_state, iss_api_const_pkg.CARD_STATE_PERSONALIZATION);
        l_iss_date := i_iss_date;
    end if;

    l_card_instance.split_hash                  := l_split_hash;
    l_card_instance.card_id                     := o_id;
    l_card_instance.seq_number                  := nvl(i_seq_number, l_card_type.seq_number_low);
    l_card_instance.state                       := l_state;
    l_card_instance.reg_date                    := com_api_sttl_day_pkg.get_sysdate;
    l_card_instance.iss_date                    := l_iss_date;
    l_card_instance.start_date                  := l_start_date;
    l_card_instance.expir_date                  := io_expir_date;
    l_card_instance.cardholder_name             := l_cardholder_name;
    l_card_instance.company_name                := l_company_name;
    l_card_instance.pin_request                 := l_pin_request;
    l_card_instance.pin_mailer_request          := l_pin_mailer_request;
    l_card_instance.embossing_request           := l_embossing_request;
    l_card_instance.status                      := nvl(i_status, l_card_type.status);
    l_card_instance.perso_priority              := l_perso_priority;
    l_card_instance.perso_method_id             := l_card_type.perso_method_id;
    l_card_instance.bin_id                      := l_card_type.bin_id;
    l_card_instance.inst_id                     := i_inst_id;
    l_card_instance.agent_id                    := i_agent_id;
    l_card_instance.blank_type_id               := nvl(i_blank_type_id, l_card_type.blank_type_id);
    l_card_instance.icc_instance_id             := i_icc_instance_id;
    l_card_instance.delivery_channel            := i_delivery_channel;
    l_card_instance.preceding_card_instance_id  := i_preceding_instance_id;
    l_card_instance.reissue_reason              := i_reissue_reason;
    l_card_instance.reissue_date                := i_reissue_date;
    l_card_instance.delivery_status             := i_delivery_status;
    l_card_instance.embossed_surname            := i_embossed_surname;
    l_card_instance.embossed_first_name         := i_embossed_first_name;
    l_card_instance.embossed_second_name        := i_embossed_second_name;
    l_card_instance.embossed_title              := i_embossed_title;
    l_card_instance.embossed_line_additional    := i_embossed_line_additional;
    l_card_instance.supplementary_info_1        := i_supplementary_info_1;
    l_card_instance.cardholder_photo_file_name  := i_cardholder_photo_file_name;
    l_card_instance.cardholder_sign_file_name   := i_cardholder_sign_file_name;

    -- Generate card_uid
    if i_card_uid is not null then
        if check_uid_unique(
               i_card_uid  => i_card_uid
             , i_card_id   => l_card_instance.card_id
           ) = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error       => 'CARD_UID_IS_NOT_UNIQUE'
              , i_env_param1  => i_card_uid
            );
        end if;
        
        l_card_instance.card_uid := i_card_uid;
    else
        generate_uid (
            i_card_id        => o_id
          , i_inst_id        => i_inst_id
          , i_service_id     => l_card_type.service_id
          , i_product_id     => l_card_type.product_id
          , i_split_hash     => l_split_hash
          , i_uid_format_id  => l_card_type.uid_format_id
          , i_params         => l_uid_params
          , o_card_uid       => l_card_instance.card_uid
        );
    end if;

    iss_api_card_instance_pkg.add_card_instance(
        i_card_number          => io_card_number
      , io_card_instance       => l_card_instance
      , i_register_event       => com_api_const_pkg.TRUE
      , i_status_reason        => iss_api_const_pkg.CARD_STATUS_REASON_CARD_ISSUE
      , i_reissue_command      => i_reissue_command
      , i_need_postponed_event => i_need_postponed_event
      , io_postponed_event_tab => io_postponed_event_tab
    );

    o_card_instance_id := l_card_instance.id;

    trc_log_pkg.debug(i_text => LOG_PREFIX || ': END');
exception
    when others then
        rollback to savepoint sp_create_card;
        raise;
end create_card;

procedure issue(
    o_id                               out com_api_type_pkg.t_medium_id
  , io_card_number                  in out com_api_type_pkg.t_card_number
  , o_card_instance_id                 out com_api_type_pkg.t_medium_id
  , i_inst_id                       in     com_api_type_pkg.t_inst_id
  , i_agent_id                      in     com_api_type_pkg.t_agent_id
  , i_contract_id                   in     com_api_type_pkg.t_medium_id
  , i_cardholder_id                 in     com_api_type_pkg.t_long_id
  , i_card_type_id                  in     com_api_type_pkg.t_tiny_id
  , i_customer_id                   in     com_api_type_pkg.t_long_id
  , i_category                      in     com_api_type_pkg.t_dict_value    default null
  , i_start_date                    in     date                             default null
  , io_expir_date                   in out date
  , i_cardholder_name               in     com_api_type_pkg.t_name          default null
  , i_company_name                  in     com_api_type_pkg.t_name          default null
  , i_perso_priority                in     com_api_type_pkg.t_dict_value    default null
  , i_service_id                    in     com_api_type_pkg.t_short_id      default null
  , i_icc_instance_id               in     com_api_type_pkg.t_medium_id     default null
  , i_delivery_channel              in     com_api_type_pkg.t_dict_value    default null
  , i_blank_type_id                 in     com_api_type_pkg.t_tiny_id       default null
  , i_seq_number                    in     com_api_type_pkg.t_tiny_id       default null
  , i_status                        in     com_api_type_pkg.t_dict_value    default null
  , i_state                         in     com_api_type_pkg.t_dict_value    default null
  , i_iss_date                      in     date                             default null
  , i_preceding_instance_id         in     com_api_type_pkg.t_dict_value    default null
  , i_reissue_reason                in     com_api_type_pkg.t_dict_value    default null
  , i_reissue_date                  in     date                             default null
  , i_pin_request                   in     com_api_type_pkg.t_dict_value    default null
  , i_embossing_request             in     com_api_type_pkg.t_dict_value    default null
  , i_delivery_status               in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_surname              in     com_api_type_pkg.t_name          default null
  , i_embossed_first_name           in     com_api_type_pkg.t_name          default null
  , i_embossed_second_name          in     com_api_type_pkg.t_name          default null
  , i_embossed_title                in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_line_additional      in     com_api_type_pkg.t_name          default null
  , i_supplementary_info_1          in     com_api_type_pkg.t_name          default null
  , i_cardholder_photo_file_name    in     iss_api_type_pkg.t_file_name     default null
  , i_cardholder_sign_file_name     in     iss_api_type_pkg.t_file_name     default null
  , i_pin_mailer_request            in     com_api_type_pkg.t_dict_value    default null
) is
    l_postponed_event_tab                  evt_api_type_pkg.t_postponed_event_tab;
begin
    issue(
        o_id                           => o_id
      , io_card_number                 => io_card_number
      , o_card_instance_id             => o_card_instance_id
      , i_inst_id                      => i_inst_id
      , i_agent_id                     => i_agent_id
      , i_contract_id                  => i_contract_id
      , i_cardholder_id                => i_cardholder_id
      , i_card_type_id                 => i_card_type_id
      , i_customer_id                  => i_customer_id
      , i_category                     => i_category
      , i_start_date                   => i_start_date
      , io_expir_date                  => io_expir_date
      , i_cardholder_name              => i_cardholder_name
      , i_company_name                 => i_company_name
      , i_perso_priority               => i_perso_priority
      , i_service_id                   => i_service_id
      , i_icc_instance_id              => i_icc_instance_id
      , i_delivery_channel             => i_delivery_channel
      , i_blank_type_id                => i_blank_type_id
      , i_seq_number                   => i_seq_number
      , i_status                       => i_status
      , i_state                        => i_state
      , i_iss_date                     => i_iss_date
      , i_preceding_instance_id        => i_preceding_instance_id
      , i_reissue_reason               => i_reissue_reason
      , i_reissue_date                 => i_reissue_date
      , i_pin_request                  => i_pin_request
      , i_embossing_request            => i_embossing_request
      , i_delivery_status              => i_delivery_status
      , i_embossed_surname             => i_embossed_surname
      , i_embossed_first_name          => i_embossed_first_name
      , i_embossed_second_name         => i_embossed_second_name
      , i_embossed_title               => i_embossed_title
      , i_embossed_line_additional     => i_embossed_line_additional
      , i_supplementary_info_1         => i_supplementary_info_1
      , i_cardholder_photo_file_name   => i_cardholder_photo_file_name
      , i_cardholder_sign_file_name    => i_cardholder_sign_file_name
      , i_pin_mailer_request           => i_pin_mailer_request
      , i_need_postponed_event         => com_api_const_pkg.FALSE
      , io_postponed_event_tab         => l_postponed_event_tab
    );
end issue;

procedure issue(
    o_id                               out com_api_type_pkg.t_medium_id
  , io_card_number                  in out com_api_type_pkg.t_card_number
  , o_card_instance_id                 out com_api_type_pkg.t_medium_id
  , i_inst_id                       in     com_api_type_pkg.t_inst_id
  , i_agent_id                      in     com_api_type_pkg.t_agent_id
  , i_contract_id                   in     com_api_type_pkg.t_medium_id
  , i_cardholder_id                 in     com_api_type_pkg.t_long_id
  , i_card_type_id                  in     com_api_type_pkg.t_tiny_id
  , i_customer_id                   in     com_api_type_pkg.t_long_id
  , i_category                      in     com_api_type_pkg.t_dict_value    default null
  , i_start_date                    in     date                             default null
  , io_expir_date                   in out date
  , i_cardholder_name               in     com_api_type_pkg.t_name          default null
  , i_company_name                  in     com_api_type_pkg.t_name          default null
  , i_perso_priority                in     com_api_type_pkg.t_dict_value    default null
  , i_service_id                    in     com_api_type_pkg.t_short_id      default null
  , i_icc_instance_id               in     com_api_type_pkg.t_medium_id     default null
  , i_delivery_channel              in     com_api_type_pkg.t_dict_value    default null
  , i_blank_type_id                 in     com_api_type_pkg.t_tiny_id       default null
  , i_seq_number                    in     com_api_type_pkg.t_tiny_id       default null
  , i_status                        in     com_api_type_pkg.t_dict_value    default null
  , i_state                         in     com_api_type_pkg.t_dict_value    default null
  , i_iss_date                      in     date                             default null
  , i_preceding_instance_id         in     com_api_type_pkg.t_dict_value    default null
  , i_reissue_reason                in     com_api_type_pkg.t_dict_value    default null
  , i_reissue_date                  in     date                             default null
  , i_pin_request                   in     com_api_type_pkg.t_dict_value    default null
  , i_embossing_request             in     com_api_type_pkg.t_dict_value    default null
  , i_delivery_status               in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_surname              in     com_api_type_pkg.t_name          default null
  , i_embossed_first_name           in     com_api_type_pkg.t_name          default null
  , i_embossed_second_name          in     com_api_type_pkg.t_name          default null
  , i_embossed_title                in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_line_additional      in     com_api_type_pkg.t_name          default null
  , i_supplementary_info_1          in     com_api_type_pkg.t_name          default null
  , i_cardholder_photo_file_name    in     iss_api_type_pkg.t_file_name     default null
  , i_cardholder_sign_file_name     in     iss_api_type_pkg.t_file_name     default null
  , i_pin_mailer_request            in     com_api_type_pkg.t_dict_value    default null
  , i_need_postponed_event          in     com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , io_postponed_event_tab          in out nocopy evt_api_type_pkg.t_postponed_event_tab
) is
begin
    create_card(
        o_id                           => o_id
      , io_card_number                 => io_card_number
      , o_card_instance_id             => o_card_instance_id
      , i_inst_id                      => i_inst_id
      , i_agent_id                     => i_agent_id
      , i_contract_id                  => i_contract_id
      , i_cardholder_id                => i_cardholder_id
      , i_card_type_id                 => i_card_type_id
      , i_customer_id                  => i_customer_id
      , i_category                     => i_category
      , i_start_date                   => i_start_date
      , io_expir_date                  => io_expir_date
      , i_cardholder_name              => i_cardholder_name
      , i_company_name                 => i_company_name
      , i_perso_priority               => i_perso_priority
      , i_service_id                   => i_service_id
      , i_icc_instance_id              => i_icc_instance_id
      , i_delivery_channel             => i_delivery_channel
      , i_blank_type_id                => i_blank_type_id
      , i_seq_number                   => i_seq_number
      , i_status                       => i_status
      , i_state                        => i_state
      , i_iss_date                     => i_iss_date
      , i_preceding_instance_id        => i_preceding_instance_id
      , i_reissue_reason               => i_reissue_reason
      , i_reissue_date                 => i_reissue_date
      , i_pin_request                  => i_pin_request
      , i_embossing_request            => i_embossing_request
      , i_delivery_status              => i_delivery_status
      , i_embossed_surname             => i_embossed_surname
      , i_embossed_first_name          => i_embossed_first_name
      , i_embossed_second_name         => i_embossed_second_name
      , i_embossed_title               => i_embossed_title
      , i_embossed_line_additional     => i_embossed_line_additional
      , i_supplementary_info_1         => i_supplementary_info_1
      , i_cardholder_photo_file_name   => i_cardholder_photo_file_name
      , i_cardholder_sign_file_name    => i_cardholder_sign_file_name
      , i_pin_mailer_request           => i_pin_mailer_request
      , i_need_postponed_event         => i_need_postponed_event
      , io_postponed_event_tab         => io_postponed_event_tab
    );
end issue;

procedure get_instance_reissue_data (
    i_card_number                   in com_api_type_pkg.t_card_number
    , i_seq_number                  in com_api_type_pkg.t_tiny_id
    , o_start_date                  out date
    , o_expir_date                  out date
    , o_card_type_id                out com_api_type_pkg.t_tiny_id
    , o_category                    out com_api_type_pkg.t_dict_value
    , o_contract_id                 out com_api_type_pkg.t_medium_id
    , o_card_id                     out com_api_type_pkg.t_medium_id
    , o_card_instance_id            out com_api_type_pkg.t_medium_id
    , o_pvv                         out number
    , o_pin_offset                  out com_api_type_pkg.t_cmid
    , o_pin_block                   out com_api_type_pkg.t_name
    , o_split_hash                  out com_api_type_pkg.t_tiny_id
    , o_cardholder_name             out com_api_type_pkg.t_name
    , o_company_name                out com_api_type_pkg.t_name
    , o_agent_id                    out com_api_type_pkg.t_agent_id
    , o_inst_id                     out com_api_type_pkg.t_inst_id
    , o_blank_type_id               out com_api_type_pkg.t_tiny_id
    , o_cardholder_photo_file_name  out iss_api_type_pkg.t_file_name
    , o_cardholder_sign_file_name   out iss_api_type_pkg.t_file_name
) is
    l_card_number           com_api_type_pkg.t_card_number;
    l_card_hash             com_api_type_pkg.t_long_id;
begin
    -- For correct usage of the index we should use during the search a value that is stored in the table iss_card_number
    l_card_number := iss_api_token_pkg.encode_card_number(i_card_number => i_card_number);
    l_card_hash   := com_api_hash_pkg.get_card_hash(i_card_number);

    select i.start_date
         , i.expir_date
         , c.card_type_id
         , c.category
         , c.contract_id
         , c.id
         , i.id
         , d.pvv
         , d.pin_offset
         , d.kcolb_nip
         , c.split_hash
         , i.cardholder_name
         , i.company_name
         , i.agent_id
         , i.inst_id
         , i.blank_type_id
         , i.cardholder_photo_file_name
         , i.cardholder_sign_file_name
      into o_start_date
         , o_expir_date
         , o_card_type_id
         , o_category
         , o_contract_id
         , o_card_id
         , o_card_instance_id
         , o_pvv
         , o_pin_offset
         , o_pin_block
         , o_split_hash
         , o_cardholder_name
         , o_company_name
         , o_agent_id
         , o_inst_id
         , o_blank_type_id
         , o_cardholder_photo_file_name
         , o_cardholder_sign_file_name
      from iss_card c
         , iss_card_number cn
         , iss_card_instance i
         , iss_card_instance_data d
     where c.card_hash             = l_card_hash
       and reverse(cn.card_number) = reverse(l_card_number)
       and i.card_id               = c.id
       and cn.card_id              = c.id
       and i.seq_number            = i_seq_number
       and d.card_instance_id(+)   = i.id
    for update of i.state;

exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error         => 'CARD_INSTANCE_NOT_FOUND'
            , i_env_param1  => get_card_mask(i_card_number)
            , i_env_param2  => i_seq_number
        );
end;

procedure calculate_dates (
    i_start_date            in date
    , i_start_date_rule     in com_api_type_pkg.t_dict_value
    , i_old_start_date      in date
    , o_start_date          out date
    , i_expir_date          in date
    , i_expir_date_rule     in com_api_type_pkg.t_dict_value
    , i_old_expir_date      in date
    , o_expir_date          out date
    , i_contract_id         in com_api_type_pkg.t_medium_id
    , i_card_id             in com_api_type_pkg.t_medium_id
    , i_params              in com_api_type_pkg.t_param_tab
    , i_inst_id             in com_api_type_pkg.t_inst_id
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.calculate_dates: ';
    l_base_date             date;
    l_threshold_date        date;
    l_service_id            com_api_type_pkg.t_short_id;
    l_contract_id           com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START i_start_date=' || i_start_date || ' i_start_date_rule=' || i_start_date_rule || ' i_old_start_date=' || i_old_start_date || ' i_expir_date='
                             || i_expir_date || ' i_expir_date_rule=' || i_expir_date_rule || ' i_old_expir_date=' || i_old_expir_date
                             || ' i_contract_id=' || i_contract_id || ' i_card_id=' || i_card_id || ' i_inst_id=' || i_inst_id
    );
    begin
        select contract_id
          into l_contract_id
          from iss_card
         where id = i_card_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error       => 'CONTRACT_NOT_FOUND'
              , i_env_param1  => i_card_id
              , i_env_param2  => i_contract_id
            );
    end;
    if i_contract_id != l_contract_id then
        begin
            -- Search service with CYCLE_EXPIRATION_DATE
            select ps.service_id
              into l_service_id
              from prd_product_service ps
                 , prd_contract c
                 , prd_attribute a
                 , prd_service s
             where c.id              = i_contract_id
               and ps.product_id     = c.product_id
               and ps.service_id     = s.id
               and a.service_type_id = s.service_type_id
               and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_CYCLE
               and a.object_type     = iss_api_const_pkg.CYCLE_EXPIRATION_DATE;
        exception
            when no_data_found then
                l_service_id := null;
        end;
    else
        l_service_id := null;
    end if;

    if i_start_date is not null then
        o_start_date := i_start_date;
    elsif i_start_date_rule = iss_api_const_pkg.START_DATE_OLD_EXPIRY_MONTH then
        o_start_date := trunc(i_old_expir_date, 'MON');
    elsif i_start_date_rule = iss_api_const_pkg.START_DATE_OLD_EXPIRY_DATE then
        o_start_date := trunc(i_old_expir_date);
    elsif i_start_date_rule = iss_api_const_pkg.START_DATE_OLD_START_DATE then
        o_start_date := i_old_start_date;
    elsif i_start_date_rule = iss_api_const_pkg.START_DATE_SYSDATE_DELAY then
        o_start_date := 
            get_start_date(
                i_card_id       => i_card_id
              , i_eff_date      => trunc(com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id))
              , i_cycle_type    => iss_api_const_pkg.CYCLE_DELAY_START_DATE
              , i_inst_id       => i_inst_id
            );
    elsif nvl(i_start_date_rule, iss_api_const_pkg.START_DATE_SYSDATE) = iss_api_const_pkg.START_DATE_SYSDATE then
        o_start_date := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id);
    else
        com_api_error_pkg.raise_error (
            i_error         => 'UNKNOWN_START_DATE_RULE'
            , i_env_param1  => i_start_date_rule
        );
    end if;

    if i_expir_date is not null then
        o_expir_date := i_expir_date;
    elsif i_expir_date_rule = iss_api_const_pkg.EXPIRY_DATE_EQUAL_EXPIRY_DATE then
        o_expir_date := i_old_expir_date;
    else

        if nvl(i_expir_date_rule, iss_api_const_pkg.EXPIRY_DATE_FROM_EXPIRY_DATE) = iss_api_const_pkg.EXPIRY_DATE_FROM_EXPIRY_DATE then
            l_base_date := i_old_expir_date;
        elsif i_expir_date_rule in (iss_api_const_pkg.EXPIRY_DATE_FROM_START_DATE, iss_api_const_pkg.EXPIRY_DATE_FROM_THRESHOLD) then
            l_base_date := o_start_date;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_EXPIRY_DATE_RULE'
                , i_env_param1  => i_expir_date_rule
            );
        end if;

        if i_expir_date_rule = iss_api_const_pkg.EXPIRY_DATE_FROM_THRESHOLD then
            l_threshold_date := get_expir_date (
                i_contract_id => i_contract_id
              , i_card_id     => i_card_id
              , i_start_date  => l_base_date
              , i_service_id  => l_service_id
              , i_params      => i_params
              , i_cycle_type  => iss_api_const_pkg.CYCLE_THRESHOLD_DATE   -- use diff type of cycle because of EXPIRY_DATE_FROM_THRESHOLD
            );
            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'l_threshold_date=' || l_threshold_date
            );

            if i_old_expir_date < l_threshold_date then
                o_expir_date := l_threshold_date;
            else
                o_expir_date := i_old_expir_date;
            end if;
        else
            o_expir_date := get_expir_date (
                i_contract_id => i_contract_id
              , i_card_id     => i_card_id
              , i_start_date  => l_base_date
              , i_service_id  => l_service_id
              , i_params      => i_params
            );
        end if;

    end if;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'END o_start_date=' || o_start_date || ' o_expir_date=' || o_expir_date
    );
end;

procedure clone_card_service(
    i_old_id                    in      com_api_type_pkg.t_medium_id
  , i_new_id                    in      com_api_type_pkg.t_medium_id
  , i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_contract_id               in      com_api_type_pkg.t_medium_id
  , i_start_date                in      date
  , i_clone_optional_services   in      com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) is
    l_params                com_api_type_pkg.t_param_tab;
    l_account_object_id     com_api_type_pkg.t_long_id;
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.clone_card_service: ';
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' START: i_old_id ='  || i_old_id
                                   || ' i_new_id = '        || i_new_id
                                   || ' i_inst_id = '       || i_inst_id
                                   || ' i_contract_id = '   || i_contract_id
                                   || ' i_start_date = '    || to_char(i_start_date, 'DD.MM.YYYY HH24:MI:SS')
                                   || ' i_clone_optional_services = ' || i_clone_optional_services
    );

    for rec in (
        select o.contract_id
             , o.service_id
             , o.entity_type
             , o.status
             , o.split_hash
          from prd_service_object   o
             , prd_service          s
             , prd_service_type     t
             , prd_product_service  p
         where o.entity_type        = iss_api_const_pkg.ENTITY_TYPE_CARD
           and o.object_id          = i_old_id
           and o.service_id         = s.id
           and s.service_type_id    = t.id
           and p.product_id         = prd_api_product_pkg.get_product_id(
                                          i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
                                        , i_object_id       => i_old_id
                                      )
           and p.service_id         = o.service_id
           and (i_clone_optional_services = com_api_const_pkg.FALSE
                and (t.is_initial = com_api_const_pkg.TRUE
                     or p.min_count > 0
                    )
                or nvl(i_clone_optional_services, com_api_const_pkg.TRUE) != com_api_const_pkg.FALSE
               )
    )
    loop
        prd_ui_service_pkg.set_service_object (
            i_service_id        => rec.service_id
          , i_contract_id       => i_contract_id
          , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id         => i_new_id
          , i_start_date        => i_start_date
          , i_end_date          => null
          , i_inst_id           => i_inst_id
          , i_params            => l_params
        );
    end loop;

    for rec in (
        select account_id
             , entity_type
             , usage_order
             , split_hash
             , is_pos_default
             , is_atm_default
             , is_atm_currency
             , is_pos_currency
          from acc_account_object
         where entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           and object_id   = i_old_id
    )
    loop
        acc_api_account_pkg.add_account_object(
            i_account_id        => rec.account_id
          , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id         => i_new_id
          , i_usage_order       => rec.usage_order
          , i_is_pos_default    => rec.is_pos_default
          , i_is_atm_default    => rec.is_atm_default
          , i_is_atm_currency   => rec.is_atm_currency
          , i_is_pos_currency   => rec.is_pos_currency
          , o_account_object_id => l_account_object_id
        );
    end loop;

    -- clone custom notifications
    for tab in (
        select custom_event_id
             , entity_type
          from ntf_custom_object
         where object_id = i_old_id
    )
    loop
        ntf_api_custom_pkg.set_custom_object(
            i_custom_event_id   => tab.custom_event_id
          , i_object_id         => i_new_id
          , i_entity_type       => coalesce(tab.entity_type, iss_api_const_pkg.ENTITY_TYPE_CARD)
          , i_is_active         => com_api_const_pkg.TRUE
        );
    end loop;
end;

procedure clone_flexible_fields(
      i_old_card_id     in  com_api_type_pkg.t_medium_id
    , i_new_card_id     in  com_api_type_pkg.t_medium_id
) is
    l_value_n              number;
    l_value_v              com_api_type_pkg.t_name;
    l_value_d              date;
begin
    trc_log_pkg.debug(
        i_text       => 'clone_flexible_fields Start'
    );
    for r in (
        select f.id field_id
             , f.name field_name
             , f.data_type
             , d.field_value
             , f.data_format
          from com_flexible_field f
             , com_flexible_data d
         where f.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
           and d.field_id     = f.id
           and d.object_id    = i_old_card_id
    ) loop

        if r.data_type = com_api_const_pkg.DATA_TYPE_CHAR then

            l_value_v := r.field_value;

            com_api_flexible_data_pkg.set_flexible_value(
                i_field_name    => upper(r.field_name)
              , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id     => i_new_card_id
              , i_field_value   => r.field_value
            );
        elsif r.data_type = com_api_const_pkg.DATA_TYPE_NUMBER then

            l_value_n := to_number(r.field_value, r.data_format);

            com_api_flexible_data_pkg.set_flexible_value(
                i_field_name    => upper(r.field_name)
              , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id     => i_new_card_id
              , i_field_value   => l_value_n
            );
        elsif r.data_type = com_api_const_pkg.DATA_TYPE_DATE then

            l_value_d := to_date(r.field_value, r.data_format);

            com_api_flexible_data_pkg.set_flexible_value(
                i_field_name    => upper(r.field_name)
              , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id     => i_new_card_id
              , i_field_value   => l_value_d
            );
        end if;
    end loop;

    trc_log_pkg.debug(
        i_text       => 'clone_flexible_fields End'
    );
end;

procedure card_reissue(
    i_card_number                   in      com_api_type_pkg.t_card_number
  , i_seq_number                    in      com_api_type_pkg.t_tiny_id := null
  , io_card_number                  in out  com_api_type_pkg.t_card_number
  , i_command                       in      com_api_type_pkg.t_dict_value := null
  , i_agent_id                      in      com_api_type_pkg.t_agent_id := null
  , i_contract_id                   in      com_api_type_pkg.t_medium_id := null
  , i_card_type_id                  in      com_api_type_pkg.t_tiny_id := null
  , i_category                      in      com_api_type_pkg.t_dict_value := null
  , i_start_date                    in      date := null
  , i_start_date_rule               in      com_api_type_pkg.t_dict_value := null
  , io_expir_date                   in out  date
  , i_expir_date_rule               in      com_api_type_pkg.t_dict_value := null
  , i_cardholder_name               in      com_api_type_pkg.t_name := null
  , i_company_name                  in      com_api_type_pkg.t_name := null
  , i_perso_priority                in      com_api_type_pkg.t_dict_value := null
  , i_pin_request                   in      com_api_type_pkg.t_dict_value := null
  , i_pin_mailer_request            in      com_api_type_pkg.t_dict_value := null
  , i_embossing_request             in      com_api_type_pkg.t_dict_value := null
  , i_delivery_channel              in      com_api_type_pkg.t_dict_value
  , i_blank_type_id                 in      com_api_type_pkg.t_tiny_id
  , i_reissue_reason                in      com_api_type_pkg.t_dict_value
  , i_reissue_date                  in      date
  , i_clone_optional_services       in      com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_delivery_status               in      com_api_type_pkg.t_dict_value := null
  , i_embossed_surname              in     com_api_type_pkg.t_name           default null
  , i_embossed_first_name           in     com_api_type_pkg.t_name           default null
  , i_embossed_second_name          in     com_api_type_pkg.t_name           default null
  , i_embossed_title                in     com_api_type_pkg.t_dict_value     default null
  , i_embossed_line_additional      in     com_api_type_pkg.t_name           default null
  , i_supplementary_info_1          in     com_api_type_pkg.t_name           default null
  , i_cardholder_photo_file_name    in     iss_api_type_pkg.t_file_name      default null
  , i_cardholder_sign_file_name     in     iss_api_type_pkg.t_file_name      default null
  , i_card_uid                      in     com_api_type_pkg.t_name           default null
  , i_reissue_command               in     com_api_type_pkg.t_dict_value     default null
  , i_need_postponed_event          in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , io_postponed_event_tab          in out nocopy evt_api_type_pkg.t_postponed_event_tab
) is
    l_id                    com_api_type_pkg.t_medium_id;
    l_card                  iss_api_type_pkg.t_card_rec;
    l_old_start_date        date;
    l_start_date            date;
    l_old_expir_date        date;
    l_cardholder_name       com_api_type_pkg.t_name;
    l_company_name          com_api_type_pkg.t_name;
    l_agent_id              com_api_type_pkg.t_agent_id;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_pvv                   number;
    l_pin_offset            com_api_type_pkg.t_cmid;
    l_pin_block             com_api_type_pkg.t_name;
    l_card_instance_id      com_api_type_pkg.t_medium_id;
    l_old_card_instance_id  com_api_type_pkg.t_medium_id;
    l_category              com_api_type_pkg.t_dict_value;
    l_card_type             iss_api_type_pkg.t_product_card_type_rec;
    l_params                com_api_type_pkg.t_param_tab;
    l_blank_type_id         com_api_type_pkg.t_tiny_id;
    l_cardholder_photo_file_name    iss_api_type_pkg.t_file_name;
    l_cardholder_sign_file_name     iss_api_type_pkg.t_file_name;
begin
    l_card := get_card(i_card_number => i_card_number);

    get_instance_reissue_data (
        i_card_number                  => i_card_number
      , i_seq_number                   => i_seq_number
      , o_start_date                   => l_old_start_date
      , o_expir_date                   => l_old_expir_date
      , o_card_type_id                 => l_card.card_type_id
      , o_category                     => l_category
      , o_contract_id                  => l_card.contract_id
      , o_card_id                      => l_card.id
      , o_card_instance_id             => l_old_card_instance_id
      , o_pvv                          => l_pvv
      , o_pin_offset                   => l_pin_offset
      , o_pin_block                    => l_pin_block
      , o_split_hash                   => l_card.split_hash
      , o_cardholder_name              => l_cardholder_name
      , o_company_name                 => l_company_name
      , o_agent_id                     => l_agent_id
      , o_inst_id                      => l_inst_id
      , o_blank_type_id                => l_blank_type_id
      , o_cardholder_photo_file_name   => l_cardholder_photo_file_name
      , o_cardholder_sign_file_name    => l_cardholder_sign_file_name
    );

    if l_old_card_instance_id is not null then
        ost_api_agent_pkg.check_agent_id(
            i_agent_id       => l_agent_id
        );

        remove_reissue_cycle(
            i_card_instance_id      => l_old_card_instance_id
          , i_split_hash            => l_card.split_hash
        );
    end if;

    l_card_type :=
        iss_api_product_pkg.get_product_card_type(
            i_contract_id     => nvl(i_contract_id, l_card.contract_id)
          , i_card_type_id    => nvl(i_card_type_id, l_card.card_type_id)
        );

    rul_api_param_pkg.set_param(
        i_name     => 'CARD_TYPE_ID'
      , i_value    => nvl(i_card_type_id, l_card.card_type_id)
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'SEQ_NUMBER'
      , i_value    => l_card_type.seq_number_low
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'CARD_CATEGORY'
      , i_value    => l_card.category
      , io_params  => l_params
    );
    calculate_dates (
        i_start_date       => i_start_date
      , i_start_date_rule  => i_start_date_rule
      , i_old_start_date   => l_old_start_date
      , o_start_date       => l_start_date
      , i_expir_date       => io_expir_date
      , i_expir_date_rule  => i_expir_date_rule
      , i_old_expir_date   => l_old_expir_date
      , o_expir_date       => io_expir_date
      , i_contract_id      => nvl(i_contract_id, l_card.contract_id)
      , i_card_id          => l_card.id
      , i_params           => l_params
      , i_inst_id          => l_inst_id
    );

    create_card(
        o_id                           => l_id
      , io_card_number                 => io_card_number
      , o_card_instance_id             => l_card_instance_id
      , i_inst_id                      => l_inst_id
      , i_agent_id                     => nvl(i_agent_id, l_agent_id)
      , i_contract_id                  => nvl(i_contract_id, l_card.contract_id)
      , i_cardholder_id                => l_card.cardholder_id
      , i_card_type_id                 => nvl(i_card_type_id, l_card.card_type_id)
      , i_customer_id                  => l_card.customer_id
      , i_category                     => l_card.category
      , i_start_date                   => l_start_date
      , io_expir_date                  => io_expir_date
      , i_cardholder_name              => nvl(i_cardholder_name, l_cardholder_name)
      , i_company_name                 => nvl(i_company_name, l_company_name)
      , i_perso_priority               => i_perso_priority
      , i_pvv                          => l_pvv
      , i_pin_block                    => l_pin_block
      , i_delivery_channel             => i_delivery_channel
      , i_blank_type_id                => i_blank_type_id
      , i_preceding_instance_id        => l_old_card_instance_id
      , i_reissue_reason               => i_reissue_reason
      , i_reissue_date                 => i_reissue_date
      , i_pin_request                  => i_pin_request
      , i_embossing_request            => i_embossing_request
      , i_delivery_status              => i_delivery_status
      , i_embossed_surname             => i_embossed_surname
      , i_embossed_first_name          => i_embossed_first_name
      , i_embossed_second_name         => i_embossed_second_name
      , i_embossed_title               => i_embossed_title
      , i_embossed_line_additional     => i_embossed_line_additional
      , i_supplementary_info_1         => i_supplementary_info_1
      , i_cardholder_photo_file_name   => nvl(i_cardholder_photo_file_name, l_cardholder_photo_file_name)
      , i_cardholder_sign_file_name    => nvl(i_cardholder_sign_file_name,  l_cardholder_sign_file_name)
      , i_card_uid                     => i_card_uid
      , i_reissue_command              => nvl(i_reissue_command, l_card_type.reiss_command)
      , i_need_postponed_event         => i_need_postponed_event
      , io_postponed_event_tab         => io_postponed_event_tab
    );

    clone_card_service(
        i_old_id                    => l_card.id
      , i_new_id                    => l_id
      , i_inst_id                   => l_inst_id
      , i_contract_id               => nvl(i_contract_id, l_card.contract_id)
      , i_start_date                => l_start_date
      , i_clone_optional_services   => i_clone_optional_services
    );

    clone_flexible_fields(
        i_old_card_id   => l_card.id
      , i_new_card_id   => l_id
    );

    ntb_ui_note_pkg.move(
        i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_id_old => l_card.id
      , i_object_id_new => l_id
    );
end card_reissue;

function get_seq_number (
    i_card_number           in com_api_type_pkg.t_card_number
  , i_inst_id               in com_api_type_pkg.t_inst_id        default null
) return com_api_type_pkg.t_tiny_id
is
    l_result                com_api_type_pkg.t_tiny_id;
    l_card_number           com_api_type_pkg.t_card_number;
    l_card_hash             com_api_type_pkg.t_long_id;
begin
    -- For correct usage of the index we should use during the search a value that is stored in the table iss_card_number
    l_card_number := iss_api_token_pkg.encode_card_number(i_card_number => i_card_number);
    l_card_hash   := com_api_hash_pkg.get_card_hash(i_card_number);

    select max(i.seq_number)
      into l_result
      from iss_card c
         , iss_card_number cn
         , iss_card_instance i
     where c.card_hash             = l_card_hash
       and reverse(cn.card_number) = reverse(l_card_number)
       and cn.card_id              = c.id
       and i.card_id               = c.id
       and (c.inst_id              = i_inst_id or i_inst_id is null);

    if l_result is not null then
        return l_result;
    else
        com_api_error_pkg.raise_error (
            i_error       => 'CARD_INSTANCE_NOT_FOUND'
          , i_env_param1  => get_card_mask(i_card_number)
        );
    end if;
end;

procedure instance_reissue(
    i_card_number                   in     com_api_type_pkg.t_card_number
  , io_seq_number                   in out com_api_type_pkg.t_tiny_id
  , i_agent_id                      in     com_api_type_pkg.t_agent_id
  , i_start_date                    in     date
  , i_start_date_rule               in     com_api_type_pkg.t_dict_value
  , io_expir_date                   in out date
  , i_expir_date_rule               in     com_api_type_pkg.t_dict_value
  , i_cardholder_name               in     com_api_type_pkg.t_name
  , i_company_name                  in     com_api_type_pkg.t_name
  , i_perso_priority                in     com_api_type_pkg.t_dict_value
  , i_pin_request                   in     com_api_type_pkg.t_dict_value
  , i_pin_mailer_request            in     com_api_type_pkg.t_dict_value
  , i_embossing_request             in     com_api_type_pkg.t_dict_value
  , i_delivery_channel              in     com_api_type_pkg.t_dict_value
  , i_blank_type_id                 in     com_api_type_pkg.t_tiny_id
  , i_reissue_reason                in     com_api_type_pkg.t_dict_value
  , i_reissue_date                  in     date
  , i_card_type_id                  in     com_api_type_pkg.t_tiny_id
  , i_delivery_status               in     com_api_type_pkg.t_dict_value
  , i_embossed_surname              in     com_api_type_pkg.t_name           default null
  , i_embossed_first_name           in     com_api_type_pkg.t_name           default null
  , i_embossed_second_name          in     com_api_type_pkg.t_name           default null
  , i_embossed_title                in     com_api_type_pkg.t_dict_value     default null
  , i_embossed_line_additional      in     com_api_type_pkg.t_name           default null
  , i_supplementary_info_1          in     com_api_type_pkg.t_name           default null
  , i_cardholder_photo_file_name    in     iss_api_type_pkg.t_file_name      default null
  , i_cardholder_sign_file_name     in     iss_api_type_pkg.t_file_name      default null
  , i_card_uid                      in     com_api_type_pkg.t_name           default null
  , i_inherit_pin_offset            in     com_api_type_pkg.t_boolean        default null
  , i_reissue_command               in     com_api_type_pkg.t_dict_value     default null
  , i_need_postponed_event          in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , io_postponed_event_tab          in out nocopy evt_api_type_pkg.t_postponed_event_tab
) is
    l_pvv                   number;
    l_pin_offset            com_api_type_pkg.t_cmid;
    l_pin_block             com_api_type_pkg.t_name;
    l_card_type             iss_api_type_pkg.t_product_card_type_rec;
    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_contract_id           com_api_type_pkg.t_medium_id;
    l_old_start_date        date;
    l_start_date            date;
    l_old_expir_date        date;
    l_params                com_api_type_pkg.t_param_tab;
    l_card_instance         iss_api_type_pkg.t_card_instance;
    l_category              com_api_type_pkg.t_dict_value;
    l_bin_ok                com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_blank_type_id         com_api_type_pkg.t_tiny_id;
    l_is_new_card_type      com_api_type_pkg.t_boolean;

    l_uid_params            com_api_type_pkg.t_param_tab;
    l_bin                   iss_api_type_pkg.t_bin_rec;
    l_agent_number          com_api_type_pkg.t_name;
    l_product_number        com_api_type_pkg.t_name;
begin
    l_card_instance.id := iss_card_instance_seq.nextval;

    savepoint sp_instance_reissue;

    get_instance_reissue_data (
        i_card_number                  => i_card_number
        , i_seq_number                 => io_seq_number
        , o_start_date                 => l_old_start_date
        , o_expir_date                 => l_old_expir_date
        , o_card_type_id               => l_card_type_id
        , o_category                   => l_category
        , o_contract_id                => l_contract_id
        , o_card_id                    => l_card_instance.card_id
        , o_card_instance_id           => l_card_instance.preceding_card_instance_id
        , o_pvv                        => l_pvv
        , o_pin_offset                 => l_pin_offset
        , o_pin_block                  => l_pin_block
        , o_split_hash                 => l_card_instance.split_hash
        , o_cardholder_name            => l_card_instance.cardholder_name
        , o_company_name               => l_card_instance.company_name
        , o_agent_id                   => l_card_instance.agent_id
        , o_inst_id                    => l_card_instance.inst_id
        , o_blank_type_id              => l_blank_type_id
        , o_cardholder_photo_file_name => l_card_instance.cardholder_photo_file_name
        , o_cardholder_sign_file_name  => l_card_instance.cardholder_sign_file_name
    );

    -- before creating a new card instance it is necessary to remove reissue cycle
    if l_card_instance.preceding_card_instance_id is not null then
        ost_api_agent_pkg.check_agent_id(
            i_agent_id       => l_card_instance.agent_id
        );

        remove_reissue_cycle(
            i_card_instance_id      => l_card_instance.preceding_card_instance_id
          , i_split_hash            => l_card_instance.split_hash
        );
    end if;

    io_seq_number := io_seq_number + 1;

    -- if new card type is defined
    if l_card_type_id != nvl(i_card_type_id, l_card_type_id) then
        l_bin_ok := iss_api_bin_pkg.is_bin_ok (
            i_card_number    => i_card_number
            , i_card_type_id => i_card_type_id
        );
        if l_bin_ok = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error (
                i_error             => 'BIN_ERROR_FOR_CARD_TYPE'
                , i_env_param1      => iss_api_card_pkg.get_card_mask(i_card_number)
                , i_env_param2      => substr(i_card_number, 1, 6)
                , i_env_param3      => i_card_type_id
            );
        end if;
        l_card_type_id := nvl(i_card_type_id, l_card_type_id);
        l_is_new_card_type  := com_api_type_pkg.TRUE;
    else
        l_is_new_card_type  := com_api_type_pkg.FALSE;
    end if;

    l_card_type := iss_api_product_pkg.get_product_card_type (
        i_contract_id           => l_contract_id
        , i_card_type_id        => l_card_type_id
        , i_seq_number          => io_seq_number
    );

    if l_is_new_card_type = com_api_type_pkg.TRUE then
        l_blank_type_id := l_card_type.blank_type_id;
    end if;

    l_params.delete;
    rul_api_param_pkg.set_param(
        i_name       => 'CARD_TYPE_ID'
        , i_value    => l_card_type_id
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name       => 'SEQ_NUMBER'
        , i_value    => io_seq_number
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name       => 'CARD_CATEGORY'
        , i_value    => l_category
        , io_params  => l_params
    );

    calculate_dates (
        i_start_date            => i_start_date
        , i_start_date_rule     => i_start_date_rule
        , i_old_start_date      => l_old_start_date
        , o_start_date          => l_start_date
        , i_expir_date          => io_expir_date
        , i_expir_date_rule     => i_expir_date_rule
        , i_old_expir_date      => l_old_expir_date
        , o_expir_date          => io_expir_date
        , i_contract_id         => l_contract_id
        , i_card_id             => l_card_instance.card_id
        , i_params              => l_params
        , i_inst_id             => l_card_instance.inst_id
    );

    l_card_instance.pin_request := nvl(i_pin_request, l_card_type.pin_request);
    l_card_instance.pin_mailer_request := nvl(i_pin_mailer_request, l_card_type.pin_mailer_request);
    l_card_instance.embossing_request := nvl(i_embossing_request, l_card_type.embossing_request);

    if l_card_instance.pin_request = iss_api_const_pkg.PIN_REQUEST_GENERATE then
        l_card_instance.pin_mailer_request := iss_api_const_pkg.PIN_MAILER_REQUEST_PRINT;

    elsif l_card_instance.pin_request = iss_api_const_pkg.PIN_REQUEST_INHERIT and l_pvv is null then
        com_api_error_pkg.raise_error (
            i_error         => 'INCONSISTENT_PIN_REQUEST'
            , i_env_param1  => i_pin_request
        );

    elsif l_card_instance.pin_request = iss_api_const_pkg.PIN_REQUEST_DONT_GENERATE then
        l_card_instance.pin_mailer_request := iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT;
    end if;

    if l_card_instance.pin_request = iss_api_const_pkg.PIN_REQUEST_INHERIT
        or i_inherit_pin_offset = com_api_const_pkg.TRUE
    then
        insert into iss_card_instance_data (
            card_instance_id
            , pvv
            , kcolb_nip
            , pin_offset
        ) values (
            l_card_instance.id
            , l_pvv
            , l_pin_block
            , l_pin_offset
        );
        l_card_instance.pin_request := iss_api_const_pkg.PIN_REQUEST_DONT_GENERATE;
    end if;

    if l_card_instance.pin_mailer_request = iss_api_const_pkg.PIN_MAILER_REQUEST_PRINT then
        if not (l_card_instance.pin_request = iss_api_const_pkg.PIN_REQUEST_GENERATE or l_pin_block is not null) then
            com_api_error_pkg.raise_error (
                i_error         => 'INCONSISTENT_PIN_MAILER_REQUEST'
                , i_env_param1  => i_pin_mailer_request
            );
        end if;
    end if;

    if (
        l_card_instance.pin_request = iss_api_const_pkg.PIN_REQUEST_GENERATE
        or l_card_instance.pin_mailer_request = iss_api_const_pkg.PIN_MAILER_REQUEST_PRINT
        or l_card_instance.embossing_request = iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS
    ) then
        l_card_instance.state := iss_api_const_pkg.CARD_STATE_PERSONALIZATION;
    else
        l_card_instance.state := l_card_type.state;
        l_card_instance.iss_date := com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_card_instance.inst_id);
    end if;

    if io_expir_date < l_start_date then
        com_api_error_pkg.raise_error (
            i_error         => 'EXPIRATION_DATE_LT_START_DATE'
            , i_env_param1  => com_api_type_pkg.convert_to_char(l_start_date)
            , i_env_param2  => com_api_type_pkg.convert_to_char(io_expir_date)
        );
    end if;

    l_card_instance.perso_priority := coalesce(i_perso_priority, l_card_type.perso_priority, iss_api_const_pkg.PERSO_PRIORITY_NORMAL);
    l_card_instance.cardholder_name := nvl(i_cardholder_name, l_card_instance.cardholder_name);
    l_card_instance.company_name := nvl(i_company_name, l_card_instance.company_name);
    l_card_instance.agent_id := nvl(i_agent_id, l_card_instance.agent_id);

    l_card_instance.seq_number               := io_seq_number;
    l_card_instance.status                   := l_card_type.status;
    l_card_instance.reg_date                 := com_api_sttl_day_pkg.get_sysdate;
    l_card_instance.start_date               := l_start_date;
    l_card_instance.expir_date               := io_expir_date;
    l_card_instance.perso_method_id          := l_card_type.perso_method_id;
    l_card_instance.bin_id                   := l_card_type.bin_id;
    l_card_instance.blank_type_id            := nvl(i_blank_type_id, l_blank_type_id);
    l_card_instance.delivery_channel         := i_delivery_channel;
    l_card_instance.reissue_reason           := i_reissue_reason;
    l_card_instance.reissue_date             := i_reissue_date;
    l_card_instance.delivery_status          := i_delivery_status;
    l_card_instance.embossed_surname         := i_embossed_surname;
    l_card_instance.embossed_first_name      := i_embossed_first_name;
    l_card_instance.embossed_second_name     := i_embossed_second_name;
    l_card_instance.embossed_title           := i_embossed_title;
    l_card_instance.embossed_line_additional := i_embossed_line_additional;
    l_card_instance.supplementary_info_1     := i_supplementary_info_1;

    l_card_instance.cardholder_photo_file_name := nvl(i_cardholder_photo_file_name, l_card_instance.cardholder_photo_file_name);
    l_card_instance.cardholder_sign_file_name  := nvl(i_cardholder_sign_file_name, l_card_instance.cardholder_sign_file_name);

    -- fill parameters for generating card_uid
    l_bin := iss_api_bin_pkg.get_bin (
        i_bin_id      => l_card_type.bin_id
    );
    rul_api_param_pkg.set_param (
        io_params     => l_uid_params
      , i_name        => 'BIN'
      , i_value       => l_bin.bin
    );
    rul_api_param_pkg.set_param (
        io_params     => l_uid_params
      , i_name        => 'INDEX'
      , i_value       => l_card_type.index_range_id
    );
    rul_api_param_pkg.set_param (
        io_params     => l_uid_params
      , i_name        => 'INST_ID_CHAR'
      , i_value       => l_card_instance.inst_id
    );
    rul_api_param_pkg.set_param (
        io_params     => l_uid_params
      , i_name        => 'CARD_ID'
      , i_value       => l_card_instance.card_id
    );

    l_agent_number := ost_ui_agent_pkg.get_agent_number(i_agent_id => l_card_instance.agent_id);

    rul_api_param_pkg.set_param (
        io_params     => l_uid_params
      , i_name        => 'AGENT_NUMBER'
      , i_value       => l_agent_number
    );

    l_product_number := prd_api_product_pkg.get_product_number(i_product_id => l_card_type.product_id);

    rul_api_param_pkg.set_param (
        io_params     => l_uid_params
      , i_name        => 'PRODUCT_NUMBER'
      , i_value       => l_product_number
    );
    
    if i_card_uid is not null then
        if check_uid_unique(
               i_card_uid  => i_card_uid
             , i_card_id   => l_card_instance.card_id
           ) = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error       => 'CARD_UID_IS_NOT_UNIQUE'
              , i_env_param1  => i_card_uid
            );
        end if;
        
        l_card_instance.card_uid := i_card_uid;
    else
        generate_uid (
            i_card_id         => l_card_instance.card_id
            , i_inst_id       => l_card_instance.inst_id
            , i_service_id    => l_card_type.service_id
            , i_product_id    => l_card_type.product_id
            , i_split_hash    => null
            , i_uid_format_id => l_card_type.uid_format_id
            , i_params        => l_uid_params
            , o_card_uid      => l_card_instance.card_uid
        );
    end if;

    iss_api_card_instance_pkg.add_card_instance(
        i_card_number       => i_card_number
      , io_card_instance    => l_card_instance
      , i_register_event    => com_api_const_pkg.TRUE
      , i_status_reason     => iss_api_const_pkg.CARD_STATUS_REASON_CARD_ISSUE
      , i_reissue_command   => nvl(i_reissue_command, l_card_type.reiss_command)
      , i_need_postponed_event => i_need_postponed_event
      , io_postponed_event_tab => io_postponed_event_tab
    );

    if l_bin_ok = com_api_const_pkg.TRUE then
        update iss_card_vw
           set card_type_id = l_card_type_id
         where id = get_card_id(i_card_number => i_card_number);
    end if;

exception
    when others then
        rollback to savepoint sp_instance_reissue;
        raise;
end;

procedure get_instance_renewal_data (
    i_card_number           in com_api_type_pkg.t_card_number
    , i_seq_number          in com_api_type_pkg.t_tiny_id
    , o_rowid               out rowid
    , o_id                  out com_api_type_pkg.t_medium_id
    , o_pin_request         out com_api_type_pkg.t_dict_value
    , o_pin_mailer_request  out com_api_type_pkg.t_dict_value
    , o_embossing_request   out com_api_type_pkg.t_dict_value
    , o_state               out com_api_type_pkg.t_dict_value
    , o_pvv                 out com_api_type_pkg.t_tiny_id
    , o_pin_offset          out com_api_type_pkg.t_cmid
    , o_pin_block           out com_api_type_pkg.t_name
    , o_contract_id         out com_api_type_pkg.t_medium_id
    , o_card_type_id        out com_api_type_pkg.t_tiny_id
    , o_pin_verify_method   out com_api_type_pkg.t_dict_value
    , o_inst_id             out com_api_type_pkg.t_inst_id
    , o_split_hash          out com_api_type_pkg.t_tiny_id
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_instance_renewal_data: ';
    l_card_number           com_api_type_pkg.t_card_number;
    l_card_hash             com_api_type_pkg.t_long_id;
begin
    -- For correct usage of the index we should use during the search a value that is stored in the table iss_card_number
    l_card_number := iss_api_token_pkg.encode_card_number(i_card_number => i_card_number);
    l_card_hash   := com_api_hash_pkg.get_card_hash(i_card_number);

    select i.rowid
         , i.id
         , i.pin_request
         , i.pin_mailer_request
         , i.embossing_request
         , i.state
         , d.pvv
         , d.pin_offset
         , d.kcolb_nip
         , c.contract_id
         , c.card_type_id
         , m.pin_verify_method
         , i.inst_id
         , c.split_hash
      into o_rowid
         , o_id
         , o_pin_request
         , o_pin_mailer_request
         , o_embossing_request
         , o_state
         , o_pvv
         , o_pin_offset
         , o_pin_block
         , o_contract_id
         , o_card_type_id
         , o_pin_verify_method
         , o_inst_id
         , o_split_hash
      from iss_card c
         , iss_card_number cn
         , iss_card_instance i
         , iss_card_instance_data d
         , prs_method m
     where c.card_hash             = l_card_hash
       and reverse(cn.card_number) = reverse(l_card_number)
       and cn.card_id              = c.id
       and i.card_id               = c.id
       and i.seq_number            = i_seq_number
       and d.card_instance_id(+)   = i.id
       and m.id(+)                 = i.perso_method_id
    for update of i.state;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'END with o_rowid [' || o_rowid
                     || '], o_id [' || o_id || '], o_pvv [' || o_pvv
                     || '], o_pin_block [' || o_pin_block
                     || '], o_contract_id [' || o_card_type_id
                     || '], o_pin_request [#1], o_pin_mailer_request [#2], '
                     || 'o_embossing_request [#3], o_state [#4], o_pin_verify_method [#5]'
      , i_env_param1 => o_pin_request
      , i_env_param2 => o_pin_mailer_request
      , i_env_param3 => o_embossing_request
      , i_env_param4 => o_state
      , i_env_param5 => o_pin_verify_method
    );
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error         => 'CARD_INSTANCE_NOT_FOUND'
            , i_env_param1  => get_card_mask(i_card_number)
            , i_env_param2  => i_seq_number
        );
end;

procedure instance_renewal(
    i_card_number                  in     com_api_type_pkg.t_card_number
  , i_seq_number                   in     com_api_type_pkg.t_tiny_id
  , i_cardholder_name              in     com_api_type_pkg.t_name
  , i_company_name                 in     com_api_type_pkg.t_name
  , i_agent_id                     in     com_api_type_pkg.t_agent_id
  , i_perso_priority               in     com_api_type_pkg.t_dict_value
  , i_pin_request                  in     com_api_type_pkg.t_dict_value
  , i_pin_mailer_request           in     com_api_type_pkg.t_dict_value
  , i_embossing_request            in     com_api_type_pkg.t_dict_value
  , i_delivery_channel             in     com_api_type_pkg.t_dict_value
  , i_reissue_reason               in     com_api_type_pkg.t_dict_value
  , i_delivery_status              in     com_api_type_pkg.t_dict_value
  , i_embossed_surname             in     com_api_type_pkg.t_name           default null
  , i_embossed_first_name          in     com_api_type_pkg.t_name           default null
  , i_embossed_second_name         in     com_api_type_pkg.t_name           default null
  , i_embossed_title               in     com_api_type_pkg.t_dict_value     default null
  , i_embossed_line_additional     in     com_api_type_pkg.t_name           default null
  , i_supplementary_info_1         in     com_api_type_pkg.t_name           default null
  , i_cardholder_photo_file_name   in     iss_api_type_pkg.t_file_name      default null
  , i_cardholder_sign_file_name    in     iss_api_type_pkg.t_file_name      default null
  , i_need_postponed_event         in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , io_postponed_event_tab         in out nocopy evt_api_type_pkg.t_postponed_event_tab
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.instance_renewal: ';
    l_rowid                 rowid;
    l_id                    com_api_type_pkg.t_medium_id;
    l_pin_request           com_api_type_pkg.t_dict_value;
    l_pin_mailer_request    com_api_type_pkg.t_dict_value;
    l_embossing_request     com_api_type_pkg.t_dict_value;
    l_state                 com_api_type_pkg.t_dict_value;
    l_pvv                   com_api_type_pkg.t_tiny_id;
    l_pin_offset            com_api_type_pkg.t_cmid;
    l_pin_block             com_api_type_pkg.t_name;
    l_contract_id           com_api_type_pkg.t_medium_id;
    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_pin_verify_method     com_api_type_pkg.t_dict_value;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_params                com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_card_number [#1'
                     || '], i_seq_number [' || i_seq_number
                     || '], i_cardholder_name [' || i_cardholder_name
                     || '], i_company_name [' || i_company_name
                     || '], i_agent_id [' || i_agent_id
                     || '], i_perso_priority [#2], i_pin_request [#3], i_pin_mailer_request [#4]'
                     || ', i_embossing_request [#5], i_delivery_channel [#6]'
      , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
      , i_env_param2 => i_perso_priority
      , i_env_param3 => i_pin_request
      , i_env_param4 => i_pin_mailer_request
      , i_env_param5 => i_embossing_request
      , i_env_param6 => i_delivery_channel
    );

    get_instance_renewal_data(
        i_card_number         => i_card_number
      , i_seq_number          => i_seq_number
      , o_rowid               => l_rowid
      , o_id                  => l_id
      , o_pin_request         => l_pin_request
      , o_pin_mailer_request  => l_pin_mailer_request
      , o_embossing_request   => l_embossing_request
      , o_state               => l_state
      , o_pvv                 => l_pvv
      , o_pin_offset          => l_pin_offset
      , o_pin_block           => l_pin_block
      , o_contract_id         => l_contract_id
      , o_card_type_id        => l_card_type_id
      , o_pin_verify_method   => l_pin_verify_method
      , o_inst_id             => l_inst_id
      , o_split_hash          => l_split_hash
    );

    -- process PIN_REQUEST
    case i_pin_request
        when iss_api_const_pkg.PIN_REQUEST_GENERATE then
            l_pin_request := i_pin_request;
            l_pin_mailer_request := iss_api_const_pkg.PIN_MAILER_REQUEST_PRINT;
        when iss_api_const_pkg.PIN_REQUEST_INHERIT then
            if l_pvv is null then
                com_api_error_pkg.raise_error (
                    i_error         => 'INCONSISTENT_PIN_REQUEST'
                  , i_env_param1    => i_pin_request
                );
            end if;
        when iss_api_const_pkg.PIN_REQUEST_DONT_GENERATE then
            l_pin_request := i_pin_request;
            l_pin_mailer_request := i_pin_mailer_request;
        else
            null;
    end case;

    -- process MAILER_REQUEST
    if i_pin_mailer_request = iss_api_const_pkg.PIN_MAILER_REQUEST_PRINT then
        if l_pin_request = iss_api_const_pkg.PIN_REQUEST_GENERATE
           or l_pin_block is not null
           or (
                  l_pin_verify_method in (prs_api_const_pkg.PIN_VERIFIC_METHOD_IBM_3624
                                        , prs_api_const_pkg.PIN_VERIFIC_METHOD_COMBINED)
                  and l_pin_offset is not null
           )
        then
            l_pin_mailer_request := i_pin_mailer_request;
        else
            com_api_error_pkg.raise_error(
                i_error       => 'INCONSISTENT_PIN_MAILER_REQUEST'
              , i_env_param1  => i_pin_mailer_request
            );
        end if;
    end if;

    -- process EMBOSSING
    if i_embossing_request in (iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS
                             , iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS)
    then
        l_embossing_request := i_embossing_request;
    end if;

    if  l_pin_request           = iss_api_const_pkg.PIN_REQUEST_GENERATE
        or l_pin_mailer_request = iss_api_const_pkg.PIN_MAILER_REQUEST_PRINT
        or l_embossing_request  = iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS
    then
        l_state := iss_api_const_pkg.CARD_STATE_PERSONALIZATION;
    end if;

    if i_reissue_reason = iss_api_const_pkg.EVENT_TYPE_PIN_REISSUE then
        update iss_card_instance i
           set i.pin_request              = l_pin_request
             , i.pin_mailer_request       = l_pin_mailer_request
             , i.embossing_request        = l_embossing_request
             , i.state                    = l_state
             , i.supplementary_info_1     = nvl(i_supplementary_info_1,     i.supplementary_info_1)
         where i.rowid = l_rowid;
    else
        update iss_card_instance i
           set i.agent_id                 = nvl(i_agent_id,                 i.agent_id)
             , i.cardholder_name          = nvl(upper(i_cardholder_name),   i.cardholder_name)
             , i.company_name             = nvl(i_company_name,             i.company_name)
             , i.perso_priority           = nvl(i_perso_priority,           iss_api_const_pkg.PERSO_PRIORITY_NORMAL)
             , i.pin_request              = l_pin_request
             , i.pin_mailer_request       = l_pin_mailer_request
             , i.embossing_request        = l_embossing_request
             , i.state                    = l_state
             , i.delivery_channel         = i_delivery_channel
             , i.delivery_status          = nvl(i_delivery_status,          i.delivery_status)
             , i.embossed_surname         = nvl(i_embossed_surname,         i.embossed_surname)
             , i.embossed_first_name      = nvl(i_embossed_first_name,      i.embossed_first_name)
             , i.embossed_second_name     = nvl(i_embossed_second_name,     i.embossed_second_name)
             , i.embossed_title           = nvl(i_embossed_title,           i.embossed_title)
             , i.embossed_line_additional = nvl(i_embossed_line_additional, i.embossed_line_additional)
             , i.supplementary_info_1     = nvl(i_supplementary_info_1,     i.supplementary_info_1)
         where i.rowid = l_rowid;
    end if;

    if i_reissue_reason = iss_api_const_pkg.CYCLE_AUTO_REISSUE then
        -- An instance renewal isn't allowed on event <iss_api_const_pkg.CYCLE_AUTO_REISSUE>
        -- to avoid registering and processing the same event with the subsequent infinite loop.
        com_api_error_pkg.raise_error(
            i_error        => 'IMPOSSIBLE_TO_RENEW_INSTANCE'
          , i_env_param1   => i_reissue_reason
        );
    elsif i_reissue_reason is not null then
        evt_api_event_pkg.register_event(
            i_event_type            => i_reissue_reason
          , i_eff_date              => com_api_sttl_day_pkg.get_calc_date(l_inst_id)
          , i_entity_type           => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id             => l_id
          , i_inst_id               => l_inst_id
          , i_split_hash            => l_split_hash
          , i_param_tab             => l_params
          , i_need_postponed_event  => i_need_postponed_event
          , io_postponed_event_tab  => io_postponed_event_tab
        );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'END with l_state [#1], l_pin_request [#2'
                     || '], l_pin_mailer_request [#3], l_embossing_request [#4]'
      , i_env_param1 => l_state
      , i_env_param2 => l_pin_request
      , i_env_param3 => l_pin_mailer_request
      , i_env_param4 => l_embossing_request
    );
end instance_renewal;

procedure reissue(
    i_card_number                  in     com_api_type_pkg.t_card_number
  , io_seq_number                  in out com_api_type_pkg.t_tiny_id
  , io_card_number                 in out com_api_type_pkg.t_card_number
  , i_command                      in     com_api_type_pkg.t_dict_value    default null
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default null
  , i_contract_id                  in     com_api_type_pkg.t_medium_id     default null
  , i_card_type_id                 in     com_api_type_pkg.t_tiny_id       default null
  , i_category                     in     com_api_type_pkg.t_dict_value    default null
  , i_start_date                   in     date                             default null
  , i_start_date_rule              in     com_api_type_pkg.t_dict_value    default null
  , io_expir_date                  in out date
  , i_expir_date_rule              in     com_api_type_pkg.t_dict_value    default null
  , i_cardholder_name              in     com_api_type_pkg.t_name          default null
  , i_company_name                 in     com_api_type_pkg.t_name          default null
  , i_perso_priority               in     com_api_type_pkg.t_dict_value    default null
  , i_pin_request                  in     com_api_type_pkg.t_dict_value    default null
  , i_pin_mailer_request           in     com_api_type_pkg.t_dict_value    default null
  , i_embossing_request            in     com_api_type_pkg.t_dict_value    default null
  , i_delivery_channel             in     com_api_type_pkg.t_dict_value    default null
  , i_blank_type_id                in     com_api_type_pkg.t_tiny_id       default null
  , i_reissue_reason               in     com_api_type_pkg.t_dict_value    default null
  , i_reissue_date                 in     date                             default null
  , i_clone_optional_services      in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_delivery_status              in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_surname             in     com_api_type_pkg.t_name          default null
  , i_embossed_first_name          in     com_api_type_pkg.t_name          default null
  , i_embossed_second_name         in     com_api_type_pkg.t_name          default null
  , i_embossed_title               in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_line_additional     in     com_api_type_pkg.t_name          default null
  , i_supplementary_info_1         in     com_api_type_pkg.t_name          default null
  , i_cardholder_photo_file_name   in     iss_api_type_pkg.t_file_name     default null
  , i_cardholder_sign_file_name    in     iss_api_type_pkg.t_file_name     default null
  , i_card_uid                     in     com_api_type_pkg.t_name          default null
  , i_inherit_pin_offset           in     com_api_type_pkg.t_boolean       default null
) is
    l_postponed_event_tab                 evt_api_type_pkg.t_postponed_event_tab;
begin
    reissue(
        i_card_number                 => i_card_number
      , io_seq_number                 => io_seq_number
      , io_card_number                => io_card_number
      , i_command                     => i_command
      , i_agent_id                    => i_agent_id
      , i_contract_id                 => i_contract_id
      , i_card_type_id                => i_card_type_id
      , i_category                    => i_category
      , i_start_date                  => i_start_date
      , i_start_date_rule             => i_start_date_rule
      , io_expir_date                 => io_expir_date
      , i_expir_date_rule             => i_expir_date_rule
      , i_cardholder_name             => i_cardholder_name
      , i_company_name                => i_company_name
      , i_perso_priority              => i_perso_priority
      , i_pin_request                 => i_pin_request
      , i_pin_mailer_request          => i_pin_mailer_request
      , i_embossing_request           => i_embossing_request
      , i_delivery_channel            => i_delivery_channel
      , i_blank_type_id               => i_blank_type_id
      , i_reissue_reason              => i_reissue_reason
      , i_reissue_date                => i_reissue_date
      , i_clone_optional_services     => i_clone_optional_services
      , i_delivery_status             => i_delivery_status
      , i_embossed_surname            => i_embossed_surname
      , i_embossed_first_name         => i_embossed_first_name
      , i_embossed_second_name        => i_embossed_second_name
      , i_embossed_title              => i_embossed_title
      , i_embossed_line_additional    => i_embossed_line_additional
      , i_supplementary_info_1        => i_supplementary_info_1
      , i_cardholder_photo_file_name  => i_cardholder_photo_file_name
      , i_cardholder_sign_file_name   => i_cardholder_sign_file_name
      , i_card_uid                    => i_card_uid
      , i_inherit_pin_offset          => i_inherit_pin_offset
      , i_need_postponed_event        => com_api_const_pkg.FALSE
      , io_postponed_event_tab        => l_postponed_event_tab
    );
end reissue;

procedure reissue(
    i_card_number                  in     com_api_type_pkg.t_card_number
  , io_seq_number                  in out com_api_type_pkg.t_tiny_id
  , io_card_number                 in out com_api_type_pkg.t_card_number
  , i_command                      in     com_api_type_pkg.t_dict_value    default null
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default null
  , i_contract_id                  in     com_api_type_pkg.t_medium_id     default null
  , i_card_type_id                 in     com_api_type_pkg.t_tiny_id       default null
  , i_category                     in     com_api_type_pkg.t_dict_value    default null
  , i_start_date                   in     date                             default null
  , i_start_date_rule              in     com_api_type_pkg.t_dict_value    default null
  , io_expir_date                  in out date
  , i_expir_date_rule              in     com_api_type_pkg.t_dict_value    default null
  , i_cardholder_name              in     com_api_type_pkg.t_name          default null
  , i_company_name                 in     com_api_type_pkg.t_name          default null
  , i_perso_priority               in     com_api_type_pkg.t_dict_value    default null
  , i_pin_request                  in     com_api_type_pkg.t_dict_value    default null
  , i_pin_mailer_request           in     com_api_type_pkg.t_dict_value    default null
  , i_embossing_request            in     com_api_type_pkg.t_dict_value    default null
  , i_delivery_channel             in     com_api_type_pkg.t_dict_value    default null
  , i_blank_type_id                in     com_api_type_pkg.t_tiny_id       default null
  , i_reissue_reason               in     com_api_type_pkg.t_dict_value    default null
  , i_reissue_date                 in     date                             default null
  , i_clone_optional_services      in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_delivery_status              in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_surname             in     com_api_type_pkg.t_name          default null
  , i_embossed_first_name          in     com_api_type_pkg.t_name          default null
  , i_embossed_second_name         in     com_api_type_pkg.t_name          default null
  , i_embossed_title               in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_line_additional     in     com_api_type_pkg.t_name          default null
  , i_supplementary_info_1         in     com_api_type_pkg.t_name          default null
  , i_cardholder_photo_file_name   in     iss_api_type_pkg.t_file_name     default null
  , i_cardholder_sign_file_name    in     iss_api_type_pkg.t_file_name     default null
  , i_card_uid                     in     com_api_type_pkg.t_name          default null
  , i_inherit_pin_offset           in     com_api_type_pkg.t_boolean       default null
  , i_need_postponed_event         in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , io_postponed_event_tab         in out nocopy evt_api_type_pkg.t_postponed_event_tab
) is
    LOG_PREFIX     constant com_api_type_pkg.t_oracle_name := lower($$PLSQL_UNIT) || '.reissue: ';

    l_card_type             iss_api_type_pkg.t_product_card_type_rec;
    l_card_rec              iss_api_type_pkg.t_card_rec;
    l_count                 com_api_type_pkg.t_tiny_id;
    l_old_contract_type     com_api_type_pkg.t_dict_value;
    l_new_contract_type     com_api_type_pkg.t_dict_value;
    l_contract_seqnum       com_api_type_pkg.t_tiny_id;
    l_contract_number       com_api_type_pkg.t_name;
    l_agent_id              com_api_type_pkg.t_agent_id;

begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_card_number [#1], io_card_number [#2], i_command [#3], '
                                   || 'i_agent_id [#4], i_contract_id [#5], i_card_type_id [#6]'
      , i_env_param1 => get_card_mask(i_card_number)
      , i_env_param2 => get_card_mask(io_card_number)
      , i_env_param3 => i_command
      , i_env_param4 => i_agent_id
      , i_env_param5 => i_contract_id
      , i_env_param6 => i_card_type_id
    );

    if io_seq_number is null then
        io_seq_number := get_seq_number(i_card_number);
    end if;

    l_card_rec := get_card(i_card_number => i_card_number);

    l_card_type := iss_api_product_pkg.get_product_card_type(
        i_contract_id       => nvl(i_contract_id, l_card_rec.contract_id)
        , i_card_type_id    => nvl(i_card_type_id, l_card_rec.card_type_id)
        , i_seq_number      => io_seq_number
    );

    -- Get agent_id from previous contract
    select agent_id
      into l_agent_id
      from prd_contract
     where id = nvl(i_contract_id, l_card_rec.contract_id);
     
    iss_cst_card_pkg.get_product_card_type(
        io_card_type    => l_card_type
      , io_card         => l_card_rec
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_card_type.reiss_product_id [#1], l_card_type.reiss_bin_id [#2]'
      , i_env_param1 => l_card_type.reiss_product_id
      , i_env_param2 => l_card_type.reiss_bin_id
    );

    if l_card_type.reiss_product_id is not null
       and l_card_type.product_id   != l_card_type.reiss_product_id
       and (
               i_reissue_reason     is null
               or i_reissue_reason  != iss_api_const_pkg.EVENT_TYPE_PIN_REISSUE
           )
    then

        -- save old contract type of product
        l_old_contract_type := prd_api_product_pkg.get_product_contract_type(i_product_id => l_card_type.product_id);
        l_new_contract_type := prd_api_product_pkg.get_product_contract_type(i_product_id => l_card_type.reiss_product_id);

        -- check if contract type not equal
        if l_old_contract_type != l_new_contract_type then
            com_api_error_pkg.raise_error(
                i_error      => 'WRONG_CONTRACT_TYPE'
              , i_env_param1 => l_new_contract_type
              , i_env_param2 => l_card_type.reiss_product_id
            );
        end if;

        l_card_type := iss_api_product_pkg.get_product_card_type(
            i_product_id        => l_card_type.reiss_product_id
            , i_card_type_id    => l_card_type.reiss_card_type_id
            , i_seq_number      => io_seq_number
            , i_bin_id          => l_card_type.reiss_bin_id
        );

        -- check services exists on new product
        for rec in (
            select o.service_id
              from prd_service_object o
                 , prd_service s
             where o.object_id    = l_card_rec.id
               and o.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
               and o.status       = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
               and (o.end_date is null or o.end_date >= sysdate)
               and s.id           = o.service_id
               and s.status       = prd_api_const_pkg.SERVICE_STATUS_ACTIVE
        ) loop
            select count(1)
              into l_count
              from prd_product_service ps
                 , prd_service s
             where product_id = l_card_type.product_id
               and s.id       = ps.service_id
               and s.status   = prd_api_const_pkg.SERVICE_STATUS_ACTIVE
               and s.id       = rec.service_id;

            if l_count = 0 then
                com_api_error_pkg.raise_error(
                    i_error      => 'SERVICE_NOT_FOUND_ON_PRODUCT'
                  , i_env_param1 => rec.service_id
                  , i_env_param2 => l_card_type.product_id
                );
            end if;
        end loop;

        -- create contract
        prd_api_contract_pkg.add_contract (
            o_id                  => l_card_rec.contract_id
          , o_seqnum              => l_contract_seqnum
          , i_product_id          => l_card_type.product_id
          , i_start_date          => null
          , i_end_date            => null
          , io_contract_number    => l_contract_number
          , i_contract_type       => l_new_contract_type
          , i_inst_id             => l_card_rec.inst_id
          , i_agent_id            => nvl(i_agent_id, l_agent_id)
          , i_customer_id         => l_card_rec.customer_id
          , i_lang                => com_ui_user_env_pkg.get_user_lang
          , i_label               => null
          , i_description         => null
        );

        l_card_type.reiss_contract_id  := l_card_rec.contract_id;
        l_card_type.reiss_card_type_id := l_card_type.card_type_id;
        l_card_type.reiss_command      := iss_api_const_pkg.REISS_COMMAND_NEW_NUMBER;

    elsif i_command is not null then
        l_card_type.reiss_contract_id  := i_contract_id;
        l_card_type.reiss_card_type_id := i_card_type_id;
        l_card_type.reiss_command      := i_command;
    end if;

    if i_command is not null then
        l_card_type.pin_request := i_pin_request;
        l_card_type.pin_mailer_request := i_pin_mailer_request;
        l_card_type.embossing_request := i_embossing_request;
        l_card_type.reiss_start_date_rule := i_start_date_rule;
        l_card_type.reiss_expir_date_rule := i_expir_date_rule;
        l_card_type.blank_type_id := i_blank_type_id;
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_card_type = {reiss_command [#1], reiss_contract_id [#2], reiss_card_type_id [#3]}'
      , i_env_param1 => l_card_type.reiss_command
      , i_env_param2 => l_card_type.reiss_contract_id
      , i_env_param3 => l_card_type.reiss_card_type_id
    );
    l_card_type.perso_priority := nvl(i_perso_priority, l_card_type.perso_priority);

    case l_card_type.reiss_command
        when iss_api_const_pkg.REISS_COMMAND_RENEWAL then
            io_card_number := i_card_number;

            instance_renewal(
                i_card_number                => i_card_number
              , i_seq_number                 => io_seq_number
              , i_cardholder_name            => i_cardholder_name
              , i_company_name               => i_company_name
              , i_agent_id                   => i_agent_id
              , i_perso_priority             => l_card_type.perso_priority
              , i_pin_request                => l_card_type.pin_request
              , i_pin_mailer_request         => l_card_type.pin_mailer_request
              , i_embossing_request          => l_card_type.embossing_request
              , i_delivery_channel           => i_delivery_channel
              , i_reissue_reason             => i_reissue_reason
              , i_delivery_status            => i_delivery_status
              , i_embossed_surname           => i_embossed_surname
              , i_embossed_first_name        => i_embossed_first_name
              , i_embossed_second_name       => i_embossed_second_name
              , i_embossed_title             => i_embossed_title
              , i_embossed_line_additional   => i_embossed_line_additional
              , i_supplementary_info_1       => i_supplementary_info_1
              , i_cardholder_photo_file_name => i_cardholder_photo_file_name
              , i_cardholder_sign_file_name  => i_cardholder_sign_file_name
              , i_need_postponed_event       => i_need_postponed_event
              , io_postponed_event_tab       => io_postponed_event_tab
            );

        when iss_api_const_pkg.REISS_COMMAND_OLD_NUMBER then
            io_card_number := i_card_number;

            instance_reissue(
                i_card_number                => i_card_number
              , io_seq_number                => io_seq_number
              , i_agent_id                   => i_agent_id
              , i_start_date                 => i_start_date
              , i_start_date_rule            => l_card_type.reiss_start_date_rule
              , io_expir_date                => io_expir_date
              , i_expir_date_rule            => l_card_type.reiss_expir_date_rule
              , i_cardholder_name            => i_cardholder_name
              , i_company_name               => i_company_name
              , i_perso_priority             => i_perso_priority
              , i_pin_request                => i_pin_request
              , i_pin_mailer_request         => i_pin_mailer_request
              , i_embossing_request          => i_embossing_request
              , i_delivery_channel           => i_delivery_channel
              , i_blank_type_id              => l_card_type.blank_type_id
              , i_reissue_reason             => i_reissue_reason
              , i_reissue_date               => i_reissue_date
              , i_card_type_id               => l_card_type.reiss_card_type_id
              , i_delivery_status            => i_delivery_status
              , i_embossed_surname           => i_embossed_surname
              , i_embossed_first_name        => i_embossed_first_name
              , i_embossed_second_name       => i_embossed_second_name
              , i_embossed_title             => i_embossed_title
              , i_embossed_line_additional   => i_embossed_line_additional
              , i_supplementary_info_1       => i_supplementary_info_1
              , i_cardholder_photo_file_name => i_cardholder_photo_file_name
              , i_cardholder_sign_file_name  => i_cardholder_sign_file_name
              , i_card_uid                   => i_card_uid
              , i_inherit_pin_offset         => i_inherit_pin_offset
              , i_reissue_command            => l_card_type.reiss_command
              , i_need_postponed_event       => i_need_postponed_event
              , io_postponed_event_tab       => io_postponed_event_tab
            );

        when iss_api_const_pkg.REISS_COMMAND_NEW_NUMBER then
            if io_card_number = i_card_number then
                io_card_number := null;
            end if;

            card_reissue(
                i_card_number                => i_card_number
              , i_seq_number                 => io_seq_number
              , io_card_number               => io_card_number
              , i_agent_id                   => i_agent_id
              , i_contract_id                => l_card_type.reiss_contract_id
              , i_card_type_id               => l_card_type.reiss_card_type_id
              , i_category                   => i_category
              , i_start_date                 => i_start_date
              , i_start_date_rule            => l_card_type.reiss_start_date_rule
              , io_expir_date                => io_expir_date
              , i_expir_date_rule            => l_card_type.reiss_expir_date_rule
              , i_cardholder_name            => i_cardholder_name
              , i_company_name               => i_company_name
              , i_perso_priority             => i_perso_priority
              , i_pin_request                => i_pin_request
              , i_pin_mailer_request         => i_pin_mailer_request
              , i_embossing_request          => i_embossing_request
              , i_delivery_channel           => i_delivery_channel
              , i_blank_type_id              => l_card_type.blank_type_id
              , i_reissue_reason             => i_reissue_reason
              , i_reissue_date               => i_reissue_date
              , i_clone_optional_services    => i_clone_optional_services
              , i_delivery_status            => i_delivery_status
              , i_embossed_surname           => i_embossed_surname
              , i_embossed_first_name        => i_embossed_first_name
              , i_embossed_second_name       => i_embossed_second_name
              , i_embossed_title             => i_embossed_title
              , i_embossed_line_additional   => i_embossed_line_additional
              , i_supplementary_info_1       => i_supplementary_info_1
              , i_cardholder_photo_file_name => i_cardholder_photo_file_name
              , i_cardholder_sign_file_name  => i_cardholder_sign_file_name
              , i_card_uid                   => i_card_uid
              , i_reissue_command            => l_card_type.reiss_command
              , i_need_postponed_event       => i_need_postponed_event
              , io_postponed_event_tab       => io_postponed_event_tab
            );

            io_seq_number := l_card_type.seq_number_low;

        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_REISSUE_COMMAND'
                , i_env_param1  => l_card_type.reiss_command
            );
    end case;

    trc_log_pkg.debug(i_text => LOG_PREFIX || 'END');
end reissue;

procedure activate_card(
    i_card_instance_id          in     com_api_type_pkg.t_medium_id
  , i_initial_status            in     com_api_type_pkg.t_dict_value
  , i_status                    in     com_api_type_pkg.t_dict_value
  , i_params                    in     com_api_type_pkg.t_param_tab
) is
begin
    evt_api_status_pkg.change_status(
        i_event_type    => iss_api_const_pkg.EVENT_TYPE_CARD_ACTIVATION
      , i_initiator     => evt_api_const_pkg.INITIATOR_SYSTEM
      , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
      , i_object_id     => i_card_instance_id
      , i_reason        => iss_api_const_pkg.CARD_STATUS_REASON_CARD_ISSUE
      , i_params        => i_params
    );
end activate_card;

procedure activate_card(
    i_card_instance_id          in     com_api_type_pkg.t_medium_id
  , i_initial_status            in     com_api_type_pkg.t_dict_value
  , i_status                    in     com_api_type_pkg.t_dict_value
) is
    l_params                           com_api_type_pkg.t_param_tab;
begin
    activate_card(
        i_card_instance_id  => i_card_instance_id
      , i_initial_status    => i_initial_status
      , i_status            => i_status
      , i_params            => l_params
    );
end activate_card;

procedure deactivate_card (
    i_card_instance_id      in com_api_type_pkg.t_medium_id
    , i_status              in com_api_type_pkg.t_dict_value
) is
    l_params    com_api_type_pkg.t_param_tab;
    l_status    com_api_type_pkg.t_dict_value;
begin
    evt_api_status_pkg.change_status(
        i_event_type    => iss_api_const_pkg.EVENT_TYPE_CARD_DEACTIVATION
      , i_initiator     => evt_api_const_pkg.INITIATOR_SYSTEM
      , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
      , i_object_id     => i_card_instance_id
      , i_reason        => iss_api_const_pkg.CARD_STATUS_REASON_PC_REGUL
      , i_params        => l_params
    );

    evt_api_status_pkg.change_status(
        i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
      , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
      , i_object_id      => i_card_instance_id
      , i_new_status     => iss_api_const_pkg.CARD_STATE_CLOSED
      , i_reason         => iss_api_const_pkg.CARD_STATUS_REASON_PC_REGUL
      , o_status         => l_status
      , i_raise_error    => com_api_const_pkg.FALSE
      , i_register_event => com_api_const_pkg.FALSE
      , i_params         => l_params
    );

    remove_reissue_cycle(
        i_card_instance_id      => i_card_instance_id
      , i_split_hash            => null
    );

end deactivate_card;

procedure get_card_limits (
    i_card_id                   in    com_api_type_pkg.t_medium_id
    , i_lang                    in    com_api_type_pkg.t_dict_value
    , o_card_limits             out   iss_api_type_pkg.t_limit_tab
) is
    l_lang              com_api_type_pkg.t_dict_value;
begin
    l_lang := nvl(i_lang, get_user_lang);

    select a.id
         , com_api_dictionary_pkg.get_article_text(a.limit_type, l_lang)
         , com_api_dictionary_pkg.get_article_desc(a.limit_type, l_lang)
         , a.sum_limit
         , a.sum_value
         , a.limit_type
      bulk collect into
           o_card_limits
      from fcl_ui_limit_counter_vw a
     where object_id   = i_card_id
       and entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD;
end get_card_limits;

procedure get_card_phones (
    i_card_id                   in    com_api_type_pkg.t_medium_id
    , o_phone_tab               out   iss_api_type_pkg.t_phone_tab
) is
    l_customer_id                   com_api_type_pkg.t_medium_id;
    l_cardholder_id                 com_api_type_pkg.t_medium_id;
begin
    select customer_id
         , cardholder_id
      into l_customer_id
         , l_cardholder_id
      from iss_card
     where id = i_card_id;

    select distinct i_card_id
         , v.delivery_address
      bulk collect into
           o_phone_tab
      from (
          select e.delivery_address
               , e.end_date
            from ntf_custom_event e
               , ntf_custom_object o
           where e.object_id = l_customer_id
             and e.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
             and e.id = o.custom_event_id(+)
             and e.status != ntf_api_const_pkg.STATUS_DO_NOT_SEND
             and (e.status != ntf_api_const_pkg.STATUS_SEND_SERVICE_ACTIVE
                  or
                  (e.status = ntf_api_const_pkg.STATUS_SEND_SERVICE_ACTIVE
                   and nvl(nvl(e.is_active, o.is_active), com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE)
                 )
             and (e.end_date is null or e.end_date > com_api_sttl_day_pkg.get_sysdate)
          union
          select e.delivery_address
               , e.end_date
            from ntf_custom_event e
               , ntf_custom_object o
           where e.object_id = l_cardholder_id
             and e.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
             and e.id = o.custom_event_id(+)
             and e.status != ntf_api_const_pkg.STATUS_DO_NOT_SEND
             and (e.status != ntf_api_const_pkg.STATUS_SEND_SERVICE_ACTIVE
                  or
                  (e.status = ntf_api_const_pkg.STATUS_SEND_SERVICE_ACTIVE
                   and nvl(nvl(e.is_active, o.is_active), com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE)
                 )
             and (e.end_date is null or e.end_date > com_api_sttl_day_pkg.get_sysdate)
      ) v;

exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error                 => 'CARD_NOT_FOUND'
            , i_env_param1          => i_card_id
        );
end get_card_phones;

/*
 * Function returns number of visible digits from beginning of a card number in according to current system settings.
 */
function get_begin_visible_char return com_api_type_pkg.t_tiny_id is
begin
    return nvl(set_ui_value_pkg.get_system_param_n(i_param_name => 'BEGIN_VISIBLE_CHAR')
             , iss_api_const_pkg.DEFAULT_BEGIN_CHAR);
end;

/*
 * Function returns number of visible digits from ending of a card number in according to current system settings.
 */
function get_end_visible_char return com_api_type_pkg.t_tiny_id is
begin
    return nvl(set_ui_value_pkg.get_system_param_n(i_param_name => 'END_VISIBLE_CHAR')
             , iss_api_const_pkg.DEFAULT_END_CHAR);
end;

function get_card_mask(
    i_card_number           in     com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_card_number
is
    l_card_number                  com_api_type_pkg.t_card_number;
begin
    -- If tokenizator is used and i_card_number is tokenized and begin or end char is greatest than default
    -- we should decode card number and make mask by card number.
    if     iss_api_token_pkg.is_token_enabled() = com_api_type_pkg.TRUE 
       and not regexp_like(i_card_number, '^[0-9]*$')
       and (g_begin_char > iss_api_const_pkg.LENGTH_OF_PLAIN_PAN_BEGINNING
         or g_end_char   > iss_api_const_pkg.LENGTH_OF_PLAIN_PAN_ENDING)
    then
        l_card_number := iss_api_token_pkg.decode_card_number(i_card_number => i_card_number);
    else
        l_card_number := i_card_number;
    end if;

    return
        case
            when length(l_card_number) >= iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
            then substr(l_card_number, 1, g_begin_char) ||
                 lpad('*', length(l_card_number) - (g_begin_char + g_end_char), '*') ||
                 substr(l_card_number, -g_end_char)
            else l_card_number
        end;
end;

function get_short_card_mask(
    i_card_number           in     com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_card_number
is
begin
    return '*' || substr(i_card_number, -4);
end;

procedure reload_settings is
begin
    g_begin_char := get_begin_visible_char();
    g_end_char   := get_end_visible_char();
end;

function get_card_limit_balance(
    i_card_id           in     com_api_type_pkg.t_medium_id
    , i_eff_date        in     date
    , i_inst_id         in     com_api_type_pkg.t_inst_id
    , i_currency        in     com_api_type_pkg.t_curr_code
    , o_array_id        out    com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_money
is
    l_service_id        com_api_type_pkg.t_medium_id;
    l_product_id        com_api_type_pkg.t_short_id;
    l_limit_amount      com_api_type_pkg.t_money;
begin
    l_product_id    := prd_api_product_pkg.get_product_id (
                           i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
                           , i_object_id     => i_card_id
                       );

    l_service_id    := prd_api_service_pkg.get_active_service_id(
                           i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                           , i_object_id   => i_card_id
                           , i_attr_name   => 'ISS_CARD_LIMITS_FOR_AVAL_BALANCE'
                           , i_eff_date    => i_eff_date
                           , i_last_active => com_api_type_pkg.TRUE
                       );

    begin
        o_array_id  := prd_api_product_pkg.get_attr_value_number(
                           i_product_id     => l_product_id
                           , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
                           , i_object_id    => i_card_id
                           , i_attr_name    => 'ISS_CARD_LIMITS_FOR_AVAL_BALANCE'
                           , i_params       => opr_api_shared_data_pkg.g_params
                           , i_service_id   => l_service_id
                           , i_eff_date     => i_eff_date
                           , i_inst_id      => i_inst_id
                       );
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error = 'ATTRIBUTE_VALUE_NOT_DEFINED' then
                o_array_id := null;
            else
                raise;
            end if;
        when others then
            trc_log_pkg.debug('Get attribute value error. '||sqlerrm);
            raise;
    end;

    if o_array_id is not null then

        select sum_value
          into l_limit_amount
          from (
                select limit_id
                     , sum_value
                  from (
                    select l.sum_limit
                         , l.currency
                         , case when l.currency != i_currency then
                                    round(
                                        com_api_rate_pkg.convert_amount(
                                            i_src_amount        => (l.sum_limit - nvl(fcl_api_limit_pkg.get_limit_sum_curr(l.limit_type, iss_api_const_pkg.ENTITY_TYPE_CARD, i_card_id, t.limit_id), 0))
                                          , i_src_currency      => l.currency              -- currency of limit
                                          , i_dst_currency      => i_currency              -- incoming currency
                                          , i_rate_type         => r.rate_type
                                          , i_inst_id           => i_inst_id
                                          , i_eff_date          => i_eff_date
                                        ))
                                else
                                    l.sum_limit - nvl(fcl_api_limit_pkg.get_limit_sum_curr(l.limit_type, iss_api_const_pkg.ENTITY_TYPE_CARD, i_card_id, t.limit_id), 0)
                           end sum_value
                         , r.rate_type
                         , t.limit_id
                      from fcl_limit l
                         , fcl_limit_rate r
                         , (
                            select element_value
                                 , fcl_ui_limit_pkg.get_limit_id(i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                               , i_object_id   => i_card_id
                                                               , i_limit_type  => element_value
                                                               , i_inst_id     => i_inst_id
                                                               ) limit_id
                              from com_array_element
                             where array_id = o_array_id
                            ) t
                      where l.id         = t.limit_id
                        and r.inst_id    = i_inst_id
                        and r.limit_type = l.limit_type
                    ) s
                order by sum_value
                ) t
        where rownum = 1;

        return l_limit_amount;

    else
        return 0;

    end if;
end;

function get_card_limit_balance(
    i_card_id                 in     com_api_type_pkg.t_medium_id
  , i_eff_date                in     date 
  , i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_currency                in     com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_money
is
    l_array_id                       com_api_type_pkg.t_medium_id;
begin
    return get_card_limit_balance(
               i_card_id         => i_card_id
             , i_eff_date        => i_eff_date
             , i_inst_id         => i_inst_id
             , i_currency        => i_currency
             , o_array_id        => l_array_id
           );
end;

function get_card_agent_number(
    i_card_id           in com_api_type_pkg.t_medium_id     default null
  , i_card_number       in com_api_type_pkg.t_card_number   default null
  , i_inst_id           in com_api_type_pkg.t_inst_id       default null
  , i_mask_error        in com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_name
is
    l_agent_number      com_api_type_pkg.t_name;
    l_card_hash         com_api_type_pkg.t_long_id;
    l_card_number       com_api_type_pkg.t_card_number;
begin
    if i_card_id is not null then
        select ost_ui_agent_pkg.get_agent_number(i_agent_id => p.agent_id)
          into l_agent_number
          from iss_card     c
             , prd_contract p
         where c.id          = i_card_id
           and c.contract_id = p.id
           and c.split_hash  = p.split_hash;
    elsif i_card_number is not null then
        l_card_number := iss_api_token_pkg.encode_card_number(i_card_number => i_card_number);
        l_card_hash   := com_api_hash_pkg.get_card_hash(i_card_number);

        select ost_ui_agent_pkg.get_agent_number(i_agent_id => p.agent_id)
          into l_agent_number
          from iss_card c
             , iss_card_number cn
             , prd_contract p
         where c.id                    = cn.card_id
           and c.card_hash             = l_card_hash
           and reverse(cn.card_number) = reverse(l_card_number)
           and p.id                    = c.contract_id
           and p.split_hash            = c.split_hash
           and (c.inst_id              = i_inst_id or i_inst_id is null);
    else
        l_agent_number := null;
    end if;

    return l_agent_number;
exception
    when no_data_found then
        if i_mask_error = com_api_const_pkg.TRUE then
            return null;
        else
            com_api_error_pkg.raise_error(
                i_error       => 'CARD_NOT_FOUND'
              , i_env_param1  => get_card_mask(i_card_number => i_card_number)
              , i_env_param2  => i_inst_id
            );
        end if;
end;

function get_card (
    i_card_uid          in     com_api_type_pkg.t_name
  , i_inst_id           in     com_api_type_pkg.t_inst_id  default null
  , i_mask_error        in     com_api_type_pkg.t_boolean  := com_api_const_pkg.TRUE
) return iss_api_type_pkg.t_card_rec is
    l_result            iss_api_type_pkg.t_card_rec;
begin
    select c.id
         , c.split_hash
         , c.card_hash
         , c.card_mask
         , c.inst_id
         , c.card_type_id
         , c.country
         , c.customer_id
         , c.cardholder_id
         , c.contract_id
         , c.reg_date
         , c.category
         , iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number
      into l_result
      from iss_card c
         , iss_card_number cn
         , iss_card_instance i
     where reverse(i.card_uid) = reverse(i_card_uid)
       and i.id                = (select max(id) 
                                    from iss_card_instance 
                                   where reverse(card_uid) = reverse(i_card_uid)
                                     and (inst_id = i_inst_id or i_inst_id is null))
       and c.id                = i.card_id
       and cn.card_id          = c.id
       and (c.inst_id          = i_inst_id or i_inst_id is null);

    return l_result;

exception
    when no_data_found then
        if i_mask_error = com_api_const_pkg.TRUE then
            return null;
        else
            com_api_error_pkg.raise_error (
                i_error       => 'CARD_NOT_FOUND'
              , i_env_param1  => i_card_uid
              , i_env_param2  => i_inst_id
            );
        end if;
end;

function get_card(
    i_card_instance_id  in     com_api_type_pkg.t_long_id
  , i_mask_error        in     com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE
) return iss_api_type_pkg.t_card_rec is
    l_result            iss_api_type_pkg.t_card_rec;
begin
    select c.id
         , c.split_hash
         , c.card_hash
         , c.card_mask
         , c.inst_id
         , c.card_type_id
         , c.country
         , c.customer_id
         , c.cardholder_id
         , c.contract_id
         , c.reg_date
         , c.category
         , iss_api_token_pkg.decode_card_number(i_card_number => n.card_number) as card_number
      into l_result
      from iss_card          c
         , iss_card_instance i
         , iss_card_number   n
     where i.id      = i_card_instance_id
       and c.id      = i.card_id
       and n.card_id = c.id;

    return l_result;

exception
    when no_data_found then
        if i_mask_error = com_api_const_pkg.TRUE then
            return null;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'CARD_IS_NOT_FOUND_BY_INSTANCE'
              , i_env_param1 => i_card_instance_id
            );
        end if;
end;

function get_card_number (
    i_card_uid         in     com_api_type_pkg.t_name
  , i_inst_id          in     com_api_type_pkg.t_inst_id       default null
  , o_card_id             out com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_card_number is
    l_card            iss_api_type_pkg.t_card_rec;
begin
    l_card := get_card(
                  i_card_uid => i_card_uid
                , i_inst_id  => i_inst_id
              );
    o_card_id := l_card.id;
    return l_card.card_number;
end;

function get_card_number (
    i_card_uid         in     com_api_type_pkg.t_name
  , i_inst_id          in     com_api_type_pkg.t_inst_id       default null
) return com_api_type_pkg.t_card_number is
begin
    return get_card(
               i_card_uid => i_card_uid
             , i_inst_id  => i_inst_id
           ).card_number;
end;

function is_instant_card(
    i_contract_id   in      com_api_type_pkg.t_medium_id
  , i_customer_id   in      com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_boolean
is
    l_is_instant_card       com_api_type_pkg.t_boolean;
begin
    -- check contract type
    begin
        select com_api_const_pkg.TRUE
          into l_is_instant_card
          from prd_contract t
             , prd_customer m
         where t.id              = i_contract_id
           and t.contract_type in (prd_api_const_pkg.CONTRACT_TYPE_INSTANT_CARD
                                 , prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD)
           and m.id              = i_customer_id
           and m.ext_entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
           and rownum            = 1;

    exception
        when no_data_found then
            l_is_instant_card := com_api_const_pkg.FALSE;
    end;

    return l_is_instant_card;
end is_instant_card;

function is_customer_agent(
    i_agent_id            in      com_api_type_pkg.t_agent_id
  , i_appl_contract_type  in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean
is
    l_is_customer_agent           com_api_type_pkg.t_boolean;
begin
    if i_appl_contract_type not in (prd_api_const_pkg.CONTRACT_TYPE_INSTANT_CARD
                             , prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD)
    then
        l_is_customer_agent := com_api_const_pkg.FALSE;

        trc_log_pkg.debug('SET l_is_customer_agent [' || l_is_customer_agent || '] by contract');
    else
        begin
            select com_api_const_pkg.TRUE
              into l_is_customer_agent
              from prd_contract t
                 , prd_customer c
             where c.ext_entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
               and c.ext_object_id   = i_agent_id
               and t.customer_id     = c.id
               and t.contract_type  in (prd_api_const_pkg.CONTRACT_TYPE_INSTANT_CARD
                                      , prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD)
               and rownum            = 1;
        exception
            when no_data_found then
                l_is_customer_agent := com_api_const_pkg.FALSE;

                trc_log_pkg.debug('SET l_is_customer_agent [' || l_is_customer_agent || '] by agent');
        end;
    end if;

    return l_is_customer_agent;
end is_customer_agent;

function get_card(
    i_account_id                in      com_api_type_pkg.t_medium_id
  , i_split_hash                in      com_api_type_pkg.t_tiny_id       default null
  , i_state                     in      com_api_type_pkg.t_dict_value    default iss_api_const_pkg.CARD_STATE_ACTIVE
) return iss_api_type_pkg.t_card_tab
is
    l_result            iss_api_type_pkg.t_card_tab;
    l_split_hash        com_api_type_pkg.t_tiny_id;
begin
    l_split_hash := 
        coalesce(
            i_split_hash
          , com_api_hash_pkg.get_split_hash(
                i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id   => i_account_id
              , i_mask_error  => com_api_const_pkg.FALSE
            )
        );
    select c.id
         , c.split_hash
         , c.card_hash
         , c.card_mask
         , c.inst_id
         , c.card_type_id
         , c.country
         , c.customer_id
         , c.cardholder_id
         , c.contract_id
         , c.reg_date
         , c.category
         , iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number
    bulk collect into l_result
      from iss_card c
         , iss_card_number cn
         , iss_card_instance i
         , acc_account_object ao
     where c.id                = i.card_id
       and cn.card_id          = c.id
       and ao.object_id        = c.id
       and ao.account_id       = i_account_id
       and ao.split_hash       = l_split_hash
       and ao.entity_type      = iss_api_const_pkg.ENTITY_TYPE_CARD
       and (i.state            = i_state 
           or i_state          is null
           )
     order by
         decode(
             c.category
           , iss_api_const_pkg.CARD_CATEGORY_PRIMARY
           , 1
           , iss_api_const_pkg.CARD_CATEGORY_UNDEFINED
           , 2
           , iss_api_const_pkg.CARD_CATEGORY_DOUBLE
           , 3
           , 9
         )
       , c.id desc
     ;
    return l_result;
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error      => 'CARD_NOT_FOUND'
          , i_env_param1 => i_account_id
        );
end;

function is_pool_card(
    i_customer_id  in      com_api_type_pkg.t_medium_id
  , i_card_status  in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean as
    l_customer_status      com_api_type_pkg.t_dict_value;
begin
    begin
       select c.status
         into l_customer_status 
         from prd_customer c
        where c.id = i_customer_id;
    exception 
        when no_data_found then
            return com_api_const_pkg.FALSE;
    end;
    
    if i_card_status = iss_api_const_pkg.CARD_STATUS_ACTIVTION_REQIRED  then
        if l_customer_status = prd_api_const_pkg.CUSTOMER_STATUS_ACTIV_REQUIRED then
            return com_api_const_pkg.TRUE;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'STATUS_MISMATCH'
              , i_env_param1 => i_card_status
              , i_env_param2 => l_customer_status
            );
        end if;
    else
        return com_api_const_pkg.FALSE;
    end if;
end;

procedure reconnect_card(
    i_card_id                      in    com_api_type_pkg.t_long_id
  , i_customer_id                  in    com_api_type_pkg.t_medium_id
  , i_contract_id                  in    com_api_type_pkg.t_long_id
  , i_cardholder_id                in    com_api_type_pkg.t_long_id
  , i_cardholder_photo_file_name   in    iss_api_type_pkg.t_file_name
  , i_cardholder_sign_file_name    in    iss_api_type_pkg.t_file_name
  , i_expir_date                   in    date                          default null
  , i_card_category                in    com_api_type_pkg.t_dict_value default null
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.reconnect_card: ';
    l_split_hash                   com_api_type_pkg.t_tiny_id;
    l_cardholder_name              com_api_type_pkg.t_name;
    l_instance_id                  com_api_type_pkg.t_medium_id;
    l_card_type                    iss_api_type_pkg.t_product_card_type_rec;
    l_card_rec                     iss_api_type_pkg.t_card_rec;
    l_seq_number                   com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_card_id [#1], i_customer_id [#2], i_contract_id [#3], i_cardholder_id [#4], i_card_category [#5]'
      , i_env_param1 => i_card_id
      , i_env_param2 => i_customer_id
      , i_env_param3 => i_contract_id
      , i_env_param4 => i_cardholder_id
      , i_env_param5 => i_card_category
    );

    begin
        select split_hash
          into l_split_hash
          from prd_customer
         where id = i_customer_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error => 'CUSTOMER_NOT_FOUND'
            );
    end;

    l_card_rec := get_card(i_card_id => i_card_id);

    l_seq_number := get_seq_number(l_card_rec.card_number);

    l_card_type := iss_api_product_pkg.get_product_card_type(
        i_contract_id       => nvl(i_contract_id, l_card_rec.contract_id)
      , i_card_type_id      => l_card_rec.card_type_id
      , i_seq_number        => l_seq_number
    );

    update iss_card_vw
       set customer_id      = i_customer_id
         , contract_id      = nvl(i_contract_id, contract_id)
         , split_hash       = l_split_hash
         , cardholder_id    = nvl(i_cardholder_id, cardholder_id)
         , category         = nvl(i_card_category, category)
     where id = i_card_id;

    evt_api_event_pkg.change_split_hash(
        i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_id   => i_card_id
      , i_split_hash  => l_split_hash
    );

    -- update cardholder for instance
    l_cardholder_name :=
        upper(
            iss_api_cardholder_pkg.get_cardholder_name(
                i_id => i_cardholder_id
            )
        );
    l_cardholder_name := get_translit(i_text => l_cardholder_name);

    begin
        select id
          into l_instance_id
          from iss_card_instance
         where card_id = i_card_id
           and seq_number = (select max(seq_number) from iss_card_instance where card_id = i_card_id);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'INSTANCE_NOT_FOUND'
              , i_env_param1    => i_card_id
            );
    end;
    
    update iss_card_instance
       set cardholder_name             = nvl(l_cardholder_name, cardholder_name)
         , split_hash                  = l_split_hash
         , cardholder_photo_file_name  = nvl(i_cardholder_photo_file_name, cardholder_photo_file_name)
         , cardholder_sign_file_name   = nvl(i_cardholder_sign_file_name, cardholder_sign_file_name)
         , expir_date       = nvl(i_expir_date, expir_date)
     where id = l_instance_id;

    evt_api_event_pkg.change_split_hash(
        i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
      , i_object_id   => l_instance_id
      , i_split_hash  => l_split_hash
    );

    prd_api_service_pkg.update_service_object(
        i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_id   => i_card_id
      , i_split_hash  => l_split_hash
      , i_contract_id => i_contract_id
    );

end reconnect_card;

function is_merchant_card(
    i_service_id                   in    com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean
as
    l_service_type_id              com_api_type_pkg.t_short_id;
begin
    select service_type_id
      into l_service_type_id
      from prd_service
     where id              = i_service_id
       and service_type_id = iss_api_const_pkg.SERVICE_TYPE_MERCH_CARD_MAINT;

    return com_api_const_pkg.TRUE;
exception 
    when no_data_found then
        return com_api_const_pkg.FALSE;
end;

begin
    reload_settings();
end iss_api_card_pkg;
/
