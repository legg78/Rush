create or replace package cst_bof_ghp_api_dsp_gen_pkg is

procedure first_chargeback;

procedure pres_chargeback_reversal;

procedure second_presentment;

procedure second_chargeback;

procedure second_presentment_reversal;

procedure retrieval_request;

procedure fee_debit_credit;

procedure fraud_reporting;

end;
/
