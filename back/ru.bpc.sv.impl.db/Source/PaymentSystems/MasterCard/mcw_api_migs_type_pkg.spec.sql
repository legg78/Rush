create or replace package mcw_api_migs_type_pkg is
/**********************************************************
 * Types for MasterCard Internet Gateway System <br />
 * <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 13.12.2016 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: MCW_API_MIGS_TYPE_PKG
 * @headcom
 **********************************************************/

subtype t_dcf_record_type      is varchar2(4);
subtype t_dcf_amount           is number(12);
subtype t_dcf_short_date       is varchar2(6);   --yymmdd
subtype t_dcf_year_mon         is varchar2(4);   --yymm
subtype t_dcf_mon_day_time     is varchar2(10);  --mmddhhmiss
subtype t_dcf_date_time        is varchar2(14);  --yyyymmddhhmiss
subtype t_dcf_time_zone        is varchar2(3);   --<sign>nn
subtype t_dcf_mon_day          is varchar2(4);   --mmdd
subtype t_dcf_time             is varchar2(6);   --hhmiss
subtype t_dcf_short_time_24    is varchar2(4);   --hh24mi
subtype t_dcf_merchant_name    is varchar2(22);
subtype t_char                 is varchar2(1);
subtype t_cur_num_code         is number(3);
subtype t_cur_num_char         is varchar2(3);
subtype t_stan_code            is number(6);
subtype t_country_num_code     is number(3);
subtype t_index                is number(12);


type t_position_length_tab is table of com_api_type_pkg.t_byte_id;
type t_place_elements_tab  is table of t_position_length_tab;

type t_6200_not_maestro_rec    is record(
    record_type                    t_dcf_record_type
  , file_name                      varchar2(32)
  , acquirer_ica                   varchar2(6)
  , sttl_date                      t_dcf_short_date
  , detail_rec_size                com_api_type_pkg.t_byte_id
  , reserved                       varchar2(205)
);

type t_6200_maestro_rec        is record(
    record_type                    t_dcf_record_type
  , file_name                      varchar2(32)
  , acquirer_ica                   varchar2(6)
  , sttl_date                      t_dcf_short_date
  , detail_rec_size                com_api_type_pkg.t_byte_id
  , r_t_number                     number(11)
  , processor_id                   number(11)
  , reserved                       varchar2(183)
);

type t_6220_transact_detail_1_rec  is record(
    record_type                        t_dcf_record_type
  , message_type                       varchar2(4)
  , card_number_de2                    com_api_type_pkg.t_card_number
  , processing_code_de3                varchar2(6)
  , amount_transaction_de4             t_dcf_amount
  , amount_settlement_de5              t_dcf_amount
  , amount_billing_de6                 t_dcf_amount
  , transmit_date_time_de7             t_dcf_mon_day_time
  , stan_de11                          t_stan_code
  , transact_date_local_de13           t_dcf_mon_day
  , transact_time_local_de12           t_dcf_time
  , expiration_date_de14               t_dcf_year_mon
  , settlement_date_de15               t_dcf_mon_day
  , merchant_type_de18                 com_api_type_pkg.t_mcc
  , pos_entry_mode_de22                varchar2(3)
  , pos_condition_code_de25            com_api_type_pkg.t_byte_char
  , retrieval_ref_num_de37             varchar2(12)
  , auth_id_response_de38              varchar2(6)
  , response_code_de39                 com_api_type_pkg.t_byte_char
  , terminal_id_de41                   varchar2(8)
  , card_acceptor_id_de42              varchar2(15)
  , e_commerce_sec_lv_de48             number(3)
  , avs_response_de48_sub              t_char
  , cv_result_code_de48_sub            t_char
  , visa_3d_sec_de48_sub               t_char
  , transaction_cur_de49               t_cur_num_code
  , settlement_cur_de50                t_cur_num_code
  , billing_cur_de51                   t_cur_num_code
  , advice_reason_de60                 varchar2(3)
  , reserved_future_1                  t_char
  , pos_cardhld_presence_de61_sub      t_char
  , pos_transact_stat_de61_sub         t_char
  , cardh_activ_term_de61_sub          t_char
  , network_number_de63_sub            varchar2(9)
  , original_stan_de90_sub             t_stan_code
  , original_date_de90_sub             t_dcf_mon_day
  , acq_spec_migs_de120_sub1           varchar2(34)
  , acq_spec_de120_sub2                varchar2(15)
  , card_data_input_de22_sub           t_char
  , cardhld_auth_cpb_de22_sub          t_char
  , card_capture_de22_sub              t_char
  , term_oper_env_de22_sub             t_char
  , cardhld_prst_de22_sub              t_char
  , card_present_de22_sub              t_char
  , card_input_mode_de22_sub           t_char
  , cardhld_auth_met_de22_sub          t_char
  , pin_capture_cpb_de22_sub           t_char
  , reserved_future_2                  t_char
);

type t_6221_transact_detail_2_rec  is record(
    record_type                        t_dcf_record_type
  , merchant_name_de43                 t_dcf_merchant_name
  , merchant_street_de43               varchar2(45)
  , merchant_city_de43                 varchar2(13)
  , merchant_province_code_de120       varchar2(3)
  , merchant_country_code_de61         t_country_num_code
  , merchant_zip_code_de61             com_api_type_pkg.t_postal_code
  , fin_network_code_de63              varchar2(3)
  , transaction_category_de48          t_char
  , merchant_advice_code_de48          com_api_type_pkg.t_byte_char
  , magnetic_stripe_csi_de48           t_char
  , magnetic_stripe_cei_de48           t_char
  , wallet_program_data_de48           varchar2(3)
  , reserved_future                    varchar2(145)
);

type t_6222_mcw_data_rec           is record(
    record_type                        t_dcf_record_type
  , banknet_network_code_de63          varchar2(3)
  , banknet_reference_code_de63        varchar2(6)
  , banknet_date_de15                  t_dcf_mon_day
  , mcw_electronic_ai_de48             t_char
  , payment_transcation_ti_de48        varchar2(3)
  , mcw_travel_ipsipi_de48             t_char
  , mcw_promotion_code_de48            varchar2(6)
  , service_code_de35                  com_api_type_pkg.t_byte_id
  , reserved_future                    varchar2(225)
);

type t_6223_visa_data_rec          is record(
    record_type                        t_dcf_record_type
  , cavv_result_code_de48              t_char
  , card_level_result_de48             com_api_type_pkg.t_byte_char
  , defer_billing_indicator_de48       t_char
  , us_debt_indicator_de48             t_char
  , relat_partis_indic_de48            t_char
  , aci_indicator_de48                 t_char
  , transact_id_de48                   number(15)
  , valid_code_de48                    varchar2(4)
  , card_inquiry_resp_de48             t_char
  , market_spec_data_id_de48           t_char
  , prestig_lodg_program_de48          t_char
  , merchant_verificat_val_de48        varchar2(10)
  , reserved_future                    varchar2(213)
);

type t_6224_amex_data_rec          is record(
    record_type                        t_dcf_record_type
  , transact_id_de48                   varchar2(15)
  , reserved_future                    varchar2(237)
);

type t_6225_emv_data_rec           is record(
    record_type                        t_dcf_record_type
  , pan_sequence_de23                  varchar2(3)
  , card_service_code_de35             varchar2(3)
  , application_crypt_de55             raw(16)
  , crypt_inform_data_de55             raw(2)
  , issuer_app_data_de55               raw(64)
  , unpredictable_num_de55             raw(8)
  , appl_transact_count_de55           raw(4)
  , terminal_verif_res_de55            raw(10)
  , transaction_date_de55              t_dcf_short_date
  , transaction_type_de55              raw(2)
  , amount_authorized_de55             t_dcf_amount
  , transaction_currency_de55          t_cur_num_code
  , appl_interch_prof_de55             raw(4)
  , terminal_country_code_de55         t_country_num_code
  , amount_other_de55                  t_dcf_amount
  , cardholder_verif_met_res_de55      raw(6)
  , terminal_capabilities_de55         raw(6)
  , terminal_type_de55                 raw(2)
  , interface_device_sn_de55           varchar2(8)
  , transact_category_code_de55        t_char
  , dedicated_file_name_de55           raw(32)
  , appl_version_num_de55              raw(4)
  , transact_seq_counter_de55          raw(8)
  , issuer_auth_data_de55              raw(32)
  , reserved_future                    t_char
);

type t_6226_din_discov_data_rec    is record(
    record_type                        t_dcf_record_type
  , e_commerc_paym_indic_de48          t_char
  , cavv_code_de48                     varchar2(4)
  , network_reference_id               varchar2(15)
  , card_data_input_cap_de22           t_char
  , reserved_future                    varchar2(231)
);

type t_6227_dcc_data_rec           is record(
    record_type                        t_dcf_record_type
  , dcc_provider                       varchar2(20)
  , dcc_merchant_id                    varchar2(20)
  , sale_amount                        t_dcf_amount
  , sale_cur_num                       t_cur_num_char
  , sale_cur_alpha                     t_cur_num_char
  , sale_cur_exponent                  number(1)
  , exchange_rate                      number(12, 1)
  , dcc_id                             varchar2(32)
  , dcc_offer_date_time                t_dcf_date_time
  , dcc_offer_timezone                 t_dcf_time_zone
  , dcc_type                           t_char
  , dcc_offer_status                   t_char
  , reserved_future                    varchar2(129)
);

type t_6228_migs_data_rec          is record(
    record_type                        t_dcf_record_type
  , migs_mso_id                        varchar2(40)
  , migs_merchant_id                   varchar2(16)
  , migs_transaction_number            varchar2(40)
  , migs_order_id                      varchar2(21)
  , migs_card_number_token             varchar2(34)
  , migs_merch_transaction_ref         varchar2(40)
  , migs_purchase_id                   varchar2(39)
  , migs_commodity_code                varchar2(4)
  , migs_customer_ref_number           varchar2(17)
  , reserved_future                    t_char
);

type t_6282_migs_customer_data_rec is record(
    record_type                        t_dcf_record_type
  , member_addendum_data_id            com_api_type_pkg.t_byte_id
  , member_addendum_data_len           number(4)
  , member_addendum_data               varchar2(245)
);

type t_6229_airline_data_rec       is record(
    record_type                        t_dcf_record_type
  , passenger_name                     varchar2(49)
  , ticket_number                      varchar2(15)
  , issuing_carrier                    varchar2(4)
  , pnr                                varchar2(6)
  , customer_code                      varchar2(27)
  , issue_date                         t_dcf_short_date
  , travel_agency_code                 varchar2(8)
  , travel_agency_name                 varchar2(40)
  , total_fare                         t_dcf_amount
  , total_taxes                        t_dcf_amount
  , total_fees                         t_dcf_amount
  , number_legs                        com_api_type_pkg.t_byte_id
  , reserved                           varchar2(58)
);

type t_airline_legs_data_rec       is record(
    record_type                        t_dcf_record_type
  , departure_date                     t_dcf_short_date
  , departure_time                     t_dcf_short_time_24
  , origin_airport                     varchar2(5)
  , arrival_date                       t_dcf_short_date
  , arrival_time                       t_dcf_short_time_24
  , destination_airport                varchar2(5)
  , carrier_code                       varchar2(4)
  , service_class                      com_api_type_pkg.t_byte_char
  , stopover_code                      t_char
  , fare_basis_code                    varchar2(15)
  , flight_number                      varchar2(5)
  , conjunction_ticket                 varchar2(15)
  , exchange_ticket                    varchar2(15)
  , coupon_number                      t_char
  , fare                               t_dcf_amount
  , taxes                              t_dcf_amount
  , fees                               t_dcf_amount
  , endorsement_restriction            varchar2(20)
  , reserved                           varchar2(108)
);

type t_6240_not_maestro_rec        is record(
    record_type                        t_dcf_record_type
  , file_name                          varchar2(32)
  , acquirer_ica                       varchar2(6)
  , sttl_date                          t_dcf_short_date
  , number_fin_transact                number(8)
  , reserved                           varchar2(200)
);

type t_6240_maestro_rec            is record(
    record_type                        t_dcf_record_type
  , file_name                          varchar2(32)
  , acquirer_ica                       varchar2(6)
  , sttl_date                          t_dcf_short_date
  , number_fin_transact                number(8)
  , r_t_number                         number(11)
  , processor_id                       number(11)
  , reserved                           varchar2(178)
);

type t_fin_message_detail_rec      is record(
    transact_detail_6220               t_6220_transact_detail_1_rec
  , transact_detail_6221               t_6221_transact_detail_2_rec
  , mastercard_data_6222               t_6222_mcw_data_rec
  , visa_data_6223                     t_6223_visa_data_rec
  , amex_data_6224                     t_6224_amex_data_rec
  , emv_data_6225                      t_6225_emv_data_rec
  , din_discov_data_6226               t_6226_din_discov_data_rec
  , dcc_data_6227                      t_6227_dcc_data_rec
  , migs_data_6228                     t_6228_migs_data_rec
  , migs_customer_data_6282            t_6282_migs_customer_data_rec
  , airline_data_6229                  t_6229_airline_data_rec
  , airline_legs_data_6230             t_airline_legs_data_rec
  , airline_legs_data_6231             t_airline_legs_data_rec
  , airline_legs_data_6232             t_airline_legs_data_rec
  , airline_legs_data_6233             t_airline_legs_data_rec
  , airline_legs_data_6234             t_airline_legs_data_rec
  , airline_legs_data_6235             t_airline_legs_data_rec
  , airline_legs_data_6236             t_airline_legs_data_rec
  , airline_legs_data_6237             t_airline_legs_data_rec
  , airline_legs_data_6238             t_airline_legs_data_rec
  , airline_legs_data_6239             t_airline_legs_data_rec
);

type t_fin_message_detail_tab is table of t_fin_message_detail_rec;

type t_fin_message_compleat_rec    is record(
    incom_sess_file_id                 com_api_type_pkg.t_long_id
  , header_not_maestro                 t_6200_not_maestro_rec
  , header_maestro                     t_6200_maestro_rec
  , fin_message_detail                 t_fin_message_detail_tab
  , trailer_not_maestro                t_6240_not_maestro_rec
  , trailer_maestro                    t_6240_maestro_rec
);

type t_fin_message_compleat_tab is table of t_fin_message_compleat_rec;

end mcw_api_migs_type_pkg;
/
