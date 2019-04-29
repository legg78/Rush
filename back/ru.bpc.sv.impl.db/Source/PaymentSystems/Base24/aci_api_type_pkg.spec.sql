create or replace package aci_api_type_pkg is
/*********************************************************
 *  ACI Base24 API types <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 17.10.2013 <br />
 *  Last changed by $Author: nasybullina $ <br />
 *  $LastChangedDate:: 2013-11-01 11:47:02 +0400#$ <br />
 *  Revision: $LastChangedRevision: 36465 $ <br />
 *  Module: aci_api_type_pkg <br />
 *  @headcom
 **********************************************************/

    type            t_aci_file_rec is record (
        id                                 com_api_type_pkg.t_long_id
        , is_incoming                      com_api_type_pkg.t_boolean
        , session_file_id                  com_api_type_pkg.t_long_id
        , network_id                       com_api_type_pkg.t_name
        , extract_date                     date
        , release_number                   com_api_type_pkg.t_tiny_id
        , name                             com_api_type_pkg.t_name
        , file_type                        com_api_type_pkg.t_dict_value
        , total                            com_api_type_pkg.t_short_id
        , amount                           com_api_type_pkg.t_money
        , impact_timestamp                 timestamp
    );
    type            t_aci_file_tab is table of t_aci_file_rec index by binary_integer;        
    
    type            t_atm_fin_rec is record (
        id                                 com_api_type_pkg.t_long_id
        , file_id                          com_api_type_pkg.t_long_id
        , headx_dat_tim                    varchar2(19)
        , headx_rec_typ                    varchar2(2)
        , headx_auth_ppd                   varchar2(4)
        , headx_term_ln                    varchar2(4)
        , headx_term_fiid                  varchar2(4)
        , headx_term_term_id               varchar2(16)
        , headx_crd_ln                     varchar2(4)
        , headx_crd_fiid                   varchar2(4)
        , headx_crd_pan                    varchar2(19)
        , headx_crd_mbr_num                varchar2(3)
        , headx_branch_id                  varchar2(4)
        , headx_region_id                  varchar2(4)

        , authx_type_cde                   varchar2(2)
        , authx_type                       varchar2(4)
        , authx_rte_stat                   varchar2(2)
        , authx_originator                 varchar2(1)
        , authx_responder                  varchar2(1)
        , authx_entry_time                 varchar2(19)
        , authx_exit_time                  varchar2(19)
        , authx_re_entry_tim               varchar2(19)
        , authx_tran_date                  varchar2(6)
        , authx_tran_time                  varchar2(8)
        , authx_post_date                  varchar2(6)
        , authx_acq_ichg_setl_date         varchar2(6)
        , authx_iss_ichg_setl_date         varchar2(6)
        , authx_seq_num                    varchar2(12)
        , authx_term_typ                   varchar2(2)
        , authx_tim_ofst                   varchar2(5)
        , authx_acq_inst_id                varchar2(11)
        , authx_rcv_inst_id                varchar2(11)
        , authx_tran_cde                   varchar2(6)
        , authx_from_acct                  varchar2(19)
        , authx_to_acct                    varchar2(19)
        , authx_mult_acct                  varchar2(1)
        , authx_amt_1                      varchar2(19)
        , authx_amt_2                      varchar2(19)
        , authx_amt_3                      varchar2(19)
        , authx_dep_bal_cr                 varchar2(10)
        , authx_dep_typ                    varchar2(1)
        , authx_resp_cde                   varchar2(3)
        , authx_term_name_loc              varchar2(25)
        , authx_term_owner_name            varchar2(22)
        , authx_term_city                  varchar2(13)
        , authx_term_st                    varchar2(3)
        , authx_term_cntry                 varchar2(2)
        , authx_orig_oseq_num              varchar2(12)
        , authx_orig_otran_dat             varchar2(4)
        , authx_orig_otran_tim             varchar2(8)
        , authx_orig_b24_post_dat          varchar2(4)
        , authx_orig_crncy_cde             varchar2(3)
        , authx_mult_crncy_auth_crncy_cd   varchar2(3)
        , authx_mult_crncy_auth_conv_rat   varchar2(8)
        , authx_mult_crncy_setl_crncy_cd   varchar2(3)
        , authx_mult_crncy_setl_conv_rat   varchar2(8)
        , authx_mult_crncy_conv_dat_tim    varchar2(19)
        , authx_rvsl_rsn                   varchar2(2)
        , authx_pin_ofst                   varchar2(16)
        , authx_shrg_grp                   varchar2(1)
        , authx_dest_order                 varchar2(1)
        , authx_auth_id_resp               varchar2(6)
        , authx_refr_imp_ind               varchar2(2)
        , authx_refr_avail_imp             varchar2(2)
        , authx_refr_ledg_imp              varchar2(2)
        , authx_refr_hld_amt_imp           varchar2(2)
        , authx_refr_caf_refr_ind          varchar2(1)
        , authx_dep_setl_imp_flg           varchar2(1)
        , authx_adj_setl_imp_flg           varchar2(1)
        , authx_refr_ind                   varchar2(4)
        , authx_frwd_inst_id_num           varchar2(11)
        , authx_crd_accpt_id_num           varchar2(11)
        , authx_crd_iss_id_num             varchar2(11)
        , record_number                    com_api_type_pkg.t_long_id
    );
    type            t_atm_fin_tab is table of t_atm_fin_rec index by binary_integer;
    
    type            t_atm_setl_rec is record (
        id                          com_api_type_pkg.t_long_id
        , file_id                   com_api_type_pkg.t_long_id
        , headx_dat_tim             varchar2(19)
        , headx_rec_typ             varchar2(2)
        , headx_auth_ppd            varchar2(4)
        , headx_term_ln             varchar2(4)
        , headx_term_fiid           varchar2(4)
        , headx_term_term_id        varchar2(16)
        , headx_crd_ln              varchar2(4)
        , headx_crd_fiid            varchar2(4)
        , headx_crd_pan             varchar2(19)
        , headx_crd_mbr_num         varchar2(3)
        , headx_branch_id           varchar2(4)
        , headx_region_id           varchar2(4)

        , term_setl_admin_dat       varchar2(6)
        , term_setl_admin_tim       varchar2(8)
        , term_setl_admin_cde       varchar2(2)
        , term_setl_num_dep         varchar2(5)
        , term_setl_amt_dep         varchar2(19)
        , term_setl_num_cmrcl_dep   varchar2(5)
        , term_setl_amt_cmrcl_dep   varchar2(19)
        , term_setl_num_pay         varchar2(5)
        , term_setl_amt_pay         varchar2(19)
        , term_setl_num_msg         varchar2(5)
        , term_setl_num_chk         varchar2(5)
        , term_setl_amt_chk         varchar2(19)
        , term_setl_num_logonly     varchar2(5)
        , term_setl_ttl_env         varchar2(5)
        , term_setl_crds_ret        varchar2(5)
        , term_setl_setl_crncy_cde  varchar2(3)
        , term_setl_tim_ofst        varchar2(5)
        , record_number             com_api_type_pkg.t_long_id
    );
    type            t_atm_setl_tab is table of t_atm_setl_rec index by binary_integer;
    
    type            t_atm_setl_hopr_rec is record (
        id                          com_api_type_pkg.t_long_id
        , hopr_num                  com_api_type_pkg.t_tiny_id
        , term_setl_hopr_contents   varchar2(2)
        , term_setl_hopr_beg_cash   varchar2(19)
        , term_setl_hopr_cash_incr  varchar2(19)
        , term_setl_hopr_cash_decr  varchar2(19)
        , term_setl_hopr_cash_out   varchar2(19)
        , term_setl_hopr_end_cash   varchar2(19)
        , term_setl_hopr_crncy_cde  varchar2(3)
        , term_setl_hopr_user_fld5  varchar2(1)
    );
    type            t_atm_setl_hopr_tab is table of t_atm_setl_hopr_rec index by binary_integer;
    
    type            t_atm_cash_rec is record (
        id                          com_api_type_pkg.t_long_id
        , file_id                   com_api_type_pkg.t_long_id
        , headx_dat_tim             varchar2(19)
        , headx_rec_typ             varchar2(2)
        , headx_auth_ppd            varchar2(4)
        , headx_term_ln             varchar2(4)
        , headx_term_fiid           varchar2(4)
        , headx_term_term_id        varchar2(16)
        , headx_crd_ln              varchar2(4)
        , headx_crd_fiid            varchar2(4)
        , headx_crd_pan             varchar2(19)
        , headx_crd_mbr_num         varchar2(3)
        , headx_branch_id           varchar2(4)
        , headx_region_id           varchar2(4)
        
        , term_cash_admin_dat       varchar2(6)
        , term_cash_admin_tim       varchar2(8)
        , term_cash_admin_cde       varchar2(2)
        , term_cash_hopr_num        varchar2(1)
        , term_cash_hopr_contents   varchar2(2)
        , term_cash_amt             varchar2(12)
        , term_cash_crncy_cde       varchar2(3)
        , term_cash_user_fld8       varchar2(1)
        , term_cash_tim_ofst        varchar2(5)
        , term_cash_cash_area       varchar2(21)
        , record_number             com_api_type_pkg.t_long_id
    );
    type            t_atm_cash_tab is table of t_atm_cash_rec index by binary_integer;
    
    type            t_atm_setl_ttl_rec is record (
        id                          com_api_type_pkg.t_long_id
        , file_id                   com_api_type_pkg.t_long_id
        , headx_dat_tim             varchar2(19)
        , headx_rec_typ             varchar2(2)
        , headx_auth_ppd            varchar2(4)
        , headx_term_ln             varchar2(4)
        , headx_term_fiid           varchar2(4)
        , headx_term_term_id        varchar2(16)
        , headx_crd_ln              varchar2(4)
        , headx_crd_fiid            varchar2(4)
        , headx_crd_pan             varchar2(19)
        , headx_crd_mbr_num         varchar2(3)
        , headx_branch_id           varchar2(4)
        , headx_region_id           varchar2(4)
        
        , setl_ttl_admin_dat        varchar2(6)
        , setl_ttl_admin_tim        varchar2(8)
        , setl_ttl_admin_cde        varchar2(2)
        , setl_ttl_term_db          varchar2(12)
        , setl_ttl_term_cr          varchar2(12)
        , setl_ttl_on_us_db         varchar2(12)
        , setl_ttl_on_us_cr         varchar2(12)
        , setl_ttl_crncy_cde        varchar2(3)
        , setl_ttl_tim_ofst         varchar2(5)
        , record_number             com_api_type_pkg.t_long_id
    );
    type            t_atm_setl_ttl_tab is table of t_atm_setl_ttl_rec index by binary_integer;

    type            t_pos_fin_rec is record (
        id                                com_api_type_pkg.t_long_id
        , file_id                         com_api_type_pkg.t_long_id
        , headx_dat_tim                   varchar2(19)
        , headx_rec_typ                   varchar2(2)
        , headx_crd_ln                    varchar2(4)
        , headx_crd_fiid                  varchar2(4)
        , headx_crd_card_crd_num          varchar2(19)
        , headx_crd_card_mbr_num          varchar2(3)
        , headx_retl_ky_ln                varchar2(4)
        , headx_retl_ky_rdfkey_fiid       varchar2(4)
        , headx_retl_ky_rdfkey_grp        varchar2(4)
        , headx_retl_ky_rdfkey_regn       varchar2(4)
        , headx_retl_ky_rdfkey_id         varchar2(19)
        , headx_retl_term_id              varchar2(16)
        , headx_retl_shift_num            varchar2(3)
        , headx_retl_batch_num            varchar2(3)
        , headx_term_ln                   varchar2(4)
        , headx_term_fiid                 varchar2(4)
        , headx_term_term_id              varchar2(16)
        , headx_term_tim                  varchar2(8)
        , headx_tkey_term_id              varchar2(16)
        , headx_tkey_rkey_rec_frmt        varchar2(1)
        , headx_tkey_rkey_retailer_id     varchar2(19)
        , headx_tkey_rkey_clerk_id        varchar2(6)
        , headx_data_flag                 varchar2(1)

        , authx_typ                       varchar2(4)
        , authx_rte_stat                  varchar2(2)
        , authx_originator                varchar2(1)
        , authx_responder                 varchar2(1)
        , authx_iss_cde                   varchar2(2)
        , authx_entry_tim                 varchar2(19)
        , authx_exit_tim                  varchar2(19)
        , authx_re_entry_tim              varchar2(19)
        , authx_tran_dat                  varchar2(6)
        , authx_tran_tim                  varchar2(8)
        , authx_post_dat                  varchar2(6)
        , authx_acq_ichg_setl_dat         varchar2(6)
        , authx_iss_ichg_setl_dat         varchar2(6)
        , authx_seq_num                   varchar2(12)
        , authx_term_name_loc             varchar2(25)
        , authx_term_owner_name           varchar2(22)
        , authx_term_city                 varchar2(13) 
        , authx_term_st                   varchar2(3)
        , authx_term_cntry_cde            varchar2(2)
        , authx_brch_id                   varchar2(4)
        , authx_term_tim_ofst             varchar2(5)
        , authx_acq_inst_id_num           varchar2(11)
        , authx_rcv_inst_id_num           varchar2(11)
        , authx_term_typ                  varchar2(2)
        , authx_clerk_id                  varchar2(6)
        , authx_crt_auth_grp              varchar2(4)
        , authx_crt_auth_user_id          varchar2(8)
        , authx_retl_sic_cde              varchar2(4)
        , authx_orig                      varchar2(4)
        , authx_dest                      varchar2(4)
        , authx_tran_cde                  varchar2(6)
        , authx_crd_typ                   varchar2(2)
        , authx_acct                      varchar2(19)
        , authx_resp_cde                  varchar2(3)
        , authx_amt_1                     varchar2(19)
        , authx_amt_2                     varchar2(19)
        , authx_exp_dat                   varchar2(4)
        , authx_track2                    varchar2(40)
        , authx_pin_ofst                  varchar2(16)
        , authx_pre_auth_seq_num          varchar2(12)
        , authx_invoice_num               varchar2(10)
        , authx_orig_invoice_num          varchar2(10)
        , authx_authorizer                varchar2(16)
        , authx_auth_ind                  varchar2(1)
        , authx_shift_num                 varchar2(3)
        , authx_batch_seq_num             varchar2(3)
        , authx_apprv_cde                 varchar2(8)
        , authx_apprv_cde_lgth            varchar2(1)
        , authx_ichg_resp                 varchar2(8)
        , authx_pseudo_term_id            varchar2(4)
        , authx_rfrl_phone                varchar2(20)
        , authx_dft_capture_flg           varchar2(1)
        , authx_setl_flag                 varchar2(1)
        , authx_rvrl_cde                  varchar2(2)
        , authx_rea_for_chrgbck           varchar2(2)
        , authx_num_of_chrgbck            varchar2(1)
        , authx_pt_srv_cond_cde           varchar2(2)
        , authx_pt_srv_entry_mde          varchar2(3)
        , authx_auth_ind2                 varchar2(1)
        , authx_orig_crncy_cde            varchar2(3)
        , authx_mult_crncy_auth_crncy_cd  varchar2(3)
        , authx_mult_crncy_auth_conv_rat  varchar2(8)
        , authx_mult_crncy_setl_crncy_cd  varchar2(3)
        , authx_mult_crncy_setl_conv_rat  varchar2(8)
        , authx_mult_crncy_conv_dat_tim   varchar2(19)
        , authx_refr_imp_ind              varchar2(1)
        , authx_refr_avail_bal            varchar2(1)
        , authx_refr_ledg_bal             varchar2(1)
        , authx_refr_amt_on_hold          varchar2(1)
        , authx_refr_ttl_float            varchar2(1)
        , authx_refr_cur_float            varchar2(1)
        , authx_adj_setl_impact_flg       varchar2(1)
        , authx_refr_ind                  varchar2(4)
        , authx_frwd_inst_id_num          varchar2(11)
        , authx_crd_accpt_id_num          varchar2(11)
        , authx_crd_iss_id_num            varchar2(11)
        , authx_orig_msg_typ              varchar2(4)
        , authx_orig_tran_tim             varchar2(8)
        , authx_orig_tran_dat             varchar2(4)
        , authx_orig_seq_num              varchar2(12)
        , authx_orig_b24_post_dat         varchar2(4)
        , authx_excp_rsn_cde              varchar2(3)
        , authx_ovrrde_flg                varchar2(1)
        , authx_addr                      varchar2(20)
        , authx_zip_cde                   varchar2(9)
        , authx_addr_vrfy_stat            varchar2(1)
        , authx_pin_ind                   varchar2(1)
        , authx_pin_tries                 varchar2(1)
        , authx_pre_auth_ts_dat           varchar2(6)
        , authx_pre_auth_ts_tim           varchar2(8)
        , authx_pre_auth_hlds_lvl         varchar2(1)
        , record_number                   com_api_type_pkg.t_long_id
    );
    type            t_pos_fin_tab is table of t_pos_fin_rec index by binary_integer;
    
    type            t_pos_setl_rec is record (
        id                             com_api_type_pkg.t_long_id
        , file_id                      com_api_type_pkg.t_long_id
        , headx_dat_tim                varchar2(19)
        , headx_rec_typ                varchar2(2)
        , headx_crd_ln                 varchar2(4)
        , headx_crd_fiid               varchar2(4)
        , headx_crd_card_crd_num       varchar2(19)
        , headx_crd_card_mbr_num       varchar2(3)
        , headx_retl_ky_ln             varchar2(4)
        , headx_retl_ky_rdfkey_fiid    varchar2(4)
        , headx_retl_ky_rdfkey_grp     varchar2(4)
        , headx_retl_ky_rdfkey_regn    varchar2(4)
        , headx_retl_ky_rdfkey_id      varchar2(19)
        , headx_retl_term_id           varchar2(16)
        , headx_retl_shift_num         varchar2(3)
        , headx_retl_batch_num         varchar2(3)
        , headx_term_ln                varchar2(4)
        , headx_term_fiid              varchar2(4)
        , headx_term_term_id           varchar2(16)
        , headx_term_tim               varchar2(8)
        , headx_tkey_term_id           varchar2(16)
        , headx_tkey_rkey_rec_frmt     varchar2(1)
        , headx_tkey_rkey_retailer_id  varchar2(19)
        , headx_tkey_rkey_clerk_id     varchar2(6)
        , headx_data_flag              varchar2(1)
        
        , rec1d_typ                    varchar2(4)
        , rec1d_post_dat               varchar2(6)
        , rec1d_prod_id                varchar2(2)
        , rec1d_rel_num                varchar2(2)
        , rec1d_dpc_num                varchar2(4)
        , rec1d_term_tim_ofst          varchar2(5)
        , rec1d_term_id                varchar2(16)
        , rec1d_retl_rttn              varchar2(11)
        , rec1d_retl_acct              varchar2(19)
        , rec1d_retl_nam               varchar2(40)
        , rec1d_setl_typ               varchar2(1)
        , rec1d_bal_flg                varchar2(1)
        , rec1d_tran_dat               varchar2(6)
        , rec1d_tran_tim               varchar2(6)
        , rec1d_ob_flg                 varchar2(1)
        , rec1d_ach_comp_id            varchar2(10)
        , rec1d_billing_info           varchar2(10)
        , rec1d_auth_crncy_cde         varchar2(3)
        , rec1d_auth_conv_rate         varchar2(8)
        , rec1d_setl_crncy_cde         varchar2(3)
        , rec1d_setl_conv_rate         varchar2(8)
        
        , rec2d_stl_dc_tot_db_cnt      varchar2(5)
        , rec2d_stl_dc_tot_db          varchar2(19)
        , rec2d_stl_dc_tot_cr_cnt      varchar2(5)
        , rec2d_stl_dc_tot_cr          varchar2(19)
        , rec2d_stl_dc_tot_adj_cnt     varchar2(5)
        , rec2d_stl_dc_tot_adj         varchar2(19)
        , rec2d_stl_tot_db_cnt         varchar2(5)
        , rec2d_stl_tot_db             varchar2(19)
        , rec2d_stl_tot_cr_cnt         varchar2(5)
        , rec2d_stl_tot_cr             varchar2(19)
        , rec2d_stl_tot_adj_cnt        varchar2(5)
        , rec2d_stl_tot_adj            varchar2(19)
        , rec2d_stl_cn_dc_tot_db_cnt   varchar2(5)
        , rec2d_stl_cn_dc_tot_db       varchar2(19)
        , rec2d_stl_cn_dc_tot_cr_cnt   varchar2(5)
        , rec2d_stl_cn_dc_tot_cr       varchar2(19)
        , rec2d_stl_cn_dc_tot_adj_cnt  varchar2(5)
        , rec2d_stl_cn_dc_tot_adj      varchar2(19)
        , rec2d_stl_cn_tot_db_cnt      varchar2(5)
        , rec2d_stl_cn_tot_db          varchar2(19)
        , rec2d_stl_cn_tot_cr_cnt      varchar2(5)
        , rec2d_stl_cn_tot_cr          varchar2(19)
        , rec2d_stl_cn_tot_adj_cnt     varchar2(5)
        , rec2d_stl_cn_tot_adj         varchar2(19)        
        , record_number                com_api_type_pkg.t_long_id    
    );
    type            t_pos_setl_tab is table of t_pos_setl_rec index by binary_integer;
    
    type            t_clerk_tot_rec is record (
        id                             com_api_type_pkg.t_long_id
        , file_id                      com_api_type_pkg.t_long_id
        , headx_dat_tim                varchar2(19)
        , headx_rec_typ                varchar2(2)
        , headx_crd_ln                 varchar2(4)
        , headx_crd_fiid               varchar2(4)
        , headx_crd_card_crd_num       varchar2(19)
        , headx_crd_card_mbr_num       varchar2(3)
        , headx_retl_ky_ln             varchar2(4)
        , headx_retl_ky_rdfkey_fiid    varchar2(4)
        , headx_retl_ky_rdfkey_grp     varchar2(4)
        , headx_retl_ky_rdfkey_regn    varchar2(4)
        , headx_retl_ky_rdfkey_id      varchar2(19)
        , headx_retl_term_id           varchar2(16)
        , headx_retl_shift_num         varchar2(3)
        , headx_retl_batch_num         varchar2(3)
        , headx_term_ln                varchar2(4)
        , headx_term_fiid              varchar2(4)
        , headx_term_term_id           varchar2(16)
        , headx_term_tim               varchar2(8)
        , headx_tkey_term_id           varchar2(16)
        , headx_tkey_rkey_rec_frmt     varchar2(1)
        , headx_tkey_rkey_retailer_id  varchar2(19)
        , headx_tkey_rkey_clerk_id     varchar2(6)
        , headx_data_flag              varchar2(1)
        
        , set_rec1d_typ                varchar2(4)
        , set_rec1d_post_dat           varchar2(6)
        , set_rec1d_prod_id            varchar2(2)
        , set_rec1d_rel_num            varchar2(2)
        , set_rec1d_dpc_num            varchar2(4)
        , set_rec1d_term_tim_ofst      varchar2(5)
        , set_rec1d_term_id            varchar2(16)
        , set_rec1d_retl_rttn          varchar2(11)
        , set_rec1d_retl_acct          varchar2(19)
        , set_rec1d_retl_nam           varchar2(40)
        , set_rec1d_setl_typ           varchar2(1)
        , set_rec1d_bal_flg            varchar2(1)
        , set_rec1d_tran_dat           varchar2(6)
        , set_rec1d_tran_tim           varchar2(6)
        , set_rec1d_ob_flg             varchar2(1)
        , set_rec1d_ach_comp_id        varchar2(10)
        , set_rec1d_billing_info       varchar2(10)
        , set_rec1d_auth_crncy_cde     varchar2(3)
        , set_rec1d_auth_conv_rate     varchar2(8)
        , set_rec1d_setl_crncy_cde     varchar2(3)
        , set_rec1d_setl_conv_rate     varchar2(8)

        , set_rec5d_db_cnt             varchar2(5)
        , set_rec5d_db_amt             varchar2(19)
        , set_rec5d_cr_cnt             varchar2(5)
        , set_rec5d_cr_amt             varchar2(19)
        , set_rec5d_adj_cnt            varchar2(5)
        , set_rec5d_adj_amt            varchar2(19)
        , set_rec5d_cash_cnt           varchar2(5)
        , set_rec5d_cash_amt           varchar2(19)
        , set_rec5d_chk_cnt            varchar2(5)
        , set_rec5d_chk_amt            varchar2(19)
        , record_number                com_api_type_pkg.t_long_id
    );
    type            t_clerk_tot_tab is table of t_clerk_tot_rec index by binary_integer;
    
    type            t_service_rec is record (
        id                             com_api_type_pkg.t_long_id
        , file_id                      com_api_type_pkg.t_long_id
        , headx_dat_tim                varchar2(19)
        , headx_rec_typ                varchar2(2)
        , headx_crd_ln                 varchar2(4)
        , headx_crd_fiid               varchar2(4)
        , headx_crd_card_crd_num       varchar2(19)
        , headx_crd_card_mbr_num       varchar2(3)
        , headx_retl_ky_ln             varchar2(4)
        , headx_retl_ky_rdfkey_fiid    varchar2(4)
        , headx_retl_ky_rdfkey_grp     varchar2(4)
        , headx_retl_ky_rdfkey_regn    varchar2(4)
        , headx_retl_ky_rdfkey_id      varchar2(19)
        , headx_retl_term_id           varchar2(16)
        , headx_retl_shift_num         varchar2(3)
        , headx_retl_batch_num         varchar2(3)
        , headx_term_ln                varchar2(4)
        , headx_term_fiid              varchar2(4)
        , headx_term_term_id           varchar2(16)
        , headx_term_tim               varchar2(8)
        , headx_tkey_term_id           varchar2(16)
        , headx_tkey_rkey_rec_frmt     varchar2(1)
        , headx_tkey_rkey_retailer_id  varchar2(19)
        , headx_tkey_rkey_clerk_id     varchar2(6)
        , headx_data_flag              varchar2(1)
        
        , service_number               com_api_type_pkg.t_tiny_id
        , set_rec1d_typ                varchar2(4)
        , set_rec1d_post_dat           varchar2(6)
        , set_rec1d_prod_id            varchar2(2)
        , set_rec1d_rel_num            varchar2(2)
        , set_rec1d_dpc_num            varchar2(4)
        , set_rec1d_term_tim_ofst      varchar2(5)
        , set_rec1d_term_id            varchar2(16)
        , set_rec1d_retl_rttn          varchar2(11)
        , set_rec1d_retl_acct          varchar2(19)
        , set_rec1d_retl_nam           varchar2(40)
        , set_rec1d_setl_typ           varchar2(1)
        , set_rec1d_bal_flg            varchar2(1)
        , set_rec1d_tran_dat           varchar2(6)
        , set_rec1d_tran_tim           varchar2(6)
        , set_rec1d_ob_flg             varchar2(1)
        , set_rec1d_ach_comp_id        varchar2(10)
        , set_rec1d_billing_info       varchar2(10)
        , set_rec1d_auth_crncy_cde     varchar2(3)
        , set_rec1d_auth_conv_rate     varchar2(8)
        , set_rec1d_setl_crncy_cde     varchar2(3)
        , set_rec1d_setl_conv_rate     varchar2(8)
        , user_data_d_len              varchar2(4)
        , record_number                com_api_type_pkg.t_long_id
    );
    type            t_service_tab is table of t_service_rec index by binary_integer;
    
    type            t_service_attribute_rec is record (
        id                             com_api_type_pkg.t_long_id
        , service_num                  com_api_type_pkg.t_tiny_id
        , typ                          varchar2(2)
        , db_cnt                       varchar2(5)
        , db                           varchar2(19)
        , cr_cnt                       varchar2(5)
        , cr                           varchar2(19)
        , adj_cnt                      varchar2(5)
        , adj                          varchar2(19)
    );
    type            t_service_attribute_tab is table of t_service_attribute_rec index by binary_integer;
    
    type            t_token_rec is record (
        id                             com_api_type_pkg.t_long_id
        , name                         com_api_type_pkg.t_byte_char
        , value                        com_api_type_pkg.t_param_value
    );
    type            t_token_tab is table of t_token_rec index by binary_integer;
    
    type            t_tag_rec is record (
        tag                            com_api_type_pkg.t_tag
        , length                       com_api_type_pkg.t_tiny_id
    );
    type            t_tag_tab is table of t_tag_rec index by binary_integer;
    
    type            t_msg_count_rec is record (
        estimated_count                pls_integer
        , successed_total              pls_integer
        , excepted_total               pls_integer
        , skipped_total                pls_integer
    );
    type            t_msg_count_tab is table of t_msg_count_rec index by com_api_type_pkg.t_name;
    
    type            t_dict_count_tab is table of binary_integer index by com_api_type_pkg.t_dict_value;
    
    type            t_event_card_rec is record (
        card_id                        com_api_type_pkg.t_medium_id
        , instance_id                  com_api_type_pkg.t_medium_id
        , inst_id                      com_api_type_pkg.t_inst_id
        , network_id                   com_api_type_pkg.t_network_id
        , bin                          com_api_type_pkg.t_bin
        , card_number                  com_api_type_pkg.t_card_number
        , seq_number                   com_api_type_pkg.t_tiny_id
        , card_status                  com_api_type_pkg.t_dict_value
        , card_iss_date                date
        , card_start_date              date
        , card_expir_date              date
        , card_type_id                 com_api_type_pkg.t_tiny_id
        , pvv                          com_api_type_pkg.t_tiny_id
        
        , prev_card_status             com_api_type_pkg.t_dict_value
        , prev_card_iss_date           date
        , prev_card_expir_date         date
        
        , account_count                com_api_type_pkg.t_account_number
        , is_emv                       com_api_type_pkg.t_tiny_id

        , spending_limit               com_api_type_pkg.t_long_id
        , withdrawals_limit            com_api_type_pkg.t_long_id
        , purchases_limit              com_api_type_pkg.t_long_id

        , atm_card_last_used           date
        , pos_card_last_used           date

        , atm_last_extr_date           date
        , atm_last_imp_date            timestamp
        , pos_last_extr_date           date

        , record_number                com_api_type_pkg.t_long_id
        , record_number_desc           com_api_type_pkg.t_long_id
        , record_inst_number           com_api_type_pkg.t_long_id
        , record_inst_number_desc      com_api_type_pkg.t_long_id
        , count                        com_api_type_pkg.t_long_id
    );
    type            t_event_card_cur is ref cursor return t_event_card_rec;
    type            t_event_card_tab is table of t_event_card_rec index by binary_integer;

    type            t_event_merchant_rec is record (
        merchant_id                    com_api_type_pkg.t_short_id
        , merchant_number              com_api_type_pkg.t_merchant_number
        , merchant_name                com_api_type_pkg.t_name
        , merchant_label               com_api_type_pkg.t_name
        , merchant_status              com_api_type_pkg.t_dict_value
        , inst_id                      com_api_type_pkg.t_inst_id
        , mcc                          com_api_type_pkg.t_name
        , mcc_name                     com_api_type_pkg.t_name
        , country                      com_api_type_pkg.t_country_code
        , region_code                  com_api_type_pkg.t_name
        , city                         com_api_type_pkg.t_name
        , street                       com_api_type_pkg.t_name
        , house                        com_api_type_pkg.t_name
        , postal_code                  com_api_type_pkg.t_postal_code
        , primary_mobile               com_api_type_pkg.t_name
        , secondary_mobile             com_api_type_pkg.t_name
        , email                        com_api_type_pkg.t_name
        , contact_name                 com_api_type_pkg.t_name
        , account_number               com_api_type_pkg.t_account_number
        , account_open_date            date
        , account_close_date           date
        , fist_operation               date
        , last_operation               date
        , last_amount                  com_api_type_pkg.t_money
        , customer_number              com_api_type_pkg.t_name

        , record_number                com_api_type_pkg.t_long_id
        , record_number_desc           com_api_type_pkg.t_long_id
        , record_inst_number           com_api_type_pkg.t_long_id
        , record_inst_number_desc      com_api_type_pkg.t_long_id
        , count                        com_api_type_pkg.t_long_id
    );
    type            t_event_merchant_cur is ref cursor return t_event_merchant_rec;
    type            t_event_merchant_tab is table of t_event_merchant_rec index by binary_integer;
    
    type            t_event_cardholder_rec is record (
        card_id                        com_api_type_pkg.t_medium_id
        , card_number                  com_api_type_pkg.t_card_number
        , prev_card_number             com_api_type_pkg.t_card_number
        , inst_id                      com_api_type_pkg.t_inst_id
        , bin                          com_api_type_pkg.t_bin

        , cardholder_name              com_api_type_pkg.t_name
        , person_name                  com_api_type_pkg.t_name
        , national_id                  com_api_type_pkg.t_name
        , person_birth_date            date
        , street                       com_api_type_pkg.t_name
        , house                        com_api_type_pkg.t_name
        , city                         com_api_type_pkg.t_name
        , country_code                 com_api_type_pkg.t_country_code
        , region_code                  com_api_type_pkg.t_name
        , postal_code                  com_api_type_pkg.t_postal_code

        , home_phone                   com_api_type_pkg.t_name
        , work_phone                   com_api_type_pkg.t_name
        , mobile_phone                 com_api_type_pkg.t_name
        , email                        com_api_type_pkg.t_name
        , customer_number              com_api_type_pkg.t_name
        , reg_date                     date
        , iss_date                     date
        , card_issued                  com_api_type_pkg.t_tiny_id
        , account_open_date            date
        , last_card_request            date
        , last_pin_change              date
        
        , atm_last_extr_date           date
        , atm_last_imp_date            timestamp
        , pos_last_extr_date           date
        
        , record_number                com_api_type_pkg.t_long_id
        , record_number_desc           com_api_type_pkg.t_long_id
        , record_inst_number           com_api_type_pkg.t_long_id
        , record_inst_number_desc      com_api_type_pkg.t_long_id
        , count                        com_api_type_pkg.t_long_id
    );
    type            t_event_cardholder_cur is ref cursor return t_event_cardholder_rec;
    type            t_event_cardholder_tab is table of t_event_cardholder_rec index by binary_integer;
        
end;
/
