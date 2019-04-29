create or replace package body iss_api_token_pkg is
/************************************************************
 * Tokenizator API <br />
 * Created by Alalykin A. (alalykin@bpcbt.com) at 22.09.2014 <br />
 * Last changed by $Author: alalykin $ <br />
 * $LastChangedDate:: 2014-09-22 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 40000 $ <br />
 * Module: iss_api_token_pkg <br />
 * @headcom
 ************************************************************/

g_enable_tokenization            com_api_type_pkg.t_boolean;

/*
 * Encoding source PAN (card number) to token with using default table index value.
 */
function svtoken_connect(
    i_host                in     varchar2
  , i_port                in     pls_integer
) return pls_integer
as external name "svtoken_client_connect" library iss_token_lib language C
parameters(
    i_host            string
  , i_port            int
  , return            int
);

/*
 * Encoding source PAN (card number) to token with using default table index value.
 */
function svtoken_encode(
    i_pan                 in     com_api_type_pkg.t_card_number
  , i_pan_length          in     pls_integer
  , o_token                  out com_api_type_pkg.t_card_number
  , o_token_length           out pls_integer
  , i_buffer_size         in     pls_integer
  , i_table_index         in     pls_integer
) return pls_integer
as external name "svtoken_client_encode" library iss_token_lib language C
parameters(
    i_pan            string
  , i_pan_length     int
  , o_token          string
  , o_token_length   by reference int
  , i_buffer_size    int
  , i_table_index    int
  , return           int
);

/*
 * Decoding source token to source PAN (card number) with using default table index value.
 */
function svtoken_decode(
    i_token               in     com_api_type_pkg.t_card_number
  , i_token_length        in     pls_integer
  , o_pan                    out com_api_type_pkg.t_card_number
  , o_pan_length             out pls_integer
  , i_buffer_size         in     pls_integer
  , o_table_index            out pls_integer
) return pls_integer
as external name "svtoken_client_decode" library iss_token_lib language C
parameters(
    i_token          string
  , i_token_length   int
  , o_pan            string
  , o_pan_length     by reference int
  , i_buffer_size    int
  , o_table_index    by reference int
  , return           int
);

/*
 * Retrieving error's description by its code.
 */
function svtoken_get_error_description(
    i_error_code          in     pls_integer
) return com_api_type_pkg.t_short_desc
as external name "get_error_description" library iss_token_lib language C
parameters(
    i_error_code     int
  , return           string
);

/*
 * Function tries to get error's description by its code but doesn't raise an exception on failure.
 */
function get_error_description(
    i_error_code          in     pls_integer
) return com_api_type_pkg.t_short_desc
is
    l_error_message              com_api_type_pkg.t_short_desc;
begin
    begin
        l_error_message := svtoken_get_error_description(i_error_code => i_error_code);
    exception
        when others then
            trc_log_pkg.debug(
                i_text       => 'Warning: get_error_description(#1) FAILED with sqlerrm: #2'
              , i_env_param1 => i_error_code
              , i_env_param2 => sqlerrm
            );
    end;
    return l_error_message;
end;

/*
 * Function determines tokenization settings in system;
 * if it is enabled then function returns a token as a result of encoding of incoming PAN,
 * otherwise it returns incoming PAN without changes.
 */
function encode_card_number(
    i_card_number         in     com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_card_number
is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.encode_card_number: ';
    l_pan                        com_api_type_pkg.t_card_number;
    l_pan_length                 pls_integer;
    l_response_code              pls_integer;
begin
    if  g_enable_tokenization = com_api_type_pkg.FALSE
        or
        i_card_number is null
    then
        l_pan := i_card_number;

    elsif length(i_card_number) < iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
       or not regexp_like(i_card_number, '^[0-9]*$') -- only digits
    then
        trc_log_pkg.warn(
            i_text       => 'IMPOSSIBLE_TO_ENCODE_PAN'
          , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
          , i_env_param2 => length(i_card_number)
          , i_env_param3 => iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
        );
        l_pan := i_card_number;

    else
        l_response_code := svtoken_encode(
                               i_pan          => i_card_number
                             , i_pan_length   => length(i_card_number)
                             , o_token        => l_pan
                             , o_token_length => l_pan_length
                             , i_buffer_size  => iss_api_const_pkg.TOKEN_BUFFER_SIZE
                             , i_table_index  => iss_api_const_pkg.DEFAULT_TOKEN_TABLE_INDEX
                           );
--        trc_log_pkg.debug(
--            i_text       => LOG_PREFIX || 'l_response_code [#5]; '
--                         || 'i_card_number [#1], encoded l_pan [#2], length(l_pan) [#3], l_pan_length [#4]'
--          , i_env_param1 => i_card_number
--          , i_env_param2 => l_pan
--          , i_env_param3 => length(l_pan)
--          , i_env_param4 => l_pan_length
--          , i_env_param5 => l_response_code
--        );
        if l_response_code != iss_api_const_pkg.TOKEN_ANSWER_OK then
            com_api_error_pkg.raise_error(
                i_error      => 'PAN_TO_TOKEN_IS_FAILED'
              , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
              , i_env_param2 => length(i_card_number)
              , i_env_param3 => l_response_code
              , i_env_param4 => get_error_description(i_error_code => l_response_code)
            );
        end if;
    end if;

    return l_pan;
exception
    when com_api_error_pkg.e_external_library_not_found then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'TOKENIZATION_LIBRARY_IS_NOT_FOUND'
          , i_env_param1 => 'iss_token_lib'
        );
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        trc_log_pkg.debug(LOG_PREFIX || 'FAILED with i_card_number [' || iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
                                     || '], l_response_code [' || l_response_code || ']');
        raise;
end encode_card_number;

/*
 * Function determines tokenization settings in system;
 * if it is enabled then function treats an incoming parameter as a token, decode it and returns PAN,
 * otherwise it returns incoming PAN without changes.
 * We don't perform any check for <i_card_number> to achieve maximum performance,
 * but we perform some checks in <encode_card_number()> because it is used much less often.
 * @i_mask_error — if flag is TRUE then errors aren't raised but ERROR messages are put into log
 */
function decode_card_number(
    i_card_number         in     com_api_type_pkg.t_card_number
  , i_mask_error          in     com_api_type_pkg.t_boolean        default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_card_number
is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.decode_card_number: ';
    l_pan                        com_api_type_pkg.t_card_number;
    l_pan_length                 pls_integer;
    l_response_code              pls_integer;
    l_index                      pls_integer;
begin
    if g_enable_tokenization = com_api_type_pkg.FALSE then
        l_pan := i_card_number;
--        trc_log_pkg.debug(
--            i_text       => LOG_PREFIX || 'i_card_number [#1], i_mask_error [#2], decoded l_pan [NULL]'
--          , i_env_param1 => i_card_number
--          , i_env_param2 => i_mask_error
--        );

    elsif i_card_number is not null then
        l_response_code := svtoken_decode(
                               i_token        => i_card_number
                             , i_token_length => length(i_card_number)
                             , o_pan          => l_pan
                             , o_pan_length   => l_pan_length
                             , i_buffer_size  => iss_api_const_pkg.TOKEN_BUFFER_SIZE
                             , o_table_index  => l_index
                           );
--        trc_log_pkg.debug(
--            i_text       => LOG_PREFIX || 'l_response_code [#5]; '
--                         || 'i_card_number [#1], i_mask_error [#6], decoded l_pan [#2], length(l_pan) [#3], l_pan_length [#4]'
--          , i_env_param1 => i_card_number
--          , i_env_param2 => l_pan
--          , i_env_param3 => length(l_pan)
--          , i_env_param4 => l_pan_length
--          , i_env_param5 => l_response_code
--          , i_env_param6 => i_mask_error
--        );
        if l_response_code != iss_api_const_pkg.TOKEN_ANSWER_OK then
            -- If <i_card_number> contains not a clear PAN but something else,
            -- and it is known for sure then it is possible to pass its unmasked
            -- value into a procedure for raising/logging an error
            l_pan := case
                         when length(i_card_number) < iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
                           or not regexp_like(i_card_number, '^[0-9]*$') -- only digits
                         then i_card_number
                         else iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
                     end;
            -- If masking of errors is used, it is needed to log the error and return source PAN's token
            begin
                com_api_error_pkg.raise_error(
                    i_error      => 'TOKEN_TO_PAN_IS_FAILED'
                  , i_env_param1 => l_pan
                  , i_env_param2 => length(i_card_number)
                  , i_env_param3 => l_response_code
                  , i_env_param4 => get_error_description(i_error_code => l_response_code)
                );
            exception
                when com_api_error_pkg.e_application_error then
                    if nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
                        raise;
                    else
                        l_pan := i_card_number;
                    end if;
            end;
        end if;
    end if;

    return l_pan;
exception
    when com_api_error_pkg.e_external_library_not_found then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'TOKENIZATION_LIBRARY_IS_NOT_FOUND'
          , i_env_param1 => 'iss_token_lib'
        );
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        trc_log_pkg.debug(LOG_PREFIX || 'FAILED with i_card_number ['
                                     || iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
                                     || '], l_response_code [' || l_response_code || ']');
        raise;
end decode_card_number;

/*
 * If tokenization is enabled and <i_use_message_bus> is set to TRUE then
 * function returns undecoded PAN (i.e. value with token);
 * in all other cases it returns decoded PAN (i.e. without a token).
 */
--function get_card_number(
--    i_card_number         in     com_api_type_pkg.t_card_number
--  , i_use_message_bus     in     com_api_type_pkg.t_boolean
--) return com_api_type_pkg.t_card_number
--is
--    l_pan                        com_api_type_pkg.t_card_number;
--begin
--    pragma inline(decode_card_number, 'YES');
--
--    if i_use_message_bus = com_api_type_pkg.TRUE then
--        l_pan := i_card_number;
--    elsif i_card_number is not null then
--        l_pan := decode_card_number(i_card_number => i_card_number);
--    end if;
--
--    return l_pan;
--end get_card_number;

/*
 * Function determines if tokenization is used; it is necessary for searching procedures.
 */
function is_token_enabled return com_api_type_pkg.t_boolean
is
begin
    return g_enable_tokenization;
end;

/*
 * We check if tokenization is enabled and cache setting parameter for the package,
 * then try to connect to SVTOKEN using address TOKENIZATOR_HOST:TOKENIZATOR_PORT.
 * Procedure should be called during the package's initialization (once per a session).
 */
procedure initialization
is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.initialization: ';
    l_svtoken_host               com_api_type_pkg.t_remote_adr;
    l_svtoken_port               com_api_type_pkg.t_port;
    l_response_code              com_api_type_pkg.t_tiny_id;
begin
    g_enable_tokenization := nvl(set_ui_value_pkg.get_system_param_n('ENABLE_TOKENIZATION'), com_api_type_pkg.FALSE);
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'tokenization is '
               || case when g_enable_tokenization = com_api_type_pkg.TRUE then 'ENABLED'
                                                                          else 'DISABLED'
                  end
    );
    if g_enable_tokenization = com_api_type_pkg.TRUE then
        l_svtoken_host := set_ui_value_pkg.get_system_param_v('TOKENIZATOR_HOST');
        l_svtoken_port := set_ui_value_pkg.get_system_param_n('TOKENIZATOR_PORT');

        if l_svtoken_host is null or l_svtoken_port is null then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'TOKENIZATOR_ADDRESS_IS_NOT_DEFINED'
              , i_env_param1 => l_svtoken_host
              , i_env_param2 => l_svtoken_port
            );
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'connecting to SVTOKEN using address [#1:#2]'
              , i_env_param1 => l_svtoken_host
              , i_env_param2 => l_svtoken_port
            );
            l_response_code := svtoken_connect(
                                   i_host => l_svtoken_host
                                 , i_port => to_number(l_svtoken_port)
                               );
            if l_response_code != iss_api_const_pkg.TOKEN_ANSWER_OK then
                com_api_error_pkg.raise_fatal_error(
                    i_error      => 'UNABLE_TO_CONNECT_TO_TOKENIZATOR'
                  , i_env_param1 => l_svtoken_host
                  , i_env_param2 => l_svtoken_port
                  , i_env_param3 => l_response_code
                );
            end if;
            trc_log_pkg.debug(LOG_PREFIX || 'connection established');
        end if;
    end if;
exception
    when com_api_error_pkg.e_external_library_not_found then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'TOKENIZATION_LIBRARY_IS_NOT_FOUND'
          , i_env_param1 => 'iss_token_lib'
        );
    when com_api_error_pkg.e_fatal_error or com_api_error_pkg.e_application_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'TOKENIZATOR_ACCESS_FAILED'
          , i_env_param1 => l_svtoken_host
          , i_env_param2 => l_svtoken_port
          , i_env_param3 => sqlerrm
        );
end initialization;

begin
    initialization();
end;
/
