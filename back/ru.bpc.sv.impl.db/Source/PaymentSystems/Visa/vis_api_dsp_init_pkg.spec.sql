create or replace package vis_api_dsp_init_pkg is

    procedure init_first_chargeback;

    procedure init_second_chargeback;

    procedure init_first_pres_reversal;

    procedure init_second_pres_reversal;

    procedure init_second_presentment;

    procedure init_pres_chargeback_reversal;

    procedure init_retrieval_request;

    procedure init_fee_collection;

    procedure init_funds_disbursement;

    procedure init_fraud_reporting;

    procedure init_vcr_disp_resp_financial;

    procedure init_vcr_disp_financial;

    procedure init_vcr_disp_resp_fin_revers;

    procedure init_vcr_disp_fin_reversal;

    procedure init_sms_first_pres_reversal;
    
    procedure init_sms_second_pres_reversal;
    
    procedure init_sms_second_presentment;
    
    procedure init_sms_fee_collection;
    
    procedure init_sms_funds_disbursement;
    
    procedure init_sms_debit_adjustment;

    procedure init_sms_credit_adjustment;

end;
/
