create or replace package body cst_bof_gim_api_dsp_init_pkg is

procedure make_cursor_statement(
    io_cursor_stmt            in out nocopy com_api_type_pkg.t_text
  , i_from                    in            com_api_type_pkg.t_text
  , i_where                   in            com_api_type_pkg.t_text
  , i_system_name             in            com_api_type_pkg.t_name
  , i_form_name               in            com_api_type_pkg.t_name    default 'r.short_description'
  , i_number                  in            com_api_type_pkg.t_name    default com_api_const_pkg.DATA_NUMBER_NULL_INIT
  , i_char                    in            com_api_type_pkg.t_name    default com_api_const_pkg.DATA_VARCHAR2_NULL_INIT
  , i_date                    in            com_api_type_pkg.t_name    default com_api_const_pkg.DATA_DATE_NULL_INIT
  , i_mandatory               in            com_api_type_pkg.t_boolean
  , i_editable                in            com_api_type_pkg.t_boolean
  , i_lov                     in            com_api_type_pkg.t_name    default 'r.lov_id'
  , i_lang                    in            com_api_type_pkg.t_name    default 'l.lang'
  , i_data_type               in            com_api_type_pkg.t_dict_value
  , i_data_length             in            com_api_type_pkg.t_name
        default 'decode(c.data_type, ''NUMBER'', c.data_precision+c.data_scale, c.char_length)'
) is
begin
    io_cursor_stmt := replace(io_cursor_stmt, dsp_api_init_pkg.STMT_SYSTEM_NAME,  i_system_name);
    io_cursor_stmt := replace(io_cursor_stmt, dsp_api_init_pkg.STMT_FORM_NAME,    i_form_name);
    io_cursor_stmt := replace(io_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_NUMBER, i_number);
    io_cursor_stmt := replace(io_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_CHAR,   i_char);
    io_cursor_stmt := replace(io_cursor_stmt, dsp_api_init_pkg.STMT_VALUE_DATE,   i_date);
    io_cursor_stmt := replace(io_cursor_stmt, dsp_api_init_pkg.STMT_MANDATORY,    i_mandatory);
    io_cursor_stmt := replace(io_cursor_stmt, dsp_api_init_pkg.STMT_EDITABLE,     i_editable);
    io_cursor_stmt := replace(io_cursor_stmt, dsp_api_init_pkg.STMT_LOV,          i_lov);
    io_cursor_stmt := replace(io_cursor_stmt, dsp_api_init_pkg.STMT_LANG,         i_lang);
    io_cursor_stmt := replace(io_cursor_stmt, dsp_api_init_pkg.STMT_FIELD_TYPE,   '''' || i_data_type || '''');
    io_cursor_stmt := replace(io_cursor_stmt, dsp_api_init_pkg.STMT_DATA_LENGTH,  i_data_length);
    io_cursor_stmt := replace(io_cursor_stmt, dsp_api_init_pkg.STMT_FROM,         i_from);
    io_cursor_stmt := replace(io_cursor_stmt, dsp_api_init_pkg.STMT_WHERE,        i_where);
end make_cursor_statement;

function get_inst_id(
    i_value_null              in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_value :=
        case
            when nvl(i_value_null, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
            then com_api_const_pkg.DATA_NUMBER_NULL_INIT
            else 'f.inst_id'
        end;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''INST_ID''';
    l_where := l_where || ' and r.lang = l.lang';

    if nvl(i_value_null, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
        l_from  := l_from  || ', cst_bof_gim_fin_msg f';
        l_where := l_where || ' and f.id = o.oper_id';
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FIN_MSG''';
    l_where := l_where || ' and c.column_name = ''INST_ID''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''INST_ID'''
      , i_number       => l_value
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.TRUE)
      , i_editable     => nvl(i_editable, com_api_const_pkg.TRUE)
      , i_data_type    => com_api_const_pkg.DATA_TYPE_NUMBER
    );

    return l_cursor_stmt;
end get_inst_id;

function get_network_id(
    i_value_null              in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_value :=
        case
            when nvl(i_value_null, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
            then com_api_const_pkg.DATA_NUMBER_NULL_INIT
            else 'f.network_id'
        end;

    l_from  := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''NETWORK_ID''';
    l_where := l_where || ' and r.lang = l.lang';

    if nvl(i_value_null, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
        l_from := l_from || ', cst_bof_gim_fin_msg f';
        l_where := l_where || ' and f.id = o.oper_id';
    end if;

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FIN_MSG''';
    l_where := l_where || ' and c.column_name = ''NETWORK_ID''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''NETWORK_ID'''
      , i_number       => l_value
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.TRUE)
      , i_editable     => nvl(i_editable, com_api_const_pkg.TRUE)
      , i_data_type    => com_api_const_pkg.DATA_TYPE_NUMBER
    );

    return l_cursor_stmt;
end;

function get_event_date (
    i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_editable                in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''EVENT_DATE''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FEE''';
    l_where := l_where || ' and c.column_name = ''EVENT_DATE''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''EVENT_DATE'''
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.FALSE)
      , i_editable     => nvl(i_editable,  com_api_const_pkg.TRUE)
      , i_data_type    => com_api_const_pkg.DATA_TYPE_DATE
    );

    return l_cursor_stmt;
end;

function get_transaction_code
    return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
    l_trans_code              com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_trans_code  := dsp_api_shared_data_pkg.get_param_char(i_name => 'TRANSACTION_CODE');

    l_from := l_from || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''TRANSACTION_CODE''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FIN_MSG''';
    l_where := l_where || ' and c.column_name = ''TRANS_CODE''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''TRANSACTION_CODE'''
      , i_char         => nvl('''' || l_trans_code || '''', com_api_const_pkg.DATA_VARCHAR2_NULL_INIT)
      , i_mandatory    => com_api_const_pkg.TRUE
      , i_editable     => com_api_const_pkg.FALSE
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_oper_amount(
    i_value_null              in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_mandatory               in            com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_editable                in            com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_trans_code              com_api_type_pkg.t_byte_char;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_trans_code  := dsp_api_shared_data_pkg.get_param_char(
                         i_name => 'TRANSACTION_CODE'
                     );
    l_value :=
        case
            when nvl(i_value_null, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
            then
                com_api_const_pkg.DATA_NUMBER_NULL_INIT
            when l_trans_code in (cst_bof_gim_api_const_pkg.TC_SALES_CHARGEBACK
                                , cst_bof_gim_api_const_pkg.TC_VOUCHER_CHARGEBACK
                                , cst_bof_gim_api_const_pkg.TC_CASH_CHARGEBACK
                                , cst_bof_gim_api_const_pkg.TC_FEE_COLLECTION
                                , cst_bof_gim_api_const_pkg.TC_FUNDS_DISBURSEMENT)
            then
                'nvl(f.sttl_amount, f.oper_amount)'
            else
                'f.oper_amount'
        end;
    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''OPER_AMOUNT'''
                       || ' and r.lang = l.lang';

    if nvl(i_value_null, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
        l_from  := l_from || ', cst_bof_gim_fin_msg f';
        l_where := l_where || ' and f.id = o.oper_id';
    end if;

    l_from  := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FIN_MSG'''
                       || ' and c.column_name = ''OPER_AMOUNT''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''OPER_AMOUNT'''
      , i_number       => l_value
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.TRUE)
      , i_editable     => nvl(i_editable, com_api_const_pkg.TRUE)
      , i_data_type    => com_api_const_pkg.DATA_TYPE_NUMBER
    );

    return l_cursor_stmt;
end get_oper_amount;

function get_oper_currency(
    i_value_null              in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_value                   in            com_api_type_pkg.t_name    default null
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_trans_code              com_api_type_pkg.t_byte_char;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_trans_code :=  dsp_api_shared_data_pkg.get_param_char(
                         i_name => 'TRANSACTION_CODE'
                     );
    l_value :=
        case
            when nvl(i_value_null, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
                nvl(i_value, com_api_const_pkg.DATA_VARCHAR2_NULL_INIT)
            when l_trans_code in (cst_bof_gim_api_const_pkg.TC_SALES_CHARGEBACK
                                , cst_bof_gim_api_const_pkg.TC_VOUCHER_CHARGEBACK
                                , cst_bof_gim_api_const_pkg.TC_CASH_CHARGEBACK
                                , cst_bof_gim_api_const_pkg.TC_FEE_COLLECTION
                                , cst_bof_gim_api_const_pkg.TC_FUNDS_DISBURSEMENT)
            then
                'nvl(f.sttl_currency, f.oper_currency)'
            else
                'f.oper_currency'
        end;
    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''OPER_CURRENCY''';
    l_where := l_where || ' and r.lang = l.lang';

    if nvl(i_value_null, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
        l_from  := l_from  || ', cst_bof_gim_fin_msg f';
        l_where := l_where || ' and f.id = o.oper_id';
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FIN_MSG''';
    l_where := l_where || ' and c.column_name = ''OPER_CURRENCY''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''OPER_CURRENCY'''
      , i_char         => l_value
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.TRUE)
      , i_editable     => nvl(i_editable, com_api_const_pkg.TRUE)
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end get_oper_currency;

function get_card_number(
    i_value_null              in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_editable                in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_value_null              com_api_type_pkg.t_boolean := nvl(i_value_null, com_api_const_pkg.FALSE);
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''CARD_NUMBER''';
    l_where := l_where || ' and r.lang = l.lang';

    if l_value_null = com_api_const_pkg.FALSE then
        l_from  := l_from  || ', cst_bof_gim_card f';
        l_where := l_where || ' and f.id = o.oper_id';
        l_value := 'iss_api_token_pkg.decode_card_number(i_card_number => f.card_number)';
    else
        l_value := com_api_const_pkg.DATA_VARCHAR2_NULL_INIT;
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_CARD''';
    l_where := l_where || ' and c.column_name = ''CARD_NUMBER''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''CARD_NUMBER'''
      , i_char         => l_value
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.FALSE)
      , i_editable     => nvl(i_editable, com_api_const_pkg.TRUE)
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_country_code(
    i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''COUNTRY''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FEE''';
    l_where := l_where || ' and c.column_name = ''FORW_INST_COUNTRY_CODE''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''COUNTRY'''
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.FALSE)
      , i_editable     => com_api_const_pkg.TRUE
      , i_lov          => '24'
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_fee_reason_code(
    i_value_null              in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_editable                in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_lov                     in            com_api_type_pkg.t_name    default null
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_name;
    l_where                   com_api_type_pkg.t_name;
    l_from                    com_api_type_pkg.t_name;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_value :=
        case
            when nvl(i_value_null, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE
            then com_api_const_pkg.DATA_VARCHAR2_NULL_INIT
            else 'f.reason_code'
        end;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name =''OPER_REASON''';
    l_where := l_where || ' and r.lang = l.lang';

    if nvl(i_value_null, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
        l_from  := l_from  || ', cst_bof_gim_fee f';
        l_where := l_where || ' and f.id = o.oper_id';
    end if;

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name  = ''CST_BOF_GIM_FEE''';
    l_where := l_where || ' and c.column_name = ''REASON_CODE''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''REASON_CODE'''
      , i_char         => l_value
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.FALSE)
      , i_editable     => nvl(i_editable, com_api_const_pkg.TRUE)
      , i_lov          => i_lov
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_member_msg_text(
    i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''MEMBER_MESSAGE_TEXT''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FIN_MSG''';
    l_where := l_where || ' and c.column_name = ''MEMBER_MSG_TEXT''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''MEMBER_MESSAGE_TEXT'''
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.FALSE)
      , i_editable     => com_api_const_pkg.TRUE
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_fee_member_msg_text(
    i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''MEMBER_MESSAGE_TEXT''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FEE''';
    l_where := l_where || ' and c.column_name = ''MESSAGE_TEXT''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''MEMBER_MESSAGE_TEXT'''
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.FALSE)
      , i_editable     => com_api_const_pkg.TRUE
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_reason_code(
    i_mandatory               in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_lov                     in            com_api_type_pkg.t_name       default null
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''OPER_REASON''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FIN_MSG''';
    l_where := l_where || ' and c.column_name = ''REASON_CODE''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''REASON_CODE'''
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.FALSE)
      , i_editable     => com_api_const_pkg.TRUE
      , i_lov          => i_lov
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_debit_credit_indicator(
    i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_editable                in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''GIM_DEBIT_CREDIT_INDICATOR''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name  = ''CST_BOF_GIM_FRAUD''';
    l_where := l_where || ' and c.column_name = ''DEBIT_CREDIT_INDICATOR''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''GIM_DEBIT_CREDIT_INDICATOR'''
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.FALSE)
      , i_editable     => nvl(i_editable, com_api_const_pkg.TRUE)
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_transaction_gen_nethod(
    i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_editable                in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''GIM_TRANS_GENERATION_METHOD''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name  = ''CST_BOF_GIM_FRAUD''';
    l_where := l_where || ' and c.column_name = ''TRANS_GENERATION_METHOD''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''GIM_TRANS_GENERATION_METHOD'''
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.FALSE)
      , i_editable     => nvl(i_editable, com_api_const_pkg.TRUE)
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_docum_ind(
    i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_editable                in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''DOCUMENTATION_INDICATOR''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FIN_MSG''';
    l_where := l_where || ' and c.column_name = ''DOCUM_IND''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''DOCUMENTATION_INDICATOR'''
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.TRUE)
      , i_editable     => nvl(i_editable, com_api_const_pkg.TRUE)
      , i_data_type    => com_api_const_pkg.DATA_TYPE_NUMBER
    );

    return l_cursor_stmt;
end;

function get_spec_chargeback_ind(
    i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_editable                in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''SPECIAL_CHARGEBACK_INDICATOR''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FIN_MSG''';
    l_where := l_where || ' and c.column_name = ''SPEC_CHARGEBACK_IND''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''SPECIAL_CHARGEBACK_INDICATOR'''
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.TRUE)
      , i_editable     => nvl(i_editable, com_api_const_pkg.TRUE)
      , i_data_type    => com_api_const_pkg.DATA_TYPE_NUMBER
    );

    return l_cursor_stmt;
end;

function get_usage_code (
    i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_editable                in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''USAGE_CODE''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FIN_MSG''';
    l_where := l_where || ' and c.column_name = ''USAGE_CODE''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''USAGE_CODE'''
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.TRUE)
      , i_editable     => nvl(i_editable, com_api_const_pkg.TRUE)
      , i_data_type    => com_api_const_pkg.DATA_TYPE_NUMBER
    );

    return l_cursor_stmt;
end;

function get_notification_code
    return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''NOTIFICATION_CODE''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FRAUD''';
    l_where := l_where || ' and c.column_name = ''NOTIFICATION_CODE''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''NOTIFICATION_CODE'''
      , i_mandatory    => com_api_const_pkg.TRUE
      , i_editable     => com_api_const_pkg.TRUE
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_card_expir_date(
    i_value_null              in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_editable                in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_value                   in            com_api_type_pkg.t_name    default null
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_value                   com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_value :=
        case
            when nvl(i_value_null, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
            then nvl(i_value, com_api_const_pkg.DATA_DATE_NULL_INIT)
            else 'case ' ||
                     'when f.card_expir_date is null ' ||
                     'then (select trunc(last_day(expir_date)) ' ||
                             'from iss_card_instance ' ||
                            'where id = p.card_instance_id) ' ||
                     'else last_day(to_date(f.card_expir_date, ''MMYY'')) ' ||
                 'end'
        end;

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''EXPIR_DATE''';
    l_where := l_where || ' and r.lang = l.lang';

    if nvl(i_value_null, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
        l_from  := l_from  || ', cst_bof_gim_fin_msg f';
        l_where := l_where || ' and f.id = o.oper_id';
    end if;

    l_from  := l_from  || ', opr_participant p';
    l_where := l_where || ' and p.oper_id = o.oper_id';
    l_where := l_where || ' and p.participant_type = ''PRTYISS''';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name  = ''CST_BOF_GIM_FIN_MSG''';
    l_where := l_where || ' and c.column_name = ''CARD_EXPIR_DATE''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''EXPIR_DATE'''
      , i_date         => l_value
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.TRUE)
      , i_editable     => nvl(i_editable, com_api_const_pkg.TRUE)
      , i_data_type    => com_api_const_pkg.DATA_TYPE_DATE
    );

    return l_cursor_stmt;
end;

function get_insurance_year
    return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''GIM_INSURANCE_YEAR''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FRAUD''';
    l_where := l_where || ' and c.column_name = ''INSURANCE_YEAR''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''GIM_INSURANCE_YEAR'''
      , i_mandatory    => com_api_const_pkg.TRUE
      , i_editable     => com_api_const_pkg.TRUE
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_fraud_type
    return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''FRAUD_TYPE''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_FRAUD''';
    l_where := l_where || ' and c.column_name = ''FRAUD_TYPE''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''FRAUD_TYPE'''
      , i_mandatory    => com_api_const_pkg.TRUE
      , i_editable     => com_api_const_pkg.TRUE
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_account_seq_number(
    i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_editable                in            com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''GIM_ACCOUNT_SEQ_NUMBER''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name  = ''CST_BOF_GIM_FRAUD''';
    l_where := l_where || ' and c.column_name = ''ACCOUNT_SEQ_NUMBER''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''GIM_ACCOUNT_SEQ_NUMBER'''
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.TRUE)
      , i_editable     => nvl(i_editable, com_api_const_pkg.TRUE)
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_document_type(
    i_mandatory               in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_editable                in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_value                   in            com_api_type_pkg.t_name       default null
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''GIM_DOCUMENT_TYPE''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_RETRIEVAL''';
    l_where := l_where || ' and c.column_name = ''DOCUMENT_TYPE''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''GIM_DOCUMENT_TYPE'''
      , i_char         => nvl('''' || i_value || '''', com_api_const_pkg.DATA_VARCHAR2_NULL_INIT)
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.FALSE)
      , i_editable     => i_editable
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_card_issuer_ref_num(
    i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_editable                in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_value                   in            com_api_type_pkg.t_name    default null
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''GIM_CARD_ISSUER_REF_NUM''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_RETRIEVAL''';
    l_where := l_where || ' and c.column_name = ''CARD_ISS_REF_NUM''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''GIM_CARD_ISSUER_REF_NUM'''
      , i_char         => nvl('''' || i_value || '''', com_api_const_pkg.DATA_VARCHAR2_NULL_INIT)
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.FALSE)
      , i_editable     => i_editable
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_cancellation_indicator(
    i_mandatory               in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_editable                in            com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_value                   in            com_api_type_pkg.t_name       default null
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''GIM_CANCELLATION_INDICATOR''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from  := l_from  || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_RETRIEVAL''';
    l_where := l_where || ' and c.column_name = ''CANCELLATION_IND''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''GIM_CANCELLATION_INDICATOR'''
      , i_char         => nvl('''' || i_value || '''', com_api_const_pkg.DATA_VARCHAR2_NULL_INIT)
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.TRUE)
      , i_editable     => nvl(i_editable, com_api_const_pkg.TRUE)
      , i_data_type    => com_api_const_pkg.DATA_TYPE_CHAR
    );

    return l_cursor_stmt;
end;

function get_response_type(
    i_mandatory               in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_editable                in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_value                   in            com_api_type_pkg.t_name    default null
) return com_api_type_pkg.t_text
is
    l_cursor_stmt             com_api_type_pkg.t_text;
    l_where                   com_api_type_pkg.t_text;
    l_from                    com_api_type_pkg.t_text;
begin
    l_cursor_stmt := dsp_api_init_pkg.default_statement();

    l_from  := l_from  || ', rul_ui_mod_param_vw r';
    l_where := l_where || ' and r.name = ''GIM_RESPONSE_TYPE''';
    l_where := l_where || ' and r.lang = l.lang';

    l_from := l_from || ', user_tab_columns c';
    l_where := l_where || ' and c.table_name = ''CST_BOF_GIM_RETRIEVAL''';
    l_where := l_where || ' and c.column_name = ''RESPONSE_TYPE''';

    -- Make cursor
    make_cursor_statement(
        io_cursor_stmt => l_cursor_stmt
      , i_from         => l_from
      , i_where        => l_where
      , i_system_name  => '''GIM_RESPONSE_TYPE'''
      , i_number       => nvl(i_value, com_api_const_pkg.DATA_NUMBER_NULL_INIT)
      , i_mandatory    => nvl(i_mandatory, com_api_const_pkg.FALSE)
      , i_editable     => i_editable
      , i_data_type    => com_api_const_pkg.DATA_TYPE_NUMBER
    );

    return l_cursor_stmt;
end;

procedure first_chargeback
is
    l_cursor_stmt           com_api_type_pkg.t_sql_statement;
    l_trans_code            com_api_type_pkg.t_byte_char;
begin
    l_trans_code := dsp_api_shared_data_pkg.get_param_char(i_name => 'TRANSACTION_CODE');

    -- Only for chargeback
    dsp_api_shared_data_pkg.set_param(
        i_name   => 'TRANSACTION_CODE'
      , i_value  => case l_trans_code
                        when cst_bof_gim_api_const_pkg.TC_SALES   then cst_bof_gim_api_const_pkg.TC_SALES_CHARGEBACK
                        when cst_bof_gim_api_const_pkg.TC_VOUCHER then cst_bof_gim_api_const_pkg.TC_VOUCHER_CHARGEBACK
                        when cst_bof_gim_api_const_pkg.TC_CASH    then cst_bof_gim_api_const_pkg.TC_CASH_CHARGEBACK
                    end
    );

    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt()
                  || get_oper_amount(i_editable => com_api_const_pkg.TRUE)    || ' union all '
                  || get_oper_currency(i_editable => com_api_const_pkg.TRUE)  || ' union all '
                  || get_member_msg_text()                                    || ' union all '
                  || get_docum_ind()                                          || ' union all '
                  || get_usage_code(i_mandatory => com_api_const_pkg.TRUE)    || ' union all '
                  || get_reason_code(
                         i_mandatory  => com_api_const_pkg.TRUE
                       , i_lov        => to_char(vis_api_const_pkg.LOV_ID_VIS_FIRST_CHARGEBACK)
                     );

    dsp_api_shared_data_pkg.set_cur_statement(
        i_cur_stat  => l_cursor_stmt
    );
end first_chargeback;

-- Presentment Chargeback Reversal
-- Second Presentment Chargeback Reversal
procedure pres_chargeback_reversal
is
    l_cursor_stmt           com_api_type_pkg.t_sql_statement;
begin
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt()
                  || dsp_api_init_pkg.empty_statement();

    dsp_api_shared_data_pkg.set_cur_statement(
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure second_presentment
is
    l_cursor_stmt           com_api_type_pkg.t_sql_statement;
begin
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt()
                  || get_oper_amount(i_editable => com_api_const_pkg.TRUE)      || ' union all '
                  || get_oper_currency(i_editable => com_api_const_pkg.TRUE)    || ' union all '
                  || get_member_msg_text(i_mandatory => com_api_const_pkg.TRUE) || ' union all '
                  || get_docum_ind(i_mandatory => com_api_const_pkg.TRUE);

    dsp_api_shared_data_pkg.set_cur_statement(
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure second_chargeback
is
    l_cursor_stmt           com_api_type_pkg.t_sql_statement;
begin
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt()
                  || get_oper_amount(i_editable => com_api_const_pkg.TRUE)   || ' union all '
                  || get_oper_currency(i_editable => com_api_const_pkg.TRUE) || ' union all '
                  || get_member_msg_text()                                   || ' union all '
                  || get_docum_ind()                                         || ' union all '
                  || get_usage_code(i_mandatory => com_api_const_pkg.TRUE)   || ' union all '
                  || get_reason_code(
                         i_mandatory  => com_api_const_pkg.TRUE
                       , i_lov        => to_char(vis_api_const_pkg.LOV_ID_VIS_FIRST_CHARGEBACK)
                     );

    dsp_api_shared_data_pkg.set_cur_statement(
        i_cur_stat  => l_cursor_stmt
    );
end second_chargeback;

-- Reversal for second_presentment and second_chargeback
procedure second_presentment_reversal
is
    l_cursor_stmt           com_api_type_pkg.t_sql_statement;
begin
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt()
                  || get_oper_amount(i_editable  => com_api_const_pkg.TRUE)    || ' union all '
                  || get_oper_currency(i_editable  => com_api_const_pkg.FALSE) || ' union all '
                  || get_member_msg_text();

    dsp_api_shared_data_pkg.set_cur_statement(
        i_cur_stat  => l_cursor_stmt
    );
end;

procedure retrieval_request
is
    l_cursor_stmt           com_api_type_pkg.t_sql_statement;
begin
    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt()
                  || get_oper_amount(
                         i_editable  => com_api_const_pkg.TRUE
                     )                                                       || ' union all '
                  || get_oper_currency(
                         i_editable  => com_api_const_pkg.TRUE
                     )                                                       || ' union all '
                  || get_reason_code(
                         i_mandatory => com_api_const_pkg.TRUE
                       , i_lov       => to_char(vis_api_const_pkg.LOV_ID_VIS_RETR_REQ_RSN_CODES)
                     )                                                       || ' union all '
                  || get_document_type(
                         i_editable  => com_api_const_pkg.TRUE
                     )                                                       || ' union all '
                  || get_card_issuer_ref_num(
                         i_value     => '000000000'
                       , i_editable  => com_api_const_pkg.FALSE
                     )                                                       || ' union all '
                  || get_cancellation_indicator(
                         i_value     => 'N'
                       , i_editable  => com_api_const_pkg.FALSE
                     )                                                       || ' union all '
                  || get_response_type(
                         i_value     => '0'
                       , i_editable  => com_api_const_pkg.FALSE
                     )
    ;

    dsp_api_shared_data_pkg.set_cur_statement(
        i_cur_stat  => l_cursor_stmt
    );
end retrieval_request;

procedure fee_collection
is
    l_cursor_stmt           com_api_type_pkg.t_sql_statement;
begin
    dsp_api_shared_data_pkg.set_param(
        i_name   => 'TRANSACTION_CODE'
      , i_value  => cst_bof_gim_api_const_pkg.TC_FEE_COLLECTION
    );

    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt()
                  || get_transaction_code()                       || ' union all '
                  || get_inst_id(
                         i_value_null => com_api_const_pkg.FALSE
                       , i_mandatory  => com_api_const_pkg.FALSE
                       , i_editable   => com_api_const_pkg.TRUE
                     )                                            || ' union all '
                  || get_network_id(
                         i_value_null => com_api_const_pkg.FALSE
                       , i_mandatory  => com_api_const_pkg.FALSE
                       , i_editable   => com_api_const_pkg.TRUE
                     )                                            || ' union all '
                  || get_event_date()                             || ' union all '
                  || get_country_code(
                         i_mandatory  => com_api_const_pkg.FALSE
                     )                                            || ' union all '
                  || get_fee_reason_code(
                         i_mandatory  => com_api_const_pkg.TRUE
                       , i_lov        => '47'
                     )                                            || ' union all '
                  || get_oper_amount(
                         i_editable   => com_api_const_pkg.TRUE
                     )                                            || ' union all '
                  || get_oper_currency(
                         i_editable   => com_api_const_pkg.TRUE
                     )                                            || ' union all '
                  || get_fee_member_msg_text();

    dsp_api_shared_data_pkg.set_cur_statement(
        i_cur_stat  => l_cursor_stmt
    );
end fee_collection;

procedure funds_disbursement
is
    l_cursor_stmt           com_api_type_pkg.t_sql_statement;
begin
    dsp_api_shared_data_pkg.set_param(
        i_name   => 'TRANSACTION_CODE'
      , i_value  => cst_bof_gim_api_const_pkg.TC_FUNDS_DISBURSEMENT
    );

    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt()
                  || get_transaction_code()                       || ' union all '
                  || get_inst_id(
                         i_value_null => com_api_const_pkg.FALSE
                       , i_mandatory  => com_api_const_pkg.FALSE
                       , i_editable   => com_api_const_pkg.FALSE
                     )                                            || ' union all '
                  || get_network_id(
                         i_value_null => com_api_const_pkg.FALSE
                       , i_mandatory  => com_api_const_pkg.FALSE
                       , i_editable   => com_api_const_pkg.FALSE
                     )                                            || ' union all '
                  || get_event_date()                             || ' union all '
                  || get_country_code(
                         i_mandatory  => com_api_const_pkg.FALSE
                     )                                            || ' union all '
                  || get_fee_reason_code(
                         i_mandatory  => com_api_const_pkg.TRUE
                       , i_lov        => '47'
                     )                                            || ' union all '
                  || get_oper_amount(
                         i_editable   => com_api_const_pkg.TRUE
                     )                                            || ' union all '
                  || get_oper_currency(
                         i_editable   => com_api_const_pkg.TRUE
                     )                                            || ' union all '
                  || get_fee_member_msg_text();

    dsp_api_shared_data_pkg.set_cur_statement(
        i_cur_stat  => l_cursor_stmt
    );
end funds_disbursement;

procedure fraud_reporting
is
    l_cursor_stmt           com_api_type_pkg.t_sql_statement;
begin
    dsp_api_shared_data_pkg.set_param(
        i_name   => 'TRANSACTION_CODE'
      , i_value  => cst_bof_gim_api_const_pkg.TC_FRAUD_ADVICE
    );

    l_cursor_stmt := dsp_api_init_pkg.get_header_stmt()
                  || get_oper_amount(
                         i_editable  => com_api_const_pkg.FALSE
                     )                                            || ' union all '
                  || get_oper_currency(
                         i_editable  => com_api_const_pkg.FALSE
                     )                                            || ' union all '
                  || get_notification_code()                      || ' union all '
                  || get_account_seq_number()                     || ' union all '
                  || get_fraud_type()                             || ' union all '
                  || get_card_expir_date()                        || ' union all '
                  || get_insurance_year()                         || ' union all '
                  || get_debit_credit_indicator()                 || ' union all '
                  || get_transaction_gen_nethod();

    dsp_api_shared_data_pkg.set_cur_statement(
        i_cur_stat  => l_cursor_stmt
    );
end fraud_reporting;

end;
/
