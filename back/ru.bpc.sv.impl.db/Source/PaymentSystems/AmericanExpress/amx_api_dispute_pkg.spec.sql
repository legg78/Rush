create or replace package amx_api_dispute_pkg as

procedure fetch_dispute_id (
    i_fin_cur                 in     sys_refcursor
  , o_fin_rec                    out amx_api_type_pkg.t_amx_fin_mes_rec
);

procedure assign_dispute(
    io_amx_fin_rec            in out nocopy amx_api_type_pkg.t_amx_fin_mes_rec    
  , o_auth                       out aut_api_type_pkg.t_auth_rec
);

procedure gen_first_presentment_rvs(
    o_fin_id                     out com_api_type_pkg.t_long_id
  , i_original_fin_id         in     com_api_type_pkg.t_long_id
  , i_trans_amount            in     com_api_type_pkg.t_money         default null
  , i_trans_currency          in     com_api_type_pkg.t_curr_code     default null
);

procedure gen_second_presentment (
    o_fin_id                     out com_api_type_pkg.t_long_id
  , i_original_fin_id         in     com_api_type_pkg.t_long_id
  , i_trans_amount            in     com_api_type_pkg.t_money         default null
  , i_trans_currency          in     com_api_type_pkg.t_curr_code     default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_itemized_doc_code       in     com_api_type_pkg.t_byte_char     default null
  , i_itemized_doc_ref_number in     com_api_type_pkg.t_name          default null
);

procedure gen_first_chargeback (
    o_fin_id                     out com_api_type_pkg.t_long_id
  , i_original_fin_id         in     com_api_type_pkg.t_long_id
  , i_func_code               in     com_api_type_pkg.t_curr_code 
  , i_trans_amount            in     com_api_type_pkg.t_money         default null
  , i_trans_currency          in     com_api_type_pkg.t_curr_code     default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_chbck_reason_text       in     com_api_type_pkg.t_name          default null
);

procedure gen_retrieval_request (
    o_fin_id                     out com_api_type_pkg.t_long_id
  , i_original_fin_id         in     com_api_type_pkg.t_long_id
  , i_func_code               in     com_api_type_pkg.t_name          default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_chbck_reason_code       in     com_api_type_pkg.t_name          default null
  , i_itemized_doc_code       in     com_api_type_pkg.t_name          default null
);

procedure gen_fulfillment (
    o_fin_id                     out com_api_type_pkg.t_long_id
  , i_original_fin_id         in     com_api_type_pkg.t_long_id
  , i_func_code               in     com_api_type_pkg.t_name          default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_itemized_doc_code       in     com_api_type_pkg.t_name          default null
  , i_itemized_doc_ref_number in     com_api_type_pkg.t_name          default null
);

procedure modify_first_chargeback (
    i_fin_id                  in     com_api_type_pkg.t_long_id
  , i_func_code               in     com_api_type_pkg.t_curr_code     default null
  , i_trans_amount            in     com_api_type_pkg.t_money         default null
  , i_trans_currency          in     com_api_type_pkg.t_curr_code     default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_chbck_reason_text       in     com_api_type_pkg.t_name          default null
);

procedure modify_second_presentment (
    i_fin_id                  in     com_api_type_pkg.t_long_id
  , i_trans_amount            in     com_api_type_pkg.t_money         default null
  , i_trans_currency          in     com_api_type_pkg.t_curr_code     default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_itemized_doc_code       in     com_api_type_pkg.t_byte_char     default null
  , i_itemized_doc_ref_number in     com_api_type_pkg.t_name          default null
);

procedure modify_retrieval_request (
    i_fin_id                  in     com_api_type_pkg.t_long_id
  , i_func_code               in     com_api_type_pkg.t_curr_code     default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_chbck_reason_code       in     com_api_type_pkg.t_name          default null
  , i_itemized_doc_code       in     com_api_type_pkg.t_byte_char     default null
);

procedure modify_fulfillment (
    i_fin_id                  in     com_api_type_pkg.t_long_id
  , i_func_code               in     com_api_type_pkg.t_curr_code     default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_itemized_doc_code       in     com_api_type_pkg.t_byte_char     default null
  , i_itemized_doc_ref_number in     com_api_type_pkg.t_name          default null
);

procedure modify_first_presentment_rvs(
    i_fin_id                  in     com_api_type_pkg.t_long_id
  , i_trans_amount            in     com_api_type_pkg.t_money         default null
  , i_trans_currency          in     com_api_type_pkg.t_curr_code     default null
);

end;
/
