create or replace package evt_api_notif_report_data_pkg is
/**********************************************************
 * Generate data for construction send event notification <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 14.10.2016 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate:: $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: EVT_API_NOTIF_REPORT_DATA_PKG
 * @headcom
 **********************************************************/
/**********************************************************
 *
 * Generate output data in xml-format of the account
 * entity for the reports construction
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_account_data(
    i_account_id           in            com_api_type_pkg.t_medium_id
  , i_lang                 in            com_api_type_pkg.t_dict_value default null
  , o_account_report_data  out           xmltype
);

/**********************************************************
 *
 * Generate output data in xml-format of the application 
 * entity for the reports construction 
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_application_data(
    i_appl_id            in            com_api_type_pkg.t_long_id
  , i_lang               in            com_api_type_pkg.t_dict_value default null
  , o_appl_report_data   out           xmltype
);

/**********************************************************
 *
 * Generate output data in xml-format of the credit invoice
 * entity for the reports construction
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_credit_invoice_data(
    i_credit_invoice_id           in            com_api_type_pkg.t_medium_id
  , i_lang                        in            com_api_type_pkg.t_dict_value default null
  , o_credit_invoice_report_data  out           xmltype
);

/**********************************************************
 *
 * Generate output data in xml-format of the card entity 
 * for the reports construction
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_card_data(
    i_card_id            in            com_api_type_pkg.t_medium_id
  , i_lang               in            com_api_type_pkg.t_dict_value default null
  , o_card_report_data   out           xmltype
);

/**********************************************************
 *
 * Generate output data in xml-format of the card instance
 * entity for the reports construction
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_card_instance_data(
    i_card_instance_id       in            com_api_type_pkg.t_medium_id
  , i_lang                   in            com_api_type_pkg.t_dict_value default null
  , o_card_inst_report_data  out           xmltype
);

/**********************************************************
 *
 * Generate output data in xml-format of the merchant 
 * entity for the reports construction
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_merchant_data(
    i_merchant_id            in            com_api_type_pkg.t_short_id
  , i_lang                   in            com_api_type_pkg.t_dict_value default null
  , o_merchant_report_data   out           xmltype
);

/**********************************************************
 *
 * Generate output data in xml-format of the session entity
 * for the reports construction
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_session_data(
    i_session_id            in      com_api_type_pkg.t_medium_id
  , i_lang                  in      com_api_type_pkg.t_dict_value default null
  , o_session_report_data   out     xmltype
);

/**********************************************************
 *
 * Generate output data in xml-format of the settlement
 * entity for the reports construction
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_settlement_data(
    i_sttl_day_id            in            com_api_type_pkg.t_long_id
  , i_lang                   in            com_api_type_pkg.t_dict_value default null
  , o_sttl_day_report_data   out           xmltype
);

/**********************************************************
 *
 * Generate output data in xml-format of the terminal 
 * entity for the reports construction
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_terminal_data(
    i_terminal_id            in            com_api_type_pkg.t_short_id
  , i_lang                   in            com_api_type_pkg.t_dict_value default null
  , o_terminal_report_data   out           xmltype
);

/**********************************************************
 *
 * Generate output data in xml-format of the operation  
 * (card-account) entity for the reports construction
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_oper_acc_iss_data(
    i_operation_id           in            com_api_type_pkg.t_long_id
  , i_lang                   in            com_api_type_pkg.t_dict_value default null
  , o_operation_acc_iss_data out           xmltype
);

/**********************************************************
 *
 * Generate xml with bonus creation/spending information
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_bonus_data(
    i_macros_id    in    com_api_type_pkg.t_short_id
  , i_lang         in    com_api_type_pkg.t_dict_value default null
  , o_report_xml   out   xmltype
);

/**********************************************************
 *
 * Generate xml with service terms information
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_service_terms_data(
    i_entity_type     in    com_api_type_pkg.t_dict_value
  , i_object_id       in    com_api_type_pkg.t_long_id
  , o_serv_terms_xml  out   xmltype
);

/**********************************************************
 *
 * Generate xml with account linked merchants information
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_account_merchant_data(
    i_account_id              in    com_api_type_pkg.t_medium_id
  , i_lang                    in    com_api_type_pkg.t_dict_value default null
  , o_account_merchants_xml   out   xmltype
);

/**********************************************************
 *
 * Generate xml with account complex information
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_account_complex_data(
    i_account_id              in    com_api_type_pkg.t_medium_id
  , i_lang                    in    com_api_type_pkg.t_dict_value default null
  , o_account_complex_xml   out   xmltype
);

/**********************************************************
 *
 * Generate xml with contact data information
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_contact_data(
    i_contact_data_id         in    com_api_type_pkg.t_medium_id
  , i_lang                    in    com_api_type_pkg.t_dict_value default null
  , o_contact_data_xml        out   xmltype
);

/**********************************************************
 *
 * Generate xml with identificational data information
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_identifier_data(
    i_identifier_object_id    in    com_api_type_pkg.t_medium_id
  , i_lang                    in    com_api_type_pkg.t_dict_value default null
  , o_identifier_data_xml     out   xmltype
);

/**********************************************************
 *
 * Generate xml with address data information
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_address_data(
    i_address_id              in    com_api_type_pkg.t_medium_id
  , i_lang                    in    com_api_type_pkg.t_dict_value default null
  , o_address_data_xml        out   xmltype
);

end evt_api_notif_report_data_pkg;
/
