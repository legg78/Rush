create or replace package body jcb_api_dsp_init_pkg is
/************************************************************
 * API for dispute init <br />
 * Created by Maslov I.(maslov@bpcbt.com) at 01.06.2013 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-10-20 16:42:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: mcw_api_dsp_init_pkg <br />
 * @headcom
 ************************************************************/

/*
 *   Get transaction code by OPERATION_ID from cache
 */
function get_fin_data
return jcb_api_type_pkg.t_fin_rec
is
    l_fin_msg                 jcb_api_type_pkg.t_fin_rec;
    l_id                      com_api_type_pkg.t_long_id;
begin
    l_id := dsp_api_shared_data_pkg.get_param_num (
                i_name => 'OPERATION_ID'
            );
    jcb_api_fin_pkg.get_fin(
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

    l_value := case when nvl(i_value_null, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
                   com_api_const_pkg.DATA_NUMBER_NULL_INIT

                    when l_mti = jcb_api_const_pkg.MSG_TYPE_CHARGEBACK then
                    'nvl(f.de005, f.de004)'
               else
                   'f.de004'
               end;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''AMOUNT''';
    l_where := l_where || ' and r.lang = l.lang';

    if nvl(i_value_null, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
        l_from := l_from || ', jcb_fin_message f';
        l_where := l_where || ' and f.id = o.oper_id';
    end if;

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''JCB_FIN_MESSAGE''';
    l_where := l_where || ' and c.column_name = ''DE004''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''DE_004''');
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
    l_where := l_where || ' and c.table_name = ''JCB_FIN_MESSAGE''';
    l_where := l_where || ' and c.column_name = ''DE004''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''CASHBACK_AMOUNT''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
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
    l_where := l_where || ' and c.table_name = ''JCB_FIN_MESSAGE''';
    l_where := l_where || ' and c.column_name = ''DE025''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''DE_025''');
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

    l_value := case when nvl(i_value_null, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
                   nvl(i_value, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT)

                    when l_mti = jcb_api_const_pkg.MSG_TYPE_CHARGEBACK then
                    'nvl(f.de050, f.de049)'
               else
                   'f.de049'
               end;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''CURRENCY''';
    l_where := l_where || ' and r.lang = l.lang';

    if nvl(i_value_null, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
        l_from := l_from || ', jcb_fin_message f';
        l_where := l_where || ' and f.id = o.oper_id';
    end if;

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''JCB_FIN_MESSAGE''';
    l_where := l_where || ' and c.column_name = ''DE049''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''DE_049''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, com_api_type_pkg.TRUE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, nvl(i_editable, com_api_type_pkg.FALSE));
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
    l_where := l_where || ' and c.table_name = ''JCB_FIN_MESSAGE''';
    l_where := l_where || ' and c.column_name = ''DE072''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, 'r.name');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, com_api_const_pkg.DATA_NUMBER_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, nvl(i_mandatory, com_api_type_pkg.FALSE));
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, com_api_type_pkg.TRUE);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_p3250 return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := com_api_const_pkg.DATA_NUMBER_NULL_INIT;
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''PDS_3250''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''JCB_FIN_MESSAGE''';
    l_where := l_where || ' and c.column_name = ''P3250''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, '''PDS_3250''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, com_api_const_pkg.DATA_DATE_NULL_INIT);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, com_api_type_pkg.TRUE);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, com_api_type_pkg.TRUE);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LOV, 'r.lov_id');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_LANG, 'l.lang');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE, ''''||com_api_const_pkg.DATA_TYPE_CHAR||'''');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH, 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FROM, l_from);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_WHERE, l_where);

    return l_cursor_stmt;
end;

function get_p3203 return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement;

    l_value := '(null)';
    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''PDS_3203''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''JCB_FIN_MESSAGE''';
    l_where := l_where || ' and c.column_name = ''P3203''';

    -- make cursor
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME, 'r.name');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME, 'r.short_description');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, '(null)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR, l_value);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE, '(null)');
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY, get_true);
    l_cursor_stmt := replace(l_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE, get_true);
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

procedure init_first_chargeback_part is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => jcb_api_const_pkg.MSG_TYPE_CHARGEBACK
    );
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de49 (
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de4 (
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '502'
    ) || ' union all ' ||
    get_p3250 || ' union all ' ||
    get_de72;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_first_chargeback_full is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    dsp_api_shared_data_pkg.set_param (
        i_name    => 'MESSAGE_TYPE'
        , i_value => jcb_api_const_pkg.MSG_TYPE_CHARGEBACK
    );
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de49 (
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de4 (
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de25 (
        i_lov => '502'
    ) || ' union all ' ||
    --3250
    get_p3250 || ' union all ' ||
    get_de72;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_common_reversal is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt || dsp_api_init_pkg.empty_statement;

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
    get_de49 || ' union all ' ||
    get_de25 (
        i_lov  => '503'
    ) || ' union all ' ||
    get_p3250 || ' union all ' ||
    get_de72;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
    trc_log_pkg.debug('l_cursor_stmt [' || l_cursor_stmt || ']');
    
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
        i_lov  => '503'
    ) || ' union all ' ||
    get_p3250 || ' union all ' ||
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
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de4 (
        i_editable  => com_api_type_pkg.TRUE
    ) || ' union all ' ||
    get_de25 (
        i_lov  => '501'
    ) || ' union all ' ||
    get_p3250 || ' union all ' ||
    get_de72;

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
        i_lov  => '501'
    ) || ' union all ' ||
    get_p3250 || ' union all ' ||
    get_de72;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure init_retrieval_request is
    l_cursor_stmt           com_api_type_pkg.t_lob_data;
begin
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt ||
    get_de25 (
        i_lov  => '504'
    ) || ' union all ' ||
    get_p3203;

    dsp_api_shared_data_pkg.set_cur_statement (
        i_cur_stat  => l_cursor_stmt
    );
end;

end;
/
