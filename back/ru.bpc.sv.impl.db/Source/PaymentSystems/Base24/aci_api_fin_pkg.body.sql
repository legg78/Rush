create or replace package body aci_api_fin_pkg is
/************************************************************
 * API for Base24 finans message <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 22.01.2014 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: aci_api_fin_pkg <br />
 * @headcom
 ************************************************************/
 
    procedure set_message_atm (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , o_mes_rec             out aci_api_type_pkg.t_atm_fin_rec
    ) is
        l_stage                 com_api_type_pkg.t_name;
    begin
        l_stage := 'headx_dat_tim';
        o_mes_rec.headx_dat_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 1
            , i_length     => 19
        );
        l_stage := 'headx_rec_typ';
        o_mes_rec.headx_rec_typ := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 20
            , i_length     => 2
        );
        l_stage := 'headx_auth_ppd';
        o_mes_rec.headx_auth_ppd := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 22
            , i_length     => 4
        );
        l_stage := 'headx_term_ln';
        o_mes_rec.headx_term_ln := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 26
            , i_length     => 4
        );
        l_stage := 'headx_term_fiid';
        o_mes_rec.headx_term_fiid := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 30
            , i_length     => 4
        );
        l_stage := 'headx_term_term_id';
        o_mes_rec.headx_term_term_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 34
            , i_length     => 16
        );
        l_stage := 'headx_crd_ln';
        o_mes_rec.headx_crd_ln := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 50
            , i_length     => 4
        );
        l_stage := 'headx_crd_fiid';
        o_mes_rec.headx_crd_fiid := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 54
            , i_length     => 4
        );
        l_stage := 'headx_crd_pan';
        o_mes_rec.headx_crd_pan := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 58
            , i_length     => 19
        );
        l_stage := 'headx_crd_mbr_num';
        o_mes_rec.headx_crd_mbr_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 77
            , i_length     => 3
        );
        l_stage := 'headx_branch_id';
        o_mes_rec.headx_branch_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 80
            , i_length     => 4
        );
        l_stage := 'headx_region_id';
        o_mes_rec.headx_region_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 84
            , i_length     => 4
        );
        
        -- auth
        l_stage := 'authx_type_cde';
        o_mes_rec.authx_type_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 90
            , i_length     => 2
        );
        l_stage := 'authx_type';
        o_mes_rec.authx_type := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 92
            , i_length     => 4
        );
        l_stage := 'authx_rte_stat';
        o_mes_rec.authx_rte_stat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 95
            , i_length     => 2
        );
        l_stage := 'authx_originator';
        o_mes_rec.authx_originator := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 98
            , i_length     => 1
        );
        l_stage := 'authx_responder';
        o_mes_rec.authx_responder := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 99
            , i_length     => 1
        );
        l_stage := 'authx_entry_time';
        o_mes_rec.authx_entry_time := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 100
            , i_length     => 19
        );
        l_stage := 'authx_exit_time';
        o_mes_rec.authx_exit_time := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 119
            , i_length     => 19
        );
        l_stage := 'authx_re_entry_tim';
        o_mes_rec.authx_re_entry_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 138
            , i_length     => 19
        );
        l_stage := 'authx_tran_date';
        o_mes_rec.authx_tran_date := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 157
            , i_length     => 6
        );
        l_stage := 'authx_tran_time';
        o_mes_rec.authx_tran_time := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 163
            , i_length     => 8
        );
        l_stage := 'authx_post_date';
        o_mes_rec.authx_post_date := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 171
            , i_length     => 6
        );
        l_stage := 'authx_acq_ichg_setl_date';
        o_mes_rec.authx_acq_ichg_setl_date := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 177
            , i_length     => 6
        );
        l_stage := 'authx_iss_ichg_setl_date';
        o_mes_rec.authx_iss_ichg_setl_date := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 183
            , i_length     => 6
        );
        l_stage := 'authx_seq_num';
        o_mes_rec.authx_seq_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 189
            , i_length     => 12
        );
        l_stage := 'authx_term_typ';
        o_mes_rec.authx_term_typ := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 201
            , i_length     => 2
        );
        l_stage := 'authx_tim_ofst';
        o_mes_rec.authx_tim_ofst := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 203
            , i_length     => 5
        );
        l_stage := 'authx_acq_inst_id';
        o_mes_rec.authx_acq_inst_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 208
            , i_length     => 11
        );
        l_stage := 'authx_rcv_inst_id';
        o_mes_rec.authx_rcv_inst_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 219
            , i_length     => 11
        );
        l_stage := 'authx_tran_cde';
        o_mes_rec.authx_tran_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 230
            , i_length     => 6
        );
        l_stage := 'authx_from_acct';
        o_mes_rec.authx_from_acct := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 236
            , i_length     => 19
        );
        l_stage := 'authx_to_acct';
        o_mes_rec.authx_to_acct := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 256
            , i_length     => 19
        );
        l_stage := 'authx_mult_acct';
        o_mes_rec.authx_mult_acct := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 275
            , i_length     => 1
        );
        l_stage := 'authx_amt_1';
        o_mes_rec.authx_amt_1 := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 276
            , i_length     => 19
        );
        l_stage := 'authx_amt_2';
        o_mes_rec.authx_amt_2 := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 295
            , i_length     => 19
        );
        l_stage := 'authx_amt_3';
        o_mes_rec.authx_amt_3 := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 314
            , i_length     => 19
        );
        l_stage := 'authx_dep_bal_cr';
        o_mes_rec.authx_dep_bal_cr := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 333
            , i_length     => 10
        );
        l_stage := 'authx_dep_typ';
        o_mes_rec.authx_dep_typ := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 343
            , i_length     => 1
        );
        l_stage := 'authx_resp_cde';
        o_mes_rec.authx_resp_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 344
            , i_length     => 3
        );
        l_stage := 'authx_term_name_loc';
        o_mes_rec.authx_term_name_loc := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 347
            , i_length     => 25
        );
        l_stage := 'authx_term_owner_name';
        o_mes_rec.authx_term_owner_name := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 372
            , i_length     => 22
        );
        l_stage := 'authx_term_city';
        o_mes_rec.authx_term_city := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 394
            , i_length     => 13
        );
        l_stage := 'authx_term_st';
        o_mes_rec.authx_term_st := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 407
            , i_length     => 3
        );
        l_stage := 'authx_term_cntry';
        o_mes_rec.authx_term_cntry := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 410
            , i_length     => 2
        );
        l_stage := 'authx_orig_oseq_num';
        o_mes_rec.authx_orig_oseq_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 412
            , i_length     => 12
        );
        l_stage := 'authx_orig_otran_dat';
        o_mes_rec.authx_orig_otran_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 424
            , i_length     => 4
        );
        l_stage := 'authx_orig_otran_tim';
        o_mes_rec.authx_orig_otran_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 428
            , i_length     => 8
        );
        l_stage := 'authx_orig_b24_post_dat';
        o_mes_rec.authx_orig_b24_post_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 436
            , i_length     => 4
        );
        l_stage := 'authx_orig_crncy_cde';
        o_mes_rec.authx_orig_crncy_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 440
            , i_length     => 3
        );
        l_stage := 'authx_mult_crncy_auth_crncy_cd';
        o_mes_rec.authx_mult_crncy_auth_crncy_cd := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 443
            , i_length     => 3
        );
        l_stage := 'authx_mult_crncy_auth_conv_rat';
        o_mes_rec.authx_mult_crncy_auth_conv_rat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 446
            , i_length     => 8
        );
        l_stage := 'authx_mult_crncy_setl_crncy_cd';
        o_mes_rec.authx_mult_crncy_setl_crncy_cd := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 454
            , i_length     => 3
        );
        l_stage := 'authx_mult_crncy_conv_dat_tim';
        o_mes_rec.authx_mult_crncy_conv_dat_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 465
            , i_length     => 19
        );
        l_stage := 'authx_rvsl_rsn';
        o_mes_rec.authx_rvsl_rsn := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 484
            , i_length     => 2
        );
        l_stage := 'authx_pin_ofst';
        o_mes_rec.authx_pin_ofst := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 486
            , i_length     => 16
        );
        l_stage := 'authx_shrg_grp';
        o_mes_rec.authx_shrg_grp := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 502
            , i_length     => 1
        );
        l_stage := 'authx_dest_order';
        o_mes_rec.authx_dest_order := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 503
            , i_length     => 1
        );
        l_stage := 'authx_auth_id_resp';
        o_mes_rec.authx_auth_id_resp := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 504
            , i_length     => 6
        );
        l_stage := 'authx_refr_imp_ind';
        o_mes_rec.authx_refr_imp_ind := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 510
            , i_length     => 1
        );
        l_stage := 'authx_refr_avail_imp';
        o_mes_rec.authx_refr_avail_imp := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 511
            , i_length     => 2
        );
        l_stage := 'authx_refr_ledg_imp';
        o_mes_rec.authx_refr_ledg_imp := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 513
            , i_length     => 2
        );
        l_stage := 'authx_refr_hld_amt_imp';
        o_mes_rec.authx_refr_hld_amt_imp := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 515
            , i_length     => 2
        );
        l_stage := 'authx_refr_caf_refr_ind';
        o_mes_rec.authx_refr_caf_refr_ind := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 517
            , i_length     => 1
        );
        l_stage := 'authx_dep_setl_imp_flg';
        o_mes_rec.authx_dep_setl_imp_flg := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 519
            , i_length     => 1
        );
        l_stage := 'authx_adj_setl_imp_flg';
        o_mes_rec.authx_adj_setl_imp_flg := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 520
            , i_length     => 1
        );
        l_stage := 'authx_refr_ind';
        o_mes_rec.authx_refr_ind := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 521
            , i_length     => 4
        );
        l_stage := 'authx_frwd_inst_id_num';
        o_mes_rec.authx_frwd_inst_id_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 541
            , i_length     => 11
        );
        l_stage := 'authx_crd_accpt_id_num';
        o_mes_rec.authx_crd_accpt_id_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 552
            , i_length     => 11
        );
        l_stage := 'authx_crd_iss_id_num';
        o_mes_rec.authx_crd_iss_id_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 563
            , i_length     => 11
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error processing ATM customer transaction on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            --dbms_output.put_line(substr(i_raw_data, 1, 575));
            raise;
    end;
    
    procedure set_message_pos (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , o_mes_rec             out aci_api_type_pkg.t_pos_fin_rec
    ) is
        l_stage                 com_api_type_pkg.t_name;
    begin
        l_stage := 'headx_dat_tim';
        o_mes_rec.headx_dat_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 1
            , i_length     => 19
        );
        l_stage := 'headx_rec_typ';
        o_mes_rec.headx_rec_typ := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 20
            , i_length     => 2
        );
        l_stage := 'headx_crd_ln';
        o_mes_rec.headx_crd_ln := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 22
            , i_length     => 4
        );
        l_stage := 'headx_crd_fiid';
        o_mes_rec.headx_crd_fiid := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 26
            , i_length     => 4
        );
        l_stage := 'headx_crd_card_crd_num';
        o_mes_rec.headx_crd_card_crd_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 30
            , i_length     => 19
        );
        l_stage := 'headx_crd_card_mbr_num';
        o_mes_rec.headx_crd_card_mbr_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 49
            , i_length     => 3
        );
        l_stage := 'headx_retl_ky_ln';
        o_mes_rec.headx_retl_ky_ln := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 52
            , i_length     => 4
        );
        l_stage := 'headx_retl_ky_rdfkey_fiid';
        o_mes_rec.headx_retl_ky_rdfkey_fiid := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 56
            , i_length     => 4
        );
        l_stage := 'headx_retl_ky_rdfkey_grp';
        o_mes_rec.headx_retl_ky_rdfkey_grp := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 60
            , i_length     => 4
        );
        l_stage := 'headx_retl_ky_rdfkey_regn';
        o_mes_rec.headx_retl_ky_rdfkey_regn := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 64
            , i_length     => 4
        );
        l_stage := 'headx_retl_ky_rdfkey_id';
        o_mes_rec.headx_retl_ky_rdfkey_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 68
            , i_length     => 19
        );
        l_stage := 'headx_retl_term_id';
        o_mes_rec.headx_retl_term_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 87
            , i_length     => 16
        );
        l_stage := 'headx_retl_shift_num';
        o_mes_rec.headx_retl_shift_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 103
            , i_length     => 3
        );
        l_stage := 'headx_retl_batch_num';
        o_mes_rec.headx_retl_batch_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 106
            , i_length     => 3
        );
        l_stage := 'headx_term_ln';
        o_mes_rec.headx_term_ln := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 109
            , i_length     => 4
        );
        l_stage := 'headx_term_fiid';
        o_mes_rec.headx_term_fiid := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 113
            , i_length     => 4
        );
        l_stage := 'headx_term_term_id';
        o_mes_rec.headx_term_term_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 117
            , i_length     => 16
        );
        l_stage := 'headx_term_tim';
        o_mes_rec.headx_term_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 133
            , i_length     => 8
        );
        l_stage := 'headx_tkey_term_id';
        o_mes_rec.headx_tkey_term_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 141
            , i_length     => 16
        );
        l_stage := 'headx_tkey_rkey_rec_frmt';
        o_mes_rec.headx_tkey_rkey_rec_frmt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 157
            , i_length     => 1
        );
        l_stage := 'headx_tkey_rkey_retailer_id';
        o_mes_rec.headx_tkey_rkey_retailer_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 158
            , i_length     => 19
        );
        l_stage := 'headx_tkey_rkey_clerk_id';
        o_mes_rec.headx_tkey_rkey_clerk_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 177
            , i_length     => 6
        );
        l_stage := 'headx_data_flag';
        o_mes_rec.headx_data_flag := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 183
            , i_length     => 1
        );
            
        -- auth
        l_stage := 'authx_typ';
        o_mes_rec.authx_typ := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 184
            , i_length     => 4
        );
        l_stage := 'authx_rte_stat';
        o_mes_rec.authx_rte_stat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 188
            , i_length     => 2
        );
        l_stage := 'authx_originator';
        o_mes_rec.authx_originator := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 190
            , i_length     => 1
        );
        l_stage := 'authx_responder';
        o_mes_rec.authx_responder := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 191
            , i_length     => 1
        );
        l_stage := 'authx_iss_cde';
        o_mes_rec.authx_iss_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 192
            , i_length     => 2
        );
        l_stage := 'authx_entry_tim';
        o_mes_rec.authx_entry_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 194
            , i_length     => 19
        );
        l_stage := 'authx_exit_tim';
        o_mes_rec.authx_exit_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 213
            , i_length     => 19
        );
        l_stage := 'authx_re_entry_tim';
        o_mes_rec.authx_re_entry_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 232
            , i_length     => 19
        );
        l_stage := 'authx_tran_dat';
        o_mes_rec.authx_tran_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 251
            , i_length     => 6
        );
        l_stage := 'authx_tran_tim';
        o_mes_rec.authx_tran_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 257
            , i_length     => 8
        );
        l_stage := 'authx_post_dat';
        o_mes_rec.authx_post_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 265
            , i_length     => 6
        );
        l_stage := 'authx_acq_ichg_setl_dat';
        o_mes_rec.authx_acq_ichg_setl_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 271
            , i_length     => 6
        );
        l_stage := 'authx_iss_ichg_setl_dat';
        o_mes_rec.authx_iss_ichg_setl_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 277
            , i_length     => 6
        );
        l_stage := 'authx_seq_num';
        o_mes_rec.authx_seq_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 283
            , i_length     => 12
        );
        l_stage := 'authx_term_name_loc';
        o_mes_rec.authx_term_name_loc := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 295
            , i_length     => 25
        );
        l_stage := 'authx_term_owner_name';
        o_mes_rec.authx_term_owner_name := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 320
            , i_length     => 22
        );
        l_stage := 'authx_term_city';
        o_mes_rec.authx_term_city := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 342
            , i_length     => 13
        );
        l_stage := 'authx_term_st';
        o_mes_rec.authx_term_st := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 355
            , i_length     => 3
        );
        l_stage := 'authx_term_cntry_cde';
        o_mes_rec.authx_term_cntry_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 358
            , i_length     => 2
        );
        l_stage := 'authx_term_tim_ofst';
        o_mes_rec.authx_term_tim_ofst := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 367
            , i_length     => 5
        );
        l_stage := 'authx_acq_inst_id_num';
        o_mes_rec.authx_acq_inst_id_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 372
            , i_length     => 11
        );
        l_stage := 'authx_rcv_inst_id_num';
        o_mes_rec.authx_rcv_inst_id_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 383
            , i_length     => 11
        );
        l_stage := 'authx_term_typ';
        o_mes_rec.authx_term_typ := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 394
            , i_length     => 2
        );
        l_stage := 'authx_clerk_id';
        o_mes_rec.authx_clerk_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 396
            , i_length     => 6
        );
        l_stage := 'authx_crt_auth_grp';
        o_mes_rec.authx_crt_auth_grp := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 402
            , i_length     => 4
        );
        l_stage := 'authx_crt_auth_user_id';
        o_mes_rec.authx_crt_auth_user_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 406
            , i_length     => 8
        );
        l_stage := 'authx_retl_sic_cde';
        o_mes_rec.authx_retl_sic_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 414
            , i_length     => 4
        );
        l_stage := 'authx_orig';
        o_mes_rec.authx_orig := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 418
            , i_length     => 4
        );
        l_stage := 'authx_dest';
        o_mes_rec.authx_dest := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 422
            , i_length     => 4
        );
        l_stage := 'authx_tran_cde';
        o_mes_rec.authx_tran_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 426
            , i_length     => 6
        );
        l_stage := 'authx_crd_typ';
        o_mes_rec.authx_crd_typ := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 432
            , i_length     => 2
        );
        l_stage := 'authx_acct';
        o_mes_rec.authx_acct := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 434
            , i_length     => 2
        );
        l_stage := 'authx_resp_cde';
        o_mes_rec.authx_resp_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 453
            , i_length     => 3
        );
        l_stage := 'authx_amt_1';
        o_mes_rec.authx_amt_1 := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 456
            , i_length     => 19
        );
        l_stage := 'authx_amt_2';
        o_mes_rec.authx_amt_2 := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 475
            , i_length     => 19
        );
        l_stage := 'authx_exp_dat';
        o_mes_rec.authx_exp_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 494
            , i_length     => 4
        );
        l_stage := 'authx_track2';
        o_mes_rec.authx_track2 := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 498
            , i_length     => 40
        );
        l_stage := 'authx_pin_ofst';
        o_mes_rec.authx_pin_ofst := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 538
            , i_length     => 16
        );
        l_stage := 'authx_pre_auth_seq_num';
        o_mes_rec.authx_pre_auth_seq_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 554
            , i_length     => 12
        );
        l_stage := 'authx_invoice_num';
        o_mes_rec.authx_invoice_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 566
            , i_length     => 10
        );
        l_stage := 'authx_orig_invoice_num';
        o_mes_rec.authx_orig_invoice_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 576
            , i_length     => 10
        );
        l_stage := 'authx_authorizer';
        o_mes_rec.authx_authorizer := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 586
            , i_length     => 16
        );
        l_stage := 'authx_auth_ind';
        o_mes_rec.authx_auth_ind := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 602
            , i_length     => 1
        );
        l_stage := 'authx_shift_num';
        o_mes_rec.authx_shift_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 603
            , i_length     => 3
        );
        l_stage := 'authx_batch_seq_num';
        o_mes_rec.authx_batch_seq_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 606
            , i_length     => 3
        );
        l_stage := 'authx_apprv_cde';
        o_mes_rec.authx_apprv_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 609
            , i_length     => 8
        );
        l_stage := 'authx_apprv_cde_lgth';
        o_mes_rec.authx_apprv_cde_lgth := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 617
            , i_length     => 1
        );
        l_stage := 'authx_apprv_cde_lgth';
        o_mes_rec.authx_apprv_cde_lgth := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 617
            , i_length     => 1
        );
        l_stage := 'authx_ichg_resp';
        o_mes_rec.authx_ichg_resp := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 618
            , i_length     => 8
        );
        l_stage := 'authx_pseudo_term_id';
        o_mes_rec.authx_pseudo_term_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 626
            , i_length     => 4
        );
        l_stage := 'authx_rfrl_phone';
        o_mes_rec.authx_rfrl_phone := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 630
            , i_length     => 20
        );
        l_stage := 'authx_dft_capture_flg';
        o_mes_rec.authx_dft_capture_flg := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 650
            , i_length     => 1
        );
        l_stage := 'authx_setl_flag';
        o_mes_rec.authx_setl_flag := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 651
            , i_length     => 1
        );
        l_stage := 'authx_rvrl_cde';
        o_mes_rec.authx_rvrl_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 652
            , i_length     => 2
        );
        l_stage := 'authx_rea_for_chrgbck';
        o_mes_rec.authx_rea_for_chrgbck := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 654
            , i_length     => 2
        );
        l_stage := 'authx_num_of_chrgbck';
        o_mes_rec.authx_num_of_chrgbck := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 656
            , i_length     => 1
        );
        l_stage := 'authx_pt_srv_cond_cde';
        o_mes_rec.authx_pt_srv_cond_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 657
            , i_length     => 2
        );
        l_stage := 'authx_pt_srv_entry_mde';
        o_mes_rec.authx_pt_srv_entry_mde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 659
            , i_length     => 3
        );
        l_stage := 'authx_auth_ind2';
        o_mes_rec.authx_auth_ind2 := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 662
            , i_length     => 1
        );
        l_stage := 'authx_orig_crncy_cde';
        o_mes_rec.authx_orig_crncy_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 663
            , i_length     => 3
        );
        l_stage := 'authx_mult_crncy_auth_crncy_cd';
        o_mes_rec.authx_mult_crncy_auth_crncy_cd := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 666
            , i_length     => 3
        );
        l_stage := 'authx_mult_crncy_auth_conv_rat';
        o_mes_rec.authx_mult_crncy_auth_conv_rat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 669
            , i_length     => 8
        );
        l_stage := 'authx_mult_crncy_setl_crncy_cd';
        o_mes_rec.authx_mult_crncy_setl_crncy_cd := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 677
            , i_length     => 3
        );
        l_stage := 'authx_mult_crncy_setl_conv_rat';
        o_mes_rec.authx_mult_crncy_setl_conv_rat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 680
            , i_length     => 8
        );
        l_stage := 'authx_mult_crncy_conv_dat_tim';
        o_mes_rec.authx_mult_crncy_conv_dat_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 688
            , i_length     => 19
        );
        l_stage := 'authx_refr_imp_ind';
        o_mes_rec.authx_refr_imp_ind := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 707
            , i_length     => 1
        );
        l_stage := 'authx_refr_avail_bal';
        o_mes_rec.authx_refr_avail_bal := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 708
            , i_length     => 1
        );
        l_stage := 'authx_refr_ledg_bal';
        o_mes_rec.authx_refr_ledg_bal := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 709
            , i_length     => 1
        );
        l_stage := 'authx_refr_amt_on_hold';
        o_mes_rec.authx_refr_amt_on_hold := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 710
            , i_length     => 1
        );
        l_stage := 'authx_refr_ttl_float';
        o_mes_rec.authx_refr_ttl_float := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 711
            , i_length     => 1
        );
        l_stage := 'authx_refr_cur_float';
        o_mes_rec.authx_refr_cur_float := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 712
            , i_length     => 1
        );
        l_stage := 'authx_adj_setl_impact_flg';
        o_mes_rec.authx_adj_setl_impact_flg := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 713
            , i_length     => 1
        );
        l_stage := 'authx_refr_ind';
        o_mes_rec.authx_refr_ind := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 714
            , i_length     => 4
        );
        l_stage := 'authx_frwd_inst_id_num';
        o_mes_rec.authx_frwd_inst_id_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 718
            , i_length     => 11
        );
        l_stage := 'authx_crd_accpt_id_num';
        o_mes_rec.authx_crd_accpt_id_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 729
            , i_length     => 11
        );
        l_stage := 'authx_crd_iss_id_num';
        o_mes_rec.authx_crd_iss_id_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 740
            , i_length     => 11
        );
        l_stage := 'authx_orig_msg_typ';
        o_mes_rec.authx_orig_msg_typ := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 751
            , i_length     => 4
        );
        l_stage := 'authx_orig_tran_tim';
        o_mes_rec.authx_orig_tran_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 755
            , i_length     => 8
        );
        l_stage := 'authx_orig_tran_dat';
        o_mes_rec.authx_orig_tran_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 763
            , i_length     => 4
        );
        l_stage := 'authx_orig_seq_num';
        o_mes_rec.authx_orig_seq_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 767
            , i_length     => 12
        );
        l_stage := 'authx_orig_b24_post_dat';
        o_mes_rec.authx_orig_b24_post_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 779
            , i_length     => 4
        );
        l_stage := 'authx_excp_rsn_cde';
        o_mes_rec.authx_excp_rsn_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 783
            , i_length     => 3
        );
        l_stage := 'authx_ovrrde_flg';
        o_mes_rec.authx_ovrrde_flg := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 786
            , i_length     => 1
        );
        l_stage := 'authx_addr';
        o_mes_rec.authx_addr := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 787
            , i_length     => 20
        );
        l_stage := 'authx_zip_cde';
        o_mes_rec.authx_zip_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 807
            , i_length     => 9
        );
        l_stage := 'authx_addr_vrfy_stat';
        o_mes_rec.authx_addr_vrfy_stat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 816
            , i_length     => 1
        );
        l_stage := 'authx_pin_ind';
        o_mes_rec.authx_pin_ind := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 817
            , i_length     => 1
        );
        l_stage := 'authx_pin_tries';
        o_mes_rec.authx_pin_tries := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 818
            , i_length     => 1
        );
        l_stage := 'authx_pre_auth_ts_dat';
        o_mes_rec.authx_pre_auth_ts_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 819
            , i_length     => 6
        );
        l_stage := 'authx_pre_auth_ts_tim';
        o_mes_rec.authx_pre_auth_ts_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 825
            , i_length     => 8
        );
        l_stage := 'authx_pre_auth_hlds_lvl';
        o_mes_rec.authx_pre_auth_hlds_lvl := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 833
            , i_length     => 1
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error processing POS customer transaction on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            --dbms_output.put_line(sqlerrm);
            raise;
    end;
    
    procedure put_message_atm (
        i_mes_rec               in aci_api_type_pkg.t_atm_fin_rec
    ) is
    begin
        insert into aci_atm_fin (
            id
            , file_id
            , headx_dat_tim
            , headx_rec_typ
            , headx_auth_ppd
            , headx_term_ln
            , headx_term_fiid
            , headx_term_term_id
            , headx_crd_ln
            , headx_crd_fiid
            , headx_crd_pan
            , headx_crd_mbr_num
            , headx_branch_id
            , headx_region_id

            , authx_type_cde
            , authx_type
            , authx_rte_stat
            , authx_originator
            , authx_responder
            , authx_entry_time
            , authx_exit_time
            , authx_re_entry_tim
            , authx_tran_date
            , authx_tran_time
            , authx_post_date
            , authx_acq_ichg_setl_date
            , authx_iss_ichg_setl_date
            , authx_seq_num
            , authx_term_typ
            , authx_tim_ofst
            , authx_acq_inst_id
            , authx_rcv_inst_id
            , authx_tran_cde
            , authx_from_acct
            , authx_to_acct
            , authx_mult_acct
            , authx_amt_1
            , authx_amt_2
            , authx_amt_3
            , authx_dep_bal_cr
            , authx_dep_typ
            , authx_resp_cde
            , authx_term_name_loc
            , authx_term_owner_name
            , authx_term_city
            , authx_term_st
            , authx_term_cntry
            , authx_orig_oseq_num
            , authx_orig_otran_dat
            , authx_orig_otran_tim
            , authx_orig_b24_post_dat
            , authx_orig_crncy_cde
            , authx_mult_crncy_auth_crncy_cd
            , authx_mult_crncy_auth_conv_rat
            , authx_mult_crncy_setl_crncy_cd
            , authx_mult_crncy_setl_conv_rat
            , authx_mult_crncy_conv_dat_tim
            , authx_rvsl_rsn
            , authx_pin_ofst
            , authx_shrg_grp
            , authx_dest_order
            , authx_auth_id_resp
            , authx_refr_imp_ind
            , authx_refr_avail_imp
            , authx_refr_ledg_imp
            , authx_refr_hld_amt_imp
            , authx_refr_caf_refr_ind
            , authx_dep_setl_imp_flg
            , authx_adj_setl_imp_flg
            , authx_refr_ind
            , authx_frwd_inst_id_num
            , authx_crd_accpt_id_num
            , authx_crd_iss_id_num
            , record_number
        ) values (
            i_mes_rec.id
            , i_mes_rec.file_id
            , i_mes_rec.headx_dat_tim
            , i_mes_rec.headx_rec_typ
            , i_mes_rec.headx_auth_ppd
            , i_mes_rec.headx_term_ln
            , i_mes_rec.headx_term_fiid
            , i_mes_rec.headx_term_term_id
            , i_mes_rec.headx_crd_ln
            , i_mes_rec.headx_crd_fiid
            , null
            , i_mes_rec.headx_crd_mbr_num
            , i_mes_rec.headx_branch_id
            , i_mes_rec.headx_region_id

            , i_mes_rec.authx_type_cde
            , i_mes_rec.authx_type
            , i_mes_rec.authx_rte_stat
            , i_mes_rec.authx_originator
            , i_mes_rec.authx_responder
            , i_mes_rec.authx_entry_time
            , i_mes_rec.authx_exit_time
            , i_mes_rec.authx_re_entry_tim
            , i_mes_rec.authx_tran_date
            , i_mes_rec.authx_tran_time
            , i_mes_rec.authx_post_date
            , i_mes_rec.authx_acq_ichg_setl_date
            , i_mes_rec.authx_iss_ichg_setl_date
            , i_mes_rec.authx_seq_num
            , i_mes_rec.authx_term_typ
            , i_mes_rec.authx_tim_ofst
            , i_mes_rec.authx_acq_inst_id
            , i_mes_rec.authx_rcv_inst_id
            , i_mes_rec.authx_tran_cde
            , i_mes_rec.authx_from_acct
            , i_mes_rec.authx_to_acct
            , i_mes_rec.authx_mult_acct
            , i_mes_rec.authx_amt_1
            , i_mes_rec.authx_amt_2
            , i_mes_rec.authx_amt_3
            , i_mes_rec.authx_dep_bal_cr
            , i_mes_rec.authx_dep_typ
            , i_mes_rec.authx_resp_cde
            , i_mes_rec.authx_term_name_loc
            , i_mes_rec.authx_term_owner_name
            , i_mes_rec.authx_term_city
            , i_mes_rec.authx_term_st
            , i_mes_rec.authx_term_cntry
            , i_mes_rec.authx_orig_oseq_num
            , i_mes_rec.authx_orig_otran_dat
            , i_mes_rec.authx_orig_otran_tim
            , i_mes_rec.authx_orig_b24_post_dat
            , i_mes_rec.authx_orig_crncy_cde
            , i_mes_rec.authx_mult_crncy_auth_crncy_cd
            , i_mes_rec.authx_mult_crncy_auth_conv_rat
            , i_mes_rec.authx_mult_crncy_setl_crncy_cd
            , i_mes_rec.authx_mult_crncy_setl_conv_rat
            , i_mes_rec.authx_mult_crncy_conv_dat_tim
            , i_mes_rec.authx_rvsl_rsn
            , i_mes_rec.authx_pin_ofst
            , i_mes_rec.authx_shrg_grp
            , i_mes_rec.authx_dest_order
            , i_mes_rec.authx_auth_id_resp
            , i_mes_rec.authx_refr_imp_ind
            , i_mes_rec.authx_refr_avail_imp
            , i_mes_rec.authx_refr_ledg_imp
            , i_mes_rec.authx_refr_hld_amt_imp
            , i_mes_rec.authx_refr_caf_refr_ind
            , i_mes_rec.authx_dep_setl_imp_flg
            , i_mes_rec.authx_adj_setl_imp_flg
            , i_mes_rec.authx_refr_ind
            , i_mes_rec.authx_frwd_inst_id_num
            , i_mes_rec.authx_crd_accpt_id_num
            , i_mes_rec.authx_crd_iss_id_num
            , i_mes_rec.record_number
        );
        
        insert into aci_card (
            id
            , card_number
        ) values (
            i_mes_rec.id
            , i_mes_rec.headx_crd_pan
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Save incoming ATM message error [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;
    
    procedure put_message_pos (
        i_mes_rec               in aci_api_type_pkg.t_pos_fin_rec
    ) is
    begin
        insert into aci_pos_fin (
            id
            , file_id
            , headx_dat_tim
            , headx_rec_typ
            , headx_crd_ln
            , headx_crd_fiid
            , headx_crd_card_crd_num
            , headx_crd_card_mbr_num
            , headx_retl_ky_ln
            , headx_retl_ky_rdfkey_fiid
            , headx_retl_ky_rdfkey_grp
            , headx_retl_ky_rdfkey_regn
            , headx_retl_ky_rdfkey_id
            , headx_retl_term_id
            , headx_retl_shift_num
            , headx_retl_batch_num
            , headx_term_ln
            , headx_term_fiid
            , headx_term_term_id
            , headx_term_tim
            , headx_tkey_term_id
            , headx_tkey_rkey_rec_frmt
            , headx_tkey_rkey_retailer_id
            , headx_tkey_rkey_clerk_id
            , headx_data_flag

            , authx_typ
            , authx_rte_stat
            , authx_originator
            , authx_responder
            , authx_iss_cde
            , authx_entry_tim
            , authx_exit_tim
            , authx_re_entry_tim
            , authx_tran_dat
            , authx_tran_tim
            , authx_post_dat
            , authx_acq_ichg_setl_dat
            , authx_iss_ichg_setl_dat
            , authx_seq_num
            , authx_term_name_loc
            , authx_term_owner_name
            , authx_term_city
            , authx_term_st
            , authx_term_cntry_cde
            , authx_brch_id
            , authx_term_tim_ofst
            , authx_acq_inst_id_num
            , authx_rcv_inst_id_num
            , authx_term_typ
            , authx_clerk_id
            , authx_crt_auth_grp
            , authx_crt_auth_user_id
            , authx_retl_sic_cde
            , authx_orig
            , authx_dest
            , authx_tran_cde
            , authx_crd_typ
            , authx_acct
            , authx_resp_cde
            , authx_amt_1
            , authx_amt_2
            , authx_exp_dat
            , authx_track2
            , authx_pin_ofst
            , authx_pre_auth_seq_num
            , authx_invoice_num
            , authx_orig_invoice_num
            , authx_authorizer
            , authx_auth_ind
            , authx_shift_num
            , authx_batch_seq_num
            , authx_apprv_cde
            , authx_apprv_cde_lgth
            , authx_ichg_resp
            , authx_pseudo_term_id
            , authx_rfrl_phone
            , authx_dft_capture_flg
            , authx_setl_flag
            , authx_rvrl_cde
            , authx_rea_for_chrgbck
            , authx_num_of_chrgbck
            , authx_pt_srv_cond_cde
            , authx_pt_srv_entry_mde
            , authx_auth_ind2
            , authx_orig_crncy_cde
            , authx_mult_crncy_auth_crncy_cd
            , authx_mult_crncy_auth_conv_rat
            , authx_mult_crncy_setl_crncy_cd
            , authx_mult_crncy_setl_conv_rat
            , authx_mult_crncy_conv_dat_tim
            , authx_refr_imp_ind
            , authx_refr_avail_bal
            , authx_refr_ledg_bal
            , authx_refr_amt_on_hold
            , authx_refr_ttl_float
            , authx_refr_cur_float
            , authx_adj_setl_impact_flg
            , authx_refr_ind
            , authx_frwd_inst_id_num
            , authx_crd_accpt_id_num
            , authx_crd_iss_id_num
            , authx_orig_msg_typ
            , authx_orig_tran_tim
            , authx_orig_tran_dat
            , authx_orig_seq_num
            , authx_orig_b24_post_dat
            , authx_excp_rsn_cde
            , authx_ovrrde_flg
            , authx_addr
            , authx_zip_cde
            , authx_addr_vrfy_stat
            , authx_pin_ind
            , authx_pin_tries
            , authx_pre_auth_ts_dat
            , authx_pre_auth_ts_tim
            , authx_pre_auth_hlds_lvl
            , record_number
        ) values (
            i_mes_rec.id
            , i_mes_rec.file_id
            , i_mes_rec.headx_dat_tim
            , i_mes_rec.headx_rec_typ
            , i_mes_rec.headx_crd_ln
            , i_mes_rec.headx_crd_fiid
            , null
            , i_mes_rec.headx_crd_card_mbr_num
            , i_mes_rec.headx_retl_ky_ln
            , i_mes_rec.headx_retl_ky_rdfkey_fiid
            , i_mes_rec.headx_retl_ky_rdfkey_grp
            , i_mes_rec.headx_retl_ky_rdfkey_regn
            , i_mes_rec.headx_retl_ky_rdfkey_id
            , i_mes_rec.headx_retl_term_id
            , i_mes_rec.headx_retl_shift_num
            , i_mes_rec.headx_retl_batch_num
            , i_mes_rec.headx_term_ln
            , i_mes_rec.headx_term_fiid
            , i_mes_rec.headx_term_term_id
            , i_mes_rec.headx_term_tim
            , i_mes_rec.headx_tkey_term_id
            , i_mes_rec.headx_tkey_rkey_rec_frmt
            , i_mes_rec.headx_tkey_rkey_retailer_id
            , i_mes_rec.headx_tkey_rkey_clerk_id
            , i_mes_rec.headx_data_flag

            , i_mes_rec.authx_typ
            , i_mes_rec.authx_rte_stat
            , i_mes_rec.authx_originator
            , i_mes_rec.authx_responder
            , i_mes_rec.authx_iss_cde
            , i_mes_rec.authx_entry_tim
            , i_mes_rec.authx_exit_tim
            , i_mes_rec.authx_re_entry_tim
            , i_mes_rec.authx_tran_dat
            , i_mes_rec.authx_tran_tim
            , i_mes_rec.authx_post_dat
            , i_mes_rec.authx_acq_ichg_setl_dat
            , i_mes_rec.authx_iss_ichg_setl_dat
            , i_mes_rec.authx_seq_num
            , i_mes_rec.authx_term_name_loc
            , i_mes_rec.authx_term_owner_name
            , i_mes_rec.authx_term_city
            , i_mes_rec.authx_term_st
            , i_mes_rec.authx_term_cntry_cde
            , i_mes_rec.authx_brch_id
            , i_mes_rec.authx_term_tim_ofst
            , i_mes_rec.authx_acq_inst_id_num
            , i_mes_rec.authx_rcv_inst_id_num
            , i_mes_rec.authx_term_typ
            , i_mes_rec.authx_clerk_id
            , i_mes_rec.authx_crt_auth_grp
            , i_mes_rec.authx_crt_auth_user_id
            , i_mes_rec.authx_retl_sic_cde
            , i_mes_rec.authx_orig
            , i_mes_rec.authx_dest
            , i_mes_rec.authx_tran_cde
            , i_mes_rec.authx_crd_typ
            , i_mes_rec.authx_acct
            , i_mes_rec.authx_resp_cde
            , i_mes_rec.authx_amt_1
            , i_mes_rec.authx_amt_2
            , i_mes_rec.authx_exp_dat
            , i_mes_rec.authx_track2
            , i_mes_rec.authx_pin_ofst
            , i_mes_rec.authx_pre_auth_seq_num
            , i_mes_rec.authx_invoice_num
            , i_mes_rec.authx_orig_invoice_num
            , i_mes_rec.authx_authorizer
            , i_mes_rec.authx_auth_ind
            , i_mes_rec.authx_shift_num
            , i_mes_rec.authx_batch_seq_num
            , i_mes_rec.authx_apprv_cde
            , i_mes_rec.authx_apprv_cde_lgth
            , i_mes_rec.authx_ichg_resp
            , i_mes_rec.authx_pseudo_term_id
            , i_mes_rec.authx_rfrl_phone
            , i_mes_rec.authx_dft_capture_flg
            , i_mes_rec.authx_setl_flag
            , i_mes_rec.authx_rvrl_cde
            , i_mes_rec.authx_rea_for_chrgbck
            , i_mes_rec.authx_num_of_chrgbck
            , i_mes_rec.authx_pt_srv_cond_cde
            , i_mes_rec.authx_pt_srv_entry_mde
            , i_mes_rec.authx_auth_ind2
            , i_mes_rec.authx_orig_crncy_cde
            , i_mes_rec.authx_mult_crncy_auth_crncy_cd
            , i_mes_rec.authx_mult_crncy_auth_conv_rat
            , i_mes_rec.authx_mult_crncy_setl_crncy_cd
            , i_mes_rec.authx_mult_crncy_setl_conv_rat
            , i_mes_rec.authx_mult_crncy_conv_dat_tim
            , i_mes_rec.authx_refr_imp_ind
            , i_mes_rec.authx_refr_avail_bal
            , i_mes_rec.authx_refr_ledg_bal
            , i_mes_rec.authx_refr_amt_on_hold
            , i_mes_rec.authx_refr_ttl_float
            , i_mes_rec.authx_refr_cur_float
            , i_mes_rec.authx_adj_setl_impact_flg
            , i_mes_rec.authx_refr_ind
            , i_mes_rec.authx_frwd_inst_id_num
            , i_mes_rec.authx_crd_accpt_id_num
            , i_mes_rec.authx_crd_iss_id_num
            , i_mes_rec.authx_orig_msg_typ
            , i_mes_rec.authx_orig_tran_tim
            , i_mes_rec.authx_orig_tran_dat
            , i_mes_rec.authx_orig_seq_num
            , i_mes_rec.authx_orig_b24_post_dat
            , i_mes_rec.authx_excp_rsn_cde
            , i_mes_rec.authx_ovrrde_flg
            , i_mes_rec.authx_addr
            , i_mes_rec.authx_zip_cde
            , i_mes_rec.authx_addr_vrfy_stat
            , i_mes_rec.authx_pin_ind
            , i_mes_rec.authx_pin_tries
            , i_mes_rec.authx_pre_auth_ts_dat
            , i_mes_rec.authx_pre_auth_ts_tim
            , i_mes_rec.authx_pre_auth_hlds_lvl
            , i_mes_rec.record_number
        );
        
        insert into aci_card (
            id
            , card_number
        ) values (
            i_mes_rec.id
            , i_mes_rec.headx_crd_card_crd_num
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Save incoming POS message error [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;
    
    procedure create_incoming_atm_message (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_atm_fin_rec
    ) is
    begin
        -- set message
        set_message_atm (
            i_raw_data   => i_raw_data
            , o_mes_rec  => o_mes_rec
        );
        
        o_mes_rec.id := opr_api_create_pkg.get_id;
        o_mes_rec.file_id := i_file_id;
        o_mes_rec.record_number := i_record_number;
        
        -- put message
        put_message_atm (
            i_mes_rec  => o_mes_rec
        );
    end;
    
    procedure create_incoming_pos_message (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_pos_fin_rec
    ) is
    begin
        -- set message
        set_message_pos (
            i_raw_data   => i_raw_data
            , o_mes_rec  => o_mes_rec
        );
        
        o_mes_rec.id := opr_api_create_pkg.get_id;
        o_mes_rec.file_id := i_file_id;
        o_mes_rec.record_number := i_record_number;

        -- put message
        put_message_pos (
            i_mes_rec  => o_mes_rec
        );
    end;

end;
/
