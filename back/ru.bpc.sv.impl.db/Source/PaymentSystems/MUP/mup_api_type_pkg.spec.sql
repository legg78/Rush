create or replace package mup_api_type_pkg is

    subtype         t_mti is mup_fin.mti%type;
    subtype         t_de002 is mup_card.card_number%type;
    subtype         t_de003 is varchar2(6);
    subtype         t_de003s is mup_fin.de003_1%type;
    subtype         t_de004 is mup_fin.de004%type;
    subtype         t_de005 is mup_fin.de005%type;
    subtype         t_de006 is mup_fin.de006%type;
    subtype         t_de009 is mup_fin.de009%type;
    subtype         t_de010 is mup_fin.de010%type;
    subtype         t_de012 is mup_fin.de012%type;
    subtype         t_de014 is mup_fin.de014%type;
    subtype         t_de022 is varchar2(12);
    subtype         t_de022s is mup_fin.de022_1%type;
    subtype         t_de023 is mup_fin.de023%type;
    subtype         t_de024 is mup_fin.de024%type;
    subtype         t_de025 is mup_fin.de025%type;
    subtype         t_de026 is mup_fin.de026%type;
    subtype         t_de030 is varchar2(24);
    subtype         t_de030s is mup_fin.de030_1%type;
    subtype         t_de031 is mup_fin.de031%type;
    subtype         t_de032 is mup_fin.de032%type;
    subtype         t_de033 is mup_fin.de033%type;
    subtype         t_de037 is mup_fin.de037%type;
    subtype         t_de038 is mup_fin.de038%type;
    subtype         t_de040 is mup_fin.de040%type;
    subtype         t_de041 is mup_fin.de041%type;
    subtype         t_de042 is mup_fin.de042%type;
    subtype         t_de043 is mup_fin.de043_1%type;
    subtype         t_de048 is varchar2(999);
    subtype         t_de049 is mup_fin.de049%type;
    subtype         t_de050 is mup_fin.de050%type;
    subtype         t_de051 is mup_fin.de051%type;
    subtype         t_de054 is mup_fin.de054%type;
    subtype         t_de055 is mup_fin.de055%type;
    subtype         t_de062 is varchar2(999);
    subtype         t_de063 is mup_fin.de063%type;
    subtype         t_de071 is mup_fin.de071%type;
    subtype         t_de072 is mup_fin.de072%type;
    subtype         t_de073 is mup_fin.de073%type;
    subtype         t_de093 is mup_fin.de093%type;
    subtype         t_de094 is mup_fin.de094%type;
    subtype         t_de095 is mup_fin.de095%type;
    subtype         t_de100 is mup_fin.de100%type;
    subtype         t_de123 is varchar2(999);
    subtype         t_de124 is varchar2(999);
    subtype         t_de125 is varchar2(999);

    subtype         t_p0005 is mup_reject.p0005%type;
    subtype         t_p0025 is mup_reject.p0025%type;
    subtype         t_p0025_1 is mup_fin.p0025_1%type;
    subtype         t_p0025_2 is mup_fin.p0025_2%type;
    subtype         t_p0026 is mup_file.p0026%type;
    subtype         t_p0105 is mup_file.p0105%type;
    subtype         t_p0110 is mup_file.p0110%type;
    subtype         t_p0122 is mup_file.p0122%type;
    subtype         t_p0137 is mup_fin.p0137%type;
    subtype         t_p0138 is mup_reject.p0138%type;
    subtype         t_p0146 is mup_fin.p0146%type;
    subtype         t_p0146_net is mup_fin.p0146_net%type;
    subtype         t_p0148 is mup_fin.p0148%type;
    subtype         t_p0149_1 is mup_fin.p0149_1%type;
    subtype         t_p0149_2 is mup_fin.p0149_2%type;
    subtype         t_p0165 is mup_fin.p0165%type;
    subtype         t_p0176 is mup_fin.p0165%type;
    subtype         t_p0190 is mup_fin.p0190%type;
    subtype         t_p0198 is mup_fin.p0198%type;
    subtype         t_p0228 is mup_fin.p0228%type;
    subtype         t_p0261 is mup_fin.p0261%type;
    subtype         t_p0262 is mup_fin.p0262%type;
    subtype         t_p0265 is mup_fin.p0265%type;
    subtype         t_p0266 is mup_fin.p0266%type;
    subtype         t_p0267 is mup_fin.p0267%type;
    subtype         t_p0268_1 is mup_fin.p0268_1%type;
    subtype         t_p0268_2 is mup_fin.p0268_2%type;
    subtype         t_p0280 is mup_reject.p0280%type;
    subtype         t_p0300 is mup_fpd.p0300%type;
    subtype         t_p0301 is mup_file.p0301%type;
    subtype         t_p0302 is mup_fpd.p0302%type;
    subtype         t_p0306 is mup_file.p0306%type;
    subtype         t_p0369 is mup_fpd.p0369%type;
    subtype         t_p0370_1 is mup_fpd.p0370_1%type;
    subtype         t_p0370_2 is mup_fpd.p0370_2%type;
    subtype         t_p0372_1 is mup_fpd.p0372_1%type;
    subtype         t_p0372_2 is mup_fpd.p0372_2%type;
    subtype         t_p0374 is mup_fpd.p0374%type;
    subtype         t_p0375 is mup_fin.p0375%type;
    subtype         t_p0378 is mup_fpd.p0378%type;
    subtype         t_p0380_1 is mup_fpd.p0380_1%type;
    subtype         t_p0380_2 is mup_fpd.p0380_2%type;
    subtype         t_p0381_1 is mup_fpd.p0381_1%type;
    subtype         t_p0381_2 is mup_fpd.p0381_2%type;
    subtype         t_p0384_1 is mup_fpd.p0384_1%type;
    subtype         t_p0384_2 is mup_fpd.p0384_2%type;
    subtype         t_p0390_1 is mup_fpd.p0390_1%type;
    subtype         t_p0390_2 is mup_fpd.p0390_2%type;
    subtype         t_p0391_1 is mup_fpd.p0391_1%type;
    subtype         t_p0391_2 is mup_fpd.p0391_2%type;
    subtype         t_p0392 is mup_fpd.p0392%type;
    subtype         t_p0393 is mup_fpd.p0393%type;
    subtype         t_p0394_1 is mup_fpd.p0394_1%type;
    subtype         t_p0394_2 is mup_fpd.p0394_2%type;
    subtype         t_p0395_1 is mup_fpd.p0395_1%type;
    subtype         t_p0395_2 is mup_fpd.p0395_2%type;
    subtype         t_p0396_1 is mup_fpd.p0396_1%type;
    subtype         t_p0396_2 is mup_fpd.p0396_2%type;
    subtype         t_p0400 is mup_fpd.p0400%type;
    subtype         t_p0401 is mup_fpd.p0401%type;
    subtype         t_p0402 is mup_fpd.p0402%type;
    subtype         t_p2001_1 is mup_fin.p2001_1%type;
    subtype         t_p2001_2 is mup_fin.p2001_2%type;
    subtype         t_p2001_3 is mup_fin.p2001_3%type;
    subtype         t_p2001_4 is mup_fin.p2001_4%type;
    subtype         t_p2001_5 is mup_fin.p2001_5%type;
    subtype         t_p2001_6 is mup_fin.p2001_6%type;
    subtype         t_p2001_7 is mup_fin.p2001_7%type;
    subtype         t_p2002 is mup_fin.p2002%type;
    subtype         t_p2063 is mup_fin.p2063%type;
    subtype         t_p2072_1 is mup_fin.p2072_1%type;
    subtype         t_p2072_2 is mup_fin.p2072_2%type;
    subtype         t_p2158_1 is mup_fin.p2158_1%type;
    subtype         t_p2158_2 is mup_fin.p2158_2%type;
    subtype         t_p2158_3 is mup_fin.p2158_3%type;
    subtype         t_p2158_4 is mup_fin.p2158_4%type;
    subtype         t_p2158_5 is mup_fin.p2158_5%type;
    subtype         t_p2158_6 is mup_fin.p2158_6%type;
    subtype         t_p2159_1 is mup_fin.p2159_1%type;
    subtype         t_p2159_2 is mup_fin.p2159_2%type;
    subtype         t_p2159_3 is mup_fin.p2159_3%type;
    subtype         t_p2159_4 is mup_fin.p2159_4%type;
    subtype         t_p2159_5 is mup_fin.p2159_5%type;
    subtype         t_p2159_6 is mup_fin.p2159_6%type;
    subtype         t_p2175_1 is mup_fin.p2175_1%type;
    subtype         t_p2175_2 is mup_fin.p2175_2%type;
    subtype         t_p2097_1 is mup_fin.p2097_1%type;
    subtype         t_p2097_2 is mup_fin.p2097_2%type;
    subtype         t_p2358_1 is mup_fpd.p2358_1%type;
    subtype         t_p2358_2 is mup_fpd.p2358_2%type;
    subtype         t_p2358_3 is mup_fpd.p2358_3%type;
    subtype         t_p2358_4 is mup_fpd.p2358_4%type;
    subtype         t_p2358_5 is mup_fpd.p2358_5%type;
    subtype         t_p2358_6 is mup_fpd.p2358_6%type;
    subtype         t_p2359_1 is mup_fpd.p2359_1%type;
    subtype         t_p2359_2 is mup_fpd.p2359_2%type;
    subtype         t_p2359_3 is mup_fpd.p2359_3%type;
    subtype         t_p2359_4 is mup_fpd.p2359_4%type;
    subtype         t_p2359_5 is mup_fpd.p2359_5%type;
    subtype         t_p2359_6 is mup_fpd.p2359_6%type;
    subtype         t_report_type is mup_file.report_type%type;
    subtype         t_endpoint is mup_file.endpoint%type;

    subtype         t_orig_transfer_agent_id is mup_trans_rpt.orig_transfer_agent_id%type;
    subtype         t_activity_type is mup_trans_rpt.activity_type%type;

    subtype         t_pds_tag       is number(4);
    subtype         t_pds_tag_chr   is varchar2(4);
    subtype         t_pds_len       is number(3);
    subtype         t_pds_len_chr   is varchar2(3);
    subtype         t_pds_body      is varchar2(992);
    subtype         t_de_body       is varchar2(999);
    type            t_pds_tab       is table of t_pds_body index by binary_integer;
    type            t_pds_row_tab   is table of mup_msg_pds%rowtype index by binary_integer;

    subtype         t_de_number     is varchar2(5);
    subtype         t_severity_code is varchar2(2);
    subtype         t_message_code  is varchar2(4);
    subtype         t_subfield_id   is varchar2(3);

    type            t_fin_rec is record (
        row_id            rowid
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
      , de022_6           com_api_type_pkg.t_byte_char
      , de022_7           t_de022s
      , de022_8           t_de022s
      , de022_9           t_de022s
      , de022_10          t_de022s
      , de022_11          t_de022s
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
      , de063             t_de063
      , de071             t_de071
      , de072             t_de072
      , de073             t_de073
      , de093             t_de093
      , de094             t_de094
      , de095             t_de095
      , de100             t_de100
      , p0025_1           t_p0025_1
      , p0025_2           t_p0025_2
      , p0105             t_p0105
      , p0137             t_p0137
      , p0146             t_p0146
      , p0146_net         t_p0146_net
      , p0148             t_p0148
      , p0149_1           t_p0149_1
      , p0149_2           t_p0149_2
      , p0165             t_p0165
      , p0176             t_p0176
      , p0190             t_p0190
      , p0198             t_p0198
      , p0228             t_p0228
      , p0261             t_p0261
      , p0262             t_p0262
      , p0265             t_p0265
      , p0266             t_p0266
      , p0267             t_p0267
      , p0268_1           t_p0268_1
      , p0268_2           t_p0268_2
      , p0375             t_p0375
      , p2002             t_p2002
      , p2063             t_p2063
      , p2072_1           t_p2072_1
      , p2072_2           t_p2072_2
      , p2158_1           t_p2158_1
      , p2158_2           t_p2158_2
      , p2158_3           t_p2158_3
      , p2158_4           t_p2158_4
      , p2158_5           t_p2158_5
      , p2158_6           t_p2158_6
      , p2159_1           t_p2159_1
      , p2159_2           t_p2159_2
      , p2159_3           t_p2159_3
      , p2159_4           t_p2159_4
      , p2159_5           t_p2159_5
      , p2159_6           t_p2159_6
      , p2175_1           t_p2175_1
      , p2175_2           t_p2175_2
      , p2097_1           t_p2097_1
      , p2097_2           t_p2097_2
      , emv_9f26          com_api_type_pkg.t_auth_long_id
      , emv_9f27          com_api_type_pkg.t_byte_char
      , emv_9f10          varchar2(64)
      , emv_9f37          com_api_type_pkg.t_dict_value
      , emv_9f36          com_api_type_pkg.t_mcc
      , emv_95            com_api_type_pkg.t_postal_code
      , emv_9a            date
      , emv_9c            com_api_type_pkg.t_byte_id
      , emv_9f02          com_api_type_pkg.t_medium_id
      , emv_5f2a          com_api_type_pkg.t_tiny_id
      , emv_82            com_api_type_pkg.t_mcc
      , emv_9f1a          com_api_type_pkg.t_tiny_id
      , emv_9f03          com_api_type_pkg.t_medium_id
      , emv_9f34          com_api_type_pkg.t_auth_code
      , emv_9f33          com_api_type_pkg.t_auth_code
      , emv_9f35          com_api_type_pkg.t_byte_id
      , emv_9f1e          com_api_type_pkg.t_auth_long_id
      , emv_9f53          com_api_type_pkg.t_byte_char
      , emv_84            com_api_type_pkg.t_account_number
      , emv_9f09          com_api_type_pkg.t_mcc
      , emv_9f41          com_api_type_pkg.t_short_id
      , emv_9f4c          com_api_type_pkg.t_terminal_number       
      , emv_91            com_api_type_pkg.t_rrn
      , emv_8a            com_api_type_pkg.t_mcc
      , emv_71            com_api_type_pkg.t_exponent
      , emv_72            com_api_type_pkg.t_exponent
      , is_collection     com_api_type_pkg.t_boolean
      , activity_type     t_activity_type
      , orig_transfer_agent_id t_orig_transfer_agent_id
      , p2001_1           t_p2001_1
      , p2001_2           t_p2001_2
      , p2001_3           t_p2001_3
      , p2001_4           t_p2001_4
      , p2001_5           t_p2001_5
      , p2001_6           t_p2001_6
      , p2001_7           t_p2001_7
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
        , de071             t_de071
        , de032             t_de032
        , de033             t_de033
        , de063             t_de063
        , de093             t_de093
        , de094             t_de094
        , de100             t_de100
    );
    type            t_add_tab is table of t_add_rec index by binary_integer;
    type            t_add_cur is ref cursor return t_add_rec;

    type         t_file_rec is record (
        id              com_api_type_pkg.t_short_id
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
      , is_returned     com_api_type_pkg.t_boolean
      , proc_bin        com_api_type_pkg.t_bin
      , sttl_date       date 
      , release_number  com_api_type_pkg.t_curr_code
      , security_code   com_api_type_pkg.t_dict_value
      , visa_file_id    com_api_type_pkg.t_curr_code
      , batch_total     com_api_type_pkg.t_short_id
      , monetary_total  com_api_type_pkg.t_short_id
      , tcr_total       com_api_type_pkg.t_short_id
      , trans_total     com_api_type_pkg.t_short_id
      , src_amount      com_api_type_pkg.t_money
      , dst_amount      com_api_type_pkg.t_money
      , report_type     t_report_type
      , endpoint        t_endpoint
      , de094           t_de094
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
        , de022_6         com_api_type_pkg.t_byte_char
        , de022_7         t_de022s
        , de022_8         t_de022s
        , de022_9         t_de022s
        , de022_10        t_de022s
        , de022_11        t_de022s
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
        , de043_1         t_de043
        , de043_2         t_de043
        , de043_3         t_de043
        , de043_4         t_de043
        , de043_5         t_de043
        , de043_6         t_de043
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
        , de123           t_de123
        , de124           t_de124
        , de125           t_de125
    );
    type            t_mes_tab is table of t_mes_rec index by binary_integer;

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
        , p0148             t_p0148
        , p0165             t_p0165
        , p0300             t_p0300
        , p0302             t_p0302
        , p0369             t_p0369
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
        , p2358_1           t_p2358_1
        , p2358_2           t_p2358_2
        , p2358_3           t_p2358_3
        , p2358_4           t_p2358_4
        , p2358_5           t_p2358_5
        , p2358_6           t_p2358_6
        , p2359_1           t_p2359_1
        , p2359_2           t_p2359_2
        , p2359_3           t_p2359_3
        , p2359_4           t_p2359_4
        , p2359_5           t_p2359_5
        , p2359_6           t_p2359_6
        , is_grouped        com_api_type_pkg.t_boolean
    );
    type            t_fpd_tab is table of t_fpd_rec index by binary_integer;

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
        , amount_delta           com_api_type_pkg.t_money 
    );

end;
/
