create or replace package body opr_api_create_pkg is
/************************************************************
 * Provides an API for creating operation. <br />
 * Created by Khougaev A.(khougaev@bpcsv.com)  at 19.03.2010 <br />
 * Module: OPR_API_CREATE_PKG <br />
 * @headcom
 *************************************************************/

g_oper_id                           com_api_type_pkg.t_long_id;

function get_id(
    i_host_date             in      date    default null
) return com_api_type_pkg.t_long_id is
begin
    return com_api_id_pkg.get_id(opr_operation_seq.nextval, coalesce(i_host_date, com_api_sttl_day_pkg.get_sysdate));
end;

function get_id(
    i_shift in com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_long_id is
    l_seq_value com_api_type_pkg.t_long_id;
begin
    if i_shift is not null
        and i_shift > 0
    then
        for idx in 1 .. i_shift - 1 loop
            l_seq_value := opr_operation_seq.nextval;
        end loop;
    end if;
    return com_api_id_pkg.get_id(opr_operation_seq.nextval, com_api_sttl_day_pkg.get_sysdate);
end;

function is_gl_account(
    i_account_number        in      com_api_type_pkg.t_account_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_boolean is
    l_result                com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin

    select com_api_const_pkg.TRUE
      into l_result
      from acc_gl_account_mvw
     where account_number = i_account_number
       and inst_id        = i_inst_id;

    return l_result;

exception
    when no_data_found then
        return l_result;
end;

function is_number_empty (
    n                       in number
) return boolean is
begin
    if n is null or n = 0 then
        return true;
    else
        return false;
    end if;
end;

function participant_needed(
    i_oper_type             in      com_api_type_pkg.t_dict_value
  , i_participant_type      in      com_api_type_pkg.t_dict_value
  , i_oper_reason           in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean is
    l_result                com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_count                 com_api_type_pkg.t_tiny_id;
begin
    select count(id)
      into l_count
      from opr_participant_type
     where oper_type = i_oper_type
       and participant_type = i_participant_type
       and (i_oper_reason is null or i_oper_reason like nvl(oper_reason, '%'));

    if l_count > 0 then
        l_result := com_api_const_pkg.TRUE;
    end if;

    return l_result;
end;

procedure get_card (
    i_card_number           in      com_api_type_pkg.t_card_number
  , i_host_date             in      date
  , io_seq_number           in out  com_api_type_pkg.t_tiny_id
  , io_expir_date           in out  date
  , io_card_service_code    in out  com_api_type_pkg.t_curr_code
  , o_card_id                  out  com_api_type_pkg.t_medium_id
  , o_card_instance_id         out  com_api_type_pkg.t_medium_id
  , o_card_type_id             out  com_api_type_pkg.t_tiny_id
  , o_customer_id              out  com_api_type_pkg.t_medium_id
  , o_card_country             out  com_api_type_pkg.t_curr_code
  , o_card_inst_id             out  com_api_type_pkg.t_tiny_id
  , io_card_network_id      in out  com_api_type_pkg.t_tiny_id
  , o_split_hash               out  com_api_type_pkg.t_tiny_id
  , i_oper_id               in      com_api_type_pkg.t_long_id
  , i_mask_error            in      com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_card_hash             com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text                  => 'Searching for card [#1][#2][#3]'
        , i_env_param1          => iss_api_card_pkg.get_card_mask(i_card_number)
        , i_env_param2          => io_seq_number
        , i_env_param3          => to_char(io_expir_date, com_api_const_pkg.DATE_FORMAT)
    );

    l_card_hash := com_api_hash_pkg.get_card_hash(i_card_number);

    select id
         , card_type_id
         , country
         , inst_id
         , nvl(network_id, io_card_network_id)
         , split_hash
         , expir_date
         , seq_number
         , service_code
         , instance_id
         , customer_id
      into o_card_id
         , o_card_type_id
         , o_card_country
         , o_card_inst_id
         , io_card_network_id
         , o_split_hash
         , io_expir_date
         , io_seq_number
         , io_card_service_code
         , o_card_instance_id
         , o_customer_id
      from (
            select c.id
                 , c.card_type_id
                 , c.country
                 , c.inst_id
                 , t.network_id
                 , c.split_hash
                 , i.expir_date
                 , i.seq_number
                 , m.service_code
                 , i.id instance_id
                 , c.customer_id
              from iss_card c
                 , iss_card_number cn
                 , net_card_type t
                 , iss_card_instance i
                 , prs_method m
             where c.card_hash = l_card_hash
               and reverse(cn.card_number) = reverse(iss_api_token_pkg.encode_card_number(i_card_number => i_card_number))
               and c.card_type_id = t.id
               and c.id = i.card_id
               and c.id = cn.card_id
               --and (io_expir_date is null or to_char(nvl(io_expir_date, i.expir_date), 'mm.yyyy') = to_char(i.expir_date, 'mm.yyyy'))
               and (io_expir_date is null
                    or
                    exists (select 1 from net_card_type_feature f where t.id = f.card_type_id and f.card_feature = net_api_const_pkg.CARD_FEATURE_STATUS_VIRTUAL)
                    or
                    to_char(nvl(io_expir_date, i.expir_date), 'mm.yyyy') = to_char(i.expir_date, 'mm.yyyy')
                   )
               and (io_seq_number is null or io_seq_number = 0 or i.seq_number = io_seq_number)
               and i.perso_method_id = m.id
             order by
                   case when i_host_date between start_date and expir_date then 0 else 1 end
                 , seq_number desc
           )
     where rownum = 1;

exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error             => 'UNKNOWN_CARD'
          , i_env_param1        => iss_api_card_pkg.get_card_mask(i_card_number)
          , i_env_param2        => io_seq_number
          , i_env_param3        => io_expir_date
          , i_mask_error        => i_mask_error
          , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id         => i_oper_id
        );
end get_card;

procedure define_network(
    i_msg_type              in      com_api_type_pkg.t_dict_value
  , i_oper_type             in      com_api_type_pkg.t_dict_value
  , i_party_type            in      com_api_type_pkg.t_dict_value
  , i_host_date             in      date
  , io_network_id           in out  com_api_type_pkg.t_tiny_id
  , io_inst_id              in out  com_api_type_pkg.t_inst_id
  , o_host_id                  out  com_api_type_pkg.t_tiny_id
  , i_client_id_type        in      com_api_type_pkg.t_dict_value
  , i_client_id_value       in      com_api_type_pkg.t_name
  , i_card_number           in      com_api_type_pkg.t_card_number
  , o_card_inst_id             out  com_api_type_pkg.t_inst_id
  , o_card_network_id          out  com_api_type_pkg.t_network_id
  , o_card_id                  out  com_api_type_pkg.t_medium_id
  , o_card_instance_id         out  com_api_type_pkg.t_medium_id
  , o_card_type_id             out  com_api_type_pkg.t_tiny_id
  , o_card_mask                out  com_api_type_pkg.t_card_number
  , o_card_hash                out  com_api_type_pkg.t_medium_id
  , io_card_seq_number      in out  com_api_type_pkg.t_tiny_id
  , io_card_expir_date      in out  date
  , io_card_service_code    in out  com_api_type_pkg.t_country_code
  , o_card_country             out  com_api_type_pkg.t_country_code
  , i_account_number        in      com_api_type_pkg.t_account_number
  , o_account_id               out  com_api_type_pkg.t_medium_id
  , io_customer_id          in out  com_api_type_pkg.t_medium_id
  , i_merchant_number       in      com_api_type_pkg.t_merchant_number
  , io_merchant_id          in out  com_api_type_pkg.t_short_id
  , i_terminal_number       in      com_api_type_pkg.t_terminal_number
  , io_terminal_id          in out  com_api_type_pkg.t_short_id
  , io_split_hash           in out  com_api_type_pkg.t_tiny_id
  , i_payment_host_id       in      com_api_type_pkg.t_tiny_id
  , i_payment_order_id      in      com_api_type_pkg.t_long_id
  , i_oper_id               in      com_api_type_pkg.t_long_id
  , i_oper_reason           in      com_api_type_pkg.t_dict_value
  , i_acq_inst_id           in      com_api_type_pkg.t_inst_id
  , i_acq_network_id        in      com_api_type_pkg.t_network_id
  , i_oper_currency         in      com_api_type_pkg.t_curr_code
  , i_terminal_type         in      com_api_type_pkg.t_dict_value
  , i_mask_error            in      com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_pan_length            com_api_type_pkg.t_tiny_id;
    l_account_resp          com_api_type_pkg.t_dict_value;
    l_customer_id           com_api_type_pkg.t_long_id;
    l_account_id            com_api_type_pkg.t_long_id;
    l_account_number        com_api_type_pkg.t_account_number;
    l_card_number           com_api_type_pkg.t_card_number;
    l_payment_purpose_id    com_api_type_pkg.t_short_id;

    l_terminal_type         com_api_type_pkg.t_dict_value;
    l_oper_currency         com_api_type_pkg.t_curr_code;
    l_iss_inst_id           com_api_type_pkg.t_inst_id;
    l_iss_network_id        com_api_type_pkg.t_network_id;

    l_client_inst_id        com_api_type_pkg.t_inst_id;
    l_client_network_id     com_api_type_pkg.t_network_id;
    l_client_type_id        com_api_type_pkg.t_tiny_id;
    l_client_coutry_code    com_api_type_pkg.t_country_code;
    l_client_bin_currency   com_api_type_pkg.t_curr_code;
    l_client_sttl_currency  com_api_type_pkg.t_curr_code;
begin
    if i_party_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then
        trc_log_pkg.debug (
            i_text              => 'Incoming ACQ network is [#1]'
          , i_env_param1        => io_network_id
        );

        if is_number_empty(io_network_id) then
            if i_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_TERMINAL
                and io_inst_id is null
            then
                begin
                    select distinct inst_id
                      into io_inst_id
                      from acq_terminal a
                     where a.terminal_number = i_client_id_value;
                exception
                    when too_many_rows then
                        com_api_error_pkg.raise_error (
                            i_error             => 'TOO_MANY_TERMINALS'
                          , i_env_param1        => i_client_id_value
                          , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          , i_object_id         => i_oper_id
                          , i_mask_error        => i_mask_error
                        );
                    when no_data_found then
                        io_inst_id := null;
                end;

            elsif i_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                and io_inst_id is null
            then
                iss_api_bin_pkg.get_bin_info(
                    i_card_number     => i_client_id_value
                  , o_iss_inst_id     => io_inst_id
                  , o_iss_network_id  => l_iss_network_id
                  , o_card_inst_id    => l_client_inst_id
                  , o_card_network_id => l_client_network_id
                  , o_card_type       => l_client_type_id
                  , o_card_country    => l_client_coutry_code
                  , o_bin_currency    => l_client_bin_currency
                  , o_sttl_currency   => l_client_sttl_currency
                  , i_raise_error     => com_api_type_pkg.TRUE
                );
            end if;

            io_network_id :=
                ost_api_institution_pkg.get_inst_network (
                    i_inst_id       => io_inst_id
                );

            trc_log_pkg.debug (
                i_text              => 'Acq network found by institution [#1] is [#2]'
              , i_env_param1        => io_inst_id
              , i_env_param2        => io_network_id
            );
        end if;

        if is_number_empty(io_network_id) then
            com_api_error_pkg.raise_error (
                i_error             => 'UNKNOWN_INSTITUTION_NETWORK'
              , i_env_param1        => io_inst_id
              , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id         => i_oper_id
              , i_mask_error        => i_mask_error
            );
        end if;

    else -- was: i_party_type in (com_api_const_pkg.PARTICIPANT_ISSUER, com_api_const_pkg.PARTICIPANT_DEST) then
        trc_log_pkg.debug (
            i_text       => 'Find out iss network. Client id type [#1], client id value [#2], '
                         || 'card number [#3], account number [#4]'
          , i_env_param1 => i_client_id_type
          , i_env_param2 => case i_client_id_type
                                when opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                                then iss_api_card_pkg.get_card_mask(i_card_number => i_client_id_value)
                                else i_client_id_value
                            end
          , i_env_param3 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
          , i_env_param4 => i_account_number
        );

        if i_client_id_type in (aup_api_const_pkg.CLIENT_ID_TYPE_UNKNOWN
                              , aup_api_const_pkg.CLIENT_ID_TYPE_NONE)
        then
            io_network_id := net_api_const_pkg.UNIDENTIFIED_NETWORK;
            io_inst_id := ost_api_const_pkg.UNIDENTIFIED_INST;

        elsif i_client_id_type in (opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                                 , opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID)
        then
            l_card_number :=
                case i_client_id_type
                    when opr_api_const_pkg.CLIENT_ID_TYPE_CARD then
                        nvl(i_card_number, i_client_id_value)
                    when opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID then
                        iss_api_card_pkg.get_card_number (i_card_uid => i_client_id_value)
                        --iss_api_card_pkg.get_card_number(i_card_id => i_client_id_value)
                end;
            if o_card_id is null then
                o_card_id := iss_api_card_pkg.get_card_id(i_card_number => l_card_number);
            end if;
            
            iss_api_bin_pkg.get_bin_info (
                i_card_number           => l_card_number
              , i_oper_type             => i_oper_type
              , i_terminal_type         => l_terminal_type
              , i_acq_inst_id           => i_acq_inst_id
              , i_acq_network_id        => i_acq_network_id
              , i_msg_type              => i_msg_type
              , i_oper_reason           => i_oper_reason
              , i_oper_currency         => l_oper_currency
              , i_merchant_id           => io_merchant_id
              , i_terminal_id           => io_terminal_id
              , o_iss_inst_id           => l_iss_inst_id
              , o_iss_network_id        => l_iss_network_id
              , o_iss_host_id           => o_host_id
              , o_card_type_id          => o_card_type_id
              , o_card_country          => o_card_country
              , o_card_inst_id          => o_card_inst_id
              , o_card_network_id       => o_card_network_id
              , o_pan_length            => l_pan_length
              , i_raise_error           => com_api_const_pkg.FALSE
            );

            trc_log_pkg.debug (
                i_text              => 'Own bin search result [#1][#2][#3]'
              , i_env_param1        => iss_api_card_pkg.get_card_mask(l_card_number)
              , i_env_param2        => l_iss_network_id
              , i_env_param3        => l_iss_inst_id
            );

            if l_iss_network_id is null then

                trc_log_pkg.debug (
                    i_text              => 'net_api_bin_pkg.get_bin_info. i_terminal_type [#1], i_acq_inst_id [#2], i_acq_network_id [#3], i_oper_currency [#4]'
                  , i_env_param1        => i_terminal_type
                  , i_env_param2        => i_acq_inst_id
                  , i_env_param3        => i_acq_network_id
                  , i_env_param4        => i_oper_currency
                );

                l_iss_inst_id := io_inst_id;

                net_api_bin_pkg.get_bin_info(
                    i_card_number           => l_card_number
                  , i_oper_type             => i_oper_type
                  , i_terminal_type         => i_terminal_type
                  , i_acq_inst_id           => i_acq_inst_id
                  , i_acq_network_id        => i_acq_network_id
                  , i_msg_type              => i_msg_type
                  , i_oper_reason           => i_oper_reason
                  , i_oper_currency         => i_oper_currency
                  , i_merchant_id           => io_merchant_id
                  , i_terminal_id           => io_terminal_id
                  , io_iss_inst_id          => l_iss_inst_id
                  , o_iss_network_id        => l_iss_network_id
                  , o_iss_host_id           => o_host_id
                  , o_card_type_id          => o_card_type_id
                  , o_card_country          => o_card_country
                  , o_card_inst_id          => o_card_inst_id
                  , o_card_network_id       => o_card_network_id
                  , o_pan_length            => l_pan_length
                  , i_raise_error           => com_api_const_pkg.FALSE
                );

                trc_log_pkg.debug (
                    i_text              => 'Network bin search result [#1][#2][#3]'
                  , i_env_param1        => iss_api_card_pkg.get_card_mask(l_card_number)
                  , i_env_param2        => l_iss_network_id
                  , i_env_param3        => l_iss_inst_id
                );
            end if;

            if io_inst_id is null then
                io_inst_id := l_iss_inst_id;
            end if;
            if io_network_id is null then
                io_network_id := l_iss_network_id;
            end if;

            if io_network_id is null then
                if i_party_type = com_api_const_pkg.PARTICIPANT_DEST then
                    com_api_error_pkg.raise_error (
                        i_error             => 'UNKNOWN_DESTINATION_NETWORK'
                      , i_env_param1        => iss_api_card_pkg.get_card_mask(l_card_number)
                      , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id         => i_oper_id
                      , i_mask_error        => i_mask_error
                    );
                else
                    com_api_error_pkg.raise_error (
                        i_error             => 'UNKNOWN_ISSUING_NETWORK'
                      , i_env_param1        => iss_api_card_pkg.get_card_mask(l_card_number)
                      , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id         => i_oper_id
                      , i_mask_error        => i_mask_error
                    );
                end if;
            end if;
            trc_log_pkg.debug (
                i_text              => 'o_card_id [#1]'
              , i_env_param1        => o_card_id
            );

        elsif i_client_id_type in (aup_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT) then
            trc_log_pkg.debug (
                i_text              => 'Going to find own account [#1][#2][#3][#4]'
              , i_env_param1        => i_account_number
              , i_env_param2        => i_client_id_type
              , i_env_param3        => i_client_id_value
              , i_env_param4        => io_inst_id
            );

            acc_api_account_pkg.find_account (
                i_account_number        => nvl(i_account_number, i_client_id_value)
              , i_oper_type             => i_oper_type
              , i_party_type            => i_party_type
              , i_msg_type              => i_msg_type
              , i_inst_id               => io_inst_id
              , o_account_id            => o_account_id
              , o_customer_id           => io_customer_id
              , o_split_hash            => io_split_hash
              , o_inst_id               => io_inst_id
              , o_iss_network_id        => io_network_id
              , o_resp_code             => l_account_resp
            );

            if io_customer_id is null and
               is_gl_account(nvl(i_account_number, i_client_id_value), io_inst_id) = com_api_const_pkg.FALSE
            then
                com_api_error_pkg.raise_error (
                    i_error             => 'UNKNOWN_CUSTOMER'
                  , i_env_param1        => i_account_number
                  , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , i_object_id         => i_oper_id
                  , i_mask_error        => i_mask_error
                );

            elsif l_account_resp = aup_api_const_pkg.RESP_CODE_ACCOUNT_RESTRICTED then
                com_api_error_pkg.raise_error (
                    i_error             => 'ACCOUNT_RESTRICTED'
                  , i_env_param1        => i_account_number
                  , i_env_param2        => o_card_inst_id
                  , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , i_object_id         => i_oper_id
                  , i_mask_error        => i_mask_error
                );

            end if;

            --get host_id
            if i_party_type = com_api_const_pkg.PARTICIPANT_ISSUER then
                begin
                    o_host_id := net_api_network_pkg.get_default_host (
                        i_network_id          => io_network_id
                    );
                exception
                    when others then
                        o_host_id := null;
                end;
            end if;

        elsif i_client_id_type in (aup_api_const_pkg.CLIENT_ID_TYPE_EMAIL
                                 , aup_api_const_pkg.CLIENT_ID_TYPE_MOBILE
                                 , aup_api_const_pkg.CLIENT_ID_TYPE_CUSTOMER
                                 , aup_api_const_pkg.CLIENT_ID_TYPE_CONTRACT)
              or substr(i_client_id_type, 1, 4) = com_api_const_pkg.COMMUNICATION_METHOD_KEY
        then
            trc_log_pkg.debug (
                i_text              => 'Going to find own customer [#1][#2][#3]'
              , i_env_param1        => i_client_id_type
              , i_env_param2        => i_client_id_value
              , i_env_param3        => io_inst_id
            );

            prd_api_customer_pkg.find_customer (
                i_client_id_type      => i_client_id_type
              , i_client_id_value     => i_client_id_value
              , i_inst_id             => io_inst_id
              , o_customer_id         => io_customer_id
              , o_split_hash          => io_split_hash
              , o_inst_id             => io_inst_id
              , o_iss_network_id      => io_network_id
              , i_raise_error         => com_api_type_pkg.FALSE
              , i_error_value         => null
            );

            if io_customer_id is null then
                if i_party_type = com_api_const_pkg.PARTICIPANT_ISSUER then
                    com_api_error_pkg.raise_error(
                        i_error             => 'UNKNOWN_CUSTOMER'
                      , i_env_param1        => i_client_id_value
                      , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id         => i_oper_id
                      , i_mask_error        => i_mask_error
                    );
                else
                    io_network_id := net_api_const_pkg.UNIDENTIFIED_NETWORK;
                    io_inst_id := ost_api_const_pkg.UNIDENTIFIED_INST;
                end if;
            end if;

        -- define service provider as destination customer
        elsif i_client_id_type is null and
            i_party_type = com_api_const_pkg.PARTICIPANT_DEST and
            i_payment_order_id is not null
        then
            prd_api_customer_pkg.find_customer(
                i_acq_inst_id           => io_inst_id
              , i_payment_order_id      => i_payment_order_id
              , o_customer_id           => io_customer_id
            );

        elsif i_client_id_type in (opr_api_const_pkg.CLIENT_ID_TYPE_EXTCARD) then
            select
                min(purpose_id)
            into
                l_payment_purpose_id
            from
                pmo_order
            where
                id = i_payment_order_id;
            trc_log_pkg.debug (
                i_text        => 'payment_purpose_id[#1]'
              , i_env_param1  => l_payment_purpose_id
            );

            if nvl(l_payment_purpose_id, 0) in (
                pmo_api_const_pkg.TOPUP_FROM_LINKED_CARD
            ) then
                ecm_api_linked_card_pkg.get_linked_card_data(
                    i_linked_card_id   => i_client_id_value
                  , o_customer_id      => l_customer_id
                  , o_account_id       => l_account_id
                  , o_account_number   => l_account_number
                  , o_card_network_id  => o_card_network_id
                  , o_card_inst_id     => o_card_inst_id
                  , o_iss_network_id   => io_network_id
                  , o_iss_inst_id      => io_inst_id
                );

            else
                pmo_ui_linked_card_pkg.get_linked_card_data(
                    i_linked_card_id            => i_client_id_value
                  , o_customer_id               => l_customer_id
                  , o_account_id                => l_account_id
                  , o_account_number            => l_account_number
                  , o_card_network_id           => o_card_network_id
                  , o_card_inst_id              => o_card_inst_id
                  , o_iss_network_id            => io_network_id
                  , o_iss_inst_id               => io_inst_id
                );

            end if;

            select
                m.id
            into
                o_host_id
            from
                net_member m
            where
                m.network_id = io_network_id
                and m.inst_id = io_inst_id;

            trc_log_pkg.debug (
                i_text              => 'Linked card found [#1][#2][#3][#4][#5]'
              , i_env_param1        => o_card_network_id
              , i_env_param2        => o_card_inst_id
              , i_env_param3        => io_network_id
              , i_env_param4        => io_inst_id
              , i_env_param5        => o_host_id
            );

        elsif i_client_id_type = pmo_api_const_pkg.CLIENT_ID_TYPE_SRVP_NUMBER then
            trc_log_pkg.debug (
                i_text              => 'Going to find provider [#1][#2][#3]'
              , i_env_param1        => i_client_id_type
              , i_env_param2        => i_client_id_value
              , i_env_param3        => io_inst_id
            );

            prd_api_customer_pkg.find_customer (
                i_client_id_type      => i_client_id_type
              , i_client_id_value     => i_client_id_value
              , i_inst_id             => io_inst_id
              , o_customer_id         => io_customer_id
              , o_split_hash          => io_split_hash
              , o_inst_id             => io_inst_id
              , o_iss_network_id      => io_network_id
              , i_raise_error         => com_api_type_pkg.FALSE
              , i_error_value         => null
            );

            if io_customer_id is null then
                if i_party_type = com_api_const_pkg.PARTICIPANT_ISSUER then
                    com_api_error_pkg.raise_error(
                        i_error             => 'UNKNOWN_CUSTOMER'
                      , i_env_param1        => i_client_id_value
                      , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id         => i_oper_id
                      , i_mask_error        => i_mask_error
                    );
                else
                    io_network_id := net_api_const_pkg.UNIDENTIFIED_NETWORK;
                    io_inst_id := ost_api_const_pkg.UNIDENTIFIED_INST;
                end if;
            end if;

        elsif i_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_MERCHANT then
            trc_log_pkg.debug (
                i_text              => 'Going to find merchant [#1][#2][#3]'
              , i_env_param1        => i_client_id_type
              , i_env_param2        => i_client_id_value
              , i_env_param3        => io_inst_id
            );

            begin
                select m.id
                     , c.id
                     , c.split_hash
                  into io_merchant_id
                     , io_customer_id
                     , io_split_hash
                  from acq_merchant m
                     , prd_customer c
                 where m.contract_id = c.contract_id
                   and m.merchant_number = i_client_id_value
                   and m.inst_id = io_inst_id;

            exception
                when no_data_found then
                    io_merchant_id  := null;
                    io_customer_id  := null;
                    io_split_hash   := null;
            end;

        elsif i_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_TERMINAL then
            trc_log_pkg.debug (
                i_text              => 'Going to find terminal [#1][#2][#3]'
              , i_env_param1        => i_client_id_type
              , i_env_param2        => i_client_id_value
              , i_env_param3        => io_inst_id
            );

            begin
                select t.id
                     , m.id
                     , c.id
                     , c.split_hash
                  into io_terminal_id
                     , io_merchant_id
                     , io_customer_id
                     , io_split_hash
                  from acq_terminal t
                     , acq_merchant m
                     , prd_customer c
                 where t.terminal_number = i_client_id_value
                   and t.merchant_id = m.id
                   and t.contract_id = c.contract_id;
            exception
                when no_data_found then
                    io_merchant_id  := null;
                    io_terminal_id  := null;
                    io_customer_id  := null;
                    io_split_hash   := null;
            end;

        else
            cst_api_operation_pkg.define_network(
                i_msg_type              => i_msg_type
              , i_oper_type             => i_oper_type
              , i_party_type            => i_party_type
              , i_host_date             => i_host_date
              , io_network_id           => io_network_id
              , io_inst_id              => io_inst_id
              , o_host_id               => o_host_id
              , i_client_id_type        => i_client_id_type
              , i_client_id_value       => i_client_id_value
              , io_customer_id          => io_customer_id
              , io_split_hash           => io_split_hash
              , i_payment_host_id       => i_payment_host_id
              , i_payment_order_id      => i_payment_order_id
            );

            if io_network_id is null then
                com_api_error_pkg.raise_error (
                    i_error             => 'UNKNOWN_ISSUING_NETWORK'
                  , i_env_param1        => i_client_id_type
                  , i_env_param2        => i_client_id_value
                  , i_env_param3        => iss_api_card_pkg.get_card_mask(i_card_number)
                  , i_env_param4        => i_account_number
                  , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , i_object_id         => i_oper_id
                  , i_mask_error        => i_mask_error
                );
            end if;
        end if;
    end if;

    trc_log_pkg.debug (
        i_text              => 'Defined institution [#1] and network [#2]'
      , i_env_param1        => io_inst_id
      , i_env_param2        => io_network_id
    );
end define_network;

procedure perform_checks(
    i_oper_id               in      com_api_type_pkg.t_long_id
  , i_msg_type              in      com_api_type_pkg.t_dict_value
  , i_oper_type             in      com_api_type_pkg.t_dict_value
  , i_oper_reason           in      com_api_type_pkg.t_dict_value
  , i_party_type            in      com_api_type_pkg.t_dict_value
  , i_host_date             in      date
  , io_network_id           in out  com_api_type_pkg.t_tiny_id
  , io_inst_id              in out  com_api_type_pkg.t_inst_id
  , io_client_id_type       in out  com_api_type_pkg.t_dict_value
  , io_client_id_value      in out  com_api_type_pkg.t_name
  , io_card_number          in out  com_api_type_pkg.t_card_number
  , io_card_inst_id         in out  com_api_type_pkg.t_inst_id
  , io_card_network_id      in out  com_api_type_pkg.t_network_id
  , o_card_id                  out  com_api_type_pkg.t_medium_id
  , o_card_instance_id         out  com_api_type_pkg.t_medium_id
  , io_card_type_id         in out  com_api_type_pkg.t_tiny_id
  , io_card_mask            in out  com_api_type_pkg.t_card_number
  , io_card_hash            in out  com_api_type_pkg.t_medium_id
  , io_card_seq_number      in out  com_api_type_pkg.t_tiny_id
  , io_card_expir_date      in out  date
  , io_card_service_code    in out  com_api_type_pkg.t_country_code
  , io_card_country         in out  com_api_type_pkg.t_country_code
  , i_account_number        in      com_api_type_pkg.t_account_number
  , io_account_id           in out  com_api_type_pkg.t_medium_id
  , io_customer_id          in out  com_api_type_pkg.t_medium_id
  , i_merchant_number       in      com_api_type_pkg.t_merchant_number
  , io_merchant_id          in out  com_api_type_pkg.t_short_id
  , i_terminal_number       in      com_api_type_pkg.t_terminal_number
  , io_terminal_id          in out  com_api_type_pkg.t_short_id
  , o_split_hash               out  com_api_type_pkg.t_tiny_id
  , i_external_auth_id      in      com_api_type_pkg.t_attr_name        default null
  , i_external_orig_id      in      com_api_type_pkg.t_attr_name        default null
  , i_trace_number          in      com_api_type_pkg.t_attr_name        default null
  , i_mask_error            in      com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_is_reversal           in      com_api_type_pkg.t_boolean          default null
  , i_acq_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_acq_network_id        in      com_api_type_pkg.t_network_id       default null
  , i_oper_currency         in      com_api_type_pkg.t_curr_code        default null
  , i_acq_inst_bin          in      com_api_type_pkg.t_rrn              default null
  , i_iss_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_iss_network_id        in      com_api_type_pkg.t_network_id       default null
  , i_oper_date             in      date                                default null
  , i_originator_refnum     in      com_api_type_pkg.t_rrn              default null
) is
    l_checks            com_api_type_pkg.t_dict_tab;
    l_account_resp      com_api_type_pkg.t_dict_value;
    l_acq_inst_id       com_api_type_pkg.t_inst_id;
    l_iss_inst_id       com_api_type_pkg.t_inst_id;
    l_currency          com_api_type_pkg.t_curr_code;
    l_account_number    com_api_type_pkg.t_account_number;
    l_card_number       com_api_type_pkg.t_card_number;
    l_count             pls_integer;
    l_host_id           com_api_type_pkg.t_tiny_id;
    l_card_type_id      com_api_type_pkg.t_tiny_id;
    l_card_country      com_api_type_pkg.t_country_code;
    l_card_inst_id      com_api_type_pkg.t_tiny_id;
    l_card_network_id   com_api_type_pkg.t_network_id;
    l_pan_length        com_api_type_pkg.t_tiny_id;
    l_terminal_type     com_api_type_pkg.t_dict_value;
    l_iss_network_id    com_api_type_pkg.t_network_id;
    l_card_id           com_api_type_pkg.t_medium_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_card_token        iss_api_type_pkg.t_card_token_rec;
    l_params            com_api_type_pkg.t_param_tab;
    l_sttl_type         com_api_type_pkg.t_dict_value;
    l_match_status      com_api_type_pkg.t_dict_value;
    l_oper_detail_tab   opr_api_type_pkg.t_oper_detail_tab;

    procedure add_bin_info(
        i_oper_id           in      com_api_type_pkg.t_long_id
      , i_party_type        in      com_api_type_pkg.t_dict_value
      , i_card_network_id   in      com_api_type_pkg.t_network_id
      , i_card_number       in      com_api_type_pkg.t_card_number
      , i_card_type_id      in      com_api_type_pkg.t_tiny_id
    )
    is
        l_product_id                 com_api_type_pkg.t_dict_value;
        l_brand                      com_api_type_pkg.t_dict_value;
        l_region                     com_api_type_pkg.t_dict_value;
        l_product_type               com_api_type_pkg.t_dict_value;
        l_account_funding_source     com_api_type_pkg.t_dict_value;
        l_participant                opr_api_type_pkg.t_oper_part_rec;
    begin
        trc_log_pkg.debug(
            i_text => 'opr_api_const_pkg.CHECK_BIN_INFO ' || i_card_network_id || 
                      ' i_card_number=' || iss_api_card_pkg.get_card_mask(i_card_number) ||
                      ' i_card_type_id=' || i_card_type_id ||
                      ' i_card_network_id=' || i_card_network_id
        );
        if i_card_number is null then

            opr_api_operation_pkg.get_participant(
                i_oper_id           => i_oper_id
              , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
              , o_participant       => l_participant
            );
            trc_log_pkg.debug(
                i_text => 'found io_card_number=' || iss_api_card_pkg.get_card_mask(l_participant.card_number) ||
                         ' io_card_network_id='   || l_participant.card_network_id ||
                         ' io_card_type_id='      || l_participant.card_type_id
            );

        else
            l_participant.card_number     := i_card_number;
            l_participant.card_network_id := i_card_network_id;
            l_participant.card_type_id    := i_card_type_id;
        end if;

        case l_participant.card_network_id
            when mcw_api_const_pkg.MCW_NETWORK_ID then
                mcw_utl_pkg.get_bin_range_data(
                    i_card_number  => l_participant.card_number
                  , i_card_type_id => l_participant.card_type_id
                  , o_product_id   => l_product_id
                  , o_brand        => l_brand
                  , o_region       => l_region
                  , o_product_type => l_product_type
                );
            when vis_api_const_pkg.VISA_NETWORK_ID then                        
                vis_api_fin_message_pkg.get_bin_range_data(
                    i_card_number            => l_participant.card_number
                  , i_card_type_id           => l_participant.card_type_id
                  , o_product_id             => l_product_id
                  , o_region                 => l_region
                  , o_account_funding_source => l_account_funding_source
                );
            else null;
        end case;        
                
        trc_log_pkg.debug(
            i_text => 'opr_api_const_pkg.CHECK_BIN_INFO l_product_id=' || l_product_id ||
                     ' l_region || ' || l_region || '  l_product_type = ' || l_product_type ||
                     ' l_account_funding_source=' || l_account_funding_source ||
                     ' l_brand=' || l_brand
        );
        if l_product_id is not null or l_brand        is not null or 
            l_region    is not null or l_product_type is not null or
            l_account_funding_source                  is not null
        then                                
            begin                              
                insert into opr_bin_info(
                    oper_id
                  , participant_type
                  , split_hash
                  , product_id
                  , brand
                  , region
                  , product_type
                  , account_funding_source
                )
                values(
                    i_oper_id
                  , i_party_type
                  , com_api_hash_pkg.get_split_hash(
                        i_value => i_oper_id
                    )
                  , l_product_id
                  , l_brand
                  , l_region
                  , l_product_type
                  , l_account_funding_source
                );
            exception
                when dup_val_on_index then
                    com_api_error_pkg.raise_error (
                        i_error             => 'DUPLICATE_OPERATION'
                      , i_env_param1        => null
                      , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id         => i_oper_id
                    );
            end;
        end if;        
    end add_bin_info;
    
begin
    trc_log_pkg.debug(
        i_text            => 'Fetching checks for [#1][#2][#3][#4][#5]'
      , i_env_param1      => i_msg_type
      , i_env_param2      => i_oper_type
      , i_env_param3      => i_party_type
      , i_env_param4      => io_inst_id
      , i_env_param5      => io_network_id
    );

    opr_api_check_pkg.get_checks(
        i_msg_type            => i_msg_type
      , i_oper_type           => i_oper_type
      , i_party_type          => i_party_type
      , i_inst_id             => io_inst_id
      , i_network_id          => io_network_id
      , o_checks              => l_checks
    );

    if l_checks.count = 0 then
        trc_log_pkg.debug('No any check is found');
    else
        for i in 1 .. l_checks.count loop
            trc_log_pkg.debug (
                i_text              => 'Going to check [#1]'
              , i_env_param1        => l_checks(i)
            );

            case
                when l_checks(i) = opr_api_const_pkg.CHECK_SKIP then
                    trc_log_pkg.debug (
                        i_text              => 'Skip checks'
                    );
                    return;

                when l_checks(i) = opr_api_const_pkg.CHECK_OWN_MERCHANT then
                    trc_log_pkg.debug (
                        i_text              => 'Incoming merchant [#1][#2]'
                      , i_env_param1        => i_merchant_number
                      , i_env_param2        => io_inst_id
                    );

                    if is_number_empty(io_merchant_id) then
                        acq_api_merchant_pkg.get_merchant(
                            i_inst_id           => io_inst_id
                          , i_merchant_number   => i_merchant_number
                          , o_customer_id       => io_customer_id
                          , o_merchant_id       => io_merchant_id
                          , o_split_hash        => o_split_hash
                        );

                        if io_merchant_id is null then
                            com_api_error_pkg.raise_error (
                                i_error             => 'UNKNOWN_MERCHANT'
                              , i_env_param1        => i_merchant_number
                              , i_env_param2        => io_inst_id
                              , i_mask_error        => i_mask_error
                              , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              , i_object_id         => i_oper_id
                            );
                        end if;

                        trc_log_pkg.debug (
                            i_text              => 'Merchant got [#1][#2][#3]'
                          , i_env_param1        => io_inst_id
                          , i_env_param2        => i_merchant_number
                          , i_env_param3        => io_merchant_id
                        );

                    elsif not is_number_empty(io_merchant_id) then
                        o_split_hash :=
                            com_api_hash_pkg.get_split_hash (
                                i_entity_type       => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                              , i_object_id         => io_merchant_id
                            );
                    end if;

                when l_checks(i) = opr_api_const_pkg.CHECK_OWN_TERMINAL then
                    trc_log_pkg.debug (
                        i_text              => 'Incoming terminal [#1][#2][#3]'
                      , i_env_param1        => io_merchant_id
                      , i_env_param2        => i_terminal_number
                      , i_env_param3        => io_terminal_id
                    );

                    if is_number_empty(io_terminal_id) then
                        acq_api_terminal_pkg.get_terminal (
                            i_merchant_id       => io_merchant_id
                          , i_terminal_number   => i_terminal_number
                          , o_terminal_id       => io_terminal_id
                        );

                        trc_log_pkg.debug (
                            i_text              => 'Terminal got [#1][#2][#3]'
                          , i_env_param1        => io_merchant_id
                          , i_env_param2        => i_terminal_number
                          , i_env_param3        => io_terminal_id
                        );

                        if is_number_empty(io_terminal_id) then
                            com_api_error_pkg.raise_error (
                                i_error             => 'UNKNOWN_TERMINAL'
                              , i_env_param1        => io_inst_id
                              , i_env_param2        => i_merchant_number
                              , i_env_param3        => io_merchant_id
                              , i_env_param4        => i_terminal_number
                              , i_mask_error        => i_mask_error
                              , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              , i_object_id         => i_oper_id
                            );
                        end if;
                    end if;

                when l_checks(i) = opr_api_const_pkg.CHECK_OWN_CARD then
                    if io_client_id_type in (opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                                           , opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID)
                    then
                        trc_log_pkg.debug(
                            i_text       => 'Start card searching because of customer identification type [#1]'
                          , i_env_param1 => io_client_id_type
                        );
                        l_card_number :=
                            case io_client_id_type
                                when opr_api_const_pkg.CLIENT_ID_TYPE_CARD then
                                    nvl(io_card_number, io_client_id_value)
                                when opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID then
                                    iss_api_card_pkg.get_card_number (i_card_uid => io_client_id_value)
                            end;
                        io_card_mask := iss_api_card_pkg.get_card_mask(l_card_number);
                        io_card_hash := com_api_hash_pkg.get_card_hash(l_card_number);

                        get_card (
                            i_card_number         => l_card_number
                          , i_host_date           => i_host_date
                          , io_seq_number         => io_card_seq_number
                          , io_expir_date         => io_card_expir_date
                          , io_card_service_code  => io_card_service_code
                          , o_card_id             => o_card_id
                          , o_card_instance_id    => o_card_instance_id
                          , o_customer_id         => io_customer_id
                          , o_card_type_id        => io_card_type_id
                          , o_card_country        => io_card_country
                          , o_card_inst_id        => io_card_inst_id
                          , io_card_network_id    => io_card_network_id
                          , o_split_hash          => o_split_hash
                          , i_oper_id             => i_oper_id
                          , i_mask_error          => i_mask_error
                        );

                        trc_log_pkg.debug (
                            i_text              => 'Card search results [#1][#2][#3]'
                          , i_env_param1        => iss_api_card_pkg.get_card_mask(l_card_number)
                          , i_env_param2        => o_card_id
                          , i_env_param3        => io_customer_id
                        );
                    else
                        trc_log_pkg.debug (
                            i_text              => 'Card search isn''t required because of different customer identification type [#1]'
                          , i_env_param1        => io_client_id_type
                        );
                    end if;

--                    when l_checks(i) = opr_api_const_pkg.CHECK_ISS_HOST_CONSUMER then
--                        o_acq_member_id :=
--                            net_api_network_pkg.get_member_id (
--                                i_inst_id           => i_acq_inst_id
--                              , i_network_id        => o_iss_network_id
--                            );

                when l_checks(i) = opr_api_const_pkg.CHECK_FOREIGN_CARD then
                    if io_client_id_type in (opr_api_const_pkg.CLIENT_ID_TYPE_CARD)
                    then
                        trc_log_pkg.debug(
                            i_text       => 'Start getting BIN info because of customer identification type [#1]'
                          , i_env_param1 => io_client_id_type
                        );
                        l_card_number := nvl(io_card_number, io_client_id_value);

                        iss_api_bin_pkg.get_bin_info(
                            i_card_number           => l_card_number
                          , i_oper_type             => i_oper_type
                          , i_terminal_type         => l_terminal_type
                          , i_acq_inst_id           => i_acq_inst_id
                          , i_acq_network_id        => i_acq_network_id
                          , i_msg_type              => i_msg_type
                          , i_oper_reason           => i_oper_reason
                          , i_oper_currency         => i_oper_currency
                          , i_merchant_id           => io_merchant_id
                          , i_terminal_id           => io_terminal_id
                          , o_iss_inst_id           => l_iss_inst_id
                          , o_iss_network_id        => l_iss_network_id
                          , o_iss_host_id           => l_host_id
                          , o_card_type_id          => l_card_type_id
                          , o_card_country          => l_card_country
                          , o_card_inst_id          => l_card_inst_id
                          , o_card_network_id       => l_card_network_id
                          , o_pan_length            => l_pan_length
                          , i_raise_error           => com_api_const_pkg.FALSE
                        );

                        if l_iss_network_id is null then
                            net_api_bin_pkg.get_bin_info(
                                i_card_number           => l_card_number
                              , i_oper_type             => i_oper_type
                              , i_terminal_type         => l_terminal_type
                              , i_acq_inst_id           => i_acq_inst_id
                              , i_acq_network_id        => i_acq_network_id
                              , i_msg_type              => i_msg_type
                              , i_oper_reason           => i_oper_reason
                              , i_oper_currency         => i_oper_currency
                              , i_merchant_id           => io_merchant_id
                              , i_terminal_id           => io_terminal_id
                              , o_iss_inst_id           => l_iss_inst_id
                              , o_iss_network_id        => l_iss_network_id
                              , o_iss_host_id           => l_host_id
                              , o_card_type_id          => l_card_type_id
                              , o_card_country          => l_card_country
                              , o_card_inst_id          => l_card_inst_id
                              , o_card_network_id       => l_card_network_id
                              , o_pan_length            => l_pan_length
                              , i_raise_error           => com_api_const_pkg.FALSE
                            );
                            trc_log_pkg.debug (
                                i_text              => 'BIN search results [#1][#2][#3][#4][#5]'
                              , i_env_param1        => iss_api_card_pkg.get_card_mask(l_card_number)
                              , i_env_param2        => l_card_type_id
                              , i_env_param3        => l_card_country
                              , i_env_param4        => l_card_inst_id
                              , i_env_param5        => l_card_network_id
                            );
                            if l_iss_network_id is not null then
                                io_card_type_id    := l_card_type_id;
                                io_card_country    := l_card_country;
                                io_card_inst_id    := l_card_inst_id;
                                io_card_network_id := l_card_network_id;
                                io_inst_id         := l_iss_inst_id;
                                io_network_id      := l_iss_network_id;
                            end if;
                        else
                            trc_log_pkg.debug (
                                i_text              => 'BIN search results (Found own BIN) [#1]'
                              , i_env_param1        => iss_api_card_pkg.get_card_mask(l_card_number)
                            );
                        end if;

                    else
                        trc_log_pkg.debug (
                            i_text              => 'Card search isn''t required because of different customer identification type [#1]'
                          , i_env_param1        => io_client_id_type
                        );
                    end if;

                when l_checks(i) = opr_api_const_pkg.CHECK_FIND_ACCOUNT then

                    if io_account_id is null then
                        trc_log_pkg.debug(
                            i_text       => 'Start account searching: [#1][#2][#3][#4][#5][#6]'
                          , i_env_param1 => i_account_number
                          , i_env_param2 => i_oper_type
                          , i_env_param3 => io_card_inst_id
                          , i_env_param4 => io_inst_id
                          , i_env_param5 => i_party_type
                          , i_env_param6 => i_msg_type
                        );
                        acc_api_account_pkg.find_account(
                            i_account_number  => i_account_number
                          , i_oper_type       => i_oper_type
                          , i_inst_id         => nvl(io_card_inst_id, io_inst_id)
                          , i_party_type      => i_party_type
                          , i_msg_type        => i_msg_type
                          , o_account_id      => io_account_id
                          , o_resp_code       => l_account_resp
                        );
                    else
                        trc_log_pkg.debug(
                            i_text       => 'Searching account by number isn''t required because account identifier [#1] is present'
                          , i_env_param1 => io_account_id
                        );
                    end if;

                    if io_account_id is null then
                        com_api_error_pkg.raise_error (
                            i_error             => 'UNKNOWN_ACCOUNT'
                          , i_env_param1        => i_account_number
                          , i_env_param2        => io_card_inst_id
                          , i_mask_error        => i_mask_error
                          , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          , i_object_id         => i_oper_id
                        );

                    elsif l_account_resp = aup_api_const_pkg.RESP_CODE_ACCOUNT_RESTRICTED then
                        com_api_error_pkg.raise_error (
                            i_error             => 'ACCOUNT_RESTRICTED'
                          , i_env_param1        => i_account_number
                          , i_env_param2        => io_card_inst_id
                          , i_mask_error        => i_mask_error
                          , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          , i_object_id         => i_oper_id
                        );
                    end if;

                when l_checks(i) = opr_api_const_pkg.CHECK_FIND_INSTITUTION_CUST then
                    -- find acq institution
                    begin
                        select a.inst_id
                          into l_acq_inst_id
                          from opr_participant a
                         where a.oper_id = g_oper_id
                           and a.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER;
                    exception
                        when no_data_found then
                            com_api_error_pkg.raise_error(
                                i_error        => 'ACQ_INST_NOT_FOUND'
                              , i_env_param1   => g_oper_id
                              , i_mask_error   => i_mask_error
                              , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              , i_object_id    => i_oper_id
                            );
                    end;

                    io_customer_id :=
                        prd_api_customer_pkg.get_customer_id(
                            i_ext_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                          , i_ext_object_id   => io_inst_id
                          , i_inst_id         => l_acq_inst_id
                        );
                    -- prd_api_customer_pkg.get_customer_id(i_ext_...) doesn't raise an error on NO_DATA_FOUND
                    if io_customer_id is null then
                        com_api_error_pkg.raise_error(
                            i_error        => 'EXT_CUSTOMER_DOES_NOT_EXIST'
                          , i_env_param1   => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                          , i_env_param2   => io_inst_id
                          , i_env_param3   => l_acq_inst_id
                          , i_mask_error   => i_mask_error
                          , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          , i_object_id    => i_oper_id
                        );
                    end if;

                when l_checks(i) = opr_api_const_pkg.CHECK_DEFINE_PAYMENT_PROVIDER then
                    -- Find payment provider as a customer with extended type ENTITY_TYPE_INSTITUTION,
                    -- presume that io_network_id can't be NULL
                    l_iss_inst_id := net_api_network_pkg.get_inst_id(i_network_id => io_network_id);

                    if l_iss_inst_id is not null then
                        com_api_error_pkg.raise_error(
                            i_error        => 'ACQ_INST_NOT_FOUND'
                          , i_env_param1   => g_oper_id
                          , i_mask_error   => i_mask_error
                          , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          , i_object_id    => i_oper_id
                        );
                    end if;
                    trc_log_pkg.debug(
                        i_text       => 'call prd_api_customer_pkg.get_customer_id [#1][#2] for extended customer type'
                      , i_env_param1 => io_inst_id
                      , i_env_param2 => l_iss_inst_id
                    );

                    io_customer_id :=
                        prd_api_customer_pkg.get_customer_id(
                            i_ext_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                          , i_ext_object_id   => io_inst_id
                          , i_inst_id         => l_iss_inst_id
                        );

                    trc_log_pkg.debug (
                        i_text         => 'prd_api_customer_pkg.get_customer_id returned [#1]'
                      , i_env_param1   => io_customer_id
                    );

                    -- Search deposit account of a customer that is actually payment provider,
                    -- if account is not found then debug error message is logged inside of procedure
                    acc_api_account_pkg.find_account (
                        i_customer_id       => io_customer_id
                      , i_account_type      => acc_api_const_pkg.ACCOUNT_TYPE_PAYM_PROV_DEPOSIT
                      , io_currency         => l_currency
                      , o_account_id        => io_account_id
                      , o_account_number    => l_account_number
                    );

                when l_checks(i) = opr_api_const_pkg.CHECK_DUPLICATE_OPERATION then
                    -- Find duplicate operation using external_auth_id
                    select count(1)
                      into l_count
                      from aut_auth a
                         , opr_operation o
                     where a.external_auth_id = i_external_auth_id
                       and o.id = a.id
                       and (i_is_reversal is null or i_is_reversal = o.is_reversal);

                    trc_log_pkg.debug (
                        i_text         => 'l_count [#1]'
                      , i_env_param1   => l_count
                    );

                    if l_count > 0 then
                        com_api_error_pkg.raise_error (
                            i_error             => 'DUPLICATE_OPERATION'
                          , i_env_param1        => i_external_auth_id
                          , i_mask_error        => i_mask_error
                          , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          , i_object_id         => i_oper_id
                        );
                    end if;

                when l_checks(i) = opr_api_const_pkg.CHECK_DEFINE_CUST_BY_MRCH_PAN then
                    l_card_id := iss_api_card_pkg.get_card_id(
                                     i_card_number  => nvl(io_card_number, io_client_id_value)
                                 );

                    l_split_hash := com_api_hash_pkg.get_split_hash(
                                        i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                                      , i_object_id   => l_card_id
                                      , i_mask_error  => com_api_const_pkg.FALSE
                                    );
                    begin
                        select m.id, c.customer_id
                          into io_merchant_id, io_customer_id
                          from acc_account_object a
                             , acc_account_object b
                             , acq_merchant       m
                             , prd_contract       c
                         where a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and a.object_id   = l_card_id
                           and a.split_hash  = l_split_hash
                           and a.account_id  = b.account_id
                           and b.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                           and b.split_hash  = l_split_hash
                           and m.id          = b.object_id
                           and m.contract_id = c.id
                           and m.split_hash  = c.split_hash
                           and c.inst_id     = nvl(io_inst_id, c.inst_id);
                    exception
                        when no_data_found then
                            com_api_error_pkg.raise_error(
                                i_error             => 'CUSTOMER_NOT_FOUND'
                              , i_env_param1        => io_customer_id
                              , i_env_param2        => io_inst_id
                              , i_mask_error        => i_mask_error
                              , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              , i_object_id         => i_oper_id
                            );
                    end;

                    trc_log_pkg.debug(
                        i_text          => 'Customer got [#1][#2]'
                      , i_env_param1    => iss_api_card_pkg.get_card_mask(l_card_number)
                      , i_env_param2    => io_customer_id
                    );

                when l_checks(i) = opr_api_const_pkg.CHECK_BIN_INFO then

                    add_bin_info(
                        i_oper_id         => i_oper_id
                      , i_party_type      => i_party_type 
                      , i_card_network_id => io_card_network_id
                      , i_card_number     => io_card_number
                      , i_card_type_id    => io_card_type_id
                    );
                when l_checks(i) = opr_api_const_pkg.CHECK_ISS_TOKEN_THEM_ON_US then
                    trc_log_pkg.debug (
                        i_text       => 'CHECK_ISS_TOKEN_THEM_ON_US: iss_inst_id [#1] inst_id [#2]'
                                   ||'iss_network_id[#3] network_id [#4] acq_inst_bin [#5] card_number [#6]'
                      , i_env_param1 => i_iss_inst_id
                      , i_env_param2 => io_inst_id
                      , i_env_param3 => i_iss_network_id
                      , i_env_param4 => io_network_id
                      , i_env_param5 => i_acq_inst_bin
                      , i_env_param6 => io_card_number
                    );

                    iss_api_bin_pkg.get_bin_info (
                        i_card_number     => io_card_number
                      , o_card_inst_id    => l_card_inst_id
                      , o_card_network_id => l_card_network_id
                      , o_card_type       => l_card_type_id
                      , o_card_country    => l_card_country
                      , i_raise_error     => com_api_const_pkg.FALSE
                    );

                    if l_card_inst_id is not null
                   and l_card_network_id is not null
                   and l_card_type_id is not null
                    then
                        -- this is our BIN. Try to find card in our database
                        l_card_token := 
                            iss_api_card_token_pkg.get_token(
                                i_token       => io_card_number
                              , i_mask_error  => com_api_const_pkg.TRUE
                            );

                        if l_card_token.id is not null then
                            -- this is our own card. Set IS_LOOP flag, correct sttl_type and match_status
                            l_params('IS_LOOP') := com_api_type_pkg.TRUE;

                            trc_log_pkg.debug(
                                i_text         => 'CHECK_ISS_TOKEN_THEM_ON_US: card_token [#1] found. Set IS_LOOP flag to 1'
                              , i_env_param1   => l_card_token.card_id
                            );

                            net_api_sttl_pkg.get_sttl_type(
                                i_iss_inst_id     => io_inst_id
                              , i_acq_inst_id     => i_acq_inst_id
                              , i_card_inst_id    => null
                              , i_iss_network_id  => io_network_id
                              , i_acq_network_id  => i_acq_network_id
                              , i_card_network_id => null
                              , i_acq_inst_bin    => i_acq_inst_bin
                              , o_sttl_type       => l_sttl_type
                              , o_match_status    => l_match_status
                              , i_mask_error      => com_api_const_pkg.FALSE
                              , i_error_value     => null
                              , i_params          => l_params
                              , i_oper_type       => i_oper_type
                            );

                            if l_sttl_type is not null or l_match_status is not null then
                                update opr_operation 
                                   set sttl_type    = nvl(l_sttl_type, sttl_type)
                                     , match_status = nvl(l_match_status, match_status)
                                 where id           = i_oper_id;
                                trc_log_pkg.debug(
                                    i_text         => 'CHECK_ISS_TOKEN_THEM_ON_US: changed sttl_type [#1] and match_status[#2] for operation [#3]'
                                  , i_env_param1   => l_sttl_type
                                  , i_env_param2   => l_match_status
                                  , i_env_param3   => i_oper_id
                                );                             
                            end if;
                            o_card_id := nvl(l_card_token.card_id, o_card_id);
                            trc_log_pkg.debug(
                                i_text         => 'CHECK_ISS_TOKEN_THEM_ON_US: changed O_CARD_ID to [#1]'
                              , i_env_param1   => o_card_id
                            );                             
                        end if;
                    end if;

                when l_checks(i) = opr_api_const_pkg.CHECK_ACQ_TOKEN_US_ON_THEM then
                    trc_log_pkg.debug (
                        i_text       => 'CHECK_ACQ_TOKEN_US_ON_TNEM: i_iss_inst_id [#1] io_inst_id [#2]'
                                      ||'i_iss_network_id[#3] io_network_id [#4] i_acq_inst_bin [#5]'
                      , i_env_param1 => i_iss_inst_id
                      , i_env_param2 => io_inst_id
                      , i_env_param3 => i_iss_network_id
                      , i_env_param4 => io_network_id
                      , i_env_param5 => i_acq_inst_bin
                    );

                    net_api_sttl_pkg.get_sttl_type(
                        i_iss_inst_id     => i_iss_inst_id
                      , i_acq_inst_id     => io_inst_id
                      , i_card_inst_id    => null
                      , i_iss_network_id  => i_iss_network_id
                      , i_acq_network_id  => io_network_id
                      , i_card_network_id => null
                      , i_acq_inst_bin    => i_acq_inst_bin
                      , o_sttl_type       => l_sttl_type
                      , o_match_status    => l_match_status
                      , i_mask_error      => com_api_const_pkg.FALSE
                      , i_error_value     => null
                      , i_params          => l_params
                      , i_oper_type       => i_oper_type
                    );
                    if l_sttl_type is not null or l_match_status is not null then
                        update opr_operation
                           set sttl_type    = nvl(l_sttl_type, sttl_type)
                             , match_status = nvl(l_match_status, match_status)
                         where id           = i_oper_id;

                        trc_log_pkg.debug(
                            i_text         => 'CHECK_ACQ_TOKEN_US_ON_TNEM: changed sttl_type [#1] and match_status[#2] for operation [#3]'
                          , i_env_param1   => l_sttl_type
                          , i_env_param2   => l_match_status
                          , i_env_param3   => i_oper_id
                        );
                    end if;

                when l_checks(i) = opr_api_const_pkg.CHECK_INSTITUTION_STATUS then
                    trc_log_pkg.debug (
                        i_text       => 'CHECK_INSTITUTION_STATUS: i_iss_inst_id [#1] io_inst_id [#2]'
                                      ||'i_iss_network_id[#3] io_network_id [#4] i_acq_inst_bin [#5]'
                      , i_env_param1 => i_iss_inst_id
                      , i_env_param2 => io_inst_id
                      , i_env_param3 => i_iss_network_id
                      , i_env_param4 => io_network_id
                      , i_env_param5 => i_acq_inst_bin
                    );
                    
                    ost_api_institution_pkg.check_status(
                        i_inst_id     => io_inst_id
                      , i_data_action => com_api_const_pkg.DATA_ACTION_FIN_PROC
                    );

                when l_checks(i) = opr_api_const_pkg.CHECK_DEFINE_OPER_ORDERS then

                    begin
                        select to_number(null)
                             , i_oper_id
                             , pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                             , o.id
                          bulk collect into
                               l_oper_detail_tab
                          from pmo_order o
                         where o.originator_refnum = i_originator_refnum
                           and o.event_date        = i_oper_date
                           and o.status            = pmo_api_const_pkg.PMO_STATUS_REQUIRE_MATCHING
                           and o.part_key          = trunc(i_oper_date);

                        opr_api_detail_pkg.set_oper_detail(
                            i_oper_id            => i_oper_id
                          , i_object_tab         => l_oper_detail_tab
                          , i_date               => i_oper_date
                        );

                        forall i in 1 .. l_oper_detail_tab.count
                            update pmo_order
                               set status = pmo_api_const_pkg.PMO_STATUS_PROCESSED
                             where id = l_oper_detail_tab(i).object_id;
                      end;
                else
                    if cst_api_check_pkg.perform_check(
                           i_oper_id                 => i_oper_id
                         , i_check_type              => l_checks(i)
                         , i_msg_type                => i_msg_type
                         , i_oper_type               => i_oper_type
                         , i_oper_reason             => i_oper_reason
                         , i_party_type              => i_party_type
                         , i_host_date               => i_host_date
                         , io_network_id             => io_network_id
                         , io_inst_id                => io_inst_id
                         , io_client_id_type         => io_client_id_type
                         , io_client_id_value        => io_client_id_value
                         , io_card_number            => io_card_number
                         , io_card_inst_id           => io_card_inst_id
                         , io_card_network_id        => io_card_network_id
                         , io_card_id                => o_card_id
                         , io_card_instance_id       => o_card_instance_id
                         , io_card_type_id           => io_card_type_id
                         , io_card_mask              => io_card_mask
                         , io_card_hash              => io_card_hash
                         , io_card_seq_number        => io_card_seq_number
                         , io_card_expir_date        => io_card_expir_date
                         , io_card_service_code      => io_card_service_code
                         , io_card_country           => io_card_country
                         , i_account_number          => i_account_number
                         , io_account_id             => io_account_id
                         , io_customer_id            => io_customer_id
                         , i_merchant_number         => i_merchant_number
                         , io_merchant_id            => io_merchant_id
                         , i_terminal_number         => i_terminal_number
                         , io_terminal_id            => io_terminal_id
                         , io_split_hash             => o_split_hash
                         , i_external_auth_id        => i_external_auth_id
                         , i_external_orig_id        => i_external_orig_id
                         , i_trace_number            => i_trace_number
                         , i_mask_error              => i_mask_error
                         , i_is_reversal             => i_is_reversal
                       ) = com_api_type_pkg.FALSE
                    then
                        com_api_error_pkg.raise_error (
                            i_error             => 'UNKNOWN_CHECK_TYPE'
                          , i_env_param1        => l_checks(i)
                          , i_env_param2        => i_msg_type
                          , i_env_param3        => i_oper_type
                          , i_env_param4        => i_party_type
                          , i_env_param5        => io_inst_id
                          , i_env_param6        => io_network_id
                          , i_mask_error        => i_mask_error
                          , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          , i_object_id         => i_oper_id
                        );
                    end if;
            end case;
            trc_log_pkg.debug('Check completed');
        end loop;

        trc_log_pkg.debug('All checks completed, in total: ' || l_checks.count());

        trc_log_pkg.debug (
            i_text          => 'Split hash got [#1]'
          , i_env_param1    => o_split_hash
        );
    end if;
end perform_checks;

procedure create_operation (
    io_oper_id                  in out  com_api_type_pkg.t_long_id
  , i_session_id                in      com_api_type_pkg.t_long_id          default null
  , i_is_reversal               in      com_api_type_pkg.t_boolean
  , i_original_id               in      com_api_type_pkg.t_long_id          default null
  , i_oper_type                 in      com_api_type_pkg.t_dict_value
  , i_oper_reason               in      com_api_type_pkg.t_dict_value       default null
  , i_msg_type                  in      com_api_type_pkg.t_dict_value
  , i_status                    in      com_api_type_pkg.t_dict_value
  , i_status_reason             in      com_api_type_pkg.t_dict_value       default null
  , i_sttl_type                 in      com_api_type_pkg.t_dict_value
  , i_terminal_type             in      com_api_type_pkg.t_dict_value       default null
  , i_acq_inst_bin              in      com_api_type_pkg.t_rrn              default null
  , i_forw_inst_bin             in      com_api_type_pkg.t_rrn              default null
  , i_merchant_number           in      com_api_type_pkg.t_merchant_number  default null
  , i_terminal_number           in      com_api_type_pkg.t_terminal_number  default null
  , i_merchant_name             in      com_api_type_pkg.t_name             default null
  , i_merchant_street           in      com_api_type_pkg.t_name             default null
  , i_merchant_city             in      com_api_type_pkg.t_name             default null
  , i_merchant_region           in      com_api_type_pkg.t_name             default null
  , i_merchant_country          in      com_api_type_pkg.t_curr_code        default null
  , i_merchant_postcode         in      com_api_type_pkg.t_name             default null
  , i_mcc                       in      com_api_type_pkg.t_mcc              default null
  , i_originator_refnum         in      com_api_type_pkg.t_rrn              default null
  , i_network_refnum            in      com_api_type_pkg.t_rrn              default null
  , i_oper_count                in      com_api_type_pkg.t_long_id          default null
  , i_oper_request_amount       in      com_api_type_pkg.t_money            default null
  , i_oper_amount_algorithm     in      com_api_type_pkg.t_dict_value       default null
  , i_oper_amount               in      com_api_type_pkg.t_money            default null
  , i_oper_currency             in      com_api_type_pkg.t_curr_code        default null
  , i_oper_cashback_amount      in      com_api_type_pkg.t_money            default null
  , i_oper_replacement_amount   in      com_api_type_pkg.t_money            default null
  , i_oper_surcharge_amount     in      com_api_type_pkg.t_money            default null
  , i_oper_date                 in      date                                default null
  , i_host_date                 in      date                                default null
  , i_match_status              in      com_api_type_pkg.t_dict_value       default null
  , i_sttl_amount               in      com_api_type_pkg.t_money            default null
  , i_sttl_currency             in      com_api_type_pkg.t_curr_code        default null
  , i_dispute_id                in      com_api_type_pkg.t_long_id          default null
  , i_payment_order_id          in      com_api_type_pkg.t_long_id          default null
  , i_payment_host_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_forced_processing         in      com_api_type_pkg.t_boolean          default null
  , i_proc_mode                 in      com_api_type_pkg.t_dict_value       default null
  , i_clearing_sequence_num     in      com_api_type_pkg.t_tiny_id          default null
  , i_clearing_sequence_count   in      com_api_type_pkg.t_tiny_id          default null
  , i_incom_sess_file_id        in      com_api_type_pkg.t_long_id          default null
  , i_fee_amount                in      com_api_type_pkg.t_money            default null
  , i_fee_currency              in      com_api_type_pkg.t_curr_code        default null
  , i_sttl_date                 in      date                                default null
  , i_acq_sttl_date             in      date                                default null
  , i_match_id                  in      com_api_type_pkg.t_long_id          default null
) is
    l_merchant_country                  com_api_type_pkg.t_country_code;
begin
    if io_oper_id is null then
        io_oper_id := get_id(
                          i_host_date => i_host_date
                      );
    end if;

    g_oper_id          := io_oper_id;
    l_merchant_country := com_api_country_pkg.get_internal_country_code(
                              i_external_country_code => i_merchant_country
                          );

    trc_log_pkg.debug(
        i_text        => 'Registering operation with ID [#1], payment_order_id [#2]'
      , i_env_param1  => io_oper_id
      , i_env_param2  => i_payment_order_id
      , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id   => io_oper_id
    );

    insert into opr_operation (
        id
      , session_id
      , is_reversal
      , original_id
      , oper_type
      , oper_reason
      , msg_type
      , status
      , status_reason
      , sttl_type
      , terminal_type
      , acq_inst_bin
      , forw_inst_bin
      , merchant_number
      , terminal_number
      , merchant_name
      , merchant_street
      , merchant_city
      , merchant_region
      , merchant_country
      , merchant_postcode
      , mcc
      , originator_refnum
      , network_refnum
      , oper_count
      , oper_request_amount
      , oper_amount_algorithm
      , oper_amount
      , oper_currency
      , oper_cashback_amount
      , oper_replacement_amount
      , oper_surcharge_amount
      , oper_date
      , host_date
      , match_status
      , sttl_amount
      , sttl_currency
      , dispute_id
      , payment_order_id
      , payment_host_id
      , forced_processing
      , match_id
      , proc_mode
      , clearing_sequence_num
      , clearing_sequence_count
      , incom_sess_file_id
      , fee_amount
      , fee_currency
      , sttl_date
      , acq_sttl_date
    ) values (
        io_oper_id
      , nvl(i_session_id, get_session_id)
      , i_is_reversal
      , i_original_id
      , i_oper_type
      , i_oper_reason
      , i_msg_type
      , i_status
      , i_status_reason
      , i_sttl_type
      , i_terminal_type
      , i_acq_inst_bin
      , i_forw_inst_bin
      , i_merchant_number
      , i_terminal_number
      , i_merchant_name
      , i_merchant_street
      , i_merchant_city
      , i_merchant_region
      , l_merchant_country
      , i_merchant_postcode
      , i_mcc
      , i_originator_refnum
      , i_network_refnum
      , i_oper_count
      , i_oper_request_amount
      , i_oper_amount_algorithm
      , i_oper_amount
      , i_oper_currency
      , i_oper_cashback_amount
      , i_oper_replacement_amount
      , i_oper_surcharge_amount
      , nvl(i_oper_date, com_api_sttl_day_pkg.get_sysdate)
      , nvl(i_host_date, com_api_sttl_day_pkg.get_sysdate)
      , i_match_status
      , i_sttl_amount
      , i_sttl_currency
      , i_dispute_id
      , i_payment_order_id
      , i_payment_host_id
      , i_forced_processing
      , i_match_id
      , nvl(i_proc_mode, aut_api_const_pkg.DEFAULT_AUTH_PROC_MODE)
      , i_clearing_sequence_num
      , i_clearing_sequence_count
      , i_incom_sess_file_id
      , i_fee_amount
      , i_fee_currency
      , i_sttl_date
      , i_acq_sttl_date
    );

    evt_api_status_pkg.add_status_log(
        i_event_type    => null
      , i_initiator     => evt_api_const_pkg.INITIATOR_SYSTEM
      , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id     => io_oper_id
      , i_reason        => i_oper_reason
      , i_status        => i_status
      , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
    );
end;

procedure add_participant(
    i_oper_id               in      com_api_type_pkg.t_long_id
  , i_msg_type              in      com_api_type_pkg.t_dict_value
  , i_oper_type             in      com_api_type_pkg.t_dict_value
  , i_oper_reason           in      com_api_type_pkg.t_dict_value       default null
  , i_participant_type      in      com_api_type_pkg.t_dict_value
  , i_host_date             in      date                                default null
  , i_client_id_type        in      com_api_type_pkg.t_dict_value       default null
  , i_client_id_value       in      com_api_type_pkg.t_name             default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id          default null
  , i_network_id            in      com_api_type_pkg.t_network_id       default null
  , i_card_inst_id          in      com_api_type_pkg.t_inst_id          default null
  , i_card_network_id       in      com_api_type_pkg.t_network_id       default null
  , i_card_id               in      com_api_type_pkg.t_medium_id        default null
  , i_card_instance_id      in      com_api_type_pkg.t_medium_id        default null
  , i_card_type_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_card_number           in      com_api_type_pkg.t_card_number      default null
  , i_card_mask             in      com_api_type_pkg.t_card_number      default null
  , i_card_hash             in      com_api_type_pkg.t_medium_id        default null
  , i_card_seq_number       in      com_api_type_pkg.t_tiny_id          default null
  , i_card_expir_date       in      date                                default null
  , i_card_service_code     in      com_api_type_pkg.t_country_code     default null
  , i_card_country          in      com_api_type_pkg.t_country_code     default null
  , i_customer_id           in      com_api_type_pkg.t_medium_id        default null
  , i_account_id            in      com_api_type_pkg.t_account_id       default null
  , i_account_type          in      com_api_type_pkg.t_dict_value       default null
  , i_account_number        in      com_api_type_pkg.t_account_number   default null
  , i_account_amount        in      com_api_type_pkg.t_money            default null
  , i_account_currency      in      com_api_type_pkg.t_curr_code        default null
  , i_auth_code             in      com_api_type_pkg.t_auth_code        default null
  , i_merchant_number       in      com_api_type_pkg.t_merchant_number  default null
  , i_merchant_id           in      com_api_type_pkg.t_short_id         default null
  , i_terminal_number       in      com_api_type_pkg.t_terminal_number  default null
  , i_terminal_id           in      com_api_type_pkg.t_short_id         default null
  , i_split_hash            in      com_api_type_pkg.t_tiny_id          default null
  , i_without_checks        in      com_api_type_pkg.t_boolean          default null
  , i_payment_host_id       in      com_api_type_pkg.t_tiny_id          default null
  , i_payment_order_id      in      com_api_type_pkg.t_long_id          default null
  , i_acq_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_acq_network_id        in      com_api_type_pkg.t_network_id       default null
  , i_oper_currency         in      com_api_type_pkg.t_curr_code        default null
  , i_terminal_type         in      com_api_type_pkg.t_dict_value       default null
  , i_external_auth_id      in      com_api_type_pkg.t_attr_name        default null
  , i_external_orig_id      in      com_api_type_pkg.t_attr_name        default null
  , i_trace_number          in      com_api_type_pkg.t_attr_name        default null
  , i_mask_error            in      com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_is_reversal           in      com_api_type_pkg.t_boolean          default null
  , i_acq_inst_bin          in      com_api_type_pkg.t_rrn              default null
  , i_iss_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_iss_network_id        in      com_api_type_pkg.t_network_id       default null
  , i_oper_date             in      date                                default null
  , i_originator_refnum     in      com_api_type_pkg.t_rrn              default null
) is
    l_oper_id               com_api_type_pkg.t_long_id :=             i_oper_id;
    l_msg_type              com_api_type_pkg.t_dict_value :=          i_msg_type;
    l_oper_type             com_api_type_pkg.t_dict_value :=          i_oper_type;
    l_participant_type      com_api_type_pkg.t_dict_value :=          i_participant_type;
    l_host_date             date :=                                   i_host_date;
    l_client_id_type        com_api_type_pkg.t_dict_value :=          i_client_id_type;
    l_client_id_value       com_api_type_pkg.t_name :=                i_client_id_value;
    l_inst_id               com_api_type_pkg.t_inst_id :=             i_inst_id;
    l_network_id            com_api_type_pkg.t_network_id :=          i_network_id;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_card_inst_id          com_api_type_pkg.t_inst_id :=             i_card_inst_id;
    l_card_network_id       com_api_type_pkg.t_network_id :=          i_card_network_id;
    l_card_id               com_api_type_pkg.t_medium_id :=           i_card_id;
    l_card_instance_id      com_api_type_pkg.t_medium_id :=           i_card_instance_id;
    l_card_type_id          com_api_type_pkg.t_tiny_id :=             i_card_type_id;
    l_card_number           com_api_type_pkg.t_card_number :=         i_card_number;
    l_card_mask             com_api_type_pkg.t_card_number :=         i_card_mask;
    l_card_hash             com_api_type_pkg.t_medium_id :=           i_card_hash;
    l_card_seq_number       com_api_type_pkg.t_tiny_id :=             i_card_seq_number;
    l_card_expir_date       date :=                                   i_card_expir_date;
    l_card_service_code     com_api_type_pkg.t_country_code :=        i_card_service_code;
    l_card_country          com_api_type_pkg.t_country_code :=        i_card_country;
    l_customer_id           com_api_type_pkg.t_medium_id :=           i_customer_id;
    l_account_id            com_api_type_pkg.t_account_id :=          i_account_id;
    l_account_type          com_api_type_pkg.t_dict_value :=          i_account_type;
    l_account_number        com_api_type_pkg.t_account_number :=      i_account_number;
    l_account_amount        com_api_type_pkg.t_money :=               i_account_amount;
    l_account_currency      com_api_type_pkg.t_curr_code :=           i_account_currency;
    l_auth_code             com_api_type_pkg.t_auth_code :=           i_auth_code;
    l_merchant_number       com_api_type_pkg.t_merchant_number :=     i_merchant_number;
    l_merchant_id           com_api_type_pkg.t_short_id :=            i_merchant_id;
    l_terminal_number       com_api_type_pkg.t_terminal_number :=     i_terminal_number;
    l_terminal_id           com_api_type_pkg.t_short_id :=            i_terminal_id;
    l_split_hash            com_api_type_pkg.t_tiny_id :=             i_split_hash;
    l_without_checks        com_api_type_pkg.t_boolean :=             i_without_checks;
    l_payment_host_id       com_api_type_pkg.t_tiny_id :=             i_payment_host_id;
    l_is_reversal           com_api_type_pkg.t_boolean :=             i_is_reversal;
begin
    add_participant(
        i_oper_id            => l_oper_id
      , i_msg_type           => l_msg_type
      , i_oper_type          => l_oper_type
      , i_participant_type   => l_participant_type
      , i_host_date          => l_host_date
      , i_client_id_type     => l_client_id_type
      , i_client_id_value    => l_client_id_value
      , io_inst_id           => l_inst_id
      , io_network_id        => l_network_id
      , o_host_id            => l_host_id
      , io_card_inst_id      => l_card_inst_id
      , io_card_network_id   => l_card_network_id
      , io_card_id           => l_card_id
      , o_card_instance_id   => l_card_instance_id
      , io_card_type_id      => l_card_type_id
      , i_card_number        => l_card_number
      , io_card_mask         => l_card_mask
      , io_card_hash         => l_card_hash
      , io_card_seq_number   => l_card_seq_number
      , io_card_expir_date   => l_card_expir_date
      , io_card_service_code => l_card_service_code
      , io_card_country      => l_card_country
      , io_customer_id       => l_customer_id
      , io_account_id        => l_account_id
      , i_account_type       => l_account_type
      , i_account_number     => l_account_number
      , i_account_amount     => l_account_amount
      , i_account_currency   => l_account_currency
      , i_auth_code          => l_auth_code
      , i_merchant_number    => l_merchant_number
      , io_merchant_id       => l_merchant_id
      , i_terminal_number    => l_terminal_number
      , io_terminal_id       => l_terminal_id
      , o_split_hash         => l_split_hash
      , i_without_checks     => l_without_checks
      , io_payment_host_id   => l_payment_host_id
      , i_payment_order_id   => i_payment_order_id
      , i_acq_inst_id        => i_acq_inst_id
      , i_acq_network_id     => i_acq_network_id
      , i_oper_currency      => i_oper_currency
      , i_terminal_type      => i_terminal_type
      , i_external_auth_id   => i_external_auth_id
      , i_external_orig_id   => i_external_orig_id
      , i_trace_number       => i_trace_number
      , i_mask_error         => i_mask_error
      , i_is_reversal        => l_is_reversal
      , i_acq_inst_bin       => i_acq_inst_bin
      , i_iss_inst_id        => i_iss_inst_id
      , i_iss_network_id     => i_iss_network_id
      , i_oper_date          => i_oper_date
      , i_originator_refnum  => i_originator_refnum
    );
end;

procedure add_participant(
    i_oper_id               in      com_api_type_pkg.t_long_id
  , i_msg_type              in      com_api_type_pkg.t_dict_value
  , i_oper_type             in      com_api_type_pkg.t_dict_value
  , i_oper_reason           in      com_api_type_pkg.t_dict_value       default null
  , i_participant_type      in      com_api_type_pkg.t_dict_value
  , i_host_date             in      date                                default null
  , i_client_id_type        in      com_api_type_pkg.t_dict_value       default null
  , i_client_id_value       in      com_api_type_pkg.t_name             default null
  , io_inst_id              in out  com_api_type_pkg.t_inst_id
  , io_network_id           in out  com_api_type_pkg.t_network_id
  , o_host_id                  out  com_api_type_pkg.t_tiny_id
  , io_card_inst_id         in out  com_api_type_pkg.t_inst_id
  , io_card_network_id      in out  com_api_type_pkg.t_network_id
  , io_card_id              in out  com_api_type_pkg.t_medium_id
  , o_card_instance_id         out  com_api_type_pkg.t_medium_id
  , io_card_type_id         in out  com_api_type_pkg.t_tiny_id
  , i_card_number           in      com_api_type_pkg.t_card_number      default null
  , io_card_mask            in out  com_api_type_pkg.t_card_number
  , io_card_hash            in out  com_api_type_pkg.t_medium_id
  , io_card_seq_number      in out  com_api_type_pkg.t_tiny_id
  , io_card_expir_date      in out  date
  , io_card_service_code    in out  com_api_type_pkg.t_country_code
  , io_card_country         in out  com_api_type_pkg.t_country_code
  , io_customer_id          in out  com_api_type_pkg.t_medium_id
  , io_account_id           in out  com_api_type_pkg.t_account_id
  , i_account_type          in      com_api_type_pkg.t_dict_value       default null
  , i_account_number        in      com_api_type_pkg.t_account_number   default null
  , i_account_amount        in      com_api_type_pkg.t_money            default null
  , i_account_currency      in      com_api_type_pkg.t_curr_code        default null
  , i_auth_code             in      com_api_type_pkg.t_auth_code        default null
  , i_merchant_number       in      com_api_type_pkg.t_merchant_number  default null
  , io_merchant_id          in out  com_api_type_pkg.t_short_id
  , i_terminal_number       in      com_api_type_pkg.t_terminal_number  default null
  , io_terminal_id          in out  com_api_type_pkg.t_short_id
  , o_split_hash               out  com_api_type_pkg.t_tiny_id
  , i_without_checks        in      com_api_type_pkg.t_boolean          default null
  , io_payment_host_id      in out  com_api_type_pkg.t_tiny_id
  , i_payment_order_id      in      com_api_type_pkg.t_long_id          default null
  , i_acq_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_acq_network_id        in      com_api_type_pkg.t_network_id       default null
  , i_oper_currency         in      com_api_type_pkg.t_curr_code        default null
  , i_terminal_type         in      com_api_type_pkg.t_dict_value       default null
  , i_external_auth_id      in      com_api_type_pkg.t_attr_name        default null
  , i_external_orig_id      in      com_api_type_pkg.t_attr_name        default null
  , i_trace_number          in      com_api_type_pkg.t_attr_name        default null
  , i_mask_error            in      com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_is_reversal           in      com_api_type_pkg.t_boolean          default null
  , i_acq_inst_bin          in      com_api_type_pkg.t_rrn              default null
  , i_iss_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_iss_network_id        in      com_api_type_pkg.t_network_id       default null
  , i_sttl_type             in      com_api_type_pkg.t_dict_value       default null
  , i_fast_oper_stage       in      com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_oper_date             in      date                                default null
  , i_originator_refnum     in      com_api_type_pkg.t_rrn              default null
) is
    l_client_id_type          com_api_type_pkg.t_dict_value := i_client_id_type;
    l_client_id_value         com_api_type_pkg.t_name       := i_client_id_value;
    l_account_number          com_api_type_pkg.t_account_number := i_account_number;
    l_card_number             com_api_type_pkg.t_card_number := i_card_number;
    l_participant_added       com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_card_id                 com_api_type_pkg.t_medium_id;

    procedure insert_data is
        l_count         pls_integer := 0;
        l_proc_stage_list         com_api_type_pkg.t_dict_tab;
        l_exec_order_list         com_api_type_pkg.t_tiny_tab;
        l_status_list             com_api_type_pkg.t_dict_tab;
        l_external_auth_id_list   com_api_type_pkg.t_name_tab;
        l_is_reversal_list        com_api_type_pkg.t_boolean_tab;
    begin

        if o_split_hash is null then
            case
                when io_customer_id is not null then
                    o_split_hash :=
                        com_api_hash_pkg.get_split_hash(
                            i_entity_type       => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                          , i_object_id         => io_customer_id
                        );
                when io_account_id is not null then
                    o_split_hash :=
                        com_api_hash_pkg.get_split_hash(
                            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id         => io_account_id
                        );
                when io_card_id is not null then
                    o_split_hash :=
                        com_api_hash_pkg.get_split_hash(
                            i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
                          , i_object_id         => io_card_id
                        );
                when io_terminal_id is not null then
                    o_split_hash :=
                        com_api_hash_pkg.get_split_hash(
                            i_entity_type       => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                          , i_object_id         => io_terminal_id
                        );
                when io_merchant_id is not null then
                    o_split_hash :=
                        com_api_hash_pkg.get_split_hash(
                            i_entity_type       => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                          , i_object_id         => io_merchant_id
                        );
                when l_card_number is not null then
                    o_split_hash :=
                        com_api_hash_pkg.get_split_hash(
                            i_value             => l_card_number
                        );
                when i_terminal_number is not null then
                    o_split_hash :=
                        com_api_hash_pkg.get_split_hash(
                            i_value             => i_terminal_number
                        );
                when i_client_id_value is not null then
                    o_split_hash :=
                        com_api_hash_pkg.get_split_hash(
                            i_value             => i_client_id_value
                        );
                else
                    o_split_hash :=
                        com_api_hash_pkg.get_split_hash(
                            i_value             => i_oper_id
                        );
                    trc_log_pkg.warn(
                        i_text          => 'UNDEFINED_PARTICIPANT_SPLIT_HASH'
                      , i_env_param1    => i_participant_type
                      , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id     => i_oper_id
                    );
            end case;
        end if;

        trc_log_pkg.debug('o_split_hash=' || o_split_hash);

        if i_card_number is not null then
            if io_card_hash is null then
                io_card_hash := com_api_hash_pkg.get_card_hash(i_card_number);
            end if;
        else
            io_card_hash := null;
        end if;
        
        if o_card_instance_id is null and io_card_id is not null then
            o_card_instance_id := iss_api_card_instance_pkg.get_card_instance_id(i_card_id => io_card_id );
        end if;
        
        insert into opr_participant (
            oper_id
          , participant_type
          , client_id_type
          , client_id_value
          , inst_id
          , network_id
          , card_inst_id
          , card_network_id
          , card_id
          , card_instance_id
          , card_type_id
          , card_mask
          , card_hash
          , card_seq_number
          , card_expir_date
          , card_service_code
          , card_country
          , customer_id
          , account_id
          , account_type
          , account_number
          , account_amount
          , account_currency
          , auth_code
          , merchant_id
          , terminal_id
          , split_hash
        ) values (
            i_oper_id
          , i_participant_type
          , l_client_id_type
          , case when l_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD then null else l_client_id_value end
          , io_inst_id
          , io_network_id
          , io_card_inst_id
          , io_card_network_id
          , io_card_id
          , o_card_instance_id
          , io_card_type_id
          , null
          , io_card_hash
          , io_card_seq_number
          , io_card_expir_date
          , io_card_service_code
          , io_card_country
          , io_customer_id
          , io_account_id
          , i_account_type
          , l_account_number
          , i_account_amount
          , i_account_currency
          , i_auth_code
          , io_merchant_id
          , io_terminal_id
          , o_split_hash
        );

        l_participant_added := com_api_type_pkg.TRUE;

        --check if operation already exists in opr_oper_stage
        select count(1)
          into l_count
          from opr_oper_stage
         where oper_id = i_oper_id;

        if l_count = 0 then

            if i_fast_oper_stage = com_api_const_pkg.TRUE then
                insert into opr_oper_stage (
                    oper_id
                  , proc_stage
                  , exec_order
                  , status
                  , split_hash
                ) select i_oper_id
                       , s.proc_stage
                       , s.exec_order
                       , s.status
                       , o_split_hash
                    from opr_proc_stage s
                   where s.parent_stage  = s.proc_stage
                     and s.proc_stage   != opr_api_const_pkg.PROCESSING_STAGE_COMMON
                     and s.split_method  = i_participant_type
                     and (s.msg_type     = i_msg_type   or s.msg_type  = '%')
                     and (s.sttl_type    = i_sttl_type  or s.sttl_type = '%')
                     and (s.oper_type    = i_oper_type  or s.oper_type = '%')
                     and s.command is null;
            else
                insert into opr_oper_stage (
                    oper_id
                  , proc_stage
                  , exec_order
                  , status
                  , split_hash
                ) select i_oper_id
                       , s.proc_stage
                       , s.exec_order
                       , s.status
                       , o_split_hash
                    from opr_proc_stage s
                       , opr_operation  o
                   where s.parent_stage  = s.proc_stage
                     and s.proc_stage   != opr_api_const_pkg.PROCESSING_STAGE_COMMON
                     and s.split_method  = i_participant_type
                     and o.id            = i_oper_id
                     and (s.msg_type     = o.msg_type   or s.msg_type  = '%')
                     and (s.sttl_type    = o.sttl_type  or s.sttl_type = '%')
                     and (s.oper_type    = o.oper_type  or s.oper_type = '%')
                     and s.command is null;
            end if;
        else
            --need to update split_hash
            delete
              from opr_oper_stage
             where oper_id = i_oper_id
               and split_hash != o_split_hash
         returning proc_stage
                 , exec_order
                 , status
                 , external_auth_id
                 , is_reversal
              bulk collect into
                   l_proc_stage_list
                 , l_exec_order_list
                 , l_status_list
                 , l_external_auth_id_list
                 , l_is_reversal_list;

             forall i in 1 .. l_proc_stage_list.count
                 insert into opr_oper_stage (
                     oper_id
                   , proc_stage
                   , exec_order
                   , status
                   , external_auth_id
                   , is_reversal
                   , split_hash
                 ) values (
                     i_oper_id
                   , l_proc_stage_list(i)
                   , l_exec_order_list(i)
                   , l_status_list(i)
                   , l_external_auth_id_list(i)
                   , l_is_reversal_list(i)
                   , o_split_hash
                 );

            trc_log_pkg.debug('inserted ' || sql%rowcount || ' rows');
        end if;

        if l_card_number is not null then
            insert into opr_card (
                oper_id
              , participant_type
              , card_number
              , split_hash
            ) values (
                i_oper_id
              , i_participant_type
              , iss_api_token_pkg.encode_card_number(i_card_number => l_card_number)
              , o_split_hash
            );
        end if;
    end;

begin
    trc_log_pkg.debug (
        i_text              => 'Add participant type [#1][#2][#3]'
      , i_env_param1        => i_participant_type
      , i_env_param2        => io_inst_id
      , i_env_param3        => io_network_id
    );
    trc_log_pkg.debug (
        i_text              => 'io_card_id [#1]'
      , i_env_param1        => io_card_id
    );

    if com_api_type_pkg.TRUE =
        participant_needed(
            i_participant_type  => i_participant_type
          , i_oper_type         => i_oper_type
          , i_oper_reason       => i_oper_reason
        )
    then
    begin
        trc_log_pkg.debug (
            i_text              => 'participant needed'
        );

        if l_client_id_type is null then
            if l_card_number is not null then
                l_client_id_type := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
            elsif l_account_number is not null then
                l_client_id_type := opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT;
            elsif io_card_id is not null then
                l_client_id_type := opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID;
            end if;
        end if;

        if l_client_id_value is null then
            if l_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT and l_account_number is not null then
                l_client_id_value := l_account_number;
            elsif l_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD and l_card_number is not null then
                l_client_id_value := l_card_number;
            elsif l_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID then
                if l_card_number is not null then
                    l_client_id_value := iss_api_card_pkg.get_card_id(i_card_number => l_card_number);
                elsif io_card_id is not null then
                    l_client_id_value := io_card_id;
                end if;
            end if;
        end if;

        if l_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT and l_account_number is null then
            l_account_number := l_client_id_value;
        elsif l_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD and l_card_number is null then
            l_card_number := l_client_id_value;
        elsif l_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID and l_card_number is null then
            l_card_number := iss_api_card_pkg.get_card_number (i_card_uid => l_client_id_value);
        end if;

        if nvl(i_without_checks, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
            trc_log_pkg.debug (
                i_text              => 'define network'
            );

            define_network(
                i_msg_type              => i_msg_type
              , i_oper_type             => i_oper_type
              , i_party_type            => i_participant_type
              , i_host_date             => i_host_date
              , io_network_id           => io_network_id
              , io_inst_id              => io_inst_id
              , o_host_id               => o_host_id
              , i_client_id_type        => l_client_id_type
              , i_client_id_value       => l_client_id_value
              , i_card_number           => l_card_number
              , o_card_inst_id          => io_card_inst_id
              , o_card_network_id       => io_card_network_id
              , o_card_id               => io_card_id
              , o_card_instance_id      => o_card_instance_id
              , o_card_type_id          => io_card_type_id
              , o_card_mask             => io_card_mask
              , o_card_hash             => io_card_hash
              , io_card_seq_number      => io_card_seq_number
              , io_card_expir_date      => io_card_expir_date
              , io_card_service_code    => io_card_service_code
              , o_card_country          => io_card_country
              , i_account_number        => l_account_number
              , o_account_id            => io_account_id
              , io_customer_id          => io_customer_id
              , i_merchant_number       => i_merchant_number
              , io_merchant_id          => io_merchant_id
              , i_terminal_number       => i_terminal_number
              , io_terminal_id          => io_terminal_id
              , io_split_hash           => o_split_hash
              , i_payment_host_id       => io_payment_host_id
              , i_payment_order_id      => i_payment_order_id
              , i_oper_id               => i_oper_id
              , i_oper_reason           => i_oper_reason
              , i_acq_inst_id           => i_acq_inst_id
              , i_acq_network_id        => i_acq_network_id
              , i_oper_currency         => i_oper_currency
              , i_terminal_type         => i_terminal_type
              , i_mask_error            => i_mask_error
            );
            trc_log_pkg.debug (
                i_text              => 'io_card_id after define network [#1]'
              , i_env_param1        => io_card_id
            );

            trc_log_pkg.debug (
                i_text              => 'perform checks'
            );

            perform_checks(
                i_oper_id               => i_oper_id
              , i_msg_type              => i_msg_type
              , i_oper_type             => i_oper_type
              , i_oper_reason           => i_oper_reason
              , i_party_type            => i_participant_type
              , i_host_date             => i_host_date
              , io_network_id           => io_network_id
              , io_inst_id              => io_inst_id
              , io_client_id_type       => l_client_id_type
              , io_client_id_value      => l_client_id_value
              , io_card_number          => l_card_number
              , io_card_inst_id         => io_card_inst_id
              , io_card_network_id      => io_card_network_id
              , o_card_id               => l_card_id
              , o_card_instance_id      => o_card_instance_id
              , io_card_type_id         => io_card_type_id
              , io_card_mask            => io_card_mask
              , io_card_hash            => io_card_hash
              , io_card_seq_number      => io_card_seq_number
              , io_card_expir_date      => io_card_expir_date
              , io_card_service_code    => io_card_service_code
              , io_card_country         => io_card_country
              , i_account_number        => l_account_number
              , io_account_id           => io_account_id
              , io_customer_id          => io_customer_id
              , i_merchant_number       => i_merchant_number
              , io_merchant_id          => io_merchant_id
              , i_terminal_number       => i_terminal_number
              , io_terminal_id          => io_terminal_id
              , o_split_hash            => o_split_hash
              , i_external_auth_id      => i_external_auth_id
              , i_external_orig_id      => i_external_orig_id
              , i_trace_number          => i_trace_number
              , i_mask_error            => i_mask_error
              , i_is_reversal           => i_is_reversal
              , i_acq_inst_id           => i_acq_inst_id
              , i_acq_network_id        => i_acq_network_id
              , i_oper_currency         => i_oper_currency
              , i_acq_inst_bin          => i_acq_inst_bin
              , i_iss_inst_id           => i_iss_inst_id
              , i_iss_network_id        => i_iss_network_id
              , i_oper_date             => i_oper_date
              , i_originator_refnum     => i_originator_refnum
            );
        end if;

        trc_log_pkg.debug (
            i_text              => 'insert data'
        );

        insert_data;

        trc_log_pkg.debug (
            i_text              => 'Participant registered ok'
        );
    exception
        when com_api_error_pkg.e_application_error then
            if l_participant_added = com_api_type_pkg.FALSE then
                insert_data;
                raise;
            end if;
    end;
    end if;
end add_participant;

procedure insert_operation (
    i_oper_id                   in      com_api_type_pkg.t_long_id
  , i_session_id                in      com_api_type_pkg.t_long_id
  , i_is_reversal               in      com_api_type_pkg.t_boolean
  , i_original_id               in      com_api_type_pkg.t_long_id
  , i_oper_type                 in      com_api_type_pkg.t_dict_value
  , i_oper_reason               in      com_api_type_pkg.t_dict_value
  , i_msg_type                  in      com_api_type_pkg.t_dict_value
  , i_status                    in      com_api_type_pkg.t_dict_value
  , i_status_reason             in      com_api_type_pkg.t_dict_value
  , i_sttl_type                 in      com_api_type_pkg.t_dict_value
  , i_terminal_type             in      com_api_type_pkg.t_dict_value
  , i_acq_inst_bin              in      com_api_type_pkg.t_rrn
  , i_forw_inst_bin             in      com_api_type_pkg.t_rrn
  , i_merchant_number           in      com_api_type_pkg.t_merchant_number
  , i_terminal_number           in      com_api_type_pkg.t_terminal_number
  , i_merchant_name             in      com_api_type_pkg.t_name
  , i_merchant_street           in      com_api_type_pkg.t_name
  , i_merchant_city             in      com_api_type_pkg.t_name
  , i_merchant_region           in      com_api_type_pkg.t_name
  , i_merchant_country          in      com_api_type_pkg.t_curr_code
  , i_merchant_postcode         in      com_api_type_pkg.t_name
  , i_mcc                       in      com_api_type_pkg.t_mcc
  , i_originator_refnum         in      com_api_type_pkg.t_rrn
  , i_network_refnum            in      com_api_type_pkg.t_rrn
  , i_oper_count                in      com_api_type_pkg.t_long_id
  , i_oper_request_amount       in      com_api_type_pkg.t_money
  , i_oper_amount_algorithm     in      com_api_type_pkg.t_dict_value
  , i_oper_amount               in      com_api_type_pkg.t_money
  , i_oper_currency             in      com_api_type_pkg.t_curr_code
  , i_oper_cashback_amount      in      com_api_type_pkg.t_money
  , i_oper_replacement_amount   in      com_api_type_pkg.t_money
  , i_oper_surcharge_amount     in      com_api_type_pkg.t_money
  , i_oper_date                 in      date
  , i_host_date                 in      date
  , i_match_status              in      com_api_type_pkg.t_dict_value
  , i_sttl_amount               in      com_api_type_pkg.t_money
  , i_sttl_currency             in      com_api_type_pkg.t_curr_code
  , i_dispute_id                in      com_api_type_pkg.t_long_id
  , i_payment_order_id          in      com_api_type_pkg.t_long_id
  , i_payment_host_id           in      com_api_type_pkg.t_tiny_id
  , i_forced_processing         in      com_api_type_pkg.t_boolean
  , i_proc_mode                 in      com_api_type_pkg.t_dict_value
  , i_incom_sess_file_id        in      com_api_type_pkg.t_long_id
  , i_sttl_date                 in      date
  , i_acq_sttl_date             in      date
) is
    l_appl_id                           com_api_type_pkg.t_long_id;
    l_seqnum                            com_api_type_pkg.t_tiny_id;
    l_merchant_country                  com_api_type_pkg.t_country_code;
begin
    trc_log_pkg.debug (
        i_text          => 'Registering operation with ID [#1], payment_order_id [#2]'
        , i_env_param1  => i_oper_id
        , i_env_param2  => i_payment_order_id
        , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        , i_object_id   => i_oper_id
    );

    l_merchant_country := com_api_country_pkg.get_internal_country_code(
                              i_external_country_code => i_merchant_country
                          );

    insert into opr_operation (
        id
      , session_id
      , is_reversal
      , original_id
      , oper_type
      , oper_reason
      , msg_type
      , status
      , status_reason
      , sttl_type
      , terminal_type
      , acq_inst_bin
      , forw_inst_bin
      , merchant_number
      , terminal_number
      , merchant_name
      , merchant_street
      , merchant_city
      , merchant_region
      , merchant_country
      , merchant_postcode
      , mcc
      , originator_refnum
      , network_refnum
      , oper_count
      , oper_request_amount
      , oper_amount_algorithm
      , oper_amount
      , oper_currency
      , oper_cashback_amount
      , oper_replacement_amount
      , oper_surcharge_amount
      , oper_date
      , host_date
      , match_status
      , sttl_amount
      , sttl_currency
      , dispute_id
      , payment_order_id
      , payment_host_id
      , forced_processing
      , proc_mode
      , incom_sess_file_id
      , sttl_date
      , acq_sttl_date
    ) values (
        i_oper_id
      , nvl(i_session_id, get_session_id)
      , i_is_reversal
      , i_original_id
      , i_oper_type
      , i_oper_reason
      , i_msg_type
      , i_status
      , i_status_reason
      , i_sttl_type
      , i_terminal_type
      , i_acq_inst_bin
      , i_forw_inst_bin
      , i_merchant_number
      , i_terminal_number
      , i_merchant_name
      , i_merchant_street
      , i_merchant_city
      , i_merchant_region
      , l_merchant_country
      , i_merchant_postcode
      , i_mcc
      , i_originator_refnum
      , i_network_refnum
      , i_oper_count
      , i_oper_request_amount
      , i_oper_amount_algorithm
      , i_oper_amount
      , i_oper_currency
      , i_oper_cashback_amount
      , i_oper_replacement_amount
      , i_oper_surcharge_amount
      , nvl(i_oper_date, com_api_sttl_day_pkg.get_sysdate)
      , nvl(i_host_date, com_api_sttl_day_pkg.get_sysdate)
      , i_match_status
      , i_sttl_amount
      , i_sttl_currency
      , i_dispute_id
      , i_payment_order_id
      , i_payment_host_id
      , i_forced_processing
      , nvl(i_proc_mode, aut_api_const_pkg.DEFAULT_AUTH_PROC_MODE)
      , i_incom_sess_file_id
      , i_sttl_date
      , i_acq_sttl_date
    );

    if i_msg_type = opr_api_const_pkg.MESSAGE_TYPE_REPRESENTMENT then
        csm_api_case_pkg.get_case_by_operation(
            i_oper_id => i_oper_id
          , o_case_id => l_appl_id
          , o_seqnum  => l_seqnum
        );

        if l_appl_id is not null then

            app_ui_application_pkg.modify_application(
                i_appl_id     => l_appl_id
              , io_seqnum     => l_seqnum
              , i_appl_status => app_api_const_pkg.APPL_STATUS_RESOLVED
            );

            csm_ui_case_pkg.refuse_application_owner(
                i_appl_id     => l_appl_id
              , io_seqnum     => l_seqnum
            );

        end if;

    end if;

end insert_operation;

procedure insert_participant (
    i_oper_id                   in com_api_type_pkg.t_long_id
    , i_participant_type        in com_api_type_pkg.t_dict_value
    , i_client_id_type          in com_api_type_pkg.t_dict_value
    , i_client_id_value         in com_api_type_pkg.t_name
    , i_inst_id                 in com_api_type_pkg.t_inst_id
    , i_network_id              in com_api_type_pkg.t_network_id
    , i_host_id                 in com_api_type_pkg.t_tiny_id
    , i_card_inst_id            in com_api_type_pkg.t_inst_id
    , i_card_network_id         in com_api_type_pkg.t_network_id
    , i_card_id                 in com_api_type_pkg.t_medium_id
    , i_card_instance_id        in com_api_type_pkg.t_medium_id
    , i_card_type_id            in com_api_type_pkg.t_tiny_id
    , i_card_number             in com_api_type_pkg.t_card_number
    , i_card_mask               in com_api_type_pkg.t_card_number
    , i_card_hash               in com_api_type_pkg.t_medium_id
    , i_card_seq_number         in com_api_type_pkg.t_tiny_id
    , i_card_expir_date         in date
    , i_card_service_code       in com_api_type_pkg.t_country_code
    , i_card_country            in com_api_type_pkg.t_country_code
    , i_customer_id             in com_api_type_pkg.t_medium_id
    , i_account_id              in com_api_type_pkg.t_account_id
    , i_account_type            in com_api_type_pkg.t_dict_value
    , i_account_number          in com_api_type_pkg.t_account_number
    , i_account_amount          in com_api_type_pkg.t_money
    , i_account_currency        in com_api_type_pkg.t_curr_code
    , i_auth_code               in com_api_type_pkg.t_auth_code
    , i_merchant_number         in com_api_type_pkg.t_merchant_number
    , i_merchant_id             in com_api_type_pkg.t_short_id
    , i_terminal_number         in com_api_type_pkg.t_terminal_number
    , i_terminal_id             in com_api_type_pkg.t_short_id
    , i_split_hash              in com_api_type_pkg.t_tiny_id
    , i_payment_host_id         in com_api_type_pkg.t_tiny_id
    , i_payment_order_id        in com_api_type_pkg.t_long_id
) is
    l_count     pls_integer := 0;
begin
    insert into opr_participant (
        oper_id
      , participant_type
      , client_id_type
      , client_id_value
      , inst_id
      , network_id
      , card_inst_id
      , card_network_id
      , card_id
      , card_instance_id
      , card_type_id
      , card_mask
      , card_hash
      , card_seq_number
      , card_expir_date
      , card_service_code
      , card_country
      , customer_id
      , account_id
      , account_type
      , account_number
      , account_amount
      , account_currency
      , auth_code
      , merchant_id
      , terminal_id
      , split_hash
    ) values (
        i_oper_id
      , i_participant_type
      , i_client_id_type
      , case when i_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD then null else i_client_id_value end
      , i_inst_id
      , i_network_id
      , i_card_inst_id
      , i_card_network_id
      , i_card_id
      , i_card_instance_id
      , i_card_type_id
      , null
      , i_card_hash
      , i_card_seq_number
      , i_card_expir_date
      , i_card_service_code
      , i_card_country
      , i_customer_id
      , i_account_id
      , i_account_type
      , i_account_number
      , i_account_amount
      , i_account_currency
      , i_auth_code
      , i_merchant_id
      , i_terminal_id
      , i_split_hash
    );

    --check if operation already exists in opr_oper_stage
    select count(1)
      into l_count
      from opr_oper_stage
     where oper_id = i_oper_id;

    if l_count = 0 then

        insert into opr_oper_stage (
            oper_id
          , proc_stage
          , exec_order
          , status
          , split_hash
        ) select i_oper_id
               , s.proc_stage
               , s.exec_order
               , s.status
               , i_split_hash
            from opr_proc_stage s
               , opr_operation  o
           where s.parent_stage = s.proc_stage
             and s.proc_stage  != opr_api_const_pkg.PROCESSING_STAGE_COMMON
             and s.split_method = i_participant_type
             and o.id           = i_oper_id
             and (s.msg_type  = o.msg_type    or s.msg_type  = '%')
             and (s.sttl_type = o.sttl_type   or s.sttl_type = '%')
             and (s.oper_type = o.oper_type   or s.oper_type = '%')
             and s.command is null;
    else
        --need to update split_hash
        update opr_oper_stage
           set split_hash = i_split_hash
         where oper_id    = i_oper_id;

        trc_log_pkg.debug('updated '||sql%rowcount||' rows');

    end if;

    if i_card_number is not null
       or
       i_client_id_value is not null
       and i_client_id_type in (opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                              , opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID)
    then
        insert into opr_card (
            oper_id
          , participant_type
          , card_number
          , split_hash
        ) values (
            i_oper_id
          , i_participant_type
          , case i_client_id_type
                when opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID then
                    -- Avoid useless calls of tokenizator, get encoded card number
                    iss_api_card_pkg.get_raw_card_number(
                        i_card_id    => i_client_id_value
                      , i_split_hash => i_split_hash
                    )
                else
                    iss_api_token_pkg.encode_card_number(
                         i_card_number => case i_client_id_type
                                              when opr_api_const_pkg.CLIENT_ID_TYPE_CARD then
                                                  i_client_id_value
                                              else
                                                  i_card_number
                                          end
                    )
            end
          , i_split_hash
        );
    end if;
end insert_participant;

procedure find_network (
  i_party_type              in      com_api_type_pkg.t_dict_value
  , i_client_id_type        in      com_api_type_pkg.t_dict_value
  , i_client_id_value       in      com_api_type_pkg.t_name
  , io_network_id           in out  com_api_type_pkg.t_tiny_id
  , io_inst_id              in out  com_api_type_pkg.t_inst_id
  , i_card_number           in      com_api_type_pkg.t_card_number
  , o_card_inst_id             out  com_api_type_pkg.t_inst_id
  , o_card_network_id          out  com_api_type_pkg.t_network_id
  , o_card_type_id             out  com_api_type_pkg.t_tiny_id
  , o_card_country             out  com_api_type_pkg.t_country_code
  , i_account_number        in      com_api_type_pkg.t_account_number
) is
    --l_pan_length        com_api_type_pkg.t_tiny_id;
begin
/*
    if i_party_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then
        trc_log_pkg.debug (
            i_text              => 'Incoming ACQ network is [#1]'
          , i_env_param1        => io_network_id
        );

        if is_number_empty(io_network_id) then
            io_network_id :=
                ost_api_institution_pkg.get_inst_network (
                    i_inst_id       => io_inst_id
                );

            trc_log_pkg.debug (
                i_text              => 'Acq network found by institution [#1] is [#2]'
              , i_env_param1        => io_inst_id
              , i_env_param2        => io_network_id
            );
        end if;

        if is_number_empty(io_network_id) then
            com_api_error_pkg.raise_error (
                i_error             => 'UNKNOWN_INSTITUTION_NETWORK'
              , i_env_param1        => io_inst_id
            );
        end if;

    else
        trc_log_pkg.debug (
            i_text              => 'Find out customer network. Client id type [#1], client id value [#2], card number [#3], account number [#4]'
          , i_env_param1        => i_client_id_type
          , i_env_param2        => i_client_id_value
          , i_env_param3        => i_card_number
          , i_env_param4        => i_account_number
        );

        if i_client_id_type in (
            aup_api_const_pkg.CLIENT_ID_TYPE_UNKNOWN
          , aup_api_const_pkg.CLIENT_ID_TYPE_NONE
        ) then
            io_network_id := net_api_const_pkg.UNIDENTIFIED_NETWORK;
            io_inst_id := ost_api_const_pkg.UNIDENTIFIED_INST;

        elsif i_client_id_type in (aup_api_const_pkg.CLIENT_ID_TYPE_CARD) then
            iss_api_bin_pkg.get_bin_info (
                i_card_number           => i_card_number
              , o_iss_inst_id           => io_inst_id
              , o_iss_network_id        => io_network_id
              , o_iss_host_id           => o_host_id
              , o_card_type_id          => o_card_type_id
              , o_card_country          => o_card_country
              , o_card_inst_id          => o_card_inst_id
              , o_card_network_id       => o_card_network_id
              , o_pan_length            => l_pan_length
              , i_raise_error           => com_api_const_pkg.FALSE
            );

            trc_log_pkg.debug (
                i_text              => 'Own bin search result [#1][#2][#3]'
              , i_env_param1        => i_card_number
              , i_env_param2        => io_network_id
              , i_env_param3        => io_inst_id
            );

            if io_network_id is null then
                net_api_bin_pkg.get_bin_info(
                    i_card_number           => i_card_number
                  , o_iss_inst_id           => io_inst_id
                  , o_iss_network_id        => io_network_id
                  , o_iss_host_id           => o_host_id
                  , o_card_type_id          => o_card_type_id
                  , o_card_country          => o_card_country
                  , o_card_inst_id          => o_card_inst_id
                  , o_card_network_id       => o_card_network_id
                  , o_pan_length            => l_pan_length
                );

                trc_log_pkg.debug (
                    i_text              => 'Network bin search result [#1][#2][#3]'
                  , i_env_param1        => i_card_number
                  , i_env_param2        => io_network_id
                  , i_env_param3        => io_inst_id
                );
            end if;

            if io_network_id is null then
                if i_party_type = com_api_const_pkg.PARTICIPANT_DEST then
                    com_api_error_pkg.raise_error (
                        i_error             => 'UNKNOWN_DESTINATION_NETWORK'
                      , i_env_param1        => i_card_number
                    );
                else
                    com_api_error_pkg.raise_error (
                        i_error             => 'UNKNOWN_ISSUING_NETWORK'
                      , i_env_param1        => i_card_number
                    );
                end if;
            end if;

        elsif (
            i_client_id_type in (
                aup_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT
                , aup_api_const_pkg.CLIENT_ID_TYPE_EMAIL
                , aup_api_const_pkg.CLIENT_ID_TYPE_MOBILE
                , aup_api_const_pkg.CLIENT_ID_TYPE_CUSTOMER
                , aup_api_const_pkg.CLIENT_ID_TYPE_CONTRACT
            ) or substr(i_client_id_type, 1, 4) = 'CNTP'
        ) then
            io_network_id := net_api_const_pkg.LOCAL_NETWORK;
            io_inst_id := ost_api_const_pkg.UNIDENTIFIED_INST;

        else
            com_api_error_pkg.raise_error (
                i_error             => 'UNKNOWN_ISSUING_NETWORK'
              , i_env_param1        => i_client_id_type
              , i_env_param2        => i_client_id_value
              , i_env_param3        => i_card_number
              , i_env_param4        => i_account_number
            );
        end if;
    end if;
*/
    trc_log_pkg.debug (
        i_text              => 'Defined institution [#1] and network [#2]'
      , i_env_param1        => io_inst_id
      , i_env_param2        => io_network_id
    );
end find_network;


procedure create_operation (
    io_oper_id                  in out  com_api_type_pkg.t_long_id
  , i_session_id                in      com_api_type_pkg.t_long_id          default null
  , i_is_reversal               in      com_api_type_pkg.t_boolean
  , i_original_id               in      com_api_type_pkg.t_long_id          default null
  , i_oper_type                 in      com_api_type_pkg.t_dict_value
  , i_oper_reason               in      com_api_type_pkg.t_dict_value       default null
  , i_msg_type                  in      com_api_type_pkg.t_dict_value
  , i_status                    in      com_api_type_pkg.t_dict_value
  , i_status_reason             in      com_api_type_pkg.t_dict_value       default null
  , i_sttl_type                 in      com_api_type_pkg.t_dict_value
  , i_terminal_type             in      com_api_type_pkg.t_dict_value       default null
  , i_acq_inst_bin              in      com_api_type_pkg.t_rrn              default null
  , i_forw_inst_bin             in      com_api_type_pkg.t_rrn              default null
  , i_merchant_number           in      com_api_type_pkg.t_merchant_number  default null
  , i_terminal_number           in      com_api_type_pkg.t_terminal_number  default null
  , i_merchant_name             in      com_api_type_pkg.t_name             default null
  , i_merchant_street           in      com_api_type_pkg.t_name             default null
  , i_merchant_city             in      com_api_type_pkg.t_name             default null
  , i_merchant_region           in      com_api_type_pkg.t_name             default null
  , i_merchant_country          in      com_api_type_pkg.t_curr_code        default null
  , i_merchant_postcode         in      com_api_type_pkg.t_name             default null
  , i_mcc                       in      com_api_type_pkg.t_mcc              default null
  , i_originator_refnum         in      com_api_type_pkg.t_rrn              default null
  , i_network_refnum            in      com_api_type_pkg.t_rrn              default null
  , i_oper_count                in      com_api_type_pkg.t_long_id          default null
  , i_oper_request_amount       in      com_api_type_pkg.t_money            default null
  , i_oper_amount_algorithm     in      com_api_type_pkg.t_dict_value       default null
  , i_oper_amount               in      com_api_type_pkg.t_money            default null
  , i_oper_currency             in      com_api_type_pkg.t_curr_code        default null
  , i_oper_cashback_amount      in      com_api_type_pkg.t_money            default null
  , i_oper_replacement_amount   in      com_api_type_pkg.t_money            default null
  , i_oper_surcharge_amount     in      com_api_type_pkg.t_money            default null
  , i_oper_date                 in      date                                default null
  , i_host_date                 in      date                                default null
  , i_match_status              in      com_api_type_pkg.t_dict_value       default null
  , i_sttl_amount               in      com_api_type_pkg.t_money            default null
  , i_sttl_currency             in      com_api_type_pkg.t_curr_code        default null
  , i_dispute_id                in      com_api_type_pkg.t_long_id          default null
  , i_payment_order_id          in      com_api_type_pkg.t_long_id          default null
  , i_payment_host_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_forced_processing         in      com_api_type_pkg.t_boolean          default null
  , i_proc_mode                 in      com_api_type_pkg.t_dict_value       default null
  , i_incom_sess_file_id        in      com_api_type_pkg.t_long_id          default null
  , io_participants             in out  nocopy opr_api_type_pkg.t_oper_part_by_type_tab
  , i_sttl_date                 in      date                                default null
  , i_acq_sttl_date             in      date                                default null
) is
    l_party_type                com_api_type_pkg.t_dict_value;
begin
    if io_oper_id is null then
        io_oper_id := get_id(
                          i_host_date => i_host_date
                      );
    end if;

    if io_participants.count > 0 then
        l_party_type := io_participants.first;

        loop
            io_participants(l_party_type).oper_id := io_oper_id;



            l_party_type := io_participants.next(l_party_type);
            exit when l_party_type is null;
        end loop;
    end if;

    insert_operation (
        i_oper_id                       => io_oper_id
        , i_session_id                  => i_session_id
        , i_is_reversal                 => i_is_reversal
        , i_original_id                 => i_original_id
        , i_oper_type                   => i_oper_type
        , i_oper_reason                 => i_oper_reason
        , i_msg_type                    => i_msg_type
        , i_status                      => i_status
        , i_status_reason               => i_status_reason
        , i_sttl_type                   => i_sttl_type
        , i_terminal_type               => i_terminal_type
        , i_acq_inst_bin                => i_acq_inst_bin
        , i_forw_inst_bin               => i_forw_inst_bin
        , i_merchant_number             => i_merchant_number
        , i_terminal_number             => i_terminal_number
        , i_merchant_name               => i_merchant_name
        , i_merchant_street             => i_merchant_street
        , i_merchant_city               => i_merchant_city
        , i_merchant_region             => i_merchant_region
        , i_merchant_country            => i_merchant_country
        , i_merchant_postcode           => i_merchant_postcode
        , i_mcc                         => i_mcc
        , i_originator_refnum           => i_originator_refnum
        , i_network_refnum              => i_network_refnum
        , i_oper_count                  => i_oper_count
        , i_oper_request_amount         => i_oper_request_amount
        , i_oper_amount_algorithm       => i_oper_amount_algorithm
        , i_oper_amount                 => i_oper_amount
        , i_oper_currency               => i_oper_currency
        , i_oper_cashback_amount        => i_oper_cashback_amount
        , i_oper_replacement_amount     => i_oper_replacement_amount
        , i_oper_surcharge_amount       => i_oper_surcharge_amount
        , i_oper_date                   => i_oper_date
        , i_host_date                   => i_host_date
        , i_match_status                => i_match_status
        , i_sttl_amount                 => i_sttl_amount
        , i_sttl_currency               => i_sttl_currency
        , i_dispute_id                  => i_dispute_id
        , i_payment_order_id            => i_payment_order_id
        , i_payment_host_id             => i_payment_host_id
        , i_forced_processing           => i_forced_processing
        , i_proc_mode                   => i_proc_mode
        , i_incom_sess_file_id          => i_incom_sess_file_id
        , i_sttl_date                   => i_sttl_date
        , i_acq_sttl_date               => i_acq_sttl_date
    );

    if io_participants.count > 0 then
        l_party_type := io_participants.first;

        loop
            insert_participant (
                i_oper_id                   => io_participants(l_party_type).oper_id
                , i_participant_type        => io_participants(l_party_type).participant_type
                , i_client_id_type          => io_participants(l_party_type).client_id_type
                , i_client_id_value         => io_participants(l_party_type).client_id_value
                , i_inst_id                 => io_participants(l_party_type).inst_id
                , i_network_id              => io_participants(l_party_type).network_id
                , i_host_id                 => null
                , i_card_inst_id            => io_participants(l_party_type).card_inst_id
                , i_card_network_id         => io_participants(l_party_type).card_network_id
                , i_card_id                 => io_participants(l_party_type).card_id
                , i_card_instance_id        => io_participants(l_party_type).card_instance_id
                , i_card_type_id            => io_participants(l_party_type).card_type_id
                , i_card_number             => io_participants(l_party_type).card_number
                , i_card_mask               => io_participants(l_party_type).card_mask
                , i_card_hash               => io_participants(l_party_type).card_hash
                , i_card_seq_number         => io_participants(l_party_type).card_seq_number
                , i_card_expir_date         => io_participants(l_party_type).card_expir_date
                , i_card_service_code       => io_participants(l_party_type).card_service_code
                , i_card_country            => io_participants(l_party_type).card_country
                , i_customer_id             => io_participants(l_party_type).customer_id
                , i_account_id              => io_participants(l_party_type).account_id
                , i_account_type            => io_participants(l_party_type).account_type
                , i_account_number          => io_participants(l_party_type).account_number
                , i_account_amount          => io_participants(l_party_type).account_amount
                , i_account_currency        => io_participants(l_party_type).account_currency
                , i_auth_code               => io_participants(l_party_type).auth_code
                , i_merchant_number         => i_merchant_number
                , i_merchant_id             => io_participants(l_party_type).merchant_id
                , i_terminal_number         => i_terminal_number
                , i_terminal_id             => io_participants(l_party_type).terminal_id
                , i_split_hash              => io_participants(l_party_type).split_hash
                , i_payment_host_id         => i_payment_host_id
                , i_payment_order_id        => i_payment_order_id
            );

            l_party_type := io_participants.next(l_party_type);
            exit when l_party_type is null;
        end loop;
    end if;

    evt_api_status_pkg.add_status_log(
        i_event_type    => null
      , i_initiator     => evt_api_const_pkg.INITIATOR_SYSTEM
      , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id     => io_oper_id
      , i_reason        => i_oper_reason
      , i_status        => i_status
      , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
    );

end create_operation;

procedure create_operation (
    i_oper                  in      opr_api_type_pkg.t_oper_rec
  , i_iss_part              in      opr_api_type_pkg.t_oper_part_rec
  , i_acq_part              in      opr_api_type_pkg.t_oper_part_rec
) is
    l_oper_id               com_api_type_pkg.t_long_id := i_oper.id;
begin
    create_operation(
        io_oper_id                => l_oper_id
      , i_session_id              => get_session_id
      , i_status                  => nvl(i_oper.status, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY)
      , i_status_reason           => null
      , i_sttl_type               => i_oper.sttl_type
      , i_msg_type                => i_oper.msg_type
      , i_oper_type               => i_oper.oper_type
      , i_oper_reason             => null
      , i_is_reversal             => i_oper.is_reversal
      , i_oper_amount             => i_oper.oper_amount
      , i_oper_currency           => i_oper.oper_currency
      , i_oper_cashback_amount    => i_oper.oper_cashback_amount
      , i_sttl_amount             => i_oper.sttl_amount
      , i_sttl_currency           => i_oper.sttl_currency
      , i_oper_date               => i_oper.oper_date
      , i_host_date               => i_oper.host_date
      , i_sttl_date               => i_oper.sttl_date
      , i_acq_sttl_date           => i_oper.acq_sttl_date
      , i_terminal_type           => i_oper.terminal_type
      , i_mcc                     => i_oper.mcc
      , i_originator_refnum       => i_oper.originator_refnum
      , i_network_refnum          => i_oper.network_refnum
      , i_acq_inst_bin            => i_oper.acq_inst_bin
      , i_forw_inst_bin           => i_oper.forw_inst_bin
      , i_merchant_number         => i_oper.merchant_number
      , i_terminal_number         => i_oper.terminal_number
      , i_merchant_name           => i_oper.merchant_name
      , i_merchant_street         => i_oper.merchant_street
      , i_merchant_city           => i_oper.merchant_city
      , i_merchant_region         => i_oper.merchant_region
      , i_merchant_country        => i_oper.merchant_country
      , i_merchant_postcode       => i_oper.merchant_postcode
      , i_dispute_id              => i_oper.dispute_id
      , i_match_status            => i_oper.match_status
      , i_original_id             => i_oper.original_id
      , i_proc_mode               => i_oper.proc_mode
      , i_clearing_sequence_num   => i_oper.clearing_sequence_num
      , i_clearing_sequence_count => i_oper.clearing_sequence_count
      , i_incom_sess_file_id      => i_oper.incom_sess_file_id
    );

    add_participant(
        i_oper_id                 => l_oper_id
      , i_msg_type                => i_oper.msg_type
      , i_oper_type               => i_oper.oper_type
      , i_participant_type        => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_host_date               => null
      , i_inst_id                 => i_iss_part.inst_id
      , i_network_id              => i_iss_part.network_id
      , i_customer_id             => i_iss_part.customer_id
      , i_client_id_type          => nvl(i_iss_part.client_id_type, opr_api_const_pkg.CLIENT_ID_TYPE_CARD)
      , i_client_id_value         => case nvl(i_iss_part.client_id_type, opr_api_const_pkg.CLIENT_ID_TYPE_CARD)
                                         when opr_api_const_pkg.CLIENT_ID_TYPE_CARD    then i_iss_part.card_number
                                         when opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID then to_char(i_iss_part.card_id)
                                                                                       else null
                                     end
      , i_card_id                 => i_iss_part.card_id
      , i_card_type_id            => i_iss_part.card_type_id
      , i_card_expir_date         => i_iss_part.card_expir_date
      , i_card_service_code       => i_iss_part.card_service_code
      , i_card_seq_number         => i_iss_part.card_seq_number
      , i_card_number             => i_iss_part.card_number
      , i_card_mask               => i_iss_part.card_mask
      , i_card_hash               => i_iss_part.card_hash
      , i_card_country            => i_iss_part.card_country
      , i_card_inst_id            => i_iss_part.card_inst_id
      , i_card_network_id         => i_iss_part.card_network_id
      , i_account_id              => null
      , i_account_number          => null
      , i_account_amount          => null
      , i_account_currency        => null
      , i_auth_code               => i_iss_part.auth_code
      , i_split_hash              => i_iss_part.split_hash
      , i_without_checks          => com_api_const_pkg.TRUE
    );

    add_participant (
        i_oper_id                 => l_oper_id
      , i_msg_type                => i_oper.msg_type
      , i_oper_type               => i_oper.oper_type
      , i_participant_type        => com_api_const_pkg.PARTICIPANT_ACQUIRER
      , i_host_date               => null
      , i_inst_id                 => i_acq_part.inst_id
      , i_network_id              => i_acq_part.network_id
      , i_merchant_id             => i_acq_part.merchant_id
      , i_terminal_id             => i_acq_part.terminal_id
      , i_terminal_number         => i_oper.terminal_number
      , i_split_hash              => i_acq_part.split_hash
      , i_without_checks          => com_api_const_pkg.TRUE
      , i_card_number             => i_acq_part.card_number
      , i_client_id_type          => i_acq_part.client_id_type
      , i_client_id_value         => case nvl(i_acq_part.client_id_type, opr_api_const_pkg.CLIENT_ID_TYPE_CARD)
                                         when opr_api_const_pkg.CLIENT_ID_TYPE_CARD    then i_acq_part.card_number
                                         when opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID then to_char(i_acq_part.card_id)
                                                                                       else null
                                     end
      , i_card_id                 => i_acq_part.card_id
      , i_card_type_id            => i_acq_part.card_type_id
      , i_card_expir_date         => i_acq_part.card_expir_date
      , i_card_service_code       => i_acq_part.card_service_code
      , i_card_seq_number         => i_acq_part.card_seq_number
      , i_card_mask               => i_acq_part.card_mask
      , i_card_hash               => i_acq_part.card_hash
      , i_card_country            => i_acq_part.card_country
      , i_card_inst_id            => i_acq_part.card_inst_id
      , i_card_network_id         => i_acq_part.card_network_id
    );
end;

procedure add_participant(
    i_oper_id               in      com_api_type_pkg.t_long_id
  , i_msg_type              in      com_api_type_pkg.t_dict_value
  , i_oper_type             in      com_api_type_pkg.t_dict_value
  , i_oper_reason           in      com_api_type_pkg.t_dict_value       default null
  , i_participant_type      in      com_api_type_pkg.t_dict_value
  , i_host_date             in      date                                default null
  , i_client_id_type        in      com_api_type_pkg.t_dict_value       default null
  , i_client_id_value       in      com_api_type_pkg.t_name             default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id          default null
  , i_network_id            in      com_api_type_pkg.t_network_id       default null
  , i_card_inst_id          in      com_api_type_pkg.t_inst_id          default null
  , i_card_network_id       in      com_api_type_pkg.t_network_id       default null
  , i_card_id               in      com_api_type_pkg.t_medium_id        default null
  , i_card_instance_id      in      com_api_type_pkg.t_medium_id        default null
  , i_card_type_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_card_number           in      com_api_type_pkg.t_card_number      default null
  , i_card_mask             in      com_api_type_pkg.t_card_number      default null
  , i_card_hash             in      com_api_type_pkg.t_medium_id        default null
  , i_card_seq_number       in      com_api_type_pkg.t_tiny_id          default null
  , i_card_expir_date       in      date                                default null
  , i_card_service_code     in      com_api_type_pkg.t_country_code     default null
  , i_card_country          in      com_api_type_pkg.t_country_code     default null
  , i_customer_id           in      com_api_type_pkg.t_medium_id        default null
  , i_account_id            in      com_api_type_pkg.t_account_id       default null
  , i_account_type          in      com_api_type_pkg.t_dict_value       default null
  , i_account_number        in      com_api_type_pkg.t_account_number   default null
  , i_account_amount        in      com_api_type_pkg.t_money            default null
  , i_account_currency      in      com_api_type_pkg.t_curr_code        default null
  , i_auth_code             in      com_api_type_pkg.t_auth_code        default null
  , i_merchant_number       in      com_api_type_pkg.t_merchant_number  default null
  , i_merchant_id           in      com_api_type_pkg.t_short_id         default null
  , i_terminal_number       in      com_api_type_pkg.t_terminal_number  default null
  , i_terminal_id           in      com_api_type_pkg.t_short_id         default null
  , o_split_hash            out     com_api_type_pkg.t_tiny_id
  , i_without_checks        in      com_api_type_pkg.t_boolean          default null
  , i_payment_host_id       in      com_api_type_pkg.t_tiny_id          default null
  , i_payment_order_id      in      com_api_type_pkg.t_long_id          default null
  , i_acq_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_acq_network_id        in      com_api_type_pkg.t_network_id       default null
  , i_oper_currency         in      com_api_type_pkg.t_curr_code        default null
  , i_terminal_type         in      com_api_type_pkg.t_dict_value       default null
  , i_external_auth_id      in      com_api_type_pkg.t_attr_name        default null
  , i_external_orig_id      in      com_api_type_pkg.t_attr_name        default null
  , i_trace_number          in      com_api_type_pkg.t_attr_name        default null
  , i_mask_error            in      com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_is_reversal           in      com_api_type_pkg.t_boolean          default null
  , i_acq_inst_bin          in      com_api_type_pkg.t_rrn              default null
  , i_iss_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_iss_network_id        in      com_api_type_pkg.t_network_id       default null
  , i_oper_date             in      date                                default null
  , i_originator_refnum     in      com_api_type_pkg.t_rrn              default null
) is
    l_oper_id               com_api_type_pkg.t_long_id :=             i_oper_id;
    l_msg_type              com_api_type_pkg.t_dict_value :=          i_msg_type;
    l_oper_type             com_api_type_pkg.t_dict_value :=          i_oper_type;
    l_participant_type      com_api_type_pkg.t_dict_value :=          i_participant_type;
    l_host_date             date :=                                   i_host_date;
    l_client_id_type        com_api_type_pkg.t_dict_value :=          i_client_id_type;
    l_client_id_value       com_api_type_pkg.t_name :=                i_client_id_value;
    l_inst_id               com_api_type_pkg.t_inst_id :=             i_inst_id;
    l_network_id            com_api_type_pkg.t_network_id :=          i_network_id;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_card_inst_id          com_api_type_pkg.t_inst_id :=             i_card_inst_id;
    l_card_network_id       com_api_type_pkg.t_network_id :=          i_card_network_id;
    l_card_id               com_api_type_pkg.t_medium_id :=           i_card_id;
    l_card_instance_id      com_api_type_pkg.t_medium_id :=           i_card_instance_id;
    l_card_type_id          com_api_type_pkg.t_tiny_id :=             i_card_type_id;
    l_card_number           com_api_type_pkg.t_card_number :=         i_card_number;
    l_card_mask             com_api_type_pkg.t_card_number :=         i_card_mask;
    l_card_hash             com_api_type_pkg.t_medium_id :=           i_card_hash;
    l_card_seq_number       com_api_type_pkg.t_tiny_id :=             i_card_seq_number;
    l_card_expir_date       date :=                                   i_card_expir_date;
    l_card_service_code     com_api_type_pkg.t_country_code :=        i_card_service_code;
    l_card_country          com_api_type_pkg.t_country_code :=        i_card_country;
    l_customer_id           com_api_type_pkg.t_medium_id :=           i_customer_id;
    l_account_id            com_api_type_pkg.t_account_id :=          i_account_id;
    l_account_type          com_api_type_pkg.t_dict_value :=          i_account_type;
    l_account_number        com_api_type_pkg.t_account_number :=      i_account_number;
    l_account_amount        com_api_type_pkg.t_money :=               i_account_amount;
    l_account_currency      com_api_type_pkg.t_curr_code :=           i_account_currency;
    l_auth_code             com_api_type_pkg.t_auth_code :=           i_auth_code;
    l_merchant_number       com_api_type_pkg.t_merchant_number :=     i_merchant_number;
    l_merchant_id           com_api_type_pkg.t_short_id :=            i_merchant_id;
    l_terminal_number       com_api_type_pkg.t_terminal_number :=     i_terminal_number;
    l_terminal_id           com_api_type_pkg.t_short_id :=            i_terminal_id;
    l_without_checks        com_api_type_pkg.t_boolean :=             i_without_checks;
    l_payment_host_id       com_api_type_pkg.t_tiny_id :=             i_payment_host_id;
    l_is_reversal           com_api_type_pkg.t_boolean :=             i_is_reversal;
begin
    add_participant(
        i_oper_id            => l_oper_id
      , i_msg_type           => l_msg_type
      , i_oper_type          => l_oper_type
      , i_participant_type   => l_participant_type
      , i_host_date          => l_host_date
      , i_client_id_type     => l_client_id_type
      , i_client_id_value    => l_client_id_value
      , io_inst_id           => l_inst_id
      , io_network_id        => l_network_id
      , o_host_id            => l_host_id
      , io_card_inst_id      => l_card_inst_id
      , io_card_network_id   => l_card_network_id
      , io_card_id           => l_card_id
      , o_card_instance_id   => l_card_instance_id
      , io_card_type_id      => l_card_type_id
      , i_card_number        => l_card_number
      , io_card_mask         => l_card_mask
      , io_card_hash         => l_card_hash
      , io_card_seq_number   => l_card_seq_number
      , io_card_expir_date   => l_card_expir_date
      , io_card_service_code => l_card_service_code
      , io_card_country      => l_card_country
      , io_customer_id       => l_customer_id
      , io_account_id        => l_account_id
      , i_account_type       => l_account_type
      , i_account_number     => l_account_number
      , i_account_amount     => l_account_amount
      , i_account_currency   => l_account_currency
      , i_auth_code          => l_auth_code
      , i_merchant_number    => l_merchant_number
      , io_merchant_id       => l_merchant_id
      , i_terminal_number    => l_terminal_number
      , io_terminal_id       => l_terminal_id
      , o_split_hash         => o_split_hash
      , i_without_checks     => l_without_checks
      , io_payment_host_id   => l_payment_host_id
      , i_payment_order_id   => i_payment_order_id
      , i_acq_inst_id        => i_acq_inst_id
      , i_acq_network_id     => i_acq_network_id
      , i_oper_currency      => i_oper_currency
      , i_terminal_type      => i_terminal_type
      , i_external_auth_id   => i_external_auth_id
      , i_external_orig_id   => i_external_orig_id
      , i_trace_number       => i_trace_number
      , i_mask_error         => i_mask_error
      , i_is_reversal        => l_is_reversal
      , i_acq_inst_bin       => i_acq_inst_bin
      , i_iss_inst_id        => i_iss_inst_id
      , i_iss_network_id     => i_iss_network_id
      , i_oper_date          => i_oper_date
      , i_originator_refnum  => i_originator_refnum
    );
end;

procedure set_oper_stage(
    i_oper_id               in      com_api_type_pkg.t_long_id      default null
  , i_external_auth_id      in      com_api_type_pkg.t_name         default null
  , i_is_reversal           in      com_api_type_pkg.t_boolean      default null
  , i_command               in      com_api_type_pkg.t_dict_value
) is
    l_oper_id       com_api_type_pkg.t_long_id;
    l_split_hash    com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.set_oper_stage START');

    l_oper_id := i_oper_id;

    if l_oper_id is null then

        l_oper_id    := opr_api_create_pkg.get_id();

        l_split_hash :=
            com_api_hash_pkg.get_split_hash(
                i_value  =>  l_oper_id
            );

        insert into opr_oper_stage (
            oper_id
          , proc_stage
          , exec_order
          , status
          , split_hash
          , external_auth_id
          , is_reversal
        ) select l_oper_id
               , s.proc_stage
               , s.exec_order
               , s.status
               , l_split_hash
               , i_external_auth_id
               , i_is_reversal
            from opr_proc_stage s
           where s.command = i_command;

        trc_log_pkg.debug('Added operation with id ['||l_oper_id||'], split_hash['|| l_split_hash||']');
    else
        -- get split_hash
        select min(split_hash)
          into l_split_hash
          from opr_oper_stage
         where oper_id = l_oper_id;

        if l_split_hash is null then
            com_api_error_pkg.raise_error(
                i_error         => 'OPERATION_NOT_FOUND'
              , i_env_param1    => l_oper_id
            );
        end if;

        --1
        delete
          from opr_oper_stage o
         where o.oper_id = l_oper_id
           and o.status  = opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
           and not exists(select 1 from opr_proc_stage p where p.command = i_command and p.proc_stage = o.proc_stage);

        trc_log_pkg.debug('Deleted ['||sql%rowcount||'] rows');

        --2
        for r in (
            select *
             from opr_proc_stage
            where command = i_command
               or (i_command = opr_api_const_pkg.OPER_STAGE_CMD_PROC_NORMALLY and proc_stage = opr_api_const_pkg.PROCESSING_STAGE_COMMON)
        ) loop

            merge into
                opr_oper_stage dst
            using (
                select l_oper_id          as oper_id
                     , r.proc_stage       as proc_stage
                     , r.status           as status
                     , r.exec_order       as exec_order
                     , l_split_hash       as split_hash
                     , i_external_auth_id as external_auth_id
                     , i_is_reversal      as is_reversal
                  from dual
            ) src
            on (
                    src.oper_id    = dst.oper_id
                and src.proc_stage = dst.proc_stage
            )
            when not matched then
                insert (
                    dst.oper_id
                  , dst.proc_stage
                  , dst.status
                  , dst.exec_order
                  , dst.split_hash
                  , dst.external_auth_id
                  , dst.is_reversal
                ) values (
                    src.oper_id
                  , src.proc_stage
                  , src.status
                  , src.exec_order
                  , src.split_hash
                  , src.external_auth_id
                  , src.is_reversal
                );

            trc_log_pkg.debug('Inserted ['||sql%rowcount||'] rows');

        end loop;

    end if;
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.set_oper_stage END');

end;

end opr_api_create_pkg;
/
