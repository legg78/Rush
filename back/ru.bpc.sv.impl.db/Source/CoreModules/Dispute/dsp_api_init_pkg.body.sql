create or replace package body dsp_api_init_pkg is

    function get_oper_amount (
        i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_value :=
            case
                when nvl(i_value_null, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
                    com_api_const_pkg.DATA_NUMBER_NULL_INIT
                else
                    'f.oper_amount'
            end;
        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''OPER_AMOUNT''';
        l_where := l_where || ' and r.lang = l.lang';

        if nvl(i_value_null, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
            l_from := l_from || ', opr_operation f';
            l_where := l_where || ' and f.id = o.oper_id';
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''OPR_OPERATION''';
        l_where := l_where || ' and c.column_name = ''OPER_AMOUNT''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''OPER_AMOUNT''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

        return l_cursor_stmt;
    end;

    function get_oper_currency (
        i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_value                   com_api_type_pkg.t_name;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_value :=
            case
                when nvl(i_value_null, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
                    com_api_const_pkg.DATA_VARCHAR2_NULL_INIT
                else
                    'f.oper_currency'
            end;

        l_from  := l_from  || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''OPER_CURRENCY''';
        l_where := l_where || ' and r.lang = l.lang';

        if nvl(i_value_null, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', opr_operation f';
            l_where := l_where || ' and f.id = o.oper_id';
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''OPR_OPERATION''';
        l_where := l_where || ' and c.column_name = ''OPER_CURRENCY''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''OPER_CURRENCY''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

        return l_cursor_stmt;
    end;

    function get_oper_reason(
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
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

        if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
            l_from  := l_from  || ', opr_operation f';
            l_where := l_where || ' and f.id = o.oper_id';
        else        
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;

        l_from  := l_from  || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''OPR_OPERATION''';
        l_where := l_where || ' and c.column_name = ''OPER_REASON''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''OPER_REASON''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, nvl(i_lov, 'r.lov_id'));        
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

        return l_cursor_stmt;

    end get_oper_reason;

    function get_message_type (
        i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
      , i_lov                     in com_api_type_pkg.t_tiny_id default null
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
        l_where                   com_api_type_pkg.t_name;
        l_from                    com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_from := l_from || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''MSG_TYPE''';
        l_where := l_where || ' and r.lang = l.lang';
        
        l_from := l_from || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''OPR_OPERATION''';
        l_where := l_where || ' and c.column_name = ''MSG_TYPE''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''MSG_TYPE''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, com_api_type_pkg.TRUE));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, nvl(to_char(i_lov), 'r.lov_id'));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

        return l_cursor_stmt;
    end;

    function get_header_stmt return com_api_type_pkg.t_text is
    begin
        return 'with operation as ( select :oper_id oper_id, :lang lang from dual )';
    end;

    function default_statement return com_api_type_pkg.t_text is
    begin
        return
        ' select ' ||
            STMT_SYSTEM_NAME||' system_name' ||
            ', '|| STMT_FORM_NAME||' form_name' ||
            ', '|| STMT_VALUE_NUMBER||' value_number' ||
            ', '|| STMT_VALUE_CHAR||' value_char' ||
            ', '|| STMT_VALUE_DATE||' value_date' ||
            ', '|| STMT_MANDATORY||' mandatory' ||
            ', '|| STMT_EDITABLE||' editable' ||
            ', '|| STMT_LOV||' lov' ||
            ', '|| STMT_LANG||' lang' ||
            ', '|| STMT_FIELD_TYPE||' field_type' ||
            ', '|| STMT_DATA_LENGTH ||' data_length' ||
        ' from ' ||
              'operation o' ||
              ', com_language_vw l' ||
              STMT_FROM ||
        ' where ' ||
              'l.lang = o.lang' ||
              STMT_WHERE;
    end;

    function empty_statement return com_api_type_pkg.t_text is
        l_cursor_stmt             com_api_type_pkg.t_text;
    begin
        l_cursor_stmt := default_statement;

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, STMT_SYSTEM_NAME, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, STMT_FORM_NAME, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, STMT_VALUE_CHAR, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, STMT_MANDATORY, com_api_type_pkg.FALSE);
        l_cursor_stmt := replace(l_cursor_stmt, STMT_EDITABLE, com_api_type_pkg.FALSE);
        l_cursor_stmt := replace(l_cursor_stmt, STMT_LOV, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, STMT_LANG, 'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, STMT_FIELD_TYPE, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, STMT_DATA_LENGTH, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, STMT_FROM, '');
        l_cursor_stmt := replace(l_cursor_stmt, STMT_WHERE, ' and 1=0');

        return l_cursor_stmt;
    end;

    procedure init_internal_reversal is
        l_cursor_stmt           com_api_type_pkg.t_sql_statement;
    begin
        l_cursor_stmt := dsp_api_init_pkg.get_header_stmt
                      || get_oper_amount(i_editable  => com_api_type_pkg.TRUE)   || ' union all '
                      || get_oper_currency(i_editable  => com_api_type_pkg.FALSE);

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_write_off_positive is
        l_cursor_stmt           com_api_type_pkg.t_sql_statement;
    begin
        l_cursor_stmt := dsp_api_init_pkg.get_header_stmt
                      || get_oper_amount(i_editable  => com_api_type_pkg.TRUE)   || ' union all '
                      || get_oper_currency(i_editable  => com_api_type_pkg.TRUE);

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_write_off_negative is
        l_cursor_stmt           com_api_type_pkg.t_sql_statement;
    begin
        l_cursor_stmt := dsp_api_init_pkg.get_header_stmt
                      || get_oper_amount(i_editable  => com_api_type_pkg.FALSE)   || ' union all '
                      || get_oper_currency(i_editable  => com_api_type_pkg.FALSE);

        dsp_api_shared_data_pkg.set_cur_statement (
            i_cur_stat  => l_cursor_stmt
        );
    end;

    procedure init_common_refund is
        l_cursor_stmt           com_api_type_pkg.t_sql_statement;
    begin
        l_cursor_stmt := dsp_api_init_pkg.get_header_stmt
                      || get_oper_amount(
                             i_value_null => com_api_type_pkg.FALSE
                           , i_editable   => com_api_type_pkg.TRUE
                           , i_mandatory  => com_api_type_pkg.TRUE
                         )  
                      || ' union all '
                      || get_oper_reason(
                             i_editable   => com_api_type_pkg.TRUE
                           , i_mandatory  => com_api_type_pkg.TRUE
                           , i_lov        => '709'
                         );  
        dsp_api_shared_data_pkg.set_cur_statement(
            i_cur_stat  => l_cursor_stmt
        );

    end init_common_refund;

end;
/
