create or replace package body cst_cfc_api_collection_pkg as

COLLECTION_DETAIL_FILE_HEADER  constant com_api_type_pkg.t_raw_data     := 'FILE|CMS';
BULK_LIMIT                     constant integer                         := 1000;
DELIMETER                      constant com_api_type_pkg.t_name         := '|';
DATE_FORMAT                    constant com_api_type_pkg.t_name         :=  cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT;
g_lang                         com_api_type_pkg.t_dict_value;

procedure get_customer_data(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , io_customer_id_tab      in  out nocopy num_tab_tpt
  , o_ref_cursor            out sys_refcursor
)as
begin
    open o_ref_cursor for
    select 'CUST' tag
         , 1 tag_order
         , customer_number
         , customer_number      || DELIMETER ||
           customer_number      || DELIMETER ||
           customer_name        || DELIMETER ||
           person_gender        || DELIMETER ||
           to_char(birthday, DATE_FORMAT)    || DELIMETER ||
           nvl(phone_num, landline_num)      || DELIMETER ||
           email                || DELIMETER ||
           marital_status       || DELIMETER ||
           case
               when phone_num is not null then 'Mobile phone'
               when landline_num is not null then 'Landline'
               else 'N/A'
           end                  || DELIMETER ||
           prev_phone_num       || DELIMETER ||
           id_issued_place      || DELIMETER ||
           direct_debit_info    || DELIMETER ||
           to_char(id_issue_date, DATE_FORMAT)  || DELIMETER ||
           reserved_field       || DELIMETER ||
           id_number data_content
     from(
           select c.customer_number
                , com_ui_object_pkg.get_object_desc(c.entity_type, c.object_id, nvl(p.lang, get_user_lang)) customer_name
                , case c.entity_type
                      when com_api_const_pkg.ENTITY_TYPE_PERSON then com_api_dictionary_pkg.get_article_text(p.gender, p.lang)
                      else null
                  end person_gender
                , case c.entity_type
                      when com_api_const_pkg.ENTITY_TYPE_PERSON then p.birthday
                      else null
                  end birthday
                , com_api_contact_pkg.get_contact_string(
                      i_contact_id     => co.contact_id
                    , i_commun_method  => com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                    , i_start_date     => get_sysdate
                  ) phone_num
                , com_api_contact_pkg.get_contact_string(
                      i_contact_id     => co.contact_id
                    , i_commun_method  => com_api_const_pkg.COMMUNICATION_METHOD_PHONE
                    , i_start_date     => get_sysdate
                  ) landline_num
                , com_api_contact_pkg.get_contact_string(
                      i_contact_id     => co.contact_id
                    , i_commun_method  => com_api_const_pkg.COMMUNICATION_METHOD_EMAIL
                    , i_start_date     => get_sysdate
                  ) email
                , c.marital_status
                , cst_cfc_com_pkg.get_prev_contact_info(
                      i_contact_id     => co.contact_id
                    , i_commun_method  => com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                    , i_start_date     => get_sysdate
                  ) prev_phone_num
                , com_api_flexible_data_pkg.get_flexible_value(
                      cst_cfc_api_const_pkg.FLEX_ID_ISSUE_PLACE
                    , com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                    , c.id
                  ) id_issued_place
                , cst_cfc_com_pkg.get_direct_debit_info(i_customer_id => c.id) direct_debit_info
                , ido.id_issue_date
                , '' reserved_field
                , ido.id_number
             from prd_customer c
                , com_person p
                , com_contact_object co
                , (select row_number() over (partition by i.object_id order by i.id desc) rng
                        , i.object_id
                        , i.id_type
                        , com_api_dictionary_pkg.get_article_text(
                              i_article => i.id_type
                            , i_lang    => g_lang
                          ) id_name
                        , substr(i.id_number, 0, 20) id_number
                        , i.id_issue_date
                        , i.id_expire_date
                     from com_id_object i
                    where i.id_type    = com_api_const_pkg.ID_TYPE_NATIONAL_ID --'IDTP0045'
                      and entity_type  = com_api_const_pkg.ENTITY_TYPE_PERSON
                  ) ido
            where c.inst_id            = nvl(i_inst_id, c.inst_id)
              and c.object_id          = p.id(+)
              and c.id                 = co.object_id(+)
              and co.entity_type(+)    = com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
              and co.contact_type(+)   = com_api_const_pkg.CONTACT_TYPE_PRIMARY --'CNTTPRMC'
              and c.object_id          = ido.object_id(+)
              and 1                    = ido.rng(+)
              and c.split_hash in (select split_hash from com_api_split_map_vw)
              and c.id in ((select column_value from table(cast(io_customer_id_tab as num_tab_tpt))))
         );
end get_customer_data;

procedure get_account_data(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , io_account_id_tab       in  out nocopy num_tab_tpt
  , o_ref_cursor            out sys_refcursor
)as
begin
    open o_ref_cursor for
    select 'CACC' tag
         , 2 tag_order
         , customer_number
         , customer_number              || DELIMETER ||
           account_number               || DELIMETER ||
           nvl(total_overdue_date, 0)   || DELIMETER ||
           'CC'                         || DELIMETER ||
           assigned_exceed              || DELIMETER ||
           overdue_amt                  || DELIMETER ||
           outstanding_amt              || DELIMETER ||
           daily_mad                    || DELIMETER ||
           unbill_amt                   || DELIMETER ||
           latest_payment_amt           || DELIMETER ||
           to_char(latest_payment_date, DATE_FORMAT) || DELIMETER ||
           to_char(start_date, DATE_FORMAT)          || DELIMETER ||
           to_char(reg_date, DATE_FORMAT)            || DELIMETER ||
           to_char(reissue_date, DATE_FORMAT)        || DELIMETER ||
           to_char(expir_date, DATE_FORMAT)          || DELIMETER ||
           currency                     || DELIMETER ||
           interest_outstanding_amt     || DELIMETER ||
           overlimit_flag               || DELIMETER ||
           overlimit_amt                || DELIMETER ||
           charge_outstanding_amount    || DELIMETER ||
           total_cwd_amt                || DELIMETER ||
           aval_cwd_amt                 || DELIMETER ||
           to_char(latest_overdue_date, DATE_FORMAT) || DELIMETER ||
           to_char(last_trx_date, DATE_FORMAT)       || DELIMETER ||
           highest_tad                  || DELIMETER ||
           bill_date                    || DELIMETER ||
           to_char(last_overdue_date, DATE_FORMAT)   || DELIMETER ||
           interest_rate                || DELIMETER ||
           min_amount_due1              || DELIMETER ||
           to_char(statement_date, DATE_FORMAT)      || DELIMETER ||
           latest_tad                   || DELIMETER ||
           scheme_name || nvl2(client_tariff, '/'||client_tariff, '') || DELIMETER ||  --block_code_1
           to_char(block_date_1, DATE_FORMAT)        || DELIMETER ||
           card_status                  || DELIMETER ||
           to_char(acc_latest_status_date, DATE_FORMAT)  || DELIMETER ||
           total_amount_due             || DELIMETER ||
           bucket                       || DELIMETER ||
           delinquency_str              || DELIMETER ||
           ovderdue_fee                 || DELIMETER ||
           overdue_interest             || DELIMETER ||
           latest_tran_amt              || DELIMETER ||
           bill_date_1                  || DELIMETER ||
           to_char(c_latest_hot_status_date, DATE_FORMAT)|| DELIMETER ||
           status                       || DELIMETER ||
           reserved_field_1             || DELIMETER ||
           lending_amt                  || DELIMETER ||
           revised_bucket               || DELIMETER ||
           pre_bucket                   || DELIMETER ||
           overdue_interest_2           || DELIMETER ||
           mad2                         || DELIMETER ||
           reserved_field_1             || DELIMETER ||
           total_interest               || DELIMETER ||
           to_char(due_date, DATE_FORMAT)            || DELIMETER ||
           to_char(c_latest_status_date, DATE_FORMAT)|| DELIMETER ||
           principal_amt                || DELIMETER ||
           net_salary                   || DELIMETER ||
           nvl(reserved_field_3, 0)     || DELIMETER ||
           card_type                    || DELIMETER ||
           total_fee                    || DELIMETER ||
           reserved_field_4             || DELIMETER ||
           reserved_field_5             || DELIMETER ||
           blank_field                  || DELIMETER ||
           to_char(c_latest_bucket_date, DATE_FORMAT)|| DELIMETER ||
           department                   || DELIMETER ||
           '' || DELIMETER ||
           card_mask                    || DELIMETER ||
           card_number data_content
     from(
           select cu.customer_number
                , a.account_number
                , greatest(0, trunc(get_sysdate - cst_cfc_com_pkg.get_first_overdue_date(
                                                      i_account_id  => a.id
                                                    , i_split_hash  => a.split_hash))
                          ) total_overdue_date
                , c.product_id
                , cst_cfc_com_pkg.get_balance_amount(
                      i_account_id     => a.id
                    , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED --'BLTP1001'
                  ) assigned_exceed
                , cst_cfc_com_pkg.get_overdue_amount(
                      i_account_id     => a.id
                    , i_split_hash     => a.split_hash
                  ) overdue_amt
                , cst_cfc_com_pkg.get_total_outstanding_amount(
                      i_account_id     => a.id
                    , i_split_hash     => a.split_hash
                  ) outstanding_amt
                , cst_cfc_com_pkg.get_daily_mad(
                      i_account_id     => a.id
                    , i_use_rounding   => com_api_const_pkg.TRUE
                  ) as daily_mad
                , cst_cfc_com_pkg.get_unbill_amount(
                      i_account_id     => a.id
                    , i_split_hash     => a.split_hash
                  ) unbill_amt
                , cst_cfc_com_pkg.get_latest_payment_amount(
                      i_account_id     => a.id
                  ) latest_payment_amt
                , cst_cfc_com_pkg.get_latest_payment_dt(
                      i_account_id     => a.id
                  ) latest_payment_date
                , i.start_date
                , i.reg_date
                , i.reissue_date
                , i.expir_date
                , com_api_currency_pkg.get_currency_name(a.currency) currency
                , (cst_cfc_com_pkg.get_balance_amount(
                       i_account_id    => a.id
                     , i_balance_type  => crd_api_const_pkg.BALANCE_TYPE_INTEREST --'BLTP1003'
                   )
                  +
                   cst_cfc_com_pkg.get_balance_amount(
                       i_account_id    => a.id
                     , i_balance_type  => crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST) --'BLTP1005'
                  ) interest_outstanding_amt
                , case
                      when cst_cfc_com_pkg.get_balance_amount(
                               i_account_id    => a.id
                             , i_balance_type  => 'BLTP1007') != 0 then 1
                      else 0
                  end overlimit_flag
                , cst_cfc_com_pkg.get_balance_amount(
                      i_account_id     => a.id
                    , i_balance_type   => 'BLTP1007') overlimit_amt
                , cst_cfc_com_pkg.get_balance_amount(
                      i_account_id      => a.id
                    , i_balance_type    => crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
                  ) charge_outstanding_amount --'BLTP1005'
                , cst_cfc_com_pkg.get_total_trans_amount(
                      i_entity_type         => com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
                    , i_object_id           => cu.id
                    , i_split_hash          => cu.split_hash
                    , i_transaction_type    => opr_api_const_pkg.OPERATION_TYPE_ATM_CASH --'OPTP0001'
                  ) total_cwd_amt
                , acc_api_balance_pkg.get_aval_balance_amount_only(
                      i_account_id      => a.id
                    , i_date            => get_sysdate()
                    , i_date_type       => com_api_const_pkg.DATE_PURPOSE_PROCESSING --'DTPR0001'
                  ) aval_cwd_amt
                , cst_cfc_com_pkg.get_first_overdue_date(
                      i_account_id      => a.id
                    , i_split_hash      => a.split_hash
                  ) latest_overdue_date
                , cst_cfc_com_pkg.get_last_trx_date(
                      i_entity_type         => com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
                    , i_object_id           => cu.id
                    , i_transaction_type    => opr_api_const_pkg.OPERATION_TYPE_ATM_CASH --'OPTP0001'
                  ) last_trx_date
                , cst_cfc_com_pkg.get_highest_tad(
                      i_account_id      => a.id
                    , i_split_hash      => a.split_hash
                    , i_bill_num        => 12
                  ) highest_tad
                , to_char(cst_cfc_com_pkg.get_cycle_date(
                              i_account_id  => a.id
                            , i_cycle_type  => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE --'CYTP1001'
                  ), 'DD') bill_date
                , cst_cfc_com_pkg.get_first_overdue_date(
                       i_account_id     => a.id
                     , i_split_hash     => a.split_hash
                  ) last_overdue_date
                , cst_cfc_com_pkg.get_interest_rate(
                      i_account_id      => a.id
                    , i_split_hash      => a.split_hash
                    , i_operation_type  => opr_api_const_pkg.OPERATION_TYPE_ATM_CASH --'OPTP0001'
                    , i_is_add_int_rate => 0
                  ) interest_rate
                , crd_invoice_pkg.round_up_mad(
                      i_account_id      => a.id
                    , i_mad             => round(nvl(cst_apc_crd_algo_proc_pkg.get_extra_mad(i_invoice_id => cin.id), 0))
                    , i_tad             => cin.total_amount_due
                    , i_product_id      => c.product_id
                  ) as min_amount_due1
                , cst_cfc_com_pkg.get_cycle_date(
                      i_account_id      => a.id
                    , i_cycle_type      => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE --'CYTP1001'
                    , i_is_next_date    => 0
                  ) statement_date
                , cin.total_amount_due latest_tad
                , com_api_dictionary_pkg.get_article_text(i.state, g_lang) block_code_1
                , to_date(com_api_flexible_data_pkg.get_flexible_value(
                              i_field_name  => cst_apc_const_pkg.FLEX_FIELD_EXTRA_DUE_DATE
                            , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
                            , i_object_id   => cin.id
                         ), com_api_const_pkg.DATE_FORMAT) block_date_1
                , com_api_dictionary_pkg.get_article_text(i.status, g_lang) card_status
                , cst_cfc_com_pkg.get_latest_change_status_dt(
                      i_event_type_tab  => com_dict_tpt(acc_api_const_pkg.EVENT_ACCOUNT_STATUS_CHANGE) -- 'EVNT0310'
                    , i_object_id       => i.id
                  ) acc_latest_status_date
                , cin.total_amount_due
                , coalesce(crd_invoice_pkg.get_converted_aging_period(
                               i_aging_period => cin.aging_period)
                             , to_char(cin.aging_period), 'N/A') bucket
                , cst_cfc_com_pkg.get_delinquency_str(
                      i_account_id      => a.id
                    , i_split_hash      => a.split_hash
                    , i_serial_number   => cin.serial_number
                    , i_month_period    => 12
                  ) delinquency_str
                , cst_cfc_com_pkg.get_overdue_fee(
                      i_account_id      => a.id
                    , i_split_hash      => a.split_hash
                  ) ovderdue_fee
                , cst_cfc_com_pkg.get_balance_amount(
                       i_account_id     => a.id
                     , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST --'BLTP1005'
                  ) overdue_interest
                , cst_cfc_com_pkg.get_latest_tran_amt(
                      i_account_id      => a.id
                    , i_split_hash      => a.split_hash
                  ) latest_tran_amt
                , to_char(cst_cfc_com_pkg.get_cycle_date(
                              i_account_id  => a.id
                            , i_cycle_type  => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE --'CYTP1001'
                  ), 'DD') bill_date_1
                , cst_cfc_com_pkg.get_latest_change_status_dt(
                      i_event_type_tab  => com_dict_tpt('EVNT0160' -- Change card status
                                                       ,'EVNT0141' -- Card personalization
                                                       ,'EVNT0120' -- Card instance creation
                                                       ,'EVNT0162' -- Permanent card blocking
                                                       )
                    , i_object_id       => i.id
                  ) c_latest_hot_status_date
                , a.status
                , '' reserved_field_1
                , cst_cfc_com_pkg.get_balance_amount(
                      i_account_id      => a.id
                    , i_balance_type    => crd_api_const_pkg.BALANCE_TYPE_LENDING --'BLTP1015'
                  ) lending_amt
                , cst_cfc_com_pkg.get_revised_bucket_attr(
                      i_customer_id     => cu.id
                    , i_account_id      => a.id
                    , i_attr            => 'revised_bucket'
                  ) revised_bucket
                , coalesce(crd_invoice_pkg.get_converted_aging_period(i_aging_period => greatest(cin.aging_period -1, 0)), 'N/A') pre_bucket
                , cst_cfc_com_pkg.get_balance_amount(
                      i_account_id      => a.id
                    , i_balance_type    => crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST --'BLTP1005'
                  ) overdue_interest_2
                , crd_invoice_pkg.round_up_mad(
                      i_account_id      => a.id
                    , i_mad             => cin.min_amount_due
                    , i_tad             => cin.total_amount_due
                    , i_product_id      => c.product_id
                  ) as mad2
                , '' reserved_field_2
                , (cst_cfc_com_pkg.get_balance_amount(
                       i_account_id     => a.id
                     , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_INTEREST)  --'BLTP1003'
                   +
                   cst_cfc_com_pkg.get_balance_amount(
                       i_account_id     => a.id
                     , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST) --'BLTP1005'
                  ) total_interest
                , cin.due_date
                , cst_cfc_com_pkg.get_latest_change_status_dt(
                      i_event_type_tab  => com_dict_tpt('EVNT0160' -- Change card status
                                                       ,'EVNT0192' -- Change card status due to lost
                                                       ,'EVNT5009' -- Change card status due to lost without card
                                                       ,'EVNT0193' -- Change card status due to stolen
                                                       ,'EVNT0201' -- Change card status due to damage
                                                       )
                    , i_object_id       => i.id
                  ) c_latest_status_date
                , cst_cfc_com_pkg.get_principal_amount(
                      i_account_id     => a.id
                  ) principal_amt
                , com_api_flexible_data_pkg.get_flexible_value(
                      i_field_name     => cst_cfc_api_const_pkg.FLEX_NET_SALARY
                    , i_entity_type    => com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
                    , i_object_id      => cu.id
                  ) net_salary
                , com_api_flexible_data_pkg.get_flexible_value( 
                      i_field_name    => cst_cfc_api_const_pkg.FLEX_IS_MAD_PAID
                    , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                    , i_object_id     => a.id
                  ) reserved_field_3 
                , com_api_i18n_pkg.get_text('NET_CARD_TYPE','NAME', ic.card_type_id, g_lang) card_type
                , cst_cfc_com_pkg.get_tran_fee(
                      i_account_id => a.id
                    , i_split_hash => a.split_hash
                  ) total_fee
                , '' reserved_field_4
                , '' reserved_field_5
                , null blank_field
                , cst_cfc_com_pkg.get_latest_change_status_dt(
                      i_event_type_tab  => com_dict_tpt('EVNT0310')
                    , i_object_id       => i.id
                  ) c_latest_bucket_date
                , com_api_flexible_data_pkg.get_flexible_value(
                      i_field_name  => cst_cfc_api_const_pkg.FLEX_EMPLOYED_DEPARTMENT
                    , i_entity_type => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                    , i_object_id   => cu.id
                  ) department
                , com_api_flexible_data_pkg.get_flexible_value(
                      i_field_name  => cst_cfc_api_const_pkg.FLEX_CARD_SCHEME_NAME
                    , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                    , i_object_id   => ic.id
                  ) scheme_name
                , com_api_flexible_data_pkg.get_flexible_value(
                     i_field_name   => cst_cfc_api_const_pkg.FLEX_CLIENT_TARIFF
                   , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
                   , i_object_id    => ic.id
                  ) client_tariff
                , ic.card_mask
                , substr(ic.card_mask, -4) card_number
             from acc_account           a
                , acc_account_object    ao
                , prd_customer          cu
                , prd_contract          c
                , iss_card_instance     i
                , crd_invoice           cin
                , iss_card              ic
            where a.customer_id     = cu.id
              and a.contract_id     = c.id
              and a.id              = ao.account_id
              and a.id              = cin.account_id(+)
              and ao.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
              and ao.object_id      = i.card_id
              and ic.id             = i.card_id
              and cu.inst_id        = nvl(i_inst_id, cu.inst_id)
              and (cin.id           = crd_invoice_pkg.get_last_invoice_id(
                                          i_account_id    => a.id
                                        , i_split_hash    => a.split_hash
                                        , i_mask_error    => com_api_type_pkg.TRUE
                                      )
                  or cin.id is null)
              and a.split_hash in (select split_hash from com_api_split_map_vw)
              and a.id in ((select column_value from table(cast(io_account_id_tab as num_tab_tpt))))
         )
    ;
end get_account_data;

procedure get_payment_data(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , l_payment_id_tab        in  out nocopy num_tab_tpt
  , o_ref_cursor            out sys_refcursor
)
is
begin
    open o_ref_cursor for
    select 'PAYD' tag
         , 3 tag_order
         , customer_number
         , customer_number      || DELIMETER ||
           account_number       || DELIMETER ||
           to_char(invoice_date, DATE_FORMAT)|| DELIMETER ||
           to_char(due_date, DATE_FORMAT)    || DELIMETER ||
           total_amount_due     || DELIMETER ||
           amount               || DELIMETER ||
           paidordue            || DELIMETER ||
           payment_desc         || DELIMETER ||
           charge_code          || DELIMETER ||
           oper_id              || DELIMETER ||
           payment_mode         || DELIMETER ||
           to_char(posting_date, DATE_FORMAT)|| DELIMETER ||
           amount_1             || DELIMETER ||
           status               || DELIMETER ||
           ref_num              || DELIMETER ||
           payment_type         || DELIMETER ||
           total_payment        || DELIMETER ||
           to_char(posting_date_1, DATE_FORMAT) || DELIMETER ||
           to_char(posting_date_2, DATE_FORMAT) || DELIMETER ||
           charge_desc data_content
     from(
           select c.customer_number
                , a.account_number
                , i.invoice_date
                , i.due_date
                , i.total_amount_due
                , p.amount
                , case
                      when p.amount > i.total_amount_due then 'P'
                      else 'D'
                  end paidOrDue
                , '' payment_desc
                , 9 charge_code
                , o.originator_refnum oper_id
                , 'CASH' payment_mode
                , p.posting_date
                , p.amount amount_1
                , 'R' status
                , o.originator_refnum ref_num
                , 'R' payment_type
                , cst_cfc_com_pkg.get_total_payment(
                      i_account_id  => a.id
                  ) total_payment
                , p.posting_date posting_date_1
                , p.posting_date posting_date_2
                , 'Statemented Balance' charge_desc
             from prd_customer  c
                , acc_account   a
                , crd_invoice   i
                , crd_payment   p
                , opr_operation o
            where c.id  = a.customer_id
              and (i.id = crd_invoice_pkg.get_last_invoice_id(
                              i_account_id   => a.id
                            , i_split_hash   => a.split_hash
                            , i_mask_error   => com_api_type_pkg.TRUE
                          )
                   or
                   i.id is null
                  )
              and p.account_id = a.id
              and p.oper_id    = o.id
              and c.inst_id    = nvl(i_inst_id, c.inst_id)
              and p.id in ((select column_value from table(cast(l_payment_id_tab as num_tab_tpt))))
         );
end get_payment_data;

procedure get_address_data(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , io_customer_id_tab      in  out nocopy num_tab_tpt
  , o_ref_cursor            out sys_refcursor
)
is
begin
    open o_ref_cursor for
    select 'ADDR' tag
         , 4 tag_order
         , customer_number
         , customer_number  || DELIMETER ||
           account_number   || DELIMETER ||
           address_type     || DELIMETER ||
           street           || DELIMETER ||
           address_line2    || DELIMETER ||
           country_name     || DELIMETER ||
           region_code      || DELIMETER ||
           city             || DELIMETER ||
           postal_code      || DELIMETER ||
           landline_phone   || DELIMETER ||
           mobile_phone     || DELIMETER ||
           is_primary data_content
     from(
           select cu.customer_number
                , ac.account_number
                , com_api_dictionary_pkg.get_article_text(o.address_type, a.lang) address_type
                , a.street
                , a.apartment || nvl2(a.house, ' '||a.house, '') as address_line2
                , b.name country_name
                , a.region_code
                , a.city
                , a.postal_code
                , com_api_contact_pkg.get_contact_string(
                      i_contact_id     => c.contact_id
                    , i_commun_method  => com_api_const_pkg.COMMUNICATION_METHOD_PHONE --'CMNM0012'
                    , i_start_date     => get_sysdate()
                  ) landline_phone
                , com_api_contact_pkg.get_contact_string(
                      i_contact_id     => c.contact_id
                    , i_commun_method  => com_api_const_pkg.COMMUNICATION_METHOD_MOBILE --'CMNM0001'
                    , i_start_date     => get_sysdate()
                  ) mobile_phone
                , decode(o.address_type, com_api_const_pkg.ADDRESS_TYPE_HOME, 1, 0) is_primary --'ADTPHOME'
             from com_address a
                , com_country b
                , com_address_object o
                , acc_account ac
                , prd_customer cu
                , com_contact_object c
            where o.entity_type    = com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
              and a.id             = o.address_id
              and a.country        = b.code(+)
              and cu.id            = o.object_id
              and cu.id            = ac.customer_id
              and c.entity_type(+) = com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
              and c.object_id(+)   = o.object_id
              and c.contact_type(+)= com_api_const_pkg.CONTACT_TYPE_PRIMARY --'CNTTPRMC'
              and cu.inst_id       = nvl(i_inst_id, cu.inst_id)
              and cu.split_hash in (select split_hash from com_api_split_map_vw)
              and cu.id in ((select column_value from table(cast(io_customer_id_tab as num_tab_tpt))))
         );
end get_address_data;

procedure get_reference_data(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , io_customer_id_tab      in  out nocopy num_tab_tpt
  , o_ref_cursor            out sys_refcursor
)
is
begin
    open o_ref_cursor for
    select 'REFD' tag
         , 5 tag_order
         , customer_number
         , account_number   || DELIMETER ||
           customer_number  || DELIMETER ||
           ref_name         || DELIMETER ||
           ref_relation     || DELIMETER ||
           ref_address      || DELIMETER ||
           ref_email        || DELIMETER ||
           ref_phone        || DELIMETER ||
           ref_landline  as data_content
     from(
           select a.account_number
                , c.customer_number
                , com_api_flexible_data_pkg.get_flexible_value(
                      i_field_name     => cst_cfc_api_const_pkg.FLEX_REFERENCE_NAME
                    , i_entity_type    => com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
                    , i_object_id      => c.id
                  ) ref_name
                , com_api_dictionary_pkg.get_article_text(
                      i_article        => com_api_flexible_data_pkg.get_flexible_value(
                      i_field_name     => cst_cfc_api_const_pkg.FLEX_REFERENCE_RELATION
                    , i_entity_type    => com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
                    , i_object_id      => c.id
                                          )
                    , i_lang           => g_lang
                  ) ref_relation
                , com_api_flexible_data_pkg.get_flexible_value(
                      i_field_name     => cst_cfc_api_const_pkg.FLEX_REFERENCE_ADDRESS
                    , i_entity_type    => com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
                    , i_object_id      => c.id
                  ) ref_address
                , '' ref_email
                , com_api_flexible_data_pkg.get_flexible_value(
                      i_field_name     => cst_cfc_api_const_pkg.FLEX_REFERENCE_PHONE
                    , i_entity_type    => com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
                    , i_object_id      => c.id
                  ) ref_phone
                , '' ref_landline
             from prd_customer c
                , acc_account a
            where c.id         = a.customer_id
              and c.inst_id    = nvl(i_inst_id, c.inst_id)
              and c.id in ((select column_value from table(cast(io_customer_id_tab as num_tab_tpt))))
              and c.split_hash in (select split_hash from com_api_split_map_vw)
         );
end get_reference_data;

procedure mark_unprocess_event(
    i_procedure_name        in com_api_type_pkg.t_name
)
is
    l_event_id_tab          com_api_type_pkg.t_number_tab;

    cursor cur_unprocess_event_objects is
    select o.id as event_object_id
      from evt_event_object o
         , evt_event e
         , evt_subscriber s
     where decode(o.status, 'EVST0001', o.procedure_name, null) = i_procedure_name
       and o.eff_date       <= get_sysdate()
       and e.id             = o.event_id
       and e.event_type     = s.event_type
       and o.procedure_name = s.procedure_name;
begin
    open cur_unprocess_event_objects;
    loop
        fetch cur_unprocess_event_objects bulk collect into
            l_event_id_tab
        limit BULK_LIMIT;

        cst_cfc_com_pkg.change_event_status(
            i_event_object_id_tab   => l_event_id_tab
          , i_event_status          => evt_api_const_pkg.EVENT_STATUS_DO_NOT_PROCES
        );
        exit when cur_unprocess_event_objects%notfound;
    end loop;
    close cur_unprocess_event_objects;
end mark_unprocess_event;

procedure process(
    i_inst_id                   in  com_api_type_pkg.t_inst_id
  , i_agent_id                  in  com_api_type_pkg.t_agent_id
  , i_lang                      in  com_api_type_pkg.t_dict_value
  , i_cust_evt_type_array_id    in  com_api_type_pkg.t_short_id
  , i_cacc_evt_type_array_id    in  com_api_type_pkg.t_short_id
  , i_payd_evt_type_array_id    in  com_api_type_pkg.t_short_id
  , i_addr_evt_type_array_id    in  com_api_type_pkg.t_short_id
  , i_refd_evt_type_array_id    in  com_api_type_pkg.t_short_id
)is
    BULK_LIMIT                  constant simple_integer := 1000;
    PROC_NAME                   constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.PROCESS';
    LOG_PREFIX                  constant com_api_type_pkg.t_name := lower(PROC_NAME) || ': ';
    l_ref_cursor                com_api_type_pkg.t_ref_cur;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_data;
    l_lang                      com_api_type_pkg.t_dict_value;
    l_estimated_count           pls_integer := 0;
    l_count                     pls_integer := 0;

    l_customer_id_tab           num_tab_tpt;
    l_account_id_tab            num_tab_tpt;
    l_payment_id_tab            num_tab_tpt;

    l_cust_event_id_tab         num_tab_tpt;
    l_cacc_event_id_tab         num_tab_tpt;
    l_payd_event_id_tab         num_tab_tpt;
    l_addr_event_id_tab         num_tab_tpt;
    l_refd_event_id_tab         num_tab_tpt;

    l_data_ref                  sys_refcursor;
    l_col_tab                   cst_cfc_api_type_pkg.t_col_tab;

    --Get customer event
    cursor cur_cust_event_objects is
    select o.id as event_object_id
         , c.id as customer_id
      from evt_event_object o
         , evt_event e
         , evt_subscriber s
         , prd_customer c
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_CFC_API_COLLECTION_PKG.PROCESS'
       and o.eff_date       <= get_sysdate()
       and e.id             = o.event_id
       and e.event_type     = s.event_type
       and o.procedure_name = s.procedure_name
       and o.object_id      = c.id
       and o.entity_type    = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
       and (c.inst_id       = i_inst_id or i_inst_id is null)
       and com_api_array_pkg.is_element_in_array(
               i_array_id       => i_cust_evt_type_array_id
             , i_elem_value     => e.event_type
           ) = com_api_const_pkg.TRUE
       /* Client request to temporary uncheck this attribute
       and prd_api_product_pkg.get_attr_value_char(
               i_entity_type    => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
             , i_object_id      => c.id
             , i_attr_name      => cst_cfc_api_const_pkg.ENABLE_COLLECTION
             , i_mask_error     => com_api_type_pkg.TRUE
           ) = cst_cfc_api_const_pkg.YES
       */
     order by o.id;

    --Get card/account event
    cursor cur_cacc_event_objects is
    select o.id             as event_object_id
         , a.id             as account_id
      from evt_event_object o
         , evt_event e
         , evt_subscriber s
         , acc_account a
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_CFC_API_COLLECTION_PKG.PROCESS'
       and o.eff_date       <= get_sysdate()
       and e.id             = o.event_id
       and e.event_type     = s.event_type
       and o.procedure_name = s.procedure_name
       and o.object_id      = a.id
       and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
       and (a.inst_id       = i_inst_id or i_inst_id is null)
       and com_api_array_pkg.is_element_in_array(
               i_array_id   => i_cacc_evt_type_array_id
             , i_elem_value => e.event_type
           ) = com_api_const_pkg.TRUE
       /* Client request to temporary uncheck this attribute
       and prd_api_product_pkg.get_attr_value_char(
               i_entity_type    => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
             , i_object_id      => a.customer_id
             , i_attr_name      => cst_cfc_api_const_pkg.ENABLE_COLLECTION
             , i_mask_error     => com_api_type_pkg.TRUE
           ) = cst_cfc_api_const_pkg.YES
       */
     order by o.id;

    --Get payment event
    cursor cur_payd_event_objects is
    select o.id             as event_object_id
         , p.id             as payment_id
      from evt_event_object o
         , evt_event        e
         , evt_subscriber   s
         , crd_payment      p
         , acc_account      a
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_CFC_API_COLLECTION_PKG.PROCESS'
       and o.eff_date       <= get_sysdate()
       and e.id             = o.event_id
       and e.event_type     = s.event_type
       and o.procedure_name = s.procedure_name
       and o.object_id      = p.oper_id
       and p.account_id     = a.id
       and o.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION --'ENTTOPER'
       and (a.inst_id       = i_inst_id or i_inst_id is null)
       and com_api_array_pkg.is_element_in_array(
               i_array_id   => i_payd_evt_type_array_id
             , i_elem_value => e.event_type
           ) = com_api_const_pkg.TRUE
       /* Client request to temporary uncheck this attribute
       and prd_api_product_pkg.get_attr_value_char(
               i_entity_type    => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
             , i_object_id      => a.customer_id
             , i_attr_name      => cst_cfc_api_const_pkg.ENABLE_COLLECTION
             , i_mask_error     => com_api_type_pkg.TRUE
            ) = cst_cfc_api_const_pkg.YES
       */
     order by o.id;

    --Get address event
    cursor cur_addr_event_objects is
    select o.id             as event_object_id
         , c.id             as customer_id
      from evt_event_object o
         , evt_event e
         , evt_subscriber s
         , prd_customer c
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_CFC_API_COLLECTION_PKG.PROCESS'
       and o.eff_date       <= get_sysdate()
       and e.id             = o.event_id
       and e.event_type     = s.event_type
       and o.procedure_name = s.procedure_name
       and o.object_id      = c.id
       and o.entity_type    = com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
       and (c.inst_id       = i_inst_id or i_inst_id is null)
       and com_api_array_pkg.is_element_in_array(
                   i_array_id       => i_addr_evt_type_array_id
                 , i_elem_value     => e.event_type
               ) = com_api_const_pkg.TRUE
       /* Client request to temporary uncheck this attribute
       and prd_api_product_pkg.get_attr_value_char(
               i_entity_type    => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
             , i_object_id      => c.id
             , i_attr_name      => cst_cfc_api_const_pkg.ENABLE_COLLECTION
             , i_mask_error     => com_api_type_pkg.TRUE
           ) = cst_cfc_api_const_pkg.YES
       */
     order by o.id;

    --Get reference event
    cursor cur_refd_event_objects is
    select o.id             as event_object_id
         , c.id             as customer_id
      from evt_event_object o
         , evt_event e
         , evt_subscriber s
         , prd_customer c
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_CFC_API_COLLECTION_PKG.PROCESS'
       and o.eff_date       <= get_sysdate()
       and e.id             = o.event_id
       and e.event_type     = s.event_type
       and o.procedure_name = s.procedure_name
       and o.object_id      = c.id
       and o.entity_type    = com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
       and (c.inst_id       = i_inst_id or i_inst_id is null)
       and com_api_array_pkg.is_element_in_array(
                   i_array_id   => i_refd_evt_type_array_id
                 , i_elem_value => e.event_type
               ) = com_api_const_pkg.TRUE
       /* Client request to temporary uncheck this attribute
       and prd_api_product_pkg.get_attr_value_char(
               i_entity_type    => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
             , i_object_id      => c.id
             , i_attr_name      => cst_cfc_api_const_pkg.ENABLE_COLLECTION
             , i_mask_error     => com_api_type_pkg.TRUE
           ) = cst_cfc_api_const_pkg.YES
       */
     order by o.id;
begin
    savepoint sp_unload_collection_data;

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - inst_id [#1] agent_id [#2]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_agent_id
    );

    g_lang := coalesce(i_lang, get_user_lang, com_api_const_pkg.LANGUAGE_ENGLISH);
    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    prc_api_file_pkg.put_line(
        i_sess_file_id => l_session_file_id
      , i_raw_data     => COLLECTION_DETAIL_FILE_HEADER
    );

    --customer part
    begin
        savepoint sp_process_customer_info;
        open cur_cust_event_objects;
        loop
            fetch cur_cust_event_objects bulk collect into
                l_cust_event_id_tab
              , l_customer_id_tab
            limit BULK_LIMIT;

            if l_customer_id_tab.count > 0 then
                get_customer_data(
                    i_inst_id           => i_inst_id
                  , io_customer_id_tab  => l_customer_id_tab
                  , o_ref_cursor        => l_data_ref
                );
               loop
                    fetch l_data_ref bulk collect into l_col_tab limit BULK_LIMIT;
                    forall i in 1..l_col_tab.count
                        insert into cst_collection_tmp values l_col_tab(i);
                    exit when l_data_ref%notfound;
                end loop;
                close l_data_ref;
            end if;
            exit when cur_cust_event_objects%notfound;
        end loop;
        close cur_cust_event_objects;
    exception
        when com_api_error_pkg.e_application_error then
            rollback to sp_process_customer_info;
            close cur_cust_event_objects;
        when others then
            trc_log_pkg.debug('Error when getting collection customer info');
            rollback to sp_process_customer_info;
            close cur_cust_event_objects;
            raise;
    end;

    -- account part
    begin
        savepoint sp_process_account_info;
        open cur_cacc_event_objects;
            loop
            fetch cur_cacc_event_objects bulk collect into
                l_cacc_event_id_tab
              , l_account_id_tab
            limit BULK_LIMIT;

            if l_account_id_tab.count > 0 then
                get_account_data(
                    i_inst_id           => i_inst_id
                  , io_account_id_tab   => l_account_id_tab
                  , o_ref_cursor        => l_data_ref
                );
                loop
                    fetch l_data_ref bulk collect into l_col_tab limit BULK_LIMIT;
                    forall i in 1..l_col_tab.count
                        insert into cst_collection_tmp values l_col_tab(i);
                     exit when l_data_ref%notfound;
                end loop;
                close l_data_ref;
            end if;

            exit when cur_cacc_event_objects%notfound;
        end loop;
        close cur_cacc_event_objects;
    exception
        when com_api_error_pkg.e_application_error then
            rollback to sp_process_account_info;
            close cur_cacc_event_objects;
        when others then
            trc_log_pkg.debug('Error when getting collection card account info');
            rollback to sp_process_account_info;
            close cur_cacc_event_objects;
            raise;
    end;

    -- payment part
    begin
        savepoint sp_process_payment_info;
        open cur_payd_event_objects;
            loop
            fetch cur_payd_event_objects bulk collect into
                l_payd_event_id_tab
              , l_payment_id_tab
            limit BULK_LIMIT;

            if l_payment_id_tab.count > 0 then
                get_payment_data(
                    i_inst_id           => i_inst_id
                  , l_payment_id_tab    => l_payment_id_tab
                  , o_ref_cursor        => l_data_ref
                );
                loop
                    fetch l_data_ref bulk collect into l_col_tab limit BULK_LIMIT;
                    forall i in 1..l_col_tab.count
                        insert into cst_collection_tmp values l_col_tab(i);
                     exit when l_data_ref%notfound;
                end loop;
                close l_data_ref;
            end if;

            exit when cur_payd_event_objects%notfound;
        end loop;
        close cur_payd_event_objects;
    exception
        when com_api_error_pkg.e_application_error then
            rollback to sp_process_payment_info;
            close cur_payd_event_objects;
        when others then
            trc_log_pkg.debug('Error when getting collection payment info');
            rollback to sp_process_payment_info;
            close cur_payd_event_objects;
            raise;
    end;
    -- address part
    begin
        savepoint sp_process_address_info;
        open cur_addr_event_objects;
            loop
            fetch cur_addr_event_objects bulk collect into
                l_addr_event_id_tab
              , l_customer_id_tab
            limit BULK_LIMIT;

            if l_customer_id_tab.count > 0 then

                get_address_data(
                    i_inst_id           => i_inst_id
                  , io_customer_id_tab  => l_customer_id_tab
                  , o_ref_cursor        => l_data_ref
                );
                loop
                    fetch l_data_ref bulk collect into l_col_tab limit BULK_LIMIT;
                    forall i in 1..l_col_tab.count
                        insert into cst_collection_tmp values l_col_tab(i);
                     exit when l_data_ref%notfound;
                end loop;
                close l_data_ref;
            end if;

            exit when cur_addr_event_objects%notfound;
        end loop;
        close cur_addr_event_objects;
    exception
        when com_api_error_pkg.e_application_error then
            rollback to sp_process_address_info;
            close cur_addr_event_objects;
        when others then
            trc_log_pkg.debug('Error when getting collection address info');
            rollback to sp_process_address_info;
            close cur_addr_event_objects;
            raise;
    end;

    -- reference part
    begin
        savepoint sp_process_reference_info;
        open cur_refd_event_objects;
            loop
            fetch cur_refd_event_objects bulk collect into
                l_refd_event_id_tab
              , l_customer_id_tab
            limit BULK_LIMIT;

            if l_customer_id_tab.count > 0 then
                get_reference_data(
                    i_inst_id           => i_inst_id
                  , io_customer_id_tab  => l_customer_id_tab
                  , o_ref_cursor        => l_data_ref
                );
                loop
                    fetch l_data_ref bulk collect into l_col_tab limit BULK_LIMIT;
                    forall i in 1..l_col_tab.count
                        insert into cst_collection_tmp values l_col_tab(i);
                     exit when l_data_ref%notfound;
                end loop;
                close l_data_ref;
            end if;

            exit when cur_refd_event_objects%notfound;
        end loop;
        close cur_refd_event_objects;
    exception
        when com_api_error_pkg.e_application_error then
            rollback to sp_process_reference_info;
            close cur_refd_event_objects;
        when others then
            trc_log_pkg.debug('Error when getting collection reference info');
            rollback to sp_process_reference_info;
            close cur_refd_event_objects;
            raise;
    end;

    for rec in (
        select tag
             , customer_number
             , data_content
         from cst_collection_tmp
        order by customer_number, tag_order
    ) loop
         l_record := rec.tag    || DELIMETER ||
                     rec.data_content;

         prc_api_file_pkg.put_line(
             i_raw_data      => l_record
           , i_sess_file_id  => l_session_file_id
            );
    end loop;

    prc_api_file_pkg.close_file(
        i_sess_file_id        => l_session_file_id
      , i_status              => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('Finish unloading the collection data');
    -- Mark process event
    evt_api_event_pkg.process_event_object(l_cust_event_id_tab);
    evt_api_event_pkg.process_event_object(l_cacc_event_id_tab);
    evt_api_event_pkg.process_event_object(l_payd_event_id_tab);
    evt_api_event_pkg.process_event_object(l_addr_event_id_tab);
    evt_api_event_pkg.process_event_object(l_refd_event_id_tab);
    -- Mark do not process event
    mark_unprocess_event(
        i_procedure_name    => 'CST_CFC_API_COLLECTION_PKG.PROCESS'
    );
exception
    when others then
        rollback to sp_unload_collection_data;
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end process;
end cst_cfc_api_collection_pkg;
/
