create or replace package body vis_api_dsp_init_pkg is

    /*
     *   Get transaction code by OPERATION_ID from cache
     */
    function get_fin_data
    return vis_api_type_pkg.t_visa_fin_mes_rec
    is
        l_fin_msg                 vis_api_type_pkg.t_visa_fin_mes_rec;
        l_id                      com_api_type_pkg.t_long_id;
    begin
        l_id := dsp_api_shared_data_pkg.get_param_num (
                    i_name => 'OPERATION_ID'
                );
        vis_api_fin_message_pkg.get_fin_mes(
            i_id      => l_id
          , o_fin_rec => l_fin_msg
        );
        return l_fin_msg;
    end;

    /*
     * Get card network id from participant (issuer) by operation id
     */
    function get_card_network_id(
        i_id      in            com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_short_id
    is
        l_part     opr_api_type_pkg.t_oper_part_rec;
    begin
        opr_api_operation_pkg.get_participant(
            i_oper_id           => i_id
          , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
          , o_participant       => l_part
        );

        return l_part.card_network_id;
    end;

    function get_inst_id (
        i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''INST_ID''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(i_value_null) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fin_message f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.inst_id';
        else
            l_value := com_api_const_pkg.DATA_NUMBER_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FIN_MESSAGE''';
        l_where := l_where || ' and c.column_name = ''INST_ID''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''INST_ID''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_network_id (
        i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''NETWORK_ID''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(i_value_null) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fin_message f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.network_id';
        else
            l_value := com_api_const_pkg.DATA_NUMBER_NULL_INIT;
        end if;

        l_from := l_from || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FIN_MESSAGE''';
        l_where := l_where || ' and c.column_name = ''NETWORK_ID''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''NETWORK_ID''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_event_date (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
        l_value_null              com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''EVENT_DATE''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(l_value_null) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fee f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.event_date';
        else
            l_value := com_api_const_pkg.DATA_DATE_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FEE''';
        l_where := l_where || ' and c.column_name = ''EVENT_DATE''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''EVENT_DATE''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     com_api_type_pkg.TRUE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_DATE||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_oper_amount (
        i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
        l_trans_code              com_api_type_pkg.t_byte_char;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''OPER_AMOUNT''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(i_value_null) = com_api_type_pkg.FALSE then
            l_trans_code  := get_fin_data().trans_code;
            l_from  := l_from  || ', vis_fin_message f';
            l_where := l_where || ' and f.id = o.oper_id';

            if l_trans_code in (vis_api_const_pkg.TC_SALES_CHARGEBACK
                              , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                              , vis_api_const_pkg.TC_CASH_CHARGEBACK
                              , vis_api_const_pkg.TC_FEE_COLLECTION
                              , vis_api_const_pkg.TC_FUNDS_DISBURSEMENT)
            then
                l_value := 'nvl(f.sttl_amount, f.oper_amount)';
            else
                l_value := 'f.oper_amount';
            end if;
        else
            l_value := com_api_const_pkg.DATA_NUMBER_NULL_INIT;
        end if;

        l_from  := l_from || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FIN_MESSAGE''';
        l_where := l_where || ' and c.column_name = ''OPER_AMOUNT''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''OPER_AMOUNT''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_oper_currency (
        i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_value                   in com_api_type_pkg.t_name := null
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
        l_trans_code              com_api_type_pkg.t_byte_char;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''OPER_CURRENCY''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(i_value_null) = com_api_type_pkg.FALSE then
            l_trans_code  := get_fin_data().trans_code;
            l_from  := l_from || ', vis_fin_message f';
            l_where := l_where || ' and f.id = o.oper_id';

            if l_trans_code in (vis_api_const_pkg.TC_SALES_CHARGEBACK
                              , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                              , vis_api_const_pkg.TC_CASH_CHARGEBACK
                              , vis_api_const_pkg.TC_FEE_COLLECTION
                              , vis_api_const_pkg.TC_FUNDS_DISBURSEMENT)
            then
                l_value := 'nvl(f.sttl_currency, f.oper_currency)';
            else
                l_value := 'f.oper_currency';
            end if;
        else
            l_value := nvl(i_value, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FIN_MESSAGE''';
        l_where := l_where || ' and c.column_name = ''OPER_CURRENCY''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''OPER_CURRENCY''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_card_number (
        i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''CARD_NUMBER''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(i_value_null) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_card f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'iss_api_token_pkg.decode_card_number(i_card_number => f.card_number)';
        else 
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_CARD''';
        l_where := l_where || ' and c.column_name = ''CARD_NUMBER''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''CARD_NUMBER''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_country_code (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''COUNTRY''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fee f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.country_code';
        else 
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FEE''';
        l_where := l_where || ' and c.column_name = ''COUNTRY_CODE''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''COUNTRY''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     com_api_type_pkg.TRUE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          '24');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_member_msg_text (
        i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''MEMBER_MESSAGE_TEXT''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(i_value_null) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fin_message f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.member_msg_text';
        else 
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FIN_MESSAGE''';
        l_where := l_where || ' and c.column_name = ''MEMBER_MSG_TEXT''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''MEMBER_MESSAGE_TEXT''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     com_api_type_pkg.TRUE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_reason_code (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_lov                     in com_api_type_pkg.t_name := null
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
        l_lov                     com_api_type_pkg.t_name;
        l_inst_id                 com_api_type_pkg.t_tiny_id;
        l_card_network_id         com_api_type_pkg.t_tiny_id;
        l_network_id              com_api_type_pkg.t_tiny_id;
        l_host_id                 com_api_type_pkg.t_tiny_id;
        l_standard_id             com_api_type_pkg.t_tiny_id;
        l_visa_dialect            com_api_type_pkg.t_dict_value;
        l_param_tab               com_api_type_pkg.t_param_tab;
        l_fin                     vis_api_type_pkg.t_visa_fin_mes_rec;
    begin
        l_lov := i_lov;
        
        l_fin := get_fin_data();

        --only for chargeback
        if l_fin.trans_code in (vis_api_const_pkg.TC_SALES_CHARGEBACK
                              , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                              , vis_api_const_pkg.TC_CASH_CHARGEBACK)
        then
            l_inst_id         := l_fin.inst_id;
            l_network_id      := l_fin.network_id;
            l_host_id         := net_api_network_pkg.get_default_host(
                                     i_network_id  => l_network_id
                                 );
            l_standard_id     := net_api_network_pkg.get_offline_standard (
                                     i_host_id       => l_host_id
                                 );
            cmn_api_standard_pkg.get_param_value (
                i_inst_id        => l_inst_id
                , i_standard_id  => l_standard_id
                , i_object_id    => l_host_id
                , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
                , i_param_name   => vis_api_const_pkg.VISA_BASEII_DIALECT
                , o_param_value  => l_visa_dialect
                , i_param_tab    => l_param_tab
            );
            if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_OPENWAY then
                l_card_network_id := get_card_network_id(
                    i_id => l_fin.id
                );
                if l_card_network_id = mcw_api_const_pkg.MCW_NETWORK_ID then
                    l_lov := '363';
                end if;
            end if;
        end if;

        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''OPER_REASON''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fin_message f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.reason_code';
        else 
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FIN_MESSAGE''';
        l_where := l_where || ' and c.column_name = ''REASON_CODE''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''REASON_CODE''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     com_api_type_pkg.TRUE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          nvl(l_lov, 'r.lov_id'));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_fee_reason_code (
        i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_lov                     in com_api_type_pkg.t_name := null
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''OPER_REASON''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(i_value_null) = com_api_type_pkg.FALSE then
            l_from := l_from || ', vis_fin_message m, vis_fee f';
            l_where := l_where || ' and m.id = o.oper_id and f.id(+) = m.id';
            l_value := 'f.reason_code';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FEE''';
        l_where := l_where || ' and c.column_name = ''REASON_CODE''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''REASON_CODE''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          nvl(i_lov, 'r.lov_id'));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_docum_ind (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''DOCUMENTATION_INDICATOR''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fin_message f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.docum_ind';
        else 
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FIN_MESSAGE''';
        l_where := l_where || ' and c.column_name = ''DOCUM_IND''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''DOCUMENTATION_INDICATOR''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_spec_chargeback_ind (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''SPECIAL_CHARGEBACK_INDICATOR''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fin_message f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.spec_chargeback_ind';
        else 
            l_value := com_api_const_pkg.DATA_NUMBER_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FIN_MESSAGE''';
        l_where := l_where || ' and c.column_name = ''SPEC_CHARGEBACK_IND''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''SPECIAL_CHARGEBACK_INDICATOR''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_usage_code (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''USAGE_CODE''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fin_message f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.usage_code';
        else 
            l_value := com_api_const_pkg.DATA_NUMBER_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FIN_MESSAGE''';
        l_where := l_where || ' and c.column_name = ''USAGE_CODE''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''USAGE_CODE''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_merchant_number (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''MERCHANT_NUMBER''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fin_message f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.merchant_number';
        else 
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FIN_MESSAGE''';
        l_where := l_where || ' and c.column_name = ''MERCHANT_NUMBER''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''MERCHANT_NUMBER''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_merchant_country (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''MERCHANT_COUNTRY''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fin_message f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.merchant_country';
        else 
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FIN_MESSAGE''';
        l_where := l_where || ' and c.column_name = ''MERCHANT_COUNTRY''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''MERCHANT_COUNTRY''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_merchant_city (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''MERCHANT_CITY''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fin_message f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.merchant_city';
        else 
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FIN_MESSAGE''';
        l_where := l_where || ' and c.column_name = ''MERCHANT_CITY''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''MERCHANT_CITY''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_notification_code return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''NOTIFICATION_CODE''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fraud f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.notification_code';
        else 
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FRAUD''';
        l_where := l_where || ' and c.column_name = ''NOTIFICATION_CODE''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''NOTIFICATION_CODE''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    com_api_type_pkg.TRUE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     com_api_type_pkg.TRUE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_iss_gen_auth return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''ISS_GEN_AUTH''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fraud f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.iss_gen_auth';
        else 
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FRAUD''';
        l_where := l_where || ' and c.column_name = ''ISS_GEN_AUTH''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''ISS_GEN_AUTH''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    com_api_type_pkg.FALSE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     com_api_type_pkg.TRUE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_card_expir_date (
        i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_value                   in com_api_type_pkg.t_name    default null
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_text;
        l_where                   com_api_type_pkg.t_text;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''EXPIR_DATE''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(i_value_null) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fin_message f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'case when f.card_expir_date is null then (select trunc(last_day(expir_date)) from iss_card_instance where id = p.card_instance_id) else last_day(to_date(f.card_expir_date,''yymm'')) end';
        else
            l_value := nvl(i_value, com_api_const_pkg.DATA_DATE_NULL_INIT);
        end if;

        l_from  := l_from  || ', opr_participant p';
        l_where := l_where || ' and p.oper_id = o.oper_id';
        l_where := l_where || ' and p.participant_type = ''PRTYISS''';

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FIN_MESSAGE''';
        l_where := l_where || ' and c.column_name = ''CARD_EXPIR_DATE''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''EXPIR_DATE''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_DATE||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_fraud_type return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_text;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name = ''FRAUD_TYPE''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fraud f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.fraud_type';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FRAUD''';
        l_where := l_where || ' and c.column_name = ''FRAUD_TYPE''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''FRAUD_TYPE''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    com_api_type_pkg.TRUE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     com_api_type_pkg.TRUE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_fraud_source_bin (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_text;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name = ''SOURCE_BIN''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fraud f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.source_bin';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FRAUD''';
        l_where := l_where || ' and c.column_name = ''SOURCE_BIN''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''SOURCE_BIN''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_source_bin (
        i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_is_reversal             in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name = ''SOURCE_BIN''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(i_value_null) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fin_message m, vis_fee f';
            l_where := l_where || ' and m.id = o.oper_id and f.id(+) = m.id';

            if i_is_reversal = com_api_type_pkg.FALSE then
               l_value := 'f.src_bin';
            else
               l_value := 'f.dst_bin';
            end if;
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FRAUD''';
        l_where := l_where || ' and c.column_name = ''SOURCE_BIN''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''SOURCE_BIN''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_destin_bin (
        i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_is_reversal             in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name = ''DESTIN_BIN''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(i_value_null) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fin_message m, vis_fee f';
            l_where := l_where || ' and m.id = o.oper_id and f.id(+) = m.id';

            if i_is_reversal = com_api_type_pkg.FALSE then
               l_value := 'f.dst_bin';
            else
               l_value := 'f.src_bin';
            end if;
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FEE''';
        l_where := l_where || ' and c.column_name = ''DST_BIN''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''DESTIN_BIN''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_account_seq_number (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''TEXT''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fraud f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.account_seq_number';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FRAUD''';
        l_where := l_where || ' and c.column_name = ''ACCOUNT_SEQ_NUMBER''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''ACCOUNT_SEQ_NUMBER''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    '''Account sequence number''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_fraud_inv_status return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''TEXT''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fraud f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.fraud_inv_status';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FRAUD''';
        l_where := l_where || ' and c.column_name = ''FRAUD_INV_STATUS''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''FRAUD_INV_STATUS''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    '''Fraud investigative status''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    com_api_type_pkg.FALSE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     com_api_type_pkg.TRUE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_excluded_trans_id_reason return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''EXCLUDED_TRANS_ID_REASON''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_fraud f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.excluded_trans_id_reason';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FRAUD''';
        l_where := l_where || ' and c.column_name = ''EXCLUDED_TRANS_ID_REASON''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''EXCLUDED_TRANS_ID_REASON''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    com_api_type_pkg.FALSE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     com_api_type_pkg.TRUE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_establ_fulfillment_method (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''ESTABLISHED_FULFILLMENT_METHOD''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_retrieval f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.used_fulfill_method';
        else
            l_value := com_api_const_pkg.DATA_NUMBER_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_RETRIEVAL''';
        l_where := l_where || ' and c.column_name = ''USED_FULFILL_METHOD''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''ESTABLISHED_FULFILLMENT_METHOD''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_request_fulfillment_method (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''REQUESTED_FULFILLMENT_METHOD''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_retrieval f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.req_fulfill_method';
        else
            l_value := com_api_const_pkg.DATA_NUMBER_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_RETRIEVAL''';
        l_where := l_where || ' and c.column_name = ''REQ_FULFILL_METHOD''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''REQUESTED_FULFILLMENT_METHOD''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_issuer_rfc_bin (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_value                   in com_api_type_pkg.t_name default null
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''ISSUER_RFC_BIN''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_retrieval f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.iss_rfc_bin';
        else
            l_value := nvl(''''||i_value||'''', com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_RETRIEVAL''';
        l_where := l_where || ' and c.column_name = ''ISS_RFC_BIN''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''ISSUER_RFC_BIN''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     i_editable);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_issuer_rfc_subaddress (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_value                   in com_api_type_pkg.t_name default null
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''ISSUER_RFC_SUBADDRESS''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_retrieval f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.iss_rfc_subaddr';
        else
            l_value := nvl(''''||i_value||'''', com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_RETRIEVAL''';
        l_where := l_where || ' and c.column_name = ''ISS_RFC_SUBADDR''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''ISSUER_RFC_SUBADDRESS''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     i_editable);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_fax_number (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''FAX_NUMBER''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_retrieval f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.fax_number';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_RETRIEVAL''';
        l_where := l_where || ' and c.column_name = ''FAX_NUMBER''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''FAX_NUMBER''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     i_editable);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_contact_for_information (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''CONTACT_FOR_INFORMATION''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_retrieval f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.contact_info';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_RETRIEVAL''';
        l_where := l_where || ' and c.column_name = ''CONTACT_INFO''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''CONTACT_FOR_INFORMATION''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     i_editable);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_vcr_reason_code (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_lov                     in com_api_type_pkg.t_name    default null
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
        l_lov                     com_api_type_pkg.t_name;
    begin
        l_lov := i_lov;

        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''MESSAGE_REASON''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_tcr4 f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.message_reason_code';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_TCR4''';
        l_where := l_where || ' and c.column_name = ''MESSAGE_REASON_CODE''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''MESSAGE_REASON''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     com_api_type_pkg.TRUE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          nvl(l_lov, 'r.lov_id'));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_vcr_dispute_condition (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''DISPUTE_CONDITION''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_tcr4 f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.dispute_condition';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_TCR4''';
        l_where := l_where || ' and c.column_name = ''DISPUTE_CONDITION''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''DISPUTE_CONDITION''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     i_editable);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_vcr_vrol_financial_id (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''VROL_FINANCIAL_ID''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_tcr4 f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.vrol_financial_id';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_TCR4''';
        l_where := l_where || ' and c.column_name = ''VROL_FINANCIAL_ID''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''VROL_FINANCIAL_ID''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     i_editable);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_vcr_vrol_case_number (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''VROL_CASE_NUMBER''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_tcr4 f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.vrol_case_number';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_TCR4''';
        l_where := l_where || ' and c.column_name = ''VROL_CASE_NUMBER''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''VROL_CASE_NUMBER''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     i_editable);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_vcr_vrol_bundle_number (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''VROL_BUNDLE_NUMBER''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_tcr4 f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.vrol_bundle_number';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_TCR4''';
        l_where := l_where || ' and c.column_name = ''VROL_BUNDLE_NUMBER''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''VROL_BUNDLE_NUMBER''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     i_editable);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_vcr_client_case_number (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''CLIENT_CASE_NUMBER''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_tcr4 f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.client_case_number';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_TCR4''';
        l_where := l_where || ' and c.column_name = ''CLIENT_CASE_NUMBER''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''CLIENT_CASE_NUMBER''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     i_editable);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;
    
    function get_transaction_code (
        i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_value := dsp_api_shared_data_pkg.get_param_char(i_name => 'TRANSACTION_CODE');

        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''TRANSACTION_CODE''';
        l_where := l_where || ' and r.lang = l.lang';

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_FIN_MESSAGE''';
        l_where := l_where || ' and c.column_name = ''TRANS_CODE''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''TRANS_CODE''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   'cast('''||l_value||''' as varchar2(4000))');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    function get_vcr_dispute_status (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_lov                     in com_api_type_pkg.t_name    default null
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
        l_lov                     com_api_type_pkg.t_name;
    begin
        l_lov := i_lov;

        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''DISPUTE_STATUS''';
        l_where := l_where || ' and r.lang = l.lang';

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', vis_tcr4 f';
            l_where := l_where || ' and f.id = o.oper_id';
            l_value := 'f.dispute_status';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''VIS_TCR4''';
        l_where := l_where || ' and c.column_name = ''DISPUTE_STATUS''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''DISPUTE_STATUS''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     com_api_type_pkg.TRUE);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          nvl(l_lov, 'r.lov_id'));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

        return l_cursor_stmt;
    end;

    procedure init_first_chargeback is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
        l_trans_code            com_api_type_pkg.t_byte_char;
    begin
        l_trans_code := get_fin_data().trans_code;

        --only for chargeback
        if l_trans_code = vis_api_const_pkg.TC_SALES then
            dsp_api_shared_data_pkg.set_param (
                i_name     => 'TRANSACTION_CODE'
                , i_value  => vis_api_const_pkg.TC_SALES_CHARGEBACK
            );
        elsif l_trans_code = vis_api_const_pkg.TC_VOUCHER then
            dsp_api_shared_data_pkg.set_param (
                i_name     => 'TRANSACTION_CODE'
                , i_value  => vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
            );
        elsif l_trans_code = vis_api_const_pkg.TC_CASH then
            dsp_api_shared_data_pkg.set_param (
                i_name     => 'TRANSACTION_CODE'
                , i_value  => vis_api_const_pkg.TC_CASH_CHARGEBACK
            );
        end if;
        l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_member_msg_text || ' union all ' ||
        get_docum_ind || ' union all ' ||
        get_usage_code(i_mandatory  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_spec_chargeback_ind || ' union all ' ||
        get_reason_code(i_mandatory  => com_api_type_pkg.TRUE, i_lov  => '428');

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_second_chargeback is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
    begin
        l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_member_msg_text || ' union all ' ||
        get_docum_ind || ' union all ' ||
        get_usage_code(i_mandatory  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_spec_chargeback_ind || ' union all ' ||
        get_reason_code(i_mandatory  => com_api_type_pkg.TRUE, i_lov  => '428');

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_first_pres_reversal is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
    begin
        l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.FALSE) || ' union all ' ||
        get_member_msg_text;

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_second_pres_reversal is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
    begin
        l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.FALSE) || ' union all ' ||
        get_member_msg_text;

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_second_presentment is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
    begin
        l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_member_msg_text(i_mandatory  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_docum_ind(i_mandatory  => com_api_type_pkg.TRUE);

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    -- Presentment Chargeback Reversal
    -- Second Presentment Chargeback Reversal
    procedure init_pres_chargeback_reversal is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
    begin
        l_cursor_stmt := dsp_api_init_pkg.get_header_stmt || dsp_api_init_pkg.empty_statement;

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_retrieval_request is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
    begin
        l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_reason_code(i_mandatory => com_api_type_pkg.TRUE, i_lov  => '99') || ' union all ' ||
        get_issuer_rfc_bin(i_value => '000000', i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_issuer_rfc_subaddress(i_value => '0000000', i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_request_fulfillment_method || ' union all ' ||
        get_establ_fulfillment_method || ' union all ' ||
        get_fax_number || ' union all ' ||
        get_contact_for_information
        ;

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_fee_collection is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
        l_oper_id               com_api_type_pkg.t_long_id;
        l_value_null            com_api_type_pkg.t_boolean;
    begin
        dsp_api_shared_data_pkg.set_param (
            i_name     => 'TRANSACTION_CODE'
            , i_value  => vis_api_const_pkg.TC_FEE_COLLECTION
        );

        l_oper_id := dsp_api_shared_data_pkg.get_param_num (i_name => 'OPERATION_ID');

        l_value_null := com_api_type_pkg.to_bool(l_oper_id is null);

        l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
        get_transaction_code(i_mandatory  => com_api_type_pkg.TRUE, i_editable => com_api_type_pkg.FALSE) || ' union all ' ||
        get_inst_id(i_value_null => l_value_null, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_network_id(i_value_null => l_value_null, i_mandatory => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_destin_bin(i_value_null => l_value_null, i_mandatory => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_source_bin(i_value_null => l_value_null, i_mandatory => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_event_date || ' union all ' ||
        get_country_code(i_mandatory  => com_api_type_pkg.FALSE) || ' union all ' ||
        get_card_number(i_value_null  => l_value_null, i_mandatory  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_fee_reason_code(i_value_null => l_value_null, i_mandatory => com_api_type_pkg.TRUE, i_lov  => '47') || ' union all ' ||
        get_oper_amount(i_value_null => l_value_null, i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_value_null => l_value_null, i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_member_msg_text(i_value_null => l_value_null)
        ;

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_funds_disbursement is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
        l_oper_id               com_api_type_pkg.t_long_id;
    begin
        dsp_api_shared_data_pkg.set_param (
            i_name     => 'TRANSACTION_CODE'
            , i_value  => vis_api_const_pkg.TC_FUNDS_DISBURSEMENT
        );

        l_oper_id := dsp_api_shared_data_pkg.get_param_num (
                         i_name => 'OPERATION_ID'
                     );

        l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
        case when l_oper_id is null then
            get_inst_id(i_value_null => com_api_type_pkg.TRUE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
            get_network_id(i_value_null => com_api_type_pkg.TRUE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all '
        end ||
        get_inst_id(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.FALSE) || ' union all ' ||
        get_network_id(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.FALSE) || ' union all ' ||
        get_destin_bin(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_source_bin(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_event_date || ' union all ' ||
        get_country_code(i_mandatory  => com_api_type_pkg.FALSE) || ' union all ' ||
        get_card_number(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_fee_reason_code(i_value_null  => com_api_type_pkg.FALSE, i_mandatory => com_api_type_pkg.TRUE, i_lov  => '47') || ' union all ' ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_member_msg_text
        ;

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_fraud_reporting is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
    begin
        l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
        get_fraud_source_bin           || ' union all ' ||
        get_oper_amount(i_editable  => com_api_type_pkg.FALSE)   || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.FALSE) || ' union all ' ||
        get_notification_code    || ' union all ' ||
        get_iss_gen_auth         || ' union all ' ||
        get_account_seq_number   || ' union all ' ||
        get_card_expir_date      || ' union all ' ||
        get_fraud_type           || ' union all ' ||
        get_fraud_inv_status     || ' union all ' ||
        get_excluded_trans_id_reason;

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );

        --dbms_output.put_line(l_cursor_stmt);
    end;

    procedure init_vcr_disp_resp_financial is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
    begin
        -- Init second presentment (Init dispute response financial)
        l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_member_msg_text(i_mandatory  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_spec_chargeback_ind || ' union all ' ||
        get_vcr_dispute_status(i_mandatory  => com_api_type_pkg.TRUE);

        dsp_api_shared_data_pkg.set_cur_statement(
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_vcr_disp_financial is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
    begin
        -- Init chargeback (Init dispute financial)
        l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_member_msg_text || ' union all ' ||
        get_spec_chargeback_ind || ' union all ' ||
        get_vcr_reason_code(i_mandatory  => com_api_type_pkg.TRUE, i_lov  => '551') || ' union all ' ||
        get_vcr_dispute_condition || ' union all ' ||
        get_vcr_vrol_financial_id || ' union all ' ||
        get_vcr_vrol_case_number || ' union all ' ||
        get_vcr_vrol_bundle_number || ' union all ' ||
        get_vcr_client_case_number(i_mandatory => com_api_type_pkg.TRUE);

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_vcr_disp_resp_fin_revers is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
    begin
        -- Init second presentment reversal (Init dispute response financial)
        l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
        get_member_msg_text;

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_vcr_disp_fin_reversal is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
    begin
        -- Init chargeback reversal (Init dispute financial reversal)
        l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
        get_member_msg_text;

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_sms_first_pres_reversal is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
    begin
        l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.FALSE) || ' union all ' ||
        get_member_msg_text;

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_sms_second_pres_reversal is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
    begin
        l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.FALSE) || ' union all ' ||
        get_member_msg_text;

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );

    end;
    
    procedure init_sms_second_presentment is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
    begin
        l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_member_msg_text(i_mandatory  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_docum_ind(i_mandatory  => com_api_type_pkg.TRUE);

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;
    
    procedure init_sms_fee_collection is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
        l_oper_id               com_api_type_pkg.t_long_id;
    begin
        dsp_api_shared_data_pkg.set_param (
            i_name   => 'TRANSACTION_CODE'
          , i_value  => vis_api_const_pkg.TC_FEE_COLLECTION
        );

        l_oper_id := dsp_api_shared_data_pkg.get_param_num (
            i_name => 'OPERATION_ID'
        );

        l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
        case when l_oper_id is null then
            get_inst_id(i_value_null => com_api_type_pkg.TRUE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
            get_network_id(i_value_null => com_api_type_pkg.TRUE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all '
        end ||
        get_inst_id(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_network_id(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_destin_bin(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_source_bin(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_event_date || ' union all ' ||
        get_country_code(i_mandatory  => com_api_type_pkg.FALSE) || ' union all ' ||
        get_card_number(i_value_null  => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_fee_reason_code(i_value_null  => com_api_type_pkg.FALSE, i_mandatory => com_api_type_pkg.TRUE, i_lov  => '47') || ' union all ' ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_member_msg_text
        ;

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;
    
    procedure init_sms_funds_disbursement is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
        l_oper_id               com_api_type_pkg.t_long_id;
    begin
        dsp_api_shared_data_pkg.set_param (
            i_name   => 'TRANSACTION_CODE'
          , i_value  => vis_api_const_pkg.TC_FUNDS_DISBURSEMENT
        );

        l_oper_id := dsp_api_shared_data_pkg.get_param_num (
                         i_name => 'OPERATION_ID'
                     );

        l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
        case when l_oper_id is null then
            get_inst_id(i_value_null => com_api_type_pkg.TRUE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
            get_network_id(i_value_null => com_api_type_pkg.TRUE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all '
        end ||
        get_inst_id(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.FALSE) || ' union all ' ||
        get_network_id(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.FALSE) || ' union all ' ||
        get_destin_bin(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_source_bin(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_event_date || ' union all ' ||
        get_country_code(i_mandatory  => com_api_type_pkg.FALSE) || ' union all ' ||
        get_card_number(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.FALSE) || ' union all ' ||
        get_fee_reason_code(i_value_null  => com_api_type_pkg.FALSE, i_mandatory => com_api_type_pkg.TRUE, i_lov  => '47') || ' union all ' ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_member_msg_text
        ;

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_sms_debit_adjustment is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
        l_oper_id               com_api_type_pkg.t_long_id;
    begin
        dsp_api_shared_data_pkg.set_param (
            i_name     => 'TRANSACTION_CODE'
            , i_value  => vis_api_const_pkg.TC_FEE_COLLECTION
        );

        l_oper_id := dsp_api_shared_data_pkg.get_param_num (
                         i_name => 'OPERATION_ID'
                     );

        l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
        case when l_oper_id is null then
            get_inst_id(i_value_null => com_api_type_pkg.TRUE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
            get_network_id(i_value_null => com_api_type_pkg.TRUE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all '
        end ||
        get_inst_id(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_network_id(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_destin_bin(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_source_bin(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_event_date || ' union all ' ||
        get_country_code(i_mandatory  => com_api_type_pkg.FALSE) || ' union all ' ||
        get_card_number(i_value_null  => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_fee_reason_code(i_value_null  => com_api_type_pkg.FALSE, i_mandatory => com_api_type_pkg.TRUE, i_lov  => '588') || ' union all ' ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_member_msg_text
        ;

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;


    procedure init_sms_credit_adjustment is
        l_cursor_stmt           com_api_type_pkg.t_lob_data;
        l_oper_id               com_api_type_pkg.t_long_id;
    begin
        dsp_api_shared_data_pkg.set_param (
            i_name     => 'TRANSACTION_CODE'
            , i_value  => vis_api_const_pkg.TC_FUNDS_DISBURSEMENT
        );

        l_oper_id := dsp_api_shared_data_pkg.get_param_num (
                         i_name => 'OPERATION_ID'
                     );

        l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
        case when l_oper_id is null then
            get_inst_id(i_value_null => com_api_type_pkg.TRUE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
            get_network_id(i_value_null => com_api_type_pkg.TRUE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all '
        end ||
        get_inst_id(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.FALSE) || ' union all ' ||
        get_network_id(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.FALSE) || ' union all ' ||
        get_destin_bin(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_source_bin(i_value_null => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE) || ' union all ' ||
        get_event_date || ' union all ' ||
        get_country_code(i_mandatory  => com_api_type_pkg.FALSE) || ' union all ' ||
        get_card_number(i_value_null  => com_api_type_pkg.FALSE, i_mandatory  => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.FALSE) || ' union all ' ||
        get_fee_reason_code(i_value_null  => com_api_type_pkg.FALSE, i_mandatory => com_api_type_pkg.TRUE, i_lov  => '588') || ' union all ' ||
        get_oper_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_oper_currency(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
        get_member_msg_text
        ;

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

end vis_api_dsp_init_pkg;
/
