create or replace package body itf_cst_cardgen_pkg is
/*********************************************************
 *  Custom cardgen processing API <br />
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 18.02.2015 <br />
 *  Last changed by $Author: kondratyev $ <br />
 *  $LastChangedDate:: 2015-02-18 12:20:06 +0400#$ <br />
 *  Revision: $LastChangedRevision: 36849 $ <br />
 *  Module: itf_cst_cardgen_pkg <br />
 *  @headcom
 **********************************************************/

procedure get_add_data(
    i_batch_card_rec in     prs_api_type_pkg.t_batch_card_rec
  , i_card_info_rec  in     prs_api_type_pkg.t_card_info_rec
  , o_add_line          out com_api_type_pkg.t_lob_data
) is
    l_tags_value_tab        com_api_type_pkg.t_param_tab;

    l_account_rec           acc_api_type_pkg.t_account_rec;
    l_name                  com_api_type_pkg.t_name;
    l_lang                  com_api_type_pkg.t_dict_value;

    function get_tag_length(
        i_len               in  com_api_type_pkg.t_tiny_id
    ) return varchar2
    is
        l_result                varchar2(4);
        l_ber_tlv_min_length    com_api_type_pkg.t_tiny_id    default 127;
        l_ber_tlv_add_length    com_api_type_pkg.t_short_id   default 32768;
    begin
        l_result :=
            case when i_len > l_ber_tlv_min_length
                then trim(to_char((i_len + l_ber_tlv_add_length), 'XXXX'))
                else lpad(trim(to_char(i_len, lpad('X', length(i_len), 'X'))), 2, '0')
            end;
        return l_result;
    end;
begin
    --Customer Name
    select i_batch_card_rec.embossed_surname
           || nvl2(i_batch_card_rec.embossed_second_name,  ' ' || i_batch_card_rec.embossed_second_name, null)
           || ' ' || i_batch_card_rec.embossed_first_name
      into l_tags_value_tab('DF8171')
      from dual;
    /*
    --National ID
    if i_card_info_rec.id_type = 'National ID' then
        l_tags_value_tab('DF801G') := i_card_info_rec.id_number;
    else
        l_tags_value_tab('DF801G') := '';
    end if;
    */
    l_tags_value_tab('DF8645') := i_card_info_rec.agent_number;
    --Credit account
    l_account_rec := acc_api_account_pkg.get_account(
                         i_entity_type      => iss_api_const_pkg.ENTITY_TYPE_CARD
                       , i_object_id        => i_batch_card_rec.card_id
                       , i_account_type     => acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
                     );
    --Assigned credit limit
    l_tags_value_tab('DF8059') := cst_cfc_com_pkg.get_balance_amount(
                                      i_account_id     => l_account_rec.account_id
                                    , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
                                  );
    -- Account number
    l_tags_value_tab('DF8780') := coalesce(l_account_rec.account_number,
        com_api_flexible_data_pkg.get_flexible_value(
            i_field_name    => cst_cfc_api_const_pkg.CST_CFC_RESERVED_ACC_NUMBER
          , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id     => i_batch_card_rec.card_id
        )
    );
    -- Client tariff
    l_tags_value_tab('DF8781') :=
    com_api_flexible_data_pkg.get_flexible_value(
        i_field_name    => cst_cfc_api_const_pkg.FLEX_CLIENT_TARIFF
      , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_id     => i_batch_card_rec.card_id
    );
    --Interest rate & Extra due date
    if l_account_rec.account_id is not null then
        l_tags_value_tab('DF8782') :=
        cst_cfc_com_pkg.get_interest_rate(
            i_account_id        => l_account_rec.account_id
          , i_split_hash        => l_account_rec.split_hash
          , i_operation_type    => opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
          , i_is_add_int_rate   => com_api_const_pkg.FALSE
          , i_is_welcome_rate   => com_api_const_pkg.TRUE
        );

        l_tags_value_tab('DF8783') :=
        cst_cfc_com_pkg.get_extra_due_date(i_account_id => l_account_rec.account_id);
    else
        l_tags_value_tab('DF8782') := '';
        l_tags_value_tab('DF8783') := '';
    end if;

    l_tags_value_tab('DF860G') :=
    get_article_text(i_article => iss_api_card_instance_pkg.get_instance(
                                      i_id  => i_batch_card_rec.card_instance_id).delivery_channel
                    );

    ntf_api_notification_pkg.get_mobile_number(
        i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id     => i_batch_card_rec.customer_id
      , i_contact_type  => com_api_const_pkg.CONTACT_TYPE_PRIMARY
      , o_address       => l_tags_value_tab('DF8027')
      , o_lang          => l_lang
    );

    l_name := l_tags_value_tab.first;

    while l_name is not null loop
        if l_tags_value_tab(l_name) is not null then
            o_add_line := o_add_line
                        || l_name
                        || get_tag_length(length(l_tags_value_tab(l_name)))
                        || l_tags_value_tab(l_name);
        end if;

        l_name := l_tags_value_tab.next(l_name);
    end loop;

exception
    when com_api_error_pkg.e_application_error then
        o_add_line := '';
end;

procedure collect_file_params (
    i_batch_card_rec in     prs_api_type_pkg.t_batch_card_rec
  , i_card_info_rec  in     prs_api_type_pkg.t_card_info_rec
  , io_params        in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    rul_api_param_pkg.set_param (
        i_name       => prs_api_const_pkg.PARAM_PERSO_PRIORITY
      , i_value      => i_batch_card_rec.perso_priority
      , io_params    => io_params
    );

    rul_api_param_pkg.set_param (
        i_name       => prs_api_const_pkg.PARAM_CARD_TYPE_NAME
      , i_value      => get_text('net_card_type',   'name', i_batch_card_rec.card_type_id, i_batch_card_rec.lang)
      , io_params    => io_params
    );
end collect_file_params;


end;
/