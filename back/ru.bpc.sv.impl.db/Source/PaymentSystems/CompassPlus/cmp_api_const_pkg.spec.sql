create or replace package cmp_api_const_pkg as

    MODULE_CODE_CMP              constant com_api_type_pkg.t_module_code := 'CMP';
    COMPASS_ACQUIRER_NAME        constant com_api_type_pkg.t_name        := 'CMP_ACQUIRER_NAME';
    COMPASS_DEST_NAME            constant com_api_type_pkg.t_name        := 'CMP_DEST_FIN_NAME';
    ACQUIRER_BIN                 constant com_api_type_pkg.t_name        := 'ACQUIRER_BIN';
    COMPASS_PROTOCOL_VERSION     constant com_api_type_pkg.t_name        := 'CMP_PROTOCOL_VERSION';    
    
    CMP_CLEARING_STANDARD        constant com_api_type_pkg.t_tiny_id     := 1026;
    GC_OLD_DATE                  constant date default to_date('01/01/1901', 'dd/mm/yyyy');
    VISA_NETWORK                 constant com_api_type_pkg.t_tiny_id     := 1003;
    MC_NETWORK                   constant com_api_type_pkg.t_tiny_id     := 1002;
    VISA_NETWORK_NSPK            constant com_api_type_pkg.t_tiny_id     := 1008;
    MC_NETWORK_NSPK              constant com_api_type_pkg.t_tiny_id     := 1009;
    FILE_TYPE_CLEARING_CMP       constant com_api_type_pkg.t_dict_value  := 'FLTPCLCM';

    IDENT_FILENO                 constant com_api_type_pkg.t_auth_code   := 'FileNo';
    IDENT_FILETYPE               constant com_api_type_pkg.t_dict_value  := 'FileType'; -- FileType: 'Extract', 'CS', 'Response'
    IDENT_INSTNAME               constant com_api_type_pkg.t_dict_value  := 'InstName'; -- InstName
    IDENT_PACKNO                 constant com_api_type_pkg.t_auth_code   := 'PackNo';
    IDENT_VERSION                constant com_api_type_pkg.t_dict_value  := 'Version';
    IDENT_TEST                   constant com_api_type_pkg.t_mcc         := 'Test';
    IDENT_ENCODING               constant com_api_type_pkg.t_dict_value  := 'Encoding';
    IDENT_CRC                    constant com_api_type_pkg.t_curr_code   := 'CRC';

    DELIM_FIELD                  constant com_api_type_pkg.t_byte_char   := chr(16);
    DELIM_SUBFIELD               constant com_api_type_pkg.t_curr_code   := chr(13) || chr(31) || chr(30);
    
    IDENT_PAN                    constant varchar2(1) := 'E';    
    IDENT_TRANCODE               constant varchar2(1) := 'C';
    IDENT_EXTSTAN                constant varchar2(2) := 'SN';
    IDENT_TRANCLASS              constant varchar2(1) := 'B';
    IDENT_ORIGTIME               constant varchar2(2) := 'B3';
    IDENT_TRANSTYPE              constant varchar2(1) := 'A';
    IDENT_TERMSIC                constant varchar2(1) := 'P';
    IDENT_EXTFID                 constant varchar2(1) := 'w';
    IDENT_TRANNUMBER             constant varchar2(1) := '~';
    IDENT_EXTRRN                 constant varchar2(1) := '^';
    IDENT_APPROVALCODE           constant varchar2(1) := 'm';
    IDENT_TERMNAME               constant varchar2(1) := 'Q';
    IDENT_EXTTERMNAME            constant varchar2(2) := 'Q1';
    IDENT_TERMRETAILERNAME       constant varchar2(1) := 'y';
    IDENT_EXTTERMRETAILERNAME    constant varchar2(2) := 'y2';
    IDENT_TERMCITY               constant varchar2(2) := 'A4';
    IDENT_TERMLOCATION           constant varchar2(1) := 'S';
    IDENT_TERMOWNER              constant varchar2(1) := 's';
    IDENT_TERMCOUNTRY            constant varchar2(2) := 'A3';
    IDENT_AMOUNT                 constant varchar2(1) := 'I';
    IDENT_CURRENCY               constant varchar2(1) := 'a';
    IDENT_AMOUNTORIG             constant varchar2(1) := 't';
    IDENT_CURRENCYORIG           constant varchar2(1) := 'u';
    IDENT_TERMINSTID             constant varchar2(2) := 'B4';
    IDENT_EXPDATE                constant varchar2(1) := 'q';
    IDENT_TERMZIP                constant varchar2(2) := 'A5';
    IDENT_FINALRRN               constant varchar2(2) := 'FR';
    IDENT_EXTTERMOWNER           constant varchar2(2) := 's1';
    IDENT_FROMACCTTYPE           constant varchar2(1) := 'W';
    IDENT_AID                    constant varchar2(2) := 'X5';
    IDENT_ARN                    constant varchar2(2) := 'X8';
    IDENT_ORIGFINAME             constant varchar2(2) := 'XA';
    IDENT_DESTFINAME             constant varchar2(2) := 'XB';
    IDENT_CLEARDATE              constant varchar2(2) := 'YA';
    
    IDENT_ID                     constant varchar2(1) := '#'; 
    IDENT_NETWORK                constant varchar2(1) := '$';
    IDENT_HOSTNETID              constant varchar2(2) := 'NI';
    IDENT_EXTTRANATTR            constant varchar2(1) := '@';
    IDENT_TERMINSTCOUNTRY        constant varchar2(2) := 'A6';
    IDENT_POSCONDITION           constant varchar2(2) := 'B1';
    IDENT_POSENTRYMODE           constant varchar2(1) := 'o';
    IDENT_PIN                    constant varchar2(1) := 'p';
    IDENT_TERMENTRYCAPS          constant varchar2(2) := 'B2';
    IDENT_TIME                   constant varchar2(1) := 'D'; 
    IDENT_EXTPSFIELDS            constant varchar2(2) := 'EF';
    IDENT_TERMCONTACTLESSCAPABLE constant varchar2(2) := 'CC';
    IDENT_TERMCLASS              constant varchar2(1) := 'O';

    --emv data
    IDENT_ICC_TERMCAPS           constant varchar2(2) := 'C1';
    IDENT_ICC_TVR                constant varchar2(2) := 'C2';
    IDENT_ICC_RANDOM             constant varchar2(2) := 'C3';
    IDENT_ICC_TERMSN             constant varchar2(2) := 'C4';
    IDENT_ICC_ISSUERDATA         constant varchar2(2) := 'C5';
    IDENT_ICC_CRYPTOGRAM         constant varchar2(2) := 'C6';
    IDENT_ICC_APPTRANCOUNT       constant varchar2(2) := 'C7';
    IDENT_ICC_TERMTRANCOUNT      constant varchar2(2) := 'C8';
    IDENT_ICC_APPPROFILE         constant varchar2(2) := 'C9';
    IDENT_ICC_IAD                constant varchar2(2) := 'D1';
    IDENT_ICC_TRANTYPE           constant varchar2(2) := 'D2';
    IDENT_ICC_TERMCOUNTRY        constant varchar2(2) := 'D3';
    IDENT_ICC_TRANDATE           constant varchar2(2) := 'D4';
    IDENT_ICC_AMOUNT             constant varchar2(2) := 'D5';
    IDENT_ICC_CURRENCY           constant varchar2(2) := 'D6';
    IDENT_ICC_CBAMOUNT           constant varchar2(2) := 'D7';
    IDENT_ICC_CRYPTINFORMDATA    constant varchar2(2) := 'D8';
    IDENT_ICC_CVMRES             constant varchar2(2) := 'D9';
    IDENT_ICC_CARDMEMBER         constant varchar2(2) := 'DG';
    IDENT_CARDMEMBER             constant varchar2(1) := 'F';
    IDENT_RECNO                  constant varchar2(1) := '!';
    IDENT_ICC_RESPCODE           constant varchar2(2) := 'DF';
    IDENT_SERVICECODE            constant varchar2(2) := 'sc';
        
    MTID_PRESENTMENT             constant com_api_type_pkg.t_mcc         := '1240';
    MTID_PRESENTMENT_REV         constant com_api_type_pkg.t_mcc         := '4240';
    MTID_COLLECT_ONLY            constant com_api_type_pkg.t_mcc         := '8240';
    MTID_COLLECT_ONLY_REV        constant com_api_type_pkg.t_mcc         := '8244';
    
    UPLOAD_COLLECT_ONLY_ALL      constant com_api_type_pkg.t_dict_value  := 'UOCLALL';
    UPLOAD_COLLECT_ONLY_CLC      constant com_api_type_pkg.t_dict_value  := 'UOCLCLC';
    UPLOAD_COLLECT_ONLY_NCLC     constant com_api_type_pkg.t_dict_value  := 'UOCLNCLC';
    
    CLEARING_COLLECT_STATUS_READY   constant com_api_type_pkg.t_dict_value  := 'CLMS0160';
    
    CMP_STANDARD_VERSION_ID_17R2 constant com_api_type_pkg.t_tiny_id := 1056;
    CMP_STANDARD_VERSION_ID_18R1 constant com_api_type_pkg.t_tiny_id := 1069;
    
end;
/
