create or replace package cst_woo_api_type_pkg as

    type t_tc_buffer   is table of com_api_type_pkg.t_text index by binary_integer;

    type t_file_rec is record (
        header                      com_api_type_pkg.t_dict_value
        , job_id                    com_api_type_pkg.t_dict_value
        , process_date              com_api_type_pkg.t_date_short
        , sequence_id               com_api_type_pkg.t_seqnum
        , total_amount              com_api_type_pkg.t_long_id
        , total_record              com_api_type_pkg.t_medium_id
    );

    type t_mes_rec_59 is record (
        seq_id                      com_api_type_pkg.t_uuid
        , recov_date                com_api_type_pkg.t_date_short
        , recov_branch_code         com_api_type_pkg.t_dict_value
        , cus_branch_code           com_api_type_pkg.t_dict_value
        , global_id                 com_api_type_pkg.t_text
        , cif_no                    com_api_type_pkg.t_cmid
        , crd_acc_num               com_api_type_pkg.t_account_number
        , card_num                  com_api_type_pkg.t_card_number
        , acc_num                   com_api_type_pkg.t_account_number
        , request_amount            com_api_type_pkg.t_money
        , total_amount              com_api_type_pkg.t_money
        , err_code                  com_api_type_pkg.t_dict_value
        , err_content               com_api_type_pkg.t_text
    );

    type t_mes_rec_65 is record (
        seq_id                      com_api_type_pkg.t_uuid
        , job_date                  com_api_type_pkg.t_date_short
        , cif_num                   com_api_type_pkg.t_cmid
        , branch_code               com_api_type_pkg.t_dict_value
        , w_bank_code               com_api_type_pkg.t_dict_value
        , w_acct_num                com_api_type_pkg.t_account_number
        , d_bank_code               com_api_type_pkg.t_dict_value
        , d_acct_num                com_api_type_pkg.t_account_number
        , d_currency                com_api_type_pkg.t_curr_code
        , d_amount                  com_api_type_pkg.t_auth_amount
        , b_content                 com_api_type_pkg.t_text
        , work_type                 com_api_type_pkg.t_dict_value
        , err_code                  com_api_type_pkg.t_dict_value
        , sv_acct_num               com_api_type_pkg.t_account_number
    );

    type t_mes_rec_67 is record (
        seq_id                      com_api_type_pkg.t_uuid
        , bank_code                 com_api_type_pkg.t_dict_value
        , notice_date               com_api_type_pkg.t_date_short
        , notice_seq                com_api_type_pkg.t_dict_value
        , from_curr                 com_api_type_pkg.t_curr_code
        , to_curr                   com_api_type_pkg.t_curr_code
        , class_code                com_api_type_pkg.t_curr_code
        , branch_code               com_api_type_pkg.t_dict_value
        , exchange_rate             com_api_type_pkg.t_money
        , f_exchange_rate           com_api_type_pkg.t_money
        , notice_time               com_api_type_pkg.t_date_short
        , status_code               com_api_type_pkg.t_dict_value
    );

    type t_mes_rec_70 is record (
        seq_id                      com_api_type_pkg.t_uuid
        , bank_code                 com_api_type_pkg.t_dict_value
        , staff_num                 com_api_type_pkg.t_cmid
        , staff_name                com_api_type_pkg.t_name
        , branch_code               com_api_type_pkg.t_dict_value
        , r_branch_code             com_api_type_pkg.t_dict_value
        , gender                    com_api_type_pkg.t_dict_value
        , eng_name                  com_api_type_pkg.t_name
        , chn_name                  com_api_type_pkg.t_name
        , cus_number                com_api_type_pkg.t_cmid
        , cus_iden_code             com_api_type_pkg.t_dict_value
        , cus_iden_num              com_api_type_pkg.t_name
        , item_value_1              com_api_type_pkg.t_dict_value
        , rank_level                com_api_type_pkg.t_dict_value
        , salary_level              com_api_type_pkg.t_dict_value
        , first_bank_date           com_api_type_pkg.t_date_short
        , move_depart_date          com_api_type_pkg.t_date_short
        , attend_depart_date        com_api_type_pkg.t_date_short
        , promote_date              com_api_type_pkg.t_date_short
        , nexn_promote_date         com_api_type_pkg.t_date_short
        , position_code             com_api_type_pkg.t_dict_value
        , devision_code             com_api_type_pkg.t_dict_value
        , birth_date                com_api_type_pkg.t_date_short
        , sal_acc_num               com_api_type_pkg.t_account_number
        , is_married                com_api_type_pkg.t_dict_value
        , wed_anniver_date          com_api_type_pkg.t_date_short
        , phone_num                 com_api_type_pkg.t_name
        , address                   com_api_type_pkg.t_text
        , cell_phone_num            com_api_type_pkg.t_name
        , emer_contact_num          com_api_type_pkg.t_name
        , security_num              com_api_type_pkg.t_name
        , email                     com_api_type_pkg.t_name
        , internal_phone_num        com_api_type_pkg.t_name
        , is_retired                com_api_type_pkg.t_dict_value
        , retire_code               com_api_type_pkg.t_dict_value
        , retire_date               com_api_type_pkg.t_date_short
        , retire_reason             com_api_type_pkg.t_text
        , before_branch             com_api_type_pkg.t_dict_value
        , item_value_2              com_api_type_pkg.t_name
        , item_value_3              com_api_type_pkg.t_name
        , item_value_4              com_api_type_pkg.t_dict_value
    );

    type t_mes_rec_73 is record (
        seq_id                      com_api_type_pkg.t_uuid
        , file_date                 com_api_type_pkg.t_date_short
        , cif_no                    com_api_type_pkg.t_cmid
        , branch_code               com_api_type_pkg.t_dict_value
        , w_acc_bank_code           com_api_type_pkg.t_dict_value
        , w_acc_num                 com_api_type_pkg.t_account_number
        , d_acc_bank_code           com_api_type_pkg.t_dict_value
        , d_acc_num                 com_api_type_pkg.t_account_number
        , d_currency                com_api_type_pkg.t_dict_value
        , d_amount                  com_api_type_pkg.t_money
        , brief_content             com_api_type_pkg.t_text
        , work_type                 com_api_type_pkg.t_dict_value
        , err_code                  com_api_type_pkg.t_dict_value
        , sv_acct_num               com_api_type_pkg.t_account_number
    );

    type t_mes_rec_77 is record (
        seq_id                      com_api_type_pkg.t_uuid
        , bank_code                 com_api_type_pkg.t_dict_value
        , cif_no                    com_api_type_pkg.t_cmid
        , cus_eng_name              com_api_type_pkg.t_name
        , first_name                com_api_type_pkg.t_name
        , second_name               com_api_type_pkg.t_name
        , surname                   com_api_type_pkg.t_name
        , cus_local_name            com_api_type_pkg.t_name
        , nationality               com_api_type_pkg.t_dict_value
        , id_type                   com_api_type_pkg.t_dict_value
        , id_num                    com_api_type_pkg.t_name
        , birth_date                com_api_type_pkg.t_date_short
        , gender                    com_api_type_pkg.t_dict_value
        , residence_type            com_api_type_pkg.t_dict_value
        , job_code                  com_api_type_pkg.t_dict_value
        , country_code              com_api_type_pkg.t_dict_value
        , region                    com_api_type_pkg.t_name
        , city                      com_api_type_pkg.t_name
        , street                    com_api_type_pkg.t_name
        , home_phone                com_api_type_pkg.t_name
        , mobile_phone              com_api_type_pkg.t_name
        , email                     com_api_type_pkg.t_name
        , fax_num                   com_api_type_pkg.t_name
        , company_name              com_api_type_pkg.t_name
        , job_class_code            com_api_type_pkg.t_dict_value
        , pos_class_code            com_api_type_pkg.t_dict_value
        , company_phone             com_api_type_pkg.t_name
        , company_addr_country      com_api_type_pkg.t_name
        , company_addr_region       com_api_type_pkg.t_name
        , company_addr_city         com_api_type_pkg.t_name
        , company_addr_street       com_api_type_pkg.t_name
        , cus_rate_code             com_api_type_pkg.t_dict_value
        , employee_num              com_api_type_pkg.t_cmid
        , retirement_code           com_api_type_pkg.t_dict_value
        , retirement_date           com_api_type_pkg.t_date_short
    );

    type t_mes_rec_78 is record (
        seq_id                      com_api_type_pkg.t_uuid
        , approved_date             com_api_type_pkg.t_date_short
        , tele_mess_num             com_api_type_pkg.t_dict_value
        , trans_num                 com_api_type_pkg.t_uuid
        , card_num                  com_api_type_pkg.t_card_number
        , card_revenue_type         com_api_type_pkg.t_dict_value
        , approved_amt              com_api_type_pkg.t_money
        , cash_id_code              com_api_type_pkg.t_dict_value
        , card_approved_code        com_api_type_pkg.t_dict_value
        , approved_time             com_api_type_pkg.t_date_short
        , terminal_id               com_api_type_pkg.t_terminal_number
        , terminal_agent_id         com_api_type_pkg.t_dict_value
        , response_code             com_api_type_pkg.t_dict_value
    );

    type t_mes_rec_79 is record (
        seq_id                      com_api_type_pkg.t_uuid
        , bank_code                 com_api_type_pkg.t_dict_value
        , cif_no                    com_api_type_pkg.t_cmid
        , accident_code             com_api_type_pkg.t_dict_value
        , cus_accident_num          com_api_type_pkg.t_attr_name
        , start_date                com_api_type_pkg.t_date_short
        , end_date                  com_api_type_pkg.t_date_short
        , free_date                 com_api_type_pkg.t_date_short
        , employee_num              com_api_type_pkg.t_attr_name
        , release_branch_code       com_api_type_pkg.t_dict_value
        , restrict_branch_code      com_api_type_pkg.t_dict_value
        , reg_branch_code           com_api_type_pkg.t_dict_value
        , reg_employee_num          com_api_type_pkg.t_attr_name
        , reg_content               com_api_type_pkg.t_text
        , is_valid                  com_api_type_pkg.t_dict_value
        , status_code               com_api_type_pkg.t_dict_value
    );

    type t_mes_rec_127 is record (
        seq_id                      com_api_type_pkg.t_uuid
        , job_date                  com_api_type_pkg.t_date_short
        , card_num                  com_api_type_pkg.t_card_number
        , delivery_status           com_api_type_pkg.t_dict_value
    );

    type t_mes_rec_128 is record (
        seq_id                      com_api_type_pkg.t_uuid
        , job_date                  com_api_type_pkg.t_date_short
        , card_num                  com_api_type_pkg.t_card_number
        , delivery_status           com_api_type_pkg.t_dict_value
        , delivery_type             com_api_type_pkg.t_dict_value
    );

    type t_mes_rec_129 is record (
        seq_id                      com_api_type_pkg.t_uuid
        , overdue_type              com_api_type_pkg.t_dict_value
        , file_date                 com_api_type_pkg.t_date_short
        , bank_code                 com_api_type_pkg.t_dict_value
        , crd_run_num               com_api_type_pkg.t_uuid
        , branch_code               com_api_type_pkg.t_dict_value
        , cif_num                   com_api_type_pkg.t_cmid
        , crd_deli_code             com_api_type_pkg.t_dict_value
        , item_1                    com_api_type_pkg.t_text
        , first_deli_date           com_api_type_pkg.t_date_short
        , deli_start_date           com_api_type_pkg.t_date_short
        , num_of_deli               com_api_type_pkg.t_long_id
        , currency_code             com_api_type_pkg.t_dict_value
        , amt_due_princ             com_api_type_pkg.t_money
        , interest_accrued_amt      com_api_type_pkg.t_money
        , amort_amt                 com_api_type_pkg.t_money
        , item_2                    com_api_type_pkg.t_text
        , deli_month                com_api_type_pkg.t_long_id
        , days_to_deli              com_api_type_pkg.t_long_id
        , overdue_interest_rate     com_api_type_pkg.t_money
    );

    type t_mes_rec_130 is record (
        seq_id                      com_api_type_pkg.t_uuid
        , agent_code                com_api_type_pkg.t_dict_value
        , virtual_acc               com_api_type_pkg.t_account_number
        , created_date              com_api_type_pkg.t_date_short
        , parent_acc                com_api_type_pkg.t_account_number
        , virtual_acc_type          com_api_type_pkg.t_dict_value
    );

    type t_mes_rec_65_1 is record (
        file_date                   date
        , cif_num                   com_api_type_pkg.t_cmid
        , agent_id                  com_api_type_pkg.t_dict_value
        , wdr_bank_code             com_api_type_pkg.t_dict_value
        , wdr_acct_num              com_api_type_pkg.t_account_number
        , dep_bank_code             com_api_type_pkg.t_dict_value
        , dep_acct_num              com_api_type_pkg.t_account_number
        , dep_curr_code             com_api_type_pkg.t_curr_code
        , dep_amount                com_api_type_pkg.t_money
        , brief_content             com_api_type_pkg.t_text
        , work_type                 com_api_type_pkg.t_dict_value
        , err_code                  com_api_type_pkg.t_dict_value
    );

    type t_mes_rec_75 is record (
        file_date                   date
        , req_date                  date
        , issused_date              date
        , reg_type                  com_api_type_pkg.t_dict_value
        , issused_branch            com_api_type_pkg.t_dict_value
        , staff_num                 com_api_type_pkg.t_name
        , inviter_num               com_api_type_pkg.t_name
        , manage_agent_id           com_api_type_pkg.t_name
        , cif_num                   com_api_type_pkg.t_cmid
        , card_num                  com_api_type_pkg.t_card_number
        , card_expire_date          date
        , division                  com_api_type_pkg.t_dict_value
        , prod_code                 com_api_type_pkg.t_name
        , card_type_class           com_api_type_pkg.t_dict_value
        , card_class                com_api_type_pkg.t_dict_value
        , card_type                 com_api_type_pkg.t_dict_value
        , brand_code                com_api_type_pkg.t_dict_value
        , card_grade                com_api_type_pkg.t_dict_value
        , old_card_num              com_api_type_pkg.t_card_number
        , card_issue_class          com_api_type_pkg.t_dict_value
        , card_status               com_api_type_pkg.t_dict_value
        , card_status_date          date
        , card_issue_date           date
        , card_aff_code             com_api_type_pkg.t_name
        , is_atm_withdraw           com_api_type_pkg.t_dict_value
        , is_use_pos                com_api_type_pkg.t_dict_value
        , sttl_due_date             date
        , billing_place             com_api_type_pkg.t_dict_value
        , account_no                com_api_type_pkg.t_account_number
        , cert_code                 com_api_type_pkg.t_name
        , sav_acct_num              com_api_type_pkg.t_account_number
        , vir_acct_num              com_api_type_pkg.t_account_number
        , cust_name                 com_api_type_pkg.t_name
        , cust_name_eng             com_api_type_pkg.t_name
        , card_relations            com_api_type_pkg.t_dict_value
        , card_holder_type_id       com_api_type_pkg.t_dict_value
        , card_holder_id            com_api_type_pkg.t_name
        , col_property_info         com_api_type_pkg.t_dict_value
        , col_property_id           com_api_type_pkg.t_name
        , col_acct_no               com_api_type_pkg.t_name
    );

    type t_mes_rec_45 is record (
        bank_code                   com_api_type_pkg.t_dict_value
        , sav_acct_num              com_api_type_pkg.t_account_number
        , acct_num                  com_api_type_pkg.t_account_number
        , notificate_num            com_api_type_pkg.t_name
        , card_num                  com_api_type_pkg.t_card_number
        , approval_num              com_api_type_pkg.t_name
        , approval_date             date
        , branch_code               com_api_type_pkg.t_dict_value
        , notificate_code           com_api_type_pkg.t_dict_value
        , accident_type             com_api_type_pkg.t_dict_value
        , accident_rea_code         com_api_type_pkg.t_dict_value
        , channel_code              com_api_type_pkg.t_dict_value
        , currency_code             com_api_type_pkg.t_curr_code
        , accident_amount           com_api_type_pkg.t_money
        , eff_expire                com_api_type_pkg.t_name
        , cif_num                   com_api_type_pkg.t_cmid
        , accident_content          com_api_type_pkg.t_name
        , register_content          com_api_type_pkg.t_name
        , release_content           com_api_type_pkg.t_name
        , contact_num               com_api_type_pkg.t_name
        , accident_status           com_api_type_pkg.t_dict_value
        , file_date                 date
        , dissmiss_reason           date
        , is_canceled               com_api_type_pkg.t_dict_value
        , cancel_reason             com_api_type_pkg.t_name
        , all_classified_code       com_api_type_pkg.t_name
        , cust_separator_code       com_api_type_pkg.t_name
        , cust_id_num               com_api_type_pkg.t_cmid
        , related_ref_num           com_api_type_pkg.t_name
        , accident_register_bal     com_api_type_pkg.t_money
        , is_fee_collected          com_api_type_pkg.t_dict_value
        , respone_for_register      com_api_type_pkg.t_name
        , register_name             com_api_type_pkg.t_name
    );

    type t_mes_rec_45_1 is record (
        file_date                   date
        , cif_num                   com_api_type_pkg.t_cmid
        , agent_id                  com_api_type_pkg.t_dict_value
        , w_bank_code               com_api_type_pkg.t_dict_value
        , sav_acct_num              com_api_type_pkg.t_account_number
        , dep_bank_code             com_api_type_pkg.t_dict_value
        , dep_acct_num              com_api_type_pkg.t_account_number
        , dep_currency              com_api_type_pkg.t_dict_value
        , dep_amount                com_api_type_pkg.t_money
        , brief_content             com_api_type_pkg.t_name
        , work_type                 com_api_type_pkg.t_dict_value
        , err_code                  com_api_type_pkg.t_dict_value
    );

    type t_mes_rec_46 is record (
        bank_code                   com_api_type_pkg.t_dict_value
        , sav_acct_num              com_api_type_pkg.t_account_number
        , acct_num                  com_api_type_pkg.t_dict_value
        , accident_num              com_api_type_pkg.t_dict_value
        , card_num                  com_api_type_pkg.t_card_number
        , approval_num              com_api_type_pkg.t_name
        , date_report               com_api_type_pkg.t_dict_value
        , trans_agent_id            com_api_type_pkg.t_dict_value
        , notif_num                 com_api_type_pkg.t_dict_value
        , accident_type             com_api_type_pkg.t_dict_value
        , accident_rea_code         com_api_type_pkg.t_dict_value
        , channel_code              com_api_type_pkg.t_dict_value
        , currency_code             com_api_type_pkg.t_curr_code
        , accident_amount           com_api_type_pkg.t_money
        , eff_expire                com_api_type_pkg.t_dict_value
        , cif_no                    com_api_type_pkg.t_cmid
        , accident_content          com_api_type_pkg.t_short_desc
        , reg_ref_content           com_api_type_pkg.t_short_desc
        , release_ref_content       com_api_type_pkg.t_short_desc
        , contact_num               com_api_type_pkg.t_name
        , accident_reg_status       com_api_type_pkg.t_dict_value
        , st_report_accident        date
        , for_acc_report            com_api_type_pkg.t_short_desc
        , is_canceled               com_api_type_pkg.t_dict_value
        , cancel_reason             com_api_type_pkg.t_short_desc
        , all_classified_code       com_api_type_pkg.t_dict_value
        , cust_separator_code       com_api_type_pkg.t_dict_value
        , cust_id_num               com_api_type_pkg.t_name
        , related_number            com_api_type_pkg.t_name
        , accident_reg              com_api_type_pkg.t_name
        , whether_num               com_api_type_pkg.t_dict_value
        , name_of_emp               com_api_type_pkg.t_name
        , reg_name                  com_api_type_pkg.t_name
    );

    type t_mes_rec_52 is record (
        file_date                   date
        , cif_num                   com_api_type_pkg.t_cmid
        , crd_acct_num              com_api_type_pkg.t_account_number
        , agent_id                  com_api_type_pkg.t_dict_value
        , cust_reg_date             date
        , acct_update_date          date
        , crd_limit                 com_api_type_pkg.t_long_id
        , remain_crd_limit          com_api_type_pkg.t_long_id
        , cash_limit_date           date
        , cash_limit                com_api_type_pkg.t_long_id
        , remain_cash_limit         com_api_type_pkg.t_long_id
        , is_his_limit_up           com_api_type_pkg.t_name
        , is_his_limit_down         com_api_type_pkg.t_name
        , is_his_limit_past         com_api_type_pkg.t_name
        , cus_level_limit           com_api_type_pkg.t_long_id
    );

    type t_mes_rec_134 is record (
        file_date                   date
        , cif_num                   com_api_type_pkg.t_cmid
        , branch_code               com_api_type_pkg.t_dict_value
        , wdr_bank_code             com_api_type_pkg.t_dict_value
        , wdr_acct_num              com_api_type_pkg.t_account_number
        , dep_bank_code             com_api_type_pkg.t_dict_value
        , dep_acct_num              com_api_type_pkg.t_account_number
        , dep_curr_code             com_api_type_pkg.t_curr_code
        , dep_amount                com_api_type_pkg.t_money
        , brief_content             com_api_type_pkg.t_text
        , work_type                 com_api_type_pkg.t_dict_value
        , err_code                  com_api_type_pkg.t_dict_value
        , sv_crd_acct               com_api_type_pkg.t_account_number
    );

    type t_mes_rec_136 is record (
        seq_id                      com_api_type_pkg.t_uuid
        , file_date                 com_api_type_pkg.t_date_short
        , cif_num                   com_api_type_pkg.t_cmid
        , branch_code               com_api_type_pkg.t_dict_value
        , wdr_bank_code             com_api_type_pkg.t_dict_value
        , wdr_acct_num              com_api_type_pkg.t_account_number
        , dep_bank_code             com_api_type_pkg.t_dict_value
        , dep_acct_num              com_api_type_pkg.t_account_number
        , dep_curr_code             com_api_type_pkg.t_curr_code
        , dep_amount                com_api_type_pkg.t_money
        , brief_content             com_api_type_pkg.t_text
        , work_type                 com_api_type_pkg.t_dict_value
        , err_code                  com_api_type_pkg.t_dict_value
        , sv_crd_acct               com_api_type_pkg.t_account_number
    );

    type t_mes_rec_137 is record (
        file_date                   date
        , cif_num                   com_api_type_pkg.t_cmid
        , branch_code               com_api_type_pkg.t_dict_value
        , wdr_bank_code             com_api_type_pkg.t_dict_value
        , wdr_acct_num              com_api_type_pkg.t_account_number
        , dep_bank_code             com_api_type_pkg.t_dict_value
        , dep_acct_num              com_api_type_pkg.t_account_number
        , dep_curr_code             com_api_type_pkg.t_curr_code
        , dep_amount                com_api_type_pkg.t_money
        , brief_content             com_api_type_pkg.t_text
        , work_type                 com_api_type_pkg.t_dict_value
        , err_code                  com_api_type_pkg.t_dict_value
        , sv_crd_acct               com_api_type_pkg.t_account_number
    );

    type t_mes_rec_138 is record (
        seq_id                      com_api_type_pkg.t_uuid
        , file_date                 com_api_type_pkg.t_date_short
        , cif_num                   com_api_type_pkg.t_cmid
        , branch_code               com_api_type_pkg.t_dict_value
        , wdr_bank_code             com_api_type_pkg.t_dict_value
        , wdr_acct_num              com_api_type_pkg.t_account_number
        , dep_bank_code             com_api_type_pkg.t_dict_value
        , dep_acct_num              com_api_type_pkg.t_account_number
        , dep_curr_code             com_api_type_pkg.t_curr_code
        , dep_amount                com_api_type_pkg.t_money
        , brief_content             com_api_type_pkg.t_text
        , work_type                 com_api_type_pkg.t_dict_value
        , err_code                  com_api_type_pkg.t_dict_value
        , sv_crd_acct               com_api_type_pkg.t_account_number
    );

    type t_mes_rec_62 is record (
          recover_date              date
        , serial_num                com_api_type_pkg.t_uuid
        , r_branch_code             com_api_type_pkg.t_dict_value
        , branch_code               com_api_type_pkg.t_dict_value
        , global_id                 com_api_type_pkg.t_name
        , card_num                  com_api_type_pkg.t_card_number
        , sav_acct_num              com_api_type_pkg.t_account_number
        , crd_acct_num              com_api_type_pkg.t_account_number
        , billing_date              date
        , cif_no                    com_api_type_pkg.t_cmid
        , first_overdue_date        date
        , first_claim_date          date
        , payment_amount            com_api_type_pkg.t_money
        , deli_principal            com_api_type_pkg.t_money
        , overdue_fee               com_api_type_pkg.t_money
        , overdue_interest          com_api_type_pkg.t_money
        , excess_amount             com_api_type_pkg.t_money
        , balance_after             com_api_type_pkg.t_money
    );

    type t_mes_rec_49 is record (
        bank_code                   com_api_type_pkg.t_dict_value
        , file_date                 date
        , acct_class_code           com_api_type_pkg.t_dict_value
        , crd_acct_num              com_api_type_pkg.t_account_number
        , trx_seq_id                com_api_type_pkg.t_long_id
        , agent_id                  com_api_type_pkg.t_dict_value
        , accrual_code              com_api_type_pkg.t_dict_value
        , payment_code              com_api_type_pkg.t_dict_value
        , business_code             com_api_type_pkg.t_dict_value
        , bs_detail_code            com_api_type_pkg.t_dict_value
        , amt_code                  com_api_type_pkg.t_dict_value
        , start_date_1              date
        , end_date_1                date
        , side                      com_api_type_pkg.t_dict_value
        , cal_method                com_api_type_pkg.t_dict_value
        , num_of_date_1             com_api_type_pkg.t_long_id
        , i_amt                     com_api_type_pkg.t_money
        , book_id                   com_api_type_pkg.t_dict_value
        , l_bs_amt_code             com_api_type_pkg.t_name
        , l_is_amt_code             com_api_type_pkg.t_dict_value
        , kfrs_bs_acct_code         com_api_type_pkg.t_dict_value
        , kfrs_is_acct_code         com_api_type_pkg.t_dict_value
        , cif_num                   com_api_type_pkg.t_cmid
        , curr_code                 com_api_type_pkg.t_dict_value
        , pri_amt                   com_api_type_pkg.t_money
        , start_date_2              date
        , end_date_2                date
        , num_of_date_2             com_api_type_pkg.t_long_id
        , rate                      com_api_type_pkg.t_rate
        , i_amt_1                   com_api_type_pkg.t_money
        , i_amt_2                   com_api_type_pkg.t_money
        , i_cal_event               com_api_type_pkg.t_dict_value
        , i_flag                    com_api_type_pkg.t_dict_value
        , s_code                    com_api_type_pkg.t_dict_value
        , g_id                      com_api_type_pkg.t_dict_value
    );

    type t_mes_rec_83 is record (
        base_date                   date
        , branch_code               com_api_type_pkg.t_dict_value
        , cif_code                  com_api_type_pkg.t_cmid
        , cardholder_name           com_api_type_pkg.t_name
        , address                   com_api_type_pkg.t_short_desc
        , province_code             com_api_type_pkg.t_dict_value
        , phone_num                 com_api_type_pkg.t_short_desc
        , nationality               com_api_type_pkg.t_country_code
        , gender                    com_api_type_pkg.t_boolean
        , birth_date                date
        , id_num                    com_api_type_pkg.t_name
        , id_issued_date            date
        , doc_num                   com_api_type_pkg.t_short_desc
        , doc_issued_date           date
        , tax_code                  com_api_type_pkg.t_short_desc
        , wh_name                   com_api_type_pkg.t_name
        , id_num_of_wh              com_api_type_pkg.t_name
        , sup_cardholder_name       com_api_type_pkg.t_name
        , sup_cardholder_id         com_api_type_pkg.t_name
    );

    type t_mes_rec_83_1 is record (
        base_date                   date
        , branch_code               com_api_type_pkg.t_dict_value
        , cif_code                  com_api_type_pkg.t_cmid
        , cardholder_name           com_api_type_pkg.t_name
        , contract_num              com_api_type_pkg.t_name
        , card_type_name            com_api_type_pkg.t_name
        , card_open_date            date
        , expired_date              date
        , card_closed_date          date
        , crd_limit                 com_api_type_pkg.t_long_id
        , statement_date            date
        , payment_amt               com_api_type_pkg.t_money
        , min_payment_amt           com_api_type_pkg.t_money
        , paid_amt                  com_api_type_pkg.t_money
        , overdue_amt               com_api_type_pkg.t_money
        , overdue_day_count         com_api_type_pkg.t_short_id
        , overdue_count             com_api_type_pkg.t_short_id
    );

    type t_mes_rec_61 is record (
        file_date                   date
        , cif_num                   com_api_type_pkg.t_cmid
        , branch_code               com_api_type_pkg.t_dict_value
        , wdr_bank_code             com_api_type_pkg.t_dict_value
        , wdr_acct_num              com_api_type_pkg.t_account_number
        , dep_bank_code             com_api_type_pkg.t_dict_value
        , dep_acct_num              com_api_type_pkg.t_account_number
        , dep_curr_code             com_api_type_pkg.t_curr_code
        , dep_amount                com_api_type_pkg.t_money
        , brief_content             com_api_type_pkg.t_text
        , work_type                 com_api_type_pkg.t_dict_value
        , err_code                  com_api_type_pkg.t_dict_value
        , sv_crd_acct               com_api_type_pkg.t_account_number
    );

    type t_mes_rec_72 is record (
        file_date                   date
        , cif_num                   com_api_type_pkg.t_cmid
        , branch_code               com_api_type_pkg.t_dict_value
        , wdr_bank_code             com_api_type_pkg.t_dict_value
        , wdr_acct_num              com_api_type_pkg.t_account_number
        , dep_bank_code             com_api_type_pkg.t_dict_value
        , dep_acct_num              com_api_type_pkg.t_account_number
        , dep_curr_code             com_api_type_pkg.t_curr_code
        , dep_amount                com_api_type_pkg.t_money
        , brief_content             com_api_type_pkg.t_text
        , work_type                 com_api_type_pkg.t_dict_value
        , err_code                  com_api_type_pkg.t_dict_value
        , sv_account                com_api_type_pkg.t_account_number
    );

    type t_mes_rec_58 is record (
        file_date                   date
        , cif_num                   com_api_type_pkg.t_cmid
        , crd_acct_num              com_api_type_pkg.t_account_number
        , agent_id                  com_api_type_pkg.t_dict_value
        , bank_code                 com_api_type_pkg.t_dict_value
        , sav_acct_num              com_api_type_pkg.t_account_number
        , acct_curr                 com_api_type_pkg.t_curr_code
        , bill_amount               com_api_type_pkg.t_money
        , mad_amount                com_api_type_pkg.t_money
        , unbilled_curr             com_api_type_pkg.t_curr_code
        , unbilled_amount           com_api_type_pkg.t_money
        , card_num                  com_api_type_pkg.t_card_number
        , virt_acct_num             com_api_type_pkg.t_account_number
        , rea_code01                com_api_type_pkg.t_dict_value
        , rea_code02                com_api_type_pkg.t_dict_value
        , rea_code03                com_api_type_pkg.t_dict_value
        , rea_code04                com_api_type_pkg.t_dict_value
        , rea_code05                com_api_type_pkg.t_dict_value
        , rea_code06                com_api_type_pkg.t_dict_value
        , rea_code07                com_api_type_pkg.t_dict_value
        , rea_code08                com_api_type_pkg.t_dict_value
        , rea_code09                com_api_type_pkg.t_dict_value
        , rea_code10                com_api_type_pkg.t_dict_value
        , brief_content             com_api_type_pkg.t_text
        , work_type                 com_api_type_pkg.t_dict_value
        , cr_used_start_dt          date
        , cr_used_end_dt            date
    );

    type t_mes_rec_131 is record (
        acct_card_number            com_api_type_pkg.t_account_number
        , oper_date                 date
        , payment_date              date
        , oper_id                   com_api_type_pkg.t_long_id
        , original_oper_id          com_api_type_pkg.t_long_id
        , reversal                  com_api_type_pkg.t_boolean
        , fee_code                  com_api_type_pkg.t_dict_value
        , original_fee_amount       com_api_type_pkg.t_money
        , original_fee_impact       com_api_type_pkg.t_sign
        , discount_on_fee_amount    com_api_type_pkg.t_money
        , discount_on_fee_impact    com_api_type_pkg.t_sign
        , fee_amount_after_discount com_api_type_pkg.t_money
        , fee_after_discount_impact com_api_type_pkg.t_sign
        , vat_on_fee_amount         com_api_type_pkg.t_money
        , vat_on_fee_impact         com_api_type_pkg.t_sign
        , original_oper_amount      com_api_type_pkg.t_money
        , original_oper_impact      com_api_type_pkg.t_sign
        , vat_gl_account            com_api_type_pkg.t_account_number
        , sav_account               com_api_type_pkg.t_account_number
    );

    type t_mes_rec_133 is record (
        branch_code                 com_api_type_pkg.t_name
        , oper_date                 date
        , vat_amount                com_api_type_pkg.t_money
        , vat_impact                com_api_type_pkg.t_sign
        , cif_no                    com_api_type_pkg.t_name
        , oper_id                   com_api_type_pkg.t_long_id
        , original_oper_id          com_api_type_pkg.t_long_id
        , reversal                  com_api_type_pkg.t_boolean
        , acct_card_number          com_api_type_pkg.t_account_number
    );

    type t_mes_rec_60 is record (
        recover_branch              com_api_type_pkg.t_dict_value
        , agent_id                  com_api_type_pkg.t_dict_value
        , global_id                 com_api_type_pkg.t_name
        , card_num                  com_api_type_pkg.t_card_number
        , acct_num                  com_api_type_pkg.t_account_number
        , crd_acct_num              com_api_type_pkg.t_account_number
        , due_date                  date
        , cif_no                    com_api_type_pkg.t_cmid
        , first_overdue_date        date
        , first_req_date            date
        , total_dep_amount          com_api_type_pkg.t_money
        , overdue_amount            com_api_type_pkg.t_money
        , overdue_fee               com_api_type_pkg.t_money
        , overdue_interest          com_api_type_pkg.t_money
        , extra_amount              com_api_type_pkg.t_money
        , bal_after_trans           com_api_type_pkg.t_money
    );

    type t_mes_rec_88 is record (
        cif_no                      com_api_type_pkg.t_name
        , account_number            com_api_type_pkg.t_account_number
        , payment_posting_date      date
        , amount_1                  com_api_type_pkg.t_money
        , amount_2                  com_api_type_pkg.t_money
        , amount_3                  com_api_type_pkg.t_money
        , amount_4                  com_api_type_pkg.t_money
        , amount_5                  com_api_type_pkg.t_money
        , amount_6                  com_api_type_pkg.t_money
        , amount_7                  com_api_type_pkg.t_money
        , amount_8                  com_api_type_pkg.t_money
        , amount_9                  com_api_type_pkg.t_money
        , amount_10                 com_api_type_pkg.t_money
        , amount_11                 com_api_type_pkg.t_money
        , amount_12                 com_api_type_pkg.t_money
        , amount_13                 com_api_type_pkg.t_money
        , amount_14                 com_api_type_pkg.t_money
        , amount_15                 com_api_type_pkg.t_money
        , amount_16                 com_api_type_pkg.t_money
        , amount_17                 com_api_type_pkg.t_money
        , amount_18                 com_api_type_pkg.t_money
    );

    type t_mes_rec_66 is record (
        branch_code                 com_api_type_pkg.t_name
        , oper_id                   com_api_type_pkg.t_long_id
        , oper_date                 date
        , cif_no                    com_api_type_pkg.t_name
        , account_number            com_api_type_pkg.t_account_number
        , amount                    com_api_type_pkg.t_money
    );

    type t_mes_rec_87 is record (
        invoice_date                date
        , cif_no                    com_api_type_pkg.t_name
        , account_number            com_api_type_pkg.t_account_number
        , due_date                  date
        , fee_amount                com_api_type_pkg.t_money
        , pos_domes_invi_amount     com_api_type_pkg.t_money
        , pos_interest              com_api_type_pkg.t_money
        , pos_oversea_invi_amount   com_api_type_pkg.t_money
        , pos_domes_corp_amount     com_api_type_pkg.t_money
        , pos_oversea_corp_amount   com_api_type_pkg.t_money
        , cash_domes_invi_amount    com_api_type_pkg.t_money
        , cash_interest             com_api_type_pkg.t_money
        , cash_oversea_invi_amount  com_api_type_pkg.t_money
        , pro_interest              com_api_type_pkg.t_money
    );

    type t_mes_rec_89 is record (
        cif_no                      com_api_type_pkg.t_name
        , account_number            com_api_type_pkg.t_account_number
        , delin_date                date
        , ovdue_fee                 com_api_type_pkg.t_money
        , ovdue_domes_invi_pos      com_api_type_pkg.t_money
        , ovdue_domes_invi_pos_inr  com_api_type_pkg.t_money
        , ovdue_ovsea_invi_pos      com_api_type_pkg.t_money
        , ovdue_domes_corp_pos      com_api_type_pkg.t_money
        , ovdue_ovsea_corp_pos      com_api_type_pkg.t_money
        , ovdue_domes_invi_cash     com_api_type_pkg.t_money
        , ovdue_domes_invi_cash_inr com_api_type_pkg.t_money
        , ovdue_ovsea_invi_cash     com_api_type_pkg.t_money
    );

    type t_oper is record (
        oper_id                     com_api_type_pkg.t_long_id
    );

    type t_mes_rec_56 is record (
        branch_code                 com_api_type_pkg.t_name
        , cif_no                    com_api_type_pkg.t_name
        , customer_name             com_api_type_pkg.t_name
        , type_of_id                com_api_type_pkg.t_dict_value
        , id_number                 com_api_type_pkg.t_name
        , account_number            com_api_type_pkg.t_account_number
        , account_subject           com_api_type_pkg.t_account_number
        , overdraft_amount          com_api_type_pkg.t_money
        , overdue_amount            com_api_type_pkg.t_money
        , overdue_date              date
    );

    type t_rec_balance is record (
        aggregation_date            date
        , account_number            com_api_type_pkg.t_account_number
        , status                    com_api_type_pkg.t_dict_value
        , amount                    com_api_type_pkg.t_money
        , currency                  com_api_type_pkg.t_curr_code
        , agent_number              com_api_type_pkg.t_name
    );  

    type t_mes_rec_99 is record (
        bank_code                       com_api_type_pkg.t_dict_value
        , log_date                      com_api_type_pkg.t_name
        , global_id                     com_api_type_pkg.t_name
        , progress_serial_number        com_api_type_pkg.t_name
        , environment_class_code        com_api_type_pkg.t_name
        , ip_address                    com_api_type_pkg.t_name
        , pcmac_address                 com_api_type_pkg.t_name
        , sv_terminal_number            com_api_type_pkg.t_name
        , sv_terminal_manage_branch     com_api_type_pkg.t_name
        , sv_terminal_manage_branch2    com_api_type_pkg.t_name
        , sv_trasaction_code            com_api_type_pkg.t_name
        , operator_staff_number         com_api_type_pkg.t_name
        , operator_staff_name           com_api_type_pkg.t_name
        , employee_job_code_operator    com_api_type_pkg.t_name
        , branch_code                   com_api_type_pkg.t_name
        , real_belong_branch_code       com_api_type_pkg.t_name
        , belong_branch_code            com_api_type_pkg.t_name
        , organizational_type_code      com_api_type_pkg.t_name
        , approval_status_code          com_api_type_pkg.t_name
        , approval_codes                com_api_type_pkg.t_name
        , first_approval_employee       com_api_type_pkg.t_name
        , reason_for_rejection          com_api_type_pkg.t_name
        , system_date                   com_api_type_pkg.t_name
        , transaction_date              com_api_type_pkg.t_name
        , processing_start_time         com_api_type_pkg.t_name
        , processing_end_time           com_api_type_pkg.t_name
        , current_business_day          com_api_type_pkg.t_name
        , next_business_day             com_api_type_pkg.t_name
        , before_business_day           com_api_type_pkg.t_name
        , before_business_day2          com_api_type_pkg.t_name
        , transaction_date2             com_api_type_pkg.t_name
        , holiday_code                  com_api_type_pkg.t_name
        , cif_no                        com_api_type_pkg.t_name
        , individual_company_code       com_api_type_pkg.t_name
        , customer_id_number            com_api_type_pkg.t_name
        , customer_id_number_code       com_api_type_pkg.t_name
        , customer_name                 com_api_type_pkg.t_name
        , cbs_account_number            com_api_type_pkg.t_name
        , card_number                   com_api_type_pkg.t_name
        , tr_curr_code                  com_api_type_pkg.t_name
        , amount_in_tr_cur              com_api_type_pkg.t_name
        , bank_based_conversion_amount  com_api_type_pkg.t_name
        , sv_trasaction_code2           com_api_type_pkg.t_name
        , sv_transaction_name           com_api_type_pkg.t_name
        , cancel_separator_code         com_api_type_pkg.t_name
        , cancellation_staff_number     com_api_type_pkg.t_name
        , cancellation_staff_name       com_api_type_pkg.t_name
        , approval_req_branch           com_api_type_pkg.t_name
        , approval_req_staff_number     com_api_type_pkg.t_name
        , approval_req_datetime         com_api_type_pkg.t_name
        , approval_complete_datetime    com_api_type_pkg.t_name
        , approval_status_code2         com_api_type_pkg.t_name
        , industry_group_code           com_api_type_pkg.t_name
    );

    type t_mes_rec_92 is record (
            cif_num                     com_api_type_pkg.t_cmid
            , division_code             com_api_type_pkg.t_dict_value
            , card_num                  com_api_type_pkg.t_card_number
            , card_type                 com_api_type_pkg.t_dict_value
            , status_code               com_api_type_pkg.t_dict_value
            , trans_date                date
            , trans_time                date
            , audit_num                 com_api_type_pkg.t_dict_value
            , reversal_date             date
            , reversal_time             date
            , reversal_audit_num        com_api_type_pkg.t_dict_value
            , card_sale_code            com_api_type_pkg.t_dict_value
            , classified_code           com_api_type_pkg.t_dict_value
            , trans_amount              com_api_type_pkg.t_money
            , mrc_name                  com_api_type_pkg.t_name
            , mrc_num                   com_api_type_pkg.t_name
            , mrc_business_num          com_api_type_pkg.t_name
            , mrc_business_name         com_api_type_pkg.t_name
            , mrc_country_code          com_api_type_pkg.t_dict_value
        );

    type t_mes_rec_126 is record (
        ref_date                    date
        , account_number            com_api_type_pkg.t_account_number
        , customer_number           com_api_type_pkg.t_name
        , point_type                com_api_type_pkg.t_dict_value
        , earned_points             com_api_type_pkg.t_long_id
        , used_points               com_api_type_pkg.t_long_id
        , expired_points            com_api_type_pkg.t_long_id
        , remaining_points          com_api_type_pkg.t_long_id
    );
    
    type t_mes_rec_93 is record (
        account_number            com_api_type_pkg.t_account_number
        , card_number               com_api_type_pkg.t_card_number
        , auth_number               com_api_type_pkg.t_dict_value
        , data_type                 com_api_type_pkg.t_dict_value
        , auth_date                 date
        , auth_reversal_date        date
        , clearing_date             date
        , clearing_reversal_date    date
        , payment_due_date          date
        , payment_prod_code         com_api_type_pkg.t_dict_value
        , approved_amount           com_api_type_pkg.t_money
        , merchant_number           com_api_type_pkg.t_text
        , saving_account            com_api_type_pkg.t_account_number
        , merchant_name             com_api_type_pkg.t_text
    );

    type t_mes_tab_49 is table of t_mes_rec_49 index by binary_integer;
    type t_mes_tab_60 is table of t_mes_rec_60 index by binary_integer;
    type t_mes_tab_61 is table of t_mes_rec_61 index by binary_integer;
    type t_mes_tab_62 is table of t_mes_rec_62 index by binary_integer;
    type t_mes_tab_65_1 is table of t_mes_rec_65_1 index by binary_integer;
    type t_mes_tab_75 is table of t_mes_rec_75 index by binary_integer;
    type t_mes_tab_45 is table of t_mes_rec_45 index by binary_integer;
    type t_mes_tab_45_1 is table of t_mes_rec_45_1 index by binary_integer;
    type t_mes_tab_46 is table of t_mes_rec_46 index by binary_integer;
    type t_mes_tab_52 is table of t_mes_rec_52 index by binary_integer;
    type t_mes_tab_56 is table of t_mes_rec_56 index by binary_integer;
    type t_mes_tab_58 is table of t_mes_rec_58 index by binary_integer;
    type t_mes_tab_66 is table of t_mes_rec_66 index by binary_integer;
    type t_mes_tab_72 is table of t_mes_rec_72 index by binary_integer;
    type t_mes_tab_83 is table of t_mes_rec_83 index by binary_integer;
    type t_mes_tab_83_1 is table of t_mes_rec_83_1 index by binary_integer;
    type t_mes_tab_87 is table of t_mes_rec_87 index by binary_integer;
    type t_mes_tab_88 is table of t_mes_rec_88 index by binary_integer;
    type t_mes_tab_89 is table of t_mes_rec_89 index by binary_integer;
    type t_mes_tab_131 is table of t_mes_rec_131 index by binary_integer;
    type t_mes_tab_133 is table of t_mes_rec_133 index by binary_integer;
    type t_mes_tab_134 is table of t_mes_rec_134 index by binary_integer;
    type t_mes_tab_136 is table of t_mes_rec_136 index by binary_integer;
    type t_mes_tab_137 is table of t_mes_rec_137 index by binary_integer;
    type t_mes_tab_138 is table of t_mes_rec_138 index by binary_integer;
    type t_tab_balance is table of t_rec_balance index by binary_integer;
    type t_mes_tab_99 is table of t_mes_rec_99 index by binary_integer;
    type t_mes_tab_92 is table of t_mes_rec_92 index by binary_integer;
    type t_mes_tab_126 is table of t_mes_rec_126 index by binary_integer;
    type t_mes_tab_93 is table of t_mes_rec_93 index by binary_integer;
    type t_oper_list is table of t_oper;

end cst_woo_api_type_pkg;
/
