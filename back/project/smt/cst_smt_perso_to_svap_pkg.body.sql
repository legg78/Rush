create or replace package body cst_smt_perso_to_svap_pkg is

procedure get_flow_template(
    i_flow_id           in      com_api_type_pkg.t_tiny_id
  , o_template_appl_id      out com_api_type_pkg.t_long_id
  , o_appl_type             out com_api_type_pkg.t_dict_value
) is
begin
    select template_appl_id
         , appl_type
      into o_template_appl_id
         , o_appl_type
      from app_flow_vw
     where id = i_flow_id;

    trc_log_pkg.debug(
        'i_flow_id [' || i_flow_id ||
        '], o_template_appl_id [' || o_template_appl_id ||
        '], o_appl_type [' || o_appl_type ||
        ']'
    );
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'APPLICATION_FLOW_NOT_FOUND'
          , i_env_param1    => o_appl_type
          , i_env_param2    => i_flow_id
         );
end get_flow_template;

procedure proc_flow_create_new_cust(
    i_perso_rec             in      cst_smt_api_type_pkg.t_perso_rec
  , io_appl_id              in out  com_api_type_pkg.t_long_id
) is
    l_template_appl_id          com_api_type_pkg.t_long_id;
    l_sysdate                   date                            := com_api_sttl_day_pkg.get_sysdate;
    l_appl_id                   com_api_type_pkg.t_long_id;
    l_appl_type                 com_api_type_pkg.t_dict_value;
    l_appl_inst_id              com_api_type_pkg.t_inst_id;
    l_appl_agent_id             com_api_type_pkg.t_agent_id;
    l_seqnum                    com_api_type_pkg.t_tiny_id;
    l_application_block_id      com_api_type_pkg.t_long_id;
    l_customer_block_id         com_api_type_pkg.t_long_id;
    l_contract_block_id         com_api_type_pkg.t_long_id;
    l_card_block_id             com_api_type_pkg.t_long_id;
    l_cardholder_block_id       com_api_type_pkg.t_long_id;
    l_person_block_id           com_api_type_pkg.t_long_id;
    l_identity_card_block_id    com_api_type_pkg.t_long_id;
    l_person_name_block_id      com_api_type_pkg.t_long_id;
    l_account_block_id          com_api_type_pkg.t_long_id;
    l_account_obj_block_id      com_api_type_pkg.t_long_id;
    l_company_block_id          com_api_type_pkg.t_long_id;
    l_address_block_id          com_api_type_pkg.t_long_id;
    l_address_name_block_id     com_api_type_pkg.t_long_id;
    l_fexible_field_id          com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text       => 'START application 1001 creation from perso file'
    );

    l_appl_id :=
        com_api_id_pkg.get_id(
            i_seq       => app_application_seq.nextval
          , i_date      => l_sysdate
        );

    trc_log_pkg.debug(
        'new io_appl_id [' || l_appl_id || ']'
    );

    get_flow_template(
        i_flow_id           => cst_smt_api_const_pkg.APP_FLOW_ID_1001
      , o_template_appl_id  => l_template_appl_id
      , o_appl_type         => l_appl_type
    );

    l_appl_inst_id  := i_perso_rec.bank_id;

    l_appl_agent_id :=
        ost_api_institution_pkg.get_default_agent(
            i_inst_id   => l_appl_inst_id
        );

    app_ui_application_pkg.add_application(
        io_appl_id         => l_appl_id
      , o_seqnum           => l_seqnum
      , i_appl_type        => app_api_const_pkg.APPL_TYPE_ISSUING
      , i_appl_number      => null
      , i_flow_id          => cst_smt_api_const_pkg.APP_FLOW_ID_1001
      , i_inst_id          => l_appl_inst_id
      , i_agent_id         => l_appl_agent_id
      , i_appl_status      => app_api_const_pkg.APPL_STATUS_PROC_READY
      , i_session_file_id  => null
      , i_file_rec_num     => null
      , i_customer_type    => null
      , i_split_hash       => null
    );

    trc_log_pkg.debug(
        i_text          => 'New l_appl_id [#1]'
      , i_env_param1    => l_appl_id
    );

    app_api_application_pkg.get_appl_data(
        i_appl_id       => l_appl_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'APPLICATION'
      , i_parent_id         => null
      , o_appl_data_id      => l_application_block_id
    );

    trc_log_pkg.debug(
        i_text => 'l_application_block_id = ' || l_application_block_id
    );
    -- CUSTOMER_TYPE block
    app_api_application_pkg.add_element(
        i_element_name      => 'CUSTOMER_TYPE'
      , i_parent_id         => l_application_block_id
      , i_element_value     => com_api_const_pkg.ENTITY_TYPE_PERSON
    );
    -- CUSTOMER_TYPE block
    app_api_application_pkg.add_element(
        i_element_name      => 'CUSTOMER'
      , i_parent_id         => l_application_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CUSTOMER'
      , i_parent_id         => l_application_block_id
      , o_appl_data_id      => l_customer_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_customer_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CUSTOMER_NUMBER'
      , i_parent_id         => l_customer_block_id
      , i_element_value     => ''
    );
    -- Add CONTRACT block
    app_api_application_pkg.add_element(
        i_element_name      => 'CONTRACT'
      , i_parent_id         => l_customer_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CONTRACT'
      , i_parent_id         => l_customer_block_id
      , o_appl_data_id      => l_contract_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_contract_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CONTRACT_TYPE'
      , i_parent_id         => l_contract_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CONTRACT_NUMBER'
      , i_parent_id         => l_contract_block_id
      , i_element_value     => ''
    );
    -- CARD block
    app_api_application_pkg.add_element(
        i_element_name      => 'CARD'
      , i_parent_id         => l_contract_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CARD'
      , i_parent_id         => l_contract_block_id
      , o_appl_data_id      => l_card_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_card_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CARD_TYPE'
      , i_parent_id         => l_card_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CARD_NUMBER'
      , i_parent_id         => l_card_block_id
      , i_element_value     => i_perso_rec.card_number
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'EXPIRATION_DATE'
      , i_parent_id         => l_card_block_id
      , i_element_value     => to_char(i_perso_rec.card_expiry_date,'MMYY')
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD'
      , i_parent_id         => l_card_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'FLEXIBLE_FIELD'
      , i_parent_id         => l_card_block_id
      , o_appl_data_id      => l_fexible_field_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_NAME'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => 'CST_TERRITORY_CODE'
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_VALUE'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => i_perso_rec.territiory_code
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'FLEXIBLE_FIELD'
      , i_parent_id         => l_card_block_id
      , o_appl_data_id      => l_fexible_field_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_NAME'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => 'CST_PROCESS_JULIAN_DATE'
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_VALUE'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => to_char(l_sysdate, 'ddmmyyyy')
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'FLEXIBLE_FIELD'
      , i_parent_id         => l_card_block_id
      , o_appl_data_id      => l_fexible_field_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_NAME'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => 'CST_CITY_CODE'
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_VALUE'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => i_perso_rec.city_code
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'FLEXIBLE_FIELD'
      , i_parent_id         => l_card_block_id
      , o_appl_data_id      => l_fexible_field_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_NAME'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => 'CST_CURRENCY_CODE'
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_VALUE'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => i_perso_rec.curr_code
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'FLEXIBLE_FIELD'
      , i_parent_id         => l_card_block_id
      , o_appl_data_id      => l_fexible_field_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_NAME'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => 'CST_ACS_CODE_INDICATOR'
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_VALUE'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => i_perso_rec.acs_code_ind
    );
    -- CARDHOLDER block
    app_api_application_pkg.add_element(
        i_element_name      => 'CARDHOLDER'
      , i_parent_id         => l_card_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CARDHOLDER'
      , i_parent_id         => l_card_block_id
      , o_appl_data_id      => l_cardholder_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_cardholder_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CARDHOLDER_NAME'
      , i_parent_id         => l_cardholder_block_id
      , i_element_value     => i_perso_rec.cardholder_name
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CARDHOLDER_BIRTH_DATE'
      , i_parent_id         => l_cardholder_block_id
      , i_element_value     => i_perso_rec.cardholder_birth_date
    );
    -- PERSON block
    app_api_application_pkg.add_element(
        i_element_name      => 'PERSON'
      , i_parent_id         => l_cardholder_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'PERSON'
      , i_parent_id         => l_cardholder_block_id
      , o_appl_data_id      => l_person_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_person_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'PERSON_NAME'
      , i_parent_id         => l_person_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'PERSON_NAME'
      , i_parent_id         => l_person_block_id
      , o_appl_data_id      => l_person_name_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'SURNAME'
      , i_parent_id         => l_person_name_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FIRST_NAME'
      , i_parent_id         => l_person_name_block_id
      , i_element_value     => i_perso_rec.cardholder_name
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'IDENTITY_CARD'
      , i_parent_id         => l_person_block_id
      , i_element_value     => ''
    );
    -- IDENTITY_CARD block
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'IDENTITY_CARD'
      , i_parent_id         => l_person_block_id
      , o_appl_data_id      => l_identity_card_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_identity_card_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'ID_TYPE'
      , i_parent_id         => l_identity_card_block_id
      , i_element_value     => cst_smt_api_const_pkg.ID_IDENTITY_CARD_TYPE
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'ID_SERIES'
      , i_parent_id         => l_identity_card_block_id
      , i_element_value     => i_perso_rec.id_code
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'ACCOUNT'
      , i_parent_id         => l_contract_block_id
      , i_element_value     => i_perso_rec.bank_account_numer1
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'ACCOUNT'
      , i_parent_id         => l_contract_block_id
      , o_appl_data_id      => l_account_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_account_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'ACCOUNT_NUMBER'
      , i_parent_id         => l_account_block_id
      , i_element_value     => i_perso_rec.bank_account_numer1
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CURRENCY'
      , i_parent_id         => l_account_block_id
      , i_element_value     => i_perso_rec.curr_code
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'ACCOUNT_OBJECT'
      , i_parent_id         => l_account_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'ACCOUNT_OBJECT'
      , i_parent_id         => l_contract_block_id
      , o_appl_data_id      => l_account_obj_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'ACCOUNT_LINK_FLAG'
      , i_parent_id         => l_account_obj_block_id
      , i_element_value     => '1'
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMPANY'
      , i_parent_id         => l_customer_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'COMPANY'
      , i_parent_id         => l_customer_block_id
      , o_appl_data_id      => l_company_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_company_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'EMBOSSED_NAME'
      , i_parent_id         => l_company_block_id
      , i_element_value     => i_perso_rec.corporate_name
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'ADDRESS'
      , i_parent_id         => l_customer_block_id
      , i_element_value     =>''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'ADDRESS'
      , i_parent_id         => l_customer_block_id
      , o_appl_data_id      => l_address_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_address_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'ADDRESS_TYPE'
      , i_parent_id         => l_address_block_id
      , i_element_value     => cst_smt_api_const_pkg.ADDRESS_TYPE_HOME
    );
     app_api_application_pkg.add_element(
        i_element_name      => 'ADDRESS_NAME'
      , i_parent_id         => l_address_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'ADDRESS_NAME'
      , i_parent_id         => l_address_block_id
      , o_appl_data_id      => l_address_name_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CITY'
      , i_parent_id         => l_address_name_block_id
      , i_element_value     => i_perso_rec.city_code
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'STREET'
      , i_parent_id         => l_address_name_block_id
      , i_element_value     =>
            coalesce(
                i_perso_rec.cardholder_address1
              , i_perso_rec.cardholder_address2
              , i_perso_rec.cardholder_address3
            )
    );

    io_appl_id := l_appl_id;
end proc_flow_create_new_cust;

procedure proc_flow_card_reissue(
    i_perso_rec             in      cst_smt_api_type_pkg.t_perso_rec
  , io_appl_id              in out  com_api_type_pkg.t_long_id
) is
    l_template_appl_id          com_api_type_pkg.t_long_id;
    l_sysdate                   date                            := com_api_sttl_day_pkg.get_sysdate;
    l_appl_id                   com_api_type_pkg.t_long_id;
    l_appl_type                 com_api_type_pkg.t_dict_value;
    l_appl_inst_id              com_api_type_pkg.t_inst_id;
    l_appl_agent_id             com_api_type_pkg.t_agent_id;
    l_seqnum                    com_api_type_pkg.t_tiny_id;
    l_application_block_id      com_api_type_pkg.t_long_id;
    l_customer_block_id         com_api_type_pkg.t_long_id;
    l_contract_block_id         com_api_type_pkg.t_long_id;
    l_card_block_id             com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text       => 'START application 5 creation from perso file'
    );

    l_appl_id :=
        com_api_id_pkg.get_id(
            i_seq       => app_application_seq.nextval
          , i_date      => l_sysdate
        );

    trc_log_pkg.debug(
        'new io_appl_id [' || l_appl_id || ']'
    );

    get_flow_template(
        i_flow_id           => cst_smt_api_const_pkg.APP_FLOW_ID_5
      , o_template_appl_id  => l_template_appl_id
      , o_appl_type         => l_appl_type
    );

     l_appl_inst_id := i_perso_rec.bank_id;

     l_appl_agent_id   :=  i_perso_rec.branch_code;

     app_ui_application_pkg.add_application(
         io_appl_id         => l_appl_id
       , o_seqnum           => l_seqnum
       , i_appl_type        => app_api_const_pkg.APPL_TYPE_ISSUING
       , i_appl_number      => null
       , i_flow_id          => cst_smt_api_const_pkg.APP_FLOW_ID_5
       , i_inst_id          => l_appl_inst_id
       , i_agent_id         => l_appl_agent_id
       , i_appl_status      => app_api_const_pkg.APPL_STATUS_PROC_READY
       , i_session_file_id  => null
       , i_file_rec_num     => null
       , i_customer_type    => null
       , i_split_hash       => null
     );

    trc_log_pkg.debug(
        i_text       => 'New l_appl_id [#1]'
      , i_env_param1 => l_appl_id
    );

    app_api_application_pkg.get_appl_data(
        i_appl_id        => l_appl_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'APPLICATION'
      , i_parent_id         => null
      , o_appl_data_id      => l_application_block_id
    );
    -- Add CUSTOMER_TYPE block
    app_api_application_pkg.add_element(
        i_element_name      => 'CUSTOMER_TYPE'
      , i_parent_id         => l_application_block_id
      , i_element_value     => com_api_const_pkg.ENTITY_TYPE_PERSON
    );
     -- Add CUSTOMER block
    app_api_application_pkg.add_element(
        i_element_name      => 'CUSTOMER'
      , i_parent_id         => l_application_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CUSTOMER'
      , i_parent_id         => l_application_block_id
      , o_appl_data_id      => l_customer_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_customer_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
    );
    -- Add CONTRACT block
    app_api_application_pkg.add_element(
        i_element_name      => 'CONTRACT'
      , i_parent_id         => l_customer_block_id
      , i_element_value     =>''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CONTRACT'
      , i_parent_id         => l_customer_block_id
      , o_appl_data_id      => l_contract_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_contract_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CONTRACT_TYPE'
      , i_parent_id         => l_contract_block_id
      , i_element_value     => ''
    );
    -- Add CARD block
    app_api_application_pkg.add_element(
        i_element_name      => 'CARD'
      , i_parent_id         => l_contract_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CARD'
      , i_parent_id         => l_contract_block_id
      , o_appl_data_id      => l_card_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_card_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CARD_NUMBER'
      , i_parent_id         => l_card_block_id
      , i_element_value     => i_perso_rec.card_number
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'EMBOSSING_REQUEST'
      , i_parent_id         => l_card_block_id
      , i_element_value     => iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS

    );
    app_api_application_pkg.add_element(
        i_element_name      => 'PIN_MAILER_REQUEST'
      , i_parent_id         => l_card_block_id
      , i_element_value     => case i_perso_rec.card_process_indicator
                               when 'F' then
                                   iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT
                               else
                                   iss_api_const_pkg.PIN_MAILER_REQUEST_PRINT
                               end
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'REISSUE_COMMAND'
      , i_parent_id         => l_card_block_id
      , i_element_value     => iss_api_const_pkg.REISS_COMMAND_NEW_NUMBER
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CLONE_OPTIONAL_SERVICES'
      , i_parent_id         => l_card_block_id
      , i_element_value     => com_api_const_pkg.TRUE
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'PIN_REQUEST'
      , i_parent_id         => l_card_block_id
      , i_element_value     => case i_perso_rec.card_process_indicator
                               when 'F' then
                                   iss_api_const_pkg.PIN_REQUEST_DONT_GENERATE
                               else
                                   iss_api_const_pkg.PIN_REQUEST_GENERATE
                               end
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'PERSO_PRIORITY'
      , i_parent_id         => l_card_block_id
      , i_element_value     => iss_api_const_pkg.PERSO_PRIORITY_NORMAL
    );

    io_appl_id := l_appl_id;
end proc_flow_card_reissue;


procedure proc_flow_pin_reissue(
    i_perso_rec             in      cst_smt_api_type_pkg.t_perso_rec
  , io_appl_id              in out  com_api_type_pkg.t_long_id
) is
begin
    null;
end proc_flow_pin_reissue;

procedure proc_flow_change_crdh_info(
    i_perso_rec             in      cst_smt_api_type_pkg.t_perso_rec
  , io_appl_id              in out  com_api_type_pkg.t_long_id
) is
    l_template_appl_id          com_api_type_pkg.t_long_id;
    l_sysdate                   date                            := com_api_sttl_day_pkg.get_sysdate;
    l_appl_id                   com_api_type_pkg.t_long_id;
    l_appl_type                 com_api_type_pkg.t_dict_value;
    l_appl_inst_id              com_api_type_pkg.t_inst_id;
    l_appl_agent_id             com_api_type_pkg.t_agent_id;
    l_seqnum                    com_api_type_pkg.t_tiny_id;
    l_application_block_id      com_api_type_pkg.t_long_id;
    l_customer_block_id         com_api_type_pkg.t_long_id;
    l_contract_block_id         com_api_type_pkg.t_long_id;
    l_card_block_id             com_api_type_pkg.t_long_id;
    l_cardholder_block_id       com_api_type_pkg.t_long_id;
    l_person_block_id           com_api_type_pkg.t_long_id;
    l_identity_card_block_id    com_api_type_pkg.t_long_id;
    l_person_name_block_id      com_api_type_pkg.t_long_id;
    l_address_block_id          com_api_type_pkg.t_long_id;
    l_address_name_block_id     com_api_type_pkg.t_long_id;
    l_fexible_field_id          com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text       => 'START application 1013 creation from perso file'
    );

    l_appl_id :=
        com_api_id_pkg.get_id(
            i_seq       => app_application_seq.nextval
          , i_date      => l_sysdate
        );

    trc_log_pkg.debug(
        'new io_appl_id [' || l_appl_id || ']'
    );

    get_flow_template(
        i_flow_id           => cst_smt_api_const_pkg.APP_FLOW_ID_1013
      , o_template_appl_id  => l_template_appl_id
      , o_appl_type         => l_appl_type
    );

    l_appl_inst_id  := i_perso_rec.bank_id;

    l_appl_agent_id :=
        ost_api_institution_pkg.get_default_agent(
            i_inst_id   => l_appl_inst_id
        );

    app_ui_application_pkg.add_application(
        io_appl_id         => l_appl_id
      , o_seqnum           => l_seqnum
      , i_appl_type        => app_api_const_pkg.APPL_TYPE_ISSUING
      , i_appl_number      => null
      , i_flow_id          => cst_smt_api_const_pkg.APP_FLOW_ID_1013
      , i_inst_id          => l_appl_inst_id
      , i_agent_id         => l_appl_agent_id
      , i_appl_status      => app_api_const_pkg.APPL_STATUS_PROC_READY
      , i_session_file_id  => null
      , i_file_rec_num     => null
      , i_customer_type    => null
      , i_split_hash       => null
    );

    trc_log_pkg.debug(
        i_text       => 'New l_appl_id [#1]'
      , i_env_param1 => l_appl_id
    );

    app_api_application_pkg.get_appl_data(
        i_appl_id        => l_appl_id
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'APPLICATION'
      , i_parent_id         => null
      , o_appl_data_id      => l_application_block_id
    );
    -- Add CUSTOMER_TYPE block
    app_api_application_pkg.add_element(
        i_element_name      => 'CUSTOMER_TYPE'
      , i_parent_id         => l_application_block_id
      , i_element_value     =>  app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        );
     -- Add CUSTOMER block
    app_api_application_pkg.add_element(
        i_element_name      => 'CUSTOMER'
      , i_parent_id         => l_application_block_id
      , i_element_value     => ''
        );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CUSTOMER'
      , i_parent_id         => l_application_block_id
      , o_appl_data_id      => l_customer_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_customer_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CUSTOMER_NUMBER'
      , i_parent_id         => l_customer_block_id
      , i_element_value     => ''
    );
    -- CONTRACT block
    app_api_application_pkg.add_element(
        i_element_name      => 'CONTRACT'
      , i_parent_id         => l_customer_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CONTRACT'
      , i_parent_id         => l_customer_block_id
      , o_appl_data_id      => l_contract_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_contract_block_id
      , i_element_value     =>  app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CONTRACT_TYPE'
      , i_parent_id         => l_contract_block_id
      , i_element_value     => ''
    );
    -- CARD block
    app_api_application_pkg.add_element(
        i_element_name      => 'CARD'
      , i_parent_id         => l_contract_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CARD'
      , i_parent_id         => l_contract_block_id
      , o_appl_data_id      => l_card_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_card_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CARD_TYPE'
      , i_parent_id         => l_card_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CARD_NUMBER'
      , i_parent_id         => l_card_block_id
      , i_element_value     => i_perso_rec.card_number
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'EXPIRATION_DATE'
      , i_parent_id         => l_card_block_id
      , i_element_value     => to_char(i_perso_rec.card_expiry_date,'MMYY')
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD'
      , i_parent_id         => l_card_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'FLEXIBLE_FIELD'
      , i_parent_id         => l_card_block_id
      , o_appl_data_id      => l_fexible_field_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_NAME'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => 'CST_TERRITORY_CODE'
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_VALUE'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => i_perso_rec.territiory_code
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'FLEXIBLE_FIELD'
      , i_parent_id         => l_card_block_id
      , o_appl_data_id      => l_fexible_field_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_NAME'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => 'CST_PROCESS_JULIAN_DATE'
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_VALUE'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => to_char(l_sysdate, 'ddmmyyyy')
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'FLEXIBLE_FIELD'
      , i_parent_id         => l_card_block_id
      , o_appl_data_id      => l_fexible_field_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_NAME'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => 'CST_CITY_CODE'
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_VALUE'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => i_perso_rec.city_code
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'FLEXIBLE_FIELD'
      , i_parent_id         => l_card_block_id
      , o_appl_data_id      => l_fexible_field_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_NAME'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => 'CST_CURRENCY_CODE'
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_VALUE'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => i_perso_rec.curr_code
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'FLEXIBLE_FIELD'
      , i_parent_id         => l_card_block_id
      , o_appl_data_id      => l_fexible_field_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_NAME'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => 'CST_ACS_CODE_INDICATOR'
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FLEXIBLE_FIELD_VALUE'
      , i_parent_id         => l_fexible_field_id
      , i_element_value     => i_perso_rec.acs_code_ind
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CARDHOLDER'
      , i_parent_id         => l_card_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CARDHOLDER'
      , i_parent_id         => l_card_block_id
      , o_appl_data_id      => l_cardholder_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_cardholder_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CARDHOLDER_NAME'
      , i_parent_id         => l_cardholder_block_id
      , i_element_value     => i_perso_rec.cardholder_name
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CARDHOLDER_BIRTH_DATE'
      , i_parent_id         => l_cardholder_block_id
      , i_element_value     => i_perso_rec.cardholder_birth_date
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'PERSON'
      , i_parent_id         => l_cardholder_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'PERSON'
      , i_parent_id         => l_cardholder_block_id
      , o_appl_data_id      => l_person_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_person_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'PERSON_NAME'
      , i_parent_id         => l_person_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'PERSON_NAME'
      , i_parent_id         => l_person_block_id
      , o_appl_data_id      => l_person_name_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'SURNAME'
      , i_parent_id         => l_person_name_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'FIRST_NAME'
      , i_parent_id         => l_person_name_block_id
      , i_element_value     => i_perso_rec.cardholder_name
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'IDENTITY_CARD'
      , i_parent_id         => l_person_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'IDENTITY_CARD'
      , i_parent_id         => l_person_block_id
      , o_appl_data_id      => l_identity_card_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_identity_card_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'ID_TYPE'
      , i_parent_id         => l_identity_card_block_id
      , i_element_value     => cst_smt_api_const_pkg.ID_IDENTITY_CARD_TYPE
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'ID_SERIES'
      , i_parent_id         => l_identity_card_block_id
      , i_element_value     => i_perso_rec.id_code
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'ADDRESS'
      , i_parent_id         => l_customer_block_id
      , i_element_value     =>''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'ADDRESS'
      , i_parent_id         => l_customer_block_id
      , o_appl_data_id      => l_address_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_address_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'ADDRESS_TYPE'
      , i_parent_id         => l_address_block_id
      , i_element_value     => cst_smt_api_const_pkg.ADDRESS_TYPE_HOME
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'ADDRESS_NAME'
      , i_parent_id         => l_address_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'ADDRESS_NAME'
      , i_parent_id         => l_address_block_id
      , o_appl_data_id      => l_address_name_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CITY'
      , i_parent_id         => l_address_name_block_id
      , i_element_value     => i_perso_rec.city_code
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'STREET'
      , i_parent_id         => l_address_name_block_id
      , i_element_value     => coalesce(
                                   i_perso_rec.cardholder_address1
                                 , i_perso_rec.cardholder_address2
                                 , i_perso_rec.cardholder_address3
                               )
    );
    io_appl_id := l_appl_id;
end;

procedure proc_flow_change_card_status(
    i_perso_rec             in      cst_smt_api_type_pkg.t_perso_rec
  , io_appl_id              in out  com_api_type_pkg.t_long_id
) is
    l_template_appl_id          com_api_type_pkg.t_long_id;
    l_sysdate                   date                            := com_api_sttl_day_pkg.get_sysdate;
    l_appl_id                   com_api_type_pkg.t_long_id;
    l_appl_type                 com_api_type_pkg.t_dict_value;
    l_appl_inst_id              com_api_type_pkg.t_inst_id;
    l_appl_agent_id             com_api_type_pkg.t_agent_id;
    l_seqnum                    com_api_type_pkg.t_tiny_id;
    l_application_block_id      com_api_type_pkg.t_long_id;
    l_customer_block_id         com_api_type_pkg.t_long_id;
    l_contract_block_id         com_api_type_pkg.t_long_id;
    l_card_block_id             com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text       => 'START application 1012 creation from perso file'
    );

    l_appl_id :=
        com_api_id_pkg.get_id(
            i_seq       => app_application_seq.nextval
          , i_date      => l_sysdate
        );

    trc_log_pkg.debug(
        'new io_appl_id [' || l_appl_id || ']'
    );

    get_flow_template(
        i_flow_id           => cst_smt_api_const_pkg.APP_FLOW_ID_1012
      , o_template_appl_id  => l_template_appl_id
      , o_appl_type         => l_appl_type
    );

    l_appl_inst_id  := i_perso_rec.bank_id;

    l_appl_agent_id :=
        ost_api_institution_pkg.get_default_agent(
            i_inst_id   => l_appl_inst_id
        );

    app_ui_application_pkg.add_application(
        io_appl_id         => l_appl_id
      , o_seqnum           => l_seqnum
      , i_appl_type        => app_api_const_pkg.APPL_TYPE_ISSUING
      , i_appl_number      => null
      , i_flow_id          => cst_smt_api_const_pkg.APP_FLOW_ID_1012
      , i_inst_id          => l_appl_inst_id
      , i_agent_id         => l_appl_agent_id
      , i_appl_status      => app_api_const_pkg.APPL_STATUS_PROC_READY
      , i_session_file_id  => null
      , i_file_rec_num     => null
      , i_customer_type    => null
      , i_split_hash       => null
    );

    trc_log_pkg.debug(
        i_text       => 'New l_appl_id [#1]'
      , i_env_param1 => l_appl_id
    );

    app_api_application_pkg.get_appl_data(
        i_appl_id           => l_appl_id
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'APPLICATION'
      , i_parent_id         => null
      , o_appl_data_id      => l_application_block_id
    );
    -- CUSTOMER_TYPE block
    app_api_application_pkg.add_element(
        i_element_name      => 'CUSTOMER_TYPE'
      , i_parent_id         => l_application_block_id
      , i_element_value     => com_api_const_pkg.ENTITY_TYPE_PERSON
        );
    -- CUSTOMER block
    app_api_application_pkg.add_element(
        i_element_name      => 'CUSTOMER'
      , i_parent_id         => l_application_block_id
      , i_element_value     => ''
        );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CUSTOMER'
      , i_parent_id         => l_application_block_id
      , o_appl_data_id      => l_customer_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_customer_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
    );
    -- CONTRACT block
    app_api_application_pkg.add_element(
        i_element_name      => 'CONTRACT'
      , i_parent_id         => l_customer_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CONTRACT'
      , i_parent_id         => l_customer_block_id
      , o_appl_data_id      => l_contract_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_contract_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CONTRACT_TYPE'
      , i_parent_id         => l_contract_block_id
      , i_element_value     => ''
    );
    -- CARD block
    app_api_application_pkg.add_element(
        i_element_name      => 'CARD'
      , i_parent_id         => l_contract_block_id
      , i_element_value     => ''
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CARD'
      , i_parent_id         => l_contract_block_id
      , o_appl_data_id      => l_card_block_id
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'COMMAND'
      , i_parent_id         => l_card_block_id
      , i_element_value     => app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CARD_NUMBER'
      , i_parent_id         => l_card_block_id
      , i_element_value     => i_perso_rec.card_number
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'EXPIRATION_DATE'
      , i_parent_id         => l_card_block_id
      , i_element_value     => to_date(i_perso_rec.card_expiry_date,'MMYY')
    );
    app_api_application_pkg.add_element(
        i_element_name      => 'CARD_STATUS'
      , i_parent_id         => l_card_block_id
      , i_element_value     => ''
    );
    io_appl_id := l_appl_id;
end;

procedure process_record(
    i_rec                   in      com_api_type_pkg.t_text
  , i_row_number            in      com_api_type_pkg.t_count
  , i_incom_sess_file_id    in      com_api_type_pkg.t_long_id
  , o_processed                 out com_api_type_pkg.t_boolean
  , o_excepted                  out com_api_type_pkg.t_boolean
)
is
    LOG_PREFIX    constant com_api_type_pkg.t_name              := lower($$PLSQL_UNIT) || '.process_record: ';
    l_perso_rec            cst_smt_api_type_pkg.t_perso_rec;
    l_appl_id              com_api_type_pkg.t_long_id;
begin
    l_perso_rec.header_rec                 := substr(i_rec, 1, 4);
    l_perso_rec.card_number                := substr(i_rec, 5, 19);
    l_perso_rec.update_code                := substr(i_rec, 24, 1);
    l_perso_rec.product_type               := substr(i_rec, 25, 2);
    l_perso_rec.cardholder_name            := substr(i_rec, 27, 26);
    l_perso_rec.corporate_name             := substr(i_rec, 79, 26);
    l_perso_rec.cardholder_address1        := substr(i_rec, 105, 32);
    l_perso_rec.cardholder_address2        := substr(i_rec, 137, 32);
    l_perso_rec.cardholder_address3        := substr(i_rec, 169, 32);
    l_perso_rec.postal_code                := substr(i_rec, 201, 9);
    l_perso_rec.correspondent_city         := substr(i_rec, 210, 26);
    l_perso_rec.bank_account_numer1        := substr(i_rec, 236, 24);
    l_perso_rec.bank_account_numer2        := substr(i_rec, 260, 24);
    l_perso_rec.branch_code                := substr(i_rec, 284, 5);
    l_perso_rec.card_begin_date            := to_date(trim(substr(i_rec, 289, 4)),'MMYY');
    l_perso_rec.card_expiry_date           := to_date(trim(substr(i_rec, 293, 4)),'MMYY');
    l_perso_rec.card_process_indicator     := substr(i_rec, 297, 1);
    l_perso_rec.territiory_code            := substr(i_rec, 342, 1);
    l_perso_rec.debit_periodicity_code     := substr(i_rec, 343, 1);
    l_perso_rec.manual_auth_call_code      := substr(i_rec, 344, 1);
    l_perso_rec.process_date               := to_date(trim(substr(i_rec, 345, 6)), 'DDMMYYYY');
    l_perso_rec.bank_id                    := substr(i_rec, 351, 5);
    l_perso_rec.cardholder_birth_date      := to_date(trim(substr(i_rec, 356, 8)), 'DDMMYYYY');
    l_perso_rec.country_code               := substr(i_rec, 380, 3);
    l_perso_rec.city_code                  := substr(i_rec, 383, 5);
    l_perso_rec.renew_option               := substr(i_rec, 388, 1);
    l_perso_rec.cardholder_source_code     := substr(i_rec, 415, 1);
    l_perso_rec.primary_card_code          := substr(i_rec, 416, 1);
    l_perso_rec.curr_code                  := substr(i_rec, 441, 3);
    l_perso_rec.card_pki_code_ind          := substr(i_rec, 480, 1);
    l_perso_rec.acs_code_ind               := substr(i_rec, 481, 1);
    l_perso_rec.id_code                    := substr(i_rec, 482, 16);
    l_perso_rec.cardholder_phone_num       := substr(i_rec, 527, 11);
    l_perso_rec.email                      := substr(i_rec, 538, 40);
    l_perso_rec.sms_notify                 := substr(i_rec, 578, 1);
    l_perso_rec.email_notify               := substr(i_rec, 579, 1);

    if l_perso_rec.update_code = '1' and l_perso_rec.card_process_indicator = 'D' then
        proc_flow_create_new_cust(
            i_perso_rec     => l_perso_rec
          , io_appl_id      => l_appl_id
        );
    elsif l_perso_rec.update_code = '1' and l_perso_rec.card_process_indicator = 'F' or
        l_perso_rec.update_code = '2' and l_perso_rec.card_process_indicator = 'D' or
        l_perso_rec.update_code = '2' and l_perso_rec.card_process_indicator = 'F' or
        l_perso_rec.update_code = '4' and l_perso_rec.card_process_indicator = 'D' or
        l_perso_rec.update_code = '4' and l_perso_rec.card_process_indicator = 'F' then

        proc_flow_card_reissue(
            i_perso_rec     => l_perso_rec
          , io_appl_id      => l_appl_id
        );

    elsif l_perso_rec.update_code = '1' and l_perso_rec.card_process_indicator = 'C'or
        l_perso_rec.update_code = '2' and l_perso_rec.card_process_indicator = 'C' or
        l_perso_rec.update_code = '4' and l_perso_rec.card_process_indicator = 'C'
    then
        proc_flow_pin_reissue(
            i_perso_rec     => l_perso_rec
          , io_appl_id      => l_appl_id
        );
    end if;

    if l_perso_rec.update_code = '2' then
        proc_flow_change_crdh_info(
            i_perso_rec     => l_perso_rec
          , io_appl_id      => l_appl_id
        );
    elsif l_perso_rec.update_code = '3' then
        proc_flow_change_card_status(
            i_perso_rec     => l_perso_rec
          , io_appl_id      => l_appl_id
        );
    end if;
    app_ui_application_pkg.process_application(
        i_appl_id   => l_appl_id
    );

    o_excepted  := com_api_const_pkg.FALSE;
    o_processed := com_api_const_pkg.TRUE;

exception
    when others then
        o_excepted  := com_api_const_pkg.TRUE;
        o_processed := com_api_const_pkg.FALSE;

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'Error - ' || sqlerrm || ' - on sess_file_id [#3] row_number [#1] for rec[#2]'
              , i_env_param1 => i_row_number
              , i_env_param2 => i_rec
              , i_env_param3 => i_incom_sess_file_id
            );
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_record;

procedure process_perso_file
is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_perso_file: ';
    l_record_count_all_files      com_api_type_pkg.t_long_id := 0;
    l_record_count                com_api_type_pkg.t_long_id := 0;
    l_record_number               com_api_type_pkg.t_long_id := 0;
    l_rec                         com_api_type_pkg.t_text;
    l_processed                   com_api_type_pkg.t_boolean;
    l_excepted                    com_api_type_pkg.t_boolean;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count_all_files;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count_all_files
    );

    for p in (
        select id session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    )
    loop
        trc_log_pkg.debug(
            i_text => LOG_PREFIX
                || 'processing session_file_id [' || p.session_file_id
                || '], record_count [' || p.record_count
                || '], file_name [' || p.file_name
                || ']'
        );
        begin
            for r in (
                select record_number
                     , raw_data
                     , count(1) over() cnt
                     , row_number() over(order by record_number) rn
                     , row_number() over(order by record_number desc) rn_desc
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            )
            loop
                l_record_number := r.record_number;
                l_rec           := r.raw_data;

                process_record(
                    i_rec                => r.raw_data
                  , i_row_number         => r.rn
                  , i_incom_sess_file_id => p.session_file_id
                  , o_processed          => l_processed
                  , o_excepted           => l_excepted
                );
            end loop;

            prc_api_file_pkg.close_file(
                i_sess_file_id          => p.session_file_id
              , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when com_api_error_pkg.e_application_error then

                l_record_count := l_record_count + p.record_count;

                prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => 0
                );
                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;
end;

end cst_smt_perso_to_svap_pkg;
/
