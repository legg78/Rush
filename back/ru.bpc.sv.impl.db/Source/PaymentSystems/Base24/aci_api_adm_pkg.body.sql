create or replace package body aci_api_adm_pkg is
/************************************************************
 * API for Base24 administrative message <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 22.01.2014 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: aci_api_adm_pkg <br />
 * @headcom
 ************************************************************/
 
    procedure set_message_setl (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , o_mes_rec             out aci_api_type_pkg.t_atm_setl_rec
        , o_hopr_tab            out aci_api_type_pkg.t_atm_setl_hopr_tab
    ) is
        l_setl_hopr_rec         aci_api_type_pkg.t_atm_setl_hopr_rec;
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
        o_mes_rec.term_setl_admin_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 90
            , i_length     => 6
        );
        o_mes_rec.term_setl_admin_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 96
            , i_length     => 8
        );
        o_mes_rec.term_setl_admin_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 104
            , i_length     => 2
        );
        o_mes_rec.term_setl_num_dep := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 712
            , i_length     => 5
        );
        o_mes_rec.term_setl_amt_dep := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 717
            , i_length     => 19
        );
        o_mes_rec.term_setl_num_cmrcl_dep := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 736
            , i_length     => 5
        );
        o_mes_rec.term_setl_amt_cmrcl_dep := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 741
            , i_length     => 19
        );
        o_mes_rec.term_setl_num_pay := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 760
            , i_length     => 5
        );
        o_mes_rec.term_setl_amt_pay := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 765
            , i_length     => 19
        );
        o_mes_rec.term_setl_num_msg := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 784
            , i_length     => 5
        );
        o_mes_rec.term_setl_num_chk := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 789
            , i_length     => 5
        );
        o_mes_rec.term_setl_amt_chk := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 794
            , i_length     => 19
        );
        o_mes_rec.term_setl_num_logonly := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 813
            , i_length     => 5
        );
        o_mes_rec.term_setl_ttl_env := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 818
            , i_length     => 5
        );
        o_mes_rec.term_setl_crds_ret := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 823
            , i_length     => 5
        );
        o_mes_rec.term_setl_setl_crncy_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 828
            , i_length     => 3
        );
        o_mes_rec.term_setl_tim_ofst := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 832
            , i_length     => 5
        );
            
        -- hopr
        for i in 1..6 loop
            l_setl_hopr_rec := null;
            l_setl_hopr_rec.hopr_num := i;
            
            l_setl_hopr_rec.term_setl_hopr_contents := aci_api_util_pkg.get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 106+(101*(i-1))
                , i_length     => 2
            );
            l_setl_hopr_rec.term_setl_hopr_beg_cash := aci_api_util_pkg.get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 108+(101*(i-1))
                , i_length     => 19
            );
            l_setl_hopr_rec.term_setl_hopr_cash_incr := aci_api_util_pkg.get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 127+(101*(i-1))
                , i_length     => 19
            );
            l_setl_hopr_rec.term_setl_hopr_cash_decr := aci_api_util_pkg.get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 146+(101*(i-1))
                , i_length     => 19
            );
            l_setl_hopr_rec.term_setl_hopr_cash_out := aci_api_util_pkg.get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 165+(101*(i-1))
                , i_length     => 19
            );
            l_setl_hopr_rec.term_setl_hopr_end_cash := aci_api_util_pkg.get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 184+(101*(i-1))
                , i_length     => 19
            );
            l_setl_hopr_rec.term_setl_hopr_crncy_cde := aci_api_util_pkg.get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 203+(101*(i-1))
                , i_length     => 3
            );
            o_hopr_tab(o_hopr_tab.count+1) := l_setl_hopr_rec;
        end loop;
        --dbms_output.put_line('hopr counts1 = ' || o_hopr_tab.count);
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error processing ATM balancing on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            --dbms_output.put_line(substr(i_raw_data, 1, 575));
            raise;
    end;
    
    procedure set_message_setl_ttl (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , o_mes_rec             out aci_api_type_pkg.t_atm_setl_ttl_rec
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
        o_mes_rec.setl_ttl_admin_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 90
            , i_length     => 6
        );
        o_mes_rec.setl_ttl_admin_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 96
            , i_length     => 8
        );
        o_mes_rec.setl_ttl_admin_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 104
            , i_length     => 2
        );
        o_mes_rec.setl_ttl_term_db := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 106
            , i_length     => 12
        );
        o_mes_rec.setl_ttl_term_cr := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 118
            , i_length     => 12
        );
        o_mes_rec.setl_ttl_on_us_db := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 130
            , i_length     => 12
        );
        o_mes_rec.setl_ttl_on_us_cr := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 142
            , i_length     => 12
        );
        o_mes_rec.setl_ttl_crncy_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 154
            , i_length     => 3
        );
        o_mes_rec.setl_ttl_tim_ofst := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 158
            , i_length     => 5
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error processing ATM settlement on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            --dbms_output.put_line(substr(i_raw_data, 1, 575));
            raise;
    end;
        
    procedure set_message_cash (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , o_mes_rec             out aci_api_type_pkg.t_atm_cash_rec
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
        o_mes_rec.term_cash_admin_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 90
            , i_length     => 6
        );
        o_mes_rec.term_cash_admin_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 96
            , i_length     => 8
        );
        o_mes_rec.term_cash_admin_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 104
            , i_length     => 2
        );
        o_mes_rec.term_cash_hopr_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 106
            , i_length     => 1
        );
        o_mes_rec.term_cash_hopr_contents := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 107
            , i_length     => 2
        );
        o_mes_rec.term_cash_amt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 109
            , i_length     => 12
        );
        o_mes_rec.term_cash_crncy_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 121
            , i_length     => 3
        );
        o_mes_rec.term_cash_tim_ofst := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 125
            , i_length     => 5
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error processing ATM cash adjustment on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            --dbms_output.put_line(substr(i_raw_data, 1, 575));
            raise;
    end;
        
    procedure put_message_setl (
        i_mes_rec               in aci_api_type_pkg.t_atm_setl_rec
        , i_hopr_tab            in aci_api_type_pkg.t_atm_setl_hopr_tab
    ) is
    begin
        insert into aci_atm_setl (
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

            , term_setl_admin_dat
            , term_setl_admin_tim
            , term_setl_admin_cde
            , term_setl_num_dep
            , term_setl_amt_dep
            , term_setl_num_cmrcl_dep
            , term_setl_amt_cmrcl_dep
            , term_setl_num_pay
            , term_setl_amt_pay
            , term_setl_num_msg
            , term_setl_num_chk
            , term_setl_amt_chk
            , term_setl_num_logonly
            , term_setl_ttl_env
            , term_setl_crds_ret
            , term_setl_setl_crncy_cde
            , term_setl_tim_ofst
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

            , i_mes_rec.term_setl_admin_dat
            , i_mes_rec.term_setl_admin_tim
            , i_mes_rec.term_setl_admin_cde
            , i_mes_rec.term_setl_num_dep
            , i_mes_rec.term_setl_amt_dep
            , i_mes_rec.term_setl_num_cmrcl_dep
            , i_mes_rec.term_setl_amt_cmrcl_dep
            , i_mes_rec.term_setl_num_pay
            , i_mes_rec.term_setl_amt_pay
            , i_mes_rec.term_setl_num_msg
            , i_mes_rec.term_setl_num_chk
            , i_mes_rec.term_setl_amt_chk
            , i_mes_rec.term_setl_num_logonly
            , i_mes_rec.term_setl_ttl_env
            , i_mes_rec.term_setl_crds_ret
            , i_mes_rec.term_setl_setl_crncy_cde
            , i_mes_rec.term_setl_tim_ofst
            , i_mes_rec.record_number
        );
            
        insert into aci_card (
            id
            , card_number
        ) values (
            i_mes_rec.id
          , iss_api_token_pkg.encode_card_number(i_card_number => i_mes_rec.headx_crd_pan)          
        );

        forall i in 1 .. i_hopr_tab.count
        insert into aci_atm_setl_hopr (
            id
            , hopr_num
            , term_setl_hopr_contents
            , term_setl_hopr_beg_cash
            , term_setl_hopr_cash_incr
            , term_setl_hopr_cash_decr
            , term_setl_hopr_cash_out
            , term_setl_hopr_end_cash
            , term_setl_hopr_crncy_cde
            , term_setl_hopr_user_fld5
        ) values (
            i_mes_rec.id
            , i_hopr_tab(i).hopr_num
            , i_hopr_tab(i).term_setl_hopr_contents
            , i_hopr_tab(i).term_setl_hopr_beg_cash
            , i_hopr_tab(i).term_setl_hopr_cash_incr
            , i_hopr_tab(i).term_setl_hopr_cash_decr
            , i_hopr_tab(i).term_setl_hopr_cash_out
            , i_hopr_tab(i).term_setl_hopr_end_cash
            , i_hopr_tab(i).term_setl_hopr_crncy_cde
            , i_hopr_tab(i).term_setl_hopr_user_fld5
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Save incoming balancing message [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;
        
    procedure put_message_setl_ttl (
        i_mes_rec               in aci_api_type_pkg.t_atm_setl_ttl_rec
    ) is
    begin
        insert into aci_atm_setl_ttl (
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
                
            , setl_ttl_admin_dat
            , setl_ttl_admin_tim
            , setl_ttl_admin_cde
            , setl_ttl_term_db
            , setl_ttl_term_cr
            , setl_ttl_on_us_db
            , setl_ttl_on_us_cr
            , setl_ttl_crncy_cde
            , setl_ttl_tim_ofst
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
                
            , i_mes_rec.setl_ttl_admin_dat
            , i_mes_rec.setl_ttl_admin_tim
            , i_mes_rec.setl_ttl_admin_cde
            , i_mes_rec.setl_ttl_term_db
            , i_mes_rec.setl_ttl_term_cr
            , i_mes_rec.setl_ttl_on_us_db
            , i_mes_rec.setl_ttl_on_us_cr
            , i_mes_rec.setl_ttl_crncy_cde
            , i_mes_rec.setl_ttl_tim_ofst
            , i_mes_rec.record_number
        );
        
        insert into aci_card (
            id
            , card_number
        ) values (
            i_mes_rec.id
          , iss_api_token_pkg.encode_card_number(i_card_number => i_mes_rec.headx_crd_pan)
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Save incoming settlement message [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;
    
    procedure put_message_cash (
        i_mes_rec               in aci_api_type_pkg.t_atm_cash_rec
    ) is
    begin
        insert into aci_atm_cash (
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
                
            , term_cash_admin_dat
            , term_cash_admin_tim
            , term_cash_admin_cde
            , term_cash_hopr_num
            , term_cash_hopr_contents
            , term_cash_amt
            , term_cash_crncy_cde
            , term_cash_user_fld8
            , term_cash_tim_ofst
            , term_cash_cash_area
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
                
            , i_mes_rec.term_cash_admin_dat
            , i_mes_rec.term_cash_admin_tim
            , i_mes_rec.term_cash_admin_cde
            , i_mes_rec.term_cash_hopr_num
            , i_mes_rec.term_cash_hopr_contents
            , i_mes_rec.term_cash_amt
            , i_mes_rec.term_cash_crncy_cde
            , i_mes_rec.term_cash_user_fld8
            , i_mes_rec.term_cash_tim_ofst
            , i_mes_rec.term_cash_cash_area
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
                i_text          => 'Save incoming cash adjustment message [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;
    
    procedure set_message_setl_tot (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , o_mes_rec             out aci_api_type_pkg.t_pos_setl_rec
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
        l_stage := 'rec1d_typ';
        o_mes_rec.rec1d_typ := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 184
            , i_length     => 4
        );
        l_stage := 'rec1d_post_dat';
        o_mes_rec.rec1d_post_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 188
            , i_length     => 6
        );
        l_stage := 'rec1d_prod_id';
        o_mes_rec.rec1d_prod_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 194
            , i_length     => 2
        );
        l_stage := 'rec1d_rel_num';
        o_mes_rec.rec1d_rel_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 196
            , i_length     => 2
        );
        l_stage := 'rec1d_dpc_num';
        o_mes_rec.rec1d_dpc_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 198
            , i_length     => 4
        );
        l_stage := 'rec1d_term_tim_ofst';
        o_mes_rec.rec1d_term_tim_ofst := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 202
            , i_length     => 5
        );
        l_stage := 'rec1d_term_id';
        o_mes_rec.rec1d_term_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 207
            , i_length     => 16
        );
        l_stage := 'rec1d_retl_rttn';
        o_mes_rec.rec1d_retl_rttn := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 223
            , i_length     => 11
        );
        l_stage := 'rec1d_retl_acct';
        o_mes_rec.rec1d_retl_acct := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 234
            , i_length     => 19
        );
        l_stage := 'rec1d_retl_nam';
        o_mes_rec.rec1d_retl_nam := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 253
            , i_length     => 40
        );
        l_stage := 'rec1d_setl_typ';
        o_mes_rec.rec1d_setl_typ := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 294
            , i_length     => 1
        );
        l_stage := 'rec1d_bal_flg';
        o_mes_rec.rec1d_bal_flg := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 295
            , i_length     => 1
        );
        l_stage := 'rec1d_tran_dat';
        o_mes_rec.rec1d_tran_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 297
            , i_length     => 6
        );
        l_stage := 'rec1d_tran_tim';
        o_mes_rec.rec1d_tran_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 303
            , i_length     => 6
        );
        l_stage := 'rec1d_ob_flg';
        o_mes_rec.rec1d_ob_flg := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 309
            , i_length     => 1
        );
        l_stage := 'rec1d_ach_comp_id';
        o_mes_rec.rec1d_ach_comp_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 310
            , i_length     => 10
        );
        l_stage := 'rec1d_billing_info';
        o_mes_rec.rec1d_billing_info := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 320
            , i_length     => 10
        );
        l_stage := 'rec1d_auth_crncy_cde';
        o_mes_rec.rec1d_auth_crncy_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 330
            , i_length     => 3
        );
        l_stage := 'rec1d_auth_conv_rate';
        o_mes_rec.rec1d_auth_conv_rate := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 333
            , i_length     => 8
        );
        l_stage := 'rec1d_setl_crncy_cde';
        o_mes_rec.rec1d_setl_crncy_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 341
            , i_length     => 3
        );
        l_stage := 'rec1d_setl_conv_rate';
        o_mes_rec.rec1d_setl_conv_rate := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 344
            , i_length     => 8
        );
        l_stage := 'rec2d_stl_dc_tot_db_cnt';
        o_mes_rec.rec2d_stl_dc_tot_db_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 353
            , i_length     => 5
        );
        l_stage := 'rec2d_stl_dc_tot_db';
        o_mes_rec.rec2d_stl_dc_tot_db := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 358
            , i_length     => 19
        );
        l_stage := 'rec2d_stl_dc_tot_cr_cnt';
        o_mes_rec.rec2d_stl_dc_tot_cr_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 377
            , i_length     => 5
        );
        l_stage := 'rec2d_stl_dc_tot_cr';
        o_mes_rec.rec2d_stl_dc_tot_cr := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 382
            , i_length     => 19
        );
        l_stage := 'rec2d_stl_dc_tot_adj_cnt';
        o_mes_rec.rec2d_stl_dc_tot_adj_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 401
            , i_length     => 5
        );
        l_stage := 'rec2d_stl_dc_tot_adj';
        o_mes_rec.rec2d_stl_dc_tot_adj := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 406
            , i_length     => 19
        );
        l_stage := 'rec2d_stl_tot_db_cnt';
        o_mes_rec.rec2d_stl_tot_db_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 425
            , i_length     => 5
        );
        l_stage := 'rec2d_stl_tot_db';
        o_mes_rec.rec2d_stl_tot_db := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 430
            , i_length     => 19
        );
        l_stage := 'rec2d_stl_tot_cr_cnt';
        o_mes_rec.rec2d_stl_tot_cr_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 449
            , i_length     => 5
        );
        l_stage := 'rec2d_stl_tot_cr_cnt';
        o_mes_rec.rec2d_stl_tot_cr := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 454
            , i_length     => 19
        );
        l_stage := 'rec2d_stl_tot_cr';
        o_mes_rec.rec2d_stl_tot_cr := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 473
            , i_length     => 19
        );
        l_stage := 'rec2d_stl_dc_tot_adj_cnt';
        o_mes_rec.rec2d_stl_dc_tot_adj_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 473
            , i_length     => 5
        );
        l_stage := 'rec2d_stl_dc_tot_adj';
        o_mes_rec.rec2d_stl_dc_tot_adj := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 478
            , i_length     => 19
        );
        l_stage := 'rec2d_stl_cn_dc_tot_db_cnt';
        o_mes_rec.rec2d_stl_cn_dc_tot_db_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 497
            , i_length     => 5
        );
        l_stage := 'rec2d_stl_cn_dc_tot_db';
        o_mes_rec.rec2d_stl_cn_dc_tot_db := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 502
            , i_length     => 19
        );
        l_stage := 'rec2d_stl_cn_dc_tot_cr_cnt';
        o_mes_rec.rec2d_stl_cn_dc_tot_cr_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 521
            , i_length     => 5
        );
        l_stage := 'rec2d_stl_cn_dc_tot_cr';
        o_mes_rec.rec2d_stl_cn_dc_tot_cr := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 526
            , i_length     => 19
        );
        l_stage := 'rec2d_stl_cn_dc_tot_adj_cnt';
        o_mes_rec.rec2d_stl_cn_dc_tot_adj_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 545
            , i_length     => 5
        );
        l_stage := 'rec2d_stl_cn_dc_tot_adj';
        o_mes_rec.rec2d_stl_cn_dc_tot_adj := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 550
            , i_length     => 19
        );
        l_stage := 'rec2d_stl_cn_tot_db_cnt';
        o_mes_rec.rec2d_stl_cn_tot_db_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 569
            , i_length     => 5
        );
        l_stage := 'rec2d_stl_cn_tot_db';
        o_mes_rec.rec2d_stl_cn_tot_db := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 574
            , i_length     => 19
        );
        l_stage := 'rec2d_stl_cn_tot_cr_cnt';
        o_mes_rec.rec2d_stl_cn_tot_cr_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 593
            , i_length     => 5
        );
        l_stage := 'rec2d_stl_cn_tot_cr';
        o_mes_rec.rec2d_stl_cn_tot_cr := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 598
            , i_length     => 19
        );
        l_stage := 'rec2d_stl_cn_tot_adj_cnt';
        o_mes_rec.rec2d_stl_cn_tot_adj_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 617
            , i_length     => 5
        );
        l_stage := 'rec2d_stl_cn_tot_adj';
        o_mes_rec.rec2d_stl_cn_tot_adj := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 622
            , i_length     => 19
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error processing POS settlement totals on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            --dbms_output.put_line(substr(i_raw_data, 1, 575));
            raise;
    end;
        
    procedure set_message_clerk (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , o_mes_rec             out aci_api_type_pkg.t_clerk_tot_rec
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
        l_stage := 'set_rec1d_typ';
        o_mes_rec.set_rec1d_typ := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 184
            , i_length     => 4
        );
        l_stage := 'set_rec1d_post_dat';
        o_mes_rec.set_rec1d_post_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 188
            , i_length     => 6
        );
        l_stage := 'set_rec1d_prod_id';
        o_mes_rec.set_rec1d_prod_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 194
            , i_length     => 2
        );
        l_stage := 'set_rec1d_rel_num';
        o_mes_rec.set_rec1d_rel_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 196
            , i_length     => 2
        );
        l_stage := 'set_rec1d_dpc_num';
        o_mes_rec.set_rec1d_dpc_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 198
            , i_length     => 4
        );
        l_stage := 'set_rec1d_term_tim_ofst';
        o_mes_rec.set_rec1d_term_tim_ofst := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 202
            , i_length     => 5
        );
        l_stage := 'set_rec1d_term_id';
        o_mes_rec.set_rec1d_term_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 207
            , i_length     => 16
        );
        l_stage := 'set_rec1d_retl_rttn';
        o_mes_rec.set_rec1d_retl_rttn := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 223
            , i_length     => 11
        );
        l_stage := 'set_rec1d_retl_acct';
        o_mes_rec.set_rec1d_retl_acct := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 234
            , i_length     => 19
        );
        l_stage := 'set_rec1d_retl_nam';
        o_mes_rec.set_rec1d_retl_nam := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 253
            , i_length     => 40
        );
        l_stage := 'set_rec1d_setl_typ';
        o_mes_rec.set_rec1d_setl_typ := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 294
            , i_length     => 1
        );
        l_stage := 'set_rec1d_bal_flg';
        o_mes_rec.set_rec1d_bal_flg := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 295
            , i_length     => 1
        );
        l_stage := 'set_rec1d_tran_dat';
        o_mes_rec.set_rec1d_tran_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 297
            , i_length     => 6
        );
        l_stage := 'set_rec1d_tran_tim';
        o_mes_rec.set_rec1d_tran_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 303
            , i_length     => 6
        );
        l_stage := 'set_rec1d_ob_flg';
        o_mes_rec.set_rec1d_ob_flg := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 309
            , i_length     => 1
        );
        l_stage := 'set_rec1d_ach_comp_id';
        o_mes_rec.set_rec1d_ach_comp_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 310
            , i_length     => 10
        );
        l_stage := 'set_rec1d_billing_info';
        o_mes_rec.set_rec1d_billing_info := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 320
            , i_length     => 10
        );
        l_stage := 'set_rec1d_auth_crncy_cde';
        o_mes_rec.set_rec1d_auth_crncy_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 330
            , i_length     => 3
        );
        l_stage := 'set_rec1d_auth_conv_rate';
        o_mes_rec.set_rec1d_auth_conv_rate := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 333
            , i_length     => 8
        );
        l_stage := 'set_rec1d_setl_crncy_cde';
        o_mes_rec.set_rec1d_setl_crncy_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 341
            , i_length     => 3
        );
        l_stage := 'set_rec1d_setl_conv_rate';
        o_mes_rec.set_rec1d_setl_conv_rate := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 344
            , i_length     => 8
        );
        l_stage := 'set_rec5d_db_cnt';
        o_mes_rec.set_rec5d_db_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 353
            , i_length     => 5
        );
        l_stage := 'set_rec5d_db_amt';
        o_mes_rec.set_rec5d_db_amt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 358
            , i_length     => 19
        );
        l_stage := 'set_rec5d_cr_cnt';
        o_mes_rec.set_rec5d_cr_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 377
            , i_length     => 5
        );
        l_stage := 'set_rec5d_cr_amt';
        o_mes_rec.set_rec5d_cr_amt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 382
            , i_length     => 19
        );
        l_stage := 'set_rec5d_adj_cnt';
        o_mes_rec.set_rec5d_adj_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 401
            , i_length     => 5
        );
        l_stage := 'set_rec5d_adj_amt';
        o_mes_rec.set_rec5d_adj_amt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 406
            , i_length     => 19
        );
        l_stage := 'set_rec5d_cash_cnt';
        o_mes_rec.set_rec5d_cash_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 425
            , i_length     => 5
        );
        l_stage := 'set_rec5d_cash_amt';
        o_mes_rec.set_rec5d_cash_amt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 430
            , i_length     => 19
        );
        l_stage := 'set_rec5d_chk_cnt';
        o_mes_rec.set_rec5d_chk_cnt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 449
            , i_length     => 5
        );
        l_stage := 'set_rec5d_chk_amt';
        o_mes_rec.set_rec5d_chk_amt := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 454
            , i_length     => 19
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error processing POS clerk totals on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            --dbms_output.put_line(substr(i_raw_data, 1, 575));
            raise;
    end;
        
    procedure set_message_service (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , o_mes_rec             out aci_api_type_pkg.t_service_rec
        , o_attr_tab            out aci_api_type_pkg.t_service_attribute_tab
    ) is
        l_service_count         com_api_type_pkg.t_tiny_id;
        l_attr_rec              aci_api_type_pkg.t_service_attribute_rec;
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
        l_stage := 'set_rec1d_typ';
        o_mes_rec.set_rec1d_typ := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 184
            , i_length     => 4
        );
        l_stage := 'set_rec1d_post_dat';
        o_mes_rec.set_rec1d_post_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 188
            , i_length     => 6
        );
        l_stage := 'set_rec1d_prod_id';
        o_mes_rec.set_rec1d_prod_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 194
            , i_length     => 2
        );
        l_stage := 'set_rec1d_rel_num';
        o_mes_rec.set_rec1d_rel_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 196
            , i_length     => 2
        );
        l_stage := 'set_rec1d_dpc_num';
        o_mes_rec.set_rec1d_dpc_num := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 198
            , i_length     => 4
        );
        l_stage := 'set_rec1d_term_tim_ofst';
        o_mes_rec.set_rec1d_term_tim_ofst := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 202
            , i_length     => 5
        );
        l_stage := 'set_rec1d_term_id';
        o_mes_rec.set_rec1d_term_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 207
            , i_length     => 16
        );
        l_stage := 'set_rec1d_retl_rttn';
        o_mes_rec.set_rec1d_retl_rttn := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 223
            , i_length     => 11
        );
        l_stage := 'set_rec1d_retl_acct';
        o_mes_rec.set_rec1d_retl_acct := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 234
            , i_length     => 19
        );
        l_stage := 'set_rec1d_retl_nam';
        o_mes_rec.set_rec1d_retl_nam := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 253
            , i_length     => 40
        );
        l_stage := 'set_rec1d_setl_typ';
        o_mes_rec.set_rec1d_setl_typ := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 294
            , i_length     => 1
        );
        l_stage := 'set_rec1d_bal_flg';
        o_mes_rec.set_rec1d_bal_flg := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 295
            , i_length     => 1
        );
        l_stage := 'set_rec1d_tran_dat';
        o_mes_rec.set_rec1d_tran_dat := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 297
            , i_length     => 6
        );
        l_stage := 'set_rec1d_tran_tim';
        o_mes_rec.set_rec1d_tran_tim := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 303
            , i_length     => 6
        );
        l_stage := 'set_rec1d_ob_flg';
        o_mes_rec.set_rec1d_ob_flg := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 309
            , i_length     => 1
        );
        l_stage := 'set_rec1d_ach_comp_id';
        o_mes_rec.set_rec1d_ach_comp_id := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 310
            , i_length     => 10
        );
        l_stage := 'set_rec1d_billing_info';
        o_mes_rec.set_rec1d_billing_info := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 320
            , i_length     => 10
        );
        l_stage := 'set_rec1d_auth_crncy_cde';
        o_mes_rec.set_rec1d_auth_crncy_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 330
            , i_length     => 3
        );
        l_stage := 'set_rec1d_auth_conv_rate';
        o_mes_rec.set_rec1d_auth_conv_rate := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 333
            , i_length     => 8
        );
        l_stage := 'set_rec1d_setl_crncy_cde';
        o_mes_rec.set_rec1d_setl_crncy_cde := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 341
            , i_length     => 3
        );
        l_stage := 'set_rec1d_setl_conv_rate';
        o_mes_rec.set_rec1d_setl_conv_rate := aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 344
            , i_length     => 8
        );
        l_stage := 'service_count';
        l_service_count := aci_api_util_pkg.get_field_number (
            i_raw_data     => i_raw_data
            , i_start_pos  => 353
            , i_length     => 5
        );
        
        for i in 1..l_service_count loop
            l_attr_rec := null;
            l_attr_rec.service_num := i;
                
            l_stage := 'typ';
            l_attr_rec.typ := aci_api_util_pkg.get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 353+(74*(i-1))
                , i_length     => 2
            );
            l_stage := 'db_cnt';
            l_attr_rec.db_cnt := aci_api_util_pkg.get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 355+(74*(i-1))
                , i_length     => 5
            );
            l_stage := 'db';
            l_attr_rec.db := aci_api_util_pkg.get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 360+(74*(i-1))
                , i_length     => 19
            );
            l_stage := 'cr_cnt';
            l_attr_rec.cr_cnt := aci_api_util_pkg.get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 379+(74*(i-1))
                , i_length     => 5
            );
            l_stage := 'cr';
            l_attr_rec.cr := aci_api_util_pkg.get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 384+(74*(i-1))
                , i_length     => 19
            );
            l_stage := 'adj_cnt';
            l_attr_rec.adj_cnt := aci_api_util_pkg.get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 403+(74*(i-1))
                , i_length     => 5
            );
            l_stage := 'adj';
            l_attr_rec.adj := aci_api_util_pkg.get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 408+(74*(i-1))
                , i_length     => 19
            );
            o_attr_tab(o_attr_tab.count + 1) := l_attr_rec;
        end loop;
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error processing POS services on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            --dbms_output.put_line(substr(i_raw_data, 1, 575));
            raise;
    end;
        
    procedure put_message_setl_tot (
        i_mes_rec               in aci_api_type_pkg.t_pos_setl_rec
    ) is
    begin
        insert into aci_pos_setl (
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

            , rec1d_typ
            , rec1d_post_dat
            , rec1d_prod_id
            , rec1d_rel_num
            , rec1d_dpc_num
            , rec1d_term_tim_ofst
            , rec1d_term_id
            , rec1d_retl_rttn
            , rec1d_retl_acct
            , rec1d_retl_nam
            , rec1d_setl_typ
            , rec1d_bal_flg
            , rec1d_tran_dat
            , rec1d_tran_tim
            , rec1d_ob_flg
            , rec1d_ach_comp_id
            , rec1d_billing_info
            , rec1d_auth_crncy_cde
            , rec1d_auth_conv_rate
            , rec1d_setl_crncy_cde
            , rec1d_setl_conv_rate
                
            , rec2d_stl_dc_tot_db_cnt
            , rec2d_stl_dc_tot_db
            , rec2d_stl_dc_tot_cr_cnt
            , rec2d_stl_dc_tot_cr
            , rec2d_stl_dc_tot_adj_cnt
            , rec2d_stl_dc_tot_adj
            , rec2d_stl_tot_db_cnt
            , rec2d_stl_tot_db
            , rec2d_stl_tot_cr_cnt
            , rec2d_stl_tot_cr
            , rec2d_stl_tot_adj_cnt
            , rec2d_stl_tot_adj
            , rec2d_stl_cn_dc_tot_db_cnt
            , rec2d_stl_cn_dc_tot_db
            , rec2d_stl_cn_dc_tot_cr_cnt
            , rec2d_stl_cn_dc_tot_cr
            , rec2d_stl_cn_dc_tot_adj_cnt
            , rec2d_stl_cn_dc_tot_adj
            , rec2d_stl_cn_tot_db_cnt
            , rec2d_stl_cn_tot_db
            , rec2d_stl_cn_tot_cr_cnt
            , rec2d_stl_cn_tot_cr
            , rec2d_stl_cn_tot_adj_cnt
            , rec2d_stl_cn_tot_adj
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

            , i_mes_rec.rec1d_typ
            , i_mes_rec.rec1d_post_dat
            , i_mes_rec.rec1d_prod_id
            , i_mes_rec.rec1d_rel_num
            , i_mes_rec.rec1d_dpc_num
            , i_mes_rec.rec1d_term_tim_ofst
            , i_mes_rec.rec1d_term_id
            , i_mes_rec.rec1d_retl_rttn
            , i_mes_rec.rec1d_retl_acct
            , i_mes_rec.rec1d_retl_nam
            , i_mes_rec.rec1d_setl_typ
            , i_mes_rec.rec1d_bal_flg
            , i_mes_rec.rec1d_tran_dat
            , i_mes_rec.rec1d_tran_tim
            , i_mes_rec.rec1d_ob_flg
            , i_mes_rec.rec1d_ach_comp_id
            , i_mes_rec.rec1d_billing_info
            , i_mes_rec.rec1d_auth_crncy_cde
            , i_mes_rec.rec1d_auth_conv_rate
            , i_mes_rec.rec1d_setl_crncy_cde
            , i_mes_rec.rec1d_setl_conv_rate
                
            , i_mes_rec.rec2d_stl_dc_tot_db_cnt
            , i_mes_rec.rec2d_stl_dc_tot_db
            , i_mes_rec.rec2d_stl_dc_tot_cr_cnt
            , i_mes_rec.rec2d_stl_dc_tot_cr
            , i_mes_rec.rec2d_stl_dc_tot_adj_cnt
            , i_mes_rec.rec2d_stl_dc_tot_adj
            , i_mes_rec.rec2d_stl_tot_db_cnt
            , i_mes_rec.rec2d_stl_tot_db
            , i_mes_rec.rec2d_stl_tot_cr_cnt
            , i_mes_rec.rec2d_stl_tot_cr
            , i_mes_rec.rec2d_stl_tot_adj_cnt
            , i_mes_rec.rec2d_stl_tot_adj
            , i_mes_rec.rec2d_stl_cn_dc_tot_db_cnt
            , i_mes_rec.rec2d_stl_cn_dc_tot_db
            , i_mes_rec.rec2d_stl_cn_dc_tot_cr_cnt
            , i_mes_rec.rec2d_stl_cn_dc_tot_cr
            , i_mes_rec.rec2d_stl_cn_dc_tot_adj_cnt
            , i_mes_rec.rec2d_stl_cn_dc_tot_adj
            , i_mes_rec.rec2d_stl_cn_tot_db_cnt
            , i_mes_rec.rec2d_stl_cn_tot_db
            , i_mes_rec.rec2d_stl_cn_tot_cr_cnt
            , i_mes_rec.rec2d_stl_cn_tot_cr
            , i_mes_rec.rec2d_stl_cn_tot_adj_cnt
            , i_mes_rec.rec2d_stl_cn_tot_adj
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
                i_text          => 'Save incoming settlement totals message [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;
        
    procedure put_message_clerk (
        i_mes_rec               in aci_api_type_pkg.t_clerk_tot_rec
    ) is
    begin
        insert into aci_clerk_tot (
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

            , set_rec1d_typ
            , set_rec1d_post_dat
            , set_rec1d_prod_id
            , set_rec1d_rel_num
            , set_rec1d_dpc_num
            , set_rec1d_term_tim_ofst
            , set_rec1d_term_id
            , set_rec1d_retl_rttn
            , set_rec1d_retl_acct
            , set_rec1d_retl_nam
            , set_rec1d_setl_typ
            , set_rec1d_bal_flg
            , set_rec1d_tran_dat
            , set_rec1d_tran_tim
            , set_rec1d_ob_flg
            , set_rec1d_ach_comp_id
            , set_rec1d_billing_info
            , set_rec1d_auth_crncy_cde
            , set_rec1d_auth_conv_rate
            , set_rec1d_setl_crncy_cde
            , set_rec1d_setl_conv_rate

            , set_rec5d_db_cnt
            , set_rec5d_db_amt
            , set_rec5d_cr_cnt
            , set_rec5d_cr_amt
            , set_rec5d_adj_cnt
            , set_rec5d_adj_amt
            , set_rec5d_cash_cnt
            , set_rec5d_cash_amt
            , set_rec5d_chk_cnt
            , set_rec5d_chk_amt
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

            , i_mes_rec.set_rec1d_typ
            , i_mes_rec.set_rec1d_post_dat
            , i_mes_rec.set_rec1d_prod_id
            , i_mes_rec.set_rec1d_rel_num
            , i_mes_rec.set_rec1d_dpc_num
            , i_mes_rec.set_rec1d_term_tim_ofst
            , i_mes_rec.set_rec1d_term_id
            , i_mes_rec.set_rec1d_retl_rttn
            , i_mes_rec.set_rec1d_retl_acct
            , i_mes_rec.set_rec1d_retl_nam
            , i_mes_rec.set_rec1d_setl_typ
            , i_mes_rec.set_rec1d_bal_flg
            , i_mes_rec.set_rec1d_tran_dat
            , i_mes_rec.set_rec1d_tran_tim
            , i_mes_rec.set_rec1d_ob_flg
            , i_mes_rec.set_rec1d_ach_comp_id
            , i_mes_rec.set_rec1d_billing_info
            , i_mes_rec.set_rec1d_auth_crncy_cde
            , i_mes_rec.set_rec1d_auth_conv_rate
            , i_mes_rec.set_rec1d_setl_crncy_cde
            , i_mes_rec.set_rec1d_setl_conv_rate

            , i_mes_rec.set_rec5d_db_cnt
            , i_mes_rec.set_rec5d_db_amt
            , i_mes_rec.set_rec5d_cr_cnt
            , i_mes_rec.set_rec5d_cr_amt
            , i_mes_rec.set_rec5d_adj_cnt
            , i_mes_rec.set_rec5d_adj_amt
            , i_mes_rec.set_rec5d_cash_cnt
            , i_mes_rec.set_rec5d_cash_amt
            , i_mes_rec.set_rec5d_chk_cnt
            , i_mes_rec.set_rec5d_chk_amt
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
                i_text          => 'Save incoming clerk totals message [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;
        
    procedure put_message_service (
        i_mes_rec               in aci_api_type_pkg.t_service_rec
        , i_attr_tab            in aci_api_type_pkg.t_service_attribute_tab
    ) is
    begin
        insert into aci_service (
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
                
            , set_rec1d_typ
            , set_rec1d_post_dat
            , set_rec1d_prod_id
            , set_rec1d_rel_num
            , set_rec1d_dpc_num
            , set_rec1d_term_tim_ofst
            , set_rec1d_term_id
            , set_rec1d_retl_rttn
            , set_rec1d_retl_acct
            , set_rec1d_retl_nam
            , set_rec1d_setl_typ
            , set_rec1d_bal_flg
            , set_rec1d_tran_dat
            , set_rec1d_tran_tim
            , set_rec1d_ob_flg
            , set_rec1d_ach_comp_id
            , set_rec1d_billing_info
            , set_rec1d_auth_crncy_cde
            , set_rec1d_auth_conv_rate
            , set_rec1d_setl_crncy_cde
            , set_rec1d_setl_conv_rate
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
                
            , i_mes_rec.set_rec1d_typ
            , i_mes_rec.set_rec1d_post_dat
            , i_mes_rec.set_rec1d_prod_id
            , i_mes_rec.set_rec1d_rel_num
            , i_mes_rec.set_rec1d_dpc_num
            , i_mes_rec.set_rec1d_term_tim_ofst
            , i_mes_rec.set_rec1d_term_id
            , i_mes_rec.set_rec1d_retl_rttn
            , i_mes_rec.set_rec1d_retl_acct
            , i_mes_rec.set_rec1d_retl_nam
            , i_mes_rec.set_rec1d_setl_typ
            , i_mes_rec.set_rec1d_bal_flg
            , i_mes_rec.set_rec1d_tran_dat
            , i_mes_rec.set_rec1d_tran_tim
            , i_mes_rec.set_rec1d_ob_flg
            , i_mes_rec.set_rec1d_ach_comp_id
            , i_mes_rec.set_rec1d_billing_info
            , i_mes_rec.set_rec1d_auth_crncy_cde
            , i_mes_rec.set_rec1d_auth_conv_rate
            , i_mes_rec.set_rec1d_setl_crncy_cde
            , i_mes_rec.set_rec1d_setl_conv_rate
            , i_mes_rec.record_number
        );
            
        insert into aci_card (
            id
            , card_number
        ) values (
            i_mes_rec.id
            , i_mes_rec.headx_crd_card_crd_num
        );

        forall i in 1 .. i_attr_tab.count
        insert into aci_service_attribute (
            id
            , service_num
            , typ
            , db_cnt
            , db
            , cr_cnt
            , cr
            , adj_cnt
            , adj
        ) values (
            i_mes_rec.id
            , i_attr_tab(i).service_num
            , i_attr_tab(i).typ
            , i_attr_tab(i).db_cnt
            , i_attr_tab(i).db
            , i_attr_tab(i).cr_cnt
            , i_attr_tab(i).cr
            , i_attr_tab(i).adj_cnt
            , i_attr_tab(i).adj
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Save incoming services message [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;
    
    procedure create_incoming_setl (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_atm_setl_rec
        , o_hopr_tab            out aci_api_type_pkg.t_atm_setl_hopr_tab
    ) is
    begin
        -- set message
        set_message_setl (
            i_raw_data    => i_raw_data
            , o_mes_rec   => o_mes_rec
            , o_hopr_tab  => o_hopr_tab
        );

        o_mes_rec.id := opr_api_create_pkg.get_id;
        o_mes_rec.file_id := i_file_id;
        o_mes_rec.record_number := i_record_number;
        
        -- put message
        put_message_setl (
            i_mes_rec     => o_mes_rec
            , i_hopr_tab  => o_hopr_tab
        );
    end;
    
    procedure create_incoming_setl_ttl (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_atm_setl_ttl_rec
    ) is
    begin
        o_mes_rec.id := opr_api_create_pkg.get_id;
        
        -- set message
        set_message_setl_ttl (
            i_raw_data   => i_raw_data
            , o_mes_rec  => o_mes_rec
        );
        
        o_mes_rec.id := opr_api_create_pkg.get_id;
        o_mes_rec.file_id := i_file_id;
        o_mes_rec.record_number := i_record_number;
        
        -- put message
        put_message_setl_ttl (
            i_mes_rec  => o_mes_rec
        );
    end;
    
    procedure create_incoming_cash (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_atm_cash_rec
    ) is
    begin
        o_mes_rec.id := opr_api_create_pkg.get_id;
        
        -- set message
        set_message_cash (
            i_raw_data   => i_raw_data
            , o_mes_rec  => o_mes_rec
        );
        
        o_mes_rec.id := opr_api_create_pkg.get_id;
        o_mes_rec.file_id := i_file_id;
        o_mes_rec.record_number := i_record_number;
        
        -- put message
        put_message_cash (
            i_mes_rec  => o_mes_rec
        );
    end;
    
    procedure create_incoming_setl_tot (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_pos_setl_rec
    ) is
    begin
        o_mes_rec.id := opr_api_create_pkg.get_id;
        
        -- set message
        set_message_setl_tot (
            i_raw_data    => i_raw_data
            , o_mes_rec   => o_mes_rec
        );
        
        o_mes_rec.id := opr_api_create_pkg.get_id;
        o_mes_rec.file_id := i_file_id;
        o_mes_rec.record_number := i_record_number;
        
        -- put message
        put_message_setl_tot (
            i_mes_rec    => o_mes_rec
        );
    end;
    
    procedure create_incoming_clerk (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_clerk_tot_rec
    ) is
    begin
        o_mes_rec.id := opr_api_create_pkg.get_id;
        
        -- set message
        set_message_clerk (
            i_raw_data    => i_raw_data
            , o_mes_rec   => o_mes_rec
        );
        
        o_mes_rec.id := opr_api_create_pkg.get_id;
        o_mes_rec.file_id := i_file_id;
        o_mes_rec.record_number := i_record_number;
        
        -- put message
        put_message_clerk (
            i_mes_rec    => o_mes_rec
        );
    end;
    
    procedure create_incoming_srvcs (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_service_rec
    ) is
        l_attr_tab              aci_api_type_pkg.t_service_attribute_tab;
    begin
        o_mes_rec.id := opr_api_create_pkg.get_id;
        
        -- set message
        set_message_service (
            i_raw_data    => i_raw_data
            , o_mes_rec   => o_mes_rec
            , o_attr_tab  => l_attr_tab
        );
        
        o_mes_rec.id := opr_api_create_pkg.get_id;
        o_mes_rec.file_id := i_file_id;
        o_mes_rec.record_number := i_record_number;
        
        -- put message
        put_message_service (
            i_mes_rec     => o_mes_rec
            , i_attr_tab  => l_attr_tab
        );
    end;
    
end;
/
