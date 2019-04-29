create or replace package amx_api_dsp_init_pkg as

procedure init_second_presentment;

procedure init_first_chargeback;

procedure init_final_chargeback;

procedure init_retrieval_request;

procedure init_fulfillment;

procedure init_first_pres_reversal;

end;
/
 