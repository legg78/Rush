create or replace package body amx_api_rejected_pkg as

function find_original_file(
    i_file_number           in     com_api_type_pkg.t_auth_code
  , i_file_date             in     date
  , i_forw_inst_code        in     com_api_type_pkg.t_cmid
  , i_receiv_inst_code      in     com_api_type_pkg.t_cmid
) return com_api_type_pkg.t_long_id
is
    l_file_id                 com_api_type_pkg.t_long_id;
begin
   select f.id
     into l_file_id
     from amx_file f
    where f.file_number = i_file_number
      and f.network_id = amx_api_const_pkg.TARGET_NETWORK
      and f.forw_inst_code = i_receiv_inst_code
      and f.receiv_inst_code = i_forw_inst_code
      and f.is_incoming = com_api_type_pkg.FALSE
      and f.func_code = amx_api_const_pkg.FUNC_CODE_ACKNOWLEDGMENT;

    return l_file_id;
exception
    when no_data_found then
        l_file_id := null;
        return l_file_id;
    when others then
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_ERR_SEARCH_ORIGIN_FILE'
            , i_env_param1  => sqlerrm
            , i_env_param2  => i_file_number
            , i_env_param3  => i_file_date
            , i_env_param4  => i_forw_inst_code
            , i_env_param5  => i_receiv_inst_code
        );
end;

function find_original_message(
    i_mtid                  in     com_api_type_pkg.t_mcc
  , i_func_code             in     com_api_type_pkg.t_curr_code
  , i_proc_code             in     com_api_type_pkg.t_auth_code
  , i_card_number           in     com_api_type_pkg.t_card_number
  , i_arn                   in     com_api_type_pkg.t_bin
  , i_transaction_id        in     com_api_type_pkg.t_merchant_number
  , i_original_file_id      in     com_api_type_pkg.t_long_id
  , o_original_msg_id          out com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id
is
    l_message_id            com_api_type_pkg.t_long_id;
begin
    select m.id
      into l_message_id
      from amx_fin_message m
         , amx_card c
     where m.file_id     = i_original_file_id
       and m.mtid        = i_mtid
       and m.func_code   = i_func_code
       and c.id          = m.id
       and c.card_number = iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
       and (m.arn = trim(i_arn) or (m.arn is null and trim(i_arn) is null) or m.transaction_id = i_transaction_id)
       and m.proc_code   = i_proc_code
       and m.network_id  = amx_api_const_pkg.TARGET_NETWORK
       and m.is_incoming = 0;

    return l_message_id;
exception
    when no_data_found then
        l_message_id := null;
        return l_message_id;
    when others then
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_ERR_SEARCH_ORIGIN_MSG'
            , i_env_param1  => sqlerrm
        );
end;

function find_original_addenda(
    i_mtid                  in     com_api_type_pkg.t_mcc
  , i_addenda_type          in     com_api_type_pkg.t_byte_char
  , i_transaction_id        in     com_api_type_pkg.t_merchant_number
  , i_original_file_id      in     com_api_type_pkg.t_long_id
  , i_amx_file              in     amx_api_type_pkg.t_amx_file_rec
  , o_original_msg_id          out com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id
is
    l_add_id                com_api_type_pkg.t_long_id;
    l_origin_msg_id         com_api_type_pkg.t_long_id;
begin
    begin

        trc_log_pkg.debug (
            i_text          => 'find_original_addenda 1'
        );

        select a.id
          into l_add_id
          from amx_add a
             , amx_fin_message m
         where a.file_id        = i_original_file_id
           and a.mtid           = i_mtid
           and a.addenda_type   = i_addenda_type
           and a.transaction_id = i_transaction_id
           and a.fin_id         = m.id
           and m.network_id     = amx_api_const_pkg.TARGET_NETWORK
           and a.is_incoming    = 0;

        trc_log_pkg.debug (
            i_text          => 'l_add_id = ' || l_add_id
        );

    exception
        when no_data_found then

            trc_log_pkg.debug (
                i_text          => 'find_original_addenda 2'
            );

            select max(origin_msg_id) keep (dense_rank first order by r.id desc)
             into l_origin_msg_id
             from amx_rejected r
            where r.file_id          = i_amx_file.id
              and r.inst_id          = i_amx_file.inst_id
              and r.incoming         = com_api_type_pkg.TRUE
              and r.forw_inst_code   = i_amx_file.forw_inst_code
              and r.receiv_inst_code = i_amx_file.receiv_inst_code
              and r.origin_file_id   = i_original_file_id;

            trc_log_pkg.debug (
                i_text          => 'l_origin_msg_id = ' || l_origin_msg_id
            );

            select a.id
             into l_add_id
             from amx_add a
                , amx_fin_message m
            where a.file_id        = i_original_file_id
              and a.mtid           = i_mtid
              and a.addenda_type   = i_addenda_type
              and a.fin_id         = m.id
              and m.network_id     = amx_api_const_pkg.TARGET_NETWORK
              and a.is_incoming    = com_api_type_pkg.FALSE
              and m.id             = l_origin_msg_id;

            trc_log_pkg.debug (
                i_text          => 'l_add_id = ' || l_add_id
            );
    end;

    return l_add_id;
exception
    when no_data_found then
        l_add_id := null;
        return l_add_id;
    when others then
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_ERR_SEARCH_ORIGIN_MSG'
            , i_env_param1  => sqlerrm
        );
end;

procedure process_reason_codes(
    i_reject_msg_id         in     com_api_type_pkg.t_long_id
  , i_reason_codes          in     com_api_type_pkg.t_original_data
) is
    l_reason_codes          com_api_type_pkg.t_original_data;
    l_rc_length             number(2);
    i                       number(2);
    l_reason_code           com_api_type_pkg.t_original_data;
begin
    l_reason_codes := trim(i_reason_codes);
    l_rc_length    := length(l_reason_codes);

    if nvl(l_rc_length, 0) > 0 then
         if mod(l_rc_length, 4) = 0 then

             for i in 1..l_rc_length/4 loop

                 l_reason_code := substr(l_reason_codes, 1 + (i - 1) * 4, 4);

                 if nvl(length(trim(l_reason_code)), 0) = 4 then

                     insert into amx_rejected_detail(
                         reject_message_id
                         , order_code
                         , reject_reason_code
                     )
                     values(
                         i_reject_msg_id
                         , i
                         , l_reason_code
                     );

                 end if;
             end loop;
         end if;
    end if;

exception
    when others then
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_ERR_PARSE_REASON_CODES'
            , i_env_param1  => sqlerrm
        );
end;

procedure process_acknowledgment(
    i_ack_message           in     com_api_type_pkg.t_text
  , i_amx_file              in     amx_api_type_pkg.t_amx_file_rec
  , o_original_file_id         out com_api_type_pkg.t_long_id
)is
    l_file_date             com_api_type_pkg.t_date_long;
    l_transmittal_date      date;
    l_msg_reason_code       com_api_type_pkg.t_mcc;
    l_msg_number            com_api_type_pkg.t_short_id;
    l_action_code           com_api_type_pkg.t_curr_code;
    l_reject_msg_id         com_api_type_pkg.t_long_id;
    l_file_seq_number       com_api_type_pkg.t_auth_code;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return trim(substr(i_ack_message, i_start, i_length));
    end;

begin
    trc_log_pkg.debug (
        i_text          => 'amx_api_rejected_pkg.process_acknowledgment start'
    );

    l_file_date                    := get_field(766, 8) || get_field(774, 6);
    l_transmittal_date             := to_date(l_file_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_msg_reason_code              := get_field(170, 4);
    l_action_code                  := get_field(252, 3);
    l_msg_number                   := get_field(1032, 8);
    l_file_seq_number              := get_field(1000, 6);

    trc_log_pkg.debug (
        i_text          => 'l_msg_reason_code = ' || l_msg_reason_code
    );
    -- fin messages
    if l_msg_reason_code not in (amx_api_const_pkg.MSG_REASON_CODE_FIN_REJECT
                                 , amx_api_const_pkg.MSG_REASON_CODE_FIN_OK
                                 , amx_api_const_pkg.MSG_REASON_CODE_DC_REJECT
                                 , amx_api_const_pkg.MSG_REASON_CODE_DC_OK)
    then
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_UNKNOWN_MSG_REASON_CODE'
            , i_env_param1  => l_msg_reason_code
        );
    end if;

    o_original_file_id :=  find_original_file(
                               i_file_number          => l_file_seq_number
                               , i_file_date          => l_transmittal_date
                               , i_forw_inst_code     => i_amx_file.forw_inst_code
                               , i_receiv_inst_code   => i_amx_file.receiv_inst_code
                            );

    if o_original_file_id is null then

        trc_log_pkg.error (
            i_text          => 'Network file acknowledgement message received, but original file not found [#1][#2][#3][#4]'
            , i_env_param1  => l_file_seq_number
            , i_env_param2  => l_transmittal_date
            , i_env_param3  => i_amx_file.forw_inst_code
            , i_env_param4  => i_amx_file.receiv_inst_code
        );
    else
        trc_log_pkg.debug (
            i_text          => 'Original file found. o_original_file_id = ' || o_original_file_id
        );

        if l_action_code = amx_api_const_pkg.ACTION_CODE_FILE_REJECT then

            l_reject_msg_id := opr_api_create_pkg.get_id;

            insert into amx_rejected(
                id
                , file_id
                , inst_id
                , incoming
                , msg_number
                , forw_inst_code
                , receiv_inst_code
                , origin_file_id
                , origin_msg_id
            ) values(
                l_reject_msg_id
                , i_amx_file.id
                , i_amx_file.inst_id
                , com_api_type_pkg.TRUE
                , l_msg_number
                , i_amx_file.forw_inst_code
                , i_amx_file.receiv_inst_code
                , o_original_file_id
                , null
            );

            -- mark file as rejected
            update amx_file f
               set f.is_rejected = com_api_type_pkg.TRUE
                 , f.reject_message_id = l_reject_msg_id
             where f.id = o_original_file_id;

            --mark all messages of file the same id
            update amx_fin_message m
               set m.is_rejected  = com_api_type_pkg.TRUE
                 , m.reject_id = l_reject_msg_id
             where m.file_id = o_original_file_id;

            --mark all addendums of file the same id
            update amx_add a
               set a.reject_id = l_reject_msg_id
             where a.file_id = o_original_file_id;

        elsif l_action_code = amx_api_const_pkg.ACTION_CODE_FULL_ACCEPT then

            trc_log_pkg.debug (
                i_text          => 'File [' || o_original_file_id || '] full accepted'
            );
        elsif l_action_code = amx_api_const_pkg.ACTION_CODE_PARTIAL_ACCEPT then

            trc_log_pkg.debug (
                i_text          => 'File [' || o_original_file_id || '] partially accepted'
            );

        end if;
    end if;

    trc_log_pkg.debug (
        i_text          => 'amx_api_rejected_pkg.process_acknowledgment end'
    );
end;


procedure process_rejected_message(
    i_ack_message           in     com_api_type_pkg.t_text
  , i_amx_file              in     amx_api_type_pkg.t_amx_file_rec
  , i_original_file_id      in     com_api_type_pkg.t_long_id
)is
    l_mtid                  com_api_type_pkg.t_mcc;
    l_func_code             com_api_type_pkg.t_curr_code;
    l_proc_code             com_api_type_pkg.t_auth_code;
    l_card_number           com_api_type_pkg.t_card_number;
    l_arn                   com_api_type_pkg.t_auth_amount;
    l_transaction_id        com_api_type_pkg.t_merchant_number;
    l_original_msg_id       com_api_type_pkg.t_long_id;
    l_reject_msg_id         com_api_type_pkg.t_long_id;
    l_msg_number            com_api_type_pkg.t_dict_value;
    l_reject_code           com_api_type_pkg.t_original_data;
    l_addenda_type          com_api_type_pkg.t_byte_char;
    l_offset                pls_integer := 0;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return trim(substr(i_ack_message, i_start, i_length));
    end;

begin
    trc_log_pkg.debug (
        i_text          => 'process_rejected_message start'
    );

    l_mtid          := get_field(1, 4);

    if l_mtid = amx_api_const_pkg.MTID_ADDENDA then

        l_addenda_type := get_field(5, 2);

        l_offset := amx_api_add_pkg.get_offset(i_addenda_type => l_addenda_type);

        l_transaction_id:= get_field(1006 + l_offset, 15);
        l_msg_number    := get_field(1032 + l_offset, 8);
        l_reject_code   := get_field(1279 + l_offset, 40);

        l_original_msg_id := find_original_addenda(
                                 i_mtid                  => l_mtid
                                 , i_addenda_type        => l_addenda_type
                                 , i_transaction_id      => l_transaction_id
                                 , i_original_file_id    => i_original_file_id
                                 , i_amx_file            => i_amx_file
                                 , o_original_msg_id     => l_original_msg_id
                             );

        l_reject_msg_id   := opr_api_create_pkg.get_id;

        if l_original_msg_id is null then

            trc_log_pkg.error (
                i_text          => 'Addenda reject received, but original addenda not found. [#1][#2][#3][#4][#5][#6][#7][#8]'
                , i_env_param1  => l_mtid
                , i_env_param2  => l_addenda_type
                , i_env_param3  => l_transaction_id
                , i_env_param4  => i_original_file_id
                , i_env_param5  => '['||i_amx_file.id||']['||i_amx_file.inst_id||']'
                , i_env_param6  => '['||i_amx_file.forw_inst_code||']['||i_amx_file.receiv_inst_code||']'
            );
        else
            trc_log_pkg.debug (
                i_text          => 'Original addenda found. l_original_msg_id = ' || l_original_msg_id
            );

            update amx_add a
               set a.reject_id  = l_reject_msg_id
             where a.id = l_original_msg_id;

        end if;

    else

        l_func_code     := get_field(167, 3);
        l_proc_code     := get_field(26, 6);
        l_card_number   := get_field(7, 19);
        l_arn           := get_field(223, 23);
        l_transaction_id:= get_field(1006, 15);
        l_msg_number    := get_field(1032, 8);
        l_reject_code   := get_field(1279, 40);

        l_original_msg_id := find_original_message(
                                 i_mtid                  => l_mtid
                                 , i_func_code           => l_func_code
                                 , i_proc_code           => l_proc_code
                                 , i_card_number         => l_card_number
                                 , i_arn                 => l_arn
                                 , i_transaction_id      => l_transaction_id
                                 , i_original_file_id    => i_original_file_id
                                 , o_original_msg_id     => l_original_msg_id
                             );

        l_reject_msg_id   := opr_api_create_pkg.get_id;

        if l_original_msg_id is null then

            trc_log_pkg.error (
                i_text          => 'Message reject received, but original message not found. [#1][#2][#3][#4][#5][#6]'
                , i_env_param1  => l_mtid
                , i_env_param2  => l_func_code
                , i_env_param3  => l_proc_code
                , i_env_param4  => l_card_number
                , i_env_param5  => l_arn
                , i_env_param6  => i_original_file_id
            );
        else
            trc_log_pkg.debug (
                i_text          => 'Original message found. l_original_msg_id = ' || l_original_msg_id
            );

            update amx_fin_message m
               set m.is_rejected  = com_api_type_pkg.TRUE
                 , m.reject_id    = l_reject_msg_id
             where m.id = l_original_msg_id;
        end if;

    end if;

    -- insert record
    insert into amx_rejected(
        id
        , file_id
        , inst_id
        , incoming
        , msg_number
        , forw_inst_code
        , receiv_inst_code
        , origin_file_id
        , origin_msg_id
    ) values(
        l_reject_msg_id
        , i_amx_file.id
        , i_amx_file.inst_id
        , 1
        , l_msg_number
        , i_amx_file.forw_inst_code
        , i_amx_file.receiv_inst_code
        , i_original_file_id
        , l_original_msg_id
    );

    trc_log_pkg.debug (
        i_text          => 'l_reject_msg_id = ' || l_reject_msg_id
    );

    if trim(l_reject_code) is not null then

        process_reason_codes(
            i_reject_msg_id        => l_reject_msg_id
            , i_reason_codes       => l_reject_code
        );
    end if;
    trc_log_pkg.debug (
        i_text          => 'process_rejected_message end'
    );
end;

end;
/

