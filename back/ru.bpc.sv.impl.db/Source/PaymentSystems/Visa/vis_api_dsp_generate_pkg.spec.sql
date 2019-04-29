create or replace package vis_api_dsp_generate_pkg is

    procedure gen_first_chargeback;

    procedure gen_second_chargeback;

    procedure gen_first_pres_reversal;

    procedure gen_second_pres_reversal;

    procedure gen_second_presentment;

    procedure gen_pres_chargeback_reversal;

    procedure gen_retrieval_request;

    procedure gen_fee_collection;

    procedure gen_funds_disbursement;

    procedure gen_transmit_monetary_credits;

    procedure gen_fraud_reporting;

    procedure gen_vcr_disp_resp_financial;

    procedure gen_vcr_disp_financial;

    procedure gen_vcr_disp_resp_fin_revers;

    procedure gen_vcr_disp_fin_reversal;

    procedure gen_sms_debit_adjustment;
    
    procedure gen_sms_credit_adjustment;

    procedure gen_sms_first_pres_reversal;
    
    procedure gen_sms_second_pres_reversal;

    procedure gen_sms_second_presentment;

    procedure gen_sms_fee_collection;
    
    procedure gen_sms_funds_disbursement;


end;
/
