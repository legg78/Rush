create or replace package mcw_api_type_pkg is

    subtype         t_mti is mcw_fin.mti%type;
    subtype         t_de002 is mcw_card.card_number%type;
    subtype         t_de003 is varchar2(6);
    subtype         t_de003s is mcw_fin.de003_1%type;
    subtype         t_de004 is mcw_fin.de004%type;
    subtype         t_de005 is mcw_fin.de005%type;
    subtype         t_de006 is mcw_fin.de006%type;
    subtype         t_de009 is mcw_fin.de009%type;
    subtype         t_de010 is mcw_fin.de010%type;
    subtype         t_de012 is mcw_fin.de012%type;
    subtype         t_de014 is mcw_fin.de014%type;
    subtype         t_de022 is varchar2(12);
    subtype         t_de022s is mcw_fin.de022_1%type;
    subtype         t_de023 is mcw_fin.de023%type;
    subtype         t_de024 is mcw_fin.de024%type;
    subtype         t_de025 is mcw_fin.de025%type;
    subtype         t_de026 is mcw_fin.de026%type;
    subtype         t_de030 is varchar2(24);
    subtype         t_de030s is mcw_fin.de030_1%type;
    subtype         t_de031 is mcw_fin.de031%type;
    subtype         t_de032 is mcw_fin.de032%type;
    subtype         t_de033 is mcw_fin.de033%type;
    subtype         t_de037 is mcw_fin.de037%type;
    subtype         t_de038 is mcw_fin.de038%type;
    subtype         t_de040 is mcw_fin.de040%type;
    subtype         t_de041 is mcw_fin.de041%type;
    subtype         t_de042 is mcw_fin.de042%type;
    subtype         t_de043 is varchar2(999);
    subtype         t_de043_1 is mcw_fin.de043_1%type;
    subtype         t_de043_2 is mcw_fin.de043_2%type;
    subtype         t_de043_3 is mcw_fin.de043_3%type;
    subtype         t_de043_4 is mcw_fin.de043_4%type;
    subtype         t_de043_5 is mcw_fin.de043_5%type;
    subtype         t_de043_6 is mcw_fin.de043_6%type;
    subtype         t_de048 is varchar2(999);
    subtype         t_de049 is mcw_fin.de049%type;
    subtype         t_de050 is mcw_fin.de050%type;
    subtype         t_de051 is mcw_fin.de051%type;
    subtype         t_de054 is mcw_fin.de054%type;
    subtype         t_de055 is mcw_fin.de055%type;
    subtype         t_de062 is varchar2(999);
    subtype         t_de063 is mcw_fin.de063%type;
    subtype         t_de071 is mcw_fin.de071%type;
    subtype         t_de072 is mcw_fin.de072%type;
    subtype         t_de073 is mcw_fin.de073%type;
    subtype         t_de093 is mcw_fin.de093%type;
    subtype         t_de094 is mcw_fin.de094%type;
    subtype         t_de095 is mcw_fin.de095%type;
    subtype         t_de100 is mcw_fin.de100%type;
    subtype         t_de111 is mcw_fin.de111%type;
    subtype         t_de123 is varchar2(999);
    subtype         t_de124 is varchar2(999);
    subtype         t_de125 is varchar2(999);
    subtype         t_de127 is varchar2(999);

    subtype         t_p0001_1 is mcw_fin.p0001_1%type;
    subtype         t_p0001_2 is mcw_fin.p0001_2%type;
    subtype         t_p0002 is mcw_fin.p0002%type;
    subtype         t_p0004_1 is mcw_fin.p0004_1%type;
    subtype         t_p0004_2 is mcw_fin.p0004_2%type;
    subtype         t_p0005 is mcw_reject.p0005%type;
    subtype         t_p0006 is mcw_reject.p0006%type;
    subtype         t_p0014 is mcw_card.p0014%type;
    subtype         t_p0018 is mcw_fin.p0018%type;
    subtype         t_p0021 is mcw_fin.p0021%type;
    subtype         t_p0022 is mcw_fin.p0022%type;
    subtype         t_p0023 is mcw_fin.p0023%type;
    subtype         t_p0025 is mcw_reject.p0025%type;
    subtype         t_p0025_1 is mcw_fin.p0025_1%type;
    subtype         t_p0025_2 is mcw_fin.p0025_2%type;
    subtype         t_p0026 is mcw_file.p0026%type;
    subtype         t_p0028 is mcw_fin.p0028%type;
    subtype         t_p0029 is mcw_fin.p0029%type;
    subtype         t_p0042 is mcw_fin.p0042%type;
    subtype         t_p0043 is mcw_fin.p0043%type;
    subtype         t_p0045 is mcw_fin.p0045%type;
    subtype         t_p0047 is mcw_fin.p0047%type;
    subtype         t_p0052 is mcw_fin.p0052%type;
    subtype         t_p0058 is mcw_fin.p0058%type;
    subtype         t_p0059 is mcw_fin.p0059%type;
    subtype         t_p0072 is mcw_fin.p0072%type;
    subtype         t_p0105 is mcw_file.p0105%type;
    subtype         t_p0110 is mcw_file.p0110%type;
    subtype         t_p0122 is mcw_file.p0122%type;
    subtype         t_p0137 is mcw_fin.p0137%type;
    subtype         t_p0138 is mcw_reject.p0138%type;
    subtype         t_p0146 is mcw_fin.p0146%type;
    subtype         t_p0146_net is mcw_fin.p0146_net%type;
    subtype         t_p0147 is mcw_fin.p0147%type;
    subtype         t_p0148 is mcw_fin.p0148%type;
    subtype         t_p0149_1 is mcw_fin.p0149_1%type;
    subtype         t_p0149_2 is mcw_fin.p0149_2%type;
    subtype         t_p0158_1 is mcw_fin.p0158_1%type;
    subtype         t_p0158_2 is mcw_fin.p0158_2%type;
    subtype         t_p0158_3 is mcw_fin.p0158_3%type;
    subtype         t_p0158_4 is mcw_fin.p0158_4%type;
    subtype         t_p0158_5 is mcw_fin.p0158_5%type;
    subtype         t_p0158_6 is mcw_fin.p0158_6%type;
    subtype         t_p0158_7 is mcw_fin.p0158_7%type;
    subtype         t_p0158_8 is mcw_fin.p0158_8%type;
    subtype         t_p0158_9 is mcw_fin.p0158_9%type;
    subtype         t_p0158_10 is mcw_fin.p0158_10%type;
    subtype         t_p0158_11 is mcw_fin.p0158_11%type;
    subtype         t_p0158_12 is mcw_fin.p0158_12%type;
    subtype         t_p0158_13 is mcw_fin.p0158_13%type;
    subtype         t_p0158_14 is mcw_fin.p0158_14%type;
    subtype         t_p0159_1 is mcw_fin.p0159_1%type;
    subtype         t_p0159_2 is mcw_fin.p0159_2%type;
    subtype         t_p0159_3 is mcw_fin.p0159_3%type;
    subtype         t_p0159_4 is mcw_fin.p0159_4%type;
    subtype         t_p0159_5 is mcw_fin.p0159_5%type;
    subtype         t_p0159_6 is mcw_fin.p0159_6%type;
    subtype         t_p0159_7 is mcw_fin.p0159_7%type;
    subtype         t_p0159_8 is mcw_fin.p0159_8%type;
    subtype         t_p0159_9 is mcw_fin.p0159_9%type;
    subtype         t_p0164_1 is mcw_currency_rate.p0164_1%type;
    subtype         t_p0164_2 is mcw_currency_rate.p0164_2%type;
    subtype         t_p0164_3 is mcw_currency_rate.p0164_3%type;
    subtype         t_p0164_4 is mcw_currency_rate.p0164_4%type;
    subtype         t_p0164_5 is mcw_currency_rate.p0164_5%type;
    subtype         t_p0165 is mcw_fin.p0165%type;
    subtype         t_p0176 is mcw_fin.p0176%type;
    subtype         t_p0181 is mcw_fin.p0181%type;
    subtype         t_p0184 is mcw_fin.p0184%type;
    subtype         t_p0185 is mcw_fin.p0185%type;
    subtype         t_p0186 is mcw_fin.p0186%type;
    subtype         t_p0198 is mcw_fin.p0198%type;
    subtype         t_p0200_1 is mcw_fin.p0200_1%type;
    subtype         t_p0200_2 is mcw_fin.p0200_2%type;
    subtype         t_p0207 is mcw_fin.p0207%type;
    subtype         t_p0208_1 is mcw_fin.p0208_1%type;
    subtype         t_p0208_2 is mcw_fin.p0208_2%type;
    subtype         t_p0209   is mcw_fin.p0209%type;
    subtype         t_p0210_1 is mcw_fin.p0210_1%type;
    subtype         t_p0210_2 is mcw_fin.p0210_2%type;
    subtype         t_p0228 is mcw_fin.p0228%type;
    subtype         t_p0230 is mcw_fin.p0230%type;
    subtype         t_p0241 is mcw_fin.p0241%type;
    subtype         t_p0243 is mcw_fin.p0243%type;
    subtype         t_p0244 is mcw_fin.p0244%type;
    subtype         t_p0260 is mcw_fin.p0260%type;
    subtype         t_p0261 is mcw_fin.p0261%type;
    subtype         t_p0262 is mcw_fin.p0262%type;
    subtype         t_p0264 is mcw_fin.p0264%type;
    subtype         t_p0265 is mcw_fin.p0265%type;
    subtype         t_p0266 is mcw_fin.p0266%type;
    subtype         t_p0267 is mcw_fin.p0267%type;
    subtype         t_p0268_1 is mcw_fin.p0268_1%type;
    subtype         t_p0268_2 is mcw_fin.p0268_2%type;
    subtype         t_p1001 is mcw_fin.p1001%type;
    subtype         t_p0280 is mcw_reject.p0280%type;
    subtype         t_p0300 is mcw_fpd.p0300%type;
    subtype         t_p0301 is mcw_file.p0301%type;
    subtype         t_p0302 is mcw_fpd.p0302%type;
    subtype         t_p0306 is mcw_file.p0306%type;
    subtype         t_p0358_1 is mcw_fpd.p0358_1%type;
    subtype         t_p0358_2 is mcw_fpd.p0358_2%type;
    subtype         t_p0358_3 is mcw_fpd.p0358_3%type;
    subtype         t_p0358_4 is mcw_fpd.p0358_4%type;
    subtype         t_p0358_5 is mcw_fpd.p0358_5%type;
    subtype         t_p0358_6 is mcw_fpd.p0358_6%type;
    subtype         t_p0358_7 is mcw_fpd.p0358_7%type;
    subtype         t_p0358_8 is mcw_fpd.p0358_8%type;
    subtype         t_p0358_9 is mcw_fpd.p0358_9%type;
    subtype         t_p0358_10 is mcw_fpd.p0358_10%type;
    subtype         t_p0358_11 is mcw_fpd.p0358_11%type;
    subtype         t_p0358_12 is mcw_fpd.p0358_12%type;
    subtype         t_p0358_13 is mcw_fpd.p0358_13%type;
    subtype         t_p0358_14 is mcw_fpd.p0358_14%type;
    subtype         t_p0359 is mcw_spd.p0359%type;
    subtype         t_p0367 is mcw_spd.p0367%type;
    subtype         t_p0368 is mcw_spd.p0368%type;
    subtype         t_p0369 is mcw_spd.p0369%type;
    subtype         t_p0370_1 is mcw_fpd.p0370_1%type;
    subtype         t_p0370_2 is mcw_fpd.p0370_2%type;
    subtype         t_p0372_1 is mcw_fpd.p0372_1%type;
    subtype         t_p0372_2 is mcw_fpd.p0372_2%type;
    subtype         t_p0374 is mcw_fpd.p0374%type;
    subtype         t_p0375 is mcw_fin.p0375%type;
    subtype         t_p0378 is mcw_fpd.p0378%type;
    subtype         t_p0380_1 is mcw_fpd.p0380_1%type;
    subtype         t_p0380_2 is mcw_fpd.p0380_2%type;
    subtype         t_p0381_1 is mcw_fpd.p0381_1%type;
    subtype         t_p0381_2 is mcw_fpd.p0381_2%type;
    subtype         t_p0384_1 is mcw_fpd.p0384_1%type;
    subtype         t_p0384_2 is mcw_fpd.p0384_2%type;
    subtype         t_p0390_1 is mcw_fpd.p0390_1%type;
    subtype         t_p0390_2 is mcw_fpd.p0390_2%type;
    subtype         t_p0391_1 is mcw_fpd.p0391_1%type;
    subtype         t_p0391_2 is mcw_fpd.p0391_2%type;
    subtype         t_p0392 is mcw_fpd.p0392%type;
    subtype         t_p0393 is mcw_fpd.p0393%type;
    subtype         t_p0394_1 is mcw_fpd.p0394_1%type;
    subtype         t_p0394_2 is mcw_fpd.p0394_2%type;
    subtype         t_p0395_1 is mcw_fpd.p0395_1%type;
    subtype         t_p0395_2 is mcw_fpd.p0395_2%type;
    subtype         t_p0396_1 is mcw_fpd.p0396_1%type;
    subtype         t_p0396_2 is mcw_fpd.p0396_2%type;
    subtype         t_p0397   is mcw_fpd.p0397%type;
    subtype         t_p0398   is mcw_fpd.p0398%type;
    subtype         t_p0399_1 is mcw_fpd.p0399_1%type;
    subtype         t_p0399_2 is mcw_fpd.p0399_2%type;
    subtype         t_p0400 is mcw_fpd.p0400%type;
    subtype         t_p0401 is mcw_fpd.p0401%type;
    subtype         t_p0402 is mcw_fpd.p0402%type;
    subtype         t_p0501_1 is mcw_add.p0501_1%type;
    subtype         t_p0501_2 is mcw_add.p0501_2%type;
    subtype         t_p0501_3 is mcw_add.p0501_3%type;
    subtype         t_p0501_4 is mcw_add.p0501_4%type;
    subtype         t_p0674   is mcw_fin.p0674%type;
    subtype         t_p0715   is mcw_add.p0715%type;
    subtype         t_ext_claim_id is mcw_fin.ext_claim_id%type;
    subtype         t_ext_message_id is mcw_fin.ext_message_id%type;
    subtype         t_ext_msg_status is mcw_fin.ext_msg_status%type;

    subtype         t_pds_tag is number(4);
    subtype         t_pds_tag_chr is varchar2(4);
    subtype         t_pds_len is number(3);
    subtype         t_pds_len_chr is varchar2(3);
    subtype         t_pds_body is varchar2(992);
    subtype         t_de_body is varchar2(999);
    type            t_pds_tab is table of t_pds_body index by binary_integer;
    type            t_pds_row_tab is table of mcw_msg_pds%rowtype index by binary_integer;

    subtype         t_de_number is varchar2(5);
    subtype         t_severity_code is varchar2(2);
    subtype         t_message_code is varchar2(4);
    subtype         t_subfield_id is varchar2(3);

    type            t_fin_rec is record (
        row_id              rowid
        , id                com_api_type_pkg.t_long_id
        , inst_id           com_api_type_pkg.t_inst_id
        , network_id        com_api_type_pkg.t_tiny_id
        , file_id           com_api_type_pkg.t_short_id
        , status            com_api_type_pkg.t_dict_value
        , impact            com_api_type_pkg.t_sign
        , is_incoming       com_api_type_pkg.t_boolean
        , is_reversal       com_api_type_pkg.t_boolean
        , is_rejected       com_api_type_pkg.t_boolean
        , is_fpd_matched    com_api_type_pkg.t_boolean
        , is_fsum_matched   com_api_type_pkg.t_boolean
        , dispute_id        com_api_type_pkg.t_long_id
        , dispute_rn        com_api_type_pkg.t_long_id
        , fpd_id            com_api_type_pkg.t_long_id
        , fsum_id           com_api_type_pkg.t_long_id
        , mti               t_mti
        , de002             t_de002
        , de003_1           t_de003
        , de003_2           t_de003
        , de003_3           t_de003
        , de004             t_de004
        , de005             t_de005
        , de006             t_de006
        , de009             t_de009
        , de010             t_de010
        , de012             t_de012
        , de014             t_de014
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
        , de030_1           t_de030s
        , de030_2           t_de030s
        , de031             t_de031
        , de032             t_de032
        , de033             t_de033
        , de037             t_de037
        , de038             t_de038
        , de040             t_de040
        , de041             t_de041
        , de042             t_de042
        , de043_1           t_de043_1
        , de043_2           t_de043_2
        , de043_3           t_de043_3
        , de043_4           t_de043_4
        , de043_5           t_de043_5
        , de043_6           t_de043_6
        , de049             t_de049
        , de050             t_de050
        , de051             t_de051
        , de054             t_de054
        , de055             t_de055
        , de063             t_de063
        , de071             t_de071
        , de072             t_de072
        , de073             t_de073
        , de093             t_de093
        , de094             t_de094
        , de095             t_de095
        , de100             t_de100
        , de111             t_de111
        , p0001_1           t_p0001_1
        , p0001_2           t_p0001_2
        , p0002             t_p0002
        , p0004_1           t_p0004_1
        , p0004_2           t_p0004_2
        , p0014             t_p0014
        , p0018             t_p0018
        , p0021             t_p0021
        , p0022             t_p0022
        , p0023             t_p0023
        , p0025_1           t_p0025_1
        , p0025_2           t_p0025_2
        , p0028             t_p0028
        , p0029             t_p0029
        , p0042             t_p0042
        , p0043             t_p0043
        , p0045             t_p0045
        , p0047             t_p0047
        , p0052             t_p0052
        , p0058             t_p0058
        , p0059             t_p0059
        , p0072             t_p0072
        , p0137             t_p0137
        , p0146             t_p0146
        , p0146_net         t_p0146_net
        , p0147             t_p0147
        , p0148             t_p0148
        , p0149_1           t_p0149_1
        , p0149_2           t_p0149_2
        , p0158_1           t_p0158_1
        , p0158_2           t_p0158_2
        , p0158_3           t_p0158_3
        , p0158_4           t_p0158_4
        , p0158_5           t_p0158_5
        , p0158_6           t_p0158_6
        , p0158_7           t_p0158_7
        , p0158_8           t_p0158_8
        , p0158_9           t_p0158_9
        , p0158_10          t_p0158_10
        , p0158_11          t_p0158_11
        , p0158_12          t_p0158_12
        , p0158_13          t_p0158_13
        , p0158_14          t_p0158_14
        , p0159_1           t_p0159_1
        , p0159_2           t_p0159_2
        , p0159_3           t_p0159_3
        , p0159_4           t_p0159_4
        , p0159_5           t_p0159_5
        , p0159_6           t_p0159_6
        , p0159_7           t_p0159_7
        , p0159_8           t_p0159_8
        , p0159_9           t_p0159_9
        , p0165             t_p0165
        , p0176             t_p0176
        , p0181             t_p0181
        , p0184             t_p0184
        , p0185             t_p0185
        , p0186             t_p0186
        , p0198             t_p0198
        , p0200_1           t_p0200_1
        , p0200_2           t_p0200_2
        , p0207             t_p0207
        , p0208_1           t_p0208_1
        , p0208_2           t_p0208_2
        , p0209             t_p0209
        , p0210_1           t_p0210_1
        , p0210_2           t_p0210_2
        , p0228             t_p0228
        , p0230             t_p0230
        , p0241             t_p0241
        , p0243             t_p0243
        , p0244             t_p0244
        , p0260             t_p0260
        , p0261             t_p0261
        , p0262             t_p0262
        , p0264             t_p0264
        , p0265             t_p0265
        , p0266             t_p0266
        , p0267             t_p0267
        , p0268_1           t_p0268_1
        , p0268_2           t_p0268_2
        , p0375             t_p0375
        , p0674             t_p0674
        , p1001             t_p1001
        , emv_9f26          com_api_type_pkg.t_auth_long_id
        , emv_9f02          com_api_type_pkg.t_medium_id
        , emv_9f27          com_api_type_pkg.t_byte_char
        , emv_9f10          varchar2(64)
        , emv_9f36          com_api_type_pkg.t_mcc
        , emv_95            com_api_type_pkg.t_postal_code
        , emv_82            com_api_type_pkg.t_mcc
        , emv_9a            date
        , emv_9c            number(2)
        , emv_9f37          com_api_type_pkg.t_dict_value
        , emv_5f2a          com_api_type_pkg.t_tiny_id
        , emv_9f33          com_api_type_pkg.t_auth_code
        , emv_9f34          com_api_type_pkg.t_auth_code
        , emv_9f1a          com_api_type_pkg.t_tiny_id
        , emv_9f35          number(2)
        , emv_9f53          com_api_type_pkg.t_byte_char
        , emv_84            com_api_type_pkg.t_account_number
        , emv_9f09          com_api_type_pkg.t_mcc
        , emv_9f03          com_api_type_pkg.t_medium_id
        , emv_9f1e          com_api_type_pkg.t_auth_long_id
        , emv_9f41          com_api_type_pkg.t_short_id
        , local_message     com_api_type_pkg.t_boolean
        , ird_trace         com_api_type_pkg.t_full_desc
        , ext_claim_id      t_ext_claim_id
        , ext_message_id    t_ext_message_id
        , msg_type          com_api_type_pkg.t_dict_value
        , ext_msg_status    t_ext_msg_status
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
        , de063             t_de063
        , de071             t_de071
        , de093             t_de093
        , de094             t_de094
        , de100             t_de100
        , p0501_1           t_p0501_1
        , p0501_2           t_p0501_2
        , p0501_3           t_p0501_3
        , p0501_4           t_p0501_4
        , p0715             t_p0715
    );
    type            t_add_tab is table of t_add_rec index by binary_integer;
    type            t_add_cur is ref cursor return t_add_rec;

    type         t_file_rec is record (
        id                com_api_type_pkg.t_short_id
        , inst_id         com_api_type_pkg.t_inst_id
        , network_id      com_api_type_pkg.t_tiny_id
        , is_incoming     com_api_type_pkg.t_boolean
        , proc_date       date
        , session_file_id com_api_type_pkg.t_long_id
        , is_rejected     com_api_type_pkg.t_boolean
        , reject_id       com_api_type_pkg.t_long_id
        , p0026           t_p0026
        , p0105           t_p0105
        , p0110           t_p0110
        , p0122           t_p0122
        , p0301           t_p0301
        , p0306           t_p0306
        , header_mti      t_mti
        , header_de024    t_de024
        , header_de071    t_de071
        , trailer_mti     t_mti
        , trailer_de024   t_de024
        , trailer_de071   t_de071
        , local_file      com_api_type_pkg.t_boolean
    );

    type            t_mes_rec is record (
        mti               t_mti
        , de002           t_de002
        , de003_1         t_de003
        , de003_2         t_de003
        , de003_3         t_de003
        , de004           t_de004
        , de005           t_de005
        , de006           t_de006
        , de009           t_de009
        , de010           t_de010
        , de012           t_de012
        , de014           t_de014
        , de022_1         t_de022s
        , de022_2         t_de022s
        , de022_3         t_de022s
        , de022_4         t_de022s
        , de022_5         t_de022s
        , de022_6         t_de022s
        , de022_7         t_de022s
        , de022_8         t_de022s
        , de022_9         t_de022s
        , de022_10        t_de022s
        , de022_11        t_de022s
        , de022_12        t_de022s
        , de023           t_de023
        , de024           t_de024
        , de025           t_de025
        , de026           t_de026
        , de030_1         t_de030s
        , de030_2         t_de030s
        , de031           t_de031
        , de032           t_de032
        , de033           t_de033
        , de037           t_de037
        , de038           t_de038
        , de040           t_de040
        , de041           t_de041
        , de042           t_de042
        , de043_1         t_de043_1
        , de043_2         t_de043_2
        , de043_3         t_de043_3
        , de043_4         t_de043_4
        , de043_5         t_de043_5
        , de043_6         t_de043_6
        , de048           t_de048
        , de049           t_de049
        , de050           t_de050
        , de051           t_de051
        , de054           t_de054
        , de055           t_de055
        , de062           t_de062
        , de063           t_de063
        , de071           t_de071
        , de072           t_de072
        , de073           t_de073
        , de093           t_de093
        , de094           t_de094
        , de095           t_de095
        , de100           t_de100
        , de111           t_de111
        , de123           t_de123
        , de124           t_de124
        , de125           t_de125
        , de127           t_de127
    );
    type            t_mes_tab is table of t_mes_rec index by binary_integer;

    type            t_cur_update_rec is record (
        id                  com_api_type_pkg.t_long_id
        , network_id        com_api_type_pkg.t_tiny_id
        , inst_id           com_api_type_pkg.t_inst_id
        , file_id           com_api_type_pkg.t_short_id
        , mti               t_mti
        , de024             t_de024
        , de050             t_de050
        , de071             t_de071
        , de093             t_de093
        , de094             t_de094
        , de100             t_de100
    );
    type            t_cur_update_tab is table of t_cur_update_rec index by binary_integer;

    type            t_cur_rate_rec is record (
        id                  com_api_type_pkg.t_long_id
        , p0164_1           t_p0164_1
        , p0164_2           t_p0164_2
        , p0164_3           t_p0164_3
        , p0164_4           t_p0164_4
        , p0164_5           t_p0164_5
        , de050             t_de050
    );
    type            t_cur_rate_tab is table of t_cur_rate_rec index by binary_integer;

    type            t_fpd_rec is record (
        id                  com_api_type_pkg.t_long_id
        , network_id        com_api_type_pkg.t_tiny_id
        , inst_id           com_api_type_pkg.t_inst_id
        , file_id           com_api_type_pkg.t_short_id
        , status            com_api_type_pkg.t_dict_value
        , mti               t_mti
        , de024             t_de024
        , de025             t_de025
        , de026             t_de026
        , de049             t_de049
        , de050             t_de050
        , de071             t_de071
        , de093             t_de093
        , de100             t_de100
        , p0014             t_p0014
        , p0148             t_p0148
        , p0165             t_p0165
        , p0300             t_p0300
        , p0302             t_p0302
        , p0358_1           t_p0358_1
        , p0358_2           t_p0358_2
        , p0358_3           t_p0358_3
        , p0358_4           t_p0358_4
        , p0358_5           t_p0358_5
        , p0358_6           t_p0358_6
        , p0358_7           t_p0358_7
        , p0358_8           t_p0358_8
        , p0358_9           t_p0358_9
        , p0358_10          t_p0358_10
        , p0358_11          t_p0358_11
        , p0358_12          t_p0358_12
        , p0358_13          t_p0358_13
        , p0358_14          t_p0358_14
        , p0370_1           t_p0370_1
        , p0370_2           t_p0370_2
        , p0372_1           t_p0372_1
        , p0372_2           t_p0372_1
        , p0374             t_p0374
        , p0375             t_p0375
        , p0378             t_p0378
        , p0380_1           t_p0380_1
        , p0380_2           t_p0380_2
        , p0381_1           t_p0381_1
        , p0381_2           t_p0381_2
        , p0384_1           t_p0384_1
        , p0384_2           t_p0384_2
        , p0390_1           t_p0390_1
        , p0390_2           t_p0390_2
        , p0391_1           t_p0391_1
        , p0391_2           t_p0391_2
        , p0392             t_p0392
        , p0393             t_p0393
        , p0394_1           t_p0394_1
        , p0394_2           t_p0394_2
        , p0395_1           t_p0395_1
        , p0395_2           t_p0395_2
        , p0396_1           t_p0396_1
        , p0396_2           t_p0396_2
        , p0400             t_p0400
        , p0401             t_p0401
        , p0402             t_p0402
        , p0397             t_p0397
        , p0398             t_p0398
        , p0399_1           t_p0399_1
        , p0399_2           t_p0399_2
        , is_grouped        com_api_type_pkg.t_boolean
    );
    type            t_fpd_tab is table of t_fpd_rec index by binary_integer;

    type            t_spd_rec is record (
        id                  com_api_type_pkg.t_long_id
        , network_id        com_api_type_pkg.t_tiny_id
        , inst_id           com_api_type_pkg.t_inst_id
        , file_id           com_api_type_pkg.t_short_id
        , status            com_api_type_pkg.t_dict_value
        , mti               t_mti
        , de024             t_de024
        , de025             t_de025
        , de049             t_de049
        , de050             t_de050
        , de071             t_de071
        , de093             t_de093
        , de100             t_de100
        , p0148             t_p0148
        , p0300             t_p0300
        , p0302             t_p0302
        , p0359             t_p0359
        , p0367             t_p0367
        , p0368             t_p0368
        , p0369             t_p0369
        , p0370_1           t_p0370_1
        , p0370_2           t_p0370_2
        , p0390_1           t_p0390_1
        , p0390_2           t_p0390_2
        , p0391_1           t_p0391_1
        , p0391_2           t_p0391_2
        , p0392             t_p0392
        , p0393             t_p0393
        , p0394_1           t_p0394_1
        , p0394_2           t_p0394_2
        , p0395_1           t_p0395_1
        , p0395_2           t_p0395_2
        , p0396_1           t_p0396_1
        , p0396_2           t_p0396_2
        , p0397             t_p0397
        , p0398             t_p0398
        , p0399_1           t_p0399_1
        , p0399_2           t_p0399_2
    );
    type            t_spd_tab is table of t_spd_rec index by binary_integer;

    type            t_fsum_rec is record (
        id                  com_api_type_pkg.t_long_id
        , network_id        com_api_type_pkg.t_tiny_id
        , inst_id           com_api_type_pkg.t_inst_id
        , file_id           com_api_type_pkg.t_short_id
        , status            com_api_type_pkg.t_dict_value
        , mti               t_mti
        , de024             t_de024
        , de025             t_de025
        , de049             t_de049
        , de071             t_de071
        , de093             t_de093
        , de100             t_de100
        , p0148             t_p0148
        , p0300             t_p0300
        , p0380_1           t_p0380_1
        , p0380_2           t_p0380_2
        , p0381_1           t_p0381_1
        , p0381_2           t_p0381_2
        , p0384_1           t_p0384_1
        , p0384_2           t_p0384_2
        , p0400             t_p0400
        , p0401             t_p0401
        , p0402             t_p0402
        , local_file        com_api_type_pkg.t_boolean
        , is_grouped        com_api_type_pkg.t_boolean
    );
    type            t_fsum_tab is table of t_fsum_rec index by binary_integer;

    type            t_reject_rec is record (
        id                  com_api_type_pkg.t_long_id
        , network_id        com_api_type_pkg.t_tiny_id
        , inst_id           com_api_type_pkg.t_inst_id
        , file_id           com_api_type_pkg.t_short_id
        , rejected_fin_id   com_api_type_pkg.t_long_id
        , rejected_file_id  com_api_type_pkg.t_short_id
        , mti               t_mti
        , de024             t_de024
        , de071             t_de071
        , de072             t_de072
        , de093             t_de093
        , de094             t_de094
        , de100             t_de100
        , p0005             t_p0005
        , p0006             t_p0006
        , p0025             t_p0025
        , p0026             t_p0026
        , p0138             t_p0138
        , p0165             t_p0165
        , p0280             t_p0280
    );
    type            t_reject_tab is table of t_reject_rec index by binary_integer;

    type            t_reject_code_rec is record (
        id                  com_api_type_pkg.t_long_id
        , de_number         t_de_number
        , severity_code     t_severity_code
        , message_code      t_message_code
        , subfield_id       t_subfield_id
    );
    type            t_reject_code_tab is table of t_reject_code_rec index by binary_integer;

    type            t_text_rec is record (
        id                  com_api_type_pkg.t_long_id
        , network_id        com_api_type_pkg.t_tiny_id
        , inst_id           com_api_type_pkg.t_inst_id
        , file_id           com_api_type_pkg.t_short_id
        , mti               t_mti
        , de024             t_de024
        , de025             t_de025
        , de071             t_de071
        , de072             t_de072
        , de093             t_de093
        , de094             t_de094
        , de100             t_de100
    );
    type            t_text_tab is table of t_text_rec index by binary_integer;

    type            t_reconcile_total_rec is record (
        amount_transaction       t_p0380_2
        , amount_reconciliation  t_p0380_2
        , rate                   com_api_type_pkg.t_rate
        , count_transaction      com_api_type_pkg.t_long_id
        , count_vs_fee           com_api_type_pkg.t_long_id
        , sttl_amount            t_p0380_2
        , max_sttl_amount        t_de004
        , max_sttl_amount_id     com_api_type_pkg.t_long_id
        , amount_delta           com_api_type_pkg.t_money /*number ??*/
    );

    subtype t_fraud_rec is mcw_fraud%rowtype ;

    function get_clearing_file_ack_status (
         i_file_id      in com_api_type_pkg.t_long_id    -- mcw_file.id
       , i_is_incoming  in com_api_type_pkg.t_boolean    -- mcw_file.is_incoming
       , i_is_rejected  in com_api_type_pkg.t_boolean    -- mcw_file.i_is_rejected
       , i_status       in com_api_type_pkg.t_dict_value -- prc_session_file.status
    ) return com_api_type_pkg.t_dict_value ;

    type  t_cu_data_group_1_rec is record (
        cmid                       com_api_type_pkg.t_cmid
        , n_month                  com_api_type_pkg.t_tiny_id
        , group_name               com_api_type_pkg.t_name
        , param_name               com_api_type_pkg.t_name
        , nn_trans                 com_api_type_pkg.t_medium_id
        , amount                   com_api_type_pkg.t_money
    );
    type  t_cu_data_group_1_tab is table of t_cu_data_group_1_rec index by binary_integer;

    type  t_cu_data_group_2_rec is record (
        cmid                       com_api_type_pkg.t_cmid
        , param_name               com_api_type_pkg.t_name
        , group_name               com_api_type_pkg.t_name
        , nn                       com_api_type_pkg.t_medium_id
    );

    type  t_cu_data_group_2_tab is table of t_cu_data_group_2_rec index by binary_integer;

    type  t_cu_data_group_3_rec is record (
          cmid                       com_api_type_pkg.t_cmid
          , mcc                      com_api_type_pkg.t_mcc
          , nn                       com_api_type_pkg.t_medium_id
    );

    type  t_cu_data_group_3_tab is table of t_cu_data_group_3_rec index by binary_integer;

    type  t_cu_data_group_4_rec is record (
          cmid                       com_api_type_pkg.t_cmid
          , n_month                  com_api_type_pkg.t_tiny_id
          , param_name               com_api_type_pkg.t_name
          , group_name               com_api_type_pkg.t_name
          , card_type                com_api_type_pkg.t_name
          , nn                       com_api_type_pkg.t_medium_id
          , amount                   com_api_type_pkg.t_money
    );

    type  t_cu_data_group_4_tab is table of t_cu_data_group_4_rec index by binary_integer;

    type  t_cu_data_group_5_rec is record (
          cmid                       com_api_type_pkg.t_cmid
          , month_num                com_api_type_pkg.t_tiny_id
          , param_name               com_api_type_pkg.t_name
          , card_type                com_api_type_pkg.t_name
          , nn_acct                  com_api_type_pkg.t_medium_id
          , nn_card                  com_api_type_pkg.t_medium_id
    );

    type  t_cu_data_group_5_tab is table of t_cu_data_group_5_rec index by binary_integer;

    type  t_cu_data_group_6_rec is record (
          cmid                       com_api_type_pkg.t_cmid
          , n_month                  com_api_type_pkg.t_tiny_id
          , param_name               com_api_type_pkg.t_name
          , group_parent_name        com_api_type_pkg.t_name
          , group_name               com_api_type_pkg.t_name
          , nn                       com_api_type_pkg.t_medium_id
          , amount                   com_api_type_pkg.t_money
    );

    type  t_cu_data_group_6_tab is table of t_cu_data_group_6_rec index by binary_integer;

    type            t_mcw_250byte_file_rec is record (
          id                      com_api_type_pkg.t_long_id
        , header_mti              com_api_type_pkg.t_mcc
        , sttl_date               date
        , processor_id            com_api_type_pkg.t_postal_code
        , record_size             com_api_type_pkg.t_byte_id
        , file_type               com_api_type_pkg.t_byte_char
        , version                 com_api_type_pkg.t_postal_code
        , session_file_id         com_api_type_pkg.t_long_id
        , inst_id                 com_api_type_pkg.t_inst_id
        , network_id              com_api_type_pkg.t_inst_id
        , total_count             com_api_type_pkg.t_medium_id
    );
end;
/
