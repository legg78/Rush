create or replace force view bgn_ui_fin_msg_vw
as
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_ID', l.lang)
           , 'BGN_FIN_ID', substr (c.comments
                                 , 1
                                 , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_ID', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.id as column_number_value
        , to_date (null) as column_date_value
        , 1 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'ID'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_FILE_ID', l.lang)
           , 'BGN_FIN_FILE_ID', substr (c.comments
                                      , 1
                                      , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_FILE_ID', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.file_id as column_number_value
        , to_date (null) as column_date_value
        , 2 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'FILE_ID'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_STATUS', l.lang)
           , 'BGN_FIN_STATUS', substr (c.comments
                                     , 1
                                     , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_STATUS', l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.status as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 3 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'STATUS'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_IS_REVERSAL', l.lang)
           , 'BGN_FIN_IS_REVERSAL', substr (c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_IS_REVERSAL', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.is_reversal as column_number_value
        , to_date (null) as column_date_value
        , 4 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'IS_REVERSAL'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_DISPUTE_ID', l.lang)
           , 'BGN_FIN_DISPUTE_ID', substr (c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_DISPUTE_ID', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.dispute_id as column_number_value
        , to_date (null) as column_date_value
        , 5 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'DISPUTE_ID'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_INST_ID', l.lang)
           , 'BGN_FIN_INST_ID', substr (c.comments
                                      , 1
                                      , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_INST_ID', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.inst_id as column_number_value
        , to_date (null) as column_date_value
        , 6 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'INST_ID'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_NETWORK_ID', l.lang)
           , 'BGN_FIN_NETWORK_ID', substr (c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_NETWORK_ID', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.network_id as column_number_value
        , to_date (null) as column_date_value
        , 7 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'NETWORK_ID'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_IS_INCOMING', l.lang)
           , 'BGN_FIN_IS_INCOMING', substr (c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_IS_INCOMING', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.is_incoming as column_number_value
        , to_date (null) as column_date_value
        , 8 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'IS_INCOMING'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_PACKAGE_ID', l.lang)
           , 'BGN_FIN_PACKAGE_ID', substr (c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_PACKAGE_ID', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.package_id as column_number_value
        , to_date (null) as column_date_value
        , 9 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'PACKAGE_ID'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_RECORD_TYPE', l.lang)
           , 'BGN_FIN_RECORD_TYPE', substr (c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_RECORD_TYPE', l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.record_type as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 10 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'RECORD_TYPE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_RECORD_NUMBER'
                                             , l.lang)
           , 'BGN_FIN_RECORD_NUMBER', substr (c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_RECORD_NUMBER'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.record_number as column_number_value
        , to_date (null) as column_date_value
        , 11 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'RECORD_NUMBER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TRANSACTION_DATE'
                                             , l.lang)
           , 'BGN_FIN_TRANSACTION_DATE', substr (
                                            c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TRANSACTION_DATE'
                                             , l.lang))
             as name
        , 'DATE' as data_type
        , to_char (null) as column_char_value
        , to_number (null) as column_number_value
        , a.transaction_date as column_date_value
        , 12 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TRANSACTION_DATE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TRANSACTION_TYPE'
                                             , l.lang)
           , 'BGN_FIN_TRANSACTION_TYPE', substr (
                                            c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TRANSACTION_TYPE'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.transaction_type as column_number_value
        , to_date (null) as column_date_value
        , 13 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TRANSACTION_TYPE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_IS_REJECT', l.lang)
           , 'BGN_FIN_IS_REJECT', substr (c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_IS_REJECT', l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.is_reject as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 14 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'IS_REJECT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_IS_FINANCE', l.lang)
           , 'BGN_FIN_IS_FINANCE', substr (c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_IS_FINANCE', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.is_finance as column_number_value
        , to_date (null) as column_date_value
        , 15 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'IS_FINANCE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CARD_MASK', l.lang)
           , 'BGN_FIN_CARD_MASK', substr (c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CARD_MASK', l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.card_mask as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 16 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CARD_MASK'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CARD_SEQ_NUMBER'
                                             , l.lang)
           , 'BGN_FIN_CARD_SEQ_NUMBER', substr (
                                           c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CARD_SEQ_NUMBER'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.card_seq_number as column_number_value
        , to_date (null) as column_date_value
        , 17 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CARD_SEQ_NUMBER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CARD_EXPIRE_DATE'
                                             , l.lang)
           , 'BGN_FIN_CARD_EXPIRE_DATE', substr (
                                            c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CARD_EXPIRE_DATE'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.card_expire_date as column_number_value
        , to_date (null) as column_date_value
        , 18 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CARD_EXPIRE_DATE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CARD_TYPE', l.lang)
           , 'BGN_FIN_CARD_TYPE', substr (c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CARD_TYPE', l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.card_type as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 19 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CARD_TYPE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_ACQUIRER_AMOUNT'
                                             , l.lang)
           , 'BGN_FIN_ACQUIRER_AMOUNT', substr (
                                           c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_ACQUIRER_AMOUNT'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.acquirer_amount as column_number_value
        , to_date (null) as column_date_value
        , 20 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'ACQUIRER_AMOUNT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_ACQUIRER_CURRENCY'
                                             , l.lang)
           , 'BGN_FIN_ACQUIRER_CURRENCY', substr (
                                             c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_ACQUIRER_CURRENCY'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.acquirer_currency as column_number_value
        , to_date (null) as column_date_value
        , 21 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'ACQUIRER_CURRENCY'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_NETWORK_AMOUNT'
                                             , l.lang)
           , 'BGN_FIN_NETWORK_AMOUNT', substr (
                                          c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_NETWORK_AMOUNT'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.network_amount as column_number_value
        , to_date (null) as column_date_value
        , 22 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'NETWORK_AMOUNT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_NETWORK_CURRENCY'
                                             , l.lang)
           , 'BGN_FIN_NETWORK_CURRENCY', substr (
                                            c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_NETWORK_CURRENCY'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.network_currency as column_number_value
        , to_date (null) as column_date_value
        , 23 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'NETWORK_CURRENCY'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CARD_AMOUNT', l.lang)
           , 'BGN_FIN_CARD_AMOUNT', substr (c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CARD_AMOUNT', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.card_amount as column_number_value
        , to_date (null) as column_date_value
        , 24 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CARD_AMOUNT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CARD_CURRENCY'
                                             , l.lang)
           , 'BGN_FIN_CARD_CURRENCY', substr (c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CARD_CURRENCY'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.card_currency as column_number_value
        , to_date (null) as column_date_value
        , 25 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CARD_CURRENCY'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_AUTH_CODE', l.lang)
           , 'BGN_FIN_AUTH_CODE', substr (c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_AUTH_CODE', l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.auth_code as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 26 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'AUTH_CODE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TRACE_NUMBER'
                                             , l.lang)
           , 'BGN_FIN_TRACE_NUMBER', substr (c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TRACE_NUMBER'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.trace_number as column_number_value
        , to_date (null) as column_date_value
        , 27 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TRACE_NUMBER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_RETRIEVAL_REFNUM'
                                             , l.lang)
           , 'BGN_FIN_RETRIEVAL_REFNUM', substr (
                                            c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_RETRIEVAL_REFNUM'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.retrieval_refnum as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 28 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'RETRIEVAL_REFNUM'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_MERCHANT_NUMBER'
                                             , l.lang)
           , 'BGN_FIN_MERCHANT_NUMBER', substr (
                                           c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_MERCHANT_NUMBER'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.merchant_number as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 29 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'MERCHANT_NUMBER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_MERCHANT_NAME'
                                             , l.lang)
           , 'BGN_FIN_MERCHANT_NAME', substr (c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_MERCHANT_NAME'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.merchant_name as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 30 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'MERCHANT_NAME'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_MERCHANT_CITY'
                                             , l.lang)
           , 'BGN_FIN_MERCHANT_CITY', substr (c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_MERCHANT_CITY'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.merchant_city as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 31 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'MERCHANT_CITY'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_MCC', l.lang)
           , 'BGN_FIN_MCC', substr (c.comments
                                  , 1
                                  , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_MCC', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.mcc as column_number_value
        , to_date (null) as column_date_value
        , 32 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'MCC'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_NUMBER'
                                             , l.lang)
           , 'BGN_FIN_TERMINAL_NUMBER', substr (
                                           c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_NUMBER'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.terminal_number as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 33 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TERMINAL_NUMBER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_POS_ENTRY_MODE'
                                             , l.lang)
           , 'BGN_FIN_POS_ENTRY_MODE', substr (
                                          c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_POS_ENTRY_MODE'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.pos_entry_mode as column_number_value
        , to_date (null) as column_date_value
        , 34 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'POS_ENTRY_MODE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_AIN', l.lang)
           , 'BGN_FIN_AIN', substr (c.comments
                                  , 1
                                  , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_AIN', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.ain as column_number_value
        , to_date (null) as column_date_value
        , 35 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'AIN'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_AUTH_INDICATOR'
                                             , l.lang)
           , 'BGN_FIN_AUTH_INDICATOR', substr (
                                          c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_AUTH_INDICATOR'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.auth_indicator as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 36 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'AUTH_INDICATOR'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TRANSACTION_NUMBER'
                                             , l.lang)
           , 'BGN_FIN_TRANSACTION_NUMBER', substr (
                                              c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TRANSACTION_NUMBER'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.transaction_number as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 37 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TRANSACTION_NUMBER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_VALIDATION_CODE'
                                             , l.lang)
           , 'BGN_FIN_VALIDATION_CODE', substr (
                                           c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_VALIDATION_CODE'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.validation_code as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 38 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'VALIDATION_CODE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_MARKET_DATA_ID'
                                             , l.lang)
           , 'BGN_FIN_MARKET_DATA_ID', substr (
                                          c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_MARKET_DATA_ID'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.market_data_id as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 39 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'MARKET_DATA_ID'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_ADD_RESPONSE_DATA'
                                             , l.lang)
           , 'BGN_FIN_ADD_RESPONSE_DATA', substr (
                                             c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_ADD_RESPONSE_DATA'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.add_response_data as column_number_value
        , to_date (null) as column_date_value
        , 40 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'ADD_RESPONSE_DATA'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_REJECT_CODE', l.lang)
           , 'BGN_FIN_REJECT_CODE', substr (c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_REJECT_CODE', l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.reject_code as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 41 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'REJECT_CODE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_RESPONSE_CODE'
                                             , l.lang)
           , 'BGN_FIN_RESPONSE_CODE', substr (c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_RESPONSE_CODE'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.response_code as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 42 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'RESPONSE_CODE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_REJECT_TEXT', l.lang)
           , 'BGN_FIN_REJECT_TEXT', substr (c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_REJECT_TEXT', l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.reject_text as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 43 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'REJECT_TEXT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_IS_OFFLINE', l.lang)
           , 'BGN_FIN_IS_OFFLINE', substr (c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_IS_OFFLINE', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.is_offline as column_number_value
        , to_date (null) as column_date_value
        , 44 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'IS_OFFLINE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_POS_TEXT', l.lang)
           , 'BGN_FIN_POS_TEXT', substr (c.comments
                                       , 1
                                       , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_POS_TEXT', l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.pos_text as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 45 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'POS_TEXT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_RESULT_CODE', l.lang)
           , 'BGN_FIN_RESULT_CODE', substr (c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_RESULT_CODE', l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.result_code as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 46 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'RESULT_CODE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_CAP'
                                             , l.lang)
           , 'BGN_FIN_TERMINAL_CAP', substr (c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_CAP'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.terminal_cap as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 47 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TERMINAL_CAP'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_RESULT'
                                             , l.lang)
           , 'BGN_FIN_TERMINAL_RESULT', substr (
                                           c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_RESULT'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.terminal_result as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 48 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TERMINAL_RESULT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_UNPRED_NUMBER'
                                             , l.lang)
           , 'BGN_FIN_UNPRED_NUMBER', substr (c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_UNPRED_NUMBER'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.unpred_number as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 49 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'UNPRED_NUMBER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_SEQ_NUMBER'
                                             , l.lang)
           , 'BGN_FIN_TERMINAL_SEQ_NUMBER', substr (
                                               c.comments
                                             , 1
                                             , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_SEQ_NUMBER'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.terminal_seq_number as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 50 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TERMINAL_SEQ_NUMBER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_DERIVATION_KEY_INDEX'
                                             , l.lang)
           , 'BGN_FIN_DERIVATION_KEY_INDEX', substr (
                                                c.comments
                                              , 1
                                              , instr (c.comments || '.'
                                                     , '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_DERIVATION_KEY_INDEX'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.derivation_key_index as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 51 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'DERIVATION_KEY_INDEX'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CRYPTO_VERSION'
                                             , l.lang)
           , 'BGN_FIN_CRYPTO_VERSION', substr (
                                          c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CRYPTO_VERSION'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.crypto_version as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 52 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CRYPTO_VERSION'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CARD_RESULT', l.lang)
           , 'BGN_FIN_CARD_RESULT', substr (c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CARD_RESULT', l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.card_result as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 53 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CARD_RESULT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_APP_CRYPTO', l.lang)
           , 'BGN_FIN_APP_CRYPTO', substr (c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_APP_CRYPTO', l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.app_crypto as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 54 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'APP_CRYPTO'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_APP_TRANS_COUNTER'
                                             , l.lang)
           , 'BGN_FIN_APP_TRANS_COUNTER', substr (
                                             c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_APP_TRANS_COUNTER'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.app_trans_counter as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 55 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'APP_TRANS_COUNTER'
   union all
   select decode (
             com_api_label_pkg.get_label_text (
                'BGN_FIN_APP_INTERCHANGE_PROFILE'
              , l.lang)
           , 'BGN_FIN_APP_INTERCHANGE_PROFILE', substr (
                                                   c.comments
                                                 , 1
                                                 , instr (c.comments || '.'
                                                        , '.'))
           , com_api_label_pkg.get_label_text (
                'BGN_FIN_APP_INTERCHANGE_PROFILE'
              , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.app_interchange_profile as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 56 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'APP_INTERCHANGE_PROFILE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_ISS_SCRIPT1_RESULT'
                                             , l.lang)
           , 'BGN_FIN_ISS_SCRIPT1_RESULT', substr (
                                              c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_ISS_SCRIPT1_RESULT'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.iss_script1_result as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 57 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'ISS_SCRIPT1_RESULT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_ISS_SCRIPT2_RESULT'
                                             , l.lang)
           , 'BGN_FIN_ISS_SCRIPT2_RESULT', substr (
                                              c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_ISS_SCRIPT2_RESULT'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.iss_script2_result as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 58 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'ISS_SCRIPT2_RESULT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_COUNTRY'
                                             , l.lang)
           , 'BGN_FIN_TERMINAL_COUNTRY', substr (
                                            c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_COUNTRY'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.terminal_country as column_number_value
        , to_date (null) as column_date_value
        , 59 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TERMINAL_COUNTRY'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_DATE'
                                             , l.lang)
           , 'BGN_FIN_TERMINAL_DATE', substr (c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_DATE'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.terminal_date as column_number_value
        , to_date (null) as column_date_value
        , 60 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TERMINAL_DATE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_AUTH_RESPONSE_CODE'
                                             , l.lang)
           , 'BGN_FIN_AUTH_RESPONSE_CODE', substr (
                                              c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_AUTH_RESPONSE_CODE'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.auth_response_code as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 61 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'AUTH_RESPONSE_CODE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_OTHER_AMOUNT'
                                             , l.lang)
           , 'BGN_FIN_OTHER_AMOUNT', substr (c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_OTHER_AMOUNT'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.other_amount as column_number_value
        , to_date (null) as column_date_value
        , 62 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'OTHER_AMOUNT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TRANS_TYPE_1'
                                             , l.lang)
           , 'BGN_FIN_TRANS_TYPE_1', substr (c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TRANS_TYPE_1'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.trans_type_1 as column_number_value
        , to_date (null) as column_date_value
        , 63 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TRANS_TYPE_1'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_TYPE'
                                             , l.lang)
           , 'BGN_FIN_TERMINAL_TYPE', substr (c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_TYPE'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.terminal_type as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 64 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TERMINAL_TYPE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TRANS_CATEGORY'
                                             , l.lang)
           , 'BGN_FIN_TRANS_CATEGORY', substr (
                                          c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TRANS_CATEGORY'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.trans_category as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 65 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TRANS_CATEGORY'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TRANS_SEQ_COUNTER'
                                             , l.lang)
           , 'BGN_FIN_TRANS_SEQ_COUNTER', substr (
                                             c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TRANS_SEQ_COUNTER'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.trans_seq_counter as column_number_value
        , to_date (null) as column_date_value
        , 66 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TRANS_SEQ_COUNTER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CRYPTO_INFO_DATA'
                                             , l.lang)
           , 'BGN_FIN_CRYPTO_INFO_DATA', substr (
                                            c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CRYPTO_INFO_DATA'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.crypto_info_data as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 67 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CRYPTO_INFO_DATA'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_DEDICATED_FILENAME'
                                             , l.lang)
           , 'BGN_FIN_DEDICATED_FILENAME', substr (
                                              c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_DEDICATED_FILENAME'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.dedicated_filename as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 68 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'DEDICATED_FILENAME'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_ISS_APP_DATA'
                                             , l.lang)
           , 'BGN_FIN_ISS_APP_DATA', substr (c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_ISS_APP_DATA'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.iss_app_data as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 69 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'ISS_APP_DATA'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CVM_RESULT', l.lang)
           , 'BGN_FIN_CVM_RESULT', substr (c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CVM_RESULT', l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.cvm_result as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 70 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CVM_RESULT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_APP_VERSION'
                                             , l.lang)
           , 'BGN_FIN_TERMINAL_APP_VERSION', substr (
                                                c.comments
                                              , 1
                                              , instr (c.comments || '.'
                                                     , '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_APP_VERSION'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.terminal_app_version as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 71 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TERMINAL_APP_VERSION'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_STTL_DATE', l.lang)
           , 'BGN_FIN_STTL_DATE', substr (c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_STTL_DATE', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.sttl_date as column_number_value
        , to_date (null) as column_date_value
        , 72 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'STTL_DATE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_NETWORK_DATA'
                                             , l.lang)
           , 'BGN_FIN_NETWORK_DATA', substr (c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_NETWORK_DATA'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.network_data as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 73 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'NETWORK_DATA'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CASHBACK_ACQ_AMOUNT'
                                             , l.lang)
           , 'BGN_FIN_CASHBACK_ACQ_AMOUNT', substr (
                                               c.comments
                                             , 1
                                             , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CASHBACK_ACQ_AMOUNT'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.cashback_acq_amount as column_number_value
        , to_date (null) as column_date_value
        , 74 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CASHBACK_ACQ_AMOUNT'
   union all
   select decode (
             com_api_label_pkg.get_label_text (
                'BGN_FIN_CASHBACK_ACQ_CURRENCY'
              , l.lang)
           , 'BGN_FIN_CASHBACK_ACQ_CURRENCY', substr (
                                                 c.comments
                                               , 1
                                               , instr (c.comments || '.'
                                                      , '.'))
           , com_api_label_pkg.get_label_text (
                'BGN_FIN_CASHBACK_ACQ_CURRENCY'
              , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.cashback_acq_currency as column_number_value
        , to_date (null) as column_date_value
        , 75 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CASHBACK_ACQ_CURRENCY'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CASHBACK_NET_AMOUNT'
                                             , l.lang)
           , 'BGN_FIN_CASHBACK_NET_AMOUNT', substr (
                                               c.comments
                                             , 1
                                             , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CASHBACK_NET_AMOUNT'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.cashback_net_amount as column_number_value
        , to_date (null) as column_date_value
        , 76 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CASHBACK_NET_AMOUNT'
   union all
   select decode (
             com_api_label_pkg.get_label_text (
                'BGN_FIN_CASHBACK_NET_CURRENCY'
              , l.lang)
           , 'BGN_FIN_CASHBACK_NET_CURRENCY', substr (
                                                 c.comments
                                               , 1
                                               , instr (c.comments || '.'
                                                      , '.'))
           , com_api_label_pkg.get_label_text (
                'BGN_FIN_CASHBACK_NET_CURRENCY'
              , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.cashback_net_currency as column_number_value
        , to_date (null) as column_date_value
        , 77 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CASHBACK_NET_CURRENCY'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CASHBACK_CARD_AMOUNT'
                                             , l.lang)
           , 'BGN_FIN_CASHBACK_CARD_AMOUNT', substr (
                                                c.comments
                                              , 1
                                              , instr (c.comments || '.'
                                                     , '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CASHBACK_CARD_AMOUNT'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.cashback_card_amount as column_number_value
        , to_date (null) as column_date_value
        , 78 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CASHBACK_CARD_AMOUNT'
   union all
   select decode (
             com_api_label_pkg.get_label_text (
                'BGN_FIN_CASHBACK_CARD_CURRENCY'
              , l.lang)
           , 'BGN_FIN_CASHBACK_CARD_CURRENCY', substr (
                                                  c.comments
                                                , 1
                                                , instr (c.comments || '.'
                                                       , '.'))
           , com_api_label_pkg.get_label_text (
                'BGN_FIN_CASHBACK_CARD_CURRENCY'
              , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.cashback_card_currency as column_number_value
        , to_date (null) as column_date_value
        , 79 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CASHBACK_CARD_CURRENCY'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TERM_TYPE', l.lang)
           , 'BGN_FIN_TERM_TYPE', substr (c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TERM_TYPE', l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.term_type as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 80 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TERM_TYPE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_SUBTYPE'
                                             , l.lang)
           , 'BGN_FIN_TERMINAL_SUBTYPE', substr (
                                            c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TERMINAL_SUBTYPE'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.terminal_subtype as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 81 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TERMINAL_SUBTYPE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TRANS_TYPE_2'
                                             , l.lang)
           , 'BGN_FIN_TRANS_TYPE_2', substr (c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TRANS_TYPE_2'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.trans_type_2 as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 82 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TRANS_TYPE_2'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CASHM_REFNUM'
                                             , l.lang)
           , 'BGN_FIN_CASHM_REFNUM', substr (c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CASHM_REFNUM'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.cashm_refnum as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 83 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CASHM_REFNUM'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_STTL_AMOUNT', l.lang)
           , 'BGN_FIN_STTL_AMOUNT', substr (c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_STTL_AMOUNT', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.sttl_amount as column_number_value
        , to_date (null) as column_date_value
        , 84 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'STTL_AMOUNT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_INTERBANK_FEE_AMOUNT'
                                             , l.lang)
           , 'BGN_FIN_INTERBANK_FEE_AMOUNT', substr (
                                                c.comments
                                              , 1
                                              , instr (c.comments || '.'
                                                     , '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_INTERBANK_FEE_AMOUNT'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.interbank_fee_amount as column_number_value
        , to_date (null) as column_date_value
        , 85 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'INTERBANK_FEE_AMOUNT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_BANK_CARD_ID'
                                             , l.lang)
           , 'BGN_FIN_BANK_CARD_ID', substr (c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_BANK_CARD_ID'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.bank_card_id as column_number_value
        , to_date (null) as column_date_value
        , 86 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'BANK_CARD_ID'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_ECOMMERCE', l.lang)
           , 'BGN_FIN_ECOMMERCE', substr (c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_ECOMMERCE', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.ecommerce as column_number_value
        , to_date (null) as column_date_value
        , 87 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'ECOMMERCE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TRANSACTION_AMOUNT'
                                             , l.lang)
           , 'BGN_FIN_TRANSACTION_AMOUNT', substr (
                                              c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TRANSACTION_AMOUNT'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.transaction_amount as column_number_value
        , to_date (null) as column_date_value
        , 88 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TRANSACTION_AMOUNT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TRANSACTION_CURRENCY'
                                             , l.lang)
           , 'BGN_FIN_TRANSACTION_CURRENCY', substr (
                                                c.comments
                                              , 1
                                              , instr (c.comments || '.'
                                                     , '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TRANSACTION_CURRENCY'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.transaction_currency as column_number_value
        , to_date (null) as column_date_value
        , 89 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TRANSACTION_CURRENCY'
   union all
   select decode (
             com_api_label_pkg.get_label_text (
                'BGN_FIN_ORIGINAL_TRANS_NUMBER'
              , l.lang)
           , 'BGN_FIN_ORIGINAL_TRANS_NUMBER', substr (
                                                 c.comments
                                               , 1
                                               , instr (c.comments || '.'
                                                      , '.'))
           , com_api_label_pkg.get_label_text (
                'BGN_FIN_ORIGINAL_TRANS_NUMBER'
              , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.original_trans_number as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 90 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'ORIGINAL_TRANS_NUMBER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_ACCOUNT_NUMBER'
                                             , l.lang)
           , 'BGN_FIN_ACCOUNT_NUMBER', substr (
                                          c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_ACCOUNT_NUMBER'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.account_number as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 91 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'ACCOUNT_NUMBER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_REPORT_PERIOD'
                                             , l.lang)
           , 'BGN_FIN_REPORT_PERIOD', substr (c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_REPORT_PERIOD'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.report_period as column_number_value
        , to_date (null) as column_date_value
        , 92 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'REPORT_PERIOD'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_WITHDRAWAL_NUMBER'
                                             , l.lang)
           , 'BGN_FIN_WITHDRAWAL_NUMBER', substr (
                                             c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_WITHDRAWAL_NUMBER'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.withdrawal_number as column_number_value
        , to_date (null) as column_date_value
        , 93 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'WITHDRAWAL_NUMBER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_PERIOD_AMOUNT'
                                             , l.lang)
           , 'BGN_FIN_PERIOD_AMOUNT', substr (c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_PERIOD_AMOUNT'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.period_amount as column_number_value
        , to_date (null) as column_date_value
        , 94 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'PERIOD_AMOUNT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CARD_SUBTYPE'
                                             , l.lang)
           , 'BGN_FIN_CARD_SUBTYPE', substr (c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CARD_SUBTYPE'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.card_subtype as column_number_value
        , to_date (null) as column_date_value
        , 95 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CARD_SUBTYPE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_ISSUER_CODE', l.lang)
           , 'BGN_FIN_ISSUER_CODE', substr (c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_ISSUER_CODE', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.issuer_code as column_number_value
        , to_date (null) as column_date_value
        , 96 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'ISSUER_CODE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_CARD_ACC_NUMBER'
                                             , l.lang)
           , 'BGN_FIN_CARD_ACC_NUMBER', substr (
                                           c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_CARD_ACC_NUMBER'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.card_acc_number as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 97 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'CARD_ACC_NUMBER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_ADD_ACC_NUMBER'
                                             , l.lang)
           , 'BGN_FIN_ADD_ACC_NUMBER', substr (
                                          c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_ADD_ACC_NUMBER'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.add_acc_number as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 98 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'ADD_ACC_NUMBER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_ATM_BANK_CODE'
                                             , l.lang)
           , 'BGN_FIN_ATM_BANK_CODE', substr (c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_ATM_BANK_CODE'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.atm_bank_code as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 99 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'ATM_BANK_CODE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_DEPOSIT_NUMBER'
                                             , l.lang)
           , 'BGN_FIN_DEPOSIT_NUMBER', substr (
                                          c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_DEPOSIT_NUMBER'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.deposit_number as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 100 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'DEPOSIT_NUMBER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_LOADED_AMOUNT_ATM'
                                             , l.lang)
           , 'BGN_FIN_LOADED_AMOUNT_ATM', substr (
                                             c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_LOADED_AMOUNT_ATM'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.loaded_amount_atm as column_number_value
        , to_date (null) as column_date_value
        , 101 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'LOADED_AMOUNT_ATM'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_IS_FULLLOAD', l.lang)
           , 'BGN_FIN_IS_FULLLOAD', substr (c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_IS_FULLLOAD', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.is_fullload as column_number_value
        , to_date (null) as column_date_value
        , 102 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'IS_FULLLOAD'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TOTAL_AMOUNT_ATM'
                                             , l.lang)
           , 'BGN_FIN_TOTAL_AMOUNT_ATM', substr (
                                            c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TOTAL_AMOUNT_ATM'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.total_amount_atm as column_number_value
        , to_date (null) as column_date_value
        , 103 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TOTAL_AMOUNT_ATM'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_TOTAL_AMOUNT_TANDEM'
                                             , l.lang)
           , 'BGN_FIN_TOTAL_AMOUNT_TANDEM', substr (
                                               c.comments
                                             , 1
                                             , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_TOTAL_AMOUNT_TANDEM'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.total_amount_tandem as column_number_value
        , to_date (null) as column_date_value
        , 104 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'TOTAL_AMOUNT_TANDEM'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_WITHDRAWAL_COUNT'
                                             , l.lang)
           , 'BGN_FIN_WITHDRAWAL_COUNT', substr (
                                            c.comments
                                          , 1
                                          , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_WITHDRAWAL_COUNT'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.withdrawal_count as column_number_value
        , to_date (null) as column_date_value
        , 105 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'WITHDRAWAL_COUNT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_RECEIPT_COUNT'
                                             , l.lang)
           , 'BGN_FIN_RECEIPT_COUNT', substr (c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_RECEIPT_COUNT'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.receipt_count as column_number_value
        , to_date (null) as column_date_value
        , 106 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'RECEIPT_COUNT'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_MESSAGE_TYPE'
                                             , l.lang)
           , 'BGN_FIN_MESSAGE_TYPE', substr (c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_MESSAGE_TYPE'
                                             , l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.message_type as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 107 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'MESSAGE_TYPE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_STAN', l.lang)
           , 'BGN_FIN_STAN', substr (c.comments
                                   , 1
                                   , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_STAN', l.lang))
             as name
        , 'VARCHAR2' as data_type
        , a.stan as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 108 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'STAN'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_INCIDENT_CAUSE'
                                             , l.lang)
           , 'BGN_FIN_INCIDENT_CAUSE', substr (
                                          c.comments
                                        , 1
                                        , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_INCIDENT_CAUSE'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.incident_cause as column_number_value
        , to_date (null) as column_date_value
        , 109 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'INCIDENT_CAUSE'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_HOST_INST_ID'
                                             , l.lang)
           , 'BGN_FIN_HOST_INST_ID', substr (c.comments
                                           , 1
                                           , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_HOST_INST_ID'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.host_inst_id as column_number_value
        , to_date (null) as column_date_value
        , 110 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'HOST_INST_ID'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_FILE_RECORD_NUMBER'
                                             , l.lang)
           , 'BGN_FIN_FILE_RECORD_NUMBER', substr (
                                              c.comments
                                            , 1
                                            , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_FILE_RECORD_NUMBER'
                                             , l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.file_record_number as column_number_value
        , to_date (null) as column_date_value
        , 111 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'FILE_RECORD_NUMBER'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_IS_INVALID', l.lang)
           , 'BGN_FIN_IS_INVALID', substr (c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_IS_INVALID', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.is_invalid as column_number_value
        , to_date (null) as column_date_value
        , 112 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'IS_INVALID'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FIN_OPER_ID', l.lang)
           , 'BGN_FIN_OPER_ID', substr (c.comments
                                      , 1
                                      , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FIN_OPER_ID', l.lang))
             as name
        , 'NUMBER' as data_type
        , to_char (null) as column_char_value
        , a.oper_id as column_number_value
        , to_date (null) as column_date_value
        , 113 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a, com_language_vw l, user_col_comments c
    where c.table_name = 'BGN_FIN'
          and c.column_name = 'OPER_ID'
   union all
   select decode (
             com_api_label_pkg.get_label_text ('BGN_FILE_FILE_TYPE', l.lang)
           , 'BGN_FILE_FILE_TYPE', substr (c.comments
                                         , 1
                                         , instr (c.comments || '.', '.'))
           , com_api_label_pkg.get_label_text ('BGN_FILE_FILE_TYPE', l.lang)
           ) as name
        , 'VARCHAR2' as data_type
        , decode(f.file_type
          , 'FLTPCLBE', 'EO'
          , 'FLTPCLBF', 'FO'
          , 'FLTPCLBS', 'SO'
          , 'FLTPCLBQ', decode(f.is_incoming, 1, 'QO', 0, 'SI')
          , f.file_type
          ) as column_char_value
        , to_number (null) as column_number_value
        , to_date (null) as column_date_value
        , 114 as column_order
        , l.lang
        , 1 as column_level
        , null as lov_id
        , null as dict_code
        , a.id as tech_id
        , a.oper_id as oper_id
     from bgn_fin a
        , bgn_file f
        , com_language_vw l
        , user_col_comments c
    where     c.table_name = 'BGN_FILE'
          and c.column_name = 'FILE_TYPE'
          and f.id = a.file_id
/

