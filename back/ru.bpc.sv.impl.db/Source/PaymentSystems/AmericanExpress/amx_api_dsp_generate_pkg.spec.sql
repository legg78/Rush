create or replace package amx_api_dsp_generate_pkg as

procedure gen_second_presentment;

procedure gen_first_chargeback;

procedure gen_final_chargeback;

procedure gen_retrieval_request;

procedure gen_fulfillment;

procedure gen_first_presentment_reversal;

end;
/
