create or replace package body cst_apc_com_pkg as

function get_main_card_id (
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id default null
) return com_api_type_pkg.t_medium_id
is
    l_split_hash         com_api_type_pkg.t_tiny_id;
begin

    l_split_hash := i_split_hash;
    if l_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(
                            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id     => i_account_id
                        );
    end if;

    for rec in (
        select t.id as card_id
          from (
                select c.id
                     , row_number() over (order by
                                          case
                                              when c.category = 'CRCG0800' then 1
                                              when c.category = 'CRCG0600' then 2
                                              when c.category = 'CRCG0200' then 3
                                              when c.category = 'CRCG0900' then 4
                                          end) as seqnum
                  from iss_card_vw c
                     , acc_account_object ao
                 where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and ao.object_id = c.id
                   and ao.account_id = i_account_id
                   and ao.split_hash = l_split_hash
               ) t
         order by t.seqnum
    ) loop
        return rec.card_id;
    end loop;

    return com_api_const_pkg.FALSE;

end get_main_card_id;


function format_amount (
    i_amount              in     com_api_type_pkg.t_money
  , i_curr_code           in     com_api_type_pkg.t_curr_code
  , i_add_curr_name       in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_use_separator       in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_separator           in     com_api_type_pkg.t_byte_char  default ','
  , i_mask_error          in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name
is
    l_format_base com_api_type_pkg.t_name;
    l_result      com_api_type_pkg.t_name;
begin
    if i_use_separator = com_api_type_pkg.TRUE then
        l_format_base := 'FM999' || i_separator || '999' || i_separator || '999' || i_separator || '999' || i_separator || '990';
    else
        l_format_base := 'FM999999999999990';
    end if;

    if i_amount is not null then -- return null if i_amount is null
        select to_char(
                        round(i_amount) / power(10, exponent)
                      , l_format_base || case
                                             when exponent > 0
                                             then '.' || rpad('0', exponent, '0')
                                             else null
                                         end
                      )
               || case
                      when i_add_curr_name = com_api_type_pkg.TRUE
                      then ' ' || name
                      else ''
                  end
          into l_result
          from com_currency
         where code = i_curr_code;
    end if;

    return l_result;

exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            return to_char(i_amount);
        else
            com_api_error_pkg.raise_error(
                i_error      => 'CURRENCY_NOT_FOUND'
              , i_env_param1 => i_curr_code
            );
        end if;

end format_amount;


function get_banner_filename (
    i_banner_name         in     com_api_type_pkg.t_text
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_mask_error          in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name is
    l_filename            com_api_type_pkg.t_name;
begin
    select filename
      into l_filename
      from rpt_banner b
     where exists (
                   select 1
                     from com_i18n c
                    where c.table_name = 'RPT_BANNER'
                      and c.column_name = 'LABEL'
                      and c.text = i_banner_name
                      and c.object_id = b.id
                  );

    return l_filename;
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            return null;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'CST_BANNER_NOT_FOUND'
              , i_env_param1 => i_banner_name
            );
        end if;
end get_banner_filename;


function get_banner_message (
    i_banner_name         in     com_api_type_pkg.t_text
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_mask_error          in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_message    com_api_type_pkg.t_text;
begin
    select com_api_i18n_pkg.get_text('RPT_BANNER', 'DESCRIPTION', c.object_id, i_lang)
      into l_message
      from com_i18n c
     where c.table_name = 'RPT_BANNER'
       and c.column_name = 'LABEL'
       and c.text = i_banner_name
       and exists (
                   select 1
                     from rpt_banner b
                    where b.id = c.object_id
                      and b.status = 'BNST0100'
                  );

    return l_message;

exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            return null;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'CST_BANNER_NOT_FOUND'
              , i_env_param1 => i_banner_name
            );
        end if;
end get_banner_message;


function get_cardholder_gender (
    i_card_id             in     com_api_type_pkg.t_medium_id
  , i_mask_error          in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_dict_value
is
    l_cardholder            iss_api_type_pkg.t_cardholder;
    l_person                com_api_type_pkg.t_person;
begin
    l_cardholder :=
        iss_api_cardholder_pkg.get_cardholder(
            i_cardholder_id  => iss_api_cardholder_pkg.get_cardholder_by_card(
                                    i_card_id => i_card_id
                                )
          , i_mask_error     => i_mask_error
        );

    l_person :=
        com_api_person_pkg.get_person(
            i_person_id   => l_cardholder.person_id
          , i_mask_error  => i_mask_error
        );

    return l_person.gender;
end get_cardholder_gender;

end cst_apc_com_pkg;
/
