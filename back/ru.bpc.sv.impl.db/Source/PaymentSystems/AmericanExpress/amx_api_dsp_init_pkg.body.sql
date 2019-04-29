create or replace package body amx_api_dsp_init_pkg as

function get_trans_amount (
    i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    , i_mandatory             in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value :=
    case when nvl(i_value_null, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
       com_api_const_pkg.DATA_NUMBER_NULL_INIT
    else
       'f.trans_amount'
    end;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''TRANS_AMOUNT''';
    l_where := l_where || ' and r.lang = l.lang';

    if nvl(i_value_null, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
        l_from := l_from || ', amx_fin_message f';
        l_where := l_where || ' and f.id = o.oper_id';
    end if;

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''AMX_FIN_MESSAGE''';
    l_where := l_where || ' and c.column_name = ''TRANS_AMOUNT''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''TRANS_AMOUNT''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.data_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_trans_currency (
    i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    , i_mandatory             in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_value                 in com_api_type_pkg.t_name := null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value :=
    case when nvl(i_value_null, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
       nvl(i_value, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT)
    else
       'f.trans_currency'
    end;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''TRANS_CURRENCY''';
    l_where := l_where || ' and r.lang = l.lang';

    if nvl(i_value_null, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
        l_from := l_from || ', amx_fin_message f';
        l_where := l_where || ' and f.id = o.oper_id';
    end if;

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''AMX_FIN_MESSAGE''';
    l_where := l_where || ' and c.column_name = ''TRANS_CURRENCY''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''TRANS_CURRENCY''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.data_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_reason_code (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
    , i_lov                   in com_api_type_pkg.t_name := null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''REASON_CODE''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''AMX_FIN_MESSAGE''';
    l_where := l_where || ' and c.column_name = ''REASON_CODE''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''REASON_CODE''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, nvl(i_lov, 'r.lov_id'));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.data_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_chbck_reason_text (
    i_mandatory               in com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE
    , i_editable              in com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
)return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''CHBCK_REASON_TEXT''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''AMX_FIN_MESSAGE''';
    l_where := l_where || ' and c.column_name = ''CHBCK_REASON_TEXT''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''CHBCK_REASON_TEXT''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.data_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_func_code (
    i_mandatory               in com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
    , i_lov                   in com_api_type_pkg.t_name := null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''FUNC_CODE''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''AMX_FIN_MESSAGE''';
    l_where := l_where || ' and c.column_name = ''FUNC_CODE''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''FUNC_CODE''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, nvl(i_lov, 'r.lov_id'));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.data_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_chargeback_reason_code (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    , i_editable              in com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
    , i_lov                   in com_api_type_pkg.t_name := null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''CHBCK_REASON_CODE''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''AMX_FIN_MESSAGE''';
    l_where := l_where || ' and c.column_name = ''CHBCK_REASON_CODE''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''CHBCK_REASON_CODE''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, nvl(i_lov, 'r.lov_id'));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.data_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_itemized_doc_code (
    i_mandatory               in com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
    , i_lov                   in com_api_type_pkg.t_name := null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''ITEMIZED_DOC_CODE''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''AMX_FIN_MESSAGE''';
    l_where := l_where || ' and c.column_name = ''ITEMIZED_DOC_CODE''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''ITEMIZED_DOC_CODE''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, nvl(i_lov, 'r.lov_id'));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.data_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_itemized_doc_ref_number (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    , i_editable              in com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''ITEMIZED_DOC_REF_NUMBER''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''AMX_FIN_MESSAGE''';
    l_where := l_where || ' and c.column_name = ''ITEMIZED_DOC_REF_NUMBER''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''ITEMIZED_DOC_REF_NUMBER''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.data_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

procedure init_second_presentment is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
    get_trans_amount(i_editable  => com_api_type_pkg.FALSE) || ' union all ' ||
    get_trans_currency(i_editable  => com_api_type_pkg.FALSE) || ' union all ' ||
    get_reason_code(i_mandatory  => com_api_type_pkg.TRUE, i_editable  => com_api_type_pkg.TRUE, i_lov  => '633') || ' union all ' ||
    get_itemized_doc_code(i_mandatory  => com_api_type_pkg.TRUE, i_editable  => com_api_type_pkg.TRUE, i_lov  => '637') || ' union all ' ||
    get_itemized_doc_ref_number(i_mandatory  => com_api_type_pkg.FALSE, i_editable  => com_api_type_pkg.TRUE);
    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );  
end;

procedure init_first_chargeback is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
    get_trans_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
    get_trans_currency(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
    get_reason_code(i_mandatory  => com_api_type_pkg.TRUE, i_editable  => com_api_type_pkg.TRUE, i_lov  => '634') || ' union all ' ||
    get_chbck_reason_text(i_mandatory  => com_api_type_pkg.TRUE, i_editable  => com_api_type_pkg.TRUE);
    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_final_chargeback is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
    get_trans_amount(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
    get_trans_currency(i_editable  => com_api_type_pkg.TRUE) || ' union all ' ||
    get_reason_code(i_mandatory  => com_api_type_pkg.TRUE, i_editable  => com_api_type_pkg.TRUE, i_lov  => '634') || ' union all ' ||
    get_chbck_reason_text(i_mandatory  => com_api_type_pkg.TRUE, i_editable  => com_api_type_pkg.TRUE);
    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;


procedure init_retrieval_request is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
    get_func_code(i_mandatory    => com_api_type_pkg.TRUE, i_editable  => com_api_type_pkg.TRUE, i_lov  => '638') || ' union all ' ||
    get_reason_code(i_mandatory  => com_api_type_pkg.TRUE, i_editable  => com_api_type_pkg.TRUE, i_lov  => '635') || ' union all ' ||
    get_chargeback_reason_code (i_mandatory  => com_api_type_pkg.FALSE, i_editable  => com_api_type_pkg.TRUE, i_lov  => '634') || ' union all ' ||
    get_itemized_doc_code(i_mandatory  => com_api_type_pkg.TRUE, i_editable  => com_api_type_pkg.TRUE, i_lov  => '637');
    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_fulfillment is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
    get_func_code(i_mandatory    => com_api_type_pkg.TRUE, i_editable  => com_api_type_pkg.TRUE, i_lov  => '638') || ' union all ' ||
    get_reason_code(i_mandatory  => com_api_type_pkg.TRUE, i_editable  => com_api_type_pkg.TRUE, i_lov  => '636') || ' union all ' ||
    get_itemized_doc_code(i_mandatory  => com_api_type_pkg.TRUE, i_editable  => com_api_type_pkg.TRUE, i_lov  => '637')|| ' union all ' ||
    get_itemized_doc_ref_number(i_mandatory  => com_api_type_pkg.TRUE, i_editable  => com_api_type_pkg.TRUE);
    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_first_pres_reversal is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_trans_amount(i_editable  => com_api_type_pkg.FALSE) || ' union all ' ||
    get_trans_currency(i_editable  => com_api_type_pkg.FALSE);

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;
    
end;
/
