create or replace package body rul_mod_gen_pkg as
/*********************************************************
 *  package for modifiers static package generation  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 07.09.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: rul_mod_gen_pkg  <br />
 *  @headcom
 **********************************************************/

CRLF                         constant com_api_type_pkg.t_oracle_name := chr(10);

PACKAGE_MAX_INDEX            constant com_api_type_pkg.t_count :=
    floor(9999 / rul_api_const_pkg.CAPACITY_OF_MOD_STATIC_PKG) + 1;

PACKAGE_INDEX_LENGTH         constant com_api_type_pkg.t_count := length(to_char(PACKAGE_MAX_INDEX));

TEMPLATE_PACKAGE_NAME        constant com_api_type_pkg.t_text :=
    'rul_mod_static<PACKAGE_NUMBER>_pkg';

TEMPLATE_SPEC_HEADER         constant com_api_type_pkg.t_text :=
'create or replace package '      || TEMPLATE_PACKAGE_NAME || ' as
';
TEMPLATE_BODY_HEADER         constant com_api_type_pkg.t_text :=
'create or replace package body ' || TEMPLATE_PACKAGE_NAME || ' as
';
TEMPLATE_WHEN_CLAUSE         constant com_api_type_pkg.t_text :=
'            when <MOD_ID> then l_result := '
|| TEMPLATE_PACKAGE_NAME || '.check_mod_<MOD_NUMBER>(i_params);';

TEMPLATE_FUNCTION_SIGNATURE  constant com_api_type_pkg.t_text :=
--'
--function check_mod_<MOD_NUMBER>(
--    i_params            in      com_api_type_pkg.t_param_tab
--) return com_api_type_pkg.t_boolean;';
'function check_mod_<MOD_NUMBER>(i_params in com_api_type_pkg.t_param_tab) ' ||
'return com_api_type_pkg.t_boolean;
';
TEMPLATE_WRAPPER_BODY_PART1  constant clob :=
'
function check_condition(
    i_mod_id            in     com_api_type_pkg.t_tiny_id
  , i_params            in     com_api_type_pkg.t_param_tab
) return com_api_type_pkg.t_boolean
is
    l_result            com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text       => ''checking modifier [#1]''
      , i_env_param1 => i_mod_id
    );

    if i_mod_id is null then
        l_result := com_api_const_pkg.TRUE;
    else
        case i_mod_id
            when    -1 then l_result := null; -- fake condition to validate package if no modifiers
'
;
TEMPLATE_WRAPPER_BODY_PART2  constant clob :=
'        else
            com_api_error_pkg.raise_error(
                i_error      => ''MODIFIER_NOT_FOUND''
              , i_env_param1 => i_mod_id
            );
        end case;
    end if;

    trc_log_pkg.debug(
        i_text       => ''checked modifier [#1], result is [#2]''
      , i_env_param1 => i_mod_id
      , i_env_param2 => l_result
    );

    return l_result;
end;'
;
TEMPLATE_PACKAGE_TRAILER     constant com_api_type_pkg.t_text := 'end;' || CRLF;

TEMPLATE_FUNCTION_BODY       constant com_api_type_pkg.t_text :=
'function check_mod_<MOD_NUMBER>(
    i_params            in      com_api_type_pkg.t_param_tab
) return com_api_type_pkg.t_boolean is
<PARAM_LIST>
    l_result            com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
<PARAM_LIST_VALUE>
    if <MOD_CONDITION> then
        l_result := com_api_const_pkg.TRUE;
    end if;
    return l_result;
end;
';

procedure nop is
begin
    null;
end;

function get_pkg_index(
    i_mod_id                in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_count is
begin
    return case
               when i_mod_id < 0
               then ceil(i_mod_id / rul_api_const_pkg.CAPACITY_OF_MOD_STATIC_PKG) - 1
               else floor(i_mod_id / rul_api_const_pkg.CAPACITY_OF_MOD_STATIC_PKG) + 1
           end;
end;

/*
 * Procedure generates/recompiles packages <rul_mod_static_pkg> and <rul_mod_static_XXX_pkg>.
 * Package <rul_mod_static_pkg> is a wrapper, it doesn't contain functions for modifier checks.
 * All checks are divided into packages <rul_mod_static_XXX_pkg>, and every single package contains
 * no more than <rul_api_const_pkg.CAPACITY_OF_MOD_STATIC_PKG> checks.
 * @i_mod_id          - if some modifier is specified then only one package will be (re)compiled,
 *                      its number is uniquely defined by a value of this paremeter;
 *                      (e.g. if CAPACITY_OF_MOD_STATIC_PKG = 100 and i_mod_id = 765 then XXX =
  *                      765 div 100 + 1 = 8, package rul_mod_static_008_pkg will be (re)compiled.)
 * @i_is_modification - the flag is TRUE if modifier <i_mod_id> has been changed (not added or
 *                      removed), in this case there is no need to recompile <rul_mod_static_pkg>.
 */
procedure generate_package(
    i_mod_id                in     com_api_type_pkg.t_tiny_id    default null
  , i_is_modification       in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.generate_package';
    l_package_spec_tab      com_api_type_pkg.t_clob_tab;
    l_package_body_tab      com_api_type_pkg.t_clob_tab;
    l_package_body_wrapper  clob;
    l_package_index         com_api_type_pkg.t_count := 0;
    l_changing_pkg_index    com_api_type_pkg.t_count := 0; -- index of the package that should be recomplied
    l_package_number        com_api_type_pkg.t_text;
    l_param_list            clob;
    l_param_list_value      clob;
    l_mod_condition         clob;
    l_mod_number            com_api_type_pkg.t_text;
    l_param_name            clob;
    l_data_type             clob;
begin
    l_package_body_wrapper := empty_clob(); -- body of package-wrapper
    l_changing_pkg_index  := case
                                 when i_mod_id is null
                                 then 0
                                 else get_pkg_index(
                                          i_mod_id => i_mod_id
                                      )
                             end;
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' START: i_mod_id [#1], i_is_modification [#2], l_changing_pkg_index [#3]'
      , i_env_param1 => i_mod_id
      , i_env_param2 => i_is_modification
      , i_env_param3 => l_changing_pkg_index
    );

    for r in (
        select id
             , condition
             , scale_id
          from rul_mod
      order by scale_id
             , priority
    ) loop
        l_package_index := 
            get_pkg_index(
                i_mod_id => r.id
            );

        if l_package_index < 0 then
            l_package_number   := '_n' || lpad(abs(l_package_index), PACKAGE_INDEX_LENGTH, '0');
            l_mod_number       := 'n' || lpad(abs(r.id), 4, '0');
        else
            l_package_number   := '_' || lpad(l_package_index, PACKAGE_INDEX_LENGTH, '0');
            l_mod_number       := lpad(r.id, 4, '0');
        end if;
        
        l_mod_condition    := r.condition;

        l_param_list       := null;
        l_param_list_value := null;

        if l_changing_pkg_index in (0, l_package_index) then
            for q in (
                select p.name
                     , p.data_type
                  from rul_mod_param p
                     , rul_mod_scale_param s
                 where s.param_id = p.id
                   and s.scale_id = r.scale_id
                   and regexp_like(l_mod_condition, ':' || p.name || '(\W|$)')
                 union all
                select distinct
                       f.name
                     , f.data_type
                  from com_flexible_field f
                     , com_flexible_field_usage u
                 where f.id = u.field_id
                   and regexp_like(l_mod_condition, ':' || f.name || '(\W|$)')                 
            ) loop
                l_data_type :=
                    case q.data_type
                        when com_api_const_pkg.DATA_TYPE_NUMBER then 'number'
                        when com_api_const_pkg.DATA_TYPE_DATE   then 'date'
                                                                else 'varchar2(200)'
                    end;
                l_param_name := 'l_' || lower(q.name);
                l_param_list := l_param_list
                             || '    ' || l_param_name || ' ' || l_data_type || ';' || CRLF;
                l_param_list_value := l_param_list_value || '    '
                    || l_param_name
                    || case q.data_type
                           when com_api_const_pkg.DATA_TYPE_NUMBER then ' := rul_api_param_pkg.get_param_num('''
                           when com_api_const_pkg.DATA_TYPE_DATE   then ' := rul_api_param_pkg.get_param_date('''
                                                                   else ' := rul_api_param_pkg.get_param_char('''
                       end
                    || q.name ||''', i_params, com_api_type_pkg.TRUE);'
                    || CRLF;
                l_mod_condition := replace(l_mod_condition, ':' || q.name, l_param_name);
            end loop;

            if not l_package_body_tab.exists(l_package_index) then
                l_package_spec_tab(l_package_index) :=
                    replace(TEMPLATE_SPEC_HEADER, '<PACKAGE_NUMBER>', l_package_number) || CRLF;
                l_package_body_tab(l_package_index) :=
                    replace(TEMPLATE_BODY_HEADER, '<PACKAGE_NUMBER>', l_package_number) || CRLF;
            end if;

            l_package_spec_tab(l_package_index) := l_package_spec_tab(l_package_index)
                || replace(TEMPLATE_FUNCTION_SIGNATURE, '<MOD_NUMBER>', l_mod_number)
                || CRLF;
            l_package_body_tab(l_package_index) := l_package_body_tab(l_package_index)
                || replace(
                       replace(
                           replace(
                               replace(TEMPLATE_FUNCTION_BODY, '<MOD_NUMBER>', l_mod_number)
                             , '<PARAM_LIST>'
                             , rtrim(l_param_list, CRLF)
                           )
                         , '<PARAM_LIST_VALUE>'
                         , rtrim(l_param_list_value, CRLF)
                       )
                     , '<MOD_CONDITION>'
                     , l_mod_condition
                   )
                || CRLF;
        end if;

        -- It is not required to recompile wrapper-package on changing modifier condition
        if i_is_modification = com_api_const_pkg.FALSE then
            l_package_body_wrapper := l_package_body_wrapper
                                   || replace(
                                          replace(
                                              replace(
                                                  TEMPLATE_WHEN_CLAUSE
                                                , '<MOD_ID>'
                                                , lpad(to_char(r.id), 5, ' ') -- 5 = 4 digits + sign
                                              )
                                            , '<MOD_NUMBER>', l_mod_number
                                          )
                                        , '<PACKAGE_NUMBER>', l_package_number
                                      )
                                   || CRLF;
        end if;
    end loop;

    -- Recompile all packages with checks or affected one only
    if l_package_body_tab.count > 0 then
        for i in l_package_body_tab.first .. l_package_body_tab.last loop
            if l_package_body_tab.exists(i) then
                trc_log_pkg.debug('compiling package with index = ' || i);
                execute immediate l_package_spec_tab(i) || TEMPLATE_PACKAGE_TRAILER;
                execute immediate l_package_body_tab(i) || TEMPLATE_PACKAGE_TRAILER;
            end if;
        end loop;
    end if;

    if i_is_modification = com_api_const_pkg.FALSE then
        trc_log_pkg.debug('compiling wrapper...');
        execute immediate replace(TEMPLATE_BODY_HEADER, '<PACKAGE_NUMBER>')
                       || TEMPLATE_WRAPPER_BODY_PART1
                       || l_package_body_wrapper
                       || TEMPLATE_WRAPPER_BODY_PART2
                       || CRLF || CRLF
                       || TEMPLATE_PACKAGE_TRAILER;
    end if;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ': FINISH'
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || ' FAILED: '
                   ||    'l_package_index [' || l_package_index
                   || '], l_package_number [' || l_package_number
                   || '], l_mod_number [' || l_mod_number
                   || '], l_mod_condition [' || l_mod_condition
                   || '], l_package_spec_tab.count [' || l_package_spec_tab.count()
                   || '], l_package_body_tab.count [' || l_package_body_tab.count() || ']'
        );
        raise;
end;

end;
/
