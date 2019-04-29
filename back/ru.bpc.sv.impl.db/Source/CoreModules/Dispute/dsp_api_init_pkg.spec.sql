create or replace package dsp_api_init_pkg is

    STMT_SYSTEM_NAME     constant varchar2(100) := '##SYSTEM_NAME##';
    STMT_FORM_NAME       constant varchar2(100) := '##FORM_NAME##';
    STMT_VALUE_NUMBER    constant varchar2(100) := '##VALUE_NUMBER##';
    STMT_VALUE_CHAR      constant varchar2(100) := '##VALUE_CHAR##';
    STMT_VALUE_DATE      constant varchar2(100) := '##VALUE_DATE##';
    STMT_MANDATORY       constant varchar2(100) := '##MANDATORY##';
    STMT_EDITABLE        constant varchar2(100) := '##EDITABLE##';
    STMT_LOV             constant varchar2(100) := '##LOV##';
    STMT_LANG            constant varchar2(100) := '##LANG##';
    STMT_FIELD_TYPE      constant varchar2(100) := '##FIELD_TYPE##';
    STMT_FROM            constant varchar2(100) := '##FROM##';
    STMT_WHERE           constant varchar2(100) := '##WHERE##';
    STMT_DATA_LENGTH     constant varchar2(100) := '##DATA_LENGTH##';

    function get_header_stmt return com_api_type_pkg.t_text;

    function default_statement return com_api_type_pkg.t_text;

    function empty_statement return com_api_type_pkg.t_text;

    procedure init_internal_reversal;

    procedure init_write_off_positive;

    procedure init_write_off_negative;

    procedure init_common_refund;

end;
/
