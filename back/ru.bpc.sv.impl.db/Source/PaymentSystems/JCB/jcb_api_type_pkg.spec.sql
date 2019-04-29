create or replace package jcb_api_type_pkg is

    subtype         t_mti is jcb_fin_message.mti%type;
    subtype         t_de002 is jcb_card.card_number%type;
    subtype         t_de003 is com_api_type_pkg.t_auth_code;
    subtype         t_de003s is jcb_fin_message.de003_1%type;
    subtype         t_de004 is jcb_fin_message.de004%type;
    subtype         t_de005 is jcb_fin_message.de005%type;
    subtype         t_de006 is jcb_fin_message.de006%type;
    subtype         t_de009 is jcb_fin_message.de009%type;
    subtype         t_de010 is jcb_fin_message.de010%type;
    subtype         t_de012 is jcb_fin_message.de012%type;
    subtype         t_de014 is jcb_fin_message.de014%type;
    subtype         t_de016 is jcb_fin_message.de016%type;
    subtype         t_de022 is com_api_type_pkg.t_cmid;
    subtype         t_de022s is jcb_fin_message.de022_1%type;
    subtype         t_de023 is jcb_fin_message.de023%type;
    subtype         t_de024 is jcb_fin_message.de024%type;
    subtype         t_de025 is jcb_fin_message.de025%type;
    subtype         t_de026 is jcb_fin_message.de026%type;
    subtype         t_de030 is varchar2(24);    
    subtype         t_de030_1 is jcb_fin_message.de030_1%type;    
    subtype         t_de030_2 is jcb_fin_message.de030_2%type;    
    subtype         t_de031 is jcb_fin_message.de031%type;    
    subtype         t_de032 is jcb_fin_message.de032%type;    
    subtype         t_de033 is jcb_fin_message.de033%type;    
    subtype         t_de037 is jcb_fin_message.de037%type;    
    subtype         t_de038 is jcb_fin_message.de038%type;    
    subtype         t_de040 is jcb_fin_message.de040%type;    
    subtype         t_de041 is jcb_fin_message.de041%type;
    subtype         t_de042 is jcb_fin_message.de042%type;    
    subtype         t_de043 is varchar2(99);    
    subtype         t_de048 is varchar2(999);    
    subtype         t_de049 is jcb_fin_message.de049%type;
    subtype         t_de050 is jcb_fin_message.de050%type;
    subtype         t_de051 is jcb_fin_message.de051%type;
    subtype         t_de054 is jcb_fin_message.de054%type;    
    subtype         t_de055 is jcb_fin_message.de055%type;
    subtype         t_de062 is varchar2(999);    
    subtype         t_de071 is jcb_fin_message.de071%type;
    subtype         t_de072 is jcb_fin_message.de072%type;
    subtype         t_de093 is jcb_fin_message.de093%type;
    subtype         t_de094 is jcb_fin_message.de094%type;
    subtype         t_de097 is jcb_fin_message.de097%type;
    subtype         t_de100 is jcb_fin_message.de100%type;
    subtype         t_de123 is varchar2(999);
    subtype         t_de124 is varchar2(999);
    subtype         t_de125 is varchar2(999);
    subtype         t_de126 is varchar2(999);

    subtype         t_p3001   is jcb_fin_message.p3001%type;
    subtype         t_p3002   is jcb_fin_message.p3002%type;
    subtype         t_p3003   is jcb_fin_message.p3003%type;
    subtype         t_p3005   is jcb_fin_message.p3005%type;
    subtype         t_p3006   is jcb_fin_message.p3006%type;
    
    subtype         t_p3005_1 is jcb_fin_p3005.p3005_1%type;
    subtype         t_p3005_2 is jcb_fin_p3005.p3005_2%type;
    subtype         t_p3005_3 is jcb_fin_p3005.p3005_3%type;
    subtype         t_p3005_4 is jcb_fin_p3005.p3005_4%type;
    subtype         t_p3005_5 is jcb_fin_p3005.p3005_5%type;
    subtype         t_p3005_6 is jcb_fin_p3005.p3005_6%type;
    subtype         t_p3005_7 is jcb_fin_p3005.p3005_7%type;
    subtype         t_p3005_8 is jcb_fin_p3005.p3005_8%type;
    subtype         t_p3005_9 is jcb_fin_p3005.p3005_9%type;
    subtype         t_p3005_10 is jcb_fin_p3005.p3005_10%type;
    
    subtype         t_p3007_1 is jcb_fin_message.p3007_1%type;
    subtype         t_p3007_2 is jcb_fin_message.p3007_2%type;
    subtype         t_p3008   is jcb_fin_message.p3008%type;    
    subtype         t_p3009   is jcb_fin_message.p3009%type;    
    subtype         t_p3011   is jcb_fin_message.p3011%type;
    subtype         t_p3012   is jcb_fin_message.p3012%type;
    subtype         t_p3013   is jcb_fin_message.p3013%type;
    subtype         t_p3014   is jcb_fin_message.p3014%type;
    subtype         t_p3021   is jcb_fin_message.p3021%type;

    subtype         t_p3201   is jcb_fin_message.p3201%type;
    subtype         t_p3202   is jcb_fin_message.p3202%type;
    subtype         t_p3203   is jcb_fin_message.p3203%type;
    subtype         t_p3205   is jcb_fin_message.p3205%type;
    subtype         t_p3206   is jcb_fin_message.p3206%type;
    subtype         t_p3207   is jcb_fin_message.p3207%type;
    subtype         t_p3208   is jcb_fin_message.p3208%type;
    subtype         t_p3209   is jcb_fin_message.p3209%type;
    subtype         t_p3210   is jcb_fin_message.p3210%type;
    subtype         t_p3211   is jcb_fin_message.p3211%type;
    subtype         t_p3250   is jcb_fin_message.p3250%type;
    subtype         t_p3251   is jcb_fin_message.p3251%type;
    subtype         t_p3302   is jcb_fin_message.p3302%type;

    subtype         t_p3901   is jcb_file.p3901%type;
    subtype         t_p3901_1 is jcb_file.p3901_1%type;
    subtype         t_p3901_2 is jcb_file.p3901_2%type;
    subtype         t_p3901_3 is jcb_file.p3901_3%type;
    subtype         t_p3901_4 is jcb_file.p3901_4%type;
    subtype         t_p3902   is jcb_file.p3902%type;    
    subtype         t_p3903   is jcb_file.p3903%type;    

    subtype         t_p3600   is jcb_add.p3600%type;    
    subtype         t_p3600_1 is jcb_add.p3600_1%type;
    subtype         t_p3600_2 is jcb_add.p3600_2%type;
    subtype         t_p3600_3 is jcb_add.p3600_3%type;
    subtype         t_p3601   is jcb_add.p3601%type;    
    subtype         t_p3602   is jcb_add.p3602%type;    
    subtype         t_p3604   is jcb_add.p3604%type;    

    subtype         t_pds_tag is number(4);
    subtype         t_pds_tag_chr is varchar2(4);
    subtype         t_pds_len is number(3);
    subtype         t_pds_len_chr is varchar2(3);
    subtype         t_pds_body is varchar2(992);
    subtype         t_de_body is varchar2(999);
    type            t_pds_tab is table of t_pds_body index by binary_integer;
    type            t_pds_row_tab is table of jcb_msg_pds%rowtype index by binary_integer;

    subtype         t_de_number is varchar2(5);
    subtype         t_severity_code is varchar2(2);
    subtype         t_message_code is varchar2(4);
    subtype         t_subfield_id is varchar2(3);

    type            t_fin_rec is record (   
        row_id              rowid
        , id                com_api_type_pkg.t_long_id
        , status            com_api_type_pkg.t_dict_value
        , inst_id           com_api_type_pkg.t_inst_id
        , network_id        com_api_type_pkg.t_tiny_id
        , file_id           com_api_type_pkg.t_short_id
        , is_incoming       com_api_type_pkg.t_boolean
        , is_reversal       com_api_type_pkg.t_boolean
        , is_rejected       com_api_type_pkg.t_boolean
        , dispute_id        com_api_type_pkg.t_long_id
        , dispute_rn        com_api_type_pkg.t_long_id
        , impact            com_api_type_pkg.t_sign
        , mti               t_mti
        , de002             t_de002
        , de003_1           t_de003s
        , de003_2           t_de003s
        , de003_3           t_de003s
        , de004             t_de004
        , de005             t_de005
        , de006             t_de006
        , de009             t_de009
        , de010             t_de010
        , de012             t_de012
        , de014             t_de014
        , de016             t_de016
        , de022_1           t_de022s
        , de022_2           t_de022s
        , de022_3           t_de022s
        , de022_4           t_de022s
        , de022_5           t_de022s
        , de022_6           t_de022s
        , de022_7           t_de022s
        , de022_8           t_de022s
        , de022_9           t_de022s
        , de022_10          t_de022s
        , de022_11          t_de022s
        , de022_12          t_de022s
        , de023             t_de023
        , de024             t_de024
        , de025             t_de025
        , de026             t_de026
        , de030_1           t_de030_1
        , de030_2           t_de030_2
        , de031             t_de031
        , de032             t_de032
        , de033             t_de033
        , de037             t_de037
        , de038             t_de038
        , de040             t_de040
        , de041             t_de041
        , de042             t_de042
        , de043_1           t_de043
        , de043_2           t_de043
        , de043_3           t_de043
        , de043_4           t_de043
        , de043_5           t_de043
        , de043_6           t_de043
        , de049             t_de049
        , de050             t_de050
        , de051             t_de051
        , de054             t_de054
        , de055             t_de055
        , de071             t_de071
        , de072             t_de072
        , de093             t_de093
        , de094             t_de094
        , de097             t_de097
        , de100             t_de100    
        , p3001             t_p3001
        , p3002             t_p3002
        , p3003             t_p3003
        , p3005             t_p3005
        , p3006             t_p3006
        , p3007_1           t_p3007_1
        , p3007_2           t_p3007_2
        , p3008             t_p3008
        , p3009             t_p3009
        , p3011             t_p3011
        , p3012             t_p3012
        , p3013             t_p3013
        , p3014             t_p3014
        , p3021             t_p3021
        , p3201             t_p3201
        , p3202             t_p3202
        , p3203             t_p3203
        , p3205             t_p3205
        , p3206             t_p3206
        , p3207             t_p3207
        , p3208             t_p3208
        , p3209             t_p3209
        , p3210             t_p3210
        , p3211             t_p3211
        , p3250             t_p3250
        , p3251             t_p3251
        , p3302             t_p3302
        , emv_9f26          com_api_type_pkg.t_auth_long_id
        , emv_9f02          com_api_type_pkg.t_medium_id
        , emv_9f27          com_api_type_pkg.t_byte_char
        , emv_9f10          varchar2(64)
        , emv_9f36          com_api_type_pkg.t_mcc
        , emv_95            com_api_type_pkg.t_postal_code
        , emv_82            com_api_type_pkg.t_mcc
        , emv_9a            date
        , emv_9c            com_api_type_pkg.t_byte_id
        , emv_9f37          com_api_type_pkg.t_dict_value
        , emv_5f2a          com_api_type_pkg.t_tiny_id
        , emv_9f33          com_api_type_pkg.t_auth_code
        , emv_9f34          com_api_type_pkg.t_auth_code
        , emv_9f1a          com_api_type_pkg.t_tiny_id
        , emv_9f35          com_api_type_pkg.t_byte_id
        --, emv_9f53          com_api_type_pkg.t_byte_char
        , emv_84            com_api_type_pkg.t_account_number
        , emv_9f09          com_api_type_pkg.t_mcc
        , emv_9f03          com_api_type_pkg.t_medium_id
        , emv_9f1e          com_api_type_pkg.t_auth_long_id
        , emv_9f41          com_api_type_pkg.t_short_id
        , emv_4f            com_api_type_pkg.t_auth_long_id
    );
    type            t_fin_tab is table of t_fin_rec index by binary_integer;
    type            t_fin_cur is ref cursor return t_fin_rec;

    type            t_add_rec is record (
        row_id              rowid
        , id                com_api_type_pkg.t_long_id
        , fin_id            com_api_type_pkg.t_long_id
        , file_id           com_api_type_pkg.t_short_id
        , is_incoming       com_api_type_pkg.t_boolean
        , mti               t_mti
        , de024             t_de024
        , de032             t_de032
        , de033             t_de033
        , de071             t_de071
        , de093             t_de093
        , de094             t_de094
        , de100             t_de100
        , p3600             t_p3600
        , p3600_1           t_p3600_1
        , p3600_2           t_p3600_2
        , p3600_3           t_p3600_3
        , p3601             t_p3601
        , p3602             t_p3602
        , p3604             t_p3604
    );
    type            t_add_tab is table of t_add_rec index by binary_integer;
    type            t_add_cur is ref cursor return t_add_rec;
    
    type            t_file_rec is record (
        id                  com_api_type_pkg.t_short_id
        , inst_id           com_api_type_pkg.t_inst_id
        , network_id        com_api_type_pkg.t_tiny_id
        , is_incoming       com_api_type_pkg.t_boolean
        , proc_date         date
        , session_file_id   com_api_type_pkg.t_long_id
        , is_rejected       com_api_type_pkg.t_boolean
        , reject_id         com_api_type_pkg.t_long_id
        , header_mti        t_mti
        , header_de024      t_de024
        , p3901             t_p3901
        , p3901_1           t_p3901_1
        , p3901_2           t_p3901_2
        , p3901_3           t_p3901_3 
        , p3901_4           t_p3901_4  
        , header_de071      t_de071
        , header_de100      t_de100
        , header_de033      t_de033
        , trailer_mti       t_mti
        , trailer_de024     t_de024
        , p3902             t_p3902
        , p3903             t_p3903
        , trailer_de071     t_de071
        , trailer_de100     t_de100
        , trailer_de033     t_de033
    );

    type            t_mes_rec is record (
        mti               t_mti
        , de002             t_de002
        , de003_1           t_de003s
        , de003_2           t_de003s
        , de003_3           t_de003s
        , de004             t_de004
        , de005             t_de005
        , de006             t_de006
        , de009             t_de009
        , de010             t_de010
        , de012             t_de012
        , de014             t_de014
        , de016             t_de016
        , de022_1           t_de022s
        , de022_2           t_de022s
        , de022_3           t_de022s
        , de022_4           t_de022s
        , de022_5           t_de022s
        , de022_6           t_de022s
        , de022_7           t_de022s
        , de022_8           t_de022s
        , de022_9           t_de022s
        , de022_10          t_de022s
        , de022_11          t_de022s
        , de022_12          t_de022s
        , de023             t_de023
        , de024             t_de024
        , de025             t_de025
        , de026             t_de026
        , de030_1           t_de030_1
        , de030_2           t_de030_2
        , de031             t_de031
        , de032             t_de032
        , de033             t_de033
        , de037             t_de037
        , de038             t_de038
        , de040             t_de040
        , de041             t_de041
        , de042             t_de042
        , de043_1           t_de043
        , de043_2           t_de043
        , de043_3           t_de043
        , de043_4           t_de043
        , de043_5           t_de043
        , de043_6           t_de043
        , de048             t_de048
        , de049             t_de049
        , de050             t_de050
        , de051             t_de051
        , de054             t_de054
        , de055             t_de055
        , de062             t_de062
        , de071             t_de071
        , de072             t_de072
        , de093             t_de093
        , de094             t_de094
        , de097             t_de097
        , de100             t_de100    
        , de123             t_de123
        , de124             t_de124
        , de125             t_de125
        , de126             t_de126
    );
    type            t_mes_tab is table of t_mes_rec index by binary_integer;

    type            t_p3005_rec is record (
        row_id              rowid
        , msg_id            com_api_type_pkg.t_long_id
        , p3005_1           t_p3005_1
        , p3005_2           t_p3005_2
        , p3005_3           t_p3005_3
        , p3005_4           t_p3005_4
        , p3005_5           t_p3005_5
        , p3005_6           t_p3005_6
        , p3005_7           t_p3005_7
        , p3005_8           t_p3005_8
        , p3005_9           t_p3005_9
        , p3005_10          t_p3005_10
    );
    type            t_p3005_tab is table of t_p3005_rec index by binary_integer;
    type            t_p3005_cur is ref cursor return t_p3005_rec;

    type            t_merchant_rec is record (
        record_type             com_api_type_pkg.t_byte_char
        , data_id               com_api_type_pkg.t_byte_char
        , reason_for_revision   com_api_type_pkg.t_byte_char
        , reason_for_cncl       com_api_type_pkg.t_byte_char
        , eff_date_for_cncl     com_api_type_pkg.t_dict_value
        , merchant_number       com_api_type_pkg.t_name --t_terminal_number
        , merchant_name         com_api_type_pkg.t_name --t_attr_name
        , mcc                   com_api_type_pkg.t_mcc
        , jcbi_sic_sub_code     com_api_type_pkg.t_byte_char
        , city_name             com_api_type_pkg.t_name --t_merchant_number
        , state_code            com_api_type_pkg.t_name --t_curr_code
        , type_merchant_class   com_api_type_pkg.t_byte_char
        , area_code_1           com_api_type_pkg.t_byte_char
        , area_code_2           com_api_type_pkg.t_byte_char
        , merchant_postal_code  com_api_type_pkg.t_name --t_postal_code
        , merchant_phone_number com_api_type_pkg.t_name --t_merchant_number
        , merchant_address_1    com_api_type_pkg.t_name --t_attr_name
        , merchant_address_2    com_api_type_pkg.t_attr_name
        , merchant_address_3    com_api_type_pkg.t_attr_name
        , merchant_address_4    com_api_type_pkg.t_attr_name
        , commission_rate       com_api_type_pkg.t_tag
        , floor_limit           com_api_type_pkg.t_region_code
        , company_name_1        com_api_type_pkg.t_attr_name
        , company_name_2        com_api_type_pkg.t_attr_name
        , company_postal_code   com_api_type_pkg.t_postal_code
        , company_phone_number  com_api_type_pkg.t_merchant_number
        , company_address_1     com_api_type_pkg.t_attr_name
        , company_address_2     com_api_type_pkg.t_attr_name
        , company_address_3     com_api_type_pkg.t_attr_name
        , company_address_4     com_api_type_pkg.t_attr_name
        , merchant_management   com_api_type_pkg.t_byte_char
        , licensee_id           com_api_type_pkg.t_name --t_tag
        , area_code_country     com_api_type_pkg.t_curr_code
        , area_code_continent   com_api_type_pkg.t_byte_char
        , pt_class_flag         com_api_type_pkg.t_byte_char
        , mag_crs_flag          com_api_type_pkg.t_byte_char
        , mo_information_flag   com_api_type_pkg.t_byte_char
        , cat_edc_flag          com_api_type_pkg.t_byte_char
        , d_r_type              com_api_type_pkg.t_byte_char
        , g_r_flag              com_api_type_pkg.t_byte_char    
        , express_flag          com_api_type_pkg.t_byte_char
        , adv_deposit_flag      com_api_type_pkg.t_byte_char
        , jl_merchant_flag      com_api_type_pkg.t_byte_char
        , sp_serv_flag          com_api_type_pkg.t_byte_char
        , mo_to_flag            com_api_type_pkg.t_byte_char
        , merchant_url          com_api_type_pkg.t_exponent
        , customer_phone_number com_api_type_pkg.t_terminal_number
        , product_id            com_api_type_pkg.t_short_id
        , merchant_id           com_api_type_pkg.t_medium_id
    );
    type           t_merchant_tab is table of t_merchant_rec index by binary_integer;

end;
/
