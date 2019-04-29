create or replace package body itf_prc_cardgen_pkg is
/************************************************************
 * CardGen processes <br />
 * Created by Kolodkina Y. (kolodkina@bpcbt.com) at 02.10.2014 <br />
 * Module: ITF_PRC_CARDGEN_PKG <br />
 * @headcom
 ************************************************************/

BULK_LIMIT             constant pls_integer := 400;
g_ber_tlv_min_length            com_api_type_pkg.t_tiny_id    default 127;
g_ber_tlv_add_length            com_api_type_pkg.t_short_id   default 32768;

g_errors_count                  com_api_type_pkg.t_long_id := 0;

type t_sess_file_rec is record (
    file_name               com_api_type_pkg.t_name
  , session_file_id         com_api_type_pkg.t_long_id
  , used                    com_api_type_pkg.t_boolean
);

type t_sess_file_rec_tab is table of t_sess_file_rec index by binary_integer;

g_sess_file_rec             t_sess_file_rec_tab;

--type t_tc_buffer is table of com_api_type_pkg.t_text index by binary_integer;

procedure check_cardholder_name(
    i_cardholder_name          in     com_api_type_pkg.t_name
  , i_check_cardholder_name    in     com_api_type_pkg.t_boolean
) is
    CARDHOLDER_NAME_SYMBOLS  constant com_api_type_pkg.t_name := '^[A-Z0-9 $()./-]+$';
begin
    -- Cardholder Name is correct according to the ISO 7813:2006, Section 7.1.2, Table 1 when:
    -- 1) The length of the Cardholder Name is >=2 and <=26.
    -- 2) The Cardholder Name does not start with one or more spaces.
    -- 3) Cardholder Name contains characters which are valid: hex[41..5A], hex[30..39], " ", "$", "(", ")", "-", ".", "/"

    if length(i_cardholder_name) > itf_api_const_pkg.CARDHOLDER_MAX_LENGTH then
        com_api_error_pkg.raise_error(
            i_error      => 'CARDHOLDER_NAME_IS_TOO_LONG'
          , i_env_param1 => i_cardholder_name
          , i_env_param2 => itf_api_const_pkg.CARDHOLDER_MAX_LENGTH
        );

    elsif length(i_cardholder_name) < itf_api_const_pkg.CARDHOLDER_MIN_LENGTH
      and i_cardholder_name != ' ' then
        com_api_error_pkg.raise_error(
            i_error      => 'CARDHOLDER_NAME_IS_TOO_SHORT'
          , i_env_param1 => i_cardholder_name
          , i_env_param2 => itf_api_const_pkg.CARDHOLDER_MIN_LENGTH
        );

    elsif substr(i_cardholder_name, 1, 1) = ' '
      and i_cardholder_name != ' ' then
        com_api_error_pkg.raise_error(
            i_error => 'CARDHOLDER_NAME_STARTED_WITH_SPACE'
          , i_env_param1 => i_cardholder_name
        );

    elsif i_check_cardholder_name = com_api_const_pkg.TRUE
      and not regexp_like(i_cardholder_name, CARDHOLDER_NAME_SYMBOLS)
      and i_cardholder_name != ' '
    then
        com_api_error_pkg.raise_error(
            i_error => 'INVALID_CARDHOLDER_NAME'
          , i_env_param1 => i_cardholder_name
        );

    end if;
end;

function get_tag_length(
    i_len                      in     com_api_type_pkg.t_tiny_id
) return varchar2
is
    l_result                   varchar2(4);
begin
    l_result :=
        case when i_len > g_ber_tlv_min_length
            then trim(to_char((i_len + g_ber_tlv_add_length), 'XXXX'))
            else lpad(trim(to_char(i_len, lpad('X', length(i_len), 'X'))), 2, '0')
        end;
    return l_result;
end;

function get_start_line(
    i_begin_line               in     com_api_type_pkg.t_lob_data
) return com_api_type_pkg.t_full_desc
is
    l_result                   com_api_type_pkg.t_full_desc;
begin
    l_result := 'DF805D' || '01' || '1';
    l_result := 'FF41'   || get_tag_length(length(i_begin_line) + length(l_result)) || l_result;
    l_result := 'DF805D' || '01' || '0' || l_result;
    l_result := 'FF4F'   || get_tag_length(length(l_result) + length(i_begin_line)) || l_result;

    return l_result;
end;

procedure clear_global_data is
begin
    trc_log_pkg.debug (
        i_text         => 'Clear global data'
    );
    g_sess_file_rec.delete;
end clear_global_data;

function set_header_line(
    i_inst_id                  in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_full_desc
is
    l_result       com_api_type_pkg.t_full_desc;
    l_line         com_api_type_pkg.t_full_desc;
    l_tmp          com_api_type_pkg.t_full_desc;
    l_file_type    com_api_type_pkg.t_dict_value;
begin
    l_file_type := 'FTYPOCGD';
    l_line := 'DF807D' || get_tag_length(length(l_file_type)) || l_file_type;

    l_tmp := to_char(get_sysdate, 'dd.mm.yyyy_HH24:MI:SS');
    l_line := l_line || 'DF807C' || get_tag_length(length(l_tmp)) || l_tmp;

    l_tmp := to_char(i_inst_id);
    l_line := l_line || 'DF8079' || get_tag_length(length(l_tmp)) || l_tmp;

    l_result := 'DF805D' || '01' || '2';
    l_result := 'FF49'   || get_tag_length(length(l_result) + length(l_line)) || l_result;
    l_result := 'DF805D' || '01' || '1' || l_result;
    l_result := 'FF45'   || get_tag_length(length(l_result) + length(l_line)) || l_result;

    l_result := l_result || l_line;

    return l_result;
end;

function set_trailer_line(
    i_record_count             in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_full_desc is

    l_result       com_api_type_pkg.t_full_desc;
begin

    l_result := to_char(i_record_count);
    l_result := 'DF807E' || get_tag_length(length(l_result)) || l_result;

    l_result := 'DF805D' || '01' || '2' || l_result;
    l_result := 'FF4A'   || get_tag_length(length(l_result)) || l_result;
    l_result := 'DF805D' || '01' || '1' || l_result;
    l_result := 'FF46'   || get_tag_length(length(l_result)) || l_result;

    return l_result;
end;

procedure collect_file_params (
    i_batch_card_rec        in prs_api_type_pkg.t_batch_card_rec
  , i_card_info_rec         in prs_api_type_pkg.t_card_info_rec
  , io_params               in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    rul_api_param_pkg.set_param (
        i_name       => 'INST_ID'
      , i_value      => i_batch_card_rec.inst_id
      , io_params    => io_params
    );

    itf_cst_cardgen_pkg.collect_file_params (
        i_batch_card_rec  => i_batch_card_rec
      , i_card_info_rec   => i_card_info_rec
      , io_params         => io_params
    );
end collect_file_params;

procedure open_file (
    i_batch_card_rec     in     prs_api_type_pkg.t_batch_card_rec
  , i_card_info_rec      in     prs_api_type_pkg.t_card_info_rec
  , o_sess_file_id          out com_api_type_pkg.t_long_id
) is
    l_params                com_api_type_pkg.t_param_tab;
    l_file_name             com_api_type_pkg.t_name;
    l_line                  com_api_type_pkg.t_lob_data;
begin
    collect_file_params (
        i_batch_card_rec  => i_batch_card_rec
      , i_card_info_rec   => i_card_info_rec
      , io_params         => l_params
    );
    l_file_name := nvl(
                       prc_api_file_pkg.get_default_file_name (
                           io_params  => l_params
                       ), ''
                   );

    for i in 1..g_sess_file_rec.count loop
        if g_sess_file_rec(i).file_name = l_file_name then
            o_sess_file_id := g_sess_file_rec(i).session_file_id;
            return;
        end if;
    end loop;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => o_sess_file_id
      , io_params       => l_params
    );

    -- set cache
    g_sess_file_rec(nvl(g_sess_file_rec.count, 0) + 1).session_file_id := o_sess_file_id;
    g_sess_file_rec(nvl(g_sess_file_rec.count, 0)).file_name           := l_file_name;

     -- put header
    l_line := set_header_line(i_batch_card_rec.inst_id);

    prc_api_file_pkg.put_line(
        i_raw_data      => l_line
      , i_sess_file_id  => o_sess_file_id
    );
end open_file;

procedure close_file (
    i_status                in com_api_type_pkg.t_dict_value
) is
begin
    for i in 1..g_sess_file_rec.count loop
        prc_api_file_pkg.close_file(
            i_sess_file_id  => g_sess_file_rec(i).session_file_id
          , i_status        => i_status
        );
    end loop;
end close_file;

procedure put_line (
    i_raw_data           in com_api_type_pkg.t_lob_data
  , i_batch_card_rec     in prs_api_type_pkg.t_batch_card_rec
  , i_card_info_rec      in prs_api_type_pkg.t_card_info_rec
) is
    l_session_file_id       com_api_type_pkg.t_long_id;
begin
    open_file (
        i_batch_card_rec  => i_batch_card_rec
      , i_card_info_rec   => i_card_info_rec
      , o_sess_file_id    => l_session_file_id
    );

    prc_api_file_pkg.put_line (
        i_raw_data        => i_raw_data
      , i_sess_file_id    => l_session_file_id
    );

    for i in 1..g_sess_file_rec.count loop
        if g_sess_file_rec(i).session_file_id = l_session_file_id then
            g_sess_file_rec(i).used := com_api_type_pkg.TRUE;
            exit;
        end if;
    end loop;
end put_line;

procedure put_trailer is
    l_line                  com_api_type_pkg.t_lob_data;
begin
    for i in 1..g_sess_file_rec.count loop
        l_line := set_trailer_line(prc_api_file_pkg.get_record_number(i_sess_file_id => g_sess_file_rec(i).session_file_id) + 1);

        prc_api_file_pkg.put_line (
            i_raw_data        => l_line
          , i_sess_file_id    => g_sess_file_rec(i).session_file_id
        );
        prc_api_file_pkg.close_file (
            i_sess_file_id  => g_sess_file_rec(i).session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
        g_sess_file_rec.delete(i);
    end loop;
end put_trailer;

procedure mark_error (
    i_batch_card_rec     in prs_api_type_pkg.t_batch_card_rec
  , i_card_info_rec      in prs_api_type_pkg.t_card_info_rec
) is
    l_params                com_api_type_pkg.t_param_tab;
    l_file_name             com_api_type_pkg.t_name;
begin
    collect_file_params (
        i_batch_card_rec  => i_batch_card_rec
      , i_card_info_rec   => i_card_info_rec
      , io_params         => l_params
    );
    l_file_name := nvl(
                       prc_api_file_pkg.get_default_file_name (
                           io_params  => l_params
                       ), ''
                   );

    for i in 1..g_sess_file_rec.count loop
        if g_sess_file_rec(i).file_name = l_file_name and g_sess_file_rec(i).used = com_api_type_pkg.FALSE then
            g_sess_file_rec.delete(i);
            exit;
        end if;
    end loop;
end mark_error;

function get_line(
    i_param_value              in     com_api_type_pkg.t_param_value
  , i_tag_name                 in     com_api_type_pkg.t_name
  , i_line                     in     com_api_type_pkg.t_full_desc
) return com_api_type_pkg.t_full_desc
is
    l_result                   com_api_type_pkg.t_full_desc;
begin
    l_result := i_line || i_tag_name
                       || get_tag_length(length(i_param_value))
                       || i_param_value;

    return l_result;
end;

procedure process_1_0(
    i_perso_cur                in            sys_refcursor
  , i_batch_id                 in            com_api_type_pkg.t_short_id
  , i_estimated_count          in            com_api_type_pkg.t_long_id
  , o_excepted_count           in out nocopy com_api_type_pkg.t_long_id
  , o_processed_count          in out nocopy com_api_type_pkg.t_long_id
  , i_empty_address            in            com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
  , i_check_cardholder_name    in            com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
  , i_format_id                in            com_api_type_pkg.t_tiny_id default null
) is
    l_batch_card_tab           prs_api_type_pkg.t_batch_card_tab;
    l_card_info_tab            prs_api_type_pkg.t_card_info_tab;
    l_card_count               com_api_type_pkg.t_short_id;
    l_tags_value_tab           com_api_type_pkg.t_param_tab;
    l_curr_line                com_api_type_pkg.t_lob_data;
    l_add_line                 com_api_type_pkg.t_lob_data;
    l_name                     com_api_type_pkg.t_name;
    l_agent_adr_id             com_api_type_pkg.t_medium_id;
    l_lang                     com_api_type_pkg.t_dict_value;

    l_country_id               com_api_type_pkg.t_tiny_id;
    l_country_lang             com_api_type_pkg.t_dict_value;
    l_address_id               com_api_type_pkg.t_medium_id;

    procedure get_address(
        i_entity_type     in     com_api_type_pkg.t_dict_value
      , i_object_id       in     com_api_type_pkg.t_long_id
      , o_address_id         out com_api_type_pkg.t_medium_id
      , o_street             out com_api_type_pkg.t_double_name
      , o_house              out com_api_type_pkg.t_double_name
      , o_apartment          out com_api_type_pkg.t_double_name
      , o_postal_code        out com_api_type_pkg.t_name
      , o_city               out com_api_type_pkg.t_double_name
      , o_country            out com_api_type_pkg.t_name
      , o_region_code        out com_api_type_pkg.t_name
    ) is
    begin
        select id
             , street
             , house
             , apartment
             , postal_code
             , city
             , country
             , region_code
             , country_id
             , country_lang
          into o_address_id
             , o_street
             , o_house
             , o_apartment
             , o_postal_code
             , o_city
             , o_country
             , o_region_code
             , l_country_id
             , l_country_lang
          from (
              select ca.id
                   , ca.lang
                   , ca.country
                   , ca.region
                   , ca.city
                   , ca.street
                   , ca.house
                   , ca.apartment
                   , ca.postal_code
                   , ca.region_code
                   , ct.id as country_id
                   , ca.lang as country_lang
                   , ob.object_id
                   , row_number() over (partition by ob.object_id order by decode(ob.address_type, 'ADTPSTDL', -1, ob.address_id)) rn
                 from com_address ca
                    , com_address_object ob
                    , com_country ct
                where ca.id = ob.address_id
                  and ob.entity_type = i_entity_type
                  and ob.object_id   = i_object_id
                  and ct.code(+)     = ca.country
          )
        where rn = 1;

    exception when no_data_found then
        o_address_id := null;
    end get_address;

begin
    o_excepted_count  := 0;
    o_processed_count := 0;

    l_card_count      := i_estimated_count;

    loop
        fetch i_perso_cur bulk collect into l_batch_card_tab limit BULK_LIMIT;

        l_card_info_tab.delete;

        for i in 1 .. l_batch_card_tab.count loop
            begin
                savepoint processing_next_card;

                l_address_id := null;

                trc_log_pkg.debug(
                    i_text          => 'Card instance [#1], card number [#2]'
                    , i_env_param1  => l_batch_card_tab(i).card_instance_id
                    , i_env_param2  => l_batch_card_tab(i).card_mask
                );

                l_card_count := nvl(l_batch_card_tab(i).card_count, i_estimated_count);
                if o_processed_count >= l_card_count then
                    exit;
                end if;

                --geneate record
                trc_log_pkg.debug(
                    i_text          => 'record_number = ' || i
                );

                -- calculate required fields of "l_card_info_tab"
                begin
                    select pd.uid_format_id
                      into l_card_info_tab(i).uid_format_id
                      from iss_product_card_type pd
                     where pd.bin_id       = l_batch_card_tab(i).bin_id
                       and pd.product_id   = l_batch_card_tab(i).product_id
                       and pd.card_type_id = l_batch_card_tab(i).card_type_id
                       and l_batch_card_tab(i).seq_number between pd.seq_number_low and pd.seq_number_high;

                exception when no_data_found then
                    null;
                end;

                begin
                    select distinct first_value(a.account_number) over (order by o.usage_order, o.is_pos_default desc, o.is_atm_default desc)
                      into l_card_info_tab(i).card_account
                      from acc_account_object o
                         , acc_account a
                     where o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                       and o.object_id   = l_batch_card_tab(i).card_id
                       and a.id          = o.account_id
                       and a.status     != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED;

                exception when no_data_found then
                    null;
                end;

                begin
                    select cd.pvv
                         , cd.kcolb_nip
                         , cd.pin_offset
                      into l_card_info_tab(i).pvv
                         , l_card_info_tab(i).pin_block
                         , l_card_info_tab(i).pin_offset
                      from iss_card_instance_data cd
                     where cd.card_instance_id = l_batch_card_tab(i).card_instance_id;

                exception when no_data_found then
                    null;
                end;

                begin
                    select *
                      into l_card_info_tab(i).person_id
                         , l_card_info_tab(i).first_name
                         , l_card_info_tab(i).second_name
                         , l_card_info_tab(i).surname
                         , l_card_info_tab(i).suffix
                         , l_card_info_tab(i).gender
                         , l_card_info_tab(i).birthday
                      from (
                            select p.id
                                 , p.first_name
                                 , p.second_name
                                 , p.surname
                                 , p.suffix
                                 , p.gender
                                 , p.birthday
                              from iss_cardholder ch
                                 , com_person p
                             where ch.id      = l_batch_card_tab(i).cardholder_id
                               and ch.inst_id = l_batch_card_tab(i).inst_id
                               and p.id       = ch.person_id
                             order by decode(p.lang, l_batch_card_tab(i).lang, 1, com_api_const_pkg.LANGUAGE_ENGLISH, 2, 3)
                            )
                     where rownum = 1;

                exception when no_data_found then
                    null;
                end;

                if l_card_info_tab(i).person_id is null then
                    begin
                        select *
                          into l_card_info_tab(i).person_id
                             , l_card_info_tab(i).first_name
                             , l_card_info_tab(i).second_name
                             , l_card_info_tab(i).surname
                             , l_card_info_tab(i).suffix
                             , l_card_info_tab(i).gender
                             , l_card_info_tab(i).birthday
                          from (
                                select p.id
                                     , p.first_name
                                     , p.second_name
                                     , p.surname
                                     , p.suffix
                                     , p.gender
                                     , p.birthday
                                  from prd_customer cm
                                     , com_person p
                                 where cm.id = l_batch_card_tab(i).customer_id
                                   and p.id  = decode(cm.entity_type, com_api_const_pkg.ENTITY_TYPE_PERSON, cm.object_id, null)
                                 order by decode(p.lang, l_batch_card_tab(i).lang, 1, com_api_const_pkg.LANGUAGE_ENGLISH, 2, 3)
                                )
                         where rownum = 1;

                    exception when no_data_found then
                        null;
                    end;
                end if;

                get_address(
                    i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                  , i_object_id     => l_batch_card_tab(i).cardholder_id
                  , o_address_id    => l_address_id
                  , o_street        => l_card_info_tab(i).street
                  , o_house         => l_card_info_tab(i).house
                  , o_apartment     => l_card_info_tab(i).apartment
                  , o_postal_code   => l_card_info_tab(i).postal_code
                  , o_city          => l_card_info_tab(i).city
                  , o_country       => l_card_info_tab(i).country
                  , o_region_code   => l_card_info_tab(i).region_code
                );

                if l_address_id is null then
                    get_address(
                        i_entity_type   => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      , i_object_id     => l_batch_card_tab(i).customer_id
                      , o_address_id    => l_address_id
                      , o_street        => l_card_info_tab(i).street
                      , o_house         => l_card_info_tab(i).house
                      , o_apartment     => l_card_info_tab(i).apartment
                      , o_postal_code   => l_card_info_tab(i).postal_code
                      , o_city          => l_card_info_tab(i).city
                      , o_country       => l_card_info_tab(i).country
                      , o_region_code   => l_card_info_tab(i).region_code
                    );
                end if;

                l_batch_card_tab(i).card_number    := iss_api_token_pkg.decode_card_number(
                                                          i_card_number => l_batch_card_tab(i).card_number
                                                      );
                l_card_info_tab(i).agent_number    := ost_ui_agent_pkg.get_agent_number(
                                                          i_agent_id    => l_batch_card_tab(i).agent_id
                                                      );

                l_card_info_tab(i).product_name   := get_text('prd_product',    'label', l_batch_card_tab(i).product_id,   l_batch_card_tab(i).lang);
                l_card_info_tab(i).country_name   := get_text('com_country',     'name', l_country_id,                     l_country_lang);

                select prd.product_number
                  into l_card_info_tab(i).product_number
                  from prd_product prd
                 where prd.id = l_batch_card_tab(i).product_id;

                l_tags_value_tab.delete;

                -- calculate tags for record
                l_tags_value_tab('DF8007') := l_card_info_tab(i).person_id;
                l_tags_value_tab('DF8008') := com_api_dictionary_pkg.get_article_text(
                                                  i_article           => l_card_info_tab(i).gender
                                                , i_lang              => l_batch_card_tab(i).lang
                                              );
                l_tags_value_tab('DF800F') := l_batch_card_tab(i).company_name;
                l_tags_value_tab('DF8012') := case when l_batch_card_tab(i).lang is null then 'CLNG00'
                                                   when l_batch_card_tab(i).lang = com_api_const_pkg.LANGUAGE_ENGLISH then 'CLNG02'
                                                   else 'CLNG01'
                                              end;
                l_tags_value_tab('DF8018') := l_card_info_tab(i).suffix;
                l_tags_value_tab('DF8019') := l_card_info_tab(i).first_name;
                l_tags_value_tab('DF801A') := l_card_info_tab(i).second_name;
                l_tags_value_tab('DF801B') := l_card_info_tab(i).surname;
                l_tags_value_tab('DF801C') := to_char(l_card_info_tab(i).birthday, 'mmddyyyy');

                l_tags_value_tab('DF8020') := com_api_address_pkg.get_address_string(
                                                  i_street            => l_card_info_tab(i).street
                                                , i_house             => l_card_info_tab(i).house
                                                , i_apartment         => l_card_info_tab(i).apartment
                                                , i_inst_id           => l_batch_card_tab(i).inst_id
                                                , i_enable_empty      => i_empty_address
                                              );
                l_tags_value_tab('DF8021') := com_api_address_pkg.get_address_string(
                                                  i_city              => l_card_info_tab(i).city
                                                , i_inst_id           => l_batch_card_tab(i).inst_id
                                                , i_enable_empty      => i_empty_address
                                              );
                l_tags_value_tab('DF8022') := null;
                l_tags_value_tab('DF8023') := null;
                l_tags_value_tab('DF8024') := l_card_info_tab(i).region_code;
                l_tags_value_tab('DF8025') := com_api_country_pkg.get_external_country_code(
                                                  i_internal_country_code => l_card_info_tab(i).country
                                              );
                l_tags_value_tab('DF8026') := l_card_info_tab(i).postal_code;

                -- custom format of address string
                -- line 1
                com_cst_address_ver2_pkg.get_address_string(
                    i_country           => l_card_info_tab(i).country
                  , i_region            => l_card_info_tab(i).region_code
                  , i_city              => l_card_info_tab(i).city
                  , i_street            => l_card_info_tab(i).street
                  , i_house             => l_card_info_tab(i).house
                  , i_apartment         => l_card_info_tab(i).apartment
                  , i_postal_code       => l_card_info_tab(i).postal_code
                  , i_region_code       => l_card_info_tab(i).region_code
                  , i_inst_id           => l_batch_card_tab(i).inst_id
                  , i_tag_name          => 'DF8020'
                  , io_tag_value        => l_tags_value_tab('DF8020')
                  , i_card_id           => l_batch_card_tab(i).card_id
                  , i_card_instance_id  => l_batch_card_tab(i).card_instance_id
                );
                -- line 2
                com_cst_address_ver2_pkg.get_address_string(
                    i_country           => l_card_info_tab(i).country
                  , i_region            => l_card_info_tab(i).region_code
                  , i_city              => l_card_info_tab(i).city
                  , i_street            => l_card_info_tab(i).street
                  , i_house             => l_card_info_tab(i).house
                  , i_apartment         => l_card_info_tab(i).apartment
                  , i_postal_code       => l_card_info_tab(i).postal_code
                  , i_region_code       => l_card_info_tab(i).region_code
                  , i_inst_id           => l_batch_card_tab(i).inst_id
                  , i_tag_name          => 'DF8021'
                  , io_tag_value        => l_tags_value_tab('DF8021')
                  , i_card_id           => l_batch_card_tab(i).card_id
                  , i_card_instance_id  => l_batch_card_tab(i).card_instance_id
                );
                -- line 3
                com_cst_address_ver2_pkg.get_address_string(
                    i_country           => l_card_info_tab(i).country
                  , i_region            => l_card_info_tab(i).region_code
                  , i_city              => l_card_info_tab(i).city
                  , i_street            => l_card_info_tab(i).street
                  , i_house             => l_card_info_tab(i).house
                  , i_apartment         => l_card_info_tab(i).apartment
                  , i_postal_code       => l_card_info_tab(i).postal_code
                  , i_region_code       => l_card_info_tab(i).region_code
                  , i_inst_id           => l_batch_card_tab(i).inst_id
                  , i_tag_name          => 'DF8022'
                  , io_tag_value        => l_tags_value_tab('DF8022')
                  , i_card_id           => l_batch_card_tab(i).card_id
                  , i_card_instance_id  => l_batch_card_tab(i).card_instance_id
                );
                -- line 4
                com_cst_address_ver2_pkg.get_address_string(
                    i_country           => l_card_info_tab(i).country
                  , i_region            => l_card_info_tab(i).region_code
                  , i_city              => l_card_info_tab(i).city
                  , i_street            => l_card_info_tab(i).street
                  , i_house             => l_card_info_tab(i).house
                  , i_apartment         => l_card_info_tab(i).apartment
                  , i_postal_code       => l_card_info_tab(i).postal_code
                  , i_region_code       => l_card_info_tab(i).region_code
                  , i_inst_id           => l_batch_card_tab(i).inst_id
                  , i_tag_name          => 'DF8023'
                  , io_tag_value        => l_tags_value_tab('DF8023')
                  , i_card_id           => l_batch_card_tab(i).card_id
                  , i_card_instance_id  => l_batch_card_tab(i).card_instance_id
                );

                l_tags_value_tab('DF8003') := l_batch_card_tab(i).customer_id;
                l_tags_value_tab('DF802C') := l_batch_card_tab(i).card_number;
                l_tags_value_tab('DF802F') := l_batch_card_tab(i).card_type_id;
                l_tags_value_tab('DF8032') := to_char(l_batch_card_tab(i).start_date, 'mmddyyyy');
                l_tags_value_tab('DF8033') := l_card_info_tab(i).card_account;
                l_tags_value_tab('DF8034') := iss_api_bin_pkg.get_bin(
                                                  i_card_number => l_batch_card_tab(i).card_number
                                              ).bin_currency;

                ntf_api_notification_pkg.get_mobile_number(
                    i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                  , i_object_id     => l_batch_card_tab(i).cardholder_id
                  , i_contact_type  => com_api_const_pkg.CONTACT_TYPE_PRIMARY
                  , o_address       => l_tags_value_tab('DF8029')
                  , o_lang          => l_lang
                );

                check_cardholder_name(
                    i_cardholder_name       => l_batch_card_tab(i).cardholder_name
                  , i_check_cardholder_name => i_check_cardholder_name
                );
                l_tags_value_tab('DF8042') := l_batch_card_tab(i).cardholder_name;

                l_tags_value_tab('DF8074') := l_batch_card_tab(i).seq_number;
                l_tags_value_tab('DF8077') := nvl(l_card_info_tab(i).pin_offset, to_char(l_card_info_tab(i).pvv));
                l_tags_value_tab('DF8103') := l_card_info_tab(i).pvv;

                l_tags_value_tab('DF8078') := to_char(l_batch_card_tab(i).expir_date, 'mmyy');
                l_tags_value_tab('DF807A') := l_card_info_tab(i).agent_number;
                l_tags_value_tab('DF8178') := case l_batch_card_tab(i).embossing_request
                                                  when iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS
                                                  then 0
                                                  else 1
                                              end;

                l_tags_value_tab('DF817B') := case l_batch_card_tab(i).pin_mailer_request  -- l_pin_mailer_request
                                                  when iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT
                                                  then 'PINM0'
                                                  else 'PINM1'
                                              end;

                l_tags_value_tab('DF8203') := l_batch_card_tab(i).card_instance_id;

                l_tags_value_tab('DF8204') := case l_batch_card_tab(i).perso_priority
                                                  when iss_api_const_pkg.PERSO_PRIORITY_NORMAL
                                                  then 'CREF0'
                                                  else 'CREF1'
                                              end;

                if l_batch_card_tab(i).customer_id is not null then
                    select to_char(reg_date, 'ddmmyyyy')
                      into l_tags_value_tab('DF8219')
                      from prd_customer
                     where id = l_batch_card_tab(i).customer_id;
                end if;

                --l_tags_value_tab('DF8261') := l_card_info_tab(i).id_series || l_card_info_tab(i).id_number;
                l_tags_value_tab('DF8354') := l_batch_card_tab(i).blank_type_id;
                l_tags_value_tab('DF8235') := to_char(l_batch_card_tab(i).inst_id, com_api_const_pkg.XML_NUMBER_FORMAT);

                --agent address
                if l_batch_card_tab(i).agent_id is not null then
                    begin
                        select address_id
                          into l_agent_adr_id
                          from com_address_object o
                         where o.object_id    = l_batch_card_tab(i).agent_id
                           and o.entity_type  = ost_api_const_pkg.ENTITY_TYPE_AGENT
                           and o.address_type = 'ADTPBSNA';

                        l_tags_value_tab('DF841A') := com_api_address_pkg.get_address_string(
                                                          i_address_id      => l_agent_adr_id
                                                        , i_lang            => l_batch_card_tab(i).lang
                                                        , i_inst_id         => l_batch_card_tab(i).inst_id
                                                      );
                    exception
                        when no_data_found then
                            null;
                    end;
                end if;

                l_tags_value_tab('DF8474') := i_batch_id;

                l_tags_value_tab('DF8043') := l_batch_card_tab(i).supplementary_info_1;

                --geneate ber_tlv
                l_curr_line := '';

                l_name := l_tags_value_tab.first;
                while l_name is not null loop
                    if l_tags_value_tab(l_name) is not null then
                        l_curr_line := l_curr_line
                                    || l_name
                                    || get_tag_length(length(l_tags_value_tab(l_name)))
                                    || l_tags_value_tab(l_name);
                    end if;

                    l_name := l_tags_value_tab.next(l_name);
                end loop;

                --user exit procedure
                itf_cst_cardgen_pkg.get_add_data(
                    i_batch_card_rec => l_batch_card_tab(i)
                  , i_card_info_rec  => l_card_info_tab(i)
                  , o_add_line       => l_add_line
                );
                l_curr_line := l_curr_line || l_add_line;

                --add begin tags
                l_curr_line := get_start_line(l_curr_line) || l_curr_line;

                -- put line
                put_line (
                    i_raw_data       => l_curr_line
                  , i_batch_card_rec => l_batch_card_tab(i)
                  , i_card_info_rec  => l_card_info_tab(i)
                );

                trc_log_pkg.debug(
                    i_text          => 'l_curr_line = ' || l_curr_line
                );

            exception
                when others then
                    rollback to savepoint processing_next_card;

                    trc_log_pkg.debug(
                        i_text => sqlerrm
                    );

                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
                        o_excepted_count := o_excepted_count + 1;

                        mark_error (
                            i_batch_card_rec  => l_batch_card_tab(i)
                          , i_card_info_rec   => l_card_info_tab(i)
                        );
                    else
                        raise;
                    end if;
            end;

            o_processed_count := o_processed_count + 1;
        end loop;

        prc_api_stat_pkg.log_current(
            i_current_count   => o_processed_count
          , i_excepted_count  => o_excepted_count
        );

        exit when i_perso_cur%notfound or o_processed_count >= l_card_count;
    end loop;

exception
    when others then
        close_file (
            i_status  => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
        raise;
end process_1_0;

procedure process(
    i_perso_cur                in            sys_refcursor
  , i_batch_id                 in            com_api_type_pkg.t_short_id
  , i_estimated_count          in            com_api_type_pkg.t_long_id
  , o_excepted_count           in out nocopy com_api_type_pkg.t_long_id
  , o_processed_count          in out nocopy com_api_type_pkg.t_long_id
  , i_empty_address            in            com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
  , i_check_cardholder_name    in            com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
  , i_format_id                in            com_api_type_pkg.t_tiny_id default null
  , i_include_limits           in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_include_service          in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_include_flexible_fields  in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_batch_card_tab           prs_api_type_pkg.t_batch_card_tab;
    l_card_info_tab            prs_api_type_pkg.t_card_info_tab;
    l_card_count               com_api_type_pkg.t_short_id;
    l_tags_value_tab           com_api_type_pkg.t_param_tab;
    l_curr_line                com_api_type_pkg.t_lob_data;
    l_add_line                 com_api_type_pkg.t_lob_data;
    l_name                     com_api_type_pkg.t_name;
    l_agent_adr_id             com_api_type_pkg.t_medium_id;
    l_lang                     com_api_type_pkg.t_dict_value;
    l_line                     com_api_type_pkg.t_lob_data;
    l_sysdate                  date;
    l_line_sequence            com_api_type_pkg.t_short_id;
    l_short_company_name       com_api_type_pkg.t_name;
    l_full_company_name        com_api_type_pkg.t_full_desc;
    l_appl_id                  com_api_type_pkg.t_long_id;

    l_country_id               com_api_type_pkg.t_tiny_id;
    l_country_lang             com_api_type_pkg.t_dict_value;
    l_address_id               com_api_type_pkg.t_medium_id;

    procedure get_preferred_lang(
        i_entity_type     in     com_api_type_pkg.t_dict_value
      , i_object_id       in     com_api_type_pkg.t_long_id
      , o_preferred_lang     out com_api_type_pkg.t_dict_value
    ) is
    begin
        select preferred_lang
          into o_preferred_lang
          from (
              select co.object_id
                   , cc.preferred_lang
                   , row_number() over (partition by co.object_id order by nvl2(cc.preferred_lang, 0, 1), cc.id desc) rn
                from com_contact cc
                   , com_contact_object co
               where cc.id = co.contact_id
                 and co.entity_type = i_entity_type
                 and co.object_id   = i_object_id
          )
         where rn = 1;

    exception when no_data_found then
        null;
    end get_preferred_lang;

    procedure get_address(
        i_entity_type     in     com_api_type_pkg.t_dict_value
      , i_object_id       in     com_api_type_pkg.t_long_id
      , o_address_id         out com_api_type_pkg.t_medium_id
      , o_street             out com_api_type_pkg.t_double_name
      , o_house              out com_api_type_pkg.t_double_name
      , o_apartment          out com_api_type_pkg.t_double_name
      , o_postal_code        out com_api_type_pkg.t_name
      , o_city               out com_api_type_pkg.t_double_name
      , o_country            out com_api_type_pkg.t_name
      , o_region_code        out com_api_type_pkg.t_name
      , o_region             out com_api_type_pkg.t_double_name
    ) is
    begin
        select id
             , street
             , house
             , apartment
             , postal_code
             , city
             , country
             , region_code
             , region
             , country_id
             , country_lang
          into o_address_id
             , o_street
             , o_house
             , o_apartment
             , o_postal_code
             , o_city
             , o_country
             , o_region_code
             , o_region
             , l_country_id
             , l_country_lang
          from (
              select ca.id
                   , ca.lang
                   , ca.country
                   , ca.region
                   , ca.city
                   , ca.street
                   , ca.house
                   , ca.apartment
                   , ca.postal_code
                   , ca.region_code
                   , ct.id as country_id
                   , ca.lang as country_lang
                   , ob.object_id
                   , row_number() over (partition by ob.object_id order by decode(ob.address_type, 'ADTPSTDL', -1, ob.address_id)) rn
                 from com_address ca
                    , com_address_object ob
                    , com_country ct
                where ca.id = ob.address_id
                  and ob.entity_type = i_entity_type
                  and ob.object_id   = i_object_id
                  and ct.code(+)     = ca.country
          )
        where rn = 1;

    exception when no_data_found then
        o_address_id := null;
    end get_address;

begin
    o_excepted_count  := 0;
    o_processed_count := 0;
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    l_card_count      := i_estimated_count;

    loop
        fetch i_perso_cur bulk collect into l_batch_card_tab limit BULK_LIMIT;

        l_card_info_tab.delete;

        for i in 1 .. l_batch_card_tab.count loop
            begin
                savepoint processing_next_card;

                l_address_id := null;

                trc_log_pkg.debug(
                    i_text          => 'Card instance [#1], card number [#2]'
                    , i_env_param1  => l_batch_card_tab(i).card_instance_id
                    , i_env_param2  => l_batch_card_tab(i).card_mask
                );

                l_card_count := nvl(l_batch_card_tab(i).card_count, i_estimated_count);
                if o_processed_count >= l_card_count then
                    exit;
                end if;

                --geneate record
                trc_log_pkg.debug(
                    i_text          => 'record_number = ' || i
                );

                -- calculate required fields of "l_card_info_tab"
                begin
                    select pd.uid_format_id
                      into l_card_info_tab(i).uid_format_id
                      from iss_product_card_type pd
                     where pd.bin_id       = l_batch_card_tab(i).bin_id
                       and pd.product_id   = l_batch_card_tab(i).product_id
                       and pd.card_type_id = l_batch_card_tab(i).card_type_id
                       and l_batch_card_tab(i).seq_number between pd.seq_number_low and pd.seq_number_high;

                exception when no_data_found then
                    null;
                end;

                begin
                    select distinct first_value(a.account_number) over (order by o.usage_order, o.is_pos_default desc nulls last, o.is_atm_default desc nulls last)
                      into l_card_info_tab(i).card_account
                      from acc_account_object o
                         , acc_account a
                     where o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                       and o.object_id   = l_batch_card_tab(i).card_id
                       and a.id          = o.account_id
                       and a.status     != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED;

                exception when no_data_found then
                    null;
                end;

                if l_batch_card_tab(i).customer_id is not null then
                    select customer_number
                         , reg_date
                      into l_card_info_tab(i).customer_number
                         , l_card_info_tab(i).customer_reg_date
                      from prd_customer
                     where id = l_batch_card_tab(i).customer_id;
                end if;

                begin
                    select cd.pvv
                         , cd.kcolb_nip
                         , cd.pin_offset
                      into l_card_info_tab(i).pvv
                         , l_card_info_tab(i).pin_block
                         , l_card_info_tab(i).pin_offset
                      from iss_card_instance_data cd
                     where cd.card_instance_id = l_batch_card_tab(i).card_instance_id;

                exception when no_data_found then
                    null;
                end;

                begin
                    select *
                      into l_card_info_tab(i).person_id
                         , l_card_info_tab(i).first_name
                         , l_card_info_tab(i).second_name
                         , l_card_info_tab(i).surname
                         , l_card_info_tab(i).suffix
                         , l_card_info_tab(i).gender
                         , l_card_info_tab(i).birthday
                      from (
                            select p.id
                                 , p.first_name
                                 , p.second_name
                                 , p.surname
                                 , p.suffix
                                 , p.gender
                                 , p.birthday
                              from iss_cardholder ch
                                 , com_person p
                             where ch.id      = l_batch_card_tab(i).cardholder_id
                               and ch.inst_id = l_batch_card_tab(i).inst_id
                               and p.id       = ch.person_id
                             order by decode(p.lang, l_batch_card_tab(i).lang, 1, com_api_const_pkg.LANGUAGE_ENGLISH, 2, 3)
                            )
                     where rownum = 1;

                exception when no_data_found then
                    null;
                end;

                if l_card_info_tab(i).person_id is null then
                    begin
                        select *
                          into l_card_info_tab(i).person_id
                             , l_card_info_tab(i).first_name
                             , l_card_info_tab(i).second_name
                             , l_card_info_tab(i).surname
                             , l_card_info_tab(i).suffix
                             , l_card_info_tab(i).gender
                             , l_card_info_tab(i).birthday
                          from (
                                select p.id
                                     , p.first_name
                                     , p.second_name
                                     , p.surname
                                     , p.suffix
                                     , p.gender
                                     , p.birthday
                                  from prd_customer cm
                                     , com_person p
                                 where cm.id = l_batch_card_tab(i).customer_id
                                   and p.id  = decode(cm.entity_type, com_api_const_pkg.ENTITY_TYPE_PERSON, cm.object_id, null)
                                 order by decode(p.lang, l_batch_card_tab(i).lang, 1, com_api_const_pkg.LANGUAGE_ENGLISH, 2, 3)
                                )
                         where rownum = 1;

                    exception when no_data_found then
                        null;
                    end;
                end if;

                get_address(
                    i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                  , i_object_id     => l_batch_card_tab(i).cardholder_id
                  , o_address_id    => l_address_id
                  , o_street        => l_card_info_tab(i).street
                  , o_house         => l_card_info_tab(i).house
                  , o_apartment     => l_card_info_tab(i).apartment
                  , o_postal_code   => l_card_info_tab(i).postal_code
                  , o_city          => l_card_info_tab(i).city
                  , o_country       => l_card_info_tab(i).country
                  , o_region_code   => l_card_info_tab(i).region_code
                  , o_region        => l_card_info_tab(i).region
                );

                if l_address_id is null then
                    get_address(
                        i_entity_type   => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      , i_object_id     => l_batch_card_tab(i).customer_id
                      , o_address_id    => l_address_id
                      , o_street        => l_card_info_tab(i).street
                      , o_house         => l_card_info_tab(i).house
                      , o_apartment     => l_card_info_tab(i).apartment
                      , o_postal_code   => l_card_info_tab(i).postal_code
                      , o_city          => l_card_info_tab(i).city
                      , o_country       => l_card_info_tab(i).country
                      , o_region_code   => l_card_info_tab(i).region_code
                      , o_region        => l_card_info_tab(i).region
                    );
                end if;

                l_batch_card_tab(i).card_number    := iss_api_token_pkg.decode_card_number(
                                                          i_card_number => l_batch_card_tab(i).card_number
                                                      );
                l_card_info_tab(i).agent_number    := ost_ui_agent_pkg.get_agent_number(
                                                          i_agent_id    => l_batch_card_tab(i).contract_agent_id
                                                      );

                l_card_info_tab(i).product_name   := get_text('prd_product',    'label', l_batch_card_tab(i).product_id,   l_batch_card_tab(i).lang);
                l_card_info_tab(i).country_name   := get_text('com_country',     'name', l_country_id,                     l_country_lang);

                select prd.product_number
                  into l_card_info_tab(i).product_number
                  from prd_product prd
                 where prd.id = l_batch_card_tab(i).product_id;

                get_preferred_lang(
                    i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                  , i_object_id       => l_batch_card_tab(i).cardholder_id
                  , o_preferred_lang  => l_card_info_tab(i).preferred_lang
                );

                if l_card_info_tab(i).preferred_lang is null then
                    get_preferred_lang(
                        i_entity_type     => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      , i_object_id       => l_batch_card_tab(i).customer_id
                      , o_preferred_lang  => l_card_info_tab(i).preferred_lang
                    );
                end if;

                l_tags_value_tab.delete;

                -- calculate tags for record
                l_tags_value_tab('DF8007') := l_card_info_tab(i).person_id;
                l_tags_value_tab('DF8008') := com_api_dictionary_pkg.get_article_text(
                                                  i_article           => l_card_info_tab(i).gender
                                                , i_lang              => l_batch_card_tab(i).lang
                                              );
                l_tags_value_tab('DF800F') := l_batch_card_tab(i).company_name;

                -- Preferred language
                if l_card_info_tab(i).preferred_lang is not null then
                    l_tags_value_tab('DF8012') := case when l_card_info_tab(i).preferred_lang is null then 'CLNG00'
                                                       when l_card_info_tab(i).preferred_lang = com_api_const_pkg.LANGUAGE_ENGLISH then 'CLNG02'
                                                       else 'CLNG01'
                                                  end;
                end if;

                l_tags_value_tab('DF8018') := l_card_info_tab(i).suffix;
                l_tags_value_tab('DF8019') := l_card_info_tab(i).first_name;
                l_tags_value_tab('DF801A') := l_card_info_tab(i).second_name;
                l_tags_value_tab('DF801B') := l_card_info_tab(i).surname;
                l_tags_value_tab('DF801C') := to_char(l_card_info_tab(i).birthday, 'mmddyyyy');

                l_tags_value_tab('DF8020') := com_api_address_pkg.get_address_string(
                                                  i_street            => l_card_info_tab(i).street
                                                , i_house             => l_card_info_tab(i).house
                                                , i_apartment         => l_card_info_tab(i).apartment
                                                , i_inst_id           => l_batch_card_tab(i).inst_id
                                                , i_enable_empty      => i_empty_address
                                              );
                l_tags_value_tab('DF8021') := com_api_address_pkg.get_address_string(
                                                  i_city              => l_card_info_tab(i).city
                                                , i_inst_id           => l_batch_card_tab(i).inst_id
                                                , i_enable_empty      => i_empty_address
                                              );
                l_tags_value_tab('DF8022') := null;
                l_tags_value_tab('DF8023') := null;
                l_tags_value_tab('DF8024') := l_card_info_tab(i).region_code;
                l_tags_value_tab('DF8025') := com_api_country_pkg.get_external_country_code(
                                                  i_internal_country_code => l_card_info_tab(i).country
                                              );
                l_tags_value_tab('DF8026') := l_card_info_tab(i).postal_code;
                l_tags_value_tab('DF8E0F') := l_card_info_tab(i).country_name;
                l_tags_value_tab('DF8E0A') := l_card_info_tab(i).region;

                -- custom format of address string
                -- line 1
                com_cst_address_ver2_pkg.get_address_string(
                    i_country           => l_card_info_tab(i).country
                  , i_region            => l_card_info_tab(i).region
                  , i_city              => l_card_info_tab(i).city
                  , i_street            => l_card_info_tab(i).street
                  , i_house             => l_card_info_tab(i).house
                  , i_apartment         => l_card_info_tab(i).apartment
                  , i_postal_code       => l_card_info_tab(i).postal_code
                  , i_region_code       => l_card_info_tab(i).region_code
                  , i_inst_id           => l_batch_card_tab(i).inst_id
                  , i_tag_name          => 'DF8020'
                  , io_tag_value        => l_tags_value_tab('DF8020')
                  , i_card_id           => l_batch_card_tab(i).card_id
                  , i_card_instance_id  => l_batch_card_tab(i).card_instance_id
                );
                -- line 2
                com_cst_address_ver2_pkg.get_address_string(
                    i_country           => l_card_info_tab(i).country
                  , i_region            => l_card_info_tab(i).region
                  , i_city              => l_card_info_tab(i).city
                  , i_street            => l_card_info_tab(i).street
                  , i_house             => l_card_info_tab(i).house
                  , i_apartment         => l_card_info_tab(i).apartment
                  , i_postal_code       => l_card_info_tab(i).postal_code
                  , i_region_code       => l_card_info_tab(i).region_code
                  , i_inst_id           => l_batch_card_tab(i).inst_id
                  , i_tag_name          => 'DF8021'
                  , io_tag_value        => l_tags_value_tab('DF8021')
                  , i_card_id           => l_batch_card_tab(i).card_id
                  , i_card_instance_id  => l_batch_card_tab(i).card_instance_id
                );
                -- line 3
                com_cst_address_ver2_pkg.get_address_string(
                    i_country           => l_card_info_tab(i).country
                  , i_region            => l_card_info_tab(i).region
                  , i_city              => l_card_info_tab(i).city
                  , i_street            => l_card_info_tab(i).street
                  , i_house             => l_card_info_tab(i).house
                  , i_apartment         => l_card_info_tab(i).apartment
                  , i_postal_code       => l_card_info_tab(i).postal_code
                  , i_region_code       => l_card_info_tab(i).region_code
                  , i_inst_id           => l_batch_card_tab(i).inst_id
                  , i_tag_name          => 'DF8022'
                  , io_tag_value        => l_tags_value_tab('DF8022')
                  , i_card_id           => l_batch_card_tab(i).card_id
                  , i_card_instance_id  => l_batch_card_tab(i).card_instance_id
                );
                -- line 4
                com_cst_address_ver2_pkg.get_address_string(
                    i_country           => l_card_info_tab(i).country
                  , i_region            => l_card_info_tab(i).region
                  , i_city              => l_card_info_tab(i).city
                  , i_street            => l_card_info_tab(i).street
                  , i_house             => l_card_info_tab(i).house
                  , i_apartment         => l_card_info_tab(i).apartment
                  , i_postal_code       => l_card_info_tab(i).postal_code
                  , i_region_code       => l_card_info_tab(i).region_code
                  , i_inst_id           => l_batch_card_tab(i).inst_id
                  , i_tag_name          => 'DF8023'
                  , io_tag_value        => l_tags_value_tab('DF8023')
                  , i_card_id           => l_batch_card_tab(i).card_id
                  , i_card_instance_id  => l_batch_card_tab(i).card_instance_id
                );

                l_tags_value_tab('DF8003') := l_batch_card_tab(i).customer_id;
                l_tags_value_tab('DF863C') := l_card_info_tab(i).customer_number;
                l_tags_value_tab('DF802C') := l_batch_card_tab(i).card_number;
                l_tags_value_tab('DF802F') := l_batch_card_tab(i).card_type_id;
                l_tags_value_tab('DF8032') := to_char(l_batch_card_tab(i).start_date, 'mmddyyyy');
                l_tags_value_tab('DF8033') := l_card_info_tab(i).card_account;
                l_tags_value_tab('DF8034') := iss_api_bin_pkg.get_bin(
                                                  i_card_number => l_batch_card_tab(i).card_number
                                              ).bin_currency;

                ntf_api_notification_pkg.get_mobile_number(
                    i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                  , i_object_id     => l_batch_card_tab(i).cardholder_id
                  , i_contact_type  => com_api_const_pkg.CONTACT_TYPE_PRIMARY
                  , o_address       => l_tags_value_tab('DF8029')
                  , o_lang          => l_lang
                );

                check_cardholder_name(
                    i_cardholder_name       => l_batch_card_tab(i).cardholder_name
                  , i_check_cardholder_name => i_check_cardholder_name
                );
                l_tags_value_tab('DF8042') := l_batch_card_tab(i).cardholder_name;

                l_tags_value_tab('DF8074') := l_batch_card_tab(i).seq_number;
                l_tags_value_tab('DF8077') := nvl(l_card_info_tab(i).pin_offset, lpad(to_char(l_card_info_tab(i).pvv), 4, '0'));
                l_tags_value_tab('DF8100') := l_card_info_tab(i).pin_block;
                l_tags_value_tab('DF8103') := lpad(to_char(l_card_info_tab(i).pvv), 4, '0');

                l_tags_value_tab('DF8078') := to_char(l_batch_card_tab(i).expir_date, 'mmyy');
                l_tags_value_tab('DF807A') := l_card_info_tab(i).agent_number;
                l_tags_value_tab('DF8178') := case l_batch_card_tab(i).embossing_request
                                                  when iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS
                                                  then 0
                                                  else 1
                                              end;

                l_tags_value_tab('DF817B') := case l_batch_card_tab(i).pin_mailer_request  -- l_pin_mailer_request
                                                  when iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT
                                                  then 'PINM0'
                                                  else 'PINM1'
                                              end;

                l_tags_value_tab('DF8203') := l_batch_card_tab(i).card_instance_id;

                l_tags_value_tab('DF8204') := case l_batch_card_tab(i).perso_priority
                                                  when iss_api_const_pkg.PERSO_PRIORITY_NORMAL
                                                  then 'CREF0'
                                                  else 'CREF1'
                                              end;

                if l_batch_card_tab(i).customer_id is not null then
                    l_tags_value_tab('DF8219') := to_char(l_card_info_tab(i).customer_reg_date, 'ddmmyyyy');
                end if;

                l_tags_value_tab('DF8235') := to_char(l_batch_card_tab(i).inst_id, com_api_const_pkg.XML_NUMBER_FORMAT);
                l_tags_value_tab('DF8354') := l_batch_card_tab(i).blank_type_id;

                --agent address
                if l_batch_card_tab(i).agent_id is not null then
                    begin
                        select address_id
                          into l_agent_adr_id
                          from com_address_object o
                         where o.object_id    = l_batch_card_tab(i).agent_id
                           and o.entity_type  = ost_api_const_pkg.ENTITY_TYPE_AGENT
                           and o.address_type = 'ADTPBSNA';

                        l_tags_value_tab('DF841A') := com_api_address_pkg.get_address_string(
                                                          i_address_id      => l_agent_adr_id
                                                        , i_lang            => l_batch_card_tab(i).lang
                                                        , i_inst_id         => l_batch_card_tab(i).inst_id
                                                      );
                    exception
                        when no_data_found then
                            null;
                    end;
                end if;

                l_tags_value_tab('DF8474') := i_batch_id;

                if l_card_info_tab(i).uid_format_id is not null
                   or i_format_id is not null
                then
                    l_tags_value_tab('DF8C07') := l_batch_card_tab(i).card_uid;
                end if;

                l_tags_value_tab('DF8E0B') := l_card_info_tab(i).product_number;
                l_tags_value_tab('DF8E0C') := l_card_info_tab(i).product_name;

                l_tags_value_tab('DF8E0D') := com_api_i18n_pkg.get_text(
                                                  i_table_name  => 'ost_agent'
                                                , i_column_name => 'name'
                                                , i_object_id   => l_batch_card_tab(i).agent_id
                                                , i_lang        => l_batch_card_tab(i).lang
                                              );
                l_tags_value_tab('DF8E18') := ost_ui_agent_pkg.get_agent_number(
                                                          i_agent_id    => l_batch_card_tab(i).agent_id
                                                      );
                l_tags_value_tab('DF8E0E') := com_api_i18n_pkg.get_text(
                                                  i_table_name  => 'ost_agent'
                                                , i_column_name => 'name'
                                                , i_object_id   => l_batch_card_tab(i).contract_agent_id
                                                , i_lang        => l_batch_card_tab(i).lang
                                              );
                l_tags_value_tab('DF8C02') := l_batch_card_tab(i).embossed_first_name;
                l_tags_value_tab('DF8C03') := l_batch_card_tab(i).embossed_second_name;
                l_tags_value_tab('DF8C04') := l_batch_card_tab(i).embossed_surname;
                l_tags_value_tab('DF8C05') := l_batch_card_tab(i).embossed_title;
                l_tags_value_tab('DF8C08') := l_batch_card_tab(i).embossed_line_additional;
                l_tags_value_tab('DF8043') := l_batch_card_tab(i).supplementary_info_1;

                if l_batch_card_tab(i).cardholder_photo_file_name is not null then
                    l_tags_value_tab('DF840D') := l_batch_card_tab(i).cardholder_photo_file_name;
                end if;
                if l_batch_card_tab(i).cardholder_sign_file_name is not null then
                    l_tags_value_tab('DF840E') := l_batch_card_tab(i).cardholder_sign_file_name;
                end if;

                -- Full company name
                begin
                    select com_api_i18n_pkg.get_text (
                               i_table_name    => 'com_company'
                             , i_column_name   => 'label'
                             , i_object_id     => c.object_id
                             , i_lang          => com_api_const_pkg.LANGUAGE_ENGLISH
                           ) as short_company_name
                         , com_api_i18n_pkg.get_text (
                               i_table_name    => 'com_company'
                             , i_column_name   => 'description'
                             , i_object_id     => c.object_id
                             , i_lang          => com_api_const_pkg.LANGUAGE_ENGLISH
                           ) as full_company_name
                      into l_short_company_name
                         , l_full_company_name
                      from prd_customer c
                     where c.id            = l_batch_card_tab(i).customer_id
                       and c.entity_type   = com_api_const_pkg.ENTITY_TYPE_COMPANY;
                exception
                    when no_data_found then
                        l_short_company_name := '';
                        l_full_company_name  := '';
                end;
                l_tags_value_tab('DF863D') := coalesce(l_full_company_name, l_short_company_name);

                -- Card Application ID
                select max(appl_id)
                  into l_appl_id
                  from app_object
                 where object_id       = l_batch_card_tab(i).card_id
                   and entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD;

                l_tags_value_tab('DF863E') := l_appl_id;

                l_line                     := '';
                l_add_line                 := '';
                l_curr_line                := '';
                l_line_sequence            := 2;

                if i_include_limits = com_api_const_pkg.TRUE then
                    -- Include limits into cardgen file
                    for l in (
                        select to_char(l.id) as limit_id
                             , l.limit_type
                             , to_char(
                                   case when l.limit_base is not null and l.limit_rate is not null
                                        then
                                            nvl(fcl_api_limit_pkg.get_limit_border_sum(
                                                    i_entity_type          => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                  , i_object_id            => l_batch_card_tab(i).card_id
                                                  , i_limit_type           => l.limit_type
                                                  , i_limit_base           => l.limit_base
                                                  , i_limit_rate           => l.limit_rate
                                                  , i_currency             => l.currency
                                                  , i_inst_id              => l_batch_card_tab(i).inst_id
                                                  , i_product_id           => l_batch_card_tab(i).product_id
                                                  , i_split_hash           => l_batch_card_tab(i).split_hash
                                                  , i_mask_error           => com_api_const_pkg.TRUE
                                                ), 0
                                            )
                                        else
                                            nvl(l.sum_limit, 0)
                                   end
                               ) as limit_sum
                             , l.currency as limit_currency
                          from fcl_limit l
                             , (select to_number(limit_id, com_api_const_pkg.NUMBER_FORMAT) limit_id
                                     , row_number() over (partition by card_id, limit_type order by decode(level_priority, 0, 0, 1)
                                                                                                         , level_priority
                                                                                                         , start_date desc
                                                                                                         , register_timestamp desc) rn
                                     , card_id
                                  from (
                                        select v.attr_value limit_id
                                             , 0 level_priority
                                             , a.object_type limit_type
                                             , v.object_id as card_id
                                             , v.split_hash
                                             , v.start_date
                                             , v.register_timestamp
                                          from prd_attribute_value v
                                             , prd_attribute a
                                         where v.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                           and a.id           = v.attr_id
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                           and v.object_id    = l_batch_card_tab(i).card_id
                                           and v.split_hash   = l_batch_card_tab(i).split_hash
                                     union all
                                        select v.attr_value
                                             , p.level_priority
                                             , a.object_type as limit_type
                                             , l_batch_card_tab(i).card_id
                                             , l_batch_card_tab(i).split_hash
                                             , v.start_date
                                             , v.register_timestamp
                                          from prd_attribute_value v
                                             , prd_attribute a
                                             , prd_service_type st
                                             , prd_service s
                                             , prd_product_service ps
                                             , prd_contract c
                                             , (select connect_by_root id product_id
                                                     , level level_priority
                                                     , id parent_id
                                                     , product_type
                                                     , case when parent_id is null then 1 else 0 end top_flag
                                                  from prd_product
                                               connect by prior parent_id = id
                                               ) p
                                         where v.service_id      = s.id
                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                           and v.attr_id         = a.id
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                           and a.service_type_id = s.service_type_id
                                           and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT  --'ENTTLIMT'
                                           and st.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and st.id             = s.service_type_id
                                           and p.product_id      = ps.product_id
                                           and s.id              = ps.service_id
                                           and ps.product_id     = c.product_id
                                           and c.id              = l_batch_card_tab(i).contract_id
                                           and c.split_hash      = l_batch_card_tab(i).split_hash
                                     union all
                                        select v.attr_value
                                             , p.level_priority
                                             , a.object_type as limit_type
                                             , l_batch_card_tab(i).card_id
                                             , l_batch_card_tab(i).split_hash
                                             , v.start_date
                                             , v.register_timestamp
                                          from prd_attribute_value v
                                             , prd_attribute a
                                             , prd_service_type st
                                             , prd_service s
                                             , prd_product_service ps
                                             , prd_contract c
                                             , acc_account_object ao
                                             , acc_account ac
                                             , (select connect_by_root id product_id
                                                     , level level_priority
                                                     , id parent_id
                                                     , product_type
                                                     , case when parent_id is null then 1 else 0 end top_flag
                                                  from prd_product
                                               connect by prior parent_id = id
                                               ) p
                                         where v.service_id      = s.id
                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                           and v.attr_id         = a.id
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                           and a.service_type_id = s.service_type_id
                                           and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT  --'ENTTLIMT'
                                           and st.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                           and st.id             = s.service_type_id
                                           and p.product_id      = ps.product_id
                                           and s.id              = ps.service_id
                                           and ps.product_id     = c.product_id
                                           and ao.object_id      = l_batch_card_tab(i).card_id
                                           and ao.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and ao.account_id     = ac.id
                                           and ac.contract_id    = c.id
                                           and c.split_hash      = ac.split_hash
                                    ) tt
                               ) limits
                         where limits.card_id    = l_batch_card_tab(i).card_id
                           and limits.rn         = 1
                           and l.id              = limits.limit_id
                    ) loop
                        l_line := get_line(i_param_value    => l.limit_id
                                         , i_tag_name       => 'DF842A'
                                         , i_line           => l_line);
                        l_line := get_line(i_param_value    => l.limit_type
                                         , i_tag_name       => 'DF842B'
                                         , i_line           => l_line);
                        l_line := get_line(i_param_value    => l.limit_sum
                                         , i_tag_name       => 'DF842C'
                                         , i_line           => l_line);
                        if l.limit_currency is not null then
                            l_line := get_line(i_param_value    => l.limit_currency
                                             , i_tag_name       => 'DF8522'
                                             , i_line           => l_line);
                        end if;
                        l_curr_line := 'DF805D' || get_tag_length(length(to_char(l_line_sequence))) || to_char(l_line_sequence);
                        l_line := 'FF804B' || get_tag_length(length(l_line) + length(l_curr_line)) || l_curr_line || l_line;
                        l_add_line := l_add_line || l_line;
                        l_line_sequence := l_line_sequence + 1;
                        l_line := '';
                    end loop;
                end if;

                if i_include_service = com_api_const_pkg.TRUE then
                    -- Include services into cardgen file
                    for l in (
                        select to_char(s.service_type_id) as service_type_id
                             , to_char(nvl(t.external_code, s.service_type_id)) as external_code
                             , to_char(nvl(s.service_number, s.id)) as service_number
                          from prd_service s
                             , prd_service_type t
                             , prd_service_object b
                         where b.service_id    = s.id
                           and t.id            = s.service_type_id
                           and b.object_id     = l_batch_card_tab(i).card_id
                           and b.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and b.split_hash    = l_batch_card_tab(i).split_hash
                    ) loop
                        l_line := get_line(i_param_value    => l.service_type_id
                                         , i_tag_name       => 'DF842A'
                                         , i_line           => l_line);
                        l_line := get_line(i_param_value    => l.external_code
                                         , i_tag_name       => 'DF842B'
                                         , i_line           => l_line);
                        l_line := get_line(i_param_value    => l.service_number
                                         , i_tag_name       => 'DF842C'
                                         , i_line           => l_line);
                        l_curr_line := 'DF805D' || get_tag_length(length(to_char(l_line_sequence))) || to_char(l_line_sequence);
                        l_line := 'FF804B' || get_tag_length(length(l_line) + length(l_curr_line)) || l_curr_line || l_line;
                        l_add_line := l_add_line || l_line;
                        l_line_sequence := l_line_sequence + 1;
                        l_line := '';
                    end loop;
                end if;

                if i_include_flexible_fields = com_api_const_pkg.TRUE then
                    -- Include limits into cardgen file
                    for l in (
                         select to_char(fd.field_id) as field_id
                              , ff.name as field_name
                              , case ff.data_type
                                    when com_api_const_pkg.DATA_TYPE_NUMBER then
                                        to_char(
                                            to_number(
                                                fd.field_value
                                              , nvl(ff.data_format, com_api_const_pkg.NUMBER_FORMAT)
                                            )
                                          , com_api_const_pkg.XML_NUMBER_FORMAT
                                        )
                                    when com_api_const_pkg.DATA_TYPE_DATE   then
                                        to_char(
                                            to_date(
                                                fd.field_value
                                              , nvl(ff.data_format, com_api_const_pkg.DATE_FORMAT)
                                            )
                                          , com_api_const_pkg.XML_DATE_FORMAT
                                        )
                                    else
                                        fd.field_value
                                end as field_value
                           from com_flexible_field ff
                              , com_flexible_data  fd
                          where ff.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                            and fd.field_id    = ff.id
                            and fd.object_id   = l_batch_card_tab(i).card_id
                    ) loop
                        l_line := get_line(i_param_value    => l.field_id
                                         , i_tag_name       => 'DF842A'
                                         , i_line           => l_line);
                        l_line := get_line(i_param_value    => l.field_name
                                         , i_tag_name       => 'DF842B'
                                         , i_line           => l_line);
                        l_line := get_line(i_param_value    => l.field_value
                                         , i_tag_name       => 'DF842C'
                                         , i_line           => l_line);
                        l_curr_line := 'DF805D' || get_tag_length(length(to_char(l_line_sequence))) || to_char(l_line_sequence);
                        l_line := 'FF804B' || get_tag_length(length(l_line) + length(l_curr_line)) || l_curr_line || l_line;
                        l_add_line := l_add_line || l_line;
                        l_line_sequence := l_line_sequence + 1;
                        l_line := '';
                    end loop;
                end if;

                --geneate ber_tlv
                l_curr_line := '';

                l_name := l_tags_value_tab.first;
                while l_name is not null loop
                    if l_tags_value_tab(l_name) is not null then
                        l_curr_line := l_curr_line
                                    || l_name
                                    || get_tag_length(length(l_tags_value_tab(l_name)))
                                    || l_tags_value_tab(l_name);
                    end if;

                    l_name := l_tags_value_tab.next(l_name);
                end loop;
                if l_add_line is not null then
                    l_curr_line := l_curr_line || l_add_line;
                end if;

                --user exit procedure
                l_add_line := '';
                itf_cst_cardgen_pkg.get_add_data(
                    i_batch_card_rec => l_batch_card_tab(i)
                  , i_card_info_rec  => l_card_info_tab(i)
                  , o_add_line       => l_add_line
                );
                l_curr_line := l_curr_line || l_add_line;

                --add begin tags
                l_curr_line := get_start_line(l_curr_line) || l_curr_line;

                -- put line
                put_line (
                    i_raw_data       => l_curr_line
                  , i_batch_card_rec => l_batch_card_tab(i)
                  , i_card_info_rec  => l_card_info_tab(i)
                );

                trc_log_pkg.debug(
                    i_text          => 'l_curr_line = ' || l_curr_line
                );

            exception
                when others then
                    rollback to savepoint processing_next_card;

                    trc_log_pkg.debug(
                        i_text => sqlerrm
                    );

                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
                        o_excepted_count := o_excepted_count + 1;

                        mark_error (
                            i_batch_card_rec  => l_batch_card_tab(i)
                          , i_card_info_rec   => l_card_info_tab(i)
                        );
                    else
                        raise;
                    end if;
            end;

            o_processed_count := o_processed_count + 1;
        end loop;

        prc_api_stat_pkg.log_current(
            i_current_count   => o_processed_count
          , i_excepted_count  => o_excepted_count
        );

        exit when i_perso_cur%notfound or o_processed_count >= l_card_count;
    end loop;

exception
    when others then
        close_file (
            i_status  => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
        raise;
end process;

procedure process_1_2(
    i_perso_cur                 in            sys_refcursor
  , i_batch_id                  in            com_api_type_pkg.t_short_id
  , i_estimated_count           in            com_api_type_pkg.t_long_id
  , o_excepted_count            in out nocopy com_api_type_pkg.t_long_id
  , o_processed_count           in out nocopy com_api_type_pkg.t_long_id
  , i_empty_address             in            com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
  , i_check_cardholder_name     in            com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
  , i_format_id                 in            com_api_type_pkg.t_tiny_id default null
  , i_include_limits            in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_include_service           in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_include_flexible_fields   in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_inst_id                   in            com_api_type_pkg.t_inst_id
  , i_replace_inst_id_by_number in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_batch_card_tab           prs_api_type_pkg.t_batch_card_tab;
    l_card_info_tab            prs_api_type_pkg.t_card_info_tab;
    l_card_count               com_api_type_pkg.t_short_id;
    l_tags_value_tab           com_api_type_pkg.t_param_tab;
    l_curr_line                com_api_type_pkg.t_lob_data;
    l_add_line                 com_api_type_pkg.t_lob_data;
    l_name                     com_api_type_pkg.t_name;
    l_agent_adr_id             com_api_type_pkg.t_medium_id;
    l_lang                     com_api_type_pkg.t_dict_value;
    l_line                     com_api_type_pkg.t_lob_data;
    l_sysdate                  date;
    l_line_sequence            com_api_type_pkg.t_short_id;
    l_short_company_name       com_api_type_pkg.t_name;
    l_full_company_name        com_api_type_pkg.t_full_desc;
    l_appl_id                  com_api_type_pkg.t_long_id;

    l_country_id               com_api_type_pkg.t_tiny_id;
    l_country_lang             com_api_type_pkg.t_dict_value;
    l_address_id               com_api_type_pkg.t_medium_id;
    l_inst_number              com_api_type_pkg.t_mcc;

    procedure get_preferred_lang(
        i_entity_type     in     com_api_type_pkg.t_dict_value
      , i_object_id       in     com_api_type_pkg.t_long_id
      , o_preferred_lang     out com_api_type_pkg.t_dict_value
    ) is
    begin
        select preferred_lang
          into o_preferred_lang
          from (
              select co.object_id
                   , cc.preferred_lang
                   , row_number() over (partition by co.object_id order by nvl2(cc.preferred_lang, 0, 1), cc.id desc) rn
                from com_contact cc
                   , com_contact_object co
               where cc.id = co.contact_id
                 and co.entity_type = i_entity_type
                 and co.object_id   = i_object_id
          )
         where rn = 1;

    exception when no_data_found then
        null;
    end get_preferred_lang;

    procedure get_address(
        i_entity_type     in     com_api_type_pkg.t_dict_value
      , i_object_id       in     com_api_type_pkg.t_long_id
      , o_address_id         out com_api_type_pkg.t_medium_id
      , o_street             out com_api_type_pkg.t_double_name
      , o_house              out com_api_type_pkg.t_double_name
      , o_apartment          out com_api_type_pkg.t_double_name
      , o_postal_code        out com_api_type_pkg.t_name
      , o_city               out com_api_type_pkg.t_double_name
      , o_country            out com_api_type_pkg.t_name
      , o_region_code        out com_api_type_pkg.t_name
      , o_region             out com_api_type_pkg.t_double_name
    ) is
    begin
        select id
             , street
             , house
             , apartment
             , postal_code
             , city
             , country
             , region_code
             , region
             , country_id
             , country_lang
          into o_address_id
             , o_street
             , o_house
             , o_apartment
             , o_postal_code
             , o_city
             , o_country
             , o_region_code
             , o_region
             , l_country_id
             , l_country_lang
          from (
              select ca.id
                   , ca.lang
                   , ca.country
                   , ca.region
                   , ca.city
                   , ca.street
                   , ca.house
                   , ca.apartment
                   , ca.postal_code
                   , ca.region_code
                   , ct.id as country_id
                   , ca.lang as country_lang
                   , ob.object_id
                   , row_number() over (partition by ob.object_id order by decode(ob.address_type, 'ADTPSTDL', -1, ob.address_id)) rn
                 from com_address ca
                    , com_address_object ob
                    , com_country ct
                where ca.id = ob.address_id
                  and ob.entity_type = i_entity_type
                  and ob.object_id   = i_object_id
                  and ct.code(+)     = ca.country
          )
        where rn = 1;

    exception when no_data_found then
        o_address_id := null;
    end get_address;

begin
    o_excepted_count  := 0;
    o_processed_count := 0;
    l_sysdate         := com_api_sttl_day_pkg.get_sysdate;
    l_inst_number     := ost_api_institution_pkg.get_inst_number(i_inst_id => i_inst_id);
    
    l_card_count      := i_estimated_count;

    loop
        fetch i_perso_cur bulk collect into l_batch_card_tab limit BULK_LIMIT;

        l_card_info_tab.delete;

        for i in 1 .. l_batch_card_tab.count loop
            begin
                savepoint processing_next_card;

                l_address_id := null;

                trc_log_pkg.debug(
                    i_text          => 'Card instance [#1], card number [#2]'
                    , i_env_param1  => l_batch_card_tab(i).card_instance_id
                    , i_env_param2  => l_batch_card_tab(i).card_mask
                );

                l_card_count := nvl(l_batch_card_tab(i).card_count, i_estimated_count);
                if o_processed_count >= l_card_count then
                    exit;
                end if;

                --geneate record
                trc_log_pkg.debug(
                    i_text          => 'record_number = ' || i
                );

                -- calculate required fields of "l_card_info_tab"
                begin
                    select pd.uid_format_id
                      into l_card_info_tab(i).uid_format_id
                      from iss_product_card_type pd
                     where pd.bin_id       = l_batch_card_tab(i).bin_id
                       and pd.product_id   = l_batch_card_tab(i).product_id
                       and pd.card_type_id = l_batch_card_tab(i).card_type_id
                       and l_batch_card_tab(i).seq_number between pd.seq_number_low and pd.seq_number_high;

                exception when no_data_found then
                    null;
                end;

                begin
                    select distinct first_value(a.account_number) over (order by o.usage_order, o.is_pos_default desc nulls last, o.is_atm_default desc nulls last)
                      into l_card_info_tab(i).card_account
                      from acc_account_object o
                         , acc_account a
                     where o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                       and o.object_id   = l_batch_card_tab(i).card_id
                       and a.id          = o.account_id
                       and a.status     != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED;

                exception when no_data_found then
                    null;
                end;

                if l_batch_card_tab(i).customer_id is not null then
                    select customer_number
                         , reg_date
                      into l_card_info_tab(i).customer_number
                         , l_card_info_tab(i).customer_reg_date
                      from prd_customer
                     where id = l_batch_card_tab(i).customer_id;
                end if;

                begin
                    select cd.pvv
                         , cd.kcolb_nip
                         , cd.pin_offset
                      into l_card_info_tab(i).pvv
                         , l_card_info_tab(i).pin_block
                         , l_card_info_tab(i).pin_offset
                      from iss_card_instance_data cd
                     where cd.card_instance_id = l_batch_card_tab(i).card_instance_id;

                exception when no_data_found then
                    null;
                end;

                begin
                    select *
                      into l_card_info_tab(i).person_id
                         , l_card_info_tab(i).first_name
                         , l_card_info_tab(i).second_name
                         , l_card_info_tab(i).surname
                         , l_card_info_tab(i).suffix
                         , l_card_info_tab(i).gender
                         , l_card_info_tab(i).birthday
                      from (
                            select p.id
                                 , p.first_name
                                 , p.second_name
                                 , p.surname
                                 , p.suffix
                                 , p.gender
                                 , p.birthday
                              from iss_cardholder ch
                                 , com_person p
                             where ch.id      = l_batch_card_tab(i).cardholder_id
                               and ch.inst_id = l_batch_card_tab(i).inst_id
                               and p.id       = ch.person_id
                             order by decode(p.lang, l_batch_card_tab(i).lang, 1, com_api_const_pkg.LANGUAGE_ENGLISH, 2, 3)
                            )
                     where rownum = 1;

                exception when no_data_found then
                    null;
                end;

                if l_card_info_tab(i).person_id is null then
                    begin
                        select *
                          into l_card_info_tab(i).person_id
                             , l_card_info_tab(i).first_name
                             , l_card_info_tab(i).second_name
                             , l_card_info_tab(i).surname
                             , l_card_info_tab(i).suffix
                             , l_card_info_tab(i).gender
                             , l_card_info_tab(i).birthday
                          from (
                                select p.id
                                     , p.first_name
                                     , p.second_name
                                     , p.surname
                                     , p.suffix
                                     , p.gender
                                     , p.birthday
                                  from prd_customer cm
                                     , com_person p
                                 where cm.id = l_batch_card_tab(i).customer_id
                                   and p.id  = decode(cm.entity_type, com_api_const_pkg.ENTITY_TYPE_PERSON, cm.object_id, null)
                                 order by decode(p.lang, l_batch_card_tab(i).lang, 1, com_api_const_pkg.LANGUAGE_ENGLISH, 2, 3)
                                )
                         where rownum = 1;

                    exception when no_data_found then
                        null;
                    end;
                end if;

                get_address(
                    i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                  , i_object_id     => l_batch_card_tab(i).cardholder_id
                  , o_address_id    => l_address_id
                  , o_street        => l_card_info_tab(i).street
                  , o_house         => l_card_info_tab(i).house
                  , o_apartment     => l_card_info_tab(i).apartment
                  , o_postal_code   => l_card_info_tab(i).postal_code
                  , o_city          => l_card_info_tab(i).city
                  , o_country       => l_card_info_tab(i).country
                  , o_region_code   => l_card_info_tab(i).region_code
                  , o_region        => l_card_info_tab(i).region
                );

                if l_address_id is null then
                    get_address(
                        i_entity_type   => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      , i_object_id     => l_batch_card_tab(i).customer_id
                      , o_address_id    => l_address_id
                      , o_street        => l_card_info_tab(i).street
                      , o_house         => l_card_info_tab(i).house
                      , o_apartment     => l_card_info_tab(i).apartment
                      , o_postal_code   => l_card_info_tab(i).postal_code
                      , o_city          => l_card_info_tab(i).city
                      , o_country       => l_card_info_tab(i).country
                      , o_region_code   => l_card_info_tab(i).region_code
                      , o_region        => l_card_info_tab(i).region
                    );
                end if;

                l_batch_card_tab(i).card_number    := iss_api_token_pkg.decode_card_number(
                                                          i_card_number => l_batch_card_tab(i).card_number
                                                      );
                l_card_info_tab(i).agent_number    := ost_ui_agent_pkg.get_agent_number(
                                                          i_agent_id    => l_batch_card_tab(i).contract_agent_id
                                                      );

                l_card_info_tab(i).product_name   := get_text('prd_product',    'label', l_batch_card_tab(i).product_id,   l_batch_card_tab(i).lang);
                l_card_info_tab(i).country_name   := get_text('com_country',     'name', l_country_id,                     l_country_lang);

                select prd.product_number
                  into l_card_info_tab(i).product_number
                  from prd_product prd
                 where prd.id = l_batch_card_tab(i).product_id;

                get_preferred_lang(
                    i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                  , i_object_id       => l_batch_card_tab(i).cardholder_id
                  , o_preferred_lang  => l_card_info_tab(i).preferred_lang
                );

                if l_card_info_tab(i).preferred_lang is null then
                    get_preferred_lang(
                        i_entity_type     => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      , i_object_id       => l_batch_card_tab(i).customer_id
                      , o_preferred_lang  => l_card_info_tab(i).preferred_lang
                    );
                end if;

                l_tags_value_tab.delete;

                -- calculate tags for record
                l_tags_value_tab('DF8007') := l_card_info_tab(i).person_id;
                l_tags_value_tab('DF8008') := com_api_dictionary_pkg.get_article_text(
                                                  i_article           => l_card_info_tab(i).gender
                                                , i_lang              => l_batch_card_tab(i).lang
                                              );
                l_tags_value_tab('DF800F') := l_batch_card_tab(i).company_name;

                -- Preferred language
                if l_card_info_tab(i).preferred_lang is not null then
                    l_tags_value_tab('DF8012') := case when l_card_info_tab(i).preferred_lang is null then 'CLNG00'
                                                       when l_card_info_tab(i).preferred_lang = com_api_const_pkg.LANGUAGE_ENGLISH then 'CLNG02'
                                                       else 'CLNG01'
                                                  end;
                end if;

                l_tags_value_tab('DF8018') := l_card_info_tab(i).suffix;
                l_tags_value_tab('DF8019') := l_card_info_tab(i).first_name;
                l_tags_value_tab('DF801A') := l_card_info_tab(i).second_name;
                l_tags_value_tab('DF801B') := l_card_info_tab(i).surname;
                l_tags_value_tab('DF801C') := to_char(l_card_info_tab(i).birthday, 'mmddyyyy');

                l_tags_value_tab('DF8020') := com_api_address_pkg.get_address_string(
                                                  i_street            => l_card_info_tab(i).street
                                                , i_house             => l_card_info_tab(i).house
                                                , i_apartment         => l_card_info_tab(i).apartment
                                                , i_inst_id           => l_batch_card_tab(i).inst_id
                                                , i_enable_empty      => i_empty_address
                                              );
                l_tags_value_tab('DF8021') := com_api_address_pkg.get_address_string(
                                                  i_city              => l_card_info_tab(i).city
                                                , i_inst_id           => l_batch_card_tab(i).inst_id
                                                , i_enable_empty      => i_empty_address
                                              );
                l_tags_value_tab('DF8022') := null;
                l_tags_value_tab('DF8023') := null;
                l_tags_value_tab('DF8024') := l_card_info_tab(i).region_code;
                l_tags_value_tab('DF8025') := com_api_country_pkg.get_external_country_code(
                                                  i_internal_country_code => l_card_info_tab(i).country
                                              );
                l_tags_value_tab('DF8026') := l_card_info_tab(i).postal_code;
                l_tags_value_tab('DF8E0F') := l_card_info_tab(i).country_name;
                l_tags_value_tab('DF8E0A') := l_card_info_tab(i).region;

                -- custom format of address string
                -- line 1
                com_cst_address_ver2_pkg.get_address_string(
                    i_country           => l_card_info_tab(i).country
                  , i_region            => l_card_info_tab(i).region
                  , i_city              => l_card_info_tab(i).city
                  , i_street            => l_card_info_tab(i).street
                  , i_house             => l_card_info_tab(i).house
                  , i_apartment         => l_card_info_tab(i).apartment
                  , i_postal_code       => l_card_info_tab(i).postal_code
                  , i_region_code       => l_card_info_tab(i).region_code
                  , i_inst_id           => l_batch_card_tab(i).inst_id
                  , i_tag_name          => 'DF8020'
                  , io_tag_value        => l_tags_value_tab('DF8020')
                  , i_card_id           => l_batch_card_tab(i).card_id
                  , i_card_instance_id  => l_batch_card_tab(i).card_instance_id
                );
                -- line 2
                com_cst_address_ver2_pkg.get_address_string(
                    i_country           => l_card_info_tab(i).country
                  , i_region            => l_card_info_tab(i).region
                  , i_city              => l_card_info_tab(i).city
                  , i_street            => l_card_info_tab(i).street
                  , i_house             => l_card_info_tab(i).house
                  , i_apartment         => l_card_info_tab(i).apartment
                  , i_postal_code       => l_card_info_tab(i).postal_code
                  , i_region_code       => l_card_info_tab(i).region_code
                  , i_inst_id           => l_batch_card_tab(i).inst_id
                  , i_tag_name          => 'DF8021'
                  , io_tag_value        => l_tags_value_tab('DF8021')
                  , i_card_id           => l_batch_card_tab(i).card_id
                  , i_card_instance_id  => l_batch_card_tab(i).card_instance_id
                );
                -- line 3
                com_cst_address_ver2_pkg.get_address_string(
                    i_country           => l_card_info_tab(i).country
                  , i_region            => l_card_info_tab(i).region
                  , i_city              => l_card_info_tab(i).city
                  , i_street            => l_card_info_tab(i).street
                  , i_house             => l_card_info_tab(i).house
                  , i_apartment         => l_card_info_tab(i).apartment
                  , i_postal_code       => l_card_info_tab(i).postal_code
                  , i_region_code       => l_card_info_tab(i).region_code
                  , i_inst_id           => l_batch_card_tab(i).inst_id
                  , i_tag_name          => 'DF8022'
                  , io_tag_value        => l_tags_value_tab('DF8022')
                  , i_card_id           => l_batch_card_tab(i).card_id
                  , i_card_instance_id  => l_batch_card_tab(i).card_instance_id
                );
                -- line 4
                com_cst_address_ver2_pkg.get_address_string(
                    i_country           => l_card_info_tab(i).country
                  , i_region            => l_card_info_tab(i).region
                  , i_city              => l_card_info_tab(i).city
                  , i_street            => l_card_info_tab(i).street
                  , i_house             => l_card_info_tab(i).house
                  , i_apartment         => l_card_info_tab(i).apartment
                  , i_postal_code       => l_card_info_tab(i).postal_code
                  , i_region_code       => l_card_info_tab(i).region_code
                  , i_inst_id           => l_batch_card_tab(i).inst_id
                  , i_tag_name          => 'DF8023'
                  , io_tag_value        => l_tags_value_tab('DF8023')
                  , i_card_id           => l_batch_card_tab(i).card_id
                  , i_card_instance_id  => l_batch_card_tab(i).card_instance_id
                );

                l_tags_value_tab('DF8003') := l_batch_card_tab(i).customer_id;
                l_tags_value_tab('DF863C') := l_card_info_tab(i).customer_number;
                l_tags_value_tab('DF802C') := l_batch_card_tab(i).card_number;
                l_tags_value_tab('DF802F') := l_batch_card_tab(i).card_type_id;
                l_tags_value_tab('DF8032') := to_char(l_batch_card_tab(i).start_date, 'mmddyyyy');
                l_tags_value_tab('DF8033') := l_card_info_tab(i).card_account;
                l_tags_value_tab('DF8034') := iss_api_bin_pkg.get_bin(
                                                  i_card_number => l_batch_card_tab(i).card_number
                                              ).bin_currency;

                ntf_api_notification_pkg.get_mobile_number(
                    i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                  , i_object_id     => l_batch_card_tab(i).cardholder_id
                  , i_contact_type  => com_api_const_pkg.CONTACT_TYPE_PRIMARY
                  , o_address       => l_tags_value_tab('DF8029')
                  , o_lang          => l_lang
                );

                check_cardholder_name(
                    i_cardholder_name       => l_batch_card_tab(i).cardholder_name
                  , i_check_cardholder_name => i_check_cardholder_name
                );
                l_tags_value_tab('DF8042') := l_batch_card_tab(i).cardholder_name;

                l_tags_value_tab('DF8074') := l_batch_card_tab(i).seq_number;
                l_tags_value_tab('DF8077') := nvl(l_card_info_tab(i).pin_offset, lpad(to_char(l_card_info_tab(i).pvv), 4, '0'));
                l_tags_value_tab('DF8100') := l_card_info_tab(i).pin_block;
                l_tags_value_tab('DF8103') := lpad(to_char(l_card_info_tab(i).pvv), 4, '0');

                l_tags_value_tab('DF8078') := to_char(l_batch_card_tab(i).expir_date, 'mmyy');
                l_tags_value_tab('DF807A') := l_card_info_tab(i).agent_number;
                l_tags_value_tab('DF8178') := case l_batch_card_tab(i).embossing_request
                                                  when iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS
                                                  then 0
                                                  else 1
                                              end;

                l_tags_value_tab('DF817B') := case l_batch_card_tab(i).pin_mailer_request  -- l_pin_mailer_request
                                                  when iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT
                                                  then 'PINM0'
                                                  else 'PINM1'
                                              end;

                l_tags_value_tab('DF8203') := l_batch_card_tab(i).card_instance_id;

                l_tags_value_tab('DF8204') := case l_batch_card_tab(i).perso_priority
                                                  when iss_api_const_pkg.PERSO_PRIORITY_NORMAL
                                                  then 'CREF0'
                                                  else 'CREF1'
                                              end;

                if l_batch_card_tab(i).customer_id is not null then
                    l_tags_value_tab('DF8219') := to_char(l_card_info_tab(i).customer_reg_date, 'ddmmyyyy');
                end if;

                l_tags_value_tab('DF8354') := l_batch_card_tab(i).blank_type_id;
                l_tags_value_tab('DF8235') := 
                    case nvl(i_replace_inst_id_by_number, com_api_const_pkg.FALSE)
                    when com_api_const_pkg.TRUE
                    then l_inst_number
                    else to_char(l_batch_card_tab(i).inst_id, com_api_const_pkg.XML_NUMBER_FORMAT)
                    end;

                --agent address
                if l_batch_card_tab(i).agent_id is not null then
                    begin
                        select address_id
                          into l_agent_adr_id
                          from com_address_object o
                         where o.object_id    = l_batch_card_tab(i).agent_id
                           and o.entity_type  = ost_api_const_pkg.ENTITY_TYPE_AGENT
                           and o.address_type = 'ADTPBSNA';

                        l_tags_value_tab('DF841A') := com_api_address_pkg.get_address_string(
                                                          i_address_id      => l_agent_adr_id
                                                        , i_lang            => l_batch_card_tab(i).lang
                                                        , i_inst_id         => l_batch_card_tab(i).inst_id
                                                      );
                    exception
                        when no_data_found then
                            null;
                    end;
                end if;

                l_tags_value_tab('DF8474') := i_batch_id;

                if l_card_info_tab(i).uid_format_id is not null
                   or i_format_id is not null
                then
                    l_tags_value_tab('DF8C07') := l_batch_card_tab(i).card_uid;
                end if;

                l_tags_value_tab('DF8E0B') := l_card_info_tab(i).product_number;
                l_tags_value_tab('DF8E0C') := l_card_info_tab(i).product_name;

                l_tags_value_tab('DF8E0D') := com_api_i18n_pkg.get_text(
                                                  i_table_name  => 'ost_agent'
                                                , i_column_name => 'name'
                                                , i_object_id   => l_batch_card_tab(i).agent_id
                                                , i_lang        => l_batch_card_tab(i).lang
                                              );
                l_tags_value_tab('DF8E18') := ost_ui_agent_pkg.get_agent_number(
                                                          i_agent_id    => l_batch_card_tab(i).agent_id
                                                      );
                l_tags_value_tab('DF8E0E') := com_api_i18n_pkg.get_text(
                                                  i_table_name  => 'ost_agent'
                                                , i_column_name => 'name'
                                                , i_object_id   => l_batch_card_tab(i).contract_agent_id
                                                , i_lang        => l_batch_card_tab(i).lang
                                              );
                l_tags_value_tab('DF8C02') := l_batch_card_tab(i).embossed_first_name;
                l_tags_value_tab('DF8C03') := l_batch_card_tab(i).embossed_second_name;
                l_tags_value_tab('DF8C04') := l_batch_card_tab(i).embossed_surname;
                l_tags_value_tab('DF8C05') := l_batch_card_tab(i).embossed_title;
                l_tags_value_tab('DF8C08') := l_batch_card_tab(i).embossed_line_additional;
                l_tags_value_tab('DF8043') := l_batch_card_tab(i).supplementary_info_1;

                if l_batch_card_tab(i).cardholder_photo_file_name is not null then
                    l_tags_value_tab('DF840D') := l_batch_card_tab(i).cardholder_photo_file_name;
                end if;
                if l_batch_card_tab(i).cardholder_sign_file_name is not null then
                    l_tags_value_tab('DF840E') := l_batch_card_tab(i).cardholder_sign_file_name;
                end if;

                -- Full company name
                begin
                    select com_api_i18n_pkg.get_text (
                               i_table_name    => 'com_company'
                             , i_column_name   => 'label'
                             , i_object_id     => c.object_id
                             , i_lang          => com_api_const_pkg.LANGUAGE_ENGLISH
                           ) as short_company_name
                         , com_api_i18n_pkg.get_text (
                               i_table_name    => 'com_company'
                             , i_column_name   => 'description'
                             , i_object_id     => c.object_id
                             , i_lang          => com_api_const_pkg.LANGUAGE_ENGLISH
                           ) as full_company_name
                      into l_short_company_name
                         , l_full_company_name
                      from prd_customer c
                     where c.id            = l_batch_card_tab(i).customer_id
                       and c.entity_type   = com_api_const_pkg.ENTITY_TYPE_COMPANY;
                exception
                    when no_data_found then
                        l_short_company_name := '';
                        l_full_company_name  := '';
                end;
                l_tags_value_tab('DF863D') := coalesce(l_full_company_name, l_short_company_name);

                -- Card Application ID
                select max(appl_id)
                  into l_appl_id
                  from app_object
                 where object_id       = l_batch_card_tab(i).card_id
                   and entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD;

                l_tags_value_tab('DF863E') := l_appl_id;

                l_line                     := '';
                l_add_line                 := '';
                l_curr_line                := '';
                l_line_sequence            := 2;

                if i_include_limits = com_api_const_pkg.TRUE then
                    -- Include limits into cardgen file
                    for l in (
                        select to_char(l.id) as limit_id
                             , l.limit_type
                             , to_char(
                                   case when l.limit_base is not null and l.limit_rate is not null
                                        then
                                            nvl(fcl_api_limit_pkg.get_limit_border_sum(
                                                    i_entity_type          => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                  , i_object_id            => l_batch_card_tab(i).card_id
                                                  , i_limit_type           => l.limit_type
                                                  , i_limit_base           => l.limit_base
                                                  , i_limit_rate           => l.limit_rate
                                                  , i_currency             => l.currency
                                                  , i_inst_id              => l_batch_card_tab(i).inst_id
                                                  , i_product_id           => l_batch_card_tab(i).product_id
                                                  , i_split_hash           => l_batch_card_tab(i).split_hash
                                                  , i_mask_error           => com_api_const_pkg.TRUE
                                                ), 0
                                            )
                                        else
                                            nvl(l.sum_limit, 0)
                                   end
                               ) as limit_sum
                             , l.currency as limit_currency
                          from fcl_limit l
                             , (select to_number(limit_id, com_api_const_pkg.NUMBER_FORMAT) limit_id
                                     , row_number() over (partition by card_id, limit_type order by decode(level_priority, 0, 0, 1)
                                                                                                         , level_priority
                                                                                                         , start_date desc
                                                                                                         , register_timestamp desc) rn
                                     , card_id
                                  from (
                                        select v.attr_value limit_id
                                             , 0 level_priority
                                             , a.object_type limit_type
                                             , v.object_id as card_id
                                             , v.split_hash
                                             , v.start_date
                                             , v.register_timestamp
                                          from prd_attribute_value v
                                             , prd_attribute a
                                         where v.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                           and a.id           = v.attr_id
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                           and v.object_id    = l_batch_card_tab(i).card_id
                                           and v.split_hash   = l_batch_card_tab(i).split_hash
                                     union all
                                        select v.attr_value
                                             , p.level_priority
                                             , a.object_type as limit_type
                                             , l_batch_card_tab(i).card_id
                                             , l_batch_card_tab(i).split_hash
                                             , v.start_date
                                             , v.register_timestamp
                                          from prd_attribute_value v
                                             , prd_attribute a
                                             , prd_service_type st
                                             , prd_service s
                                             , prd_product_service ps
                                             , prd_contract c
                                             , (select connect_by_root id product_id
                                                     , level level_priority
                                                     , id parent_id
                                                     , product_type
                                                     , case when parent_id is null then 1 else 0 end top_flag
                                                  from prd_product
                                               connect by prior parent_id = id
                                               ) p
                                         where v.service_id      = s.id
                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                           and v.attr_id         = a.id
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                           and a.service_type_id = s.service_type_id
                                           and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT  --'ENTTLIMT'
                                           and st.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and st.id             = s.service_type_id
                                           and p.product_id      = ps.product_id
                                           and s.id              = ps.service_id
                                           and ps.product_id     = c.product_id
                                           and c.id              = l_batch_card_tab(i).contract_id
                                           and c.split_hash      = l_batch_card_tab(i).split_hash
                                     union all
                                        select v.attr_value
                                             , p.level_priority
                                             , a.object_type as limit_type
                                             , l_batch_card_tab(i).card_id
                                             , l_batch_card_tab(i).split_hash
                                             , v.start_date
                                             , v.register_timestamp
                                          from prd_attribute_value v
                                             , prd_attribute a
                                             , prd_service_type st
                                             , prd_service s
                                             , prd_product_service ps
                                             , prd_contract c
                                             , acc_account_object ao
                                             , acc_account ac
                                             , (select connect_by_root id product_id
                                                     , level level_priority
                                                     , id parent_id
                                                     , product_type
                                                     , case when parent_id is null then 1 else 0 end top_flag
                                                  from prd_product
                                               connect by prior parent_id = id
                                               ) p
                                         where v.service_id      = s.id
                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                           and v.attr_id         = a.id
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                           and a.service_type_id = s.service_type_id
                                           and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT  --'ENTTLIMT'
                                           and st.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                           and st.id             = s.service_type_id
                                           and p.product_id      = ps.product_id
                                           and s.id              = ps.service_id
                                           and ps.product_id     = c.product_id
                                           and ao.object_id      = l_batch_card_tab(i).card_id
                                           and ao.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and ao.account_id     = ac.id
                                           and ac.contract_id    = c.id
                                           and c.split_hash      = ac.split_hash
                                    ) tt
                               ) limits
                         where limits.card_id    = l_batch_card_tab(i).card_id
                           and limits.rn         = 1
                           and l.id              = limits.limit_id
                    ) loop
                        l_line := get_line(i_param_value    => l.limit_id
                                         , i_tag_name       => 'DF842A'
                                         , i_line           => l_line);
                        l_line := get_line(i_param_value    => l.limit_type
                                         , i_tag_name       => 'DF842B'
                                         , i_line           => l_line);
                        l_line := get_line(i_param_value    => l.limit_sum
                                         , i_tag_name       => 'DF842C'
                                         , i_line           => l_line);
                        if l.limit_currency is not null then
                            l_line := get_line(i_param_value    => l.limit_currency
                                             , i_tag_name       => 'DF8522'
                                             , i_line           => l_line);
                        end if;
                        l_curr_line := 'DF805D' || get_tag_length(length(to_char(l_line_sequence))) || to_char(l_line_sequence);
                        l_line := 'FF804B' || get_tag_length(length(l_line) + length(l_curr_line)) || l_curr_line || l_line;
                        l_add_line := l_add_line || l_line;
                        l_line_sequence := l_line_sequence + 1;
                        l_line := '';
                    end loop;
                end if;

                if i_include_service = com_api_const_pkg.TRUE then
                    -- Include services into cardgen file
                    for l in (
                        select to_char(s.service_type_id) as service_type_id
                             , to_char(nvl(t.external_code, s.service_type_id)) as external_code
                             , to_char(nvl(s.service_number, s.id)) as service_number
                          from prd_service s
                             , prd_service_type t
                             , prd_service_object b
                         where b.service_id    = s.id
                           and t.id            = s.service_type_id
                           and b.object_id     = l_batch_card_tab(i).card_id
                           and b.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and b.split_hash    = l_batch_card_tab(i).split_hash
                    ) loop
                        l_line := get_line(i_param_value    => l.service_type_id
                                         , i_tag_name       => 'DF842A'
                                         , i_line           => l_line);
                        l_line := get_line(i_param_value    => l.external_code
                                         , i_tag_name       => 'DF842B'
                                         , i_line           => l_line);
                        l_line := get_line(i_param_value    => l.service_number
                                         , i_tag_name       => 'DF842C'
                                         , i_line           => l_line);
                        l_curr_line := 'DF805D' || get_tag_length(length(to_char(l_line_sequence))) || to_char(l_line_sequence);
                        l_line := 'FF804B' || get_tag_length(length(l_line) + length(l_curr_line)) || l_curr_line || l_line;
                        l_add_line := l_add_line || l_line;
                        l_line_sequence := l_line_sequence + 1;
                        l_line := '';
                    end loop;
                end if;

                if i_include_flexible_fields = com_api_const_pkg.TRUE then
                    -- Include limits into cardgen file
                    for l in (
                         select to_char(fd.field_id) as field_id
                              , ff.name as field_name
                              , case ff.data_type
                                    when com_api_const_pkg.DATA_TYPE_NUMBER then
                                        to_char(
                                            to_number(
                                                fd.field_value
                                              , nvl(ff.data_format, com_api_const_pkg.NUMBER_FORMAT)
                                            )
                                          , com_api_const_pkg.XML_NUMBER_FORMAT
                                        )
                                    when com_api_const_pkg.DATA_TYPE_DATE   then
                                        to_char(
                                            to_date(
                                                fd.field_value
                                              , nvl(ff.data_format, com_api_const_pkg.DATE_FORMAT)
                                            )
                                          , com_api_const_pkg.XML_DATE_FORMAT
                                        )
                                    else
                                        fd.field_value
                                end as field_value
                           from com_flexible_field ff
                              , com_flexible_data  fd
                          where ff.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                            and fd.field_id    = ff.id
                            and fd.object_id   = l_batch_card_tab(i).card_id
                    ) loop
                        l_line := get_line(i_param_value    => l.field_id
                                         , i_tag_name       => 'DF842A'
                                         , i_line           => l_line);
                        l_line := get_line(i_param_value    => l.field_name
                                         , i_tag_name       => 'DF842B'
                                         , i_line           => l_line);
                        l_line := get_line(i_param_value    => l.field_value
                                         , i_tag_name       => 'DF842C'
                                         , i_line           => l_line);
                        l_curr_line := 'DF805D' || get_tag_length(length(to_char(l_line_sequence))) || to_char(l_line_sequence);
                        l_line := 'FF804B' || get_tag_length(length(l_line) + length(l_curr_line)) || l_curr_line || l_line;
                        l_add_line := l_add_line || l_line;
                        l_line_sequence := l_line_sequence + 1;
                        l_line := '';
                    end loop;
                end if;

                --geneate ber_tlv
                l_curr_line := '';

                l_name := l_tags_value_tab.first;
                while l_name is not null loop
                    if l_tags_value_tab(l_name) is not null then
                        l_curr_line := l_curr_line
                                    || l_name
                                    || get_tag_length(length(l_tags_value_tab(l_name)))
                                    || l_tags_value_tab(l_name);
                    end if;

                    l_name := l_tags_value_tab.next(l_name);
                end loop;
                if l_add_line is not null then
                    l_curr_line := l_curr_line || l_add_line;
                end if;

                --user exit procedure
                l_add_line := '';
                itf_cst_cardgen_pkg.get_add_data(
                    i_batch_card_rec => l_batch_card_tab(i)
                  , i_card_info_rec  => l_card_info_tab(i)
                  , o_add_line       => l_add_line
                );
                l_curr_line := l_curr_line || l_add_line;

                --add begin tags
                l_curr_line := get_start_line(l_curr_line) || l_curr_line;

                -- put line
                put_line (
                    i_raw_data       => l_curr_line
                  , i_batch_card_rec => l_batch_card_tab(i)
                  , i_card_info_rec  => l_card_info_tab(i)
                );

                trc_log_pkg.debug(
                    i_text          => 'l_curr_line = ' || l_curr_line
                );

            exception
                when others then
                    rollback to savepoint processing_next_card;

                    trc_log_pkg.debug(
                        i_text => sqlerrm
                    );

                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
                        o_excepted_count := o_excepted_count + 1;

                        mark_error (
                            i_batch_card_rec  => l_batch_card_tab(i)
                          , i_card_info_rec   => l_card_info_tab(i)
                        );
                    else
                        raise;
                    end if;
            end;

            o_processed_count := o_processed_count + 1;
        end loop;

        prc_api_stat_pkg.log_current(
            i_current_count   => o_processed_count
          , i_excepted_count  => o_excepted_count
        );

        exit when i_perso_cur%notfound or o_processed_count >= l_card_count;
    end loop;

exception
    when others then
        close_file (
            i_status  => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
        raise;
end process_1_2;

procedure generate_without_batch(
    i_pin_mailer_request        in     com_api_type_pkg.t_dict_value  default null
  , i_inst_id                   in     com_api_type_pkg.t_inst_id
  , i_agent_id                  in     com_api_type_pkg.t_agent_id    default null
  , i_product_id                in     com_api_type_pkg.t_short_id    default null
  , i_card_type_id              in     com_api_type_pkg.t_tiny_id     default null
  , i_perso_priority            in     com_api_type_pkg.t_dict_value  default null
  , i_sort_id                   in     com_api_type_pkg.t_tiny_id
  , i_lang                      in     com_api_type_pkg.t_dict_value
  , i_empty_address             in     com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
  , i_check_cardholder_name     in     com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
  , i_card_count                in     com_api_type_pkg.t_tiny_id     default null
  , i_include_limits            in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_include_service           in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_include_flexible_fields   in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_ocg_version               in     com_api_type_pkg.t_name        default null
  , i_replace_inst_id_by_number in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_session_id                in     com_api_type_pkg.t_long_id     default null
  , i_start_date                in     date                           default null
  , i_end_date                  in     date                           default null
  , i_flow_id                   in     com_api_type_pkg.t_tiny_id     default null
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.generate_without_batch: ';

    l_perso_cur                sys_refcursor;

    l_batch_id                 com_api_type_pkg.t_short_id;
    l_seqnum                   com_api_type_pkg.t_seqnum;

    l_batch                    prs_api_type_pkg.t_batch_rec;
    l_warning_msg              com_api_type_pkg.t_text;

    l_estimated_count          com_api_type_pkg.t_long_id := 0;
    l_curr_estimated_cnt       com_api_type_pkg.t_long_id := 0;
    l_excepted_count           com_api_type_pkg.t_long_id := 0;
    l_processed_count          com_api_type_pkg.t_long_id := 0;
    l_format_id                com_api_type_pkg.t_tiny_id;

begin
    savepoint perso_process_start;

    clear_global_data;

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Process started'
    );

    -- get default format for uid
    l_format_id :=
        set_ui_value_pkg.get_inst_param_n(
            i_param_name => iss_api_const_pkg.UID_NAME_FORMAT
          , i_inst_id    => i_inst_id
        );

    -- First, unload all new batches
    for r in (
        select b.id batch_id
             , b.sort_id
          from prs_batch b
         where b.status = prs_api_const_pkg.BATCH_STATUS_INITIAL
           and b.inst_id = i_inst_id
           and (b.agent_id = i_agent_id or i_agent_id is null)
           and (b.product_id = i_product_id or i_product_id is null)
           and (b.card_type_id = i_card_type_id or i_card_type_id is null)
           and (b.perso_priority = i_perso_priority or i_perso_priority is null)
    ) loop

        select count(1)
          into l_curr_estimated_cnt
          from prs_batch_card
         where batch_id = r.batch_id;

        l_estimated_count := l_estimated_count + l_curr_estimated_cnt;

        trc_log_pkg.debug(
            i_text => 'l_estimated_count = ' || l_estimated_count
        );

        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );

        if l_curr_estimated_cnt > 0 then

            prs_api_card_pkg.get_batch_cards (
                o_perso_cur             => l_perso_cur
              , i_batch_id              => r.batch_id
              , i_pin_mailer_request    => i_pin_mailer_request
              , i_lang                  => i_lang
            );

            if i_ocg_version = '1.0' then
                process_1_0(
                    i_perso_cur             => l_perso_cur
                  , i_batch_id              => r.batch_id
                  , i_estimated_count       => l_estimated_count
                  , o_excepted_count        => l_excepted_count
                  , o_processed_count       => l_processed_count
                  , i_empty_address         => i_empty_address
                  , i_check_cardholder_name => i_check_cardholder_name
                  , i_format_id             => l_format_id
                );
            elsif i_ocg_version = '1.2' then
                process_1_2(
                    i_perso_cur                 => l_perso_cur
                  , i_batch_id                  => r.batch_id
                  , i_estimated_count           => l_estimated_count
                  , o_excepted_count            => l_excepted_count
                  , o_processed_count           => l_processed_count
                  , i_empty_address             => i_empty_address
                  , i_check_cardholder_name     => i_check_cardholder_name
                  , i_format_id                 => l_format_id
                  , i_include_limits            => i_include_limits
                  , i_include_service           => i_include_service
                  , i_include_flexible_fields   => i_include_flexible_fields
                  , i_inst_id                   => i_inst_id
                  , i_replace_inst_id_by_number => i_replace_inst_id_by_number 
                );
            else
                process(
                    i_perso_cur                => l_perso_cur
                  , i_batch_id                 => r.batch_id
                  , i_estimated_count          => l_estimated_count
                  , o_excepted_count           => l_excepted_count
                  , o_processed_count          => l_processed_count
                  , i_empty_address            => i_empty_address
                  , i_check_cardholder_name    => i_check_cardholder_name
                  , i_format_id                => l_format_id
                  , i_include_limits           => i_include_limits
                  , i_include_service          => i_include_service
                  , i_include_flexible_fields  => i_include_flexible_fields
                );
            end if;

            close l_perso_cur;

            prs_api_batch_pkg.mark_ok_batch(
                i_id      => r.batch_id
              , i_status  => prs_api_const_pkg.BATCH_STATUS_PROCESSED
            );

            trc_log_pkg.debug(
                i_text => 'batch_id [' || l_batch_id || '] processed'
            );
        end if;
    end loop;

    -- Secondly, unload all instances, that don't included in batches
    loop
        -- create batch
        prs_ui_batch_pkg.add_batch(
            o_id              => l_batch_id
          , o_seqnum          => l_seqnum
          , i_inst_id         => i_inst_id
          , i_agent_id        => i_agent_id
          , i_product_id      => i_product_id
          , i_card_type_id    => i_card_type_id
          , i_blank_type_id   => null
          , i_card_count      => null
          , i_hsm_device_id   => null
          , i_status          => prs_api_const_pkg.BATCH_STATUS_INITIAL
          , i_sort_id         => i_sort_id
          , i_perso_priority  => i_perso_priority
          , i_lang            => i_lang
          , i_batch_name      => to_char(systimestamp, com_api_const_pkg.TIMESTAMP_FORMAT)
        );

        trc_log_pkg.info(
            i_text        => 'Personalization batch [#1], seq_num [#2]'
          , i_env_param1  => l_batch_id
          , i_env_param2  => l_seqnum
        );

        -- add cards into batch
        prs_ui_batch_card_pkg.mark_batch_card(
            i_batch_id            => l_batch_id
          , i_agent_id            => i_agent_id
          , i_product_id          => i_product_id
          , i_card_type_id        => i_card_type_id
          , i_blank_type_id       => null
          , i_perso_priority      => i_perso_priority
          , i_pin_request         => null
          , i_embossing_request   => null
          , i_pin_mailer_request  => i_pin_mailer_request
          , o_warning_msg         => l_warning_msg
          , i_lang                => i_lang
          , i_card_count          => i_card_count
          , i_session_id          => i_session_id
          , i_start_date          => i_start_date
          , i_end_date            => i_end_date
          , i_flow_id             => i_flow_id
        );

        -- get estimated_count
        select count(*)
          into l_curr_estimated_cnt
          from prs_batch_card
         where batch_id = l_batch_id;

        l_estimated_count := l_estimated_count + l_curr_estimated_cnt;

        trc_log_pkg.debug(
            i_text => 'l_estimated_count = ' || l_estimated_count
        );

        prc_api_stat_pkg.log_estimation(
            i_estimated_count  => l_estimated_count
        );

        if l_curr_estimated_cnt > 0 then

            l_batch := prs_api_batch_pkg.get_batch(
                           i_id         => l_batch_id
                       );

            prs_api_card_pkg.get_batch_cards (
                o_perso_cur             => l_perso_cur
              , i_batch_id              => l_batch_id
              , i_pin_mailer_request    => i_pin_mailer_request
              , i_lang                  => i_lang
            );

            if i_ocg_version = '1.0'
            then
                process_1_0(
                    i_perso_cur             => l_perso_cur
                  , i_batch_id              => l_batch_id
                  , i_estimated_count       => l_estimated_count
                  , o_excepted_count        => l_excepted_count
                  , o_processed_count       => l_processed_count
                  , i_empty_address         => i_empty_address
                  , i_check_cardholder_name => i_check_cardholder_name
                  , i_format_id             => l_format_id
                );
            elsif i_ocg_version = '1.2' then
                process_1_2(
                    i_perso_cur                 => l_perso_cur
                  , i_batch_id                  => l_batch_id
                  , i_estimated_count           => l_estimated_count
                  , o_excepted_count            => l_excepted_count
                  , o_processed_count           => l_processed_count
                  , i_empty_address             => i_empty_address
                  , i_check_cardholder_name     => i_check_cardholder_name
                  , i_format_id                 => l_format_id
                  , i_include_limits            => i_include_limits
                  , i_include_service           => i_include_service
                  , i_include_flexible_fields   => i_include_flexible_fields
                  , i_inst_id                   => i_inst_id
                  , i_replace_inst_id_by_number => i_replace_inst_id_by_number 
                );
            else
                process(
                    i_perso_cur                => l_perso_cur
                  , i_batch_id                 => l_batch_id
                  , i_estimated_count          => l_estimated_count
                  , o_excepted_count           => l_excepted_count
                  , o_processed_count          => l_processed_count
                  , i_empty_address            => i_empty_address
                  , i_check_cardholder_name    => i_check_cardholder_name
                  , i_format_id                => l_format_id
                  , i_include_limits           => i_include_limits
                  , i_include_service          => i_include_service
                  , i_include_flexible_fields  => i_include_flexible_fields
                );
            end if;

            close l_perso_cur;

            prs_api_batch_pkg.mark_ok_batch(
                i_id      => l_batch_id
              , i_status  => prs_api_const_pkg.BATCH_STATUS_PROCESSED
            );

        else
            trc_log_pkg.debug(
                i_text    => LOG_PREFIX || 'l_curr_estimated_cnt = 0. Exit.'
            );

            prs_ui_batch_pkg.remove_batch(
                i_id      => l_batch_id
              , i_seqnum  => l_seqnum
            );

            exit;
        end if;
    end loop;

    put_trailer;
    clear_global_data;

    prc_api_stat_pkg.log_end (
        i_excepted_total    => l_excepted_count
      , i_processed_total   => l_processed_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'Process finished'
    );
exception
    when others then
        rollback to savepoint perso_process_start;

        clear_global_data;

        if l_perso_cur%isopen then
            close l_perso_cur;
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end generate_without_batch;

procedure load_cardgen_file(
    i_card_state               in     com_api_type_pkg.t_dict_value
) is
    l_record_count             com_api_type_pkg.t_long_id := 0;
    l_errors_count             com_api_type_pkg.t_long_id := 0;
    l_record_number            com_api_type_pkg.t_long_id := 0;

    l_record_type              com_api_type_pkg.t_dict_value;
    l_trailer_load             com_api_type_pkg.t_boolean;
    l_header_load              com_api_type_pkg.t_boolean;

    l_card_number              com_api_type_pkg.t_card_number;
    l_member_number            com_api_type_pkg.t_curr_code;
    l_pvv                      com_api_type_pkg.t_auth_code;
    l_pin_offset               com_api_type_pkg.t_cmid;
    l_plastic_issued           com_api_type_pkg.t_boolean;
    l_pin_mailer               com_api_type_pkg.t_dict_value;
    l_active_date              com_api_type_pkg.t_dict_value;
    l_card_instance_id         com_api_type_pkg.t_medium_id;
    l_pvk_index                com_api_type_pkg.t_tiny_id;
    l_inst_id                  com_api_type_pkg.t_tiny_id;
    l_split_hash               com_api_type_pkg.t_tiny_id;
    l_header_date              com_api_type_pkg.t_dict_value;
    l_state                    com_api_type_pkg.t_dict_value;

    l_ok_id_tab                com_api_type_pkg.t_medium_tab;
    l_pvv_tab                  com_api_type_pkg.t_tiny_tab;
    l_pin_offset_tab           com_api_type_pkg.t_cmid_tab;
    l_pvk_index_tab            com_api_type_pkg.t_tiny_tab;
    l_pin_block_tab            com_api_type_pkg.t_varchar2_tab;
    l_pin_block_format_tab     com_api_type_pkg.t_dict_tab;
    l_pin_mailer_tab           com_api_type_pkg.t_dict_tab;
    l_inst_tab                 com_api_type_pkg.t_tiny_tab;
    l_split_hash_tab           com_api_type_pkg.t_tiny_tab;
    l_params                   com_api_type_pkg.t_param_tab;

    -- Count only 'data records' without header (BRDG01) and footer (BRDG02)
    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id
           and trim(substr(a.raw_data, 1, 8)) not in ('BRDG01','BRDG02');

    procedure register_sensitive_data(
        i_id                  in com_api_type_pkg.t_medium_id
      , i_pvv                 in com_api_type_pkg.t_tiny_id
      , i_pin_offset          in com_api_type_pkg.t_cmid
      , i_pvk_index           in com_api_type_pkg.t_tiny_id
      , i_pin_block           in com_api_type_pkg.t_pin_block
      , i_pin_block_format    in com_api_type_pkg.t_curr_code
      , i_pin_mailer          in com_api_type_pkg.t_dict_value
      , i_inst_id             in com_api_type_pkg.t_tiny_id
      , i_split_hash          in com_api_type_pkg.t_tiny_id
    ) is
        i                        binary_integer;
    begin
        i := l_ok_id_tab.count + 1;
        -- card instance
        l_ok_id_tab(i)            := i_id;
        l_pvv_tab(i)              := i_pvv;
        l_pin_offset_tab(i)       := i_pin_offset;
        l_pvk_index_tab(i)        := nvl(i_pvk_index, iss_api_const_pkg.DEFAULT_PIN_KEY_INDEX_VALUE);
        l_pin_block_tab(i)        := i_pin_block;
        l_pin_block_format_tab(i) := nvl(i_pin_block_format, prs_api_const_pkg.PIN_BLOCK_FORMAT_ANSI);
        l_pin_mailer_tab(i)       := i_pin_mailer;
        l_inst_tab(i)             := i_inst_id;
        l_split_hash_tab(i)       := i_split_hash;
    end;

    procedure update_sensitive_data is
    begin
        trc_log_pkg.debug(
            i_text          => 'update_sensitive_data'
        );

        iss_api_card_instance_pkg.update_sensitive_data(
            i_id                => l_ok_id_tab
          , i_pvk_index         => l_pvk_index_tab
          , i_pvv               => l_pvv_tab
          , i_pin_offset        => l_pin_offset_tab
          , i_pin_block         => l_pin_block_tab
          , i_pin_block_format  => l_pin_block_format_tab
        );
        forall i in 1 .. l_ok_id_tab.count
            update iss_card_instance
               set pin_mailer_request = l_pin_mailer_tab(i)
                 , iss_date           = case l_plastic_issued
                                            when com_api_const_pkg.TRUE then
                                                coalesce(to_date(l_active_date, 'dd.mm.yyyy'), to_date(l_header_date, 'mmddyyyy'))
                                            else
                                                iss_date
                                        end
             where id = l_ok_id_tab(i);

        for i in 1 .. l_ok_id_tab.count
        loop
            evt_api_event_pkg.register_event(
                i_event_type          => iss_api_const_pkg.EVENT_TYPE_UPD_SENSITIVE_DATA
              , i_eff_date            => com_api_sttl_day_pkg.get_sysdate
              , i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              , i_object_id           => l_ok_id_tab(i)
              , i_inst_id             => l_inst_tab(i)
              , i_split_hash          => l_split_hash_tab(i)
              , i_param_tab           => l_params
            );
        end loop;

        l_ok_id_tab.delete;
        l_pvv_tab.delete;
        l_pin_offset_tab.delete;
        l_pvk_index_tab.delete;
        l_pin_block_tab.delete;
        l_pin_block_format_tab.delete;
        l_pin_mailer_tab.delete;
        l_inst_tab.delete;
        l_split_hash_tab.delete;
    end;

begin
    trc_log_pkg.debug(
        i_text          => 'load_cg_file start'
    );

    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count
    );

    trc_log_pkg.debug(
        i_text          => 'estimation record = ' || l_record_count
    );

    l_record_count := 0;

    for p in (
        select id session_file_id
             , record_count
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
      order by id
    ) loop
        l_errors_count := 0;

        begin
            savepoint sp_cg_incoming_file;

            l_record_number := 1;
            --l_tc_buffer.delete;
            l_trailer_load := com_api_const_pkg.FALSE;
            l_header_load  := com_api_const_pkg.FALSE;

            for r in (
                select record_number
                     , raw_data
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
              order by record_number
            ) loop
                l_record_type := substr(r.raw_data, 1, 8);
                trc_log_pkg.debug(
                    i_text          => 'l_record_type = ' || l_record_type
                );

                if trim(l_record_type) = 'BRDG01' then
                    l_header_load   := get_true;
                    l_header_date   := trim(substr(r.raw_data, 48, 8));

                elsif trim(l_record_type) = 'BRDG02' then
                    l_trailer_load  := get_true;

                elsif trim(l_record_type) = 'BRDG03' then

                    l_card_number   := trim(substr(r.raw_data, 21, 24));
                    l_member_number := trim(substr(r.raw_data, 239, 2));
                    if l_member_number is null then
                        l_member_number := trim(substr(r.raw_data, 45, 1));
                    end if;

                    l_pvv             := trim(substr(r.raw_data, 148, 5));
                    l_pin_offset      := trim(substr(r.raw_data, 130, 4));
                    if l_pin_offset is null then
                        l_pin_offset  := trim(substr(r.raw_data, 211, 12));
                    end if;

                    --l_plastic_order := trim(substr(r.raw_data, 153, 2));
                    l_plastic_issued:= case
                                           when trim(substr(r.raw_data, 155, 2)) = '00' then com_api_const_pkg.FALSE
                                           else com_api_const_pkg.TRUE
                                       end;
                    l_pin_mailer    := trim(substr(r.raw_data, 157, 8));

                    if l_pin_mailer = 'PINM1' then
                        l_pin_mailer := iss_api_const_pkg.PIN_MAILER_REQUEST_PRINT;
                    else
                        l_pin_mailer := iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT;
                    end if;

                    l_active_date   := trim(substr(r.raw_data, 165, 8));
                    trc_log_pkg.debug(
                        i_text        => 'Record data: [#1], [#2], [#3], [#4]'
                      , i_env_param1  => l_card_number
                      , i_env_param2  => l_pvv
                      , i_env_param3  => l_pin_mailer
                      , i_env_param4  => l_active_date
                    );

                    l_card_instance_id := iss_api_card_instance_pkg.get_card_instance_id(
                                              i_card_id          => null
                                            , i_card_number      => l_card_number
                                            , i_seq_number       => to_number(l_member_number)
                                            , i_expir_date       => null
                                            , i_raise_error      => com_api_const_pkg.TRUE
                                          );
                    trc_log_pkg.debug(
                        i_text          => 'l_card_instance = ' || l_card_instance_id
                    );

                    select inst_id
                         , split_hash
                         , state
                      into l_inst_id
                         , l_split_hash
                         , l_state
                      from iss_card_instance
                     where id = l_card_instance_id;

                    if l_state != iss_api_const_pkg.CARD_STATE_CLOSED then
                        -- update card state
                        iss_api_card_instance_pkg.change_card_state(
                            i_id          => l_card_instance_id
                          , i_card_state  => i_card_state
                          , i_raise_error => com_api_type_pkg.TRUE
                        );
                    else
                        trc_log_pkg.warn(
                            i_text        => 'STATE_NOT_CHANGED_FOR_CLOSED_CARD'
                          , i_env_param1  => l_card_instance_id
                        );
                        l_errors_count := l_errors_count + 1;
                    end if;

                    begin
                        select m.pvk_index
                          into l_pvk_index
                          from iss_card_instance i
                             , prs_method m
                         where i.id = l_card_instance_id
                           and m.id = i.perso_method_id;
                    exception
                        when no_data_found then
                            null;
                    end;
                    trc_log_pkg.debug(
                        i_text          => 'l_pvk_index = ' || l_pvk_index
                    );

                    register_sensitive_data(
                        i_id               => l_card_instance_id
                      , i_pvv              => to_number(l_pvv)
                      , i_pin_offset       => l_pin_offset
                      , i_pvk_index        => l_pvk_index
                      , i_pin_block        => null
                      , i_pin_block_format => prs_api_const_pkg.PIN_BLOCK_FORMAT_ANSI
                      , i_pin_mailer       => l_pin_mailer
                      , i_inst_id          => l_inst_id
                      , i_split_hash       => l_split_hash
                    );

                    l_record_count  := l_record_count + 1;
                else
                    trc_log_pkg.error(
                        i_text          => 'Unknown record type: ['|| trim(l_record_type) ||']'
                    );
                    l_errors_count := l_errors_count + 1;
                end if;

                l_record_number := l_record_number + 1;

                if mod(l_record_count, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => g_errors_count + l_errors_count
                    );

                    update_sensitive_data;
                end if;

            end loop;

            trc_log_pkg.debug(
                i_text          => 'End process file'
            );

            prc_api_file_pkg.close_file(
                i_sess_file_id          => p.session_file_id
              , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );

            update_sensitive_data;

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_cg_incoming_file;

                g_errors_count := g_errors_count + p.record_count;
                l_errors_count := 0;
                l_record_count := l_record_count + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_count
                  , i_excepted_count => g_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );

                raise;
        end;
    end loop;

    g_errors_count := g_errors_count + l_errors_count;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => g_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text          => 'load_cg_file end'
    );

exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end load_cardgen_file;

end itf_prc_cardgen_pkg;
/
