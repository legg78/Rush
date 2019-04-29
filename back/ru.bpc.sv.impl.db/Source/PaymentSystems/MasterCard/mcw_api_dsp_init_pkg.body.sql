create or replace package body mcw_api_dsp_init_pkg is
/************************************************************
 * API for dispute init <br />
 * Created by Maslov I.(maslov@bpcbt.com) at 01.06.2013 <br />
 * Module: mcw_api_dsp_init_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Get transaction code by OPERATION_ID from cache
 */
function get_fin_data
return mcw_api_type_pkg.t_fin_rec
is
    l_fin_msg                 mcw_api_type_pkg.t_fin_rec;
    l_id                      com_api_type_pkg.t_long_id;
begin
    l_id := dsp_api_shared_data_pkg.get_param_num (
                i_name => 'OPERATION_ID'
            );
    mcw_api_fin_pkg.get_fin(
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

function get_c01 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''C_01''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fraud f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'f.c01';
    else
        l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''STATUS''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''C_01''');
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

function get_c02 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_lov                     in com_api_type_pkg.t_name    default null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''C_02''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fraud f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'f.c02';
    else
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'to_number(lpad(nvl(f.de100, f.de093),11,''0''))';
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FRAUD''';
    l_where := l_where || ' and c.column_name = ''C02''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''C_02''');
    --l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,  'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    '''Issuer Customer Number''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          nvl(i_lov, 'r.lov_id'));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.data_type_number||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

    return l_cursor_stmt;
end;

function get_c04 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_lov                     in com_api_type_pkg.t_name    default null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''C_04''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fraud f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'f.c04';
    else
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'to_char(lpad(nvl(f.de033, f.de094),11,''0''))';
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''DE093''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''C_04''');
    --l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,  'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    '''Acquirer Customer Number''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          nvl(i_lov, 'r.lov_id'));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.data_type_char||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

    return l_cursor_stmt;
end;

function get_c14 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''AMOUNT''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fraud f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'f.c14';
    else
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'f.de004' ;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''DE004''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''C_14''');
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

function get_c15 (
    i_mandatory             in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''CURRENCY''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fraud f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'f.c15';
    else
        l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''DE049''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''C_15''');
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

function get_c28 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''C_28''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fraud f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'f.c28';
    else
        l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''STATUS''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''C_28''');
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

function get_c29 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''C_29''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fraud f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'f.c29';
    else
        l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''STATUS''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''C_29''');
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

function get_c30 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''C_30''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fraud f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'f.c30';
    else
        l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''STATUS''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''C_30''');
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

function get_c31 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''C_31''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fraud f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'f.c31';
    else
        l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''STATUS''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''C_31''');
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

function get_c44 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''C_44''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fraud f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'f.c44';
    else
        l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''STATUS''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''C_44''');
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

function get_de2 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
    l_mti                     com_api_type_pkg.t_mcc;
    l_de024                   mcw_api_type_pkg.t_de024;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_mti := dsp_api_shared_data_pkg.get_param_char (
                     i_name => 'MESSAGE_TYPE'
                 );

    l_de024 := dsp_api_shared_data_pkg.get_param_char (
                     i_name => 'DE_024'
                 );

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''CARD_NUMBER''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id(+) = o.oper_id';
        l_value := '(select iss_api_token_pkg.decode_card_number(i_card_number => fc.card_number) from mcw_card fc where fc.id = f.id)';
    else
        if l_mti = mcw_api_const_pkg.MSG_TYPE_FEE and l_de024 = mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE then
            l_from  := l_from  || ', mcw_fin f';
            l_where := l_where || ' and f.id(+) = o.oper_id';
            l_value := '(select iss_api_token_pkg.decode_card_number(i_card_number => fc.card_number) from mcw_card fc where fc.id = f.id)';
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''DE002''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''DE_002''');
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

function get_de3_1 (
    i_mandatory               in com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
  , i_lov                     in com_api_type_pkg.t_name := null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''FEE_PROCESSING_CODE''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id(+) = o.oper_id';
        l_value := 'f.de003_1';
    else
        l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''DE003_1''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''DE_003_1''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          nvl(i_lov, 'r.lov_id'));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

    return l_cursor_stmt;
end;

function get_de4 (
    i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
    l_mti                     com_api_type_pkg.t_mcc;
begin
    l_mti := dsp_api_shared_data_pkg.get_param_char(
                 i_name => 'MESSAGE_TYPE'
             );

    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''AMOUNT''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(i_value_null) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id = o.oper_id';

        if l_mti = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK then
            l_value := 'nvl(f.de005, f.de004)';
        else
            l_value := 'f.de004';
        end if;
    else
        l_value := com_api_const_pkg.DATA_NUMBER_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''DE004''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''DE_004''');
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

function get_de25 (
    i_mandatory  in     com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
  , i_editable   in     com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
  , i_lov        in     com_api_type_pkg.t_name := null
  , i_value      in     com_api_type_pkg.t_name := null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''REASON_CODE''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'f.de025';
    else
        l_value := nvl('''' || i_value ||'''', com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''DE025''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''DE_025''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          nvl(i_lov, 'r.lov_id'));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

    return l_cursor_stmt;
end;

function get_de30_1 (
    i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
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
    l_where := l_where || ' and r.name =''AMOUNT''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(i_value_null) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'f.de030_1';
    else
        l_value := com_api_const_pkg.DATA_NUMBER_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''DE030_1''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''DE_030_1''');
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

function get_de49 (
    i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_value                   in com_api_type_pkg.t_name := null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
    l_mti                     com_api_type_pkg.t_mcc;
begin
    l_mti := dsp_api_shared_data_pkg.get_param_char (
                 i_name => 'MESSAGE_TYPE'
             );

    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''CURRENCY''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(i_value_null) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id = o.oper_id';

        if l_mti = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK then
            l_value := 'nvl(f.de050, f.de049)';
        else
            l_value := 'f.de049';
        end if;
    else
        l_value := nvl(i_value, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''DE049''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''DE_049''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.FALSE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

    return l_cursor_stmt;
end;

function get_de72(
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.false
  , i_lov_id                  in com_api_type_pkg.t_tiny_id default null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''DE_072''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'f.de072';
    else
        l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''DE072''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  'r.name');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     com_api_type_pkg.TRUE);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          coalesce(to_char(i_lov_id, com_api_const_pkg.NUMBER_INT_FORMAT_DEFAULT), 'r.lov_id'));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

    return l_cursor_stmt;
end;

function get_de73 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.false
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''DE_073''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'f.de073';
    else
        l_value := com_api_const_pkg.DATA_DATE_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''DE073''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  'r.name');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.FALSE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     com_api_type_pkg.TRUE);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_DATE||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

    return l_cursor_stmt;
end;

function get_de93 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_lov                     in com_api_type_pkg.t_name    default null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
    l_mti                     com_api_type_pkg.t_mcc;
    l_de024                   mcw_api_type_pkg.t_de024;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_mti := dsp_api_shared_data_pkg.get_param_char(
                 i_name => 'MESSAGE_TYPE'
             );

    l_de024 := dsp_api_shared_data_pkg.get_param_char(
                   i_name => 'DE_024'
               );

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''DE_093''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id(+) = o.oper_id';
        l_value := 'lpad(decode(f.is_incoming, 0, f.de093, f.de094),11,''0'')';  -- swap for incoming message to Trasaction Destination ID Code
    else
        if l_mti = mcw_api_const_pkg.MSG_TYPE_FEE and l_de024 = mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE then
            l_from  := l_from  || ', mcw_fin f';
            l_where := l_where || ' and f.id(+) = o.oper_id';
            l_value := 'lpad(decode(f.is_incoming, 0, f.de093, f.de094),11,''0'')';  -- swap for incoming message to Trasaction Destination ID Code
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''DE093''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  'r.name');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          nvl(i_lov, 'r.lov_id'));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

    return l_cursor_stmt;
end;

function get_de94 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_lov                     in com_api_type_pkg.t_name    default null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
    l_mti                     com_api_type_pkg.t_mcc;
    l_de024                   mcw_api_type_pkg.t_de024;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_mti := dsp_api_shared_data_pkg.get_param_char(
                 i_name => 'MESSAGE_TYPE'
             );

    l_de024 := dsp_api_shared_data_pkg.get_param_char (
                   i_name => 'DE_024'
               );

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''DE_094''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id(+) = o.oper_id';
        l_value := 'decode(f.is_incoming, 0, f.de094, f.de093)';  -- swap for incoming message to Trasaction Destination ID Code
    else
        if l_mti = mcw_api_const_pkg.MSG_TYPE_FEE and l_de024 = mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE then
            l_from  := l_from  || ', mcw_fin f';
            l_where := l_where || ' and f.id(+) = o.oper_id';
            l_value := 'decode(f.is_incoming, 0, f.de094, f.de093)';  -- swap for incoming message to Trasaction Destination ID Code
        else
            l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
        end if;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''DE094''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  'r.name');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          nvl(i_lov, 'r.lov_id'));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

    return l_cursor_stmt;
end;

function get_network (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
    l_mti                     com_api_type_pkg.t_mcc;
    l_de024                   mcw_api_type_pkg.t_de024;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_mti := dsp_api_shared_data_pkg.get_param_char (
                 i_name => 'MESSAGE_TYPE'
             );

    l_de024 := dsp_api_shared_data_pkg.get_param_char (
                   i_name => 'DE_024'
               );

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''NETWORK_ID''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id(+) = o.oper_id';
        l_value := 'f.network_id';
    else
        if l_mti = mcw_api_const_pkg.MSG_TYPE_FEE and l_de024 = mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE then
            l_from  := l_from  || ', mcw_fin f';
            l_where := l_where || ' and f.id(+) = o.oper_id';
            l_value := 'f.network_id';
        else
            l_value :=  com_api_const_pkg.DATA_NUMBER_NULL_INIT;
        end if;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''NETWORK_ID''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  'r.name');
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

function get_p149_1 return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''CURRENCY''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id(+) = o.oper_id';
        l_value := 'f.p0149_1';
    else
        l_value :=  com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''P0149_1''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''PDS_0149_1''');
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

function get_p149_2 return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''CURRENCY''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id(+) = o.oper_id';
        l_value := 'f.p0149_2';
    else
        l_value :=  com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''P0149_2''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''PDS_0149_1''');
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

function get_p228 return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''PDS_0228''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id(+) = o.oper_id';
        l_value := 'f.p0228';
    else
        l_value :=  com_api_const_pkg.DATA_NUMBER_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''P0228''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  'r.name');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    com_api_type_pkg.TRUE);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     com_api_type_pkg.TRUE);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

    return l_cursor_stmt;
end;

function get_p262 return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_NUMBER_NULL_INIT;
    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''PDS_0262''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id(+) = o.oper_id';
        l_value := 'f.p0262';
    else
        l_value :=  com_api_const_pkg.DATA_NUMBER_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''P0262''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''PDS_0262''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    com_api_type_pkg.TRUE);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     com_api_type_pkg.TRUE);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

    return l_cursor_stmt;
end;

function get_oper_currency (
    i_mandatory        in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable         in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt      com_api_type_pkg.t_text;
    l_value            com_api_type_pkg.t_name;
    l_where            com_api_type_pkg.t_name;
    l_from             com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''OPER_CURRENCY''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', mcw_fin f';
    l_where := l_where || ' and f.id = o.oper_id';
    l_value := 'f.de049';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''DE049''';

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

function get_inst_id(
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
    l_where := l_where || ' and r.name =''INST_ID''';
    l_where := l_where || ' and r.lang = l.lang';

    if dsp_ui_process_pkg.is_null_value(i_value_null) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', mcw_fin f';
        l_where := l_where || ' and f.id(+) = o.oper_id';
        l_value := 'f.inst_id';
    else
        l_value :=  com_api_const_pkg.DATA_NUMBER_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
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


function get_mti (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
    l_value                   com_api_type_pkg.t_name;
begin
    l_value := dsp_api_shared_data_pkg.get_param_char(i_name => 'MESSAGE_TYPE');

    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''MESSAGE_TYPE''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''MTI''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''MTI''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   'cast('''||l_value||''' as varchar2(4000))');
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

function get_de24 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
    l_value                   com_api_type_pkg.t_name;
begin
    l_value := dsp_api_shared_data_pkg.get_param_char(i_name => 'DE_024');

    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''FUNC_CODE''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MCW_FIN''';
    l_where := l_where || ' and c.column_name = ''DE024''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''DE_024''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   'cast('''||l_value||''' as varchar2(4000))');
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

procedure init_first_pres_reversal is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
    l_mti                   com_api_type_pkg.t_mcc;
begin
    l_mti := get_fin_data().mti;
    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => l_mti
    );
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de4 (
        i_value_null   => com_api_type_pkg.TRUE
        , i_editable   => com_api_type_pkg.TRUE
        , i_mandatory  => com_api_type_pkg.FALSE
    ) || ' union all ' ||
    get_de49 (
        i_value_null   => com_api_type_pkg.TRUE
        , i_editable   => com_api_type_pkg.TRUE
        , i_mandatory  => com_api_type_pkg.FALSE
    );

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_retrieval_fee is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
    l_mti                   com_api_type_pkg.t_mcc;
begin
    l_mti := get_fin_data().mti;
    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => l_mti
    );
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de4 (
        i_value_null   => com_api_type_pkg.TRUE
        , i_editable   => com_api_type_pkg.TRUE
        , i_mandatory  => com_api_type_pkg.FALSE
    ) || ' union all ' ||
    get_de30_1 (
       i_value_null   => com_api_type_pkg.TRUE
       , i_editable   => com_api_type_pkg.TRUE
       , i_mandatory  => com_api_type_pkg.FALSE
    ) || ' union all ' ||
    get_de49 (
        i_value_null   => com_api_type_pkg.TRUE
        , i_editable   => com_api_type_pkg.TRUE
        , i_mandatory  => com_api_type_pkg.FALSE
    ) || ' union all ' ||
    get_de72 || ' union all ' ||
    get_p149_1 || ' union all ' ||
    get_p149_2 || ' union all ' ||
    get_hide_credit_receiver_flag(i_value => '1') || ' union all ' ||
    get_de25(        
        i_mandatory => com_api_const_pkg.TRUE
      , i_editable  => com_api_const_pkg.FALSE
      , i_value     => mcw_api_const_pkg.FEE_REASON_RETRIEVAL_RESP
    );

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_retrieval_request is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de25 (
        i_lov  => '360'
    ) || ' union all ' ||
    get_p228;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_first_chargeback_part is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
    );
    l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
    get_de49 (
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de4 (
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '363'
    ) || ' union all ' ||
    get_p262 || ' union all ' ||
    get_de72 || ' union all ' ||
    get_hide_chargeback_type(i_value => 'CHARGEBACK') || ' union all ' ||
    get_hide_partial_flag(i_value => 1) ;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_first_chargeback_full is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
    );
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de49 (
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de4 (
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de25 (
        i_lov => '363'
    ) || ' union all ' ||
    get_p262 || ' union all ' ||
    get_de72 || ' union all ' ||
    get_hide_chargeback_type(i_value => 'CHARGEBACK') || ' union all ' ||
    get_hide_partial_flag(i_value => 0);

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_common_reversal is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
        mcw_api_dsp_init_pkg.get_hide_reversal_flag(
            i_value => 1
        );

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_chargeback_fee is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
    l_mti                   com_api_type_pkg.t_mcc;
    l_de024                 com_api_type_pkg.t_mcc;
    l_de025                 com_api_type_pkg.t_mcc;
begin
    l_mti   := get_fin_data().mti;
    l_de024 := get_fin_data().de024;

    if l_de024 in (mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                 , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART)
    then
        l_de025 := mcw_api_const_pkg.FEE_REASON_HANDL_ISS_CHBK;
    else
        l_de025 := mcw_api_const_pkg.FEE_REASON_HANDL_ISS_CHBK2;
    end if;

    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => l_mti
    );
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de4 (
        i_value_null   => com_api_type_pkg.TRUE
        , i_mandatory  => com_api_type_pkg.FALSE
        , i_editable   => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de49 (
        i_editable     => com_api_type_pkg.FALSE
        , i_mandatory  => com_api_type_pkg.FALSE
    ) || ' union all ' ||
    get_de72 || ' union all ' ||

    get_de25 (
        i_mandatory  => com_api_const_pkg.TRUE
      , i_editable   => com_api_const_pkg.FALSE
      , i_value      => l_de025  
    ) || ' union all ' ||
            
    get_hide_credit_receiver_flag (
       i_value       => '1' --creditReceiver = true
    );
    
    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_second_pres_full is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
    l_mti                   com_api_type_pkg.t_mcc;
begin
    l_mti := get_fin_data().mti;
    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => l_mti
    );
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de4 (
        i_editable  => com_api_type_pkg.FALSE
    ) || ' union all ' ||
    get_de49 (
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '364'
    ) || ' union all ' ||
    get_p262 || ' union all ' ||
    get_de72 || ' union all ' ||
    get_hide_chargeback_type(i_value => 'SECOND_PRESENTMENT')  || ' union all ' ||
    get_hide_partial_flag(i_value => 0);

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_second_pres_part is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
    l_mti                   com_api_type_pkg.t_mcc;
begin
    l_mti := get_fin_data().mti;
    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => l_mti
    );
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de4 || ' union all ' ||
    get_de49 (
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '364'
    ) || ' union all ' ||
    get_p262 || ' union all ' ||
    get_de72 || ' union all ' ||
    get_hide_chargeback_type(i_value => 'SECOND_PRESENTMENT') || ' union all ' ||
    get_hide_partial_flag(i_value => 1);
    dbms_output.put_line(l_cursor_stmt);
    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_second_presentment_fee is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
    l_mti                   com_api_type_pkg.t_mcc;
begin
    l_mti := get_fin_data().mti;
    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => l_mti
    );
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de4 || ' union all ' ||
    get_de49 (
        i_value_null  => com_api_type_pkg.TRUE,
        i_mandatory => com_api_type_pkg.TRUE,
        i_editable => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de72 || ' union all ' ||
    get_hide_credit_receiver_flag(i_value => '1') || ' union all ' ||
    get_de25(i_value => mcw_api_const_pkg.FEE_REASON_HANDL_ACQ_PRES2)
    ;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_second_chbk_full is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
    l_mti                   com_api_type_pkg.t_mcc;
begin
    l_mti := get_fin_data().mti;
    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => l_mti
    );
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de49 (
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de4 (
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '365'
    ) || ' union all ' ||
    get_p262 || ' union all ' ||
    get_de72 || ' union all ' ||
    get_hide_chargeback_type(i_value => 'ARB_CHARGEBACK') || ' union all ' ||
    get_hide_partial_flag(i_value => 0);

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_second_chbk_part is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
    l_mti                   com_api_type_pkg.t_mcc;
begin
    l_mti := get_fin_data().mti;
    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => l_mti
    );
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de49 (
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de4 (
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '365'
    ) || ' union all ' ||
    get_p262 || ' union all ' ||
    get_de72 || ' union all ' ||
    get_hide_chargeback_type(i_value => 'ARB_CHARGEBACK') || ' union all ' ||
    get_hide_partial_flag(i_value => 1);

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_member_fee is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    dsp_api_shared_data_pkg.set_param (
        i_name  => 'MESSAGE_TYPE'
      , i_value => mcw_api_const_pkg.MSG_TYPE_FEE
    );
    dsp_api_shared_data_pkg.set_param (
        i_name  => 'DE_024'
      , i_value => mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE
    );

    l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt  ||
    get_mti  (i_editable => com_api_type_pkg.FALSE)   || ' union all ' ||
    get_de24 (i_editable => com_api_type_pkg.FALSE)   || ' union all ' ||
    get_de4  (i_value_null  => com_api_type_pkg.TRUE) || ' union all ' ||
    get_de49 (i_value_null  => com_api_type_pkg.TRUE, i_editable => com_api_type_pkg.TRUE)  || ' union all ' ||
    get_de25 (i_lov => '366') || ' union all ' ||
    get_de3_1(i_lov => '368') || ' union all ' ||
    get_de72(
        i_mandatory => com_api_type_pkg.FALSE
      , i_lov_id    => '717'
    )                         || ' union all ' ||
    get_de73 (i_mandatory  => com_api_type_pkg.FALSE) || ' union all ' ||
    get_de93 (i_mandatory  => com_api_type_pkg.TRUE)  || ' union all ' ||
    get_de94 || ' union all ' ||
    get_de2  (i_mandatory  => com_api_type_pkg.FALSE) || ' union all ' ||
    get_network || ' union all ' ||
    get_inst_id(i_value_null => com_api_type_pkg.TRUE, i_mandatory => com_api_type_pkg.FALSE, i_editable => com_api_type_pkg.TRUE);

    mcw_api_shared_data_pkg.set_fin;

    dsp_api_shared_data_pkg.set_cur_statement (i_cur_stat => l_cursor_stmt);
end;

procedure init_fee_return is
    l_cursor_stmt com_api_type_pkg.t_lob_data;
    l_mti         com_api_type_pkg.t_mcc;
    l_de003_1     mcw_api_type_pkg.t_de003;
begin
    l_mti     := get_fin_data().mti;
    l_de003_1 := get_fin_data().de003_1;

    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => l_mti
    );
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de4 || ' union all ' ||
    get_de49 (
        i_value_null  => com_api_type_pkg.TRUE
        , i_value     => '''840'''
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '367'
    ) || ' union all ' ||
    get_de72(i_lov_id => '717') || ' union all ' ||
    get_de73 || ' union all ' ||
    get_hide_credit_receiver_flag(
        i_value => case l_de003_1 
                   when mcw_api_const_pkg.PROC_CODE_CREDIT_FEE then '1' 
                   when mcw_api_const_pkg.PROC_CODE_DEBIT_FEE then '0' 
                   else null 
                   end
    );


    mcw_api_shared_data_pkg.set_fin;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat => l_cursor_stmt
    );
end;

procedure init_fee_resubmition is
    l_cursor_stmt  com_api_type_pkg.t_lob_data;
    l_mti          com_api_type_pkg.t_mcc;
    l_de003_1      mcw_api_type_pkg.t_de003;
begin
    l_mti := get_fin_data().mti;
    l_de003_1 := get_fin_data().de003_1;

    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => l_mti
    );
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de4 || ' union all ' ||
    get_de49 (
        i_value_null  => com_api_type_pkg.TRUE
        , i_value     => '''840'''
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '367'
    ) || ' union all ' ||
    get_de72 || ' union all ' ||
    get_de73 || ' union all ' ||
    get_hide_credit_receiver_flag(
        i_value => case l_de003_1 
                   when mcw_api_const_pkg.PROC_CODE_CREDIT_FEE then '1' 
                   when mcw_api_const_pkg.PROC_CODE_DEBIT_FEE then '0' 
                   else null 
                   end
    );

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_fee_second_return is
    l_cursor_stmt  com_api_type_pkg.t_lob_data;
    l_mti          com_api_type_pkg.t_mcc;
    l_de003_1      mcw_api_type_pkg.t_de003;
begin
    l_mti := get_fin_data().mti;
    l_de003_1 := get_fin_data().de003_1;

    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => l_mti
    );
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de4 || ' union all ' ||
    get_de49 (
        i_value_null  => com_api_type_pkg.TRUE
        , i_value     => '''840'''
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '367'
    ) || ' union all ' ||
    get_de72 || ' union all ' ||
    get_de73 || ' union all ' ||
    get_hide_credit_receiver_flag(
        i_value => case l_de003_1 
                   when mcw_api_const_pkg.PROC_CODE_CREDIT_FEE then '1' 
                   when mcw_api_const_pkg.PROC_CODE_DEBIT_FEE then '0' 
                   else null 
                   end
    );

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_fraud_reporting is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_c01 || ' union all ' ||
    get_c14 || ' union all ' ||
    get_oper_currency || ' union all ' ||
    get_c28 || ' union all ' ||
    get_c29 || ' union all ' ||
    get_c30 (i_mandatory => com_api_type_pkg.FALSE ) || ' union all ' ||
    get_c44 (i_mandatory => com_api_type_pkg.FALSE ) || ' union all ' ||
    get_c04 || ' union all ' ||
    get_c02;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );

    mcw_api_shared_data_pkg.set_fin();
end;

procedure init_retrieval_request_acknowl is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt 
      ||  get_p228
      || dsp_api_init_pkg.empty_statement;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

function get_formatted_de72(
    i_format_id           in com_api_type_pkg.t_tiny_id
  , i_claim_reason_code   in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_full_desc is
    l_params                 com_api_type_pkg.t_param_tab;
    l_de031                  com_api_type_pkg.t_arn;
    l_de72                   com_api_type_pkg.t_full_desc;
begin
    l_de031 := mcw_api_shared_data_pkg.get_fin().de031;
    rul_api_param_pkg.set_param(
        i_name     => 'DE_031'
      , i_value    => l_de031
      , io_params  => l_params
    );

    rul_api_param_pkg.set_param(
        i_name     => 'SYS_DATE'
      , i_value    => sysdate
      , io_params  => l_params
    );

    rul_api_param_pkg.set_param(
        i_name     => 'CLAIM_REASON_CODE'
      , i_value    => i_claim_reason_code
      , io_params  => l_params
    );

    l_de72 := rul_api_name_pkg.get_name(
                  i_format_id  => i_format_id
                , i_param_tab  => l_params
              );

	return l_de72;

end get_formatted_de72;

function get_hide_reversal_flag (
    i_value_null  in     com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
  , i_mandatory   in     com_api_type_pkg.t_boolean  default com_api_const_pkg.TRUE
  , i_editable    in     com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
  , i_value       in     com_api_type_pkg.t_name     default null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''HIDE_REVERSAL_FLAG''';
    l_where := l_where || ' and r.lang = l.lang';

    l_value := nvl(i_value, com_api_const_pkg.DATA_NUMBER_NULL_INIT);

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''HIDE_REVERSAL_FLAG''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.FALSE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  '1');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

    return l_cursor_stmt;
end;

function get_hide_chargeback_type (
    i_value_null  in     com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
  , i_mandatory   in     com_api_type_pkg.t_boolean  default com_api_const_pkg.TRUE
  , i_editable    in     com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
  , i_value       in     com_api_type_pkg.t_name     default null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''HIDE_CHARGEBACK_TYPE''';
    l_where := l_where || ' and r.lang = l.lang';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''HIDE_CHARGEBACK_TYPE''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   '''' || i_value ||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.FALSE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  '18');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

    return l_cursor_stmt;
end;

function get_hide_partial_flag (
    i_value_null  in     com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
  , i_mandatory   in     com_api_type_pkg.t_boolean  default com_api_const_pkg.TRUE
  , i_editable    in     com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
  , i_value       in     com_api_type_pkg.t_name     default null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''HIDE_PARTIAL_FLAG''';
    l_where := l_where || ' and r.lang = l.lang';

    l_value := nvl(i_value, com_api_const_pkg.DATA_NUMBER_NULL_INIT);

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''HIDE_PARTIAL_FLAG''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.FALSE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  '1');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

    return l_cursor_stmt;
end;


function get_hide_credit_receiver_flag (
    i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_value                   in com_api_type_pkg.t_name := null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
    l_mti                     com_api_type_pkg.t_mcc;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''HIDE_CREDIT_RECEIVER_FLAG''';
    l_where := l_where || ' and r.lang = l.lang';

    l_value := nvl(i_value, com_api_const_pkg.DATA_NUMBER_NULL_INIT);

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  '''HIDE_CREDIT_RECEIVER_FLAG''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     nvl(i_editable, com_api_type_pkg.FALSE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  '1');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        l_where);

    --dbms_output.put_line(l_cursor_stmt);
    return l_cursor_stmt;
end;

end mcw_api_dsp_init_pkg;
/
