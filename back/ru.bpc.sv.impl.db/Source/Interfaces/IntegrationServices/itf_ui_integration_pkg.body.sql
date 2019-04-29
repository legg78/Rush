create or replace package body itf_ui_integration_pkg as

procedure check_customer_exists(
    i_customer_number     in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , io_customer_id        in out com_api_type_pkg.t_medium_id
) is
begin
    if io_customer_id is null then
        io_customer_id := prd_api_customer_pkg.get_customer_id(
                              i_customer_number => i_customer_number
                            , i_inst_id         => i_inst_id
                            , i_mask_error      => com_api_type_pkg.FALSE
                          );
    else
        select id
          into io_customer_id
          from prd_customer_vw
         where id       = io_customer_id
           and (inst_id = i_inst_id or i_inst_id is null);
    end if;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error       => 'CUSTOMER_NOT_FOUND'
          , i_env_param1  => nvl(i_customer_number, io_customer_id)
          , i_env_param2  => i_inst_id
        );
end;

procedure get_account_list(
    i_customer_number     in     com_api_type_pkg.t_name          default null
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_customer_id         in     com_api_type_pkg.t_medium_id     default null
  , i_card_number         in     com_api_type_pkg.t_card_number   default null
  , i_card_id             in     com_api_type_pkg.t_medium_id     default null
  , i_status              in     com_api_type_pkg.t_dict_value    default null
  , i_account_type        in     com_api_type_pkg.t_dict_value    default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_balance_type        in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor             out sys_refcursor
) is
    l_lang          com_api_type_pkg.t_dict_value;
    l_cursor_str    com_api_type_pkg.t_text;
    l_customer_id   com_api_type_pkg.t_medium_id;
    l_card_rec      iss_api_type_pkg.t_card_rec;
begin
    l_lang := coalesce(i_lang, get_user_lang());

    l_customer_id := i_customer_id;

    -- get card
    if l_customer_id is null and i_customer_number is null then
        l_card_rec := iss_api_card_pkg.get_card(
                          i_card_id     => i_card_id
                        , i_card_number => i_card_number
                        , i_inst_id     => i_inst_id
                        , i_mask_error  => com_api_type_pkg.FALSE
                      );
        l_customer_id := l_card_rec.customer_id;
    end if;

    check_customer_exists(
        i_customer_number   => i_customer_number
      , i_inst_id           => i_inst_id
      , io_customer_id      => l_customer_id
    );

    l_cursor_str :=
       'select t.id
       , t.account_number
       , t.account_type
       , com_api_dictionary_pkg.get_article_desc(t.account_type, l_lang) account_type_name
       , t.currency
       , (select name from com_currency where code = t.currency) currency_name
       , t.status
       , com_api_dictionary_pkg.get_article_desc(t.status, l_lang) status_name
       , com_api_currency_pkg.get_amount_str(t.ladger_balance, t.currency, 1, ''FM999999999999999990.0099'') aval_balance
       , com_api_currency_pkg.get_amount_str(t.hold_balance, t.currency, 1, ''FM999999999999999990.0099'')  hold_balance
       , t.agent_id
       , com_api_i18n_pkg.get_text(''ost_agent'',''name'', t.agent_id, l_lang) agent_name
       , t.open_date
       , case when t.status = ''ACSTCLSD'' then t.close_date
              else null
         end close_date
       , com_ui_object_pkg.get_object_desc(t.entity_type, t.object_id, l_lang) owner_name
       , com_api_currency_pkg.get_amount_str(t.request_balance, t.currency, 1, ''FM999999999999999990.0099'') request_balance
    from(
        select a.id
             , a.account_number
             , a.account_type
             , a.currency
             , a.status
             , a.agent_id
             , c.object_id
             , c.entity_type
             , min(b.open_date) open_date
             , max(b.close_date) close_date
             , sum(case when b.balance_type = ''BLTP0002'' then b.balance else 0 end) hold_balance
             , acc_api_balance_pkg.get_aval_balance_amount_only(a.id) ladger_balance
             , sum(case when b.balance_type = i_balance_type then b.balance else 0 end) request_balance
          from acc_account a
             , prd_customer c
             , acc_balance b
             , (select :i_inst_id i_inst_id
                     , :i_customer_id l_customer_id
                     , :i_customer_number i_customer_number
                     , :l_card_id l_card_id
                     , :i_status i_status
                     , :i_account_type i_account_type
                     , :i_balance_type i_balance_type
                     from dual) x
         where c.id = a.customer_id
           and a.inst_id = i_inst_id
           and b.account_id = a.id
           and b.split_hash = a.split_hash
           and c.id = l_customer_id ';

    if i_card_id is not null or i_card_number is not null then
        l_card_rec := iss_api_card_pkg.get_card(
                          i_card_id     => i_card_id
                        , i_card_number => i_card_number
                        , i_mask_error  => com_api_type_pkg.FALSE
                      );
        -- Checking for institute
        if l_card_rec.customer_id != l_customer_id then
            com_api_error_pkg.raise_error(
                i_error      => 'CARD_NOT_FOUND'
              , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number)
              , i_env_param2 => l_card_rec.id
              , i_env_param3 => l_customer_id
            );
        end if;

        l_cursor_str := l_cursor_str
                     || ' and exists (select 1 from acc_account_object o ' ||
                                      'where l_card_id = o.object_id ' ||
                                        'and o.account_id = a.id ' ||
                                        'and o.entity_type = ''ENTTCARD'')';
    end if;

    if i_status is not null then
        l_cursor_str := l_cursor_str || ' and i_status = a.status';
    end if;

    if i_account_type is not null then
        l_cursor_str := l_cursor_str || ' and i_account_type = a.account_type';
    end if;

    l_cursor_str := l_cursor_str ||
        ' group by a.id
             , a.account_number
             , a.account_type
             , a.currency
             , a.status
             , a.agent_id
             , c.object_id
             , c.entity_type
    ) t
    , (select :i_lang l_lang from dual) x';

    --dbms_output.put_line(l_cursor_str);
    open o_ref_cursor for l_cursor_str
        using i_inst_id
            , l_customer_id
            , upper(i_customer_number)
            , l_card_rec.id
            , i_status
            , i_account_type
            , i_balance_type
            , l_lang;
exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_account_list FAILED: l_customer_id [' || l_customer_id ||
                          '], l_card_rec{id [' || l_card_rec.id || '], customer_id [' || l_card_rec.customer_id ||
                          ']}, l_cursor_str: ' || chr(13) || chr(10) || l_cursor_str);
        raise;
end get_account_list;

procedure get_account_list(
    i_customer_number   in     com_api_type_pkg.t_name          default null
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_customer_id       in     com_api_type_pkg.t_medium_id     default null
  , i_card_number       in     com_api_type_pkg.t_card_number   default null
  , i_card_uid          in     com_api_type_pkg.t_name          default null
  , i_status            in     com_api_type_pkg.t_dict_value    default null
  , i_account_type      in     com_api_type_pkg.t_dict_value    default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
  , i_balance_type      in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor           out sys_refcursor
) is
    l_card_id   com_api_type_pkg.t_medium_id;
begin
    if i_card_uid is null then
        l_card_id := null;
    else
        l_card_id := iss_api_card_pkg.get_card_id_by_uid(
                         i_card_uid => i_card_uid
                       , i_inst_id  => i_inst_id
                     );
    end if;

    get_account_list(
        i_customer_number   => i_customer_number
      , i_inst_id           => i_inst_id
      , i_customer_id       => i_customer_id
      , i_card_number       => i_card_number
      , i_card_id           => l_card_id
      , i_status            => i_status
      , i_account_type      => i_account_type
      , i_lang              => i_lang
      , i_balance_type      => i_balance_type
      , o_ref_cursor        => o_ref_cursor
    );
end get_account_list;

procedure get_account_payment_details(
    i_id                  in     com_api_type_pkg.t_account_id
    , io_account_number   in out com_api_type_pkg.t_account_number
    , i_inst_id           in     com_api_type_pkg.t_inst_id
    , i_lang              in     com_api_type_pkg.t_dict_value    default null
    , o_recipient_name    out    com_api_type_pkg.t_name
    , o_bank_name         out    com_api_type_pkg.t_name
    , o_bic               out    com_api_type_pkg.t_name
    , o_tin               out    com_api_type_pkg.t_name
    , o_corr_account      out    com_api_type_pkg.t_name
    , o_bank_address      out    com_api_type_pkg.t_param_value
) is
    l_lang                com_api_type_pkg.t_dict_value;
    l_id                  com_api_type_pkg.t_account_id;
begin
    l_lang := coalesce(i_lang, get_user_lang());
    l_id := i_id;

    if l_id is null then
        begin
            select id
              into l_id
              from acc_account
             where account_number =  io_account_number
               and inst_id = i_inst_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error                 => 'ACCOUNT_NOT_FOUND'
                    , i_env_param1          => nvl(io_account_number, l_id)
                    , i_env_param2          => i_inst_id
                );
        end;
    end if;

   select t.account_number
        , com_ui_object_pkg.get_object_desc(t.entity_type, t.object_id, l_lang)
        , com_api_i18n_pkg.get_text('ost_institution','name', t.inst_id, l_lang)
        , com_api_flexible_data_pkg.get_flexible_value ('FLX_BANK_ID_CODE', 'ENTTINST', t.inst_id)
        , com_api_flexible_data_pkg.get_flexible_value ('FLX_TAX_ID', 'ENTTINST', t.inst_id)
        , com_api_flexible_data_pkg.get_flexible_value ('CORRESPONDENT_ACCOUNT', 'ENTTINST', t.inst_id)
        , com_api_address_pkg.get_address_string(t.address_id, l_lang)
     into io_account_number
        , o_recipient_name
        , o_bank_name
        , o_bic
        , o_tin
        , o_corr_account
        , o_bank_address
     from (select a.account_number
               , c.object_id
               , c.entity_type
               , a.inst_id
               , (select address_id
                    from com_address_object o
                   where o.object_id = a.inst_id
                     and o.address_type = 'ADTPBSNA'
                     and o.entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION) address_id
            from acc_account a
               , prd_customer c
           where a.id = l_id
             and a.inst_id = i_inst_id
             and c.id = a.customer_id) t;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error       => 'ACCOUNT_NOT_FOUND'
          , i_env_param1  => nvl(io_account_number, l_id)
          , i_env_param2  => i_inst_id
        );
end get_account_payment_details;

procedure get_rate_for_inst(
    i_rate_type           in     com_api_type_pkg.t_dict_value
    , i_src_currency      in     com_api_type_pkg.t_curr_code
    , i_dst_currency      in     com_api_type_pkg.t_curr_code
    , i_eff_date          in     date default null
    , i_inst_id           in     com_api_type_pkg.t_inst_id
    , o_rate                 out com_api_type_pkg.t_rate
) is
begin
    o_rate := com_api_rate_pkg.get_rate(
                  i_src_currency     => i_src_currency
                , i_dst_currency     => i_dst_currency
                , i_rate_type        => i_rate_type
                , i_inst_id          => i_inst_id
                , i_eff_date         => trunc(coalesce(i_eff_date, com_api_sttl_day_pkg.get_sysdate))
                , i_mask_exception   => com_api_type_pkg.FALSE
                , i_exception_value  => 0
              );
end get_rate_for_inst;

function get_balance(
    i_card_id             in     com_api_type_pkg.t_medium_id
    , i_balance_type      in     com_api_type_pkg.t_dict_value
    , i_bin_currency      in     com_api_type_pkg.t_curr_code
    , i_inst_id           in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_name is
    l_balance             com_api_type_pkg.t_money;
    l_limit_amount        com_api_type_pkg.t_money;
    l_array_id            com_api_type_pkg.t_medium_id;
begin
    if i_balance_type = acc_api_const_pkg.BALANCE_TYPE_HOLD then
        select nvl(sum(case when b.currency = i_bin_currency
                        then b.balance
                        else com_api_rate_pkg.convert_amount(
                                 i_src_amount      => b.balance
                               , i_src_currency    => b.currency
                               , i_dst_currency    => i_bin_currency
                               , i_rate_type       => t.rate_type
                               , i_inst_id         => a.inst_id
                               , i_eff_date        => com_api_sttl_day_pkg.get_sysdate
                               , i_mask_exception  => com_api_type_pkg.FALSE
                               , i_exception_value => null
                               , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_SELLING
                             )
                   end), 0)
          into l_balance
          from acc_account_object o
             , acc_account a
             , acc_balance b
             , acc_balance_type t
         where o.object_id = i_card_id
           and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           and o.account_id = a.id
           and a.status = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE
           and b.account_id = a.id
           and b.balance_type = acc_api_const_pkg.BALANCE_TYPE_HOLD
           and t.account_type = a.account_type
           and t.balance_type = b.balance_type
           and b.split_hash = a.split_hash
           and a.inst_id = t.inst_id;
    else
        select nvl(sum(case when b.currency = i_bin_currency
                        then acc_api_balance_pkg.get_aval_balance_amount_only(a.id)
                        else com_api_rate_pkg.convert_amount(
                                 i_src_amount      => acc_api_balance_pkg.get_aval_balance_amount_only(a.id)
                               , i_src_currency    => b.currency
                               , i_dst_currency    => i_bin_currency
                               , i_rate_type       => t.rate_type
                               , i_inst_id         => a.inst_id
                               , i_eff_date        => com_api_sttl_day_pkg.get_sysdate
                               , i_mask_exception  => com_api_type_pkg.FALSE
                               , i_exception_value => null
                               , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_SELLING
                             )
                   end), 0)
          into l_balance
          from acc_account_object o
             , acc_account a
             , acc_balance b
             , acc_balance_type t
         where o.object_id = i_card_id
           and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           and o.account_id = a.id
           and a.status = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE
           and b.account_id = a.id
           and b.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
           and b.close_date is null
           and t.account_type = a.account_type
           and t.balance_type = b.balance_type
           and b.split_hash = a.split_hash
           and a.inst_id = t.inst_id;

        trc_log_pkg.debug(
            i_text       => 'l_balance [' || l_balance || ']'
        );
        -- get aval balance of limits of card
        l_limit_amount := iss_api_card_pkg.get_card_limit_balance(
            i_card_id       => i_card_id
            , i_eff_date    => com_api_sttl_day_pkg.get_sysdate
            , i_inst_id     => i_inst_id
            , i_currency    => i_bin_currency
            , o_array_id    => l_array_id
        );
        trc_log_pkg.debug(
            i_text       => 'l_limit_amount [' || l_limit_amount || ']'
        );

        if l_array_id is not null then

            l_balance := least(0, l_balance, l_limit_amount);

        end if;

        trc_log_pkg.debug(
            i_text       => 'l_balance [' || l_balance || ']'
        );
    end if;

    return com_api_currency_pkg.get_amount_str(
               i_amount         => l_balance
             , i_curr_code      => i_bin_currency
             , i_mask_curr_code => com_api_type_pkg.TRUE
             , i_format_mask    => 'FM999999999999999990.0099'
           );
end get_balance;

procedure get_card_list(
    i_customer_number           in  com_api_type_pkg.t_name
  , i_inst_id                   in  com_api_type_pkg.t_inst_id
  , i_customer_id               in  com_api_type_pkg.t_medium_id
  , i_account_number            in  com_api_type_pkg.t_account_number
  , i_account_id                in  com_api_type_pkg.t_account_id
  , i_state                     in  com_api_type_pkg.t_dict_value        default null
  , i_get_balance               in  com_api_type_pkg.t_boolean           default null
  , i_card_mask                 in  com_api_type_pkg.t_card_number       default null
  , i_card_type_id              in  com_api_type_pkg.t_tiny_id           default null
  , i_product_id                in  com_api_type_pkg.t_short_id          default null
  , i_creation_date             in  date                                 default null
  , i_expir_date                in  date                                 default null
  , i_embossed_name             in  com_api_type_pkg.t_name              default null
  , i_cardholder_first_name     in  com_api_type_pkg.t_name              default null
  , i_cardholder_last_name      in  com_api_type_pkg.t_name              default null
  , i_cardholder_number         in  com_api_type_pkg.t_name              default null
  , i_lang                      in  com_api_type_pkg.t_dict_value        default null
  , i_impersonal_cards          in  com_api_type_pkg.t_name              default null
  , o_ref_cursor               out  sys_refcursor
) is
    l_customer_id                   com_api_type_pkg.t_medium_id;
    l_account_rec                   acc_api_type_pkg.t_account_rec;
    l_lang                          com_api_type_pkg.t_dict_value;
    l_cursor_str                    com_api_type_pkg.t_lob_data;
    l_unmasked_pan                  com_api_type_pkg.t_boolean;
    l_cardholder_id                 com_api_type_pkg.t_medium_id;
    l_impersonal_cards              com_api_type_pkg.t_medium_id;

    LOG_PREFIX             constant com_api_type_pkg.t_name            := lower($$PLSQL_UNIT) || '.get_card_list: ';
 
    FIRST_PART             constant com_api_type_pkg.t_text            := '
        with bals as (select accnt.account_id
                            , accnt.card_id
                            , case when nvl(:i_get_balance, :i_false) = :i_true
                                   then itf_ui_integration_pkg.get_balance(
                                              i_card_id      => accnt.object_id
                                            , i_balance_type => :i_ledger
                                            , i_bin_currency => accnt.bin_currency
                                            , i_inst_id      => accnt.inst_id
                                        )
                                   else null
                              end as aval_balance
                            , case when nvl(:i_get_balance, :i_false) = :i_true
                                   then itf_ui_integration_pkg.get_balance(
                                              i_card_id      => accnt.object_id
                                            , i_balance_type => :i_ledger
                                            , i_bin_currency => accnt.bin_currency
                                            , i_inst_id      => accnt.inst_id
                                        )
                                   else null
                              end as hold_balance
                         from (select o.id
                                    , o.object_id
                                    , b.bin_currency
                                    , o.account_id
                                    , c.inst_id
                                    , c.id card_id
                                    , row_number() over (partition by c.id order by o.id) acc_rn
                                 from iss_card c
                                 join iss_card_instance i 
                                   on c.id = i.card_id
                                 join iss_bin b 
                                   on b.id = i.bin_id ';

    MIDDLE_PART            constant com_api_type_pkg.t_lob_data        := '
                             ) accnt
                       where acc_rn=1
             )
        select c.id                                                                        as id
             , iss_api_card_pkg.get_card_uid_by_id(c.id)                                   as card_uid
             , i.id                                                                        as card_instance_id
             , case when :l_unmasked_pan = 0 then null
                    else iss_api_token_pkg.decode_card_number(n.card_number)
               end                                                                         as card_number
             , iss_api_card_pkg.get_card_mask(i_card_number => n.card_number)              as card_mask
             , t.id                                                                        as card_type
             , i.seq_number                                                                as seq_number
             , nvl(i.reg_date, c.reg_date)                                                 as creation_date
             , to_char(i.expir_date, ''mm.yyyy'')                                          as expir_date
             , com_ui_person_pkg.get_person_name(h.person_id, :l_lang)                     as person_name
             , c.category                                                                  as category
             , com_api_dictionary_pkg.get_article_desc(c.category, :l_lang)                as category_name
             , t.network_id                                                                as network_id
             , com_api_i18n_pkg.get_text(''net_network'', ''name'', t.network_id, :l_lang) as network_name
             , i.status                                                                    as status
             , com_api_dictionary_pkg.get_article_desc(i.status, :l_lang)                  as status_name
             , i.state                                                                     as state
             , com_api_dictionary_pkg.get_article_desc(i.state, :l_lang)                   as state_name
             , i.delivery_status                                                           as delivery_status
             , com_api_dictionary_pkg.get_article_desc(i.delivery_status, :l_lang)         as delivery_status_name
             , b.bin_currency                                                              as bin_currency
             , (select name from com_currency where code = b.bin_currency)                 as currency_name
             , bals.aval_balance                                                           as aval_balance
             , bals.hold_balance                                                           as hold_balance
             , nvl(:l_customer_id, c.customer_id)                                          as customer_id
             , prd_api_customer_pkg.get_customer_number(
                   i_customer_id => nvl(:l_customer_id, c.customer_id)
                 , i_inst_id     => :l_inst_id
               )                                                                           as customer_number
             , p.inst_id                                                                   as inst_id
             , acc_api_account_pkg.get_account_number(i_account_id => bals.account_id)     as account_number
             , bals.account_id                                                             as account_id
             , p.product_id                                                                as product_id
             , get_text(''prd_product'', ''label'', p.product_id, :l_lang)                 as product_name
             , (i.embossed_first_name || '' '' || i.embossed_surname)                      as embossed_name ';
    MIDDLE_PART2           constant com_api_type_pkg.t_lob_data        := '
             , substr(h.cardholder_name, 1, instr(h.cardholder_name, '' '')-1)             as cardholder_first_name
             , substr(h.cardholder_name, instr(h.cardholder_name, '' '')+1)                as cardholder_last_name
          from iss_card c
          join iss_card_instance i 
            on c.id = i.card_id
           and (:i_state is null or i.state = :i_state)
          join iss_bin b 
            on b.id = i.bin_id
          join prd_contract_vw p
            on p.id      = c.contract_id
           and p.inst_id = c.inst_id
          join iss_card_number_vw n
            on n.card_id = c.id
          join net_card_type t
            on t.id      = c.card_type_id ';

    SQL_WITHOUT_BALS       constant com_api_type_pkg.t_text            := '
        select c.id                                                                        as id
             , iss_api_card_pkg.get_card_uid_by_id(c.id)                                   as card_uid
             , i.id                                                                        as card_instance_id
             , case when :l_unmasked_pan = 0 then null
                    else iss_api_token_pkg.decode_card_number(n.card_number)
               end                                                                         as card_number
             , iss_api_card_pkg.get_card_mask(i_card_number => n.card_number)              as card_mask
             , t.id                                                                        as card_type
             , i.seq_number                                                                as seq_number
             , nvl(i.reg_date, c.reg_date)                                                 as creation_date
             , to_char(i.expir_date, ''mm.yyyy'')                                          as expir_date
             , null                                                                        as person_name
             , c.category                                                                  as category
             , com_api_dictionary_pkg.get_article_desc(c.category, :l_lang)                as category_name
             , t.network_id                                                                as network_id
             , com_api_i18n_pkg.get_text(''net_network'', ''name'', t.network_id, :l_lang) as network_name
             , i.status                                                                    as status
             , com_api_dictionary_pkg.get_article_desc(i.status, :l_lang)                  as status_name
             , i.state                                                                     as state
             , com_api_dictionary_pkg.get_article_desc(i.state, :l_lang)                   as state_name
             , i.delivery_status                                                           as delivery_status
             , com_api_dictionary_pkg.get_article_desc(i.delivery_status, :l_lang)         as delivery_status_name
             , b.bin_currency                                                              as bin_currency
             , (select name from com_currency where code = b.bin_currency)                 as currency_name
             , null                                                                        as aval_balance
             , null                                                                        as hold_balance
             , nvl(:l_customer_id, c.customer_id)                                          as customer_id
             , prd_api_customer_pkg.get_customer_number(
                   i_customer_id => nvl(:l_customer_id, c.customer_id)
                 , i_inst_id     => :l_inst_id
               )                                                                           as customer_number
             , p.inst_id                                                                   as inst_id
             , null                                                                        as account_number
             , null                                                                        as account_id
             , p.product_id                                                                as product_id
             , get_text(''prd_product'', ''label'', p.product_id, :l_lang)                 as product_name
             , (i.embossed_first_name || '' '' || i.embossed_surname)                      as embossed_name
             , null                                                                        as cardholder_first_name
             , null                                                                        as cardholder_last_name ';
    SQL_WITHOUT_BALS2      constant com_api_type_pkg.t_text            := '
          from iss_card c
          join iss_card_instance i 
            on c.id = i.card_id
           and (:i_state is null or i.state = :i_state)
          join iss_bin b 
            on b.id = i.bin_id
          join prd_contract_vw p
            on p.id      = c.contract_id
           and p.inst_id = c.inst_id
          join iss_card_number_vw n
            on n.card_id = c.id
          join net_card_type t
            on t.id      = c.card_type_id
         where c.cardholder_id is null
           and not exists (
               select 1 
                 from acc_account_object ao
                where ao.object_id = c.id
                  and ao.entity_type = :i_entity_card_type
               ) ';
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX
               || 'START with i_customer_number [' || i_customer_number
               || '], i_inst_id ['                 || i_inst_id
               || '], i_customer_id ['             || i_customer_id
               || '], i_account_number ['          || i_account_number
               || '], i_account_id ['              || i_account_id
               || '], i_state ['                   || i_state
               || '], i_get_balance ['             || i_get_balance
               || '], i_card_mask ['               || i_card_mask
               || '], i_card_type_id ['            || i_card_type_id
               || '], i_product_id ['              || i_product_id
               || '], i_creation_date ['           || i_creation_date
               || '], i_expir_date ['              || i_expir_date
               || '], i_embossed_name ['           || i_embossed_name
               || '], i_cardholder_first_name ['   || i_cardholder_first_name
               || '], i_cardholder_last_name ['    || i_cardholder_last_name
               || '], i_cardholder_number ['       || i_cardholder_number
               || '], i_lang ['                    || i_lang
               || '], i_impersonal_cards ['        || i_impersonal_cards
               || ']'
    );

    l_lang        := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());
    l_customer_id := i_customer_id;

    case i_impersonal_cards
        when 'ANY' then
            l_impersonal_cards := 1;
        when 'UNLINKED' then
            l_impersonal_cards := 2;
        else -- 'NONE'
            l_impersonal_cards := 0;
    end case;

    if l_customer_id is not null or (i_inst_id is not null and i_customer_number is not null) then
        check_customer_exists(
            i_customer_number => i_customer_number
          , i_inst_id         => i_inst_id
          , io_customer_id    => l_customer_id
        );
        trc_log_pkg.debug(LOG_PREFIX || ' customer id [' || l_customer_id || ']');
    end if;

    if i_cardholder_number is not null and i_inst_id is not null then
        l_cardholder_id :=
            iss_api_cardholder_pkg.get_cardholder(
                i_inst_id           => i_inst_id
              , i_cardholder_number => i_cardholder_number
              , i_card_id           => null
              , i_mask_error        => com_api_const_pkg.FALSE
            ).id;
    end if;

    if i_account_id is not null or i_account_number is not null then
        l_account_rec := acc_api_account_pkg.get_account(
                             i_account_id     => i_account_id
                           , i_account_number => i_account_number
                           , i_inst_id        => i_inst_id
                           , i_mask_error     => com_api_type_pkg.FALSE
                         );
        trc_log_pkg.debug(
            i_text => LOG_PREFIX
                   || 'l_account_rec = {id [' || l_account_rec.account_id
                   || '], inst_id ['          || l_account_rec.inst_id
                   || ']}'
        );

        -- Extra check for correctness of account's institution and customer
        if i_inst_id is not null and nvl(l_account_rec.inst_id, i_inst_id) != i_inst_id
           or
           l_customer_id != l_account_rec.customer_id
        then
            com_api_error_pkg.raise_error(
                i_error      => 'ACCOUNT_NOT_FOUND'
              , i_env_param1 => l_account_rec.account_id
              , i_env_param2 => i_inst_id
              , i_env_param3 => l_customer_id
            );
        end if;
    end if;

    l_unmasked_pan := nvl(set_ui_value_pkg.get_inst_param_n('UNMASKED_PAN_IN_RESPONSE_ON_WS'), com_api_type_pkg.TRUE);

    if l_impersonal_cards = 0 then
        -- 1. based on customer identifier (if specified);
        -- 2. based on customer number and institution identifier; (!) already received l_customer_id
        if l_customer_id is not null then
            trc_log_pkg.debug(LOG_PREFIX || 'open cursor by customer ID, impersonal_cards = NONE');
            l_cursor_str := FIRST_PART
                || '             join iss_cardholder h 
                                   on h.id = c.cardholder_id
                                 join acc_account_object o
                                   on o.object_id = c.id
                                  and o.object_id  is not null
                                  and o.entity_type = :i_entity_card_type
                                  and (o.account_id = :l_account_id or :l_account_id is null)
                                where c.customer_id = :l_customer_id '
                || MIDDLE_PART || MIDDLE_PART2 || '
          join acc_account_object ao 
            on ao.object_id   = c.id
           and ao.entity_type = :i_entity_card_type
          join bals
            on bals.account_id = ao.account_id
           and bals.card_id    = ao.object_id
          join iss_cardholder h
            on h.id = c.cardholder_id
         where c.customer_id  = :l_customer_id ';
        -- 3. based on cardholder number and institution identifier;
        elsif i_cardholder_number is not null then
            trc_log_pkg.debug(LOG_PREFIX || 'open cursor by cardholder number and inst ID, impersonal_cards = NONE');
            l_cursor_str := FIRST_PART
                         || '     join iss_cardholder h 
                                    on h.id = c.cardholder_id 
                                   and h.cardholder_number = ''' || i_cardholder_number || '''
                                  join acc_account_object o
                                    on o.object_id = c.id
                                   and o.object_id  is not null
                                   and o.entity_type = :i_entity_card_type
                                   and (o.account_id = :l_account_id or :l_account_id is null)
                                 where c.inst_id = :i_inst_id '
                         || MIDDLE_PART || MIDDLE_PART2 || '
          join acc_account_object ao 
            on ao.object_id   = c.id
           and ao.entity_type = :i_entity_card_type
          join bals
            on bals.account_id = ao.account_id
           and bals.card_id    = ao.object_id
          join iss_cardholder h
            on h.id = c.cardholder_id
         where c.inst_id  = :i_inst_id
           and h.cardholder_number = ''' || i_cardholder_number || ''' ';
        -- 4. based on card mask and institution identifier;
        elsif i_card_mask is not null then
            trc_log_pkg.debug(LOG_PREFIX || 'open cursor by card mask and inst ID, impersonal_cards = NONE');
            l_cursor_str := FIRST_PART
                || '          join iss_cardholder h 
                                on h.id = c.cardholder_id
                              join acc_account_object o
                                on o.object_id = c.id
                               and o.object_id  is not null
                               and o.entity_type = :i_entity_card_type
                               and (o.account_id = :l_account_id or :l_account_id is null)
                             where c.inst_id = :i_inst_id 
                               and reverse(c.card_mask) like reverse(:i_card_mask) '
                || MIDDLE_PART || MIDDLE_PART2 || '
          join acc_account_object ao 
            on ao.object_id   = c.id
           and ao.entity_type = :i_entity_card_type
          join bals
            on bals.account_id = ao.account_id
           and bals.card_id    = ao.object_id
          join iss_cardholder h
            on h.id = c.cardholder_id
         where c.inst_id  = :i_inst_id 
           and reverse(c.card_mask) like reverse(:i_card_mask) ';
        end if;
    elsif l_impersonal_cards = 1 then
        -- 1. based on customer identifier (if specified);
        -- 2. based on customer number and institution identifier; (!) already received l_customer_id
        if l_customer_id is not null then
            trc_log_pkg.debug(LOG_PREFIX || 'open cursor by customer ID, impersonal_cards = ANY');
            l_cursor_str := FIRST_PART
                || '        left join iss_cardholder h 
                                   on h.id = c.cardholder_id
                            left join acc_account_object o
                                   on o.object_id = c.id
                                  and o.object_id  is not null
                                  and o.entity_type = :i_entity_card_type
                                  and (o.account_id = :l_account_id or :l_account_id is null)
                                where c.customer_id = :l_customer_id '
                || MIDDLE_PART || MIDDLE_PART2 || '
     left join acc_account_object ao 
            on ao.object_id   = c.id
           and ao.entity_type = :i_entity_card_type
     left join bals
            on bals.account_id = ao.account_id
           and bals.card_id    = ao.object_id
     left join iss_cardholder h
            on h.id = c.cardholder_id
         where c.customer_id  = :l_customer_id ';
        -- 3. based on cardholder number and institution identifier;
        elsif i_cardholder_number is not null then
            trc_log_pkg.debug(LOG_PREFIX || 'open cursor by cardholder number and inst ID, impersonal_cards = ANY');
            l_cursor_str := FIRST_PART
                || '              join iss_cardholder h 
                                    on h.id = c.cardholder_id 
                                   and h.cardholder_number = ''' || i_cardholder_number || '''
                             left join acc_account_object o
                                    on o.object_id = c.id
                                   and o.object_id  is not null
                                   and o.entity_type = :i_entity_card_type
                                   and (o.account_id = :l_account_id or :l_account_id is null)
                                 where c.inst_id = :i_inst_id '
                || MIDDLE_PART || MIDDLE_PART2 || '
     left join acc_account_object ao 
            on ao.object_id   = c.id
           and ao.entity_type = :i_entity_card_type
     left join bals
            on bals.account_id = ao.account_id
           and bals.card_id    = ao.object_id
          join iss_cardholder h
            on h.id = c.cardholder_id
         where c.inst_id  = :i_inst_id
           and h.cardholder_number = ''' || i_cardholder_number || ''' ';
        -- 4. based on card mask and institution identifier;
        elsif i_card_mask is not null then
            trc_log_pkg.debug(LOG_PREFIX || 'open cursor by card mask and inst ID, impersonal_cards = ANY');
            l_cursor_str := FIRST_PART
                || '          join iss_cardholder h 
                                on h.id = c.cardholder_id
                              join acc_account_object o
                                on o.object_id = c.id
                               and o.object_id  is not null
                               and o.entity_type = :i_entity_card_type
                               and (o.account_id = :l_account_id or :l_account_id is null)
                             where c.inst_id = :i_inst_id 
                               and reverse(c.card_mask) like reverse(:i_card_mask) '
                || MIDDLE_PART || MIDDLE_PART2 || '
     left join acc_account_object ao 
            on ao.object_id   = c.id
           and ao.entity_type = :i_entity_card_type
     left join bals
            on bals.account_id = ao.account_id
           and bals.card_id    = ao.object_id
     left join iss_cardholder h
            on h.id = c.cardholder_id
         where c.inst_id  = :i_inst_id 
           and reverse(c.card_mask) like reverse(:i_card_mask) ';
        end if;

    elsif l_impersonal_cards = 2 then
        -- 1. based on customer identifier (if specified);
        -- 2. based on customer number and institution identifier; (!) already received l_customer_id
        if l_customer_id is not null then
            trc_log_pkg.debug(LOG_PREFIX || 'open cursor by customer ID, impersonal_cards = NONE');
            l_cursor_str := SQL_WITHOUT_BALS || SQL_WITHOUT_BALS2 || '
           and c.customer_id  = :l_customer_id ';
        -- 3. based on cardholder number and institution identifier;
        elsif i_cardholder_number is not null then
            trc_log_pkg.debug(LOG_PREFIX || 'open cursor by customer ID, impersonal_cards = NONE');
            l_cursor_str := SQL_WITHOUT_BALS || SQL_WITHOUT_BALS2 || '
           and c.inst_id  = :i_inst_id
           and 1 = 2 '; -- NOT SUPPORTED
        -- 4. based on card mask and institution identifier;
        elsif i_card_mask is not null then
            trc_log_pkg.debug(LOG_PREFIX || 'open cursor by card mask and inst ID, impersonal_cards = NONE');
            l_cursor_str := SQL_WITHOUT_BALS || SQL_WITHOUT_BALS2 || '
           and c.inst_id  = :i_inst_id 
           and reverse(c.card_mask) like reverse(:i_card_mask) ';
        end if;
    end if;

    if i_card_type_id is not null then
        l_cursor_str := l_cursor_str || ' and c.card_type_id = ' || i_card_type_id;
    end if;

    if i_product_id is not null then
        l_cursor_str := l_cursor_str || ' and p.product_id = ' || i_product_id;
    end if;

    if i_creation_date is not null then
        l_cursor_str := l_cursor_str
                     || ' and to_date(to_char(nvl(i.reg_date, c.reg_date), ''DD.MM.YYYY''), ''DD.MM.YYYY'') = to_date('''
                     || to_char(i_creation_date, 'DD.MM.YYYY')
                     || ''', ''DD.MM.YYYY'')';
    end if;

    if i_expir_date is not null then
        l_cursor_str := l_cursor_str
                     || ' and i.expir_date <= to_date(''' || to_char(i_expir_date, 'DD.MM.YYYY') || ''', ''DD.MM.YYYY'')';
    end if;

    if i_embossed_name is not null then
        l_cursor_str := l_cursor_str
                     || ' and ((i.embossed_first_name || '' '' || i.embossed_surname) = '''
                     || upper(i_embossed_name)
                     || ''' or (i.embossed_title || '' '' || i.embossed_first_name || '' '' || i.embossed_surname) = '''
                     || upper(i_embossed_name)
                     || ''')';
    end if;

    if i_cardholder_first_name is not null and i_cardholder_last_name is not null and l_impersonal_cards != 2 then
        l_cursor_str := l_cursor_str
                     || ' and h.cardholder_name = '''
                     || upper(i_cardholder_first_name)
                     || ' '
                     || upper(i_cardholder_last_name)
                     || '''';
    elsif i_cardholder_first_name is not null and i_cardholder_last_name is null and l_impersonal_cards != 2 then
        l_cursor_str := l_cursor_str
                     || ' and h.cardholder_name = '''
                     || upper(i_cardholder_first_name)
                     || '''';
    elsif i_cardholder_first_name is null and i_cardholder_last_name is not null and l_impersonal_cards != 2 then
        l_cursor_str := l_cursor_str
                     || ' and h.cardholder_name = '''
                     || upper(i_cardholder_last_name)
                     || '''';
    end if;

    if i_cardholder_number is not null and l_impersonal_cards != 2 then
        l_cursor_str := l_cursor_str || ' and h.cardholder_number = ''' || i_cardholder_number || '''';
    end if;

    case l_impersonal_cards
        when 2 then
            if i_card_mask is not null then
                open o_ref_cursor for l_cursor_str
                using l_unmasked_pan
                    , l_lang
                    , l_lang
                    , l_lang
                    , l_lang
                    , l_lang
                    , l_customer_id
                    , l_customer_id
                    , i_inst_id
                    , l_lang
                    , i_state
                    , i_state
                    , iss_api_const_pkg.ENTITY_TYPE_CARD
                    , nvl(l_customer_id, i_inst_id)  -- for cardholder's variant of request;
                    , i_card_mask;
            else
                open o_ref_cursor for l_cursor_str
                using l_unmasked_pan
                    , l_lang
                    , l_lang
                    , l_lang
                    , l_lang
                    , l_lang
                    , l_customer_id
                    , l_customer_id
                    , i_inst_id
                    , l_lang
                    , i_state
                    , i_state
                    , iss_api_const_pkg.ENTITY_TYPE_CARD
                    , nvl(l_customer_id, i_inst_id);  -- for cardholder's variant of request;
            end if;
        else
            if i_card_mask is not null then
                open o_ref_cursor for l_cursor_str
                using i_get_balance
                    , com_api_type_pkg.FALSE
                    , com_api_type_pkg.TRUE
                    , acc_api_const_pkg.BALANCE_TYPE_LEDGER
                    , i_get_balance
                    , com_api_type_pkg.FALSE
                    , com_api_type_pkg.TRUE
                    , acc_api_const_pkg.BALANCE_TYPE_LEDGER
                    , iss_api_const_pkg.ENTITY_TYPE_CARD
                    , l_account_rec.account_id
                    , l_account_rec.account_id
                    , nvl(l_customer_id, i_inst_id)  -- for cardholder's variant of request
                    , i_card_mask
                    , l_unmasked_pan
                    , l_lang
                    , l_lang
                    , l_lang
                    , l_lang
                    , l_lang
                    , l_lang
                    , l_customer_id
                    , l_customer_id
                    , i_inst_id
                    , l_lang
                    , i_state
                    , i_state
                    , iss_api_const_pkg.ENTITY_TYPE_CARD
                    , nvl(l_customer_id, i_inst_id) -- for cardholder's variant of request
                    , i_card_mask;
            else
                open o_ref_cursor for l_cursor_str
                using i_get_balance
                    , com_api_type_pkg.FALSE
                    , com_api_type_pkg.TRUE
                    , acc_api_const_pkg.BALANCE_TYPE_LEDGER
                    , i_get_balance
                    , com_api_type_pkg.FALSE
                    , com_api_type_pkg.TRUE
                    , acc_api_const_pkg.BALANCE_TYPE_LEDGER
                    , iss_api_const_pkg.ENTITY_TYPE_CARD
                    , l_account_rec.account_id
                    , l_account_rec.account_id
                    , nvl(l_customer_id, i_inst_id)  -- for cardholder's variant of request
                    , l_unmasked_pan
                    , l_lang
                    , l_lang
                    , l_lang
                    , l_lang
                    , l_lang
                    , l_lang
                    , l_customer_id
                    , l_customer_id
                    , i_inst_id
                    , l_lang
                    , i_state
                    , i_state
                    , iss_api_const_pkg.ENTITY_TYPE_CARD
                    , nvl(l_customer_id, i_inst_id);  -- for cardholder's variant of request
            end if;
    end case;
exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'l_cursor_str [1] [' || substr(l_cursor_str, 1, 2411) || ']'
        );
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'l_cursor_str [2] [' || substr(l_cursor_str, 2412, 3151) || ']'
        );
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'l_cursor_str [3] [' || substr(l_cursor_str, 5563) || ']'
        );
        raise;
end get_card_list;

procedure get_card_details(
    i_card_number         in     com_api_type_pkg.t_card_number
  , i_card_id             in     com_api_type_pkg.t_medium_id
  , i_seq_number          in     com_api_type_pkg.t_inst_id
  , i_expir_date          in     date
  , i_instance_id         in     com_api_type_pkg.t_medium_id
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_card_type_id        in     com_api_type_pkg.t_tiny_id       default null
  , i_inst_id             in     com_api_type_pkg.t_inst_id       default null
  , o_ref_cursor             out sys_refcursor
) is
    l_lang                       com_api_type_pkg.t_dict_value;
    l_seq_number                 com_api_type_pkg.t_inst_id;
    l_card_id                    com_api_type_pkg.t_medium_id;
    l_unmasked_pan               com_api_type_pkg.t_boolean;
    l_person_id                  com_api_type_pkg.t_medium_id;

    type t_detail_rec is record (
        card_instance_id         com_api_type_pkg.t_medium_id
      , seq_number               com_api_type_pkg.t_tiny_id
      , card_id                  com_api_type_pkg.t_medium_id
      , split_hash               com_api_type_pkg.t_tiny_id
      , expir_date               com_api_type_pkg.t_name
      , status                   com_api_type_pkg.t_dict_value
      , state                    com_api_type_pkg.t_dict_value
      , iss_date                 date
      , agent_id                 com_api_type_pkg.t_short_id
      , prec_card_instance_id    com_api_type_pkg.t_medium_id
      , delivery_method          com_api_type_pkg.t_dict_value
      , reissue_reason           com_api_type_pkg.t_dict_value
      , customer_id              com_api_type_pkg.t_medium_id
      , card_mask                com_api_type_pkg.t_card_number
      , card_type_id             com_api_type_pkg.t_tiny_id
      , category                 com_api_type_pkg.t_dict_value
      , cardholder_id            com_api_type_pkg.t_medium_id
      , contract_id              com_api_type_pkg.t_medium_id
      , network_id               com_api_type_pkg.t_tiny_id
      , is_virtual               com_api_type_pkg.t_boolean
    );

    type t_info_rec is record (
        card_uid                  com_api_type_pkg.t_name
      , card_number               com_api_type_pkg.t_card_number
      , person_name               com_api_type_pkg.t_name
      , card_type_name            com_api_type_pkg.t_name
      , network_name              com_api_type_pkg.t_name
      , category_name             com_api_type_pkg.t_name
      , status                    com_api_type_pkg.t_dict_value
      , status_name               com_api_type_pkg.t_name
      , state                     com_api_type_pkg.t_dict_value
      , state_name                com_api_type_pkg.t_name
      , agent_name                com_api_type_pkg.t_name
      , agent_number              com_api_type_pkg.t_name
      , product_number            com_api_type_pkg.t_name
      , product_id                com_api_type_pkg.t_short_id
      , product_name              com_api_type_pkg.t_name
      , counter_invalid_pin       com_api_type_pkg.t_long_id
      , delivery_method_desc      com_api_type_pkg.t_full_desc
      , reissue_reason_desc       com_api_type_pkg.t_full_desc
      , state_change_reason       com_api_type_pkg.t_dict_value
      , state_change_reason_desc  com_api_type_pkg.t_full_desc
      , state_change_date         date
      , state_change_user         com_api_type_pkg.t_name
      , prev_state                com_api_type_pkg.t_dict_value
      , prev_state_desc           com_api_type_pkg.t_full_desc
      , status_change_reason      com_api_type_pkg.t_dict_value
      , status_change_reason_desc com_api_type_pkg.t_full_desc
      , status_change_date        date
      , status_change_user        com_api_type_pkg.t_name
      , prev_status               com_api_type_pkg.t_dict_value
      , prev_status_desc          com_api_type_pkg.t_full_desc
      , last_application_date     date
      , last_application_user     com_api_type_pkg.t_name
      , prev_card_id              com_api_type_pkg.t_long_id
      , prev_card_number          com_api_type_pkg.t_card_number
      , replace_card_id           com_api_type_pkg.t_medium_id
      , replace_card_number       com_api_type_pkg.t_card_number
    );

    l_detail_rec    t_detail_rec;
    l_info_rec      t_info_rec;

    procedure get_status_log_info(
        i_card_instance_id         in     com_api_type_pkg.t_medium_id
      , i_stat_type                in     com_api_type_pkg.t_dict_value
      , o_reason                      out com_api_type_pkg.t_dict_value
      , o_change_date                 out date
      , o_change_user                 out com_api_type_pkg.t_name
      , o_prev_state                  out com_api_type_pkg.t_dict_value
      , o_state_change_reason_desc    out com_api_type_pkg.t_full_desc
      , o_prev_state_desc             out com_api_type_pkg.t_full_desc
    ) is
    begin
        select h.reason
             , h.change_date
             , u.name as change_user
             , h.prev_state
          into o_reason
             , o_change_date
             , o_change_user
             , o_prev_state
          from (
                   select sl.reason
                        , sl.change_date
                        , sl.user_id
                        , lag(sl.status) over (partition by sl.object_id, substr(sl.status, 1, 4) order by sl.change_date) as prev_state
                        , row_number()   over (partition by sl.object_id, substr(sl.status, 1, 4) order by sl.change_date desc) as rn
                     from evt_status_log sl
                    where sl.object_id            = i_card_instance_id
                      and sl.entity_type          = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                      and substr(sl.status, 1, 4) = i_stat_type
               ) h
             , acm_user u
         where u.id = h.user_id
           and h.rn = 1;

        o_state_change_reason_desc := com_api_dictionary_pkg.get_article_desc(o_reason,     l_lang);
        o_prev_state_desc          := com_api_dictionary_pkg.get_article_desc(o_prev_state, l_lang);

    exception
        when no_data_found then
            null;
    end get_status_log_info;

begin
    l_lang         := coalesce(i_lang, get_user_lang);
    l_seq_number   := i_seq_number;
    l_unmasked_pan := nvl(set_ui_value_pkg.get_inst_param_n('UNMASKED_PAN_IN_RESPONSE_ON_WS'), com_api_type_pkg.TRUE);

    if i_instance_id is not null then
        begin
            select i.id
                 , i.seq_number
                 , i.card_id
                 , i.split_hash
                 , to_char(trunc(i.expir_date, 'mm'), 'mm.yyyy') as expir_date
                 , i.status
                 , i.state
                 , i.iss_date
                 , i.agent_id
                 , i.preceding_card_instance_id
                 , i.delivery_channel           as delivery_method
                 , i.reissue_reason
                 , c.customer_id
                 , c.card_mask
                 , c.card_type_id
                 , c.category
                 , c.cardholder_id
                 , c.contract_id
                 , t.network_id
                 , nvl(t.is_virtual, 0)         as is_virtual
              into l_detail_rec
              from iss_card_instance i
                 , iss_card c
                 , net_card_type t
             where i.id  = i_instance_id
               and c.id  = i.card_id
               and t.id  = c.card_type_id
               and (t.id = i_card_type_id or i_card_type_id is null)
               and (c.inst_id = i_inst_id or i_inst_id is null);
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error        => 'CARD_NOT_FOUND'
                  , i_env_param1   => i_instance_id
                );
        end;

    else
        l_card_id := iss_api_card_pkg.get_card(
                         i_card_id     => i_card_id
                       , i_card_number => i_card_number
                       , i_inst_id     => i_inst_id
                       , i_mask_error  => com_api_type_pkg.FALSE
                     ).id;

        if i_expir_date is not null then
            select max(i.seq_number)
              into l_seq_number
              from iss_card_instance i
             where i.card_id = l_card_id
               and trunc(i.expir_date, 'mm') = trunc(i_expir_date, 'mm')
               and (i.inst_id = i_inst_id or i_inst_id is null);

        elsif l_seq_number is null then
            select max(i.seq_number)
              into l_seq_number
              from iss_card_instance i
             where i.card_id = l_card_id
               and (i.inst_id = i_inst_id or i_inst_id is null);

        end if;

        select i.id
             , i.seq_number
             , i.card_id
             , i.split_hash
             , to_char(trunc(i.expir_date, 'mm'), 'mm.yyyy') as expir_date
             , i.status
             , i.state
             , i.iss_date
             , i.agent_id
             , i.preceding_card_instance_id
             , i.delivery_channel           as delivery_method
             , i.reissue_reason
             , c.customer_id
             , c.card_mask
             , c.card_type_id
             , c.category
             , c.cardholder_id
             , c.contract_id
             , t.network_id
             , nvl(t.is_virtual, 0)         as is_virtual
          into l_detail_rec
          from iss_card_instance i
             , iss_card c
             , net_card_type t
         where i.card_id    = l_card_id
           and i.seq_number = l_seq_number
           and c.id         = i.card_id
           and t.id         = c.card_type_id
           and (t.id        = i_card_type_id or i_card_type_id is null)
           and (c.inst_id   = i_inst_id or i_inst_id is null);

    end if;

    l_info_rec.card_uid             := iss_api_card_pkg.get_card_uid_by_id(l_detail_rec.card_id);

    l_info_rec.status_name          := com_api_dictionary_pkg.get_article_desc(l_detail_rec.status,          l_lang);
    l_info_rec.state_name           := com_api_dictionary_pkg.get_article_desc(l_detail_rec.state,           l_lang);
    l_info_rec.delivery_method_desc := com_api_dictionary_pkg.get_article_desc(l_detail_rec.delivery_method, l_lang);
    l_info_rec.reissue_reason_desc  := com_api_dictionary_pkg.get_article_desc(l_detail_rec.reissue_reason,  l_lang);
    l_info_rec.category_name        := com_api_dictionary_pkg.get_article_desc(l_detail_rec.category,        l_lang);

    l_info_rec.agent_name           := com_api_i18n_pkg.get_text('ost_agent',     'name', l_detail_rec.agent_id,     l_lang);
    l_info_rec.card_type_name       := com_api_i18n_pkg.get_text('net_card_type', 'name', l_detail_rec.card_type_id, l_lang);
    l_info_rec.network_name         := com_api_i18n_pkg.get_text('net_network',   'name', l_detail_rec.network_id,   l_lang);

    select ag.agent_number
      into l_info_rec.agent_number
      from ost_agent ag
     where ag.id = l_detail_rec.agent_id;

    if l_unmasked_pan = com_api_type_pkg.TRUE then
        select iss_api_token_pkg.decode_card_number(n.card_number)
          into l_info_rec.card_number
          from iss_card_number_vw n
         where n.card_id = l_detail_rec.card_id;
    end if;

    select p.product_number
         , p.id
      into l_info_rec.product_number
         , l_info_rec.product_id
      from prd_contract c
         , prd_product  p
     where c.id         = l_detail_rec.contract_id
       and c.split_hash = l_detail_rec.split_hash
       and p.id         = c.product_id;

    l_info_rec.product_name :=
        com_api_i18n_pkg.get_text(
            i_table_name     => 'prd_product'
          , i_column_name    => 'label'
          , i_object_id      => l_info_rec.product_id
          , i_lang           => l_lang
        );

    select h.person_id
      into l_person_id
      from iss_cardholder h
     where h.id = l_detail_rec.cardholder_id;

    l_info_rec.person_name := com_ui_person_pkg.get_person_name(l_person_id, l_lang);

    l_info_rec.counter_invalid_pin :=
        nvl(
            fcl_api_limit_pkg.get_limit_count_curr(
                i_limit_type  => iss_api_const_pkg.LIMIT_PIN_ENTRY
              , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id   => l_detail_rec.card_id
              , i_limit_id    => null
              , i_mask_error  => com_api_const_pkg.TRUE
            )
          , 0
        );

    get_status_log_info(
        i_card_instance_id         => l_detail_rec.card_instance_id
      , i_stat_type                => 'CSTE'
      , o_reason                   => l_info_rec.state_change_reason
      , o_change_date              => l_info_rec.state_change_date
      , o_change_user              => l_info_rec.state_change_user
      , o_prev_state               => l_info_rec.prev_state
      , o_state_change_reason_desc => l_info_rec.state_change_reason_desc
      , o_prev_state_desc          => l_info_rec.prev_state_desc
    );

    get_status_log_info(
        i_card_instance_id         => l_detail_rec.card_instance_id
      , i_stat_type                => 'CSTS'
      , o_reason                   => l_info_rec.status_change_reason
      , o_change_date              => l_info_rec.status_change_date
      , o_change_user              => l_info_rec.status_change_user
      , o_prev_state               => l_info_rec.prev_status
      , o_state_change_reason_desc => l_info_rec.status_change_reason_desc
      , o_prev_state_desc          => l_info_rec.prev_status_desc
    );

    -- Get user_name and date for last modification of this card
    begin
        select t.change_date
             , u.name as change_user
          into l_info_rec.last_application_date
             , l_info_rec.last_application_user
          from (
                   select max(h.change_date) keep (dense_rank last order by h.change_date) as change_date
                        , max(h.change_user) keep (dense_rank last order by h.change_date) as change_user_id
                     from app_object  o
                        , app_history h
                    where o.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                      and o.object_id    = l_detail_rec.card_id
                      and h.appl_id      = o.appl_id
                      and h.appl_status  = app_api_const_pkg.APPL_STATUS_PROC_SUCCESS
               ) t
             , acm_user u
         where u.id = t.change_user_id;

    exception
        when no_data_found then
            null;
    end;

    -- Get previous card number
    if l_detail_rec.prec_card_instance_id is not null then
        begin
            select i.card_id
                 , n.card_number
              into l_info_rec.prev_card_id
                 , l_info_rec.prev_card_number
              from iss_card_instance  i
                 , iss_card_number_vw n
             where i.id         = l_detail_rec.prec_card_instance_id
               and i.split_hash = l_detail_rec.split_hash
               and n.card_id    = i.card_id;

        exception
            when no_data_found then
                null;
        end;
    end if;

    -- Get next card number
    begin
        select i.card_id
             , n.card_number
          into l_info_rec.replace_card_id
             , l_info_rec.replace_card_number
          from iss_card           c
             , iss_card_instance  i
             , iss_card_number_vw n
         where c.customer_id                = l_detail_rec.customer_id
           and c.split_hash                 = l_detail_rec.split_hash
           and i.card_id                    = c.id
           and i.preceding_card_instance_id = l_detail_rec.card_instance_id
           and i.split_hash                 = l_detail_rec.split_hash
           and n.card_id                    = i.card_id;

    exception
        when no_data_found then
            null;
    end;

    open o_ref_cursor for
        select l_detail_rec.card_id                   as id
             , l_info_rec  .card_uid                  as card_uid
             , l_detail_rec.card_instance_id          as instance_id
             , l_info_rec  .card_number               as card_number
             , l_detail_rec.card_mask                 as card_mask
             , l_detail_rec.seq_number                as seq_number
             , l_detail_rec.expir_date                as expir_date
             , l_info_rec  .person_name               as person_name
             , l_detail_rec.card_type_id              as card_type_id
             , l_info_rec  .card_type_name            as name_card_type
             , l_detail_rec.network_id                as network_id
             , l_info_rec  .network_name              as network_name
             , l_detail_rec.category                  as category
             , l_info_rec  .category_name             as category_name
             , l_detail_rec.status                    as status
             , l_info_rec  .status_name               as status_name
             , l_detail_rec.state                     as state
             , l_info_rec  .state_name                as state_name
             , l_detail_rec.iss_date                  as iss_date
             , l_detail_rec.agent_id                  as agent_id
             , l_info_rec  .agent_name                as agent_name
             , l_info_rec  .agent_number              as agent_number
             , l_info_rec  .product_number            as product_number
             , l_info_rec  .product_id                as product_id
             , l_info_rec  .product_name              as product_name
             , l_detail_rec.is_virtual                as is_virtual
             , l_info_rec  .counter_invalid_pin       as counter_invalid_pin
             , l_detail_rec.delivery_method           as delivery_method
             , l_info_rec  .delivery_method_desc      as delivery_method_description
             , l_detail_rec.reissue_reason            as reissue_reason
             , l_info_rec  .reissue_reason_desc       as reissue_reason_description
             , l_info_rec  .state_change_reason       as state_change_reason
             , l_info_rec  .state_change_reason_desc  as state_change_reason_desc
             , l_info_rec  .state_change_date         as state_change_date
             , l_info_rec  .state_change_user         as state_change_user
             , l_info_rec  .prev_state                as prev_state
             , l_info_rec  .prev_state_desc           as prev_state_description
             , l_info_rec  .status_change_reason      as status_change_reason
             , l_info_rec  .status_change_reason_desc as status_change_reason_desc
             , l_info_rec  .status_change_date        as status_change_date
             , l_info_rec  .status_change_user        as status_change_user
             , l_info_rec  .prev_status               as prev_status
             , l_info_rec  .prev_status_desc          as prev_status_description
             , l_info_rec  .last_application_date     as last_application_date
             , l_info_rec  .last_application_user     as last_application_user
             , l_info_rec  .prev_card_id              as prev_card_id
             , l_info_rec  .prev_card_number          as prev_card_number
             , l_info_rec  .replace_card_id           as replace_card_id
             , l_info_rec  .replace_card_number       as replace_card_number
          from dual;

end get_card_details;

procedure get_card_details(
    i_card_number       in     com_api_type_pkg.t_card_number
  , i_card_uid          in     com_api_type_pkg.t_name
  , i_seq_number        in     com_api_type_pkg.t_inst_id
  , i_expir_date        in     date
  , i_instance_id       in     com_api_type_pkg.t_medium_id
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
  , i_card_type_id      in     com_api_type_pkg.t_tiny_id       default null
  , i_inst_id           in     com_api_type_pkg.t_inst_id       default null
  , o_ref_cursor       out     sys_refcursor
) is
    l_card_id   com_api_type_pkg.t_medium_id;
begin
    if i_card_uid is null then
        l_card_id := null;
    else
        l_card_id := iss_api_card_pkg.get_card_id_by_uid(
                         i_card_uid => i_card_uid
                       , i_inst_id  => i_inst_id
                     );
    end if;

    get_card_details(
        i_card_number   => i_card_number
      , i_card_id       => l_card_id
      , i_seq_number    => i_seq_number
      , i_expir_date    => i_expir_date
      , i_instance_id   => i_instance_id
      , i_lang          => i_lang
      , i_card_type_id  => i_card_type_id
      , i_inst_id       => i_inst_id
      , o_ref_cursor    => o_ref_cursor
    );
end get_card_details;

function get_country_name(
    i_code                 in     com_api_type_pkg.t_dict_value
    , i_lang               in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name
is
    l_result    com_api_type_pkg.t_name;
begin
    select com_api_i18n_pkg.get_text('com_country','name', c.id, i_lang)
      into l_result
      from com_country c
     where c.code = i_code;
    return l_result;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error             => 'COUNTRY_CODE_NOT_FOUND'
          , i_env_param1        => i_code
        );
end;

procedure get_customer_details(
    io_customer_id        in out com_api_type_pkg.t_medium_id
  , io_customer_number    in out com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_lang                in     com_api_type_pkg.t_dict_value default null
  , o_entity_type            out com_api_type_pkg.t_dict_value
  , o_entity_type_name       out com_api_type_pkg.t_name
  , o_category               out com_api_type_pkg.t_dict_value
  , o_category_name          out com_api_type_pkg.t_name
  , o_credit_rating          out com_api_type_pkg.t_dict_value
  , o_credit_rating_name     out com_api_type_pkg.t_name
  , o_resident               out com_api_type_pkg.t_inst_id
  , o_nationality            out com_api_type_pkg.t_dict_value
  , o_country_code           out com_api_type_pkg.t_dict_value
  , o_country_name           out com_api_type_pkg.t_name
  , o_relation               out com_api_type_pkg.t_dict_value
  , o_relation_name          out com_api_type_pkg.t_name
  , o_first_name             out com_api_type_pkg.t_name
  , o_second_name            out com_api_type_pkg.t_name
  , o_surname                out com_api_type_pkg.t_name
  , o_gender                 out com_api_type_pkg.t_dict_value
  , o_birthday               out date
  , o_place_birth            out com_api_type_pkg.t_full_desc
  , o_short_name             out com_api_type_pkg.t_name
  , o_full_name              out com_api_type_pkg.t_full_desc
  , o_incorp_form            out com_api_type_pkg.t_dict_value
  , o_incorp_form_name       out com_api_type_pkg.t_name
  , o_money_laundry_risk     out com_api_type_pkg.t_dict_value
  , o_person_title           out com_api_type_pkg.t_dict_value
  , o_person_suffix          out com_api_type_pkg.t_dict_value
  , o_marital_status         out com_api_type_pkg.t_dict_value
  , o_marital_status_date    out date
  , o_children_number        out com_api_type_pkg.t_dict_value
  , o_employment_status      out com_api_type_pkg.t_dict_value
  , o_employment_period      out com_api_type_pkg.t_dict_value
  , o_residence_type         out com_api_type_pkg.t_dict_value
  , o_income_range           out com_api_type_pkg.t_dict_value
) is
    l_lang                       com_api_type_pkg.t_dict_value;
    l_object_id                  com_api_type_pkg.t_medium_id;
begin
    l_lang := coalesce(i_lang, get_user_lang());
    check_customer_exists(
        i_customer_number   => io_customer_number
      , i_inst_id           => i_inst_id
      , io_customer_id      => io_customer_id
    );

    select c.id
        , c.customer_number
        , c.entity_type
        , com_api_dictionary_pkg.get_article_desc(c.entity_type, l_lang)
        , c.category
        , com_api_dictionary_pkg.get_article_desc(c.category, l_lang)
        , c.credit_rating
        , com_api_dictionary_pkg.get_article_desc(c.credit_rating, l_lang)
        , c.resident
        , c.nationality
        , case when c.nationality is null then null else com_api_country_pkg.get_country_name(c.nationality) end
        , case when c.nationality is null then null else get_country_name(c.nationality, l_lang) end
        , c.relation
        , com_api_dictionary_pkg.get_article_desc(c.relation, l_lang)
        , c.object_id
        , c.money_laundry_risk
        , c.marital_status
        , c.marital_status_date
        , c.number_of_children
        , c.employment_status
        , c.employment_period
        , c.residence_type
        , c.income_range
     into io_customer_id
        , io_customer_number
        , o_entity_type
        , o_entity_type_name
        , o_category
        , o_category_name
        , o_credit_rating
        , o_credit_rating_name
        , o_resident
        , o_nationality
        , o_country_code
        , o_country_name
        , o_relation
        , o_relation_name
        , l_object_id
        , o_money_laundry_risk
        , o_marital_status
        , o_marital_status_date
        , o_children_number
        , o_employment_status
        , o_employment_period
        , o_residence_type
        , o_income_range
     from prd_customer_vw c
    where c.id = io_customer_id
      and c.inst_id = i_inst_id;

    if o_entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON then
        begin
            select t.first_name
                 , t.second_name
                 , t.surname
                 , t.gender
                 , trunc(t.birthday)
                 , t.place_of_birth
                 , t.title
                 , t.suffix
              into o_first_name
                 , o_second_name
                 , o_surname
                 , o_gender
                 , o_birthday
                 , o_place_birth
                 , o_person_title
                 , o_person_suffix
              from
                  (select p.first_name
                        , p.second_name
                        , p.surname
                        , p.gender
                        , trunc(p.birthday) birthday
                        , p.place_of_birth
                        , p.title
                        , p.suffix                     
                     from com_person_vw p
                    where p.id = l_object_id
                    order by decode(lang, nvl(l_lang, com_ui_user_env_pkg.get_user_lang), 1, com_api_const_pkg.DEFAULT_LANGUAGE, 2, 3)
                  ) t
             where rownum = 1;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'PERSON_NOT_FOUND'
                  , i_env_param1  => l_object_id
                  , i_env_param2  => l_lang
                );
        end;
    else
        begin
            select com_api_i18n_pkg.get_text('com_company','label', l_object_id, l_lang)
                 , com_api_i18n_pkg.get_text('com_company','description', l_object_id, l_lang)
                 , c.incorp_form
                 , com_api_dictionary_pkg.get_article_desc(c.incorp_form, l_lang)
              into o_short_name
                 , o_full_name
                 , o_incorp_form
                 , o_incorp_form_name
              from com_company_vw c
             where c.id = l_object_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'COMPANY_NOT_FOUND'
                  , i_env_param1  => l_object_id
                );
        end;
    end if;
end get_customer_details;

procedure get_customer_addresses(
    i_customer_id          in     com_api_type_pkg.t_medium_id
    , i_customer_number    in     com_api_type_pkg.t_name
    , i_inst_id            in     com_api_type_pkg.t_inst_id
    , i_lang               in     com_api_type_pkg.t_dict_value    default null
    , o_ref_cursor         out    sys_refcursor
) is
    l_lang              com_api_type_pkg.t_dict_value;
    l_customer_id       com_api_type_pkg.t_medium_id;
begin
    l_lang := coalesce(i_lang, get_user_lang());

    l_customer_id := i_customer_id;
    check_customer_exists(
        i_customer_number     => i_customer_number
        , i_inst_id           => i_inst_id
        , io_customer_id      => l_customer_id
    );

    open o_ref_cursor for
        select o.address_type
            , com_api_dictionary_pkg.get_article_desc(i_article => o.address_type, i_lang => l_lang) as address_type_name
            , a.country
            , itf_ui_integration_pkg.get_country_name(i_code => a.country, i_lang => l_lang) as country_name
            , a.postal_code
            , a.region
            , a.city
            , a.street
            , a.house
            , a.apartment
         from prd_customer c
            , com_address_object o
            , com_address a
        where c.id = l_customer_id
          and c.inst_id = i_inst_id
          and o.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
          and o.object_id = c.id
          and a.id = o.address_id;

end get_customer_addresses;

procedure get_customer_contacts(
    i_customer_id        in     com_api_type_pkg.t_medium_id
  , i_customer_number    in     com_api_type_pkg.t_name
  , i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_get_only_actual    in     com_api_type_pkg.t_boolean       default null
  , i_lang               in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor            out sys_refcursor
) is
    l_lang                      com_api_type_pkg.t_dict_value;
    l_cursor_str                com_api_type_pkg.t_text;
    l_get_only_actual           com_api_type_pkg.t_boolean;
    l_customer_id               com_api_type_pkg.t_medium_id;
begin
    l_lang := coalesce(i_lang, get_user_lang());
    l_get_only_actual := nvl(i_get_only_actual, com_api_type_pkg.FALSE);

    l_customer_id := i_customer_id;
    check_customer_exists(
        i_customer_number     => i_customer_number
        , i_inst_id           => i_inst_id
        , io_customer_id      => l_customer_id
    );

    l_cursor_str :=
        'select o.contact_type
              , com_api_dictionary_pkg.get_article_desc(o.contact_type, i_lang) contact_type_name
              , d.commun_method
              , com_api_dictionary_pkg.get_article_desc(d.commun_method, i_lang) commun_method_name
              , d.commun_address
              , t.preferred_lang
           from prd_customer c
              , com_contact_object o
              , com_contact t
              , com_contact_data d
              , (select :i_lang i_lang
                      , :i_customer_id l_customer_id
                      , :i_inst_id i_inst_id
                      , :i_get_only_actual l_get_only_actual
                   from dual) x
          where c.inst_id = i_inst_id
            and o.object_id = c.id
            and o.entity_type = ''ENTTCUST''
            and t.id = o.contact_id
            and d.contact_id = o.contact_id
            and c.id = l_customer_id ';

    if l_get_only_actual = com_api_type_pkg.TRUE then
        l_cursor_str := l_cursor_str || ' and (d.end_date is null or d.end_date > to_date(''' || com_api_sttl_day_pkg.get_sysdate || '''))';
    end if;

    --dbms_output.put_line(l_cursor_str);
    open o_ref_cursor for l_cursor_str
        using l_lang
            , l_customer_id
            , i_inst_id
            , l_get_only_actual;

end get_customer_contacts;

procedure get_customer_documents(
    i_customer_id        in     com_api_type_pkg.t_medium_id
  , i_customer_number    in     com_api_type_pkg.t_name
  , i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_get_only_actual    in     com_api_type_pkg.t_boolean       default null
  , i_lang               in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor            out sys_refcursor
) is
    l_lang                      com_api_type_pkg.t_dict_value;
    l_cursor_str                com_api_type_pkg.t_text;
    l_get_only_actual           com_api_type_pkg.t_boolean;
    l_customer_id               com_api_type_pkg.t_medium_id;
begin
    l_lang := coalesce(i_lang, get_user_lang());
    l_get_only_actual := nvl(i_get_only_actual, com_api_type_pkg.FALSE);
    l_customer_id := i_customer_id;

    check_customer_exists(
        i_customer_number     => i_customer_number
        , i_inst_id           => i_inst_id
        , io_customer_id      => l_customer_id
    );

    l_cursor_str :=
        'select o.id_type
              , com_api_dictionary_pkg.get_article_desc(o.id_type, l_lang) id_type_name
              , o.id_series
              , o.id_number
              , trunc(o.id_issue_date) id_issue_date
              , trunc(o.id_expire_date) id_expire_date
              , o.id_issuer
              , com_api_i18n_pkg.get_text(''COM_ID_OBJECT'',''DESCRIPTION'', o.id, l_lang) comments
              , o.country as id_country
           from prd_customer c
              , com_id_object o
              , (select :i_lang l_lang
                      , :i_customer_id l_customer_id
                      , :i_inst_id i_inst_id
                      , :i_get_only_actual l_get_only_actual
                   from dual) x
          where c.object_id = o.object_id
            and c.entity_type = o.entity_type
            and c.id = l_customer_id ';

    if l_get_only_actual = com_api_type_pkg.TRUE then
        l_cursor_str := l_cursor_str || ' and (o.id_expire_date is null or trunc(o.id_expire_date) >= trunc(com_api_sttl_day_pkg.get_sysdate))';
    end if;

    --dbms_output.put_line(l_cursor_str);
    open o_ref_cursor for l_cursor_str
        using l_lang
            , l_customer_id
            , i_inst_id
            , l_get_only_actual;

end get_customer_documents;

procedure get_object_operations(
    i_card_id              in    com_api_type_pkg.t_medium_id
    , i_card_number        in    com_api_type_pkg.t_name
    , i_inst_id            in    com_api_type_pkg.t_inst_id
    , i_account_id         in    com_api_type_pkg.t_account_id
    , i_account_number     in    com_api_type_pkg.t_account_number
    , i_customer_id        in    com_api_type_pkg.t_medium_id
    , i_customer_number    in    com_api_type_pkg.t_name
    , i_lang               in    com_api_type_pkg.t_dict_value      default null
    , i_start_date         in    date
    , i_end_date           in    date
    , i_status_tab         in    com_dict_tpt                       default com_dict_tpt()
    , i_oper_type          in    com_api_type_pkg.t_dict_value      default null
    , i_msg_type           in    com_api_type_pkg.t_dict_value      default null
    , i_match_status       in    com_api_type_pkg.t_dict_value      default null
    , i_merchant_number    in    com_api_type_pkg.t_merchant_number default null
    , i_merchant_name      in    com_api_type_pkg.t_name            default null
    , o_ref_cursor         out   sys_refcursor
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_object_operations: ';
    l_lang              com_api_type_pkg.t_dict_value;
    l_card_rec          iss_api_type_pkg.t_card_rec;
    l_account_rec       acc_api_type_pkg.t_account_rec;
    l_customer_id       com_api_type_pkg.t_medium_id;
    l_currency          com_api_type_pkg.t_dict_value;
    l_start_date        date;
    l_end_date          date;
    l_statuses_cnt      com_api_type_pkg.t_count := 0;
    l_account_id        com_api_type_pkg.t_account_id;
begin
    trc_log_pkg.debug(
        LOG_PREFIX || 'START with i_card_id ['    || i_card_id
                   || '], i_inst_id ['            || i_inst_id
                   || '], i_card_number ['        || iss_api_card_pkg.get_card_mask(i_card_number)
                   || '], i_status_tab.count() [' || i_status_tab.count()
                   || '], i_account_id ['         || i_account_id
                   || '], i_account_number ['     || i_account_number
                   || '], i_customer_id ['        || i_customer_id
                   || '], i_customer_number ['    || i_customer_number
                   || '], i_oper_type ['          || i_oper_type
                   || '], i_msg_type ['           || i_msg_type
                   || '], i_match_status ['       || i_match_status
                   || '], i_merchant_number ['    || i_merchant_number
                   || '], i_merchant_name ['      || i_merchant_name || ']'
    );

    if i_card_id is not null or i_card_number is not null then
        l_card_rec := iss_api_card_pkg.get_card(
                          i_card_id     => i_card_id
                        , i_card_number => i_card_number
                        , i_mask_error  => com_api_type_pkg.FALSE
                      );
        trc_log_pkg.debug(LOG_PREFIX || 'l_card_rec = {id [' || l_card_rec.id
                                     || '], inst_id [' || l_card_rec.inst_id  || ']}');

        -- Extra check for correctness of institution
        if i_inst_id is not null and nvl(l_card_rec.inst_id, i_inst_id) != i_inst_id then
            com_api_error_pkg.raise_error(
                i_error      => 'CARD_NOT_FOUND'
              , i_env_param1 => l_card_rec.id
              , i_env_param2 => i_inst_id
            );
        end if;

        begin
            select distinct first_value(a.id) over (order by o.usage_order, o.is_pos_default desc, o.is_atm_default desc)
              into l_account_id
              from acc_account_object o
                 , acc_account a
             where o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and o.object_id   = l_card_rec.id
               and a.id          = o.account_id
               and a.status     != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'ACCOUNT_NOT_FOUND'
                  , i_env_param1 => l_card_rec.id
                  , i_env_param2 => i_inst_id
                );
        end;

        -- Get balance currency
        begin
            select currency
              into l_currency
              from acc_balance_vw
             where account_id = l_account_id
               and balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error      => 'BALANCE_NOT_FOUND'
                  , i_env_param1 => l_account_id
                  , i_env_param2 => acc_api_const_pkg.BALANCE_TYPE_LEDGER
                );
        end;

    elsif i_account_id is not null or i_account_number is not null then
        l_account_rec := acc_api_account_pkg.get_account(
                             i_account_id     => i_account_id
                           , i_account_number => i_account_number
                           , i_inst_id        => i_inst_id
                           , i_mask_error     => com_api_type_pkg.FALSE
                         );
        trc_log_pkg.debug(LOG_PREFIX || 'l_account_rec = {id [' || l_account_rec.account_id
                                     || '], inst_id [' || l_account_rec.inst_id || ']}');

        -- Extra check for correctness of institution
        if i_inst_id is not null and nvl(l_account_rec.inst_id, i_inst_id) != i_inst_id then
            com_api_error_pkg.raise_error(
                i_error      => 'ACCOUNT_NOT_FOUND'
              , i_env_param1 => l_account_rec.account_id
              , i_env_param2 => i_inst_id
            );
        end if;

        -- Get balance currency
        begin
            select currency
              into l_currency
              from acc_balance_vw
             where account_id = l_account_rec.account_id
               and balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error      => 'BALANCE_NOT_FOUND'
                  , i_env_param1 => l_account_rec.account_id
                  , i_env_param2 => acc_api_const_pkg.BALANCE_TYPE_LEDGER
                );
        end;

    else
        -- No data about an account and a card is availabe thus we are trying to use customer data
        l_customer_id := i_customer_id;
        check_customer_exists(
            i_customer_number   => i_customer_number
          , i_inst_id           => i_inst_id
          , io_customer_id      => l_customer_id
        );
        trc_log_pkg.debug(LOG_PREFIX || 'l_customer_id [' || l_customer_id || ']');
    end if;

    l_statuses_cnt := i_status_tab.count();
    l_lang         := coalesce(i_lang, get_user_lang());
    if i_start_date is null then
        com_api_error_pkg.raise_error (
            i_error      => 'START_DATE_IS_EMPTY'
        );
    end if;
    l_start_date   := trunc(i_start_date);
    if i_end_date is null then
        com_api_error_pkg.raise_error (
            i_error      => 'END_DATE_IS_EMPTY'
        );
    end if;
    l_end_date     := trunc(i_end_date) + 1 - com_api_const_pkg.ONE_SECOND;

    open o_ref_cursor for
        select o.id
             , coalesce(p.card_mask, iss_api_card_pkg.get_card_mask(i_card_number => opc.card_number)) as card_mask
             , p.account_number
             , p.card_seq_number
             , o.is_reversal
             , o.oper_date
             , o.oper_type
             , com_api_dictionary_pkg.get_article_desc(i_article => o.oper_type, i_lang => l_lang) as oper_type_name
             , o.status
             , com_api_dictionary_pkg.get_article_desc(i_article => o.status, i_lang => l_lang) as status_name
             , com_api_currency_pkg.get_amount_str(
                   i_amount         => o.oper_amount
                 , i_curr_code      => o.oper_currency
                 , i_mask_curr_code => com_api_type_pkg.TRUE
                 , i_format_mask    => 'FM999999999999999990.0099'
                 , i_mask_error     => com_api_type_pkg.TRUE
               ) as oper_amount
             , o.oper_currency
             , c.name as currency_name
             , o.mcc
             , o.merchant_name
             , o.merchant_number
             , itf_ui_integration_pkg.get_merchant_address(
                   i_merchant_postcode => o.merchant_postcode
                 , i_merchant_country  => o.merchant_country
                 , i_merchant_region   => o.merchant_region
                 , i_merchant_city     => o.merchant_city
                 , i_merchant_street   => o.merchant_street
               ) as merchant_address
             , com_api_currency_pkg.get_amount_str(
                   i_amount         => get_available_balance_amount(
                                           i_account_id => p.account_id
                                         , i_oper_id    => o.id
                                         , i_host_date  => o.host_date
                                         , i_currency   => l_currency
                                       )
                 , i_curr_code      => l_currency
                 , i_mask_curr_code => com_api_type_pkg.TRUE
                 , i_format_mask    => 'FM999999999999999990.0099'
                 , i_mask_error     => com_api_type_pkg.TRUE
               ) as balance
             , l_currency as currency
             , com_api_currency_pkg.get_amount_str(
                   i_amount         => nvl(
                       (select abs(sum(e.balance_impact * e.amount))
                          from acc_entry e
                             , acc_macros m
                         where m.object_id        = o.id
                           and m.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                           and m.id               = e.macros_id
                           and e.status          != acc_api_const_pkg.ENTRY_STATUS_CANCELED
                           and e.account_id       = p.account_id
                           and e.balance_type    in (acc_api_const_pkg.BALANCE_TYPE_LEDGER, acc_api_const_pkg.BALANCE_TYPE_HOLD)
                       )
                     , 0
                   )
                 , i_curr_code      => l_currency
                 , i_mask_curr_code => com_api_type_pkg.TRUE
                 , i_format_mask    => 'FM999999999999999990.0099'
                 , i_mask_error     => com_api_type_pkg.TRUE
               ) as account_amount
             , l_currency as account_currency
             , o.host_date
             , o.original_id
             , case
                   when o.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT and o.match_id is not null
                        then (select aa.external_auth_id from aut_auth aa where aa.id = o.match_id)
                   else a.external_auth_id
               end as external_auth_id
             , a.resp_code
             , a.is_advice
             , a.cat_level
             , a.card_data_input_cap
             , a.crdh_auth_cap
             , a.card_capture_cap
             , a.terminal_operating_env
             , a.crdh_presence
             , a.card_presence
             , a.card_data_input_mode
             , a.crdh_auth_method
             , a.crdh_auth_entity
             , a.card_data_output_cap
             , a.terminal_output_cap
             , a.pin_capture_cap
             , a.pin_presence
             , o.terminal_number
             , p.auth_code
          from opr_operation o
             , opr_participant p
             , opr_card opc
             , com_currency c
             , aut_auth a
         where o.host_date between l_start_date and l_end_date
           and o.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
           and p.oper_id = o.id
           and c.code(+) = o.oper_currency
           and opc.oper_id(+) = p.oper_id
           and opc.participant_type(+) = p.participant_type
           and a.id(+) = o.id
           and (o.is_reversal = 0
                or
                not exists (select * from opr_operation op where o.id = op.original_id and op.is_reversal = 1))
           and (l_card_rec.id is not null            and p.card_id = l_card_rec.id
                or
                l_account_rec.account_id is not null and p.account_id = l_account_rec.account_id
                or
                l_customer_id is not null            and p.customer_id = l_customer_id)
           and (l_statuses_cnt = 0 or o.status in (select nvl(column_value, o.status) from table(i_status_tab)))
           and (i_oper_type is null or o.oper_type = i_oper_type)
           and (i_msg_type is null or o.msg_type = i_msg_type)
           and (i_match_status is null or o.match_status = i_match_status)
           and (i_merchant_number is null or upper(o.merchant_number) like upper(i_merchant_number))
           and (i_merchant_name is null or upper(o.merchant_name) like upper(i_merchant_name));

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        trc_log_pkg.debug(LOG_PREFIX || 'FAILED with l_lang [' || l_lang
                                     || '], l_currency [' || l_currency
                                     || '], l_start_date [' || com_api_type_pkg.convert_to_char(l_start_date)
                                     || '], l_end_date [' || com_api_type_pkg.convert_to_char(l_end_date) || ']');
        raise;
end get_object_operations;

procedure get_object_operations(
    i_card_uid              in    com_api_type_pkg.t_name
  , i_card_number           in    com_api_type_pkg.t_name
  , i_inst_id               in    com_api_type_pkg.t_inst_id
  , i_account_id            in    com_api_type_pkg.t_account_id
  , i_account_number        in    com_api_type_pkg.t_account_number
  , i_customer_id           in    com_api_type_pkg.t_medium_id
  , i_customer_number       in    com_api_type_pkg.t_name
  , i_lang                  in    com_api_type_pkg.t_dict_value      default null
  , i_start_date            in    date
  , i_end_date              in    date
  , i_status_tab            in    com_dict_tpt                       default com_dict_tpt()
  , i_oper_type             in    com_api_type_pkg.t_dict_value      default null
  , i_msg_type              in    com_api_type_pkg.t_dict_value      default null
  , i_match_status          in    com_api_type_pkg.t_dict_value      default null
  , i_merchant_number       in    com_api_type_pkg.t_merchant_number default null
  , i_merchant_name         in    com_api_type_pkg.t_name            default null
  , o_ref_cursor           out   sys_refcursor
) is
    l_card_id   com_api_type_pkg.t_medium_id;
begin
    if i_card_uid is null then
        l_card_id := null;
    else
        l_card_id := iss_api_card_pkg.get_card_id_by_uid(
                         i_card_uid => i_card_uid
                       , i_inst_id  => i_inst_id
                     );
    end if;

    get_object_operations(
        i_card_id           => l_card_id
      , i_card_number       => i_card_number
      , i_inst_id           => i_inst_id
      , i_account_id        => i_account_id
      , i_account_number    => i_account_number
      , i_customer_id       => i_customer_id
      , i_customer_number   => i_customer_number
      , i_lang              => i_lang
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_status_tab        => i_status_tab
      , i_oper_type         => i_oper_type
      , i_msg_type          => i_msg_type
      , i_match_status      => i_match_status
      , i_merchant_number   => i_merchant_number
      , i_merchant_name     => i_merchant_name
      , o_ref_cursor        => o_ref_cursor
    );

end get_object_operations;

function get_merchant_address(
    i_merchant_postcode    in     com_api_type_pkg.t_name
    , i_merchant_country   in     com_api_type_pkg.t_name
    , i_merchant_region    in     com_api_type_pkg.t_name
    , i_merchant_city      in     com_api_type_pkg.t_name
    , i_merchant_street    in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_full_desc
is
    l_result        com_api_type_pkg.t_full_desc;
begin
    if i_merchant_postcode is not null then
        l_result := i_merchant_postcode;
    end if;

    if i_merchant_country is not null then
        if l_result is not null then
            l_result := l_result || ', ';
        end if;
        l_result := l_result || i_merchant_country;
    end if;

    if i_merchant_region is not null then
        if l_result is not null then
            l_result := l_result || ', ';
        end if;
        l_result := l_result || i_merchant_region;
    end if;

    if i_merchant_city is not null then
        if l_result is not null then
            l_result := l_result || ', ';
        end if;
        l_result := l_result || i_merchant_city;
    end if;

    if i_merchant_street is not null then
        if l_result is not null then
            l_result := l_result || ', ';
        end if;
        l_result := l_result || i_merchant_street;
    end if;

    return l_result;
end;

procedure get_customer_ntf_settings(
    i_customer_id          in    com_api_type_pkg.t_medium_id
    , i_customer_number    in    com_api_type_pkg.t_name
    , i_inst_id            in    com_api_type_pkg.t_inst_id
    , i_account_id         in    com_api_type_pkg.t_account_id
    , i_account_number     in    com_api_type_pkg.t_account_number
    , i_card_id            in    com_api_type_pkg.t_medium_id
    , i_card_number        in    com_api_type_pkg.t_name
    , i_lang               in    com_api_type_pkg.t_dict_value    default null
    , o_ref_cursor         out   sys_refcursor
) is
    l_lang              com_api_type_pkg.t_dict_value;
    l_customer_id       com_api_type_pkg.t_medium_id;
    l_product_id        com_api_type_pkg.t_short_id;
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_scheme_id         com_api_type_pkg.t_tiny_id;
    l_entity_type       com_api_type_pkg.t_dict_value;
    l_object_id         com_api_type_pkg.t_medium_id;
    l_card_rec          iss_api_type_pkg.t_card_rec;
    l_srv_active        com_api_type_pkg.t_boolean;
begin
    l_lang := coalesce(i_lang, get_user_lang());

    l_customer_id := i_customer_id;
    check_customer_exists(
        i_customer_number     => i_customer_number
        , i_inst_id           => i_inst_id
        , io_customer_id      => l_customer_id
    );

    l_product_id := prd_api_product_pkg.get_product_id(
        i_entity_type       => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id         => l_customer_id
    );

    l_scheme_id := prd_api_product_pkg.get_attr_value_number (
        i_product_id    => l_product_id
      , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id     => l_customer_id
      , i_attr_name     => 'NOTIFICATION_SCHEME'
      , i_params        => l_param_tab
      , i_inst_id       => i_inst_id
    );

    -- get object
    if i_card_id is not null or i_card_number is not null then
        l_card_rec := iss_api_card_pkg.get_card(
                          i_card_id     => i_card_id
                        , i_card_number => i_card_number
                        , i_mask_error  => com_api_type_pkg.FALSE
                      );
        if l_card_rec.customer_id != l_customer_id then
            com_api_error_pkg.raise_error (
                i_error      => 'CARD_NOT_FOUND'
              , i_env_param1 => nvl(i_card_number, l_card_rec.id)
              , i_env_param3 => l_customer_id
            );
        else
            l_object_id := l_card_rec.id;
            l_entity_type := iss_api_const_pkg.ENTITY_TYPE_CARD;

            if prd_api_service_pkg.get_active_service_id(
                   i_entity_type => l_entity_type
                 , i_object_id   => l_object_id
                 , i_attr_name   => ntf_api_const_pkg.NOTIFICATION_SERVICE_USE_FEE
                 , i_eff_date    => com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id)
                 , i_mask_error  => com_api_type_pkg.TRUE
                 , i_inst_id     => i_inst_id
               ) is null
            then
                l_srv_active := com_api_type_pkg.FALSE;
            else
                l_srv_active := com_api_type_pkg.TRUE;
            end if;
        end if;

    elsif i_account_id is not null or i_account_number is not null then
        begin
            if i_account_id is null then
                select id
                  into l_object_id
                  from acc_account
                 where account_number = i_account_number
                   and inst_id = i_inst_id
                   and customer_id = l_customer_id;
            else
                select id
                  into l_object_id
                  from acc_account
                 where id = i_account_id
                   and inst_id = i_inst_id
                   and customer_id = l_customer_id;
            end if;
            l_entity_type := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;

            l_srv_active := com_api_type_pkg.FALSE;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error                 => 'ACCOUNT_NOT_FOUND'
                    , i_env_param1          => nvl(i_account_number, i_account_id)
                    , i_env_param2          => i_inst_id
                    , i_env_param3          => l_customer_id
                );
        end;
    end if;

    open o_ref_cursor for
        select l_entity_type as entity_type
             , com_api_dictionary_pkg.get_article_desc(l_entity_type, l_lang) entity_type_name
             , l_object_id as object_id
             , e.event_type
             , com_api_dictionary_pkg.get_article_desc(e.event_type, l_lang) event_type_name
             , nvl(c.channel_id, l.id) channel_id
             , com_api_i18n_pkg.get_text('ntf_channel','name', nvl(c.channel_id, l.id), l_lang) channel_name
             , ntf_api_notification_pkg.get_delivery_address (
                                           i_address      => c.delivery_address
                                         , i_channel_id   => l.id
                                         , i_entity_type  => e.entity_type
                                         , i_object_id    => l_customer_id
                                         , i_contact_type => e.contact_type
                                     ) delivery_address
          from ntf_scheme_event  e
             , ntf_channel       l
             , ntf_custom_event  c
             , ntf_custom_object o
         where e.scheme_id          = l_scheme_id
           and e.channel_id         = l.id
           and e.entity_type        = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
           and ( (e.status = ntf_api_const_pkg.STATUS_ALWAYS_SEND)
              or (e.status = ntf_api_const_pkg.STATUS_SEND_SERVICE_ACTIVE and l_srv_active = com_api_type_pkg.TRUE)
           )
           and c.entity_type(+)     = e.entity_type
           and c.object_id(+)       = l_customer_id
           and nvl(c.contact_type(+), e.contact_type) = e.contact_type
           and o.custom_event_id(+) = c.id
           and o.object_id(+)       = l_object_id
           and nvl(o.is_active, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE
         ;
end get_customer_ntf_settings;

procedure get_customer_ntf_settings(
    i_customer_id       in    com_api_type_pkg.t_medium_id
  , i_customer_number   in    com_api_type_pkg.t_name
  , i_inst_id           in    com_api_type_pkg.t_inst_id
  , i_account_id        in    com_api_type_pkg.t_account_id
  , i_account_number    in    com_api_type_pkg.t_account_number
  , i_card_uid          in    com_api_type_pkg.t_name
  , i_card_number       in    com_api_type_pkg.t_name
  , i_lang              in    com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor       out    sys_refcursor
) is
    l_card_id   com_api_type_pkg.t_medium_id;
begin
    if i_card_uid is null then
        l_card_id := null;
    else
        l_card_id := iss_api_card_pkg.get_card_id_by_uid(
                         i_card_uid => i_card_uid
                       , i_inst_id  => i_inst_id
                     );
    end if;

    get_customer_ntf_settings(
        i_customer_id       => i_customer_id
      , i_customer_number   => i_customer_number
      , i_inst_id           => i_inst_id
      , i_account_id        => i_account_id
      , i_account_number    => i_account_number
      , i_card_id           => l_card_id
      , i_card_number       => i_card_number
      , i_lang              => i_lang
      , o_ref_cursor        => o_ref_cursor
    );
end get_customer_ntf_settings;

/*
 * Returns all limits for specified entity object.
 * Procedure supports searching by 3 entity types, every entity should be specified
 * either its identifier or number.
 * Searching priority: 1) card; 2) account; 3) customer.
 * @i_inst_id    is a mandatory parameter for searching by any entity type
 */
procedure get_object_limits(
    i_card_number          in    com_api_type_pkg.t_name
  , i_card_id              in    com_api_type_pkg.t_medium_id
  , i_account_id           in    com_api_type_pkg.t_account_id
  , i_account_number       in    com_api_type_pkg.t_account_number
  , i_inst_id              in    com_api_type_pkg.t_inst_id
  , i_customer_id          in    com_api_type_pkg.t_medium_id
  , i_customer_number      in    com_api_type_pkg.t_name
  , i_lang                 in    com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor           out   sys_refcursor
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_object_limits: ';
    l_card_rec                   iss_api_type_pkg.t_card_rec;
    l_object_id                  com_api_type_pkg.t_medium_id;
    l_entity_type                com_api_type_pkg.t_dict_value;
    l_lang                       com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_card_number [#1], i_card_id [' || i_card_id
                     || '], i_account_id [' || i_account_id
                     || '], i_account_number [' || i_account_number || '], i_inst_id [' || i_inst_id
                     || '], i_customer_id [' || i_customer_id || '], i_customer_number [' || i_customer_number || ']'
      , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number)
    );

    if i_inst_id is null then
        com_api_error_pkg.raise_error(
            i_error => 'INSTITUTION_NOT_DEFINED'
        );
    end if;

    l_lang := coalesce(i_lang, get_user_lang());

    if i_card_id is not null or i_card_number is not null then
        l_card_rec := iss_api_card_pkg.get_card(
                          i_card_id     => i_card_id
                        , i_card_number => i_card_number
                        , i_mask_error  => com_api_type_pkg.FALSE
                      );
        if l_card_rec.inst_id != i_inst_id then
            trc_log_pkg.debug(
                i_text       => 'Card was found in institution [' || l_card_rec.inst_id
                             || '] but it belongs to institution [' || i_inst_id || ']'
            );
            com_api_error_pkg.raise_error(
                i_error      => 'CARD_IS_NOT_FOUND'
              , i_env_param1 => coalesce(
                                    i_card_id
                                  , iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
                                )
              , i_env_param2 => i_inst_id
            );
        end if;

        l_object_id   := l_card_rec.id;
        l_entity_type := iss_api_const_pkg.ENTITY_TYPE_CARD;

    elsif i_account_id is not null or i_account_number is not null then
        l_object_id := acc_api_account_pkg.get_account(
                           i_account_id     => i_account_id
                         , i_account_number => i_account_number
                         , i_inst_id        => i_inst_id
                         , i_mask_error     => com_api_type_pkg.FALSE
                       ).account_id;
        l_entity_type := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;

    elsif i_customer_id is not null or i_customer_number is not null then
        l_object_id := i_customer_id;
        check_customer_exists(
            i_customer_number => i_customer_number
          , i_inst_id         => i_inst_id
          , io_customer_id    => l_object_id
        );
        l_entity_type := prd_api_const_pkg.ENTITY_TYPE_CUSTOMER;

    else
        com_api_error_pkg.raise_error(
            i_error => 'ENTITY_OBJECT_IS_NOT_DEFINED'
        );
    end if;

    trc_log_pkg.debug(
        i_text => 'l_object_id [' || l_object_id
               || '], l_entity_type [' || l_entity_type
               || '], l_lang [' || l_lang || ']'
    );

    open o_ref_cursor for
        select a.entity_type
             , a.object_id
             , a.limit_type
             , com_api_dictionary_pkg.get_article_text(i_article => a.limit_type, i_lang => l_lang) as limit_name
             , a.limit_currency
             , a.count_value
             , a.sum_value
             , a.sum_limit
             , a.count_limit
             , a.last_reset_date
             , a.next_date
          from fcl_ui_limit_counter_vw a
         where a.object_id   = l_object_id
           and a.entity_type = l_entity_type;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'FAILED with i_card_id [' || i_card_id || '], i_card_number [#1], i_inst_id [' || i_inst_id
                   || '], i_account_id [' || i_account_id || '], i_account_number [' || i_account_number
                   || '], i_customer_id [' || i_customer_id || '], i_customer_number [' || i_customer_number || ']'
          , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number)
        );
        raise;
end get_object_limits;

procedure get_object_limits(
    i_card_number          in    com_api_type_pkg.t_name
  , i_card_uid             in    com_api_type_pkg.t_name
  , i_account_id           in    com_api_type_pkg.t_account_id
  , i_account_number       in    com_api_type_pkg.t_account_number
  , i_inst_id              in    com_api_type_pkg.t_inst_id
  , i_customer_id          in    com_api_type_pkg.t_medium_id
  , i_customer_number      in    com_api_type_pkg.t_name
  , i_lang                 in    com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor           out   sys_refcursor
) is
    l_card_id   com_api_type_pkg.t_medium_id;
begin
    if i_card_uid is null then
        l_card_id := null;
    else
        l_card_id := iss_api_card_pkg.get_card_id_by_uid(
                         i_card_uid => i_card_uid
                       , i_inst_id  => i_inst_id
                     );
    end if;

    get_object_limits(
        i_card_number          => i_card_number
      , i_card_id              => l_card_id
      , i_account_id           => i_account_id
      , i_account_number       => i_account_number
      , i_inst_id              => i_inst_id
      , i_customer_id          => i_customer_id
      , i_customer_number      => i_customer_number
      , i_lang                 => i_lang
      , o_ref_cursor           => o_ref_cursor
    );
end get_object_limits;

/*
 * Returns all authorization schemes for card's institution.
 * Start/end date are returned only for schemes that are defined directly for the card i_card_id/i_card_number and active currently.
 * @i_only_active    if TRUE then only active schemes for the card will be shown
 */
procedure get_card_auth_schemes(
    i_card_id              in    com_api_type_pkg.t_medium_id
  , i_card_number          in    com_api_type_pkg.t_name
  , i_only_active          in    com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_inst_id              in    com_api_type_pkg.t_inst_id      default null
  , i_lang                 in    com_api_type_pkg.t_dict_value   default null
  , o_ref_cursor           out   sys_refcursor
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_card_auth_schemes: ';
    l_lang                       com_api_type_pkg.t_dict_value;
    l_date                       date;
    l_card_rec                   iss_api_type_pkg.t_card_rec;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_card_id [' || i_card_id
                                   || '], i_card_number [#1], i_only_active [' || i_only_active || ']'
      , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number)
    );

    l_lang := coalesce(i_lang, get_user_lang());
    l_date := com_api_sttl_day_pkg.get_sysdate();

    l_card_rec := iss_api_card_pkg.get_card(
                      i_card_id     => i_card_id
                    , i_card_number => i_card_number
                    , i_inst_id     => i_inst_id
                    , i_mask_error  => com_api_type_pkg.FALSE
                  );
    trc_log_pkg.debug(LOG_PREFIX || 'card found, l_card_rec = {id [' || l_card_rec.id || '], inst_id [' || l_card_rec.inst_id || ']}');

    open o_ref_cursor for
        with subquery as (
            select s.id as scheme_id
                 , s.system_name
                 , case when so.id is not null
                         and l_date between nvl(so.start_date, l_date) and nvl(so.end_date, l_date)
                        then com_api_type_pkg.TRUE
                        else com_api_type_pkg.FALSE
                   end as is_active
                 , so.start_date
                 , so.end_date
              from      aup_scheme_vw s
              left join aup_scheme_object_vw so
                   on so.scheme_id   = s.id
                  and so.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                  and so.object_id   = l_card_rec.id
              where s.inst_id in (l_card_rec.inst_id, ost_api_const_pkg.DEFAULT_INST)
        )
        select distinct
               v.system_name
             , com_api_i18n_pkg.get_text(
                   i_table_name  => 'aup_scheme'
                 , i_column_name => 'label'
                 , i_object_id   => v.scheme_id
                 , i_lang        => l_lang
               ) as scheme_name
             , first_value(v.is_active)  over (partition by v.scheme_id order by v.is_active desc) as is_active
             , first_value(v.start_date) over (partition by v.scheme_id order by v.is_active desc, v.start_date desc) as start_date
             , first_value(v.end_date)   over (partition by v.scheme_id order by v.is_active desc, v.start_date desc) as end_date
          from subquery v
         where nvl(i_only_active, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
               or
               v.is_active = com_api_type_pkg.TRUE
        order by 3 desc, 1 desc, 4 desc;

    trc_log_pkg.debug(LOG_PREFIX || 'END ');
end get_card_auth_schemes;

procedure get_card_auth_schemes(
    i_card_uid             in    com_api_type_pkg.t_name
  , i_card_number          in    com_api_type_pkg.t_name
  , i_only_active          in    com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_inst_id              in    com_api_type_pkg.t_inst_id      default null
  , i_lang                 in    com_api_type_pkg.t_dict_value   default null
  , o_ref_cursor           out   sys_refcursor
) is
    l_card_id   com_api_type_pkg.t_medium_id;
begin
    if i_card_uid is null then
        l_card_id := null;
    else
        l_card_id := iss_api_card_pkg.get_card_id_by_uid(
                         i_card_uid => i_card_uid
                       , i_inst_id  => i_inst_id
                     );
    end if;

    get_card_auth_schemes(
        i_card_id              => l_card_id
      , i_card_number          => i_card_number
      , i_only_active          => i_only_active
      , i_inst_id              => i_inst_id
      , i_lang                 => i_lang
      , o_ref_cursor           => o_ref_cursor
    );
end get_card_auth_schemes;

procedure get_cardholder_data(
    i_card_number          in     com_api_type_pkg.t_card_number
  , i_card_id              in     com_api_type_pkg.t_medium_id    default null
  , i_inst_id              in     com_api_type_pkg.t_inst_id      default null
  , i_lang                 in     com_api_type_pkg.t_dict_value   default null
  , o_surname              out    com_api_type_pkg.t_name
  , o_first_name           out    com_api_type_pkg.t_name
  , o_second_name          out    com_api_type_pkg.t_name
  , o_gender               out    com_api_type_pkg.t_dict_value
  , o_birthday             out    date
  , o_cardholder_number    out    com_api_type_pkg.t_short_desc
  , o_cardholder_name      out    com_api_type_pkg.t_name
  , o_document_cursor      out    sys_refcursor
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_cardholder_data: ';
    l_cardholder_id               com_api_type_pkg.t_medium_id;
    l_card_id                     com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_card_id [' || i_card_id || '], i_card_number [#1], i_lang [' || i_lang || ']'
      , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number)
    );

    l_card_id := iss_api_card_pkg.get_card(
                     i_card_id     => i_card_id
                   , i_card_number => i_card_number
                   , i_inst_id     => i_inst_id
                   , i_mask_error  => com_api_type_pkg.FALSE
                 ).id;

    select v.cardholder_id
         , v.cardholder_number
         , v.cardholder_name
         , v.surname
         , v.first_name
         , v.second_name
         , v.gender
         , v.birthday
      into l_cardholder_id
         , o_cardholder_number
         , o_cardholder_name
         , o_surname
         , o_first_name
         , o_second_name
         , o_gender
         , o_birthday
      from (
          select ch.id as cardholder_id
               , p.surname
               , p.first_name
               , p.second_name
               , p.gender
               , p.birthday
               , ch.cardholder_number
               , ch.cardholder_name
            from iss_card c
            left join iss_cardholder_vw ch  on ch.id = c.cardholder_id
            left join com_person_vw p       on p.id = ch.person_id
           where c.id = l_card_id
        order by case p.lang
                     when coalesce(i_lang, com_ui_user_env_pkg.get_user_lang()) then 1
                     when com_api_const_pkg.DEFAULT_LANGUAGE                    then 2
                                                                                else 3
                 end
      ) v
     where rownum = 1;

    if l_cardholder_id is null then
        com_api_error_pkg.raise_error(
            i_error      => 'CARDHOLDER_NOT_FOUND'
          , i_env_param1 => case
                                when i_card_id is not null then
                                    'card_id = ' || i_card_id
                                else
                                    'card_mask = ' || iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
                            end
        );
    end if;

    open o_document_cursor for
        select d.id             as id_value
             , d.id_type        as id_type
             , i.name           as id_type_name
             , d.id_series      as id_series
             , d.id_number      as id_number
             , d.id_issuer      as id_issuer
             , d.id_issue_date  as id_issue_date
             , d.id_expire_date as id_expire_date
          from com_id_object_vw d
             , iss_cardholder_vw ch
             , iss_card_vw c
             , com_ui_dictionary_vw i
         where c.id             = l_card_id
           and ch.id            = c.cardholder_id
           and d.object_id      = ch.person_id
           and i.dict || i.code = d.id_type
           and i.lang           = nvl(i_lang, com_ui_user_env_pkg.get_user_lang())
           and (c.inst_id       = i_inst_id or i_inst_id is null);

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'CARD_NOT_FOUND'
          , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number)
          , i_env_param2 => i_card_id
        );
end get_cardholder_data;

procedure get_cardholder_data(
    i_card_number          in     com_api_type_pkg.t_card_number
  , i_card_uid             in     com_api_type_pkg.t_name         default null
  , i_inst_id              in     com_api_type_pkg.t_inst_id      default null
  , i_lang                 in     com_api_type_pkg.t_dict_value   default null
  , o_surname              out    com_api_type_pkg.t_name
  , o_first_name           out    com_api_type_pkg.t_name
  , o_second_name          out    com_api_type_pkg.t_name
  , o_gender               out    com_api_type_pkg.t_dict_value
  , o_birthday             out    date
  , o_cardholder_number    out    com_api_type_pkg.t_short_desc
  , o_cardholder_name      out    com_api_type_pkg.t_name
  , o_document_cursor      out    sys_refcursor
) is
    l_card_id   com_api_type_pkg.t_medium_id;
begin
    if i_card_uid is null then
        l_card_id := null;
    else
        l_card_id := iss_api_card_pkg.get_card_id_by_uid(
                         i_card_uid => i_card_uid
                       , i_inst_id  => i_inst_id
                     );
    end if;

    get_cardholder_data(
        i_card_number          => i_card_number
      , i_card_id              => l_card_id
      , i_inst_id              => i_inst_id
      , i_lang                 => i_lang
      , o_surname              => o_surname
      , o_first_name           => o_first_name
      , o_second_name          => o_second_name
      , o_gender               => o_gender
      , o_birthday             => o_birthday
      , o_cardholder_number    => o_cardholder_number
      , o_cardholder_name      => o_cardholder_name
      , o_document_cursor      => o_document_cursor
    );
end get_cardholder_data;

procedure get_cardholder_addresses(
    i_cardholder_id      in     com_api_type_pkg.t_medium_id
  , i_lang               in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor         out    sys_refcursor
) is
    l_lang              com_api_type_pkg.t_dict_value;
begin
    l_lang := nvl(i_lang, com_ui_user_env_pkg.get_user_lang());

    open o_ref_cursor for
        select o.address_type
             , com_api_dictionary_pkg.get_article_desc(i_article => o.address_type, i_lang => l_lang) as address_type_name
             , a.country
             , itf_ui_integration_pkg.get_country_name(i_code => a.country, i_lang => l_lang) as country_name
             , a.postal_code
             , a.region
             , a.city
             , a.street
             , a.house
             , a.apartment
          from iss_cardholder_vw ch
             , com_address_object o
             , com_address a
         where ch.id = i_cardholder_id
           and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
           and o.object_id = ch.id
           and a.id = o.address_id;

end get_cardholder_addresses;

procedure get_cardholder_documents(
    i_cardholder_id      in     com_api_type_pkg.t_medium_id
  , i_lang               in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor         out    sys_refcursor
) is
    l_lang              com_api_type_pkg.t_dict_value;
begin
    l_lang := nvl(i_lang, com_ui_user_env_pkg.get_user_lang());

    open o_ref_cursor for
        select d.id_type                                                        as type
             , com_api_dictionary_pkg.get_article_desc(d.id_type, 'LANGENG')    as type_name
             , d.id_series                                                      as series
             , d.id_number                                                      as "number"
             , d.id_issuer                                                      as issuer
             , d.id_issue_date                                                  as issue_date
             , d.id_expire_date                                                 as expire_date
             , com_api_i18n_pkg.get_text (i_table_name    => 'com_id_object',
                                          i_column_name   => 'DESCRIPTION',
                                          i_object_id     => d.id,
                                          i_lang          => l_lang)            as description
          from com_id_object_vw d
             , iss_cardholder_vw ch
         where ch.id = i_cardholder_id
           and d.object_id = ch.person_id;

end get_cardholder_documents;

procedure get_cardholder_contacts(
    i_cardholder_id      in     com_api_type_pkg.t_medium_id
  , i_lang               in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor         out    sys_refcursor
) is
    l_lang              com_api_type_pkg.t_dict_value;
begin
    l_lang := nvl(i_lang, com_ui_user_env_pkg.get_user_lang());

    open o_ref_cursor for
        select o.contact_type
             , com_api_dictionary_pkg.get_article_desc(o.contact_type, l_lang) contact_type_name
             , d.commun_method
             , com_api_dictionary_pkg.get_article_desc(d.commun_method, l_lang) commun_method_name
             , d.commun_address
          from iss_cardholder_vw ch
             , com_contact_object o
             , com_contact t
             , com_contact_data d
         where o.object_id = ch.id
           and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
           and t.id = o.contact_id
           and d.contact_id = o.contact_id
           and ch.id = i_cardholder_id;

end get_cardholder_contacts;

procedure get_cardholder_ext_data(
    i_cardholder_id        in     com_api_type_pkg.t_medium_id      default null
  , i_cardholder_number    in     com_api_type_pkg.t_name           default null
  , i_lang                 in     com_api_type_pkg.t_dict_value     default null
  , i_inst_id              in     com_api_type_pkg.t_inst_id        default null
  , o_surname              out    com_api_type_pkg.t_name
  , o_first_name           out    com_api_type_pkg.t_name
  , o_second_name          out    com_api_type_pkg.t_name
  , o_gender               out    com_api_type_pkg.t_dict_value
  , o_birthday             out    date
  , o_cardholder_number    out    com_api_type_pkg.t_short_desc
  , o_cardholder_name      out    com_api_type_pkg.t_name
  , o_document_cursor      out    sys_refcursor
  , o_address_cursor       out    sys_refcursor
  , o_contact_cursor       out    sys_refcursor
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_cardholder_ext_data: ';
    l_cardholder_id               com_api_type_pkg.t_medium_id;
    l_cardholder_number           com_api_type_pkg.t_name;
    l_inst_id                     com_api_type_pkg.t_inst_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_cardholder_id [' || i_cardholder_id ||
                        '], i_cardholder_number [' || i_cardholder_number ||
                        '], i_lang [' || i_lang || ']' ||
                        '], i_inst_id [' || i_inst_id || ']'
    );

    if i_cardholder_id is not null then
        select ch.cardholder_number
             , ch.inst_id
          into l_cardholder_number
             , l_inst_id
          from iss_cardholder_vw ch
         where ch.id = i_cardholder_id
           and rownum = 1;
    end if;

    if i_cardholder_number is not null and i_inst_id is not null then
        select ch.id
          into l_cardholder_id
          from iss_cardholder_vw ch
         where ch.cardholder_number = i_cardholder_number
           and ch.inst_id = i_inst_id
           and rownum = 1;
    end if;

    if (i_cardholder_number is not null and l_cardholder_id != nvl(i_cardholder_id, l_cardholder_id))
        or (i_cardholder_id is not null and l_cardholder_number != nvl(i_cardholder_number, l_cardholder_number))
    then
        com_api_error_pkg.raise_error(
            i_error      => 'CARDHOLDER_ID_AND_NUMBER_MISMATCH'
            , i_env_param1 => l_cardholder_id
            , i_env_param2 => i_cardholder_number
            , i_env_param3 => i_inst_id
        );
    elsif l_cardholder_id is null then
        l_cardholder_id := i_cardholder_id;
    end if;

    if l_cardholder_id is null then
        com_api_error_pkg.raise_error(
            i_error      => 'CARDHOLDER_NOT_FOUND'
            , i_env_param1 => i_cardholder_id
            , i_env_param2 => i_cardholder_number
            , i_env_param3 => i_inst_id
        );
    end if;

    select v.cardholder_number
         , v.cardholder_name
         , v.surname
         , v.first_name
         , v.second_name
         , v.gender
         , v.birthday
      into o_cardholder_number
         , o_cardholder_name
         , o_surname
         , o_first_name
         , o_second_name
         , o_gender
         , o_birthday
      from (
             select p.surname
                  , p.first_name
                  , p.second_name
                  , p.gender
                  , p.birthday
                  , ch.cardholder_name
                  , ch.cardholder_number
               from iss_cardholder_vw ch
          left join com_person_vw p on p.id = ch.person_id
              where ch.id = l_cardholder_id
           order by case p.lang
                        when coalesce(i_lang, com_ui_user_env_pkg.get_user_lang()) then 1
                        when com_api_const_pkg.DEFAULT_LANGUAGE                    then 2
                        else 3
                    end
          ) v
    where rownum = 1;

    if o_cardholder_number is null then
        com_api_error_pkg.raise_error(
            i_error      => 'CARDHOLDER_NOT_FOUND'
            , i_env_param1 => i_cardholder_id
            , i_env_param2 => i_cardholder_number
            , i_env_param3 => i_inst_id
        );
    end if;


    get_cardholder_documents(l_cardholder_id, i_lang, o_document_cursor);
    get_cardholder_addresses(l_cardholder_id, i_lang, o_address_cursor);
    get_cardholder_contacts(l_cardholder_id, i_lang, o_contact_cursor);

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'CARDHOLDER_NOT_FOUND'
            , i_env_param1 => i_cardholder_id
            , i_env_param2 => i_cardholder_number
            , i_env_param3 => i_inst_id
        );
end get_cardholder_ext_data;

procedure get_last_invoice(
    i_account_number       in    com_api_type_pkg.t_name
    , i_inst_id            in    com_api_type_pkg.t_inst_id
    , o_ref_cursor         out   sys_refcursor
) is
    l_account_id        com_api_type_pkg.t_account_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_invoice_id        com_api_type_pkg.t_account_id;
begin
    select id
         , split_hash
      into l_account_id
         , l_split_hash
      from acc_account
     where account_number = i_account_number
       and inst_id = i_inst_id;

    l_invoice_id := crd_invoice_pkg.get_last_invoice_id(
        i_account_id       => l_account_id
        , i_split_hash     => l_split_hash
        , i_mask_error     => com_api_const_pkg.TRUE
    );

    open o_ref_cursor for
       select a.account_number
            , a.currency
            , i.id
            , i.account_id
            , i.serial_number
            , i.invoice_date
            , i.invoice_type
            , i.min_amount_due
            , i.total_amount_due
            , i.own_funds
            , i.exceed_limit
            , i.start_date
            , i.due_date
            , i.grace_date
            , i.penalty_date
            , i.is_mad_paid
            , i.is_tad_paid
            , i.aging_period
            , i.agent_id
            , i.inst_id
         from crd_invoice i
            , acc_account a
        where i.account_id = a.id
          and i.id = l_invoice_id;

exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error                 => 'ACCOUNT_NOT_FOUND'
            , i_env_param1          => i_account_number
            , i_env_param2          => i_inst_id
        );
end;

procedure get_credit_statement(
    o_xml                  out   clob
    , i_account_number     in    com_api_type_pkg.t_name
    , i_inst_id            in    com_api_type_pkg.t_inst_id
    , i_lang               in    com_api_type_pkg.t_dict_value
) is
    l_account_id        com_api_type_pkg.t_account_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_invoice_id        com_api_type_pkg.t_account_id;

    procedure get_report (
        o_xml                   out clob
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_invoice_id          in com_api_type_pkg.t_medium_id
    ) is
        l_header                xmltype;
        l_detail                xmltype;
        l_result                xmltype;

        l_account_id            com_api_type_pkg.t_account_id;
        l_invoice_date          date;
        l_start_date            date;
        l_lag_invoice           crd_api_type_pkg.t_invoice_rec;
        l_currency_id           com_api_type_pkg.t_tiny_id;
        l_currency              com_api_type_pkg.t_dict_value;
        l_currency_name         com_api_type_pkg.t_dict_value;
        l_sysdate               date;

    begin
        trc_log_pkg.debug (
            i_text          => 'Run statement report [#1] [#2]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_invoice_id
        );

        l_lag_invoice := null;
        l_sysdate := com_api_sttl_day_pkg.get_sysdate();

        begin
            select
                account_id
                , invoice_date
            into
                l_account_id
                , l_invoice_date
            from
                crd_invoice_vw
            where
                id = i_invoice_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error         => 'INVOICE_NOT_FOUND'
                    , i_env_param1  => i_invoice_id
                );
        end;

        select currency
          into l_currency
          from acc_account
         where id = l_account_id;

        -- get previous invoice
        begin
            select
                i1.id
                , i1.account_id
                , i1.serial_number
                , i1.invoice_type
                , i1.exceed_limit
                , i1.total_amount_due
                , i1.own_funds
                , i1.min_amount_due
                , i1.invoice_date
                , i1.grace_date
                , i1.due_date
                , i1.penalty_date
                , i1.aging_period
                , i1.is_tad_paid
                , i1.is_mad_paid
                , i1.inst_id
                , i1.agent_id
                , i1.split_hash
                , i1.overdue_date
                , i1.start_date
            into
                l_lag_invoice
            from
                crd_invoice_vw i1
                , ( select
                        a.id
                        , lag(a.id) over (order by a.invoice_date) lag_id
                    from
                        crd_invoice_vw a
                    where
                        a.account_id = l_account_id
                ) i2
            where
                i1.id = i2.lag_id
                and i2.id = i_invoice_id;
        exception
            when no_data_found then
                trc_log_pkg.debug (
                    i_text  => 'Previous invoice not found'
                );
        end;

        -- calc start date
        if l_lag_invoice.id is null then
            begin
                select
                    o.start_date
                into
                    l_start_date
                from
                    prd_service_object o
                    , prd_service s
                where
                    o.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                    and object_id = l_account_id
                    and s.id = o.service_id
                    and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error (
                        i_error         => 'ACCOUNT_SERVICE_NOT_FOUND'
                        , i_env_param1  => l_account_id
                        , i_env_param2  => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                    );
            end;
        else
            l_start_date := l_lag_invoice.invoice_date;
        end if;

        select id
             , name
          into l_currency_id
             , l_currency_name
          from com_currency
         where code = l_currency;

        -- header
        select
            xmlconcat(
                xmlelement( "customer_number", t.customer_number )
              , xmlelement( "account_number", t.account_number )
              , xmlelement( "account_currency", l_currency_name)
              , (
                select
                     xmlagg(
                           xmlelement("customer_name"
                               , com_ui_person_pkg.get_person_name(
                                     i_person_id => p.id
                                   , i_lang      => p.lang
                                 )
                           )
                     )
                    from (select id, min(lang) keep(dense_rank first order by decode(lang, i_lang, 1, 'LANGENG', 2, 3)) lang
                           from com_person group by id
                        ) p2
                      , com_person p
                  where p2.id  = t.object_id
                    and p.id   = p2.id
                    and p.lang = p2.lang
              )
              , (
                select xmlelement("delivery_address"
                           , com_api_address_pkg.get_address_string(
                                 i_address_id        => a.id
                               , i_lang              => i_lang
                               , i_inst_id           => a.inst_id
                               , i_enable_empty      => com_api_const_pkg.FALSE
                             )
                       )
                      from com_address_object o
                         , com_address a
                     where o.entity_type = 'ENTTCUST'
                       and o.object_id   = t.customer_id
                       and a.id          = o.address_id
                       and a.lang        = i_lang
                       and rownum        = 1
              )
              , xmlelement( "start_date", to_char(start_date, 'dd/mm/yyyy') )
              , xmlelement( "invoice_date", to_char(invoice_date, 'dd/mm/yyyy') )
              , xmlelement( "min_amount_due", com_api_currency_pkg.get_amount_str(nvl(min_amount_due, 0), l_currency, com_api_const_pkg.TRUE))
              , xmlelement( "due_date", to_char(due_date, 'dd/mm/yyyy'))
              , xmlelement( "credit_limit", com_api_currency_pkg.get_amount_str(nvl(credit_limit, 0), l_currency, com_api_const_pkg.TRUE))
              , xmlelement( "incoming_balance", com_api_currency_pkg.get_amount_str(nvl(incoming_balance, 0), l_currency, com_api_const_pkg.TRUE))
              , xmlelement( "payment_amount", com_api_currency_pkg.get_amount_str(nvl(payment_amount, 0), l_currency, com_api_const_pkg.TRUE))
              , xmlelement( "expense_amount", com_api_currency_pkg.get_amount_str(nvl(expense_amount, 0), l_currency, com_api_const_pkg.TRUE))
              , xmlelement( "interest_amount", com_api_currency_pkg.get_amount_str(nvl(interest_amount, 0), l_currency, com_api_const_pkg.TRUE))
              , xmlelement( "fee_amount", com_api_currency_pkg.get_amount_str(nvl(fee_amount, 0), l_currency, com_api_const_pkg.TRUE))
              , xmlelement( "total_amount_due", com_api_currency_pkg.get_amount_str(nvl(total_amount_due, 0), l_currency, com_api_const_pkg.TRUE))
              , xmlelement( "own_funds", com_api_currency_pkg.get_amount_str(nvl(own_funds, 0), l_currency, com_api_const_pkg.TRUE))
              , xmlelement( "hold_balance", com_api_currency_pkg.get_amount_str(nvl(hold_balance, 0), l_currency, com_api_const_pkg.TRUE))
              , xmlelement( "available_balance", com_api_currency_pkg.get_amount_str(nvl(available_balance, 0), l_currency, com_api_const_pkg.TRUE))
              , xmlelement( "outgoing_balance", com_api_currency_pkg.get_amount_str((nvl(total_amount_due, 0)- nvl(own_funds, 0)), l_currency, com_api_const_pkg.TRUE))
              , xmlelement( "grace_date", to_char(grace_date, 'dd/mm/yyyy') )
              , xmlelement( "penalty_date", to_char(penalty_date, 'dd/mm/yyyy') )
              , xmlelement( "aging_period", aging_period )
              , xmlelement( "is_tad_paid", is_tad_paid )
              , xmlelement( "is_mad_paid", is_mad_paid )
              , xmlelement( "statement_date", to_char(l_sysdate, 'dd/mm/yyyy') )
              , xmlelement( "overdue_balance", com_api_currency_pkg.get_amount_str(nvl(overdue_balance, 0), l_currency, com_api_const_pkg.TRUE))
              , xmlelement( "overdue_intr_balance", com_api_currency_pkg.get_amount_str(nvl(overdue_intr_balance, 0), l_currency, com_api_const_pkg.TRUE))
              , xmlelement( "serial_number", serial_number )
            )
        into l_header
        from (
            select
                c.customer_number
                , a.account_number
                , c.object_id
                , c.id customer_id
                , i.start_date
                , i.invoice_date
                , i.min_amount_due
                , i.due_date
                , i.exceed_limit credit_limit
                , nvl(l_lag_invoice.total_amount_due, 0) incoming_balance
                , i.payment_amount
                , (i.expense_amount - i.fee_amount) expense_amount
                , i.interest_amount
                , i.fee_amount
                , i.total_amount_due
                , i.own_funds
                , i.hold_balance
                , i.available_balance
                , i.grace_date
                , i.penalty_date
                , i.aging_period
                , i.is_tad_paid
                , i.is_mad_paid
                , i.overdue_balance
                , i.overdue_intr_balance
                , i.serial_number
            from
                crd_invoice_vw i
                , acc_account_vw a
                , prd_customer_vw c
            where
                i.id = i_invoice_id
                and a.id = i.account_id
                and c.id(+) = a.customer_id
                and c.entity_type(+) = com_api_const_pkg.ENTITY_TYPE_PERSON
        ) t;

        begin

            -- details
            select
                xmlelement("operations",
                    xmlagg(
                        xmlelement( "operation"
                        , xmlelement( "card_mask", card_mask)
                        , xmlelement( "oper_category", oper_category)
                        , xmlelement( "oper_date", to_char(oper_date, 'dd.mm.yyyy hh24:mi:ss'))
                        , xmlelement( "posting_date", to_char(posting_date, 'dd.mm.yyyy'))
                        , xmlelement( "oper_amount", com_api_currency_pkg.get_amount_str(oper_amount, oper_currency, com_api_type_pkg.TRUE))
                        , xmlelement( "oper_currency", oper_currency_name)
                        , xmlelement( "posting_amount", com_api_currency_pkg.get_amount_str(account_amount, account_currency, com_api_type_pkg.TRUE))
                        , xmlelement( "posting_currency", account_currency_name)
                        , xmlelement( "oper_type", oper_type)
                        , xmlelement( "oper_type_name", oper_type_name)
                        , xmlelement( "merchant_name", merchant_name)
                        , xmlelement( "merchant_street", merchant_street)
                        , xmlelement( "merchant_city", merchant_city)
                        , xmlelement( "merchant_country", merchant_country)
                        , xmlelement( "oper_id", oper_id)
                        , xmlelement( "fee_type", fee_type)
                        , xmlelement( "fee_type_name", com_api_dictionary_pkg.get_article_text(fee_type, i_lang))
                       )
                        order by oper_category
                    )
                )
             into l_detail
             from (
                select (select card_mask from iss_card where id = d.card_id) card_mask
                     , 'EXPENSE' oper_category
                     , o.oper_date
                     , d.posting_date
                     , o.oper_amount
                     , o.oper_currency
                     , cr2.name oper_currency_name
                     , d.amount account_amount
                     , d.currency account_currency
                     , cr.name account_currency_name
                     , o.oper_type
                     , com_api_dictionary_pkg.get_article_text(o.oper_type, i_lang) oper_type_name
                     , o.merchant_name
                     , o.merchant_street
                     , o.merchant_city
                     , r.name merchant_country
                     , d.fee_type
                     , d.card_id
                     , o.id oper_id
                     , d.id debt_id
                  from (
                      select distinct debt_id
                        from crd_invoice_debt_vw
                       where invoice_id = i_invoice_id
                         and is_new = com_api_type_pkg.TRUE
                        ) e
                        , crd_debt d
                        , opr_operation o
                        , opr_participant p
                        , com_country r
                        , com_currency cr
                        , com_currency cr2
                    where d.id = e.debt_id
                      and d.oper_id = o.id(+)
                      and p.oper_id(+) = o.id
                      and p.participant_type(+) = 'PRTYISS'
                      and d.oper_type != opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE --'OPTP0119'
                      and o.merchant_country = r.code(+)
                      and d.currency = cr.code(+)
                      and o.oper_currency = cr2.code(+)
                     union all
                    select (select card_mask from iss_card where id = d.card_id) card_mask
                         , 'FEE' oper_category
                         , o.oper_date
                         , d.posting_date
                         , o.oper_amount
                         , o.oper_currency
                         , cr2.name oper_currency_name
                         , d.amount account_amount
                         , d.currency account_currency
                         , cr.name account_currency_name
                         , o.oper_type
                         , com_api_dictionary_pkg.get_article_text(o.oper_type, i_lang) oper_type_name
                         , o.merchant_name
                         , o.merchant_street
                         , o.merchant_city
                         , r.name merchant_country
                         , d.fee_type
                         , d.card_id
                         , o.id oper_id
                         , d.id
                      from (
                           select distinct debt_id
                             from crd_invoice_debt_vw
                            where invoice_id = i_invoice_id
                              and is_new = com_api_type_pkg.TRUE
                            ) e
                            , crd_debt d
                            , opr_operation o
                            , opr_participant p
                            , com_country r
                            , com_currency cr
                            , com_currency cr2
                        where d.id = e.debt_id
                          and d.oper_id = o.id(+)
                          and p.oper_id(+) = o.id
                          and p.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
                          and d.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE--'OPTP0119'
                          and o.merchant_country = r.code(+)
                          and d.currency = cr.code(+)
                          and o.oper_currency = cr2.code(+)
                    union all
                    select (select card_mask from iss_card where id = m.card_id) card_mask
                         , 'PAYMENT' oper_category
                         , o.oper_date
                         , m.posting_date
                         , o.oper_amount
                         , o.oper_currency
                         , cr2.name oper_currency_name
                         , m.amount account_amount
                         , m.currency account_currency
                         , cr.name account_currency_name
                         , o.oper_type
                         , com_api_dictionary_pkg.get_article_text(o.oper_type, i_lang) oper_type_name
                         , o.merchant_name
                         , o.merchant_street
                         , o.merchant_city
                         , r.name merchant_country
                         , null fee_type
                         , m.card_id
                         , o.id oper_id
                         , null debt_id
                     from crd_invoice_payment p
                         , crd_payment m
                         , opr_operation o
                         , opr_participant iss
                         , com_country r
                         , com_currency cr
                         , com_currency cr2
                     where p.invoice_id = i_invoice_id
                       and p.is_new = com_api_type_pkg.TRUE
                       and m.id = p.pay_id
                       and m.oper_id = o.id(+)
                       and iss.oper_id(+) = o.id
                       and iss.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
                       and o.merchant_country = r.code(+)
                       and m.currency = cr.code(+)
                       and o.oper_currency = cr2.code(+)
                ) t;
        exception
            when no_data_found then
                trc_log_pkg.debug (
                    i_text  => 'Operations not found'
                );
        end;

        select
            xmlelement (
                "report"
                , l_header
                , l_detail
            ) r
        into
            l_result
        from
            dual;

        o_xml := l_result.getclobval();

    end get_report;
begin
    select id
         , split_hash
      into l_account_id
         , l_split_hash
      from acc_account
     where account_number = i_account_number
       and inst_id = i_inst_id;

    l_invoice_id := crd_invoice_pkg.get_last_invoice_id(
        i_account_id       => l_account_id
        , i_split_hash     => l_split_hash
        , i_mask_error     => com_api_const_pkg.TRUE
    );

    get_report (
        o_xml             => o_xml
        , i_lang          => i_lang
        , i_invoice_id    => l_invoice_id
    );

exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error                 => 'ACCOUNT_NOT_FOUND'
            , i_env_param1          => i_account_number
            , i_env_param2          => i_inst_id
        );
end;

procedure get_flex_fields(
    i_entity_type          in    com_api_type_pkg.t_dict_value
    , i_object_id          in    com_api_type_pkg.t_long_id
    , i_lang               in    com_api_type_pkg.t_dict_value
    , o_ref_cursor         out   sys_refcursor
) is
    l_lang                       com_api_type_pkg.t_dict_value;
begin
    l_lang := coalesce(i_lang, get_user_lang());

    open o_ref_cursor for
        select d.id
             , d.field_id
             , f.entity_type
             , f.object_type
             , get_number_value (f.data_type, f.DEFAULT_VALUE) default_number_value
             , get_char_value (f.data_type, f.DEFAULT_VALUE) default_char_value
             , get_date_value (f.data_type, f.DEFAULT_VALUE) default_date_value
             , get_lov_value (f.data_type, f.DEFAULT_VALUE, f.lov_id) default_lov_value
             , f.is_user_defined
             , f.inst_id
             , get_text ('ost_institution', 'name', f.inst_id, l_lang) inst_name
          from com_flexible_field f
             , com_flexible_data d
         where f.id = d.field_id
           and f.entity_type = i_entity_type
           and d.object_id = i_object_id;
end;

procedure get_object_cycles (
    i_entity_type  in  com_api_type_pkg.t_dict_value
  , i_object_id    in  com_api_type_pkg.t_long_id
  , o_ref_cursor   out sys_refcursor
) is
    l_obj_find_sql     com_api_type_pkg.t_lob_data;
    l_count            com_api_type_pkg.t_count := 0;
    l_product_id       com_api_type_pkg.t_short_id;
begin
    begin
        select
            'select count(*) from ' || e.table_name || ' where id = :1'
        into
            l_obj_find_sql
        from
            adt_entity e
        where
            e.entity_type = i_entity_type;
    exception
        when no_data_found then
           com_api_error_pkg.raise_error (
               i_error                 => 'ENTITY_TYPE_NOT_FOUND'
               , i_env_param1          => i_entity_type
           );
    end;

    execute immediate l_obj_find_sql into l_count using i_object_id;
    if l_count = 0 then
       com_api_error_pkg.raise_error (
           i_error                 => 'OBJECT_NOT_FOUND'
           , i_env_param1          => i_entity_type
           , i_env_param2          => i_object_id
       );
    end if;

    l_product_id := prd_api_product_pkg.get_product_id(
        i_entity_type      => i_entity_type
      , i_object_id        => i_object_id
    );

    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        open o_ref_cursor for
            select
                cycle_type
              , cycle_type_description
              , prev_date
              , next_date
              , cycle_id
              , cycle_description
              , entity_type
              , entity_description
            from (
                select
                    pa.attr_object_type as cycle_type
                  , com_api_dictionary_pkg.get_article_text(pa.attr_object_type) as cycle_type_description
                  , cc.prev_date
                  , cc.next_date
                  , to_number(pa.attr_value, get_number_format) as cycle_id
                  , fcl_ui_cycle_pkg.get_cycle_desc(to_number(pa.attr_value, get_number_format)) as cycle_description
                  , so.entity_type
                  , com_api_dictionary_pkg.get_article_text(so.entity_type) as entity_description
                  , row_number() over (partition by pa.attr_id order by nvl(pa.mod_id, 0), pa.start_date desc, pa.register_timestamp desc) as rn
                from
                    prd_service_object so
                inner join
                    prd_contract c
                on
                    c.id                = so.contract_id                              and
                    sysdate between c.start_date and nvl(c.end_date, sysdate)
                inner join
                    --prd_product_attribute_mvw pa
                    (select a.entity_type attr_entity_type
                          , a.object_type attr_object_type
                          , v.attr_value
                          , v.mod_id
                          , v.start_date
                          , v.end_date
                          , v.attr_id
                          , v.register_timestamp
                          , p.product_id
                          , s.id service_id
                       from (
                            select connect_by_root id product_id
                                 , level level_priority
                                 , id parent_id
                                 , product_type
                                 , case when parent_id is null then 1 else 0 end top_flag
                              from prd_product
                             connect by prior parent_id = id
                               start with id = l_product_id
                           ) p
                          , prd_attribute_value v
                          , prd_attribute a
                          , prd_service s
                          , rul_mod m
                          , prd_product_service ps
                      where ps.product_id     = p.product_id
                        and ps.service_id     = s.id
                        and v.service_id      = s.id
                        and a.service_type_id = s.service_type_id
                        and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                        and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                        and v.attr_id         = a.id
                        and v.mod_id          = m.id(+)
                        and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_CYCLE
                     ) pa
                on
                    pa.service_id       = so.service_id                               and
                    sysdate       between pa.start_date and nvl(pa.end_date, sysdate) and
                    --pa.attr_entity_type = fcl_api_const_pkg.ENTITY_TYPE_CYCLE         and
                    pa.product_id       = c.product_id
                inner join
                    (select
                         max(id) keep (dense_rank last order by seq_number) as id
                     from
                         iss_card_instance
                     where
                         card_id = i_object_id and
                         status  = iss_api_const_pkg.CARD_STATUS_VALID_CARD) ci
                on
                    1 = 1
                left join
                    fcl_cycle_counter cc
                on
                    cc.entity_type      = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE and
                    cc.object_id        = ci.id                                       and
                    cc.cycle_type       = pa.attr_object_type
                where
                    so.entity_type      = iss_api_const_pkg.ENTITY_TYPE_CARD          and
                    so.object_id        = i_object_id                                 and
                    sysdate    between    so.start_date and nvl(so.end_date, sysdate) and
                    so.status           = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
            ) where
                rn = 1;
    elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        open o_ref_cursor for
            select
                cycle_type
              , cycle_type_description
              , prev_date
              , next_date
              , cycle_id
              , cycle_description
              , entity_type
              , entity_description
            from (
                select
                    pa.attr_object_type as cycle_type
                  , com_api_dictionary_pkg.get_article_text(pa.attr_object_type) as cycle_type_description
                  , cc.prev_date
                  , cc.next_date
                  , to_number(pa.attr_value, get_number_format) as cycle_id
                  , fcl_ui_cycle_pkg.get_cycle_desc(to_number(pa.attr_value, get_number_format)) as cycle_description
                  , so.entity_type
                  , com_api_dictionary_pkg.get_article_text(so.entity_type) as entity_description
                  , row_number() over (partition by pa.attr_id order by nvl(pa.mod_id, 0), pa.start_date desc, pa.register_timestamp desc) as rn
                from
                    prd_service_object so
                inner join
                    prd_contract c
                on
                    c.id                = so.contract_id                              and
                    sysdate       between c.start_date and nvl(c.end_date, sysdate)
                inner join
                    --prd_product_attribute_mvw pa
                    (select a.entity_type attr_entity_type
                          , a.object_type attr_object_type
                          , v.attr_value
                          , v.mod_id
                          , v.start_date
                          , v.end_date
                          , v.attr_id
                          , v.register_timestamp
                          , p.product_id
                          , s.id service_id
                       from (
                            select connect_by_root id product_id
                                 , level level_priority
                                 , id parent_id
                                 , product_type
                                 , case when parent_id is null then 1 else 0 end top_flag
                              from prd_product
                             connect by prior parent_id = id
                               start with id = l_product_id
                           ) p
                          , prd_attribute_value v
                          , prd_attribute a
                          , prd_service s
                          , rul_mod m
                          , prd_product_service ps
                      where ps.product_id     = p.product_id
                        and ps.service_id     = s.id
                        and v.service_id      = s.id
                        and a.service_type_id = s.service_type_id
                        and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                        and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                        and v.attr_id         = a.id
                        and v.mod_id          = m.id(+)
                        and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_CYCLE
                     ) pa
                on
                    pa.service_id       = so.service_id                               and
                    sysdate       between pa.start_date and nvl(pa.end_date, sysdate) and
                    --pa.attr_entity_type = fcl_api_const_pkg.ENTITY_TYPE_CYCLE         and
                    pa.product_id       = c.product_id
                left join
                    fcl_cycle_counter cc
                on
                    cc.entity_type      = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT       and
                    cc.object_id        = i_object_id                                 and
                    cc.cycle_type       = pa.attr_object_type
                where
                    so.entity_type      = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT       and
                    so.object_id        = i_object_id                                 and
                    sysdate       between so.start_date and nvl(so.end_date, sysdate) and
                    so.status           = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
            ) where
                rn = 1
            union all
                select
                    cc.cycle_type
                  , com_api_dictionary_pkg.get_article_text(cc.cycle_type) as cycle_type_description
                  , cc.prev_date
                  , cc.next_date
                  , null as cycle_id
                  , fcl_ui_cycle_pkg.get_cycle_desc(null) as cycle_description
                  , cc.entity_type
                  , com_api_dictionary_pkg.get_article_text(cc.entity_type) as entity_description
                from
                    fcl_cycle_counter_vw cc
                  , (select
                         max(id) keep (dense_rank last order by serial_number) as id
                     from
                         crd_invoice
                     where
                         account_id = i_object_id) inv
                where
                    cc.entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE and
                    cc.object_id   = inv.id;
    else
        open o_ref_cursor for
            select
                cc.cycle_type
              , com_api_dictionary_pkg.get_article_text(cc.cycle_type) as cycle_type_description
              , cc.prev_date
              , cc.next_date
              , null as cycle_id
              , fcl_ui_cycle_pkg.get_cycle_desc(null) as cycle_description
              , cc.entity_type
              , com_api_dictionary_pkg.get_article_text(cc.entity_type) as entity_description
            from
                fcl_cycle_counter_vw cc
            where
                cc.entity_type = i_entity_type and
                cc.object_id   = i_object_id;
    end if;
end get_object_cycles;

function get_available_balance_amount(
    i_account_id           in     com_api_type_pkg.t_account_id
  , i_oper_id              in     com_api_type_pkg.t_long_id
  , i_host_date            in     date
  , i_currency             in     com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_money
is
    l_posting_date         date;
    l_balance_amount       com_api_type_pkg.t_money;
    l_balance              com_api_type_pkg.t_amount_rec;
    l_rate_type            com_api_type_pkg.t_dict_value;
    l_inst_id              com_api_type_pkg.t_inst_id;
begin
    -- Posting date of account entries differ from original operation's host date, so that it is necessary
    -- to find posting date of any macros for correct balance calculating. Otherwise, the function returns
    -- available balance BEFORE the operation but not AFTER it.

    select min(m.posting_date)
      into l_posting_date
      from acc_macros_vw m
     where m.account_id = i_account_id
       and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and m.object_id = i_oper_id;

    if l_posting_date is null then
        l_posting_date := i_host_date;
    end if;

--    trc_log_pkg.debug(
--        i_text       => lower($$PLSQL_UNIT) || '.get_available_balance_amount: '
--                     || 'i_account_id [#1], i_oper_id [#2], i_host_date [#3]'
--      , i_env_param1 => i_account_id
--      , i_env_param2 => i_oper_id
--      , i_env_param3 => i_host_date
--    );
    l_balance := acc_api_balance_pkg.get_aval_balance_amount(
               i_account_id => i_account_id
             , i_date       => l_posting_date
             , i_date_type  => com_api_const_pkg.DATE_PURPOSE_PROCESSING
             , i_mask_error => com_api_type_pkg.FALSE
           );

    if nvl(i_currency, l_balance.currency) = l_balance.currency then
        l_balance_amount := l_balance.amount;
    else
        begin
            select a.inst_id, bt.rate_type
              into l_inst_id, l_rate_type
              from acc_account a
                 , acc_balance_type bt
             where a.account_type = bt.account_type
               and bt.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and a.id = i_account_id
               and a.inst_id = bt.inst_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error             => 'RATE_TYPE_NOT_FOUND'
                );
        end;

        l_balance_amount := round(com_api_rate_pkg.convert_amount(
                                      i_src_amount      => l_balance.amount
                                    , i_src_currency    => l_balance.currency
                                    , i_dst_currency    => i_currency
                                    , i_rate_type       => l_rate_type
                                    , i_inst_id         => l_inst_id
                                    , i_eff_date        => get_sysdate()
                                    , i_mask_exception  => com_api_type_pkg.FALSE
                                    , i_exception_value => null
                                    , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_SELLING
                                  ));
    end if;

    return l_balance_amount;
end get_available_balance_amount;

procedure get_account_details(
    i_account_id           in    com_api_type_pkg.t_account_id
  , i_account_number       in    com_api_type_pkg.t_account_number
  , i_inst_id              in    com_api_type_pkg.t_inst_id
  , i_lang                 in    com_api_type_pkg.t_dict_value     default null
  , o_ref_cursor           out   sys_refcursor
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_account_details: ';
    l_account_id                 com_api_type_pkg.t_account_id;
    l_lang                       com_api_type_pkg.t_dict_value;
begin
    l_lang := coalesce(i_lang, get_user_lang());

    l_account_id := acc_api_account_pkg.get_account(
                        i_account_id     => i_account_id
                      , i_account_number => i_account_number
                      , i_inst_id        => i_inst_id
                      , i_mask_error     => com_api_type_pkg.FALSE
                    ).account_id;

    trc_log_pkg.debug(LOG_PREFIX || 'l_account_id [' || l_account_id || '], l_lang [' || l_lang || ']');

    open o_ref_cursor for
        with main_select as (
            select
                a.id as account_id
              , a.account_number
              , a.account_type
              , com_api_dictionary_pkg.get_article_desc(a.account_type, l_lang) as account_type_name
              , a.currency
              , a.status
              , com_api_dictionary_pkg.get_article_desc(a.status, l_lang) as status_name
              , com_api_currency_pkg.get_amount_str(acc_api_balance_pkg.get_aval_balance_amount_only(a.id), a.currency, 1, 'FM999999999999999990.0099') as available_balance
              , a.agent_id
              , com_api_i18n_pkg.get_text('ost_agent', 'name', a.agent_id, l_lang) as agent_name
              , ag.agent_number
              , prd.product_number
            from
                acc_account_vw a
              , ost_agent_vw ag
              , prd_contract_vw cntr
              , prd_product_vw prd
            where
                ag.id   = a.agent_id      and
                cntr.id = a.contract_id   and
                prd.id  = cntr.product_id and
                a.id    = l_account_id
        ),
        status_change as (
            select
                h.account_id
              , h.reason
              , h.change_date
              , u.name as change_user
              , h.prev_state
            from
                (select
                     ms.account_id
                   , sl.reason
                   , sl.change_date
                   , sl.user_id
                   , lag(sl.status) over (partition by ms.account_id order by sl.change_date) as prev_state
                   , row_number() over (partition by ms.account_id order by sl.change_date desc) as rn
                 from
                     main_select ms
                   , evt_status_log sl
                 where
                     sl.object_id   = ms.account_id and
                     sl.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                ) h
              , acm_user_vw u
            where
                u.id = h.user_id and
                h.rn = 1
        ),
        first_application as (
            select
                ms.account_id
              , max(ah.change_date) keep (dense_rank first order by ah.change_date) as change_date
            from
                main_select ms
              , app_object o
              , app_history_vw ah
            where
                o.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT  and
                o.object_id    = ms.account_id                          and
                ah.appl_id     = o.appl_id                              and
                ah.appl_status = app_api_const_pkg.APPL_STATUS_PROC_SUCCESS
            group by
                ms.account_id
        ),
        last_application as (
            select
                t.account_id
              , t.change_date
              , u.name as change_user
            from
                (select
                     ms.account_id
                   , max(ah.change_date) keep (dense_rank last order by ah.change_date) as change_date
                   , max(ah.change_user) keep (dense_rank last order by ah.change_date) as change_user
                 from
                     main_select ms
                   , app_object o
                   , app_history_vw ah
                 where
                     o.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT and
                     o.object_id    = ms.account_id                         and
                     ah.appl_id     = o.appl_id                             and
                     ah.appl_status = app_api_const_pkg.APPL_STATUS_PROC_SUCCESS
                 group by
                     ms.account_id
                ) t
              , acm_user_vw u
            where
                t.change_user = u.id
        )
        select
            ms.account_id
          , ms.account_number
          , ms.account_type
          , ms.account_type_name
          , ms.currency
          , ms.status
          , ms.status_name
          , ms.available_balance
          , ms.agent_id
          , ms.agent_name
          , ms.agent_number
          , ms.product_number
          , fapp.change_date as account_open_date
          , sts.reason as status_change_reason
          , com_api_dictionary_pkg.get_article_desc(sts.reason, l_lang) as status_change_reason_desc
          , sts.change_date as status_change_date
          , sts.change_user as status_change_user
          , sts.prev_state as prev_status
          , com_api_dictionary_pkg.get_article_desc(sts.prev_state, l_lang) as prev_status_description
          , lapp.change_date as last_application_date
          , lapp.change_user as last_application_user
        from
            main_select ms
          , status_change sts
          , last_application lapp
          , first_application fapp
        where
            sts.account_id  (+) = ms.account_id and
            lapp.account_id (+) = ms.account_id and
            fapp.account_id (+) = ms.account_id;

exception
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'FAILED with i_account_id [' || i_account_id
                                 || '], i_account_number [' || i_account_number
                                 || '], i_inst_id [' || i_inst_id || ']'
        );
        raise;
end get_account_details;

procedure get_account_balances(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_account_number      in     com_api_type_pkg.t_account_number
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_lang                in     com_api_type_pkg.t_dict_value     default null
  , o_ref_cursor             out sys_refcursor
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_account_balances: ';
    l_account_id                 com_api_type_pkg.t_account_id;
    l_lang                       com_api_type_pkg.t_dict_value;
    l_account                    acc_api_type_pkg.t_account_rec;
begin
    l_lang := coalesce(i_lang, get_user_lang());

    l_account := acc_api_account_pkg.get_account(
                     i_account_id     => i_account_id
                   , i_account_number => i_account_number
                   , i_inst_id        => i_inst_id
                   , i_mask_error     => com_api_type_pkg.FALSE
                 );

    l_account_id := l_account.account_id;

    trc_log_pkg.debug(LOG_PREFIX || 'l_account_id [' || l_account_id || '], l_lang [' || l_lang || ']');

    if i_account_number is not null and i_account_number != l_account.account_number then
        com_api_error_pkg.raise_error(
            i_error      => 'ACCOUNT_NOT_FOUND'
          , i_env_param1 => nvl(i_account_id, i_account_number)
          , i_env_param2 => i_inst_id
        );
    end if;

    open o_ref_cursor for
        select
            ab.balance_type
          , com_api_dictionary_pkg.get_article_desc(
                i_article        => ab.balance_type
              , i_lang           => l_lang
            ) as balance_type_description
          , com_api_currency_pkg.get_amount_str(
                i_amount         => round(ab.balance + nvl(br.reserv_amount, 0))
              , i_curr_code      => ab.currency
              , i_mask_curr_code => com_api_type_pkg.TRUE
              , i_format_mask    => 'FM999999999999999990.0099'
            ) as amount
          , ab.currency
          , com_api_currency_pkg.get_amount_str(
                i_amount         => round(com_api_rate_pkg.convert_amount(
                                        i_src_amount      => ab.balance + nvl(br.reserv_amount, 0)
                                      , i_src_currency    => ab.currency
                                      , i_dst_currency    => acc.currency
                                      , i_rate_type       => bt.rate_type
                                      , i_inst_id         => acc.inst_id
                                      , i_eff_date        => get_sysdate()
                                      , i_mask_exception  => com_api_type_pkg.FALSE
                                      , i_exception_value => null
                                      , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_SELLING
                                    ))
              , i_curr_code      => acc.currency
              , i_mask_curr_code => com_api_type_pkg.TRUE
              , i_format_mask    => 'FM999999999999999990.0099'
            ) as amount_acc_currency
          , acc.currency as account_currency
        from
            acc_balance_vw ab
          , acc_account_vw acc
          , acc_balance_type_vw bt
          , acc_api_balance_reserv_vw br
        where
            ab.status           = acc_api_const_pkg.BALANCE_STATUS_ACTIVE and
            acc.id              = ab.account_id    and
            acc.split_hash      = ab.split_hash    and
            bt.account_type     = acc.account_type and
            bt.inst_id          = acc.inst_id      and
            bt.balance_type     = ab.balance_type  and
            br.account_id (+)   = ab.account_id    and
            br.balance_type (+) = ab.balance_type  and
            br.split_hash (+)   = ab.split_hash    and
            ab.account_id = l_account_id;

exception
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'FAILED with i_account_id [' || i_account_id
                                 || '], i_account_number [' || i_account_number
                                 || '], i_inst_id [' || i_inst_id || ']'
        );
        raise;
end get_account_balances;

procedure get_card_features (
    i_card_number        in    com_api_type_pkg.t_card_number
  , i_card_id            in    com_api_type_pkg.t_medium_id      default null
  , i_inst_id            in    com_api_type_pkg.t_inst_id        default null
  , i_lang               in    com_api_type_pkg.t_dict_value     default null
  , o_ref_cursor         out   sys_refcursor
) is
    l_card_id                  com_api_type_pkg.t_medium_id;
begin
    l_card_id := iss_api_card_pkg.get_card(
                     i_card_id     => i_card_id
                   , i_card_number => i_card_number
                   , i_inst_id     => i_inst_id
                   , i_mask_error  => com_api_type_pkg.FALSE
                 ).id;

    open o_ref_cursor for
        select ft.card_feature
             , com_api_dictionary_pkg.get_article_desc(
                   i_article => ft.card_feature
                 , i_lang    => coalesce(i_lang, get_user_lang())
               ) as feature_description
          from iss_card crd
          join net_card_type_feature ft
            on ft.card_type_id = crd.card_type_id
         where crd.id          = l_card_id
           and (crd.inst_id    = i_inst_id or i_inst_id is null)
      order by ft.seqnum;

exception
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT)
                         || '.get_card_features FAILED: i_card_id [' || i_card_id
                         || '], i_card_number [#1], i_lang [' || i_lang
                         || '], l_card_id [' || l_card_id || ']'
          , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number)
        );
        raise;
end get_card_features;

procedure get_card_features (
    i_card_number        in     com_api_type_pkg.t_card_number
  , i_card_uid           in     com_api_type_pkg.t_name           default null
  , i_inst_id            in     com_api_type_pkg.t_inst_id        default null
  , i_lang               in     com_api_type_pkg.t_dict_value     default null
  , o_ref_cursor            out sys_refcursor
) is
    l_card_id                   com_api_type_pkg.t_medium_id;
begin
    if i_card_uid is null then
        l_card_id := null;
    else
        l_card_id := iss_api_card_pkg.get_card_id_by_uid(
                         i_card_uid => i_card_uid
                       , i_inst_id  => i_inst_id
                     );
    end if;

    get_card_features (
        i_card_number        => i_card_number
      , i_card_id            => l_card_id
      , i_inst_id            => i_inst_id
      , i_lang               => i_lang
      , o_ref_cursor         => o_ref_cursor
    );
end;

/*
 * Procedure executes search of customer by incoming card number and check match of incoming key word with stored one.
 * If key words don't match then empty outgoing parameters will be returned.
 */
procedure get_cards_customer(
    i_card_number          in       com_api_type_pkg.t_card_number
  , i_key_word             in       com_api_type_pkg.t_name
  , o_customer_id              out  com_api_type_pkg.t_medium_id
  , io_inst_id             in  out  com_api_type_pkg.t_inst_id
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_cards_customer: ';
    l_card_rec                   iss_api_type_pkg.t_card_rec;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_card_number [#1], io_inst_id [#2]'
      , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number)
      , i_env_param2 => io_inst_id
    );

    l_card_rec := iss_api_card_pkg.get_card(
                      i_card_id     => null
                    , i_card_number => i_card_number
                    , i_inst_id     => io_inst_id
                    , i_mask_error  => com_api_type_pkg.TRUE
                  );

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'l_card_rec {cardholder_id [' || l_card_rec.cardholder_id
                             || '], inst_id [' || l_card_rec.inst_id
                             || '], customer_id [' || l_card_rec.customer_id || ']}'
    );

    if l_card_rec.cardholder_id is null then
        trc_log_pkg.debug(LOG_PREFIX || 'key word checking FAILED because a cardholder is NOT found');

    elsif sec_api_question_pkg.check_security_word(
              i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
            , i_object_id   => l_card_rec.cardholder_id
            , i_word        => i_key_word
          ) = com_api_type_pkg.FALSE
    then
        trc_log_pkg.debug(LOG_PREFIX || 'key word checking FAILED, do NOT provide found customer');

    else
        trc_log_pkg.debug(LOG_PREFIX || 'key word checking passed, provide found customer');
        o_customer_id := l_card_rec.customer_id;
        io_inst_id    := l_card_rec.inst_id;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end get_cards_customer;

procedure get_customer_contacts(
    i_customer_id         in     com_api_type_pkg.t_medium_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_lang                in     com_api_type_pkg.t_dict_value     default null
  , o_client_name            out com_api_type_pkg.t_full_desc
  , o_phone_number           out com_api_type_pkg.t_name
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_customer_contacts: ';
    l_contact_id                 com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_customer_id [' || i_customer_id || '], i_inst_id [' || i_inst_id || ']');

    begin
        select com_ui_object_pkg.get_object_desc(c.entity_type, c.object_id, coalesce(i_lang, get_user_lang()))
          into o_client_name
          from prd_customer_vw c
         where c.id = i_customer_id
           and nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST) in (c.inst_id, ost_api_const_pkg.DEFAULT_INST);
    exception
        when no_data_found then
            trc_log_pkg.debug(LOG_PREFIX || 'person/company not found');
    end;

    begin
        select distinct
               first_value(cd.contact_id)
                   over (order by case contact_type when com_api_const_pkg.CONTACT_TYPE_PRIMARY then 0 else 1 end)
          into l_contact_id
          from com_contact_object_vw cd
         where cd.object_id   = i_customer_id
           and cd.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER;

        o_phone_number := com_api_contact_pkg.get_contact_string(
                              i_contact_id    => l_contact_id
                            , i_commun_method => com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                            , i_start_date    => null
                          );
    exception
        when no_data_found then
            trc_log_pkg.debug(LOG_PREFIX || 'contact not found');
    end;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end get_customer_contacts;

function get_percent_rate(
    i_account_id         in      com_api_type_pkg.t_medium_id
  , i_service_id         in      com_api_type_pkg.t_short_id        default null
  , i_product_id         in      com_api_type_pkg.t_short_id
  , i_split_hash         in      com_api_type_pkg.t_tiny_id
  , i_eff_date           in      date                               default null
  , i_fee_type           in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_money
is
    l_result                     com_api_type_pkg.t_money;
    l_service_id                 com_api_type_pkg.t_short_id;
    l_eff_date                   date;
begin
    l_eff_date := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate());

    if i_service_id is null then
        l_service_id := crd_api_service_pkg.get_active_service(i_account_id => i_account_id
                                                             , i_eff_date   => l_eff_date
                                                             , i_split_hash => i_split_hash);
    else
        l_service_id := i_service_id;
    end if;

    select percent_rate
      into l_result
      from (select t.percent_rate
              from (select v.attr_value as fee_id
                         , 0 level_priority
                         , a.data_type
                         , a.entity_type as attr_entity_type
                         , v.register_timestamp
                         , v.start_date
                         , m.priority
                      from prd_attribute_value v
                         , prd_attribute a
                         , rul_mod m
                     where v.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                       and v.object_id   = i_account_id
                       and v.service_id  = l_service_id
                       and v.split_hash  = i_split_hash
                       and a.entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE
                       and a.object_type = i_fee_type
                       and a.id          = v.attr_id
                       and v.mod_id      = m.id(+)
                       and l_eff_date between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
                 union all
                    select v.attr_value
                         , p.level_priority
                         , a.data_type
                         , a.entity_type attr_entity_type
                         , v.register_timestamp
                         , v.start_date
                         , m.priority
                      from (select connect_by_root id product_id
                                 , level level_priority
                                 , id parent_id
                                 , product_type
                                 , case when parent_id is null then 1 else 0 end top_flag
                              from prd_product
                        connect by prior parent_id = id
                        start with id = i_product_id
                           ) p
                         , prd_attribute_value v
                         , prd_attribute a
                         , prd_service s
                         , prd_product_service ps
                         , rul_mod m
                     where ps.product_id     = p.product_id
                       and ps.service_id     = s.id
                       and v.service_id      = s.id
                       and a.service_type_id = s.service_type_id
                       and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                       and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                       and v.attr_id         = a.id
                       and s.id              = l_service_id
                       and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_FEE
                       and a.object_type     = i_fee_type
                       and v.mod_id          = m.id(+)
                       and l_eff_date between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
                   ) f
                 , fcl_fee_tier t
             where to_number(f.fee_id, 'FM999999999999999990.0000') = t.fee_id
          order by decode(level_priority, 0, 0, 1)
                 , priority nulls last
                 , level_priority
                 , start_date desc
                 , register_timestamp desc
           )
     where rownum = 1;

    return l_result;
exception
    when no_data_found then
        return null;
end get_percent_rate;

procedure get_credit_account_data(
    i_account_id            in     com_api_type_pkg.t_medium_id
  , io_account_number       in out com_api_type_pkg.t_account_number
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_eff_date              in     date
  , i_lang                  in     com_api_type_pkg.t_dict_value        default null
  , o_closing_date             out date
  , o_total_amount_due         out com_api_type_pkg.t_money
  , o_exceed_limit             out com_api_type_pkg.t_money
  , o_interest_rate            out com_api_type_pkg.t_money
  , o_interest_amount          out com_api_type_pkg.t_money
  , o_overdue_rate             out com_api_type_pkg.t_money
  , o_overdue_amount           out com_api_type_pkg.t_money
  , o_total_income             out com_api_type_pkg.t_money
  , o_repay_amount             out com_api_type_pkg.t_money
  , o_repay_interest           out com_api_type_pkg.t_money
  , o_repay_overdue            out com_api_type_pkg.t_money
  , o_remainder_debt           out com_api_type_pkg.t_money
  , o_overdraft_balance        out com_api_type_pkg.t_money
  , o_interest_balance         out com_api_type_pkg.t_money
  , o_overdue_balance          out com_api_type_pkg.t_money
  , o_due_date                 out date
  , o_min_amount_due           out com_api_type_pkg.t_money
) is
    l_account_rec                  acc_api_type_pkg.t_account_rec;
    l_invoice_id                   com_api_type_pkg.t_medium_id;
    l_service_id                   com_api_type_pkg.t_short_id;
    l_product_id                   com_api_type_pkg.t_short_id;
    l_eff_date                     date;
    l_balances                     com_api_type_pkg.t_amount_by_name_tab;
    l_overdue_intr_amount          com_api_type_pkg.t_money;
begin
    l_eff_date   := nvl(i_eff_date, get_sysdate);

    l_account_rec := acc_api_account_pkg.get_account(
                         i_account_id      => i_account_id
                       , i_account_number  => io_account_number
                       , i_inst_id         => i_inst_id
                       , i_mask_error      => com_api_const_pkg.FALSE
                     );
    io_account_number := l_account_rec.account_number;

    l_service_id :=
        crd_api_service_pkg.get_active_service(
            i_account_id        => l_account_rec.account_id
          , i_eff_date          => l_eff_date
          , i_split_hash        => l_account_rec.split_hash
        );

    if l_service_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'SERVICE_NOT_FOUND'
          , i_env_param1  => nvl(l_account_rec.account_id, io_account_number)
          , i_env_param2  => l_eff_date
        );
    end if;

    -- get last invoice
    select max(i.id)
      into l_invoice_id
      from crd_invoice i
     where i.account_id    = l_account_rec.account_id
       and i.invoice_date <= l_eff_date;

    select end_date
      into o_closing_date
      from prd_service_object
     where service_id  = l_service_id
       and object_id   = l_account_rec.account_id
       and entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => l_account_rec.account_id
          , i_eff_date          => l_eff_date
        );

    -- fees
    o_interest_rate :=
        nvl(
            get_percent_rate(
                i_account_id        => l_account_rec.account_id
              , i_service_id        => l_service_id
              , i_product_id        => l_product_id
              , i_split_hash        => l_account_rec.split_hash
              , i_eff_date          => l_eff_date
              , i_fee_type          => crd_api_const_pkg.INTEREST_RATE_FEE_TYPE
            )
          , 0
        );

    o_overdue_rate :=
        nvl(
            get_percent_rate(
                i_account_id        => l_account_rec.account_id
              , i_service_id        => l_service_id
              , i_product_id        => l_product_id
              , i_split_hash        => l_account_rec.split_hash
              , i_eff_date          => l_eff_date
              , i_fee_type          => crd_api_const_pkg.ADDIT_INTEREST_RATE_FEE_TYPE
            )
          , 0
        );

    o_overdue_rate := o_overdue_rate + o_interest_rate;

    if l_invoice_id is not null then

        select i.total_amount_due
             , i.exceed_limit
             , i.overdue_balance
             , i.overdue_intr_balance
             , i.due_date
             , i.min_amount_due
          into o_total_amount_due
             , o_exceed_limit
             , o_overdue_amount
             , l_overdue_intr_amount
             , o_due_date
             , o_min_amount_due
          from crd_invoice i
         where id = l_invoice_id;

        -- inerest amount
        select nvl(sum(i.interest_amount), 0)
          into o_interest_amount
          from crd_debt_interest i
         where i.invoice_id = l_invoice_id
           and i.balance_type = crd_api_const_pkg.BALANCE_TYPE_INTEREST;

        -- add overdue inerest
        o_interest_amount := o_interest_amount + l_overdue_intr_amount;

    else

        o_total_amount_due := 0;
        o_exceed_limit     := 0;
        o_overdue_amount   := 0;
        o_interest_amount  := 0;
        o_min_amount_due   := 0;
        o_due_date         := null;

    end if;

    -- total income
    select sum (amount)
      into o_total_income
      from crd_payment
     where decode(is_new, 1, account_id, null) = l_account_rec.account_id
       and split_hash = l_account_rec.split_hash;

    -- repayment
    select sum(dp.pay_amount)
         , sum(case when dp.balance_type in (crd_api_const_pkg.BALANCE_TYPE_INTEREST, crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST)
                    then dp.pay_amount
                    else 0
                end)
         , sum(case when dp.balance_type = crd_api_const_pkg.BALANCE_TYPE_OVERDUE then dp.pay_amount
                    else 0
               end)
      into o_repay_amount
         , o_repay_interest
         , o_repay_overdue
      from crd_debt_payment dp
         , crd_payment p
     where decode(p.is_new, 1, account_id, null) = l_account_rec.account_id
       and p.id = dp.pay_id;

    -- remainder debt
    o_remainder_debt := o_total_amount_due - o_repay_amount;

    -- get account balances
    acc_api_balance_pkg.get_account_balances(
        i_account_id  => l_account_rec.account_id
      , o_balances    => l_balances
    );

    o_overdraft_balance := l_balances(crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT).amount;
    o_interest_balance  := l_balances(crd_api_const_pkg.BALANCE_TYPE_INTEREST).amount
                         + l_balances(crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST).amount;
    o_overdue_balance   := l_balances(crd_api_const_pkg.BALANCE_TYPE_OVERDUE).amount;
end;

/*
 * Searching customer's identifier by provided ID card data or personal contact (communication) data.
 * Parameter <i_inst_id> is always required.
 * For search may be used either pair of parameters <i_commun_method> and <i_commun_address>
 * or parameters <i_id_type>, <i_id_series> (optional), <i_id_number>.
 * If all parameters are provided then all of them will be used in search.
 * (In other words if provided ID card data is correct but personal contact data is wrong
 *  then NULL will be returned into outgoing parameter <o_customer_id>.)
 * Note: parameter <i_commun_address> is uppercased.
 */
procedure get_customer_by_personal_data(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_commun_method         in      com_api_type_pkg.t_dict_value
  , i_commun_address        in      com_api_type_pkg.t_full_desc
  , i_id_type               in      com_api_type_pkg.t_dict_value
  , i_id_series             in      com_api_type_pkg.t_name          default null
  , i_id_number             in      com_api_type_pkg.t_name
  , i_max_count             in      com_api_type_pkg.t_long_id       default 1
  , o_customer_id_tab          out  num_tab_tpt
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_customer_by_personal_data: ';
    l_customer_id_tab               num_tab_tpt             := num_tab_tpt();
    l_sysdate                       date;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_inst_id [' || i_inst_id
                     || '], i_commun_method [#1], i_commun_address [' || i_commun_address
                     || '], i_id_type [#2], i_id_series [' || i_id_series || '], i_id_number [' || i_id_number || ']'
      , i_env_param1 => i_commun_method
      , i_env_param2 => i_id_type
    );

    if i_inst_id is null
       or (
           (i_commun_method is null or i_commun_address is null)
           and
           (i_id_type       is null or i_id_number      is null)
       )
    then
        com_api_error_pkg.raise_error(
            i_error => 'NOT_ENOUGH_DATA_TO_FIND_CUSTOMER'
        );
    end if;

    l_sysdate := com_api_sttl_day_pkg.get_sysdate();

    select c.id as customer_id
      bulk collect into l_customer_id_tab
      from com_contact_data   cd
         , com_contact_object co
         , prd_customer       c
     where upper(cd.commun_address) = upper(i_commun_address)
       and cd.commun_method         = i_commun_method
       and l_sysdate between nvl(cd.start_date, l_sysdate) and nvl(cd.end_date, l_sysdate)
       and co.contact_id            = cd.contact_id
       and co.entity_type           = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
       and c.id                     = co.object_id
       and c.inst_id                = i_inst_id
    union
    select c.id as customer_id
      from com_id_object i
         , prd_customer  c
     where i.id_type                = i_id_type
       and i.id_number              = i_id_number
       and (i_id_series is null or i.id_series = i_id_series)
       and c.entity_type            = i.entity_type
       and c.object_id              = i.object_id
       and c.inst_id                = i_inst_id;

    if i_max_count is null then
        o_customer_id_tab := l_customer_id_tab;

    elsif l_customer_id_tab.count > i_max_count then
        raise too_many_rows;
    else
        o_customer_id_tab := num_tab_tpt();

        for i in 1 .. l_customer_id_tab.count loop
            o_customer_id_tab.extend;
            o_customer_id_tab(o_customer_id_tab.count) := l_customer_id_tab(i);
        end loop;
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'END with o_customer_id_tab.count [#1]'
      , i_env_param1 => o_customer_id_tab.count
    );
exception
    when too_many_rows then
        com_api_error_pkg.raise_error(
            i_error      => 'TOO_MANY_CUSTOMERS_ARE_FOUND'
          , i_env_param1 => i_inst_id
          , i_env_param2 => l_customer_id_tab.count
          , i_env_param3 => i_max_count
          , i_env_param4 => i_commun_method
          , i_env_param5 => i_commun_address
          , i_env_param6 => i_id_type || '-' || i_id_series || '-' || i_id_number
        );
    when others then
        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_type_pkg.TRUE
        then
            raise;
        else -- no_data_found and any unexpected exception
            com_api_error_pkg.raise_error(
                i_error      => 'CUSTOMER_NOT_FOUND'
              , i_env_param2 => i_inst_id
              , i_env_param3 => i_commun_method
              , i_env_param4 => i_commun_address
              , i_env_param5 => i_id_type
              , i_env_param6 => i_id_number
            );
        end if;
end get_customer_by_personal_data;

procedure get_card_by_phone(
    i_commun_address        in     com_api_type_pkg.t_full_desc
  , i_card_mask             in     com_api_type_pkg.t_card_number
  , i_inst_id               in     com_api_type_pkg.t_inst_id         default null
  , o_card_number              out com_api_type_pkg.t_card_number
  , o_card_mask                out com_api_type_pkg.t_card_number
) is
    l_sysdate                      date;
    l_card_number                  com_api_type_pkg.t_card_number;
    l_card_mask                    com_api_type_pkg.t_card_number;
begin
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    select iss_api_token_pkg.decode_card_number(i_card_number => n.card_number)
         , c.card_mask
      into l_card_number
         , l_card_mask
      from (select min(o.object_id) customer_id
              from com_contact_data c
                 , com_contact_object o
             where c.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
               and upper(c.commun_address) = upper(i_commun_address)
               and o.contact_id = c.contact_id
               and (c.end_date is null or c.end_date > l_sysdate)
           ) t
         , iss_card c
         , iss_card_number n
     where c.customer_id = t.customer_id
       and reverse(c.card_mask) like reverse(i_card_mask) || '%'
       and c.id = n.card_id
       and (c.inst_id = i_inst_id or i_inst_id is null);

    if nvl(set_ui_value_pkg.get_inst_param_n('UNMASKED_PAN_IN_RESPONSE_ON_WS'), com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        o_card_number := l_card_number;
    else
        o_card_mask := l_card_mask;
    end if;

exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error      => 'CARD_NOT_FOUND'
          , i_env_param1 => i_commun_address
          , i_env_param2 => i_card_mask
        );
end;

procedure get_contract_list(
    i_customer_number       in      com_api_type_pkg.t_name
  , i_customer_id           in      com_api_type_pkg.t_medium_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_card_number           in      com_api_type_pkg.t_card_number    default null
  , i_card_id               in      com_api_type_pkg.t_medium_id      default null
  , i_seq_number            in      com_api_type_pkg.t_inst_id        default null
  , i_expir_date            in      date                              default null
  , i_instance_id           in      com_api_type_pkg.t_medium_id      default null
  , i_account_number        in      com_api_type_pkg.t_account_number default null
  , i_account_id            in      com_api_type_pkg.t_account_id     default null
  , o_ref_cursor               out  sys_refcursor
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_contract_list ';
    l_lang                          com_api_type_pkg.t_dict_value;
    l_sysdate                       date;
    l_customer_id                   com_api_type_pkg.t_medium_id;
    l_customer_number               com_api_type_pkg.t_name;
    l_card_rec                      iss_api_type_pkg.t_card_rec;
    l_card_rec_by_pan               iss_api_type_pkg.t_card_rec; -- card by card number
    l_instance_rec                  iss_api_type_pkg.t_card_instance;
    l_inconsistent_instance_data    boolean;
    l_account_rec                   acc_api_type_pkg.t_account_rec;
    l_account_rec_by_an             acc_api_type_pkg.t_account_rec; -- account by account number
begin
    l_lang    := get_user_lang();
    l_sysdate := com_api_sttl_day_pkg.get_sysdate();

    trc_log_pkg.debug(
        i_text => LOG_PREFIX
               || '<< i_inst_id ['         || i_inst_id
               || '], i_customer_number [' || i_customer_number
               || '], i_customer_id ['     || i_customer_id
               || '], i_card_number ['     || iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
               || '], i_card_id ['         || i_card_id
               || '], i_seq_number ['      || i_seq_number
               || '], i_expir_date ['      || to_char(i_expir_date, 'dd.mm.yyyy')
               || '] i_instance_id ['      || i_instance_id
               || '], i_account_number ['  || i_account_number
               || '], i_account_id ['      || i_account_id || ']'
    );

    -- Forbid to search a customer by its number only
    -- and force raising an error if instituion is not specifed
    if i_inst_id is null then
        com_api_error_pkg.raise_error(
            i_error   => 'INSTITUTION_IS_NOT_DEFINED'
        );
    else
        ost_api_institution_pkg.check_institution(
            i_inst_id => i_inst_id
        );
    end if;

    if i_customer_number is not null then
        l_customer_id :=
            prd_api_customer_pkg.get_customer_id(
                i_customer_number => i_customer_number
              , i_inst_id         => i_inst_id
              , i_mask_error      => com_api_type_pkg.FALSE
            );
    end if;

    if i_customer_id is not null then
        l_customer_number :=
            prd_api_customer_pkg.get_customer_number(
                i_customer_id     => i_customer_id
              , i_inst_id         => i_inst_id
              , i_mask_error      => com_api_type_pkg.FALSE
            );
    end if;

    -- Check that i_customer_id and i_customer_number+i_inst_id specify the same customer
    if      i_customer_number is not null
        and l_customer_id != nvl(i_customer_id, l_customer_id)
        or
            i_customer_id is not null
        and l_customer_number != nvl(i_customer_number, l_customer_number)
    then
        com_api_error_pkg.raise_error(
            i_error      => 'CUSTOMER_ID_AND_NUMBER_MISMATCH'
          , i_env_param1 => i_customer_id
          , i_env_param2 => i_customer_number
          , i_env_param3 => i_inst_id
        );
    elsif l_customer_id is null then
        l_customer_id := i_customer_id;
    end if;

    if i_card_id is not null then
        l_card_rec        := iss_api_card_pkg.get_card(
                                 i_card_id     => i_card_id
                               , i_mask_error  => com_api_type_pkg.FALSE
                             );
    end if;

    if i_card_number is not null then
        l_card_rec_by_pan := iss_api_card_pkg.get_card(
                                 i_card_number => i_card_number
                               , i_mask_error  => com_api_type_pkg.FALSE
                             );
    end if;

    if      i_card_id     is not null
        and i_card_number is not null
        and l_card_rec.id != l_card_rec_by_pan.id
    then
        com_api_error_pkg.raise_error(
            i_error      => 'CARD_ID_AND_NUMBER_MISMATCH'
          , i_env_param1 => i_card_id
          , i_env_param2 => i_card_number
        );
    elsif   l_card_rec.id        is null
        and l_card_rec_by_pan.id is not null
    then
        l_card_rec := l_card_rec_by_pan;
    end if;

    if l_card_rec.customer_id != l_customer_id then
        com_api_error_pkg.raise_error(
            i_error      => 'CARD_OR_ACCOUNT_DOES_NOT_BELONG_TO_CUSTOMER'
          , i_env_param1 => l_card_rec.id
          , i_env_param2 => null
          , i_env_param3 => l_customer_id
        );
    end if;

    -- Check card instance
    if l_card_rec.id is not null then
        if i_seq_number is not null or i_expir_date is not null then
            l_instance_rec.id :=
                iss_api_card_instance_pkg.get_card_instance_id(
                    i_card_id     => l_card_rec.id
                  , i_card_number => null
                  , i_seq_number  => i_seq_number
                  , i_expir_date  => i_expir_date
                  , i_raise_error => com_api_const_pkg.TRUE
                );
            l_inconsistent_instance_data :=
                l_instance_rec.id != nvl(i_instance_id, l_instance_rec.id);
        elsif i_instance_id is not null then
            l_instance_rec :=
                iss_api_card_instance_pkg.get_instance(
                    i_id          => i_instance_id
                  , i_card_id     => l_card_rec.id
                  , i_raise_error => com_api_const_pkg.TRUE
                );
            l_inconsistent_instance_data :=
                l_instance_rec.seq_number != nvl(i_seq_number, l_instance_rec.seq_number)
                or
                l_instance_rec.expir_date != nvl(i_expir_date, l_instance_rec.expir_date);
        else
            l_inconsistent_instance_data := false;
        end if;
        -- Check card instance data for consistency
        if l_inconsistent_instance_data then
            com_api_error_pkg.raise_error(
                i_error      => 'CARD_INSTANCE_DATA_ARE_INCONSISTENT'
              , i_env_param1 => l_card_rec.id
              , i_env_param2 => i_instance_id
              , i_env_param3 => i_seq_number
              , i_env_param4 => i_expir_date
            );
        end if;
    end if;

    if i_account_id is not null then
        l_account_rec :=
            acc_api_account_pkg.get_account(
                i_account_id     => i_account_id
              , i_account_number => null
              , i_inst_id        => i_inst_id
              , i_mask_error     => com_api_type_pkg.FALSE
            );
    end if;

    if i_account_number is not null then
        l_account_rec_by_an :=
            acc_api_account_pkg.get_account(
                i_account_id     => null
              , i_account_number => i_account_number
              , i_inst_id        => i_inst_id
              , i_mask_error     => com_api_type_pkg.FALSE
            );
    end if;

    if      i_account_id     is not null
        and i_account_number is not null
        and l_account_rec.account_id != l_account_rec_by_an.account_id
    then
        com_api_error_pkg.raise_error(
            i_error      => 'ACCOUNT_ID_AND_NUMBER_MISMATCH'
          , i_env_param1 => i_account_id
          , i_env_param2 => i_account_number
        );
    elsif   l_account_rec.account_id       is null
        and l_account_rec_by_an.account_id is not null
    then
        l_account_rec := l_account_rec_by_an;
    end if;

    -- If both card and account are passing into the procedure should be linked
    -- with the same contract, otherwise a error is raised
    if      l_card_rec.id            is not null
        and l_account_rec.account_id is not null
        and l_account_rec.contract_id != l_card_rec.contract_id
    then
        com_api_error_pkg.raise_error(
            i_error      => 'CARD_CONTRACT_DIFFERS_FROM_ACCOUNT_CONTRACT'
          , i_env_param1 => l_customer_id
          , i_env_param2 => l_card_rec.id
          , i_env_param3 => l_card_rec.contract_id
          , i_env_param4 => l_account_rec.account_id
          , i_env_param5 => l_account_rec.contract_id
        );
    elsif l_account_rec.customer_id != l_customer_id then
        com_api_error_pkg.raise_error(
            i_error      => 'CARD_OR_ACCOUNT_DOES_NOT_BELONG_TO_CUSTOMER'
          , i_env_param1 => null
          , i_env_param2 => l_account_rec.account_id
          , i_env_param3 => l_customer_id
        );
    else
        l_card_rec.contract_id := nvl(l_account_rec.contract_id, l_card_rec.contract_id);
    end if;

--    trc_log_pkg.debug(
--        i_text => LOG_PREFIX
--               || '>> l_customer_id ['          || l_customer_id
--               || '], l_card_rec.contract_id [' || l_card_rec.contract_id
--               || '], l_sysdate ['              || to_char(l_sysdate, 'dd.mm.yyyy') || ']'
--    );

    open o_ref_cursor for
        select ct.contract_number
             , ct.contract_type
             , get_text('prd_product', 'label', ct.product_id, l_lang) as product
             , ct.start_date
             , ct.end_date
          from prd_contract ct
         where ct.customer_id = l_customer_id
           and (l_card_rec.contract_id is null or ct.id = l_card_rec.contract_id)
           and l_sysdate between nvl(ct.start_date, l_sysdate - 1) and nvl(ct.end_date, l_sysdate + 1)
      order by ct.start_date
    ;
end get_contract_list;

procedure get_contract_list(
    i_customer_number       in      com_api_type_pkg.t_name
  , i_customer_id           in      com_api_type_pkg.t_medium_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_card_number           in      com_api_type_pkg.t_card_number    default null
  , i_card_uid              in      com_api_type_pkg.t_name           default null
  , i_seq_number            in      com_api_type_pkg.t_inst_id        default null
  , i_expir_date            in      date                              default null
  , i_instance_id           in      com_api_type_pkg.t_medium_id      default null
  , i_account_number        in      com_api_type_pkg.t_account_number default null
  , i_account_id            in      com_api_type_pkg.t_account_id     default null
  , o_ref_cursor               out  sys_refcursor
) is
    l_card_id                       com_api_type_pkg.t_medium_id;
begin
    if i_card_uid is null then
        l_card_id := null;
    else
        l_card_id := iss_api_card_pkg.get_card_id_by_uid(
                         i_card_uid => i_card_uid
                       , i_inst_id  => i_inst_id
                     );
    end if;

    get_contract_list(
        i_customer_number       => i_customer_number
      , i_customer_id           => i_customer_id
      , i_inst_id               => i_inst_id
      , i_card_number           => i_card_number
      , i_card_id               => l_card_id
      , i_seq_number            => i_seq_number
      , i_expir_date            => i_expir_date
      , i_instance_id           => i_instance_id
      , i_account_number        => i_account_number
      , i_account_id            => i_account_id
      , o_ref_cursor            => o_ref_cursor
    );
end get_contract_list;

procedure get_remote_banking_activity(
    i_customer_number       in      com_api_type_pkg.t_name
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , o_banking_activity         out  com_api_type_pkg.t_boolean
) is
begin
    itf_cst_integration_pkg.get_remote_banking_activity(
        i_customer_number       => i_customer_number
      , i_inst_id               => i_inst_id
      , o_banking_activity      => o_banking_activity
    );

    if o_banking_activity is null then
        o_banking_activity := com_api_const_pkg.TRUE;
    end if;
end get_remote_banking_activity;

procedure get_account_balances (
    i_account_id              in     com_api_type_pkg.t_account_id
  , i_balance_type            in     com_api_type_pkg.t_dict_value
  , o_balance_amount             out com_api_type_pkg.t_money
  , o_balance_currency           out com_api_type_pkg.t_curr_code
  , o_aval_balance               out com_api_type_pkg.t_money
  , o_aval_balance_currency      out com_api_type_pkg.t_curr_code
) is
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_account_balances: ';
    l_account                        acc_api_type_pkg.t_account_rec;
    l_balance_amount                 com_api_type_pkg.t_amount_rec;
    l_aval_balance                   com_api_type_pkg.t_amount_rec;
begin
    l_account := acc_api_account_pkg.get_account(
                     i_account_id     => i_account_id
                   , i_mask_error     => com_api_type_pkg.FALSE
                 );

    trc_log_pkg.debug(LOG_PREFIX || 'account_id [' || l_account.account_id || ']');

    l_balance_amount := acc_api_balance_pkg.get_balance_amount (
                            i_account_id    => l_account.account_id
                          , i_balance_type  => i_balance_type
                          , i_mask_error    => com_api_const_pkg.FALSE
                          , i_lock_balance  => com_api_const_pkg.FALSE
                        );
    l_aval_balance := acc_api_balance_pkg.get_aval_balance_amount (
                          i_account_id  => l_account.account_id
                      );

    o_balance_amount        := l_balance_amount.amount;
    o_balance_currency      := l_balance_amount.currency;
    o_aval_balance          := l_aval_balance.amount;
    o_aval_balance_currency := l_aval_balance.currency;
end;

function get_invoice_start_date(
    i_account_id              in     com_api_type_pkg.t_account_id
  , i_invoice_id              in     com_api_type_pkg.t_account_id
) return date
is
    l_start_date                     date;
begin
    -- calc start date
    if i_invoice_id is null then
        begin
            -- get start date of credit service on current account
            select o.start_date
              into l_start_date
              from prd_service_object o
                 , prd_service s
             where o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
               and object_id         = i_account_id
               and s.id              = o.service_id
               and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'ACCOUNT_SERVICE_NOT_FOUND'
                  , i_env_param1  => i_account_id
                  , i_env_param2  => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                );
        end;
    else
        select invoice_date
          into l_start_date
          from crd_invoice_vw i
         where i.id = i_invoice_id;
    end if;

    return l_start_date;
end;

procedure get_specified_invoice(
    i_account_number     in     com_api_type_pkg.t_name
  , i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_lang               in     com_api_type_pkg.t_dict_value    default null
  , i_invoice_age        in     com_api_type_pkg.t_seqnum        default 0
  , o_ref_cursor            out sys_refcursor
) is
    l_account_rec               acc_api_type_pkg.t_account_rec;
    l_invoice_id                com_api_type_pkg.t_account_id;
    l_next_invoice_id           com_api_type_pkg.t_account_id;
    l_lang                      com_api_type_pkg.t_dict_value;
    l_aval_balance              com_api_type_pkg.t_amount_rec;
    l_start_date                date;
    l_end_date                  date;
    l_statement_date            date;
    l_payment_amount            com_api_type_pkg.t_money    := 0;
    l_expense_amount            com_api_type_pkg.t_money    := 0;
    l_interest_amount           com_api_type_pkg.t_money    := 0;
    l_fee_amount                com_api_type_pkg.t_money    := 0;
    l_penalty_fee_amount        com_api_type_pkg.t_money    := 0;
    l_overdue_amount            com_api_type_pkg.t_money    := 0;
    l_overdue_intr_amount       com_api_type_pkg.t_money    := 0;
    l_incoming_debt             com_api_type_pkg.t_money    := 0;
    l_outgoing_debt             com_api_type_pkg.t_money    := 0;
    l_currency                  com_api_type_pkg.t_dict_value;
    l_from_id                   com_api_type_pkg.t_long_id;
    l_till_id                   com_api_type_pkg.t_long_id;
    l_calc_interest_end_attr    com_api_type_pkg.t_dict_value;
    l_calc_interest_date_end    date;
    l_calc_due_date             date;
    l_invoice_age               com_api_type_pkg.t_seqnum;

begin
    l_lang           := coalesce(i_lang, get_user_lang());
    l_statement_date := get_sysdate();
    l_invoice_age    := nvl(i_invoice_age, 0);

    l_account_rec := acc_api_account_pkg.get_account(
                         i_account_id     => null
                       , i_account_number => i_account_number
                       , i_inst_id        => i_inst_id
                       , i_mask_error     => com_api_const_pkg.FALSE
                     );

    if i_invoice_age = 0 then
        l_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                            i_account_id     => l_account_rec.account_id
                          , i_split_hash     => l_account_rec.split_hash
                          , i_mask_error     => com_api_const_pkg.TRUE
                        );

        l_start_date := get_invoice_start_date(
                            i_account_id     => l_account_rec.account_id
                          , i_invoice_id     => l_invoice_id
                        );

        l_from_id := com_api_id_pkg.get_from_id(l_start_date);
        l_till_id := com_api_id_pkg.get_till_id(l_statement_date);

        select sum(pay_amount)
          into l_payment_amount
          from crd_payment
         where decode(is_new, 1, account_id, null) = l_account_rec.account_id
           and split_hash = l_account_rec.split_hash;

        select sum(d.amount)
          into l_expense_amount
          from crd_debt d
         where decode(d.is_new, 1, d.account_id, null) = l_account_rec.account_id
           and d.split_hash = l_account_rec.split_hash;

        l_calc_interest_end_attr :=
            crd_interest_pkg.get_interest_calc_end_date(
                i_account_id  => l_account_rec.account_id
              , i_eff_date    => l_statement_date
              , i_split_hash  => l_account_rec.split_hash
              , i_inst_id     => l_account_rec.inst_id
            );

        -- Get Due Date
        l_calc_due_date :=
            crd_invoice_pkg.calc_next_invoice_due_date(
                i_account_id => l_account_rec.account_id
              , i_split_hash => l_account_rec.split_hash
              , i_inst_id    => l_account_rec.inst_id
              , i_eff_date   => l_statement_date
              , i_mask_error => case l_calc_interest_end_attr
                                    when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                                        then com_api_const_pkg.FALSE
                                    when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                                        then com_api_const_pkg.TRUE
                                    else com_api_const_pkg.FALSE
                                end
            );

        for r in (
            select a.fee_id
                 , a.amount
                 , a.balance_date as start_date
                 , lead(a.balance_date) over (partition by a.balance_type order by a.id) end_date
                 , i.due_date
              from crd_debt_interest a
                 , crd_debt d
                 , crd_invoice i
             where decode(d.status, 'DBTSACTV', d.account_id, null) = l_account_rec.account_id
               and a.is_charged      = com_api_const_pkg.FALSE
               and d.is_grace_enable = com_api_const_pkg.FALSE
               and d.id              = a.debt_id
               and a.split_hash      = l_account_rec.split_hash
               and a.id between l_from_id and l_till_id
               and a.invoice_id      = i.id(+)
          order by d.id
        ) loop
            l_calc_interest_date_end :=
                case l_calc_interest_end_attr
                    when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                        then r.end_date
                    when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                        then nvl(r.due_date, l_calc_due_date)
                    else r.end_date
                end;
            l_interest_amount := l_interest_amount
                               + round(
                                     fcl_api_fee_pkg.get_fee_amount(
                                         i_fee_id            => r.fee_id
                                       , i_base_amount       => r.amount
                                       , io_base_currency    => l_currency
                                       , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                       , i_object_id         => l_account_rec.account_id
                                       , i_split_hash        => l_account_rec.split_hash
                                       , i_eff_date          => r.start_date
                                       , i_start_date        => r.start_date
                                       , i_end_date          => l_calc_interest_date_end
                                     )
                                   , 4
                                 );
            trc_log_pkg.debug(
                i_text        => 'Calc interest [#1] [#2] [#3] [#4]'
              , i_env_param1  => r.fee_id
              , i_env_param2  => r.amount
              , i_env_param4  => r.start_date
              , i_env_param5  => r.end_date
            );
        end loop;

        select nvl(sum(i.total_amount_due), 0)
          into l_incoming_debt
          from crd_invoice i
         where id = l_invoice_id;

        select sum(b.amount) as total_amount_due
             , sum(
                   case when b.balance_type = crd_api_const_pkg.BALANCE_TYPE_OVERDUE
                        then b.amount
                        else 0
                   end
               ) as overdue_balance
             , sum(
                   case when b.balance_type = crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
                        then b.amount
                        else 0
                    end
               ) as overdue_intr_balance
          into l_outgoing_debt
             , l_overdue_amount
             , l_overdue_intr_amount
          from (select d.id     as debt_id
                     , d.status
                  from crd_debt d
                 where decode(d.status, 'DBTSACTV', d.account_id, null) = l_account_rec.account_id
                   and d.split_hash = l_account_rec.split_hash
                union
                select d.id     as debt_id
                     , d.status
                  from crd_debt d
                 where decode(d.is_new, 1, d.account_id, null) = l_account_rec.account_id
                   and d.status     = crd_api_const_pkg.DEBT_STATUS_ACTIVE  -- 'DBTSACTV'
                   and d.account_id = l_account_rec.account_id
                   and d.split_hash = l_account_rec.split_hash) d
             , crd_debt_balance b
         where b.debt_id      = d.debt_id
           and b.split_hash   = l_account_rec.split_hash
           and b.balance_type != acc_api_const_pkg.BALANCE_TYPE_LEDGER  -- 'BLTP0001'
           and b.id           between l_from_id and l_till_id;

        select sum(p.account_amount)
          into l_penalty_fee_amount
          from (
               select distinct debt_id
                 from crd_invoice_debt_vw
                where invoice_id = l_invoice_id
                  and is_new = com_api_type_pkg.TRUE
                ) e
          join crd_debt d
            on d.id = e.debt_id
          join opr_operation o
            on d.oper_id = o.id
          join opr_participant p
            on p.oper_id = o.id
         where p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and d.oper_type        = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE;
    else
        begin
            select id
                 , start_date
                 , total_amount_due
              into l_invoice_id
                 , l_start_date
                 , l_incoming_debt
              from (select id
                         , start_date
                         , total_amount_due
                         , row_number() over (order by id desc) rn
                      from crd_invoice
                     where account_id = l_account_rec.account_id
                   ) inv
             where rn - 1 = l_invoice_age;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'INVOICE_NOT_FOUND'
                  , i_env_param1  => l_account_rec.account_id
                  , i_env_param2  => l_invoice_age
                );
        end;

        select min(id)
          into l_next_invoice_id
          from crd_invoice
         where account_id = l_account_rec.account_id
           and split_hash = l_account_rec.split_hash
           and id > l_invoice_id;

        select i.payment_amount
             , i.expense_amount
             , i.interest_amount
             , i.fee_amount
             , i.overdue_balance
             , i.overdue_intr_balance
             , i.total_amount_due
             , i.start_date
          into l_payment_amount
             , l_expense_amount
             , l_interest_amount
             , l_penalty_fee_amount
             , l_overdue_amount
             , l_overdue_intr_amount
             , l_outgoing_debt
             , l_end_date
          from crd_invoice i
         where i.id = l_next_invoice_id;
    end if;

    -- get aval balance
    l_aval_balance := acc_api_balance_pkg.get_aval_balance_amount(
                          i_account_id  => l_account_rec.account_id
                        , i_date        => l_statement_date
                        , i_date_type   => com_api_const_pkg.DATE_PURPOSE_PROCESSING
                      );

    open o_ref_cursor for
       select l_statement_date                                              as statement_date
            , com_ui_person_pkg.get_person_name(c.object_id, l_lang)        as customer_name
            , com_api_address_pkg.get_address_string(ao.address_id, l_lang) as customer_address
            , a.account_number
            , a.currency
            , l_aval_balance.amount
            , i.id
            , i.account_id
            , i.serial_number
            , i.invoice_date
            , i.invoice_type
            , i.min_amount_due
            , i.total_amount_due
            , i.own_funds
            , i.exceed_limit
            , i.start_date
            , i.due_date
            , i.grace_date
            , i.penalty_date
            , i.is_mad_paid
            , i.is_tad_paid
            , i.aging_period
            , i.agent_id
            , i.inst_id
            , l_start_date               as invoice_begin_date
            , l_end_date                 as invoice_end_date
            , l_payment_amount           as total_income
            , l_expense_amount           as total_expenses
            , l_interest_amount          as interest_amount
            , l_fee_amount               as fee_amount
            , l_overdue_amount           as overdue_amount
            , l_overdue_intr_amount      as overdue_interest_amount
            , l_penalty_fee_amount       as penalty_fee_amount
            , l_incoming_debt            as incoming_debt
            , l_outgoing_debt            as outgoing_debt
         from crd_invoice i
         join acc_account a
           on i.account_id = a.id
         join prd_customer c
           on c.id = a.customer_id
         join com_address_object ao
           on ao.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
          and ao.address_type = com_api_const_pkg.ADDRESS_TYPE_HOME
          and ao.object_id = c.id
        where i.id = l_invoice_id;
exception
    when others then
        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT) || '.get_specified_invoice FAILED: i_account_number [' || i_account_number
                   || '], i_inst_id [' || i_inst_id || '], l_invoice_age [' || l_invoice_age
                   || '], ' || chr(13) || chr(10)   || sqlerrm
        );
        raise;
end get_specified_invoice;

procedure get_invoice_oper_aggr_data(
    i_invoice_id         in     com_api_type_pkg.t_medium_id
  , o_ref_cursor            out sys_refcursor
) is
begin
    open o_ref_cursor for
        select opr.oper_type                    as operation_type
             , get_article_text(opr.oper_type)  as operation_type_name
             , opr.oper_currency                as operation_currency
             , count(opr.id)                    as total_operation_count
             , sum(opr.oper_amount) - sum(opp.oper_amount) as total_operation_amount
          from (
                 select distinct debt_id
                      , split_hash
                   from crd_invoice_debt_vw
                  where invoice_id = i_invoice_id
                 )  cid
          join crd_debt cd
            on cd.split_hash = cid.split_hash
           and cd.id = cid.debt_id
          join opr_operation opr
            on opr.id = cd.oper_id
          left
          join (select dispute_id       as dispute_id
                     , sum(oper_amount) as oper_amount
                  from opr_operation
                 where msg_type = 'MSGTPRES'
                   and status in ('OPST0400')
                 group by dispute_id
               ) opp
            on opr.id = opp.dispute_id
         where opr.status in ('OPST0400', 'OPST0800', 'OPST0850')
      group by opr.oper_type
             , opr.oper_type
             , opr.oper_currency;
end;

procedure get_invoice_oper_list_data(
    i_invoice_id         in     com_api_type_pkg.t_medium_id
  , o_ref_cursor            out sys_refcursor
) is
begin
    open o_ref_cursor for
        select o.oper_date       as oper_date
             , o.oper_type       as oper_type
             , op.account_amount as income
             , 0                 as expenses
             , 0                 as credit
             , op.account_amount as repayment
             , 0                 as percent
             , get_article_desc(o.oper_type) as operation_description
          from crd_invoice_payment p
          join crd_payment m
            on p.pay_id = m.id
          join opr_operation o
            on m.oper_id = o.id
          join opr_participant op
            on o.id = op.oper_id
           and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
         where p.invoice_id = i_invoice_id
           and m.is_reversal = 0

         union all

        select o.oper_date       as oper_date
             , o.oper_type       as oper_type
             , 0                 as income
             , op.account_amount as expenses
             , sum(d.debt_amount)as credit
             , 0                 as repayment
             , sum(nvl(interest_amount, 0))  as percent
             , get_article_desc(o.oper_type) as operation_description
          from (
                select distinct debt_id
                     , split_hash
                  from crd_invoice_debt_vw
                 where invoice_id = i_invoice_id
                ) cid
          join crd_debt d
            on d.split_hash = cid.split_hash
           and d.id = cid.debt_id
          join opr_operation o
            on d.oper_id = o.id
          join opr_participant op
            on o.id = op.oper_id
           and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
          left
          join (select interest_amount
                     , debt_id
                  from crd_debt_interest
                 where invoice_id = i_invoice_id
               ) di
            on di.debt_id = cid.debt_id
         where d.is_reversal = 0
      group by o.oper_date
             , o.oper_type
             , o.id
             , op.account_amount;
end;

procedure get_merchant_stat(
    o_xml                  out clob
  , i_customer_number   in     com_api_type_pkg.t_name
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_start_date        in     date
  , i_end_date          in     date
) is
    l_customer_id              com_api_type_pkg.t_medium_id;
    l_count                    com_api_type_pkg.t_medium_id;
    l_start_date               date;
    l_end_date                 date;
begin
    check_customer_exists(
        i_customer_number  => i_customer_number
      , i_inst_id          => i_inst_id
      , io_customer_id     => l_customer_id
    );

    l_start_date := trunc(coalesce(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date   := trunc(coalesce(i_end_date,   com_api_sttl_day_pkg.get_sysdate));

    select xmlconcat(
               xmlelement("xml"
                 , xmlelement("customer_number", min(x.customer_number))
                 , xmlagg(
                       xmlelement("date_stat"
                         , xmlelement("date", x.stat_date)
                         , (
                               select xmlagg(
                                          xmlelement("currencies"
                                            , xmlelement("currency",   z.currency_code)
                                            , xmlelement("amount_sum", sum(z.amount_sum))
                                            , xmlelement("fee_sum",    sum(z.fee_sum))
                                          )
                                      )
                                 from acq_merchant_daily_stat z
                                where z.customer_id = x.customer_id
                                  and z.stat_date   = x.stat_date
                                group by z.currency_code
                           )
                         , xmlelement("trxn_count_total", sum(x.trxn_count_total))
                         , xmlelement("trxn_count_pay",   sum(x.trxn_count_pay))
                         , xmlelement("trxn_count_trf",   sum(x.trxn_count_trf))
                         , xmlelement("trxn_count_dep",   sum(x.trxn_count_dep))
                         , xmlelement("trxn_count_cash",  sum(x.trxn_count_cash))
                       )
                   )
               )
           ).getClobVal()
         , count(1)
      into o_xml
         , l_count
      from acq_merchant_daily_stat x
     where x.customer_id = l_customer_id
       and x.stat_date   between l_start_date and l_end_date
     group by x.stat_date
            , x.customer_number
            , x.customer_id
     order by x.stat_date;

    if l_count = 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'STATISTIC_NOT_FOUND'
          , i_env_param1  => i_customer_number
          , i_env_param2  => i_inst_id
          , i_env_param3  => to_char(l_start_date, 'dd.mm.yyyy')
          , i_env_param4  => to_char(l_end_date,   'dd.mm.yyyy')
        );
    end if;

exception
    when others then
        trc_log_pkg.error(
            i_text => 'itf_ui_integration_pkg.get_merchant_stat: '||sqlerrm
        );
        raise;

end get_merchant_stat;

procedure get_iss_appl_list(
    i_customer_number   in     com_api_type_pkg.t_name          default null
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_customer_id       in     com_api_type_pkg.t_medium_id     default null
  , i_operator_id       in     com_api_type_pkg.t_name          default null
  , i_appl_status       in     com_api_type_pkg.t_dict_value    default null
  , i_flow_id           in     com_api_type_pkg.t_dict_value    default null
  , i_start_date        in     date                             default null
  , i_end_date          in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor           out sys_refcursor
) is
    l_lang                     com_api_type_pkg.t_dict_value;
    l_cursor_str               com_api_type_pkg.t_text;
    l_from_clause              com_api_type_pkg.t_text;
    l_where_clause             com_api_type_pkg.t_text;
    l_customer_id              com_api_type_pkg.t_medium_id;
begin
    l_lang := coalesce(i_lang, get_user_lang());

    l_customer_id := i_customer_id;

    if i_customer_id is not null or i_customer_number is not null then
        check_customer_exists(
            i_customer_number   => i_customer_number
          , i_inst_id           => i_inst_id
          , io_customer_id      => l_customer_id
        );
    end if;

    l_cursor_str :=
       'select appl_id
             , appl_number
             , appl_status
             , com_api_dictionary_pkg.get_article_desc(appl_status, p_lang) appl_status_name
             , flow_id
             , com_api_i18n_pkg.get_text(''app_flow'', ''label'', flow_id, p_lang) flow_name
             , register_date
             , last_change_date
             , customer_number
             , customer_id
             , com_ui_object_pkg.get_object_desc(i_entity_type => '''|| prd_api_const_pkg.ENTITY_TYPE_CUSTOMER ||''', i_object_id => customer_id, i_lang => p_lang) customer_name
          from (
                select a.id appl_id
                     , a.appl_number
                     , a.appl_status
                     , a.flow_id
                     , (select min(change_date) from app_history h where h.appl_id = a.id) register_date
                     , (select max(change_date) from app_history h where h.appl_id = a.id) last_change_date
                     , c.id customer_id
                     , c.customer_number
                     , p_lang
                     , p_start_date
                     , p_end_date';

    l_from_clause :=
          ' from (select :p_customer_id as p_customer_id
                       , :p_appl_status as p_appl_status
                       , :p_flow_id     as p_flow_id
                       , :p_operator_id as p_operator_id
                       , :p_start_date  as p_start_date
                       , :p_end_date    as p_end_date
                       , :p_lang        as p_lang
                       , :p_inst_id     as p_inst_id
                    from dual
                  ) x
             , app_application a
             , app_object o
             , prd_customer c';

    l_where_clause :=
        ' where a.id = c.id
            and o.entity_type = '''|| prd_api_const_pkg.ENTITY_TYPE_CUSTOMER ||'''
            and o.object_id = c.id
            and a.inst_id = p_inst_id
            and a.appl_type = '''|| app_api_const_pkg.APPL_TYPE_ISSUING ||'''';

    if i_operator_id is not null then
        l_from_clause := l_from_clause || ', acm_user u ';
        l_where_clause := l_where_clause || ' and u.name = p_operator_id and u.id = a.user_id ';
    end if;

    if l_customer_id is not null then
        l_where_clause := l_where_clause || ' and c.object_id = p_customer_id';
    end if;

    if i_flow_id is not null then
        l_where_clause := l_where_clause || ' and a.flow_id = p_flow_id';
    end if;

    if i_appl_status is not null then
        l_where_clause := l_where_clause || ' and a.appl_status = p_appl_status';
    end if;

    l_cursor_str := l_cursor_str || l_from_clause || l_where_clause || ') where 1 = 1';

    if i_start_date is not null then
        l_cursor_str := l_cursor_str || ' and register_date >= p_start_date';
    end if;

    if i_end_date is not null then
        l_cursor_str := l_cursor_str || ' and register_date <= p_end_date';
    end if;

--    dbms_output.put_line(l_cursor_str);
    open o_ref_cursor for l_cursor_str
        using l_customer_id
            , i_appl_status
            , i_flow_id
            , upper(i_operator_id)
            , i_start_date
            , i_end_date
            , l_lang
            , i_inst_id;
end;

procedure get_customer_by_card(
    i_card_number       in     com_api_type_pkg.t_card_number
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
  , io_inst_id          in out com_api_type_pkg.t_inst_id
  , o_customer_id          out com_api_type_pkg.t_medium_id
  , o_customer_number      out com_api_type_pkg.t_name
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.get_card_list ';
    l_card_rec                 iss_api_type_pkg.t_card_rec;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_card_number [#1], i_lang[#2]'
      , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number)
      , i_env_param2 => i_lang
    );

    l_card_rec := iss_api_card_pkg.get_card(
                      i_card_id     => null
                    , i_card_number => i_card_number
                    , i_inst_id     => io_inst_id
                    , i_mask_error  => com_api_type_pkg.FALSE
                  );

    io_inst_id    := l_card_rec.inst_id;
    o_customer_id := l_card_rec.customer_id;

    if o_customer_id is null then
        com_api_error_pkg.raise_error (
            i_error       => 'CUSTOMER_NOT_FOUND'
          , i_env_param1  => o_customer_id
          , i_env_param2  => io_inst_id
        );
    else
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '>> l_card_rec {customer_id [#1], inst_id[#2]}'
          , i_env_param1 => o_customer_id
          , i_env_param2 => io_inst_id
        );

        select customer_number
          into o_customer_number
          from prd_customer
         where id = o_customer_id;
    end if;

exception
    when others then
        trc_log_pkg.error(
            i_text  => LOG_PREFIX || 'FAILED: ' || sqlerrm
        );
        raise;
end;

procedure get_fin_overview_list(
    i_card_number       in     com_api_type_pkg.t_card_number
  , i_account_number    in     com_api_type_pkg.t_account_number  default null
  , i_inst_id           in     com_api_type_pkg.t_inst_id         default null
  , o_cardholder_number    out com_api_type_pkg.t_name
  , o_cardholder_name      out com_api_type_pkg.t_name
  , o_ref_cursor           out sys_refcursor
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) || '.get_fin_overview_list: ';
    l_card_id                  com_api_type_pkg.t_account_id;
begin
    l_card_id := iss_api_card_pkg.get_card_id(
                     i_card_number => i_card_number
                   , i_inst_id     => i_inst_id
                 );

    select h.cardholder_number
         , (select max(nvl(i.cardholder_name, h.cardholder_name))
              keep (dense_rank last order by seq_number)
              from iss_card_instance i
             where i.card_id = c.id
           ) as cardholder_name
      into o_cardholder_number
         , o_cardholder_name
      from iss_card c
         , iss_cardholder h
     where h.id = c.cardholder_id
       and c.id = l_card_id
       and (c.inst_id = i_inst_id or i_inst_id is null);

    open o_ref_cursor for
        with invoice as (
            select a.account_number
                 , a.id as account_id
                 , a.split_hash
                 , a.currency
                 , max(i.due_date) keep (dense_rank last order by i.invoice_date) as due_date
                 , max(i.total_amount_due) keep (dense_rank last order by i.invoice_date) as tad
              from iss_card c
                 , acc_account_object ao
                 , acc_account a
                 , crd_invoice i
             where c.id            = l_card_id
               and ao.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
               and a.account_type  = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
               and ao.object_id    = c.id
               and a.id            = ao.account_id
               and decode(i_account_number, null, a.account_number, i_account_number) = a.account_number
               and i.account_id(+) = a.id
               and i.split_hash(+) = a.split_hash
          group by a.account_number
                 , a.id
                 , a.split_hash
                 , a.currency
        )
        select i.account_number
             , i.account_id
             , i.currency
             , sum(d.amount) as amount_due
             , coalesce(i.tad
                      , sum(case when bt.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER then 0 else nvl(d.amount, 0) end)
               ) as total_amount_due
          from invoice i
             , (select d.*
                  from crd_debt d
                     , invoice  i
                 where decode(d.status, 'DBTSACTV', d.account_id, null) = i.account_id
                   and d.split_hash = i.split_hash
                   and d.is_new = com_api_const_pkg.TRUE
                 union
                select d.*
                  from crd_debt d
                     , invoice  i
                 where decode(d.is_new, com_api_const_pkg.TRUE, d.account_id, null) = i.account_id
                   and d.split_hash = i.split_hash
                   and d.is_new = com_api_const_pkg.TRUE
               ) d
             , crd_debt_balance bt
         where d.account_id(+)  = i.account_id
           and bt.debt_id(+)    = d.id
           and bt.split_hash(+) = d.split_hash
      group by i.account_number
             , i.account_id
             , i.currency
             , i.tad;
exception
    when others then
        trc_log_pkg.debug(
            i_text  => LOG_PREFIX || sqlerrm
        );
        raise;
end get_fin_overview_list;

procedure get_fin_overview_fee_list(
    i_account_id        in     com_api_type_pkg.t_account_id
  , o_ref_cursor           out sys_refcursor
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_fin_overview_fee_list: ';
begin
    open o_ref_cursor for
        select o.fee_amount    as fee_amount
             , o.fee_currency  as fee_currency
             , o.oper_reason   as fee_type
          from opr_operation   o
             , opr_participant p
         where o.oper_reason   like '%FETP%'
           and o.id               = p.oper_id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and p.account_id       = i_account_id;
exception
    when others then
        trc_log_pkg.debug(
            i_text  => LOG_PREFIX || sqlerrm
        );
        raise;
end get_fin_overview_fee_list;

procedure get_crd_card_payment_list(
    i_card_number       in     com_api_type_pkg.t_card_number
  , i_account_number    in     com_api_type_pkg.t_account_number  default null
  , i_inst_id           in     com_api_type_pkg.t_inst_id         default null
  , o_ref_cursor           out sys_refcursor
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_crd_card_payment_list: ';
    l_card_id                    com_api_type_pkg.t_account_id;
begin
    l_card_id := iss_api_card_pkg.get_card_id(
                     i_card_number => i_card_number
                   , i_inst_id     => i_inst_id
                 );

    open o_ref_cursor for
        select a.account_number as account_number
             , a.id as account_id
             , a.currency as currency
             , max(min_amount_due)   keep (dense_rank last order by invoice_date) as min_amount_due
             , max(total_amount_due) keep (dense_rank last order by invoice_date) as total_amount_due
             , max(due_date)         keep (dense_rank last order by invoice_date) as due_date
          from acc_account_object o
             , acc_account a
             , iss_card c
             , crd_invoice i
         where o.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
           and a.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
           and i.account_id   = a.id
           and i.split_hash   = a.split_hash
           and o.object_id    = c.id
           and a.id           = o.account_id
           and c.id           = l_card_id
           and decode(i_account_number, null, a.account_number, i_account_number) = a.account_number
      group by a.account_number
             , a.id
             , a.currency;
exception
    when others then
        trc_log_pkg.debug(
            i_text  => LOG_PREFIX || sqlerrm
        );
        raise;
end get_crd_card_payment_list;

procedure get_crd_account_payment_list(
    i_account_id        in       com_api_type_pkg.t_account_id
  , o_ref_cursor        out      sys_refcursor
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_crd_account_payment_list: ';
begin
    open o_ref_cursor for
        select o.originator_refnum
             , c.pay_amount
             , c.currency
             , d.sttl_date as payment_date
          from opr_operation o
             , crd_payment c
             , com_settlement_day d
         where o.id = c.oper_id
           and d.sttl_day(+) = c.sttl_day
           and decode(c.status, 'PMTSACTV', c.account_id, null) = i_account_id;
exception
    when others then
        trc_log_pkg.debug(
            i_text  => LOG_PREFIX || sqlerrm
        );
        raise;
end get_crd_account_payment_list;

procedure accelerate_dpp(
    i_external_auth_id        in     com_api_type_pkg.t_attr_name
  , i_new_count               in     com_api_type_pkg.t_tiny_id    default null
  , i_payment_amount          in     com_api_type_pkg.t_money      default null
  , i_acceleration_type       in     com_api_type_pkg.t_dict_value
  , i_check_mad_aging_unpaid  in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name        := lower($$PLSQL_UNIT) || '.accelerate_dpp: ';
begin
    trc_log_pkg.debug(
        i_text  => LOG_PREFIX || 'Start'
    );
    dpp_api_payment_plan_pkg.accelerate_dpp(
        i_external_auth_id        =>  i_external_auth_id
      , i_new_count               =>  i_new_count
      , i_payment_amount          =>  i_payment_amount
      , i_acceleration_type       =>  i_acceleration_type
      , i_check_mad_aging_unpaid  =>  i_check_mad_aging_unpaid
    );
    trc_log_pkg.debug(
        i_text  => LOG_PREFIX || 'Finish success'
    );
end accelerate_dpp;

procedure get_customer_info(
    i_card_number         in     com_api_type_pkg.t_card_number
  , i_inst_id             in     com_api_type_pkg.t_inst_id         default null
  , i_lang                in     com_api_type_pkg.t_dict_value      default null
  , o_customer_id            out com_api_type_pkg.t_medium_id
  , o_customer_number        out com_api_type_pkg.t_name
  , o_customer_name          out com_api_type_pkg.t_name
  , o_national_id            out com_api_type_pkg.t_name
  , o_customer_document      out com_api_type_pkg.t_name
  , o_customer_phone         out com_api_type_pkg.t_name
  , o_card_id                out com_api_type_pkg.t_name
  , o_card_seq_number        out com_api_type_pkg.t_inst_id
  , o_card_expiry_date       out date
  , o_branch_code            out com_api_type_pkg.t_name
  , o_client_tariff          out com_api_type_pkg.t_name
  , o_address_cursor         out sys_refcursor
  , o_account_cursor         out sys_refcursor
) is
    l_lang                       com_api_type_pkg.t_dict_value;
    l_card_id                    com_api_type_pkg.t_account_id;
begin
    l_lang := coalesce(i_lang, get_user_lang());

    select c.customer_id as customer_id
         , p.customer_number as customer_number
         , com_ui_object_pkg.get_object_desc(i_entity_type => p.entity_type
                                           , i_object_id   => p.object_id
                                           , i_lang        => l_lang
           ) as customer_name
         , (select com_api_dictionary_pkg.get_article_text(id_series || ' ' || id_number)
              from com_id_object
             where id = (select max(id)
                           from com_id_object
                          where entity_type = p.entity_type
                            and object_id   = p.object_id
                            and id_type     = com_api_const_pkg.ID_TYPE_NATIONAL_ID
                        )
           ) as national_id
         , com_ui_id_object_pkg.get_id_card_desc(i_entity_type => p.entity_type
                                               , i_object_id   => p.object_id
                                               , i_lang        => l_lang
           ) as customer_document
         , c.id as card_id
      into o_customer_id
         , o_customer_number
         , o_customer_name
         , o_national_id
         , o_customer_document
         , l_card_id
      from iss_card_number n
         , iss_card c
         , prd_customer p
     where c.id          = n.card_id
       and p.id          = c.customer_id
       and p.split_hash  = c.split_hash
       and n.card_number = i_card_number
       and (c.inst_id    = i_inst_id or i_inst_id is null);

    o_card_id := nvl(iss_api_card_pkg.get_card_uid_by_id(l_card_id), l_card_id);

    select seq_number   as card_seq_number
         , expir_date   as card_expiry_date
         , agent_number as branch_code
         , null         as client_tariff
      into o_card_seq_number
         , o_card_expiry_date
         , o_branch_code
         , o_client_tariff
      from (select i.seq_number
                 , i.expir_date
                 , ost_ui_agent_pkg.get_agent_number(i.agent_id) as agent_number
              from iss_card_instance i
                 , iss_card_number n
                 , iss_card c
             where n.card_id    = i.card_id
               and i.status     in (iss_api_const_pkg.CARD_STATUS_VALID_CARD
                                  , iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED)
               and i.card_id    = c.id
               and i.split_hash = c.split_hash
               and c.id         = l_card_id
               and (c.inst_id   = i_inst_id or i_inst_id is null)
          order by i.seq_number desc
           )
     where rownum = 1;

    select min(d.commun_address) keep (dense_rank first order by d.commun_method)
      into o_customer_phone
      from com_contact_object o
         , com_contact_data d
         , iss_card c
     where d.contact_id     = o.contact_id
       and o.object_id      = c.customer_id
       and o.entity_type    = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
       and c.id             = l_card_id
       and d.commun_method in (com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                             , com_api_const_pkg.COMMUNICATION_METHOD_PHONE)
       and (c.inst_id       = i_inst_id or i_inst_id is null);

    open o_address_cursor for
        select com_api_dictionary_pkg.get_article_text(
                   i_article => o.address_type
                 , i_lang    => l_lang
               ) as address_type
             , a.postal_code
             , a.country
             , a.region
             , a.city
             , a.street
             , a.house
             , a.apartment
          from com_address a
             , com_address_object o
             , iss_card c
         where o.object_id   = c.customer_id
           and o.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
           and a.id          = o.address_id
           and c.id          = l_card_id
           and a.lang        = l_lang
           and (c.inst_id    = i_inst_id or i_inst_id is null);

    open o_account_cursor for
        select a.id             as account_id
             , a.account_number as account_number
             , a.currency       as currency
             , get_percent_rate(i_account_id => o.account_id
                              , i_product_id => p.product_id
                              , i_split_hash => o.split_hash
                              , i_fee_type   => crd_api_const_pkg.INTEREST_RATE_FEE_TYPE
               )                as interest_rate
             , b.balance        as credit_limit
          from acc_account_object o
             , acc_account a
             , prd_contract p
             , acc_balance b
         where a.id              = o.account_id
           and a.split_hash      = o.split_hash
           and p.split_hash      = a.split_hash
           and o.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
           and p.id              = a.contract_id
           and b.account_id(+)   = o.account_id
           and b.balance_type(+) = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
           and o.object_id       = l_card_id
           and (a.inst_id        = i_inst_id or i_inst_id is null);
end get_customer_info;

procedure get_transaction (
    i_inst_id                    in       com_api_type_pkg.t_inst_id
  , i_customer_id                in       com_api_type_pkg.t_medium_id
  , i_lang                       in       com_api_type_pkg.t_dict_value      default null
  , i_masked_pan                 in       com_api_type_pkg.t_card_number     default null
  , i_account_number             in       com_api_type_pkg.t_account_number  default null
  , i_card_type_id               in       com_api_type_pkg.t_inst_id         default null
  , i_transaction_date_from      in       com_api_type_pkg.t_name            default null
  , i_transaction_date_to        in       com_api_type_pkg.t_name            default null
  , i_transaction_type           in       com_api_type_pkg.t_dict_value      default null
  , i_response_code              in       com_api_type_pkg.t_dict_value      default null
  , i_transactions_sorting       in       com_param_map_tpt                  default null
  , i_transaction_direction_sort in       com_api_type_pkg.t_name            default 'DESC'
  , o_transaction_cursor         out      sys_refcursor
)
is
    LOG_PREFIX          constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.get_transaction: ';
    l_customer_number            com_api_type_pkg.t_name    := null;
    l_ref_source                 com_api_type_pkg.t_text    := null;
    COLUMN_LIST         constant com_api_type_pkg.t_text    :=
        'select o.id              as id '                     ||
             ', o.oper_type       as operationType '          ||
             ', o.oper_amount     as operAmount '             ||
             ', o.oper_currency   as operCurrency '           ||
             ', o.oper_date       as operDate '               ||
             ', o.status          as status '                 ||
             ', case o.status_reason '                        ||
             '       when ''AUSR0101'' then '                 ||
             '            (select a.resp_code '               ||
             '               from aut_auth a '                ||
             '              where a.id = o.id) '              ||
             '       else o.status_reason '                   ||
             '  end               as statusReason '           ||
             ', c.card_mask       as cardMask '               ||
             ', c.card_number     as cardNumber '             ||
             ', n.name            as cardType '               ||
             ', p.customer_id     as customerId '             ||
             ', p.inst_id         as acqInstId '              ||
             ', o.terminal_number as terminalNumber '         ||
             ', p.account_number  as accountNumber '          ||
             ', o.is_reversal     as isReversal '             ||
             ', case com_api_array_pkg.is_element_in_array( ' ||
             '             i_array_id   => 10000011 '         ||
             '           , i_elem_value => o.oper_type) '     ||
             '       when 1 then ''credit'''                  ||
             '       else ''debit'''                          ||
             '  end               as debitCreditSign ';

    SOURCE_LIST         constant com_api_type_pkg.t_text    :=
          'from opr_operation o '                                              ||
             ', opr_participant p '                                            ||
             ', iss_ui_card_vw c '                                             ||
             ', net_ui_card_type_vw n '                                        ||
             ', (select :p_inst_id               as p_inst_id '                ||
                     ', :p_customer_id           as p_customer_id '            ||
                     ', :p_lang                  as p_lang '                   ||
                     ', :p_masked_pan            as p_masked_pan '             ||
                     ', :p_card_type_id          as p_card_type_id '           ||
                     ', :p_account_number        as p_account_number '         ||
                     ', :p_transaction_date_from as p_transaction_date_from '  ||
                     ', :p_transaction_date_to   as p_transaction_date_to '    ||
                     ', :p_transaction_type      as p_transaction_type '       ||
                     ', :p_response_code         as p_response_code '          ||
                  'from dual '                                                 ||
               ') x '                                                          ||
         'where o.id             = p.oper_id '                                 ||
           'and c.id             = p.card_id '                                 ||
           'and n.id             = c.card_type_id '                            ||
           'and p.inst_id        = x.p_inst_id '                               ||
           'and p.customer_id    = x.p_customer_id '                           ||
           'and n.lang           = nvl(x.p_lang, n.lang) '                     ||
           'and c.card_mask      = nvl(x.p_masked_pan, c.card_mask) '          ||
           'and c.card_type_id   = nvl(x.p_card_type_id, c.card_type_id) '     ||
           'and p.account_number = nvl(x.p_account_number, p.account_number) ' ||
           'and o.oper_type      = nvl(x.p_transaction_type, o.oper_type) '    ||
           'and o.status_reason  = nvl(x.p_response_code, o.status_reason) ';

    DATE_CONDITIONS     constant com_api_type_pkg.t_text    :=
           'and o.oper_date >= case '                                              ||
                                'when x.p_transaction_date_from is not null then ' ||
                                  'to_date(x.p_transaction_date_from, '            ||
                                          '''YYYY-MM-DD HH24:MI:SS'') '            ||
                                'else o.oper_date '                                ||
                              'end '                                               ||
           'and o.oper_date <= case '                                              ||
                                'when x.p_transaction_date_to is not null then '   ||
                                  'to_date(x.p_transaction_date_to, '              ||
                                          '''YYYY-MM-DD HH24:MI:SS'') '            ||
                                'else o.oper_date '                                ||
                              'end ';

    function get_sorting_param return com_api_type_pkg.t_text is
        l_result            com_api_type_pkg.t_text;
    begin
        if i_transactions_sorting is not null then
            select nvl2(list, 'order by ' || list, '')
              into l_result
              from (select rtrim(xmlagg(
                                 xmlelement(e, name || ' ' || char_value, ',').extract('//text()')), ',') list
                      from table(cast(i_transactions_sorting as com_param_map_tpt))
                   );
        elsif upper(i_transaction_direction_sort) = 'ASC' then
            l_result := 'order by o.oper_date';
        else
            l_result := 'order by o.oper_date desc';
        end if;
        return l_result;
    exception
        when no_data_found then
            return null;
        when others then
            trc_log_pkg.debug(
                i_text  => LOG_PREFIX || sqlerrm
            );
            raise;
    end;
begin

    l_customer_number := prd_api_customer_pkg.get_customer_number(
        i_customer_id => i_customer_id
      , i_inst_id     => i_inst_id
      , i_mask_error  => com_api_const_pkg.FALSE
    );

    l_ref_source := COLUMN_LIST || SOURCE_LIST || DATE_CONDITIONS || get_sorting_param();

    open o_transaction_cursor for l_ref_source
    using i_inst_id
        , i_customer_id
        , i_lang
        , i_masked_pan
        , i_card_type_id
        , i_account_number
        , i_transaction_date_from
        , i_transaction_date_to
        , i_transaction_type
        , i_response_code;

exception
    when others then
        trc_log_pkg.debug(
            i_text  => LOG_PREFIX || sqlerrm
        );
    raise;
end get_transaction;

procedure get_product(
    i_inst_id           in       com_api_type_pkg.t_inst_id
  , i_customer_id       in       com_api_type_pkg.t_medium_id
  , i_lang              in       com_api_type_pkg.t_dict_value      default null
  , o_product_cursor        out  sys_refcursor
)
is
    LOG_PREFIX          constant com_api_type_pkg.t_name        := lower($$PLSQL_UNIT) || '.get_product: ';
    l_customer_number            com_api_type_pkg.t_name;
    l_row_count                  com_api_type_pkg.t_tiny_id;
    l_lang                       com_api_type_pkg.t_dict_value;
begin

    l_lang := coalesce(i_lang, get_user_lang);

    -- Check that customer is found
    l_customer_number := prd_api_customer_pkg.get_customer_number(
        i_customer_id => i_customer_id
      , i_inst_id     => i_inst_id
      , i_mask_error  => com_api_const_pkg.FALSE
    );

    select count(1)
      into l_row_count
      from prd_product p
     where p.id in (select c.product_id from prd_contract c where c.customer_id = i_customer_id);

    if l_row_count = 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'PRODUCT_NOT_FOUND_BY_CUSTOMER'
          , i_env_param1 => i_customer_id
          , i_env_param2 => i_inst_id
          , i_env_param3 => i_lang
        );
    end if;

    open o_product_cursor for
        select level
             , connect_by_isleaf as isLeaf
             , t.id              as id
             , get_text(
                   i_table_name  => 'prd_product'
                 , i_column_name => 'label'
                 , i_object_id   => t.id
                 , i_lang        => l_lang
               )                 as name
             , get_text(
                   i_table_name  => 'prd_product'
                 , i_column_name => 'description'
                 , i_object_id   => t.id
                 , i_lang        => l_lang
               )                 as description
             , t.parent_id       as parentId
          from (
            select distinct
                   p.parent_id
                 , p.id
              from prd_product p
             connect by prior p.parent_id = p.id
               start with p.id in (select c.product_id from prd_contract c where c.customer_id = i_customer_id)
        ) t
        connect by prior t.id = parent_id
          start with t.parent_id is null
          order siblings by t.id asc;

exception
    when others then
        trc_log_pkg.debug(
            i_text  => LOG_PREFIX || sqlerrm
        );
    raise;
end get_product;

procedure get_dictionaries(
    i_dict_version         in    com_api_type_pkg.t_name
  , i_array_dictionary_id  in    com_api_type_pkg.t_medium_id     default null
  , i_lang                 in    com_api_type_pkg.t_dict_value    default null
  , i_inst_id              in    com_api_type_pkg.t_inst_id       default null
  , io_xml                 in out nocopy clob
) is
    CRLF      constant com_api_type_pkg.t_name      := chr(13) || chr(10);
    l_result           com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text        => 'itf_ui_integration_pkg.get_dictionaries: START with i_dict_version [#1], i_array_dictionary_id [#2], i_lang [#3], i_inst_id [#4]'
      , i_env_param1  => i_dict_version
      , i_env_param2  => i_array_dictionary_id
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    if i_inst_id is not null and i_inst_id <> ost_api_const_pkg.DEFAULT_INST then
        ost_api_institution_pkg.check_institution(
            i_inst_id => i_inst_id
        );
    end if;

    if i_dict_version is null then
        com_api_error_pkg.raise_error(
            i_error      => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1 => i_dict_version
        );
    end if;

    l_result :=
        com_itf_dict_pkg.execute_dict_query(
            i_dict_version         => i_dict_version
          , i_array_dictionary_id  => i_array_dictionary_id
          , i_inst_id              => i_inst_id
          , i_entry_point          => com_api_const_pkg.ENTRYPOINT_WEBSERVICE
          , i_lang                 => i_lang
          , io_xml                 => io_xml
        );

    if l_result = 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'REQUESTED_DATA_NOT_FOUND'
          , i_env_param1 => 'ENTT0047'
        );
    end if;

    io_xml := com_api_const_pkg.XML_HEADER || CRLF || io_xml;

    trc_log_pkg.debug('itf_ui_integration_pkg.get_dictionaries: FINISH');

end get_dictionaries;

procedure get_currency_rates(
    i_inst_id              in            com_api_type_pkg.t_inst_id        default null
  , i_base_rate_export     in            com_api_type_pkg.t_boolean        default null
  , i_rate_type            in            com_api_type_pkg.t_dict_value     default null
  , i_eff_date             in            date                              default null
  , i_dict_version         in            com_api_type_pkg.t_name
  , io_xml                 in out nocopy clob
) is
    CRLF      constant com_api_type_pkg.t_name      := chr(13) || chr(10);
    l_result           com_api_type_pkg.t_short_id;
    l_eff_date         date;

    l_event_tab        com_api_type_pkg.t_number_tab;
    l_rate_id_tab      num_tab_tpt;

    l_full_export      com_api_type_pkg.t_boolean;
    l_xml              clob;

begin
    trc_log_pkg.debug(
        i_text        => 'itf_ui_integration_pkg.get_currency_rates: START with i_inst_id [#1], i_base_rate_export [#2], i_rate_type [#3], i_eff_date [#4], i_dict_version [#5]'
      , i_env_param1  => i_inst_id
      , i_env_param2  => i_base_rate_export
      , i_env_param3  => i_rate_type
      , i_env_param4  => to_char(i_eff_date, com_api_const_pkg.DATE_FORMAT)
      , i_env_param5  => i_dict_version
    );

    if i_inst_id is null then
        com_api_error_pkg.raise_error(
            i_error      => 'INSTITUTION_IS_NOT_DEFINED'
          , i_env_param1 => i_inst_id
        );
    elsif i_inst_id <> ost_api_const_pkg.DEFAULT_INST then
        ost_api_institution_pkg.check_institution(
            i_inst_id => i_inst_id
        );
    end if;

    if i_dict_version is null then
        com_api_error_pkg.raise_error(
            i_error      => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1 => i_dict_version
        );
    end if;

    l_full_export := com_api_const_pkg.TRUE;
    l_eff_date    := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

    l_result :=
        com_itf_dict_pkg.execute_rate_query(
            i_count_query_only          => null
          , i_get_rate_id_tab           => com_api_const_pkg.TRUE
          , i_dict_version              => i_dict_version
          , i_inst_id                   => i_inst_id
          , i_eff_date                  => l_eff_date
          , i_full_export               => l_full_export
          , i_base_rate_export          => null
          , i_rate_type                 => i_rate_type
          , i_replace_inst_id_by_number => com_api_type_pkg.FALSE
          , i_entry_point               => com_api_const_pkg.ENTRYPOINT_WEBSERVICE
          , io_xml                      => l_xml
          , io_rate_id_tab              => l_rate_id_tab
          , io_event_tab                => l_event_tab
        );

    trc_log_pkg.debug('l_rate_id_tab.count=' || l_rate_id_tab.count);

    if l_rate_id_tab.count > 0 then
        l_result :=
            com_itf_dict_pkg.execute_rate_query(
                i_count_query_only          => com_api_const_pkg.FALSE
              , i_get_rate_id_tab           => com_api_const_pkg.FALSE
              , i_dict_version              => i_dict_version
              , i_inst_id                   => i_inst_id
              , i_eff_date                  => l_eff_date
              , i_full_export               => l_full_export
              , i_base_rate_export          => i_base_rate_export
              , i_rate_type                 => i_rate_type
              , i_replace_inst_id_by_number => com_api_const_pkg.FALSE
              , i_entry_point               => com_api_const_pkg.ENTRYPOINT_WEBSERVICE
              , io_xml                      => io_xml
              , io_rate_id_tab              => l_rate_id_tab
              , io_event_tab                => l_event_tab
            );

        io_xml := com_api_const_pkg.XML_HEADER || CRLF || io_xml;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'REQUESTED_DATA_NOT_FOUND'
          , i_env_param1 => 'ENTT0055'
        );
    end if;

    trc_log_pkg.debug('itf_ui_integration_pkg.get_currency_rates: FINISH');

end get_currency_rates;

procedure get_mcc(
    i_lang                 in     com_api_type_pkg.t_dict_value    default null
  , i_dict_version         in     com_api_type_pkg.t_name
  , o_xml                     out clob
) is
    CRLF          constant        com_api_type_pkg.t_name          := chr(13) || chr(10);
    l_result                      com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text        => 'itf_ui_integration_pkg.get_mcc: START with i_lang [#1], i_dict_version [#2]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_dict_version
    );

    l_result :=
        com_itf_dict_pkg.execute_mcc_query(
            i_dict_version => i_dict_version
          , i_lang         => i_lang
          , i_entry_point  => com_api_const_pkg.ENTRYPOINT_WEBSERVICE
          , o_xml          => o_xml
        );

    o_xml := com_api_const_pkg.XML_HEADER || CRLF || o_xml;

    trc_log_pkg.debug('itf_ui_integration_pkg.get_mcc: FINISH');

end get_mcc;

procedure get_unbilled_debts(
    i_inst_id              in      com_api_type_pkg.t_inst_id
  , i_account_id           in      com_api_type_pkg.t_long_id
  , i_account_number       in      com_api_type_pkg.t_account_number
  , o_unbilled_debt           out  sys_refcursor
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_unbilled_debts: ';
    l_account_rec          acc_api_type_pkg.t_account_rec;
    l_service_id           com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'start inst [#1], account [#2] account number [#3]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_account_id
      , i_env_param3 => i_account_number
    );

    l_account_rec := acc_api_account_pkg.get_account(
        i_inst_id        => i_inst_id
      , i_account_id     => i_account_id
      , i_account_number => i_account_number
      , i_mask_error     => com_api_const_pkg.FALSE
    );

    trc_log_pkg.debug(
        i_text       => 'account id [#1]'
      , i_env_param1 => l_account_rec.account_id
    );

    l_service_id := crd_api_service_pkg.get_active_service(
        i_account_id => l_account_rec.account_id
      , i_eff_date   => get_sysdate
      , i_split_hash => l_account_rec.split_hash
      , i_mask_error => com_api_const_pkg.FALSE
    );

    open o_unbilled_debt for
        select d.id                         as debt_id
             , d.card_id
             , iss_api_card_pkg.get_card_mask(
                   i_card_number => cn.card_number
               )                            as card_mask
             , d.sttl_type
             , d.oper_type
             , get_article_text(
                   i_article => d.oper_type
               )                            as oper_type_desc
             , d.terminal_type
             , get_article_text(
                   i_article => d.terminal_type
               )                            as terminal_type_desc
             , o.merchant_name
             , o.merchant_number
             , d.oper_date
             , d.posting_date
             , d.amount                     as oper_amount
             , d.currency                   as oper_currency
             , d.debt_amount
             , d.currency                   as debt_currency
             , d.mcc
          from acc_account a
      join crd_debt d on decode(d.is_new, 1, d.account_id, null) = a.id
                         and d.is_reversal = com_api_const_pkg.FALSE
          left join iss_card_number cn on d.card_id = cn.card_id
          left join opr_operation o on d.oper_id = o.id
         where a.id = l_account_rec.account_id
           and not exists (
               select 1
                 from crd_debt_interest di
                where d.id = di.debt_id
                  and (di.is_charged = com_api_const_pkg.TRUE
                       or di.interest_amount > 0)
           );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'done'
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'fail [#1]'
          , i_env_param1 => sqlerrm
        );
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        else
            raise;
        end if;
end get_unbilled_debts;

procedure import_pmo_response(
    i_pmo_response_tab      in      pmo_response_tpt            default pmo_response_tpt()
  , i_create_operation      in      com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
) is
    l_resp_amount_rec       com_api_type_pkg.t_amount_rec;
begin
    for i in 1 .. i_pmo_response_tab.count loop
        l_resp_amount_rec           := null;
        l_resp_amount_rec.amount    := i_pmo_response_tab(i).amount;
        l_resp_amount_rec.currency  := i_pmo_response_tab(i).currency;

        pmo_api_order_pkg.process_pmo_response(
            i_order_id          => i_pmo_response_tab(i).order_id
          , i_resp_code         => i_pmo_response_tab(i).resp_code
          , i_resp_amount_rec   => l_resp_amount_rec
        );

        if i_create_operation = com_api_const_pkg.TRUE then
            pmo_prc_import_pkg.create_order_operation(
                i_order_id      => i_pmo_response_tab(i).order_id
            );
        end if;
    end loop;
end import_pmo_response;

procedure export_pmo(
    i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_purpose_id                in      com_api_type_pkg.t_short_id     default null
  , i_pmo_status_change_mode    in      com_api_type_pkg.t_dict_value   default null
  , i_max_count                 in      com_api_type_pkg.t_tiny_id      default null
  , o_ref_cursor                   out  com_api_type_pkg.t_ref_cur
) is
    cursor cu_order(
        p_inst_id               in      com_api_type_pkg.t_inst_id
      , p_purpose_id            in      com_api_type_pkg.t_short_id
      , p_sysdate               in      date
    ) is
        select o.id
             , o.inst_id
             , o.entity_type
             , o.object_id
             , o.split_hash
             , o.expiration_date
          from pmo_order o
             , pmo_purpose p
         where p.id             = o.purpose_id
           and o.event_date    <= p_sysdate
           and o.amount        >  0
           and decode(o.status, 'POSA0001', o.status, null) = pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC
           and (
                    o.inst_id       = p_inst_id
                or  p_inst_id       is null
                or  p_inst_id       = ost_api_const_pkg.DEFAULT_INST
               )
           and (
                    o.purpose_id    = p_purpose_id
                or  p_purpose_id    is null
               )
         order by o.id;

    l_object_id_tab             com_api_type_pkg.t_number_tab;
    l_entity_type_tab           com_api_type_pkg.t_dict_tab;
    l_split_hash_tab            com_api_type_pkg.t_number_tab;
    l_order_id_tab              com_api_type_pkg.t_number_tab;
    l_inst_id_tab               com_api_type_pkg.t_number_tab;
    l_expiration_date_tab       com_api_type_pkg.t_date_tab;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_order_id_out_tab          num_tab_tpt                     := num_tab_tpt();
    l_count                     com_api_type_pkg.t_count        := 0;
    l_max_count                 com_api_type_pkg.t_count        := nvl(i_max_count, 100);
    l_pmo_status_change_mode    com_api_type_pkg.t_dict_value;
begin
    open cu_order(
        p_inst_id               => i_inst_id
      , p_purpose_id            => i_purpose_id
      , p_sysdate               => com_api_sttl_day_pkg.get_sysdate
    );
    loop
        fetch cu_order bulk collect into
              l_order_id_tab
            , l_inst_id_tab
            , l_entity_type_tab
            , l_object_id_tab
            , l_split_hash_tab
            , l_expiration_date_tab
        limit l_max_count;

        for i in 1 .. l_order_id_tab.count loop
            exit when l_count > l_max_count;

            if pmo_api_order_pkg.check_is_pmo_expired(
                    i_expiration_date   => l_expiration_date_tab(i)
                  , i_order_id          => l_order_id_tab(i)
                  , i_entity_type       => l_entity_type_tab(i)
                  , i_object_id         => l_object_id_tab(i)
                  , i_inst_id           => l_inst_id_tab(i)
                  , i_split_hash        => l_split_hash_tab(i)
                  , i_param_tab         => l_param_tab
                ) = com_api_const_pkg.TRUE
            then
                continue;
            end if;

            l_pmo_status_change_mode := nvl(i_pmo_status_change_mode, pmo_api_const_pkg.PMO_SCM_MARK_ORDER_PROCESSED);

            if  l_pmo_status_change_mode = pmo_api_const_pkg.PMO_SCM_MARK_ORDER_PROCESSED
            then
                update pmo_order o
                   set o.status = pmo_api_const_pkg.PMO_STATUS_PROCESSED
                 where o.id     = l_order_id_tab(i);

                l_order_id_out_tab.extend;
                l_order_id_out_tab(l_order_id_out_tab.count) := l_order_id_tab(i);

                l_count := l_count + 1;
            else
                trc_log_pkg.debug(
                    i_text          => 'Status of the payment order [#1] isn''t changed for i_pmo_status_change_mode [#2]'
                  , i_env_param1    => l_order_id_tab(i)
                  , i_env_param2    => i_pmo_status_change_mode
                );
            end if;
        end loop;

        exit when cu_order%notfound;
    end loop;

    close cu_order;

    open o_ref_cursor for
        select o.id                 as order_id
             , c.customer_number    as customer_number
             , o.amount             as amount
             , o.currency           as currency
             , o.event_date         as event_date
             , o.purpose_id         as purpose_id
          from pmo_order o
             , prd_customer c
          where o.id in (select column_value from table(cast(l_order_id_out_tab as num_tab_tpt)))
            and o.customer_id  = c.id;
end export_pmo;

procedure export_pmo_data(
    i_order_id                  in      com_api_type_pkg.t_long_id
  , o_ref_cursor                   out  com_api_type_pkg.t_ref_cur
) is
begin
    open o_ref_cursor for
        select p.param_name
             , d.param_value
          from pmo_order_data d
             , pmo_parameter p
         where d.order_id = i_order_id
           and d.param_id = p.id
           and d.param_value is not null;
end export_pmo_data;

end itf_ui_integration_pkg;
/
