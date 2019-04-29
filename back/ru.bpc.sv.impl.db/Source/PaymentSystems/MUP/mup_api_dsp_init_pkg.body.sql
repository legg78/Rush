create or replace package body mup_api_dsp_init_pkg is
/************************************************************
 * API for dispute init <br />
 * Created by Maslov I.(maslov@bpcbt.com) at 01.06.2013 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-10-20 16:42:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: mup_api_dsp_init_pkg <br />
 * @headcom
 ************************************************************/

/*
 *   Get transaction code by OPERATION_ID from cache
 */
function get_fin_data
return mup_api_type_pkg.t_fin_rec
is
    l_fin_msg                 mup_api_type_pkg.t_fin_rec;
    l_id                      com_api_type_pkg.t_long_id;
begin
    l_id := dsp_api_shared_data_pkg.get_param_num (
                i_name => 'OPERATION_ID'
            );
    mup_api_fin_pkg.get_fin(
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
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''C_01''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''STATUS''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''C_01''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_c02 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_NUMBER_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''DE_094''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''DE094''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''C_02''');
    --l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, '''Issuer Customer Number''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.data_type_number||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_c04 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := 'to_char(lpad(f.de093,11,''0''))';
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''DE_093''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', mup_fin f';
    l_where := l_where || ' and f.id = o.oper_id';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''DE093''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''C_04''');
    --l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, '''Acquirer Customer Number''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.data_type_char||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_c14 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := 'f.de004' ;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''AMOUNT''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', mup_fin f';
    l_where := l_where || ' and f.id = o.oper_id';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''DE004''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''C_14''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

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

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''CURRENCY''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''DE049''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''C_15''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_c28 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''C_28''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''STATUS''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''C_28''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_c29 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''C_29''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''STATUS''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''C_29''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

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

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''C_30''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''STATUS''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''C_30''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_c31 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''C_31''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''STATUS''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''C_31''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_c44 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''C_44''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''STATUS''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''C_44''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_de2 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
    l_mti                     com_api_type_pkg.t_mcc;
    l_de024                   mup_api_type_pkg.t_de024;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_mti := dsp_api_shared_data_pkg.get_param_char (
                     i_name => 'MESSAGE_TYPE'
                 );

    l_de024 := dsp_api_shared_data_pkg.get_param_char (
                     i_name => 'DE_024'
                 );

    l_value := case when l_mti = mup_api_const_pkg.MSG_TYPE_FEE and l_de024 = mup_api_const_pkg.FUNC_CODE_MEMBER_FEE then
                    'f.de002'
               else
                   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT
               end;

    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''CARD_NUMBER''';
    l_where := l_where || ' and r.lang = l.lang';

    if l_mti = mup_api_const_pkg.MSG_TYPE_FEE and l_de024 = mup_api_const_pkg.FUNC_CODE_MEMBER_FEE then
        l_from := l_from || ', mup_fin f';
        l_where := l_where || ' and f.id(+) = o.oper_id';
    end if;

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''DE002''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''DE_002''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_de3_1 (
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
    l_where := l_where || ' and r.name =''FEE_PROCESSING_CODE''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''DE003_1''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''DE_003_1''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, nvl(i_lov, 'r.lov_id'));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_de4 (
    i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    , i_mandatory             in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
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

    l_value := case when nvl(i_value_null, get_false) = get_true then
                   com_api_const_pkg.DATA_NUMBER_NULL_INIT

                    when l_mti = mup_api_const_pkg.MSG_TYPE_CHARGEBACK then
                    'nvl(f.de005, f.de004)'
               else
                   'f.de004'
               end;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''AMOUNT''';
    l_where := l_where || ' and r.lang = l.lang';

    if nvl(i_value_null, get_false) = get_false then
        l_from := l_from || ', mup_fin f';
        l_where := l_where || ' and f.id = o.oper_id';
    end if;

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''DE004''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''DE_004''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_cashback (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''CASHBACK_AMOUNT''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''DE004''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''CASHBACK_AMOUNT''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_de25 (
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
    l_where := l_where || ' and r.name =''REASON_CODE''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''DE025''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''DE_025''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, nvl(i_lov, 'r.lov_id'));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_de30_1 (
    i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    , i_mandatory             in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := case when nvl(i_value_null, get_false) = get_true then
                   com_api_const_pkg.DATA_NUMBER_NULL_INIT
               else
                   'f.de030_1'
               end;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''AMOUNT''';
    l_where := l_where || ' and r.lang = l.lang';

    if nvl(i_value_null, get_false) = get_false then
        l_from := l_from || ', mup_fin f';
        l_where := l_where || ' and f.id = o.oper_id';
    end if;

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''DE030_1''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''DE_030_1''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_de49 (
    i_value_null              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    , i_mandatory             in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    , i_value                 in com_api_type_pkg.t_name := null
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

    l_value := case when nvl(i_value_null, get_false) = get_true then
                   nvl(i_value, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT)

                    when l_mti = mup_api_const_pkg.MSG_TYPE_CHARGEBACK then
                    'nvl(f.de050, f.de049)'
               else
                   'f.de049'
               end;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''CURRENCY''';
    l_where := l_where || ' and r.lang = l.lang';

    if nvl(i_value_null, get_false) = get_false then
        l_from := l_from || ', mup_fin f';
        l_where := l_where || ' and f.id = o.oper_id';
    end if;

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''DE049''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''DE_049''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_false));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_de72 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.false
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''DE_072''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''DE072''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, 'r.name');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_false));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, get_true);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

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

    l_value := com_api_const_pkg.DATA_DATE_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''DE_073''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''DE073''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, 'r.name');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_false));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, get_true);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_DATE||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_de93 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_lov                   in com_api_type_pkg.t_name    default null
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
    l_mti                     com_api_type_pkg.t_mcc;
    l_de024                   mup_api_type_pkg.t_de024;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_mti := dsp_api_shared_data_pkg.get_param_char (
                     i_name => 'MESSAGE_TYPE'
                 );

    l_de024 := dsp_api_shared_data_pkg.get_param_char (
                     i_name => 'DE_024'
                 );

    l_value := case when l_mti = mup_api_const_pkg.MSG_TYPE_FEE and l_de024 = mup_api_const_pkg.FUNC_CODE_MEMBER_FEE then
                    'lpad(f.de093,11,''0'')'
               else
                   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT
               end;

    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''DE_093''';
    l_where := l_where || ' and r.lang = l.lang';

    if l_mti = mup_api_const_pkg.MSG_TYPE_FEE and l_de024 = mup_api_const_pkg.FUNC_CODE_MEMBER_FEE then
        l_from := l_from || ', mup_fin f';
        l_where := l_where || ' and f.id(+) = o.oper_id';
    end if;

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''DE093''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, 'r.name');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, nvl(i_lov, 'r.lov_id'));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_de94 (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
    l_mti                     com_api_type_pkg.t_mcc;
    l_de024                   mup_api_type_pkg.t_de024;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_mti := dsp_api_shared_data_pkg.get_param_char (
                     i_name => 'MESSAGE_TYPE'
                 );

    l_de024 := dsp_api_shared_data_pkg.get_param_char (
                     i_name => 'DE_024'
                 );

    l_value := case when l_mti = mup_api_const_pkg.MSG_TYPE_FEE and l_de024 = mup_api_const_pkg.FUNC_CODE_MEMBER_FEE then
                    'f.de094'
               else
                   com_api_const_pkg.DATA_VARCHAR2_NULL_INIT
               end;

    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''DE_094''';
    l_where := l_where || ' and r.lang = l.lang';

    if l_mti = mup_api_const_pkg.MSG_TYPE_FEE and l_de024 = mup_api_const_pkg.FUNC_CODE_MEMBER_FEE then
        l_from := l_from || ', mup_fin f';
        l_where := l_where || ' and f.id(+) = o.oper_id';
    end if;

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''DE094''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, 'r.name');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_network (
    i_mandatory               in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    , i_editable              in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
    l_mti                     com_api_type_pkg.t_mcc;
    l_de024                   mup_api_type_pkg.t_de024;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_mti := dsp_api_shared_data_pkg.get_param_char (
                     i_name => 'MESSAGE_TYPE'
                 );

    l_de024 := dsp_api_shared_data_pkg.get_param_char (
                     i_name => 'DE_024'
                 );

    l_value := case when l_mti = mup_api_const_pkg.MSG_TYPE_FEE and l_de024 = mup_api_const_pkg.FUNC_CODE_MEMBER_FEE then
                    'f.network_id'
               else
                   com_api_const_pkg.DATA_NUMBER_NULL_INIT
               end;

    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''NETWORK_ID''';
    l_where := l_where || ' and r.lang = l.lang';

    if l_mti = mup_api_const_pkg.MSG_TYPE_FEE and l_de024 = mup_api_const_pkg.FUNC_CODE_MEMBER_FEE then
        l_from := l_from || ', mup_fin f';
        l_where := l_where || ' and f.id(+) = o.oper_id';
    end if;

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''NETWORK_ID''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, 'r.name');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_p149_1 return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''CURRENCY''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''P0149_1''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''PDS_0149_1''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, get_false);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, get_true);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_p149_2 return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''CURRENCY''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''P0149_2''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''PDS_0149_1''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, get_false);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, get_true);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_p228 return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_NUMBER_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''PDS_0228''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''P0228''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, 'r.name');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, get_true);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, get_true);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

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
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''PDS_0262''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''P0262''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''PDS_0262''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, get_true);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, get_true);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_NUMBER||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_p2072_1 return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := '''CYR''';
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''PDS_2072_1''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''P2072_1''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''PDS_2072_1''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, get_false);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, get_false);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_p2072_2 return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''PDS_2072_2''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''MUP_FIN''';
    l_where := l_where || ' and c.column_name = ''P2072_2''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''PDS_2072_2''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, get_false);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, get_true);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_RAW||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, ''RAW'', c.data_length, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

    function get_oper_currency (
        i_mandatory        in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
        , i_editable       in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_text is
        l_cursor_stmt      com_api_type_pkg.t_text;
        l_value            com_api_type_pkg.t_name;
        l_where            com_api_type_pkg.t_name;
        l_from             com_api_type_pkg.t_name;
    begin
        l_cursor_stmt := dsp_api_init_pkg.default_statement;

        l_value := 'f.de049' ;
        l_from := l_from || ', rul_ui_mod_param_vw r';
        l_where := l_where || ' and r.name =''OPER_CURRENCY''';
        l_where := l_where || ' and r.lang = l.lang';

        l_from := l_from || ', mup_fin f';
        l_where := l_where || ' and f.id = o.oper_id';

        l_from := l_from || ', user_tab_columns c';
        l_where := l_where || ' and c.table_name = ''MUP_FIN''';
        l_where := l_where || ' and c.column_name = ''DE049''';

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''OPER_CURRENCY''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, get_true));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, get_true));
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
        l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

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
    get_de4 || ' union all ' ||
    get_de49;

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
        i_value_null   => get_true
        , i_editable   => get_true
        , i_mandatory  => get_false
    ) || ' union all ' ||
    get_de30_1 (
       i_value_null   => get_true
       , i_editable   => get_true
       , i_mandatory  => get_false
    ) || ' union all ' ||
    get_de49 (
        i_value_null   => get_true
        , i_editable   => get_true
        , i_mandatory  => get_false
    ) || ' union all ' ||
    get_de72 || ' union all ' ||
    get_p149_1 || ' union all ' ||
    get_p149_2;

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
    l_cursor_stmt              com_api_type_pkg.t_lob_data;
begin
    dsp_api_shared_data_pkg.set_param (
        i_name  => 'MESSAGE_TYPE'
      , i_value => mup_api_const_pkg.MSG_TYPE_CHARGEBACK
    );
    l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
    get_de49 (
        i_editable  => get_true
    ) || ' union all ' ||
    get_de4 (
        i_editable  => get_true
    ) || ' union all ' ||
    /*get_cashback (
        i_mandatory  => get_false
    ) || ' union all ' ||*/
    get_de25 (
        i_lov  => '1061'
    ) || ' union all ' ||
    get_p262 || ' union all ' ||
    get_de72
    ;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_first_chargeback_full is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => mup_api_const_pkg.MSG_TYPE_CHARGEBACK
    );
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de49 (
        i_editable  => get_false
    ) || ' union all ' ||
    get_de4 (
        i_editable  => get_false
    ) || ' union all ' ||
    get_de25 (
        i_lov => '1061'
    ) || ' union all ' ||
    get_p262 || ' union all ' ||
    get_de72
    ;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_common_reversal is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
    l_fin_rec               mup_api_type_pkg.t_fin_rec;
    l_standard_version_id   com_api_type_pkg.t_tiny_id;
begin
    l_fin_rec := get_fin_data;
    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => l_fin_rec.mti
    );
    l_standard_version_id := cmn_api_standard_pkg.get_current_version(
        i_network_id => l_fin_rec.network_id
    );
    if l_standard_version_id >= mup_api_const_pkg.MUP_STANDARD_VERSION_ID_18Q4 then
        l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
        get_de4 || ' union all ' ||
        get_de49;
    else
        l_cursor_stmt := dsp_api_init_pkg.get_header_stmt || dsp_api_init_pkg.empty_statement;
    end if;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_chargeback_fee is
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
        i_value_null   => get_true
        , i_mandatory  => get_false
        , i_editable   => get_true
    ) || ' union all ' ||
    get_de49 (
        i_editable     => get_false
        , i_mandatory  => get_false
    ) || ' union all ' ||
    get_de72;

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
        i_editable  => get_false
    ) || ' union all ' ||
    get_de49 || ' union all ' ||
    get_de25 (
        i_lov  => '1062'
    ) || ' union all ' ||
    get_p262 || ' union all ' ||
    get_de72
    ;

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
        i_editable  => get_true
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '1062'
    ) || ' union all ' ||
    get_p262 || ' union all ' ||
    get_de72
    ;

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
        i_value_null  => get_true
    ) || ' union all ' ||
    get_de72;

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
        i_editable  => get_false
    ) || ' union all ' ||
    get_de4 (
        i_editable  => get_false
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '1063'
    ) || ' union all ' ||
    get_p262 || ' union all ' ||
    get_de72 || ' union all ' ||
    get_p2072_1 || ' union all ' ||
    get_p2072_2;

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
        i_editable  => get_true
    ) || ' union all ' ||
    get_de4 (
        i_editable  => get_true
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '1063'
    ) || ' union all ' ||
    get_p262 || ' union all ' ||
    get_de72 || ' union all ' ||
    get_p2072_1 || ' union all ' ||
    get_p2072_2;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_member_fee is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => mup_api_const_pkg.MSG_TYPE_FEE
    );
    dsp_api_shared_data_pkg.set_param (
        i_name    => 'DE_024'
        , i_value => mup_api_const_pkg.FUNC_CODE_MEMBER_FEE
    );
    
    l_cursor_stmt:= dsp_api_init_pkg.get_header_stmt ||
    get_de4 (
        i_value_null  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de49 (
        i_value_null  => com_api_type_pkg.TRUE
        , i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de25 || ' union all ' ||
    get_de3_1 (
        i_lov  => '368'
    ) || ' union all ' ||
    get_de72 (
        i_mandatory  => com_api_type_pkg.FALSE
    ) || ' union all ' ||
    get_de73 (
        i_mandatory  => com_api_type_pkg.FALSE
    ) || ' union all ' ||
    get_de93 (
        i_mandatory  => com_api_type_pkg.TRUE
      , i_lov  => '1066'
    ) || ' union all ' ||
    get_de94 || ' union all ' ||
    get_de2 (
        i_mandatory  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_network;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_fee_return is
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
        i_value_null  => get_true
        , i_value     => '''840'''
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '1065'
    ) || ' union all ' ||
    get_de72 || ' union all ' ||
    get_de73;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_fee_resubmition is
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
        i_value_null  => get_true
        , i_value     => '''840'''
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '1065'
    ) || ' union all ' ||
    get_de72 || ' union all ' ||
    get_de73;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_fee_second_return is
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
        i_value_null  => get_true
        , i_value     => '''840'''
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '1065'
    ) || ' union all ' ||
    get_de72 || ' union all ' ||
    get_de73;

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
    get_c30 ( i_mandatory => get_false ) || ' union all ' ||
    get_c44 ( i_mandatory => get_false ) || ' union all ' ||
    get_c04 || ' union all ' ||
    get_c02;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_retrieval_request_acknowl is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt || dsp_api_init_pkg.empty_statement;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

end;
/
