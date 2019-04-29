create or replace package body mcw_api_migs_pkg is
/**********************************************************
 * API for MasterCard Internet Gateway System <br />
 * This gateway supported not only cards of the MasterCard IPS <br />
 * but cards of others IPS such as Visa, JCB, Amex, etc <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 13.12.2016 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: MCW_API_MIGS_PKG
 * @headcom
 **********************************************************/
 
CRLF                           constant com_api_type_pkg.t_name := chr(13) || chr(10);

HEADER_RECORD_TYPE             constant mcw_api_migs_type_pkg.t_dcf_record_type := '6200';
DETAIL_BEGIN_RECORD_TYPE       constant mcw_api_migs_type_pkg.t_dcf_record_type := '6220';
DETAIL_2_RECORD_TYPE           constant mcw_api_migs_type_pkg.t_dcf_record_type := '6221';
DETAIL_MCW_RECORD_TYPE         constant mcw_api_migs_type_pkg.t_dcf_record_type := '6222';
DETAIL_VISA_RECORD_TYPE        constant mcw_api_migs_type_pkg.t_dcf_record_type := '6223';
DETAIL_AMEX_RECORD_TYPE        constant mcw_api_migs_type_pkg.t_dcf_record_type := '6224';
DETAIL_EMV_RECORD_TYPE         constant mcw_api_migs_type_pkg.t_dcf_record_type := '6225';
DETAIL_DIN_DISC_RECORD_TYPE    constant mcw_api_migs_type_pkg.t_dcf_record_type := '6226';
DETAIL_DCC_RECORD_TYPE         constant mcw_api_migs_type_pkg.t_dcf_record_type := '6227';
DETAIL_MIGS_RECORD_TYPE        constant mcw_api_migs_type_pkg.t_dcf_record_type := '6228';
DETAIL_MIGS_CUST_RECORD_TYPE   constant mcw_api_migs_type_pkg.t_dcf_record_type := '6282';
DETAIL_AIRLINE_RECORD_TYPE     constant mcw_api_migs_type_pkg.t_dcf_record_type := '6229';
DETAIL_AIRLINE0_RECORD_TYPE    constant mcw_api_migs_type_pkg.t_dcf_record_type := '6230';
DETAIL_AIRLINE1_RECORD_TYPE    constant mcw_api_migs_type_pkg.t_dcf_record_type := '6231';
DETAIL_AIRLINE2_RECORD_TYPE    constant mcw_api_migs_type_pkg.t_dcf_record_type := '6232';
DETAIL_AIRLINE3_RECORD_TYPE    constant mcw_api_migs_type_pkg.t_dcf_record_type := '6233';
DETAIL_AIRLINE4_RECORD_TYPE    constant mcw_api_migs_type_pkg.t_dcf_record_type := '6234';
DETAIL_AIRLINE5_RECORD_TYPE    constant mcw_api_migs_type_pkg.t_dcf_record_type := '6235';
DETAIL_AIRLINE6_RECORD_TYPE    constant mcw_api_migs_type_pkg.t_dcf_record_type := '6236';
DETAIL_AIRLINE7_RECORD_TYPE    constant mcw_api_migs_type_pkg.t_dcf_record_type := '6237';
DETAIL_AIRLINE8_RECORD_TYPE    constant mcw_api_migs_type_pkg.t_dcf_record_type := '6238';
DETAIL_AIRLINE9_RECORD_TYPE    constant mcw_api_migs_type_pkg.t_dcf_record_type := '6239';
DETAIL_TRAILER_RECORD_TYPE     constant mcw_api_migs_type_pkg.t_dcf_record_type := '6240';

DEFAULT_PART_DICT_CODE         constant com_api_type_pkg.t_dict_value := '000';

DICT_CARD_HOLDER_AUTH_CAP      constant com_api_type_pkg.t_dict_value := 'F222';
DICT_CARD_CAPTURE_CAP          constant com_api_type_pkg.t_dict_value := 'F223';
DICT_TERMINAL_OPERATING_ENV    constant com_api_type_pkg.t_dict_value := 'F224';
DICT_CARDHOLDER_AUTH_METHOD    constant com_api_type_pkg.t_dict_value := 'F228';
DICT_PIN_CAPTURE_CAP           constant com_api_type_pkg.t_dict_value := 'F22C';

CVV2_RESULT_MATCH              constant com_api_type_pkg.t_dict_value := 'CV2R0001';
CVV2_RESULT_NOT_MATCH          constant com_api_type_pkg.t_dict_value := 'CV2R0002';
CVV2_RESULT_NOT_PROCESSED      constant com_api_type_pkg.t_dict_value := 'CV2R0003';
CVV2_RESULT_NOT_PRESENT_VC     constant com_api_type_pkg.t_dict_value := 'CV2R0004';
CVV2_RESULT_ISS_NOT_PROVIDE    constant com_api_type_pkg.t_dict_value := 'CV2R0005';

procedure parse_dcf_record_exec(
    i_record_number        in com_api_type_pkg.t_short_id
  , i_record_type          in mcw_api_migs_type_pkg.t_dcf_record_type
  , i_record_str           in com_api_type_pkg.t_exponent
  , i_incom_sess_file_id   in com_api_type_pkg.t_long_id
) is
    
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_record_exec: ';
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START record type - '   || i_record_type   || CRLF
                                 || '      record_number - ' || i_record_number || CRLF
                                 || '      string - '        || i_record_str    || CRLF
                                 || '      incom_file_id - ' || i_incom_sess_file_id
    );
    
    if i_record_type = HEADER_RECORD_TYPE then
        
        extend_fin_message;
        
        g_dcf_fin_messages(g_dcf_fin_messages.last).incom_sess_file_id := i_incom_sess_file_id;
        
    elsif i_record_type = DETAIL_BEGIN_RECORD_TYPE then
        
        extend_fin_detail;
        
    end if;
    
    if i_record_type in (
           HEADER_RECORD_TYPE
         , DETAIL_BEGIN_RECORD_TYPE
         , DETAIL_2_RECORD_TYPE
         , DETAIL_MCW_RECORD_TYPE
         , DETAIL_VISA_RECORD_TYPE
         , DETAIL_AMEX_RECORD_TYPE
         , DETAIL_EMV_RECORD_TYPE
         , DETAIL_DIN_DISC_RECORD_TYPE
         , DETAIL_DCC_RECORD_TYPE
         , DETAIL_MIGS_RECORD_TYPE
         , DETAIL_MIGS_CUST_RECORD_TYPE
         , DETAIL_AIRLINE_RECORD_TYPE
         , DETAIL_AIRLINE0_RECORD_TYPE
         , DETAIL_AIRLINE1_RECORD_TYPE
         , DETAIL_AIRLINE2_RECORD_TYPE
         , DETAIL_AIRLINE3_RECORD_TYPE
         , DETAIL_AIRLINE4_RECORD_TYPE
         , DETAIL_AIRLINE5_RECORD_TYPE
         , DETAIL_AIRLINE6_RECORD_TYPE
         , DETAIL_AIRLINE7_RECORD_TYPE
         , DETAIL_AIRLINE8_RECORD_TYPE
         , DETAIL_AIRLINE9_RECORD_TYPE
         , DETAIL_TRAILER_RECORD_TYPE
       )
    then
        
        execute immediate ' BEGIN' || CRLF
                       || '     mcw_api_migs_pkg.parse_dcf_' || i_record_type || '_record(' || CRLF
                       || '         i_record_str => :str' || CRLF
                       || '     );' || CRLF
                       || ' END;'
                    using in i_record_str;
                    
    else

        trc_log_pkg.debug(LOG_PREFIX || 'INVALID RECORD TYPE - ' || i_record_type || CRLF
                                     || ' RECORD NUMBER - ' || i_record_number || ' SKIPPED'
        );

    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => i_record_type
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_record_exec;

procedure parse_dcf_6200_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is
    
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6200_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6200';
    
    ELEMENTS_NOT_MAESTRO_MAP   constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1, 1,  4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2, 5,  32)
          , mcw_api_migs_type_pkg.t_position_length_tab(3, 37, 6)
          , mcw_api_migs_type_pkg.t_position_length_tab(4, 43, 6)
          , mcw_api_migs_type_pkg.t_position_length_tab(5, 49, 3)
          , mcw_api_migs_type_pkg.t_position_length_tab(6, 52, 205)
        );

    ELEMENTS_MAESTRO_MAP       constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1, 1,  4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2, 5,  32)
          , mcw_api_migs_type_pkg.t_position_length_tab(3, 37, 6)
          , mcw_api_migs_type_pkg.t_position_length_tab(4, 43, 6)
          , mcw_api_migs_type_pkg.t_position_length_tab(5, 49, 3)
          , mcw_api_migs_type_pkg.t_position_length_tab(6, 52, 11)
          , mcw_api_migs_type_pkg.t_position_length_tab(7, 63, 11)
          , mcw_api_migs_type_pkg.t_position_length_tab(8, 74, 183)
        );
        
    POSITION           constant com_api_type_pkg.t_sign := 2;
    LEN                constant com_api_type_pkg.t_sign := 3;
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
        
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main := g_dcf_fin_messages.last;
    
    select rtrim(substr(i_record_str, ELEMENTS_NOT_MAESTRO_MAP(1)(POSITION), ELEMENTS_NOT_MAESTRO_MAP(1)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_NOT_MAESTRO_MAP(2)(POSITION), ELEMENTS_NOT_MAESTRO_MAP(2)(LEN)))
         , substr(i_record_str, ELEMENTS_NOT_MAESTRO_MAP(3)(POSITION), ELEMENTS_NOT_MAESTRO_MAP(3)(LEN))
         , substr(i_record_str, ELEMENTS_NOT_MAESTRO_MAP(4)(POSITION), ELEMENTS_NOT_MAESTRO_MAP(4)(LEN))
         , to_number(
               substr(i_record_str, ELEMENTS_NOT_MAESTRO_MAP(5)(POSITION), ELEMENTS_NOT_MAESTRO_MAP(5)(LEN))
             , 'fm000'
           )
         , substr(i_record_str, ELEMENTS_NOT_MAESTRO_MAP(6)(POSITION), ELEMENTS_NOT_MAESTRO_MAP(6)(LEN))
      into g_dcf_fin_messages(l_i_main).header_not_maestro
      from dual;
      
    if  g_dcf_fin_messages(l_i_main).header_not_maestro.acquirer_ica = '0' then
        
        g_dcf_fin_messages(l_i_main).header_not_maestro := null;
        
        select rtrim(substr(i_record_str, ELEMENTS_MAESTRO_MAP(1)(POSITION), ELEMENTS_MAESTRO_MAP(1)(LEN)))
             , rtrim(substr(i_record_str, ELEMENTS_MAESTRO_MAP(2)(POSITION), ELEMENTS_MAESTRO_MAP(2)(LEN)))
             , substr(i_record_str, ELEMENTS_MAESTRO_MAP(3)(POSITION), ELEMENTS_MAESTRO_MAP(3)(LEN))
             , substr(i_record_str, ELEMENTS_MAESTRO_MAP(4)(POSITION), ELEMENTS_MAESTRO_MAP(4)(LEN))
             , substr(i_record_str, ELEMENTS_MAESTRO_MAP(5)(POSITION), ELEMENTS_MAESTRO_MAP(5)(LEN))
             , to_number(
                   substr(i_record_str, ELEMENTS_MAESTRO_MAP(6)(POSITION), ELEMENTS_MAESTRO_MAP(6)(LEN))
                 , 'fm00000000000'
               )
             , to_number(
                   substr(i_record_str, ELEMENTS_MAESTRO_MAP(7)(POSITION), ELEMENTS_MAESTRO_MAP(7)(LEN))
                 , 'fm00000000000'
               )
             , substr(i_record_str, ELEMENTS_MAESTRO_MAP(8)(POSITION), ELEMENTS_MAESTRO_MAP(8)(LEN))
          into g_dcf_fin_messages(l_i_main).header_maestro
          from dual;
          
     end if;
     
     trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6200_record;

procedure parse_dcf_6220_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is
    
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6220_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6220';
    
    ELEMENTS_TRANSACT_DETAIL_MAP  constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1,  1,   4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2,  5,   4)
          , mcw_api_migs_type_pkg.t_position_length_tab(3,  9,   20)
          , mcw_api_migs_type_pkg.t_position_length_tab(4,  29,  6)
          , mcw_api_migs_type_pkg.t_position_length_tab(5,  35,  12)
          , mcw_api_migs_type_pkg.t_position_length_tab(6,  47,  12)
          , mcw_api_migs_type_pkg.t_position_length_tab(7,  59,  12)
          , mcw_api_migs_type_pkg.t_position_length_tab(8,  71,  10)
          , mcw_api_migs_type_pkg.t_position_length_tab(9,  81,  6)
          , mcw_api_migs_type_pkg.t_position_length_tab(10, 87,  4)
          , mcw_api_migs_type_pkg.t_position_length_tab(11, 91,  6)
          , mcw_api_migs_type_pkg.t_position_length_tab(12, 97,  4)
          , mcw_api_migs_type_pkg.t_position_length_tab(13, 101, 4)
          , mcw_api_migs_type_pkg.t_position_length_tab(14, 105, 4)
          , mcw_api_migs_type_pkg.t_position_length_tab(15, 109, 3)
          , mcw_api_migs_type_pkg.t_position_length_tab(16, 112, 2)
          , mcw_api_migs_type_pkg.t_position_length_tab(17, 114, 12)
          , mcw_api_migs_type_pkg.t_position_length_tab(18, 126, 6)
          , mcw_api_migs_type_pkg.t_position_length_tab(19, 132, 2)
          , mcw_api_migs_type_pkg.t_position_length_tab(20, 134, 8)
          , mcw_api_migs_type_pkg.t_position_length_tab(21, 142, 15)
          , mcw_api_migs_type_pkg.t_position_length_tab(22, 157, 3)
          , mcw_api_migs_type_pkg.t_position_length_tab(23, 160, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(24, 161, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(25, 162, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(26, 163, 3)
          , mcw_api_migs_type_pkg.t_position_length_tab(27, 166, 3)
          , mcw_api_migs_type_pkg.t_position_length_tab(28, 169, 3)
          , mcw_api_migs_type_pkg.t_position_length_tab(29, 172, 3)
          , mcw_api_migs_type_pkg.t_position_length_tab(30, 175, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(31, 176, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(32, 177, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(33, 178, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(34, 179, 9)
          , mcw_api_migs_type_pkg.t_position_length_tab(35, 188, 6)
          , mcw_api_migs_type_pkg.t_position_length_tab(36, 194, 4)
          , mcw_api_migs_type_pkg.t_position_length_tab(37, 198, 34)
          , mcw_api_migs_type_pkg.t_position_length_tab(38, 232, 15)
          , mcw_api_migs_type_pkg.t_position_length_tab(39, 247, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(40, 248, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(41, 249, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(42, 250, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(43, 251, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(44, 252, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(45, 253, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(46, 254, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(47, 255, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(48, 256, 1)
        );

    POSITION           constant com_api_type_pkg.t_sign := 2;
    LEN                constant com_api_type_pkg.t_sign := 3;
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;
        
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    select rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(1)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(1)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(2)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(2)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(3)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(3)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(4)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(4)(LEN)))
         , to_number(
               substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(5)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(5)(LEN))
             , 'fm000000000000'
           )
         , to_number(
               substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(6)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(6)(LEN))
             , 'fm000000000000'
           )
         , to_number(
               substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(7)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(7)(LEN))
             , 'fm000000000000'
           )
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(8)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(8)(LEN)))
         , to_number(
               substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(9)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(9)(LEN))
             , 'fm000000'
           )
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(10)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(10)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(11)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(11)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(12)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(12)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(13)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(13)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(14)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(14)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(15)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(15)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(16)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(16)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(17)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(17)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(18)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(18)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(19)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(19)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(20)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(20)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(21)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(21)(LEN)))
         , to_number(
               substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(22)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(22)(LEN))
             , 'fm000'
           )
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(23)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(23)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(24)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(24)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(25)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(25)(LEN)))
         , to_number(
               substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(26)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(26)(LEN))
             , 'fm000'
           )
         , to_number(
               substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(27)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(27)(LEN))
             , 'fm000'
           )
         , to_number(
               substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(28)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(28)(LEN))
             , 'fm000'
           )
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(29)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(29)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(30)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(30)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(31)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(31)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(32)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(32)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(33)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(33)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(34)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(34)(LEN)))
         , to_number(
               substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(35)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(35)(LEN))
             , 'fm000000'
           )
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(36)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(36)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(37)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(37)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(38)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(38)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(39)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(39)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(40)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(40)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(41)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(41)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(42)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(42)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(43)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(43)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(44)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(44)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(45)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(45)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(46)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(46)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(47)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(47)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(48)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(48)(LEN)))
      into g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).transact_detail_6220
      from dual;
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6220_record;

procedure parse_dcf_6221_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is
    
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6221_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6221';
    
    ELEMENTS_TRANSACT_DETAIL_MAP  constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1,  1,   4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2,  5,   22)
          , mcw_api_migs_type_pkg.t_position_length_tab(3,  27,  45)
          , mcw_api_migs_type_pkg.t_position_length_tab(4,  72,  13)
          , mcw_api_migs_type_pkg.t_position_length_tab(5,  85,  3)
          , mcw_api_migs_type_pkg.t_position_length_tab(6,  88,  3)
          , mcw_api_migs_type_pkg.t_position_length_tab(7,  91,  10)
          , mcw_api_migs_type_pkg.t_position_length_tab(8,  101, 3)
          , mcw_api_migs_type_pkg.t_position_length_tab(9,  104, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(10, 105, 2)
          , mcw_api_migs_type_pkg.t_position_length_tab(11, 107, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(12, 108, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(13, 109, 3)
          , mcw_api_migs_type_pkg.t_position_length_tab(14, 112, 145)
        );

    POSITION           constant com_api_type_pkg.t_sign := 2;
    LEN                constant com_api_type_pkg.t_sign := 3;
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;
        
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    select rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(1)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(1)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(2)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(2)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(3)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(3)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(4)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(4)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(5)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(5)(LEN)))
         , to_number(
               substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(6)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(6)(LEN))
             , 'fm000'
           )
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(7)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(7)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(8)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(8)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(9)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(9)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(10)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(10)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(11)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(11)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(12)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(12)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(13)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(13)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_TRANSACT_DETAIL_MAP(14)(POSITION), ELEMENTS_TRANSACT_DETAIL_MAP(14)(LEN)))
      into g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).transact_detail_6221
      from dual;
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6221_record;

procedure parse_dcf_6222_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is
    
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6222_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6222';
    
    ELEMENTS_MCW_DATA_MAP     constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1,  1,   4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2,  5,   3)
          , mcw_api_migs_type_pkg.t_position_length_tab(3,  8,   6)
          , mcw_api_migs_type_pkg.t_position_length_tab(4,  14,  4)
          , mcw_api_migs_type_pkg.t_position_length_tab(5,  18,  1)
          , mcw_api_migs_type_pkg.t_position_length_tab(6,  19,  3)
          , mcw_api_migs_type_pkg.t_position_length_tab(7,  22,  1)
          , mcw_api_migs_type_pkg.t_position_length_tab(8,  23,  6)
          , mcw_api_migs_type_pkg.t_position_length_tab(9,  29,  3)
          , mcw_api_migs_type_pkg.t_position_length_tab(10, 32,  225)
        );

    POSITION           constant com_api_type_pkg.t_sign := 2;
    LEN                constant com_api_type_pkg.t_sign := 3;
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;
        
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    select rtrim(substr(i_record_str, ELEMENTS_MCW_DATA_MAP(1)(POSITION), ELEMENTS_MCW_DATA_MAP(1)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MCW_DATA_MAP(2)(POSITION), ELEMENTS_MCW_DATA_MAP(2)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MCW_DATA_MAP(3)(POSITION), ELEMENTS_MCW_DATA_MAP(3)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MCW_DATA_MAP(4)(POSITION), ELEMENTS_MCW_DATA_MAP(4)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MCW_DATA_MAP(5)(POSITION), ELEMENTS_MCW_DATA_MAP(5)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MCW_DATA_MAP(6)(POSITION), ELEMENTS_MCW_DATA_MAP(6)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MCW_DATA_MAP(7)(POSITION), ELEMENTS_MCW_DATA_MAP(7)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MCW_DATA_MAP(8)(POSITION), ELEMENTS_MCW_DATA_MAP(8)(LEN)))
         , to_number(
               substr(i_record_str, ELEMENTS_MCW_DATA_MAP(9)(POSITION), ELEMENTS_MCW_DATA_MAP(9)(LEN))
             , 'fm000'
           )
         , rtrim(substr(i_record_str, ELEMENTS_MCW_DATA_MAP(10)(POSITION), ELEMENTS_MCW_DATA_MAP(10)(LEN)))
      into g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).mastercard_data_6222
      from dual;
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6222_record;

procedure parse_dcf_6223_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is
    
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6223_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6223';
    
    ELEMENTS_VISA_DATA_MAP    constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1,  1,   4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2,  5,   1)
          , mcw_api_migs_type_pkg.t_position_length_tab(3,  6,   2)
          , mcw_api_migs_type_pkg.t_position_length_tab(4,  8,   1)
          , mcw_api_migs_type_pkg.t_position_length_tab(5,  9,   1)
          , mcw_api_migs_type_pkg.t_position_length_tab(6,  10,  1)
          , mcw_api_migs_type_pkg.t_position_length_tab(7,  11,  1)
          , mcw_api_migs_type_pkg.t_position_length_tab(8,  12,  15)
          , mcw_api_migs_type_pkg.t_position_length_tab(9,  27,  4)
          , mcw_api_migs_type_pkg.t_position_length_tab(10, 31,  1)
          , mcw_api_migs_type_pkg.t_position_length_tab(11, 32,  1)
          , mcw_api_migs_type_pkg.t_position_length_tab(12, 33,  1)
          , mcw_api_migs_type_pkg.t_position_length_tab(13, 34,  10)
          , mcw_api_migs_type_pkg.t_position_length_tab(14, 44,  213)
        );

    POSITION           constant com_api_type_pkg.t_sign := 2;
    LEN                constant com_api_type_pkg.t_sign := 3;
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;
        
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    select rtrim(substr(i_record_str, ELEMENTS_VISA_DATA_MAP(1)(POSITION), ELEMENTS_VISA_DATA_MAP(1)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_VISA_DATA_MAP(2)(POSITION), ELEMENTS_VISA_DATA_MAP(2)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_VISA_DATA_MAP(3)(POSITION), ELEMENTS_VISA_DATA_MAP(3)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_VISA_DATA_MAP(4)(POSITION), ELEMENTS_VISA_DATA_MAP(4)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_VISA_DATA_MAP(5)(POSITION), ELEMENTS_VISA_DATA_MAP(5)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_VISA_DATA_MAP(6)(POSITION), ELEMENTS_VISA_DATA_MAP(6)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_VISA_DATA_MAP(7)(POSITION), ELEMENTS_VISA_DATA_MAP(7)(LEN)))
         , to_number(
               substr(i_record_str, ELEMENTS_VISA_DATA_MAP(8)(POSITION), ELEMENTS_VISA_DATA_MAP(8)(LEN))
             , 'fm000000000000000'
           )
         , rtrim(substr(i_record_str, ELEMENTS_VISA_DATA_MAP(9)(POSITION), ELEMENTS_VISA_DATA_MAP(9)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_VISA_DATA_MAP(10)(POSITION), ELEMENTS_VISA_DATA_MAP(10)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_VISA_DATA_MAP(11)(POSITION), ELEMENTS_VISA_DATA_MAP(11)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_VISA_DATA_MAP(12)(POSITION), ELEMENTS_VISA_DATA_MAP(12)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_VISA_DATA_MAP(13)(POSITION), ELEMENTS_VISA_DATA_MAP(13)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_VISA_DATA_MAP(14)(POSITION), ELEMENTS_VISA_DATA_MAP(14)(LEN)))
      into g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).visa_data_6223
      from dual;
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6223_record;

procedure parse_dcf_6224_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is
    
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6224_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6224';
    
    ELEMENTS_AMEX_DATA_MAP    constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1,  1,   4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2,  5,   15)
          , mcw_api_migs_type_pkg.t_position_length_tab(3,  20,  237)
        );

    POSITION           constant com_api_type_pkg.t_sign := 2;
    LEN                constant com_api_type_pkg.t_sign := 3;
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;
        
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    select rtrim(substr(i_record_str, ELEMENTS_AMEX_DATA_MAP(1)(POSITION), ELEMENTS_AMEX_DATA_MAP(1)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AMEX_DATA_MAP(2)(POSITION), ELEMENTS_AMEX_DATA_MAP(2)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AMEX_DATA_MAP(3)(POSITION), ELEMENTS_AMEX_DATA_MAP(3)(LEN)))
      into g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).amex_data_6224
      from dual;
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6224_record;

procedure parse_dcf_6225_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is
    
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6225_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6225';
    
    ELEMENTS_EMV_DATA_MAP    constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1,  1,   4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2,  5,   3)
          , mcw_api_migs_type_pkg.t_position_length_tab(3,  8,   3)
          , mcw_api_migs_type_pkg.t_position_length_tab(4,  11,  16)
          , mcw_api_migs_type_pkg.t_position_length_tab(5,  27,  2)
          , mcw_api_migs_type_pkg.t_position_length_tab(6,  29,  64)
          , mcw_api_migs_type_pkg.t_position_length_tab(7,  93,  8)
          , mcw_api_migs_type_pkg.t_position_length_tab(8,  101, 4)
          , mcw_api_migs_type_pkg.t_position_length_tab(9,  105, 10)
          , mcw_api_migs_type_pkg.t_position_length_tab(10, 115, 6)
          , mcw_api_migs_type_pkg.t_position_length_tab(11, 121, 2)
          , mcw_api_migs_type_pkg.t_position_length_tab(12, 123, 12)
          , mcw_api_migs_type_pkg.t_position_length_tab(13, 135, 3)
          , mcw_api_migs_type_pkg.t_position_length_tab(14, 138, 4)
          , mcw_api_migs_type_pkg.t_position_length_tab(15, 142, 3)
          , mcw_api_migs_type_pkg.t_position_length_tab(16, 145, 12)
          , mcw_api_migs_type_pkg.t_position_length_tab(17, 157, 6)
          , mcw_api_migs_type_pkg.t_position_length_tab(18, 163, 6)
          , mcw_api_migs_type_pkg.t_position_length_tab(19, 169, 2)
          , mcw_api_migs_type_pkg.t_position_length_tab(20, 171, 8)
          , mcw_api_migs_type_pkg.t_position_length_tab(21, 179, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(22, 180, 32)
          , mcw_api_migs_type_pkg.t_position_length_tab(23, 212, 4)
          , mcw_api_migs_type_pkg.t_position_length_tab(24, 216, 8)
          , mcw_api_migs_type_pkg.t_position_length_tab(25, 224, 32)
          , mcw_api_migs_type_pkg.t_position_length_tab(26, 256, 1)
        );

    POSITION           constant com_api_type_pkg.t_sign := 2;
    LEN                constant com_api_type_pkg.t_sign := 3;
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;
        
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    select rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(1)(POSITION), ELEMENTS_EMV_DATA_MAP(1)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(2)(POSITION), ELEMENTS_EMV_DATA_MAP(2)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(3)(POSITION), ELEMENTS_EMV_DATA_MAP(3)(LEN)))
         , utl_raw.cast_to_raw(
               c => rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(4)(POSITION), ELEMENTS_EMV_DATA_MAP(4)(LEN)))
           )
         , utl_raw.cast_to_raw(
               c => rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(5)(POSITION), ELEMENTS_EMV_DATA_MAP(5)(LEN)))
           )
         , utl_raw.cast_to_raw(
               c => rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(6)(POSITION), ELEMENTS_EMV_DATA_MAP(6)(LEN)))
           )
         , utl_raw.cast_to_raw(
               c => rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(7)(POSITION), ELEMENTS_EMV_DATA_MAP(7)(LEN)))
           )
         , utl_raw.cast_to_raw(
               c => rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(8)(POSITION), ELEMENTS_EMV_DATA_MAP(8)(LEN)))
           )
         , utl_raw.cast_to_raw(
               c => rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(9)(POSITION), ELEMENTS_EMV_DATA_MAP(9)(LEN)))
           )
         , rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(10)(POSITION), ELEMENTS_EMV_DATA_MAP(10)(LEN)))
         , utl_raw.cast_to_raw(
               c => rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(11)(POSITION), ELEMENTS_EMV_DATA_MAP(11)(LEN)))
           )
         , to_number(
               substr(i_record_str, ELEMENTS_EMV_DATA_MAP(12)(POSITION), ELEMENTS_EMV_DATA_MAP(12)(LEN))
             , 'fm000000000000'
           )
         , to_number(
               substr(i_record_str, ELEMENTS_EMV_DATA_MAP(13)(POSITION), ELEMENTS_EMV_DATA_MAP(13)(LEN))
             , 'fm000'
           )
         , utl_raw.cast_to_raw(
               c => rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(14)(POSITION), ELEMENTS_EMV_DATA_MAP(14)(LEN)))
           )
         , to_number(
               substr(i_record_str, ELEMENTS_EMV_DATA_MAP(15)(POSITION), ELEMENTS_EMV_DATA_MAP(15)(LEN))
             , 'fm000'
           )
         , to_number(
               substr(i_record_str, ELEMENTS_EMV_DATA_MAP(16)(POSITION), ELEMENTS_EMV_DATA_MAP(16)(LEN))
             , 'fm000000000000'
           )
         , utl_raw.cast_to_raw(
               c => rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(17)(POSITION), ELEMENTS_EMV_DATA_MAP(17)(LEN)))
           )
         , utl_raw.cast_to_raw(
               c => rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(18)(POSITION), ELEMENTS_EMV_DATA_MAP(18)(LEN)))
           )
         , utl_raw.cast_to_raw(
               c => rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(19)(POSITION), ELEMENTS_EMV_DATA_MAP(19)(LEN)))
           )
         , rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(20)(POSITION), ELEMENTS_EMV_DATA_MAP(20)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(21)(POSITION), ELEMENTS_EMV_DATA_MAP(21)(LEN)))
         , utl_raw.cast_to_raw(
               c => rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(22)(POSITION), ELEMENTS_EMV_DATA_MAP(22)(LEN)))
           )
         , utl_raw.cast_to_raw(
               c => rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(23)(POSITION), ELEMENTS_EMV_DATA_MAP(23)(LEN)))
           )
         , utl_raw.cast_to_raw(
               c => rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(24)(POSITION), ELEMENTS_EMV_DATA_MAP(24)(LEN)))
           )
         , utl_raw.cast_to_raw(
               c => rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(25)(POSITION), ELEMENTS_EMV_DATA_MAP(25)(LEN)))
           )
         , rtrim(substr(i_record_str, ELEMENTS_EMV_DATA_MAP(26)(POSITION), ELEMENTS_EMV_DATA_MAP(26)(LEN)))
      into g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).emv_data_6225
      from dual;
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6225_record;

procedure parse_dcf_6226_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is
    
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6226_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6226';
    
    ELEMENTS_DIN_DISCOV_DATA_MAP    constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1,  1,   4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2,  5,   1)
          , mcw_api_migs_type_pkg.t_position_length_tab(3,  6,   4)
          , mcw_api_migs_type_pkg.t_position_length_tab(4,  10,  15)
          , mcw_api_migs_type_pkg.t_position_length_tab(5,  25,  1)
          , mcw_api_migs_type_pkg.t_position_length_tab(6,  26,  231)
        );

    POSITION           constant com_api_type_pkg.t_sign := 2;
    LEN                constant com_api_type_pkg.t_sign := 3;
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;
        
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    select rtrim(substr(i_record_str, ELEMENTS_DIN_DISCOV_DATA_MAP(1)(POSITION), ELEMENTS_DIN_DISCOV_DATA_MAP(1)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_DIN_DISCOV_DATA_MAP(2)(POSITION), ELEMENTS_DIN_DISCOV_DATA_MAP(2)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_DIN_DISCOV_DATA_MAP(3)(POSITION), ELEMENTS_DIN_DISCOV_DATA_MAP(3)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_DIN_DISCOV_DATA_MAP(4)(POSITION), ELEMENTS_DIN_DISCOV_DATA_MAP(4)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_DIN_DISCOV_DATA_MAP(5)(POSITION), ELEMENTS_DIN_DISCOV_DATA_MAP(5)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_DIN_DISCOV_DATA_MAP(6)(POSITION), ELEMENTS_DIN_DISCOV_DATA_MAP(6)(LEN)))
      into g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).din_discov_data_6226
      from dual;
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6226_record;

procedure parse_dcf_6227_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is
    
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6227_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6227';
    
    ELEMENTS_DCC_DATA_MAP    constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1,  1,   4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2,  5,   20)
          , mcw_api_migs_type_pkg.t_position_length_tab(3,  25,  20)
          , mcw_api_migs_type_pkg.t_position_length_tab(4,  45,  12)
          , mcw_api_migs_type_pkg.t_position_length_tab(5,  57,  3)
          , mcw_api_migs_type_pkg.t_position_length_tab(6,  60,  3)
          , mcw_api_migs_type_pkg.t_position_length_tab(7,  63,  1)
          , mcw_api_migs_type_pkg.t_position_length_tab(8,  64,  13)
          , mcw_api_migs_type_pkg.t_position_length_tab(9,  77,  32)
          , mcw_api_migs_type_pkg.t_position_length_tab(10, 109, 14)
          , mcw_api_migs_type_pkg.t_position_length_tab(11, 123, 3)
          , mcw_api_migs_type_pkg.t_position_length_tab(12, 126, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(13, 127, 1)
          , mcw_api_migs_type_pkg.t_position_length_tab(14, 128, 129)
        );

    POSITION           constant com_api_type_pkg.t_sign := 2;
    LEN                constant com_api_type_pkg.t_sign := 3;
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;
        
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    select rtrim(substr(i_record_str, ELEMENTS_DCC_DATA_MAP(1)(POSITION), ELEMENTS_DCC_DATA_MAP(1)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_DCC_DATA_MAP(2)(POSITION), ELEMENTS_DCC_DATA_MAP(2)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_DCC_DATA_MAP(3)(POSITION), ELEMENTS_DCC_DATA_MAP(3)(LEN)))
         , to_number(
               substr(i_record_str, ELEMENTS_DCC_DATA_MAP(4)(POSITION), ELEMENTS_DCC_DATA_MAP(4)(LEN))
             , 'fm000000000000'
           )
         , rtrim(substr(i_record_str, ELEMENTS_DCC_DATA_MAP(5)(POSITION), ELEMENTS_DCC_DATA_MAP(5)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_DCC_DATA_MAP(6)(POSITION), ELEMENTS_DCC_DATA_MAP(6)(LEN)))
         , to_number(
               substr(i_record_str, ELEMENTS_DCC_DATA_MAP(7)(POSITION), ELEMENTS_DCC_DATA_MAP(7)(LEN))
             , 'fm0'
           )
         , to_number(
               substr(i_record_str, ELEMENTS_DCC_DATA_MAP(8)(POSITION), ELEMENTS_DCC_DATA_MAP(8)(LEN))
             , 'fm00000000000.0'
           )
         , rtrim(substr(i_record_str, ELEMENTS_DCC_DATA_MAP(9)(POSITION), ELEMENTS_DCC_DATA_MAP(9)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_DCC_DATA_MAP(10)(POSITION), ELEMENTS_DCC_DATA_MAP(10)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_DCC_DATA_MAP(11)(POSITION), ELEMENTS_DCC_DATA_MAP(11)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_DCC_DATA_MAP(12)(POSITION), ELEMENTS_DCC_DATA_MAP(12)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_DCC_DATA_MAP(13)(POSITION), ELEMENTS_DCC_DATA_MAP(13)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_DCC_DATA_MAP(14)(POSITION), ELEMENTS_DCC_DATA_MAP(14)(LEN)))
      into g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).dcc_data_6227
      from dual;
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6227_record;

procedure parse_dcf_6228_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is
    
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6228_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6228';
    
    ELEMENTS_MIGS_DATA_MAP    constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1,  1,   4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2,  5,   40)
          , mcw_api_migs_type_pkg.t_position_length_tab(3,  45,  16)
          , mcw_api_migs_type_pkg.t_position_length_tab(4,  61,  40)
          , mcw_api_migs_type_pkg.t_position_length_tab(5,  101, 21)
          , mcw_api_migs_type_pkg.t_position_length_tab(6,  122, 34)
          , mcw_api_migs_type_pkg.t_position_length_tab(7,  156, 40)
          , mcw_api_migs_type_pkg.t_position_length_tab(8,  196, 39)
          , mcw_api_migs_type_pkg.t_position_length_tab(9,  235, 4)
          , mcw_api_migs_type_pkg.t_position_length_tab(10, 239, 17)
          , mcw_api_migs_type_pkg.t_position_length_tab(11, 256, 1)
        );

    POSITION           constant com_api_type_pkg.t_sign := 2;
    LEN                constant com_api_type_pkg.t_sign := 3;
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;
        
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    select rtrim(substr(i_record_str, ELEMENTS_MIGS_DATA_MAP(1)(POSITION),  ELEMENTS_MIGS_DATA_MAP(1)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MIGS_DATA_MAP(2)(POSITION),  ELEMENTS_MIGS_DATA_MAP(2)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MIGS_DATA_MAP(3)(POSITION),  ELEMENTS_MIGS_DATA_MAP(3)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MIGS_DATA_MAP(4)(POSITION),  ELEMENTS_MIGS_DATA_MAP(4)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MIGS_DATA_MAP(5)(POSITION),  ELEMENTS_MIGS_DATA_MAP(5)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MIGS_DATA_MAP(6)(POSITION),  ELEMENTS_MIGS_DATA_MAP(6)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MIGS_DATA_MAP(7)(POSITION),  ELEMENTS_MIGS_DATA_MAP(7)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MIGS_DATA_MAP(8)(POSITION),  ELEMENTS_MIGS_DATA_MAP(8)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MIGS_DATA_MAP(9)(POSITION),  ELEMENTS_MIGS_DATA_MAP(9)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MIGS_DATA_MAP(10)(POSITION), ELEMENTS_MIGS_DATA_MAP(10)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_MIGS_DATA_MAP(11)(POSITION), ELEMENTS_MIGS_DATA_MAP(11)(LEN)))
      into g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).migs_data_6228
      from dual;
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6228_record;

procedure parse_dcf_6282_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is
    
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6282_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6282';
    
    ELEMENTS_MIGS_CUSTOM_DATA_MAP    constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1,  1,   4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2,  5,   3)
          , mcw_api_migs_type_pkg.t_position_length_tab(3,  8,   4)
          , mcw_api_migs_type_pkg.t_position_length_tab(4,  12,  245)
        );

    POSITION           constant com_api_type_pkg.t_sign := 2;
    LEN                constant com_api_type_pkg.t_sign := 3;
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;
        
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    select rtrim(substr(i_record_str, ELEMENTS_MIGS_CUSTOM_DATA_MAP(1)(POSITION),  ELEMENTS_MIGS_CUSTOM_DATA_MAP(1)(LEN)))
         , to_number(
               substr(i_record_str, ELEMENTS_MIGS_CUSTOM_DATA_MAP(2)(POSITION),  ELEMENTS_MIGS_CUSTOM_DATA_MAP(2)(LEN))
             , 'fm000'
           )
         , to_number(
               substr(i_record_str, ELEMENTS_MIGS_CUSTOM_DATA_MAP(3)(POSITION),  ELEMENTS_MIGS_CUSTOM_DATA_MAP(3)(LEN))
             , 'fm0000'
           )
         , rtrim(substr(i_record_str, ELEMENTS_MIGS_CUSTOM_DATA_MAP(4)(POSITION),  ELEMENTS_MIGS_CUSTOM_DATA_MAP(4)(LEN)))
      into g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).migs_customer_data_6282
      from dual;
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6282_record;

procedure parse_dcf_6229_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is
    
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6229_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6229';
    
    ELEMENTS_AIRLINE_DATA_MAP    constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1,  1,   4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2,  5,   49)
          , mcw_api_migs_type_pkg.t_position_length_tab(3,  54,  15)
          , mcw_api_migs_type_pkg.t_position_length_tab(4,  69,  4)
          , mcw_api_migs_type_pkg.t_position_length_tab(5,  73,  6)
          , mcw_api_migs_type_pkg.t_position_length_tab(6,  79,  27)
          , mcw_api_migs_type_pkg.t_position_length_tab(7,  106, 6)
          , mcw_api_migs_type_pkg.t_position_length_tab(8,  112, 8)
          , mcw_api_migs_type_pkg.t_position_length_tab(9,  120, 40)
          , mcw_api_migs_type_pkg.t_position_length_tab(10, 160, 12)
          , mcw_api_migs_type_pkg.t_position_length_tab(11, 172, 12)
          , mcw_api_migs_type_pkg.t_position_length_tab(12, 184, 12)
          , mcw_api_migs_type_pkg.t_position_length_tab(13, 196, 3)
          , mcw_api_migs_type_pkg.t_position_length_tab(14, 199, 58)
        );

    POSITION           constant com_api_type_pkg.t_sign := 2;
    LEN                constant com_api_type_pkg.t_sign := 3;
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;
        
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    select rtrim(substr(i_record_str, ELEMENTS_AIRLINE_DATA_MAP(1)(POSITION),  ELEMENTS_AIRLINE_DATA_MAP(1)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_DATA_MAP(2)(POSITION),  ELEMENTS_AIRLINE_DATA_MAP(2)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_DATA_MAP(3)(POSITION),  ELEMENTS_AIRLINE_DATA_MAP(3)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_DATA_MAP(4)(POSITION),  ELEMENTS_AIRLINE_DATA_MAP(4)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_DATA_MAP(5)(POSITION),  ELEMENTS_AIRLINE_DATA_MAP(5)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_DATA_MAP(6)(POSITION),  ELEMENTS_AIRLINE_DATA_MAP(6)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_DATA_MAP(7)(POSITION),  ELEMENTS_AIRLINE_DATA_MAP(7)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_DATA_MAP(8)(POSITION),  ELEMENTS_AIRLINE_DATA_MAP(8)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_DATA_MAP(9)(POSITION),  ELEMENTS_AIRLINE_DATA_MAP(9)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_DATA_MAP(10)(POSITION), ELEMENTS_AIRLINE_DATA_MAP(10)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_DATA_MAP(11)(POSITION), ELEMENTS_AIRLINE_DATA_MAP(11)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_DATA_MAP(12)(POSITION), ELEMENTS_AIRLINE_DATA_MAP(12)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_DATA_MAP(13)(POSITION), ELEMENTS_AIRLINE_DATA_MAP(13)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_DATA_MAP(14)(POSITION), ELEMENTS_AIRLINE_DATA_MAP(14)(LEN)))
      into g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).airline_data_6229
      from dual;
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6229_record;

procedure parse_dcf_air_leg_record(
    i_record_str           in com_api_type_pkg.t_exponent
  , o_result              out mcw_api_migs_type_pkg.t_airline_legs_data_rec
) is
    
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_air_leg_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_air_leg';
    
    ELEMENTS_AIRLINE_LEG_DATA_MAP    constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1,  1,   4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2,  5,   6)
          , mcw_api_migs_type_pkg.t_position_length_tab(3,  11,  4)
          , mcw_api_migs_type_pkg.t_position_length_tab(4,  15,  5)
          , mcw_api_migs_type_pkg.t_position_length_tab(5,  20,  6)
          , mcw_api_migs_type_pkg.t_position_length_tab(6,  26,  4)
          , mcw_api_migs_type_pkg.t_position_length_tab(7,  30,  5)
          , mcw_api_migs_type_pkg.t_position_length_tab(8,  35,  4)
          , mcw_api_migs_type_pkg.t_position_length_tab(9,  39,  2)
          , mcw_api_migs_type_pkg.t_position_length_tab(10, 41,  1)
          , mcw_api_migs_type_pkg.t_position_length_tab(11, 42,  15)
          , mcw_api_migs_type_pkg.t_position_length_tab(12, 57,  5)
          , mcw_api_migs_type_pkg.t_position_length_tab(13, 62,  15)
          , mcw_api_migs_type_pkg.t_position_length_tab(14, 77,  15)
          , mcw_api_migs_type_pkg.t_position_length_tab(15, 92,  1)
          , mcw_api_migs_type_pkg.t_position_length_tab(16, 93,  12)
          , mcw_api_migs_type_pkg.t_position_length_tab(17, 105, 12)
          , mcw_api_migs_type_pkg.t_position_length_tab(18, 117, 12)
          , mcw_api_migs_type_pkg.t_position_length_tab(19, 129, 20)
          , mcw_api_migs_type_pkg.t_position_length_tab(20, 149, 108)
        );

    POSITION           constant com_api_type_pkg.t_sign := 2;
    LEN                constant com_api_type_pkg.t_sign := 3;
        
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    select rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(1)(POSITION),  ELEMENTS_AIRLINE_LEG_DATA_MAP(1)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(2)(POSITION),  ELEMENTS_AIRLINE_LEG_DATA_MAP(2)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(3)(POSITION),  ELEMENTS_AIRLINE_LEG_DATA_MAP(3)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(4)(POSITION),  ELEMENTS_AIRLINE_LEG_DATA_MAP(4)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(5)(POSITION),  ELEMENTS_AIRLINE_LEG_DATA_MAP(5)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(6)(POSITION),  ELEMENTS_AIRLINE_LEG_DATA_MAP(6)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(7)(POSITION),  ELEMENTS_AIRLINE_LEG_DATA_MAP(7)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(8)(POSITION),  ELEMENTS_AIRLINE_LEG_DATA_MAP(8)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(9)(POSITION),  ELEMENTS_AIRLINE_LEG_DATA_MAP(9)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(10)(POSITION), ELEMENTS_AIRLINE_LEG_DATA_MAP(10)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(11)(POSITION), ELEMENTS_AIRLINE_LEG_DATA_MAP(11)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(12)(POSITION), ELEMENTS_AIRLINE_LEG_DATA_MAP(12)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(13)(POSITION), ELEMENTS_AIRLINE_LEG_DATA_MAP(13)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(14)(POSITION), ELEMENTS_AIRLINE_LEG_DATA_MAP(14)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(15)(POSITION), ELEMENTS_AIRLINE_LEG_DATA_MAP(15)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(16)(POSITION), ELEMENTS_AIRLINE_LEG_DATA_MAP(16)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(17)(POSITION), ELEMENTS_AIRLINE_LEG_DATA_MAP(17)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(18)(POSITION), ELEMENTS_AIRLINE_LEG_DATA_MAP(18)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(19)(POSITION), ELEMENTS_AIRLINE_LEG_DATA_MAP(19)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_AIRLINE_LEG_DATA_MAP(20)(POSITION), ELEMENTS_AIRLINE_LEG_DATA_MAP(20)(LEN)))
      into o_result
      from dual;
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_air_leg_record;

procedure parse_dcf_6230_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6230_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6230';
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;

begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    parse_dcf_air_leg_record(
        i_record_str => i_record_str
      , o_result     => g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).airline_legs_data_6230
    );
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6230_record;

procedure parse_dcf_6231_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6231_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6231';
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;

begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    parse_dcf_air_leg_record(
        i_record_str => i_record_str
      , o_result     => g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).airline_legs_data_6231
    );
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6231_record;

procedure parse_dcf_6232_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6232_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6232';
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;

begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    parse_dcf_air_leg_record(
        i_record_str => i_record_str
      , o_result     => g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).airline_legs_data_6232
    );
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6232_record;

procedure parse_dcf_6233_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6233_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6233';
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;

begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    parse_dcf_air_leg_record(
        i_record_str => i_record_str
      , o_result     => g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).airline_legs_data_6233
    );
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6233_record;

procedure parse_dcf_6234_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6234_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6234';
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;

begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    parse_dcf_air_leg_record(
        i_record_str => i_record_str
      , o_result     => g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).airline_legs_data_6234
    );
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6234_record;

procedure parse_dcf_6235_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6235_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6235';
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;

begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    parse_dcf_air_leg_record(
        i_record_str => i_record_str
      , o_result     => g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).airline_legs_data_6235
    );
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6235_record;

procedure parse_dcf_6236_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6236_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6236';
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;

begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    parse_dcf_air_leg_record(
        i_record_str => i_record_str
      , o_result     => g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).airline_legs_data_6236
    );
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6236_record;

procedure parse_dcf_6237_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6237_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6237';
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;

begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    parse_dcf_air_leg_record(
        i_record_str => i_record_str
      , o_result     => g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).airline_legs_data_6237
    );
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6237_record;

procedure parse_dcf_6238_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6238_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6238';
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;

begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    parse_dcf_air_leg_record(
        i_record_str => i_record_str
      , o_result     => g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).airline_legs_data_6238
    );
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6238_record;

procedure parse_dcf_6239_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6239_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6239';
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
    l_i_detail         mcw_api_migs_type_pkg.t_index;

begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main   := g_dcf_fin_messages.last;
    l_i_detail := g_dcf_fin_messages(l_i_main).fin_message_detail.last;
    
    parse_dcf_air_leg_record(
        i_record_str => i_record_str
      , o_result     => g_dcf_fin_messages(l_i_main).fin_message_detail(l_i_detail).airline_legs_data_6239
    );
      
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6239_record;

procedure parse_dcf_6240_record(
    i_record_str           in com_api_type_pkg.t_exponent
) is
    
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.parse_dcf_6240_record: ';
    
    RECORD_TYPE        constant com_api_type_pkg.t_name := 'dcf_6240';
    
    ELEMENTS_NOT_MAESTRO_MAP  constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1, 1,  4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2, 5,  32)
          , mcw_api_migs_type_pkg.t_position_length_tab(3, 37, 6)
          , mcw_api_migs_type_pkg.t_position_length_tab(4, 43, 6)
          , mcw_api_migs_type_pkg.t_position_length_tab(5, 49, 8)
          , mcw_api_migs_type_pkg.t_position_length_tab(6, 57, 200)
        );

    ELEMENTS_MAESTRO_MAP      constant mcw_api_migs_type_pkg.t_place_elements_tab :=
        mcw_api_migs_type_pkg.t_place_elements_tab(
            mcw_api_migs_type_pkg.t_position_length_tab(1, 1,  4)
          , mcw_api_migs_type_pkg.t_position_length_tab(2, 5,  32)
          , mcw_api_migs_type_pkg.t_position_length_tab(3, 37, 6)
          , mcw_api_migs_type_pkg.t_position_length_tab(4, 43, 6)
          , mcw_api_migs_type_pkg.t_position_length_tab(5, 49, 8)
          , mcw_api_migs_type_pkg.t_position_length_tab(6, 57, 11)
          , mcw_api_migs_type_pkg.t_position_length_tab(7, 68, 11)
          , mcw_api_migs_type_pkg.t_position_length_tab(8, 79, 178)
        );
        
    POSITION           constant com_api_type_pkg.t_sign := 2;
    LEN                constant com_api_type_pkg.t_sign := 3;
    
    l_i_main           mcw_api_migs_type_pkg.t_index;
        
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with string - ' || CRLF
                                 || i_record_str
    );
    
    l_i_main := g_dcf_fin_messages.last;
    
    select rtrim(substr(i_record_str, ELEMENTS_NOT_MAESTRO_MAP(1)(POSITION), ELEMENTS_NOT_MAESTRO_MAP(1)(LEN)))
         , rtrim(substr(i_record_str, ELEMENTS_NOT_MAESTRO_MAP(2)(POSITION), ELEMENTS_NOT_MAESTRO_MAP(2)(LEN)))
         , substr(i_record_str, ELEMENTS_NOT_MAESTRO_MAP(3)(POSITION), ELEMENTS_NOT_MAESTRO_MAP(3)(LEN))
         , substr(i_record_str, ELEMENTS_NOT_MAESTRO_MAP(4)(POSITION), ELEMENTS_NOT_MAESTRO_MAP(4)(LEN))
         , to_number(
               substr(i_record_str, ELEMENTS_NOT_MAESTRO_MAP(5)(POSITION), ELEMENTS_NOT_MAESTRO_MAP(5)(LEN))
             , 'fm00000000'
           )
         , substr(i_record_str, ELEMENTS_NOT_MAESTRO_MAP(6)(POSITION), ELEMENTS_NOT_MAESTRO_MAP(6)(LEN))
      into g_dcf_fin_messages(l_i_main).trailer_not_maestro
      from dual;
      
    if  g_dcf_fin_messages(l_i_main).trailer_not_maestro.acquirer_ica = '0' then
        
        g_dcf_fin_messages(l_i_main).trailer_not_maestro := null;
        
        select rtrim(substr(i_record_str, ELEMENTS_MAESTRO_MAP(1)(POSITION), ELEMENTS_MAESTRO_MAP(1)(LEN)))
             , rtrim(substr(i_record_str, ELEMENTS_MAESTRO_MAP(2)(POSITION), ELEMENTS_MAESTRO_MAP(2)(LEN)))
             , substr(i_record_str, ELEMENTS_MAESTRO_MAP(3)(POSITION), ELEMENTS_MAESTRO_MAP(3)(LEN))
             , substr(i_record_str, ELEMENTS_MAESTRO_MAP(4)(POSITION), ELEMENTS_MAESTRO_MAP(4)(LEN))
             , to_number(
                   substr(i_record_str, ELEMENTS_MAESTRO_MAP(5)(POSITION), ELEMENTS_MAESTRO_MAP(5)(LEN))
                 , 'fm00000000'
               )
             , to_number(
                   substr(i_record_str, ELEMENTS_MAESTRO_MAP(6)(POSITION), ELEMENTS_MAESTRO_MAP(6)(LEN))
                 , 'fm00000000000'
               )
             , to_number(
                   substr(i_record_str, ELEMENTS_MAESTRO_MAP(7)(POSITION), ELEMENTS_MAESTRO_MAP(7)(LEN))
                 , 'fm00000000000'
               )
             , substr(i_record_str, ELEMENTS_MAESTRO_MAP(8)(POSITION), ELEMENTS_MAESTRO_MAP(8)(LEN))
          into g_dcf_fin_messages(l_i_main).trailer_maestro
          from dual;
          
    end if;
     
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        com_api_error_pkg.raise_error(
            i_error         => 'UNABLE_TO_PARSE_RECORD'
          , i_env_param1    => RECORD_TYPE
          , i_env_param2    => i_record_str
        );
    
end parse_dcf_6240_record;

procedure extend_fin_message
is

    IS_FIRST   constant com_api_type_pkg.t_boolean := 1;

begin
    
    if not g_dcf_fin_messages.exists(IS_FIRST) then
        
        g_dcf_fin_messages :=  mcw_api_migs_type_pkg.t_fin_message_compleat_tab(null);
        
    else
        
        g_dcf_fin_messages.extend;
        
    end if;
    
end extend_fin_message;

procedure extend_fin_detail
is
    IS_FIRST   constant com_api_type_pkg.t_boolean := 1;
    
    l_index    mcw_api_migs_type_pkg.t_index;

begin
    
    l_index := g_dcf_fin_messages.last;
    
    if not g_dcf_fin_messages(l_index).fin_message_detail.exists(IS_FIRST) then
        
        g_dcf_fin_messages(l_index).fin_message_detail :=  mcw_api_migs_type_pkg.t_fin_message_detail_tab(null);
        
    else
        
        g_dcf_fin_messages(l_index).fin_message_detail.extend;
        
    end if;
    
end extend_fin_detail;

function get_record_type(
    i_record_str           in com_api_type_pkg.t_exponent
) return mcw_api_migs_type_pkg.t_dcf_record_type
is
begin
    return substr(i_record_str, 1, 4);
end get_record_type;

function response_code_map(
    i_resp_code_original   in com_api_type_pkg.t_byte_char
) return com_api_type_pkg.t_dict_value
is
begin
    
    return case
               when i_resp_code_original in ('00', '08', '11', '85')
                   then aup_api_const_pkg.RESP_CODE_OK
               when i_resp_code_original = '05'
                   then aup_api_const_pkg.RESP_CODE_DO_NOT_HONOR
               when i_resp_code_original = '51'
                   then aup_api_const_pkg.RESP_CODE_UNSUFFICIENT_FUNDS
               when i_resp_code_original = '54'
                   then aup_api_const_pkg.RESP_CODE_EXPIRED_CARD
               else aup_api_const_pkg.RESP_CODE_ERROR
           end;
           
end response_code_map;

function avs_response_code_map(
    i_avs_resp_code_original   in com_api_type_pkg.t_byte_char
) return com_api_type_pkg.t_dict_value
is
begin
    
    return case
               when i_avs_resp_code_original = 'A'
                   then aup_api_const_pkg.AVS_RES_ADDR_MATCH_ZIP_NOT
               when i_avs_resp_code_original = 'B'
                   then aup_api_const_pkg.AVS_RES_ADDR_MATCH_ZIP_INCOMP
               when i_avs_resp_code_original = 'C'
                   then aup_api_const_pkg.AVS_RES_ADDR_INCOMP_ZIP_INCOMP
               when i_avs_resp_code_original = 'G'
                   then aup_api_const_pkg.AVS_RES_NOT_VERIFIED_INTERNAL
               when i_avs_resp_code_original = 'N'
                   then aup_api_const_pkg.AVS_RES_NO_MATCH
               when i_avs_resp_code_original = 'P'
                   then aup_api_const_pkg.AVS_RES_ADDR_INCOMP
               when i_avs_resp_code_original = 'S'
                   then aup_api_const_pkg.AVS_RES_NOR_SUPPORTED
               when i_avs_resp_code_original = 'U'
                   then aup_api_const_pkg.AVS_RES_NOT_VERFIED_DOMESTIC
               when i_avs_resp_code_original = 'Y'
                   then aup_api_const_pkg.AVS_RES_ADDR_MATCH_ZIP_MATCH
               when i_avs_resp_code_original = 'Z'
                   then aup_api_const_pkg.AVS_RES_ZIP_MATCH_ADDR_NOT
               else  aup_api_const_pkg.AVS_RES_INITIAL
           end;
           
end avs_response_code_map;

function cvv2_result_map(
    i_cvv2_result_original   in com_api_type_pkg.t_byte_char
) return com_api_type_pkg.t_dict_value
is
begin
    
    return case
               when i_cvv2_result_original = 'M'
                   then CVV2_RESULT_MATCH
               when i_cvv2_result_original = 'N'
                   then CVV2_RESULT_NOT_MATCH
               when i_cvv2_result_original = 'P'
                   then CVV2_RESULT_NOT_PROCESSED
               when i_cvv2_result_original = 'S'
                   then CVV2_RESULT_NOT_PRESENT_VC
               when i_cvv2_result_original = 'U'
                   then CVV2_RESULT_ISS_NOT_PROVIDE
               else CVV2_RESULT_NOT_PROCESSED
           end;
           
end cvv2_result_map;

procedure check_duplication_operation(
    i_operate          in opr_api_type_pkg.t_oper_rec
) is

    l_operate_id_tab   com_api_type_pkg.t_long_tab;
    l_err_text         com_api_type_pkg.t_text;

begin
    
    select o.id
      bulk collect
      into l_operate_id_tab
      from opr_operation o
     where o.originator_refnum = i_operate.originator_refnum
           and o.msg_type = opr_api_const_pkg.MESSAGE_TYPE_POS_BATCH
           and trunc(o.oper_date) = trunc(i_operate.oper_date)
           and o.oper_amount = i_operate.oper_amount
           and o.oper_currency = i_operate.oper_currency
           and o.status in (
                   opr_api_const_pkg.OPERATION_STATUS_PROCESSING
                 , opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                 , opr_api_const_pkg.OPERATION_STATUS_MANUAL
                 , opr_api_const_pkg.OPERATION_STATUS_DUPLICATE
                 , opr_api_const_pkg.OPERATION_STATUS_MERGED
                 , opr_api_const_pkg.OPERATION_STATUS_WAIT_CLEARING
                 , opr_api_const_pkg.OPERATION_STATUS_WAIT_SETTL
                 , opr_api_const_pkg.OPERATION_STATUS_WAIT_ACTIV
                 , opr_api_const_pkg.OPERATION_STATUS_CORRECTED
                 , opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                 , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC
                 , opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD
               )
    ;
    
    if l_operate_id_tab.count > 0 then
        
        for i in l_operate_id_tab.first .. l_operate_id_tab.last
        loop
            l_err_text := l_err_text || to_char(l_operate_id_tab(i)) || ',';
        end loop;
        
        com_api_error_pkg.raise_error(
            i_error         => 'CHECK_NOT_SUCCESSFUL'
          , i_env_param1    => 'FOUND DUPLICATE OPERATIONS, ID IN (' || rtrim(l_err_text, ',') || ')'
        );
        
    end if;
    
end check_duplication_operation;

procedure internal_matching(
    i_operation_id     in com_api_type_pkg.t_long_id
) is

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.internal_matching: ';
    
    l_processed_count      com_api_type_pkg.t_long_id := 0;
    
begin

    trc_log_pkg.debug(LOG_PREFIX || 'START operation_id [' || i_operation_id || ']');
    
    for r in (
        select a.merchant_name
             , a.merchant_street
             , a.merchant_city
             , a.merchant_country
             , a.merchant_region
             , a.merchant_postcode
             , a.id original_id
             , a.terminal_type
             , a.acq_inst_bin
             , a.network_refnum
             , a.oper_request_amount
             , a.oper_surcharge_amount
             , d.resp_code                  
             , d.proc_type                  
             , d.proc_mode                  
             , d.is_advice                  
             , d.is_repeat                  
             , d.bin_amount                 
             , d.bin_currency               
             , d.bin_cnvt_rate              
             , d.network_amount             
             , d.network_currency           
             , d.network_cnvt_date          
             , d.network_cnvt_rate          
             , d.account_cnvt_rate          
             , d.parent_id                  
             , d.addr_verif_result          
             , d.iss_network_device_id      
             , d.acq_device_id              
             , d.acq_resp_code              
             , d.acq_device_proc_result     
             , d.cat_level                  
             , d.card_data_input_cap        
             , d.crdh_auth_cap              
             , d.card_capture_cap           
             , d.terminal_operating_env     
             , d.crdh_presence              
             , d.card_presence              
             , d.card_data_input_mode       
             , d.crdh_auth_method           
             , d.crdh_auth_entity           
             , d.card_data_output_cap       
             , d.terminal_output_cap        
             , d.pin_capture_cap            
             , d.pin_presence               
             , d.cvv2_presence              
             , d.cvc_indicator              
             , d.pos_entry_mode             
             , d.pos_cond_code              
             , d.emv_data                   
             , d.atc                        
             , d.tvr                        
             , d.cvr                        
             , d.addl_data                  
             , d.service_code               
             , d.device_date                
             , d.cvv2_result                
             , d.certificate_method         
             , d.certificate_type           
             , d.merchant_certif            
             , d.cardholder_certif          
             , d.ucaf_indicator             
             , d.is_early_emv               
             , d.is_completed               
             , d.amounts                    
             , d.cavv_presence              
             , d.aav_presence               
             , d.transaction_id             
             , d.system_trace_audit_number  
             , d.external_auth_id           
             , d.external_orig_id           
             , d.agent_unique_id            
             , d.native_resp_code           
             , d.trace_number     
             , e.card_service_code          
          from opr_operation a
             , opr_operation b
             , aut_auth c
             , aut_auth d
             , opr_participant e
         where b.id = i_operation_id
           and c.id = b.id
           and b.msg_type = opr_api_const_pkg.MESSAGE_TYPE_POS_BATCH
           and a.originator_refnum = b.originator_refnum
           and trunc(a.oper_date) = trunc(b.oper_date)
           and a.oper_amount = b.oper_amount
           and a.oper_currency = b.oper_currency
           and a.msg_type = opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
           and a.is_reversal = b.is_reversal
           and a.id = d.id
           and e.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
           and e.oper_id(+) = a.id
    ) loop
            
        update opr_operation a
           set a.merchant_name     = r.merchant_name
             , a.merchant_street   = r.merchant_street
             , a.merchant_city     = r.merchant_city
             , a.merchant_country  = r.merchant_country
             , a.merchant_region   = r.merchant_region
             , a.merchant_postcode = r.merchant_postcode
             , a.original_id       = nvl(a.original_id, r.original_id)
             , a.terminal_type     = r.terminal_type
             , a.acq_inst_bin      = r.acq_inst_bin
             , a.network_refnum    = r.network_refnum
             , a.oper_request_amount = r.oper_request_amount
             , a.oper_surcharge_amount = r.oper_surcharge_amount
         where a.id = i_operation_id;
         
        l_processed_count := sql%rowcount;
                 
        update aut_auth d
           set d.resp_code                  = nvl(d.resp_code                      , r.resp_code                )
             , d.proc_type                  = nvl(d.proc_type                      , r.proc_type                )
             , d.proc_mode                  = nvl(d.proc_mode                      , r.proc_mode                )
             , d.is_advice                  = nvl(d.is_advice                      , r.is_advice                )
             , d.is_repeat                  = nvl(d.is_repeat                      , r.is_repeat                )
             , d.bin_amount                 = nvl(d.bin_amount                     , r.bin_amount               )
             , d.bin_currency               = nvl(d.bin_currency                   , r.bin_currency             )
             , d.bin_cnvt_rate              = nvl(d.bin_cnvt_rate                  , r.bin_cnvt_rate            )
             , d.network_amount             = nvl(d.network_amount                 , r.network_amount           )
             , d.network_currency           = nvl(d.network_currency               , r.network_currency         )
             , d.network_cnvt_date          = nvl(d.network_cnvt_date              , r.network_cnvt_date        )
             , d.network_cnvt_rate          = nvl(d.network_cnvt_rate              , r.network_cnvt_rate        )
             , d.account_cnvt_rate          = nvl(d.account_cnvt_rate              , r.account_cnvt_rate        )
             , d.parent_id                  = nvl(d.parent_id                      , r.parent_id                )
             , d.addr_verif_result          = nvl(d.addr_verif_result              , r.addr_verif_result        )
             , d.iss_network_device_id      = nvl(d.iss_network_device_id          , r.iss_network_device_id    )
             , d.acq_device_id              = nvl(d.acq_device_id                  , r.acq_device_id            )
             , d.acq_resp_code              = nvl(d.acq_resp_code                  , r.acq_resp_code            )
             , d.acq_device_proc_result     = nvl(d.acq_device_proc_result         , r.acq_device_proc_result   )
             , d.cat_level                  = nvl(d.cat_level                      , r.cat_level                )
             , d.card_data_input_cap        = nvl(d.card_data_input_cap            , r.card_data_input_cap      )
             , d.crdh_auth_cap              = nvl(d.crdh_auth_cap                  , r.crdh_auth_cap            )
             , d.card_capture_cap           = nvl(d.card_capture_cap               , r.card_capture_cap         )
             , d.terminal_operating_env     = nvl(d.terminal_operating_env         , r.terminal_operating_env   )
             , d.crdh_presence              = nvl(d.crdh_presence                  , r.crdh_presence            )
             , d.card_presence              = nvl(d.card_presence                  , r.card_presence            )
             , d.card_data_input_mode       = nvl(d.card_data_input_mode           , r.card_data_input_mode     )
             , d.crdh_auth_method           = nvl(d.crdh_auth_method               , r.crdh_auth_method         )
             , d.crdh_auth_entity           = nvl(d.crdh_auth_entity               , r.crdh_auth_entity         )
             , d.card_data_output_cap       = nvl(d.card_data_output_cap           , r.card_data_output_cap     )
             , d.terminal_output_cap        = nvl(d.terminal_output_cap            , r.terminal_output_cap      )
             , d.pin_capture_cap            = nvl(d.pin_capture_cap                , r.pin_capture_cap          )
             , d.pin_presence               = nvl(d.pin_presence                   , r.pin_presence             )
             , d.cvv2_presence              = nvl(d.cvv2_presence                  , r.cvv2_presence            )
             , d.cvc_indicator              = nvl(d.cvc_indicator                  , r.cvc_indicator            )
             , d.pos_entry_mode             = nvl(d.pos_entry_mode                 , r.pos_entry_mode           )
             , d.pos_cond_code              = nvl(d.pos_cond_code                  , r.pos_cond_code            )
             , d.emv_data                   = nvl(d.emv_data                       , r.emv_data                 )
             , d.atc                        = nvl(d.atc                            , r.atc                      )
             , d.tvr                        = nvl(d.tvr                            , r.tvr                      )
             , d.cvr                        = nvl(d.cvr                            , r.cvr                      )
             , d.addl_data                  = nvl(d.addl_data                      , r.addl_data                )
             , d.service_code               = nvl(d.service_code                   , r.service_code             )
             , d.device_date                = nvl(d.device_date                    , r.device_date              )
             , d.cvv2_result                = nvl(d.cvv2_result                    , r.cvv2_result              )
             , d.certificate_method         = nvl(d.certificate_method             , r.certificate_method       )
             , d.certificate_type           = nvl(d.certificate_type               , r.certificate_type         )
             , d.merchant_certif            = nvl(d.merchant_certif                , r.merchant_certif          )
             , d.cardholder_certif          = nvl(d.cardholder_certif              , r.cardholder_certif        )
             , d.ucaf_indicator             = nvl(d.ucaf_indicator                 , r.ucaf_indicator           )
             , d.is_early_emv               = nvl(d.is_early_emv                   , r.is_early_emv             )
             , d.is_completed               = nvl(d.is_completed                   , r.is_completed             )
             , d.amounts                    = nvl(d.amounts                        , r.amounts                  )
             , d.cavv_presence              = nvl(d.cavv_presence                  , r.cavv_presence            )
             , d.aav_presence               = nvl(d.aav_presence                   , r.aav_presence             )
             , d.transaction_id             = nvl(d.transaction_id                 , r.transaction_id           )
             , d.system_trace_audit_number  = nvl(d.system_trace_audit_number      , r.system_trace_audit_number)
             , d.external_auth_id           = nvl(d.external_auth_id               , r.external_auth_id         )
             , d.external_orig_id           = nvl(d.external_orig_id               , r.external_orig_id         )
             , d.agent_unique_id            = nvl(d.agent_unique_id                , r.agent_unique_id          )
             , d.native_resp_code           = nvl(d.native_resp_code               , r.native_resp_code         )
             , d.trace_number               = nvl(d.trace_number                   , r.trace_number             )
         where d.id = i_operation_id;
         
        l_processed_count := l_processed_count + sql%rowcount;
         
        if r.card_service_code is not null then
            
            update opr_participant
               set card_service_code = r.card_service_code
             where participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and oper_id = i_operation_id;
               
            l_processed_count := l_processed_count + sql%rowcount;
                
        end if;
        
        exit;
        
    end loop;
    
    trc_log_pkg.debug(LOG_PREFIX || 'END; processed [' || l_processed_count || '] records');
    
end internal_matching;

procedure fin_message_operate_mapping(
    i_header_index     in mcw_api_migs_type_pkg.t_index
  , i_detail_index     in mcw_api_migs_type_pkg.t_index
  , o_operate         out opr_api_type_pkg.t_oper_rec
  , o_iss_part        out opr_api_type_pkg.t_oper_part_rec
  , o_acq_part        out opr_api_type_pkg.t_oper_part_rec
  , o_auth_data       out aut_api_type_pkg.t_auth_rec
) is
    
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.fin_message_operate_mapping: ';
    
    l_iss_inst_id          com_api_type_pkg.t_inst_id;
    l_acq_inst_id          com_api_type_pkg.t_inst_id;
    l_card_inst_id         com_api_type_pkg.t_inst_id;
    l_iss_network_id       com_api_type_pkg.t_tiny_id;
    l_iss_host_id          com_api_type_pkg.t_tiny_id;
    l_pan_length           com_api_type_pkg.t_tiny_id;
    l_acq_network_id       com_api_type_pkg.t_tiny_id;
    l_acq_inst_bin         com_api_type_pkg.t_rrn;
    l_host_id              com_api_type_pkg.t_tiny_id;
    l_standard_id          com_api_type_pkg.t_tiny_id;
    l_card_network_id      com_api_type_pkg.t_tiny_id;
    l_card_type_id         com_api_type_pkg.t_tiny_id;
    l_country_code         com_api_type_pkg.t_country_code;
    
    l_card_rec             iss_api_type_pkg.t_card_rec;
    
    l_param_tab            com_api_type_pkg.t_param_tab;
    
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with params - ' || CRLF
                                 || 'HEADER: ' || i_header_index || CRLF
                                 || 'DETAIL: ' || i_detail_index
    );
    
    if g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.record_type is null then
        
        com_api_error_pkg.raise_error(
            i_error        => 'WRONG_STRUCTURE_FIN_MESSAGE'
          , i_env_param1   => 'NOT FOUND RECORD TYPE 6220'
        );
        
    elsif g_dcf_fin_messages(i_header_index).header_not_maestro.record_type is null then
        
        com_api_error_pkg.raise_error(
            i_error        => 'WRONG_STRUCTURE_FIN_MESSAGE'
          , i_env_param1   => 'FOUND MAESTRO CARD HEADER. THIS TYPE NOT SUPPORTED.'
        );
        
    end if;
    
    if g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.original_stan_de90_sub <> 0 then
        
        com_api_error_pkg.raise_error(
            i_error        => 'WRONG_STRUCTURE_FIN_MESSAGE'
          , i_env_param1   => 'ORIGINAL STAN FIELD NOT EQUAL "0". THIS FINANCIAL RECORD NOT SUPPORTED.'
        );
        
    else
        
        o_operate.is_reversal   := com_api_const_pkg.FALSE;
        
    end if;
    
    o_operate.oper_date    := to_date(
                                  to_char(get_sysdate, 'yyyy')
                               || g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.transmit_date_time_de7
                                , 'yyyymmddhh24miss'
                              );
    
    --This code is made for the case of transfer to another year
    if o_operate.oper_date > get_sysdate then
        o_operate.oper_date := add_months(o_operate.oper_date, -12);
    end if;
    
    o_operate.host_date    := to_date(
                                  to_char(get_sysdate, 'yyyy')
                               || g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.transact_date_local_de13
                               || g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.transact_time_local_de12
                                , 'yyyymmddhh24miss'
                              );
                              
    --Comment is similar to on comment which higher
    if o_operate.host_date > get_sysdate then
        
        o_operate.host_date := add_months(o_operate.host_date, -12);
        
    end if;
    
    o_operate.id           := opr_api_create_pkg.get_id(i_host_date => o_operate.host_date);
    
    o_operate.status_reason := response_code_map(
                                   i_resp_code_original => g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.response_code_de39
                               );
    
    o_operate.status       := case
                                  when o_operate.status_reason = aup_api_const_pkg.RESP_CODE_OK
                                      then opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                                  else opr_api_const_pkg.OPERATION_STATUS_UNSUCCESSFUL
                              end;
    
    o_operate.oper_type    :=
        case 
            when g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.processing_code_de3 in (
                     '000000'
                   , '003000'
                   , '001000'
                   , '002000'
                 )
                then opr_api_const_pkg.OPERATION_TYPE_PURCHASE
            when g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.processing_code_de3 in (
                     '200000'
                   , '203000'
                   , '200010'
                   , '200020'
                   , '280010'
                   , '280020'
                 )
                then opr_api_const_pkg.OPERATION_TYPE_REFUND
            when g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.processing_code_de3 =
                     '280000'
                then opr_api_const_pkg.OPERATION_TYPE_PAYMENT
        end;
        
    if o_operate.oper_type is null then
        
        com_api_error_pkg.raise_error(
            i_error        => 'WRONG_STRUCTURE_FIN_MESSAGE'
          , i_env_param1   => 'WRONG VALUE PROCESSING CODE PARAMETER - ' || g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.processing_code_de3
          
        );
        
    end if;
    
    o_operate.msg_type     := 
        case g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.pos_transact_stat_de61_sub
            when '0'
                then opr_api_const_pkg.MESSAGE_TYPE_POS_BATCH
        end;
        
    if o_operate.msg_type is null then
        
        com_api_error_pkg.raise_error(
            i_error        => 'WRONG_STRUCTURE_FIN_MESSAGE'
          , i_env_param1   => 'WRONG VALUE POS TRANSACTION STATUS INDICATOR - ' || g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.pos_transact_stat_de61_sub
        );
        
    end if;
    
    o_iss_part.card_number     := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.card_number_de2;
    
    o_iss_part.card_id         := iss_api_card_pkg.get_card_id(i_card_number => o_iss_part.card_number);
    
    if o_iss_part.card_id is not null then
        
        iss_api_bin_pkg.get_bin_info(
            i_card_number      => o_iss_part.card_number
          , o_iss_inst_id      => l_iss_inst_id
          , o_iss_network_id   => l_iss_network_id
          , o_iss_host_id      => l_iss_host_id
          , o_card_type_id     => l_card_type_id
          , o_card_country     => l_country_code
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_pan_length       => l_pan_length
        );
    
        l_card_rec                   := iss_api_card_pkg.get_card(
                                            i_card_id => o_iss_part.card_id
                                        );
        o_iss_part.card_type_id      := l_card_type_id;
        o_iss_part.customer_id       := l_card_rec.customer_id;
        o_iss_part.card_hash         := l_card_rec.card_hash;
        o_iss_part.split_hash        := l_card_rec.split_hash;
    
        o_iss_part.card_seq_number   := iss_api_card_pkg.get_seq_number(i_card_number => o_iss_part.card_number);
        
    else
    
        net_api_bin_pkg.get_bin_info(
            i_card_number      => o_iss_part.card_number
          , i_oper_type        => o_operate.oper_type
          , o_iss_inst_id      => l_iss_inst_id
          , o_iss_network_id   => l_iss_network_id
          , o_iss_host_id      => l_iss_host_id
          , o_card_type_id     => l_card_type_id
          , o_card_country     => l_country_code
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_pan_length       => l_pan_length
        );
        
    end if;
    
    o_operate.oper_amount   := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.amount_transaction_de4;
    o_operate.oper_currency := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.transaction_cur_de49;
    
    
    o_operate.sttl_amount   := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.amount_settlement_de5;
    o_operate.sttl_currency := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.settlement_cur_de50;
    
    o_operate.mcc           := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.merchant_type_de18;
    
    o_operate.originator_refnum  := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.retrieval_ref_num_de37;
    o_operate.network_refnum     := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.retrieval_ref_num_de37;

    o_operate.merchant_number    := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.card_acceptor_id_de42;
    o_operate.terminal_number    := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.terminal_id_de41;
    
    o_operate.terminal_type      := case g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.cardh_activ_term_de61_sub
                                        when '6'
                                            then acq_api_const_pkg.TERMINAL_TYPE_EPOS
                                        else acq_api_const_pkg.TERMINAL_TYPE_POS
                                    end;
    
    o_operate.merchant_name      := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6221.merchant_name_de43;
    o_operate.merchant_street    := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6221.merchant_street_de43;
    o_operate.merchant_city      := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6221.merchant_city_de43;
    o_operate.merchant_region    := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6221.merchant_province_code_de120;
    o_operate.merchant_country   := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6221.merchant_country_code_de61;
    o_operate.merchant_postcode  := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6221.merchant_zip_code_de61;
    
    l_acq_network_id             := mcw_api_const_pkg.MCW_NETWORK_ID;
    l_host_id                    := net_api_network_pkg.get_default_host(l_acq_network_id);
    l_standard_id                := net_api_network_pkg.get_offline_standard(
                                        i_host_id           => l_host_id
                                    );
    l_acq_inst_id                := cmn_api_standard_pkg.find_value_owner (
                                        i_standard_id  => l_standard_id
                                      , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
                                      , i_object_id    => l_host_id
                                      , i_param_name   => mcw_api_const_pkg.CMID
                                      , i_value_char   => g_dcf_fin_messages(i_header_index).header_not_maestro.acquirer_ica
                                    );
                                    
    l_acq_inst_bin               := cmn_api_standard_pkg.get_varchar_value(
                                        i_inst_id     => l_acq_inst_id
                                      , i_standard_id => l_standard_id
                                      , i_object_id   => l_host_id
                                      , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
                                      , i_param_name  => mcw_api_const_pkg.ACQUIRER_BIN
                                      , i_param_tab   => l_param_tab
                                    );
    
    net_api_sttl_pkg.get_sttl_type(
        i_iss_inst_id      => l_iss_inst_id
      , i_acq_inst_id      => l_acq_inst_id
      , i_card_inst_id     => l_card_inst_id
      , i_iss_network_id   => l_iss_network_id
      , i_acq_network_id   => l_acq_network_id
      , i_card_network_id  => l_card_network_id
      , i_acq_inst_bin     => l_acq_inst_bin
      , o_sttl_type        => o_operate.sttl_type
      , o_match_status     => o_operate.match_status
      , i_oper_type        => o_operate.oper_type
    );
    
    o_operate.incom_sess_file_id := g_dcf_fin_messages(i_header_index).incom_sess_file_id;
    
    --issuer participant
    o_iss_part.participant_type  := com_api_const_pkg.PARTICIPANT_ISSUER;
    o_iss_part.card_expir_date   := to_date(
                                        g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.expiration_date_de14
                                      , 'yymm'
                                    );
                                    
    o_iss_part.inst_id           := l_iss_inst_id;
    o_iss_part.network_id        := l_iss_network_id;
    
    o_iss_part.card_mask         := iss_api_card_pkg.get_card_mask(
                                        i_card_number => o_iss_part.card_number
                                    );
    
    o_iss_part.card_country      := l_country_code;
    o_iss_part.card_inst_id      := l_card_inst_id;
    o_iss_part.card_network_id   := l_card_network_id;
    
    o_iss_part.client_id_type    := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
    o_iss_part.client_id_value   := o_iss_part.card_number;
    o_iss_part.auth_code         := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.auth_id_response_de38;
    o_iss_part.card_service_code := nvl(
                                        g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).mastercard_data_6222.service_code_de35
                                      , g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).emv_data_6225.card_service_code_de35
                                    );
    
    --acquirer participant
    o_acq_part.participant_type  := com_api_const_pkg.PARTICIPANT_ACQUIRER;
    o_acq_part.client_id_type    := opr_api_const_pkg.CLIENT_ID_TYPE_TERMINAL;
    o_acq_part.client_id_value   := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.terminal_id_de41;
    o_acq_part.inst_id           := l_acq_inst_id;
    o_acq_part.network_id        := l_acq_network_id;
    
    acq_api_terminal_pkg.get_terminal(
        i_inst_id         => l_acq_inst_id
      , i_merchant_number => o_operate.merchant_number
      , i_terminal_number => o_operate.terminal_number
      , o_merchant_id     => o_acq_part.merchant_id
      , o_terminal_id     => o_acq_part.terminal_id
    );
    
    --get auth data
    o_auth_data.resp_code                  := o_operate.status_reason;
    o_auth_data.proc_type                  := aut_api_const_pkg.DEFAULT_AUTH_PROC_TYPE;
    o_auth_data.proc_mode                  := case
                                                  when o_auth_data.resp_code = aup_api_const_pkg.RESP_CODE_OK
                                                      then aut_api_const_pkg.DEFAULT_AUTH_PROC_MODE
                                                  else aut_api_const_pkg.AUTH_PROC_MODE_DECLINED
                                              end;
    o_auth_data.is_advice                  := com_api_const_pkg.TRUE;
    o_auth_data.network_amount             := o_operate.oper_amount;
    o_auth_data.network_currency           := o_operate.oper_currency;
    o_auth_data.addr_verif_result          := avs_response_code_map(
                                                  i_avs_resp_code_original => g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.avs_response_de48_sub
                                              );
    o_auth_data.card_data_input_cap        := acq_api_const_pkg.DICT_CARD_DATA_INPUT_CAP      || DEFAULT_PART_DICT_CODE || g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.card_data_input_de22_sub;
    o_auth_data.crdh_auth_cap              := DICT_CARD_HOLDER_AUTH_CAP                       || DEFAULT_PART_DICT_CODE || g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.cardhld_auth_cpb_de22_sub;
    o_auth_data.card_capture_cap           := DICT_CARD_CAPTURE_CAP                           || DEFAULT_PART_DICT_CODE || g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.card_capture_de22_sub;
    o_auth_data.terminal_operating_env     := DICT_TERMINAL_OPERATING_ENV                     || DEFAULT_PART_DICT_CODE || g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.term_oper_env_de22_sub;
    o_auth_data.crdh_presence              := acq_api_const_pkg.DICT_CARDHOLDER_PRESENCE_DATA || DEFAULT_PART_DICT_CODE || g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.cardhld_prst_de22_sub;
    o_auth_data.card_presence              := acq_api_const_pkg.DICT_CARD_PRESENCE_DATA       || DEFAULT_PART_DICT_CODE || g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.card_present_de22_sub;
    o_auth_data.card_data_input_mode       := acq_api_const_pkg.DICT_CARD_DATA_INPUT_MODE     || DEFAULT_PART_DICT_CODE || g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.card_input_mode_de22_sub;
    o_auth_data.crdh_auth_method           := DICT_CARDHOLDER_AUTH_METHOD                     || DEFAULT_PART_DICT_CODE || g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.cardhld_auth_met_de22_sub;
    o_auth_data.pin_capture_cap            := DICT_PIN_CAPTURE_CAP                            || DEFAULT_PART_DICT_CODE || g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.pin_capture_cpb_de22_sub;
    o_auth_data.pos_entry_mode             := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.pos_entry_mode_de22;
    o_auth_data.pos_cond_code              := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.pos_condition_code_de25;
    o_auth_data.system_trace_audit_number  := g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.stan_de11;
    o_auth_data.cvv2_result                := cvv2_result_map(
                                                  i_cvv2_result_original => g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).transact_detail_6220.cv_result_code_de48_sub
                                              );
    o_auth_data.is_completed               := aut_api_const_pkg.AUTH_NOT_COMPLETE_STAGE_CONF;
    
    o_auth_data.auth_code                  := o_iss_part.auth_code;
    
    o_auth_data.service_code               := nvl(
                                                  g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).mastercard_data_6222.service_code_de35
                                                , g_dcf_fin_messages(i_header_index).fin_message_detail(i_detail_index).emv_data_6225.card_service_code_de35
                                              );
    
    trc_log_pkg.debug(LOG_PREFIX || 'END');
     
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'END with error: ' || SQLERRM);
        
        raise;
        
end fin_message_operate_mapping;

end mcw_api_migs_pkg;
/
