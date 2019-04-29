create or replace package cst_bmed_crd_api_const_pkg as

    MERCHANT_SUBSIDY_FEE_TYPE           constant com_api_type_pkg.t_dict_value := 'FETP0414';
    BANK_SUBSIDY_FEE_TYPE               constant com_api_type_pkg.t_dict_value := 'FETP0415';

    MERCHANT_INTEREST_FEE_TYPE          constant com_api_type_pkg.t_dict_value := 'FETP0417';
    BANK_INTEREST_FEE_TYPE              constant com_api_type_pkg.t_dict_value := 'FETP0416';
end;
/
