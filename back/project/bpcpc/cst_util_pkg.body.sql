create or replace package body cst_util_pkg is

function get_sum_str(
    i_data in number
) return varchar2 is
    stmon   varchar2(255);
    st      varchar2(15);
    d1      varchar2(3);
    tr1     varchar2(1);
    tr2     varchar2(1);
    tr3     varchar2(1);
    kop1    varchar2(1);
    kop2    varchar2(1);
begin
    st    := substr((to_char(abs(i_data), '999999999990D00')), 2, 15);
    stmon := '';

    for i in 1 .. 5 loop
        d1 := substr(st, 1, 3);
        st := substr(st, 4, (length(st) - 3));
        tr1 := substr(d1, 1, 1);
        tr2 := substr(d1, 2, 1);
        tr3 := substr(d1, 3, 1);

        if i <> 5 then
            if tr1 = '1' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.hundred', i_lang => 'LANGRUS') || ' ';
            end if;
            if tr1 = '2' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.two_hundred', i_lang => 'LANGRUS') || ' ';
            end if;
            if tr1 = '3' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.three_hundred', i_lang => 'LANGRUS') || ' ';
            end if;
            if tr1 = '4' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.four_hundred', i_lang => 'LANGRUS') || ' ';
            end if;
            if tr1 = '5' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.five_hundred', i_lang => 'LANGRUS') || ' ';
            end if;
            if tr1 = '6' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.six_hundred', i_lang => 'LANGRUS') || ' ';
            end if;
            if tr1 = '7' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.seven_hundred', i_lang => 'LANGRUS') || ' ';
            end if;
            if tr1 = '8' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.eight_hundred', i_lang => 'LANGRUS') || ' ';
            end if;
            if tr1 = '9' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.nine_hundred', i_lang => 'LANGRUS') || ' ';
            end if;

            if tr2 = '1' then
                if tr3 = '0' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.ten', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '1' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.eleven', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '2' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.twelve', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '3' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.thirteen', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '4' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.fourteen', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '5' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.fifteen', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '6' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.sixteen', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '7' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.seventeen', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '8' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.eighteen', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '9' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.nineteen', i_lang => 'LANGRUS') || ' ';
                end if;
            end if;

            if tr2 = '2' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.twenty', i_lang => 'LANGRUS') || ' ';
            end if;
            if tr2 = '3' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.thirty', i_lang => 'LANGRUS') || ' ';
            end if;
            if tr2 = '4' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.forty', i_lang => 'LANGRUS') || ' ';
            end if;
            if tr2 = '5' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.fifty', i_lang => 'LANGRUS') || ' ';
            end if;
            if tr2 = '6' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.sixty', i_lang => 'LANGRUS') || ' ';
            end if;
            if tr2 = '7' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.seventy', i_lang => 'LANGRUS') || ' ';
            end if;
            if tr2 = '8' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.eighty', i_lang => 'LANGRUS') || ' ';
            end if;
            if tr2 = '9' then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.ninety', i_lang => 'LANGRUS') || ' ';
            end if;

            if tr2 != '1' then
                if tr3 = '1' and i != 3 then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.odin', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '1' and i = 3 then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.odna', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '2' and i != 3 then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.dva', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '2' and i = 3 then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.dve', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '3' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.three', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '4' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.four', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '5' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.five', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '6' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.six', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '7' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.seven', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '8' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.eight', i_lang => 'LANGRUS') || ' ';
                end if;
                if tr3 = '9' then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.nine', i_lang => 'LANGRUS') || ' ';
                end if;
            end if;

            if i = 1 then
                if (tr1 = ' ') and (tr2 = ' ') and (tr3 = ' ') then
                    null;
                elsif (tr1 = '0') and (tr2 = '0') and (tr3 = '0') then
                    null;
                elsif (tr3 = '1') and (tr2 != '1') then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.milliard', i_lang => 'LANGRUS') || ' ';
                elsif (tr3 = '2' or tr3 = '3' or tr3 = '4') and (tr2 != '1') then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.milliarda', i_lang => 'LANGRUS') || ' ';
                else
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.milliardov', i_lang => 'LANGRUS') || ' ';
                end if;
            end if;

            if i = 2 then
                if (tr1 = ' ') and (tr2 = ' ') and (tr3 = ' ') then
                    null;
                elsif (tr1 = '0') and (tr2 = '0') and (tr3 = '0') then
                    null;
                elsif (tr3 = '1') and (tr2 != '1') then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.million', i_lang => 'LANGRUS') || ' ';
                elsif (tr3 = '2' or tr3 = '3' or tr3 = '4') and (tr2 != '1') then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.milliona', i_lang => 'LANGRUS') || ' ';
                else
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.millionov', i_lang => 'LANGRUS') || ' ';
                end if;
            end if;

            if i = 3 then
                if (tr1 = ' ') and (tr2 = ' ') and (tr3 = ' ') then
                    null;
                elsif (tr1 = '0') and (tr2 = '0') and (tr3 = '0') then
                    null;
                elsif (tr3 = '1') and (tr2 <> '1') then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.thousand', i_lang => 'LANGRUS') || ' ';
                elsif (tr3 = '2' or tr3 = '3' or tr3 = '4') and (tr2 <> '1') then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.tysyachi', i_lang => 'LANGRUS') || ' ';
                else
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.tysyach', i_lang => 'LANGRUS') || ' ';
                end if;
            end if;

            if i = 4 then
                if (tr1 = ' ') and (tr2 = ' ') and (tr3 = ' ') then
                    null;
                elsif (tr3 = '1') and (tr2 != '1') then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.ruble', i_lang => 'LANGRUS') || ' ';
                elsif (tr3 = '2' or tr3 = '3' or tr3 = '4') and (tr2 != '1') then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.rublya', i_lang => 'LANGRUS') || ' ';
                elsif (tr1 = ' ') and (tr2 = ' ') and (tr3 = '0') then
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.nol_rublei', i_lang => 'LANGRUS') || ' ';
                else
                    stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.rublei', i_lang => 'LANGRUS') || ' ';
                end if;
            end if;
        end if;

        if i = 5 then
            kop1 := substr(d1, 2, 1);
            kop2 := substr(d1, 3, 1);
            stmon := stmon || kop1 || kop2 || ' ';

            if (kop2 = '1') and (kop1 != '1') then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.kopeika', i_lang => 'LANGRUS') || ' ';
            elsif (kop2 = '2' or kop2 = '3' or kop2 = '4') and (kop1 != '1') then
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.kopeiki', i_lang => 'LANGRUS') || ' ';
            else
                stmon := stmon || com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.kopeek', i_lang => 'LANGRUS') || ' ';
            end if;
        end if;
    end loop;

    return(stmon);
end get_sum_str;

function get_formated_date(
    i_date in date default sysdate
) return varchar2 is
    l_date com_api_type_pkg.t_original_data;
begin
    l_date := to_char(i_date, 'dd');
    l_date := l_date || ' ' || case to_char(i_date, 'mm')
                                    when 1 then com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.yanvarya', i_lang => 'LANGRUS')
                                    when 2 then com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.fevralya', i_lang => 'LANGRUS')
                                    when 3 then com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.marta', i_lang => 'LANGRUS')
                                    when 4 then com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.aprelya', i_lang => 'LANGRUS')
                                    when 5 then com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.maya', i_lang => 'LANGRUS')
                                    when 6 then com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.iyunya', i_lang => 'LANGRUS')
                                    when 7 then com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.iyulya', i_lang => 'LANGRUS')
                                    when 8 then com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.avgusta', i_lang => 'LANGRUS')
                                    when 9 then com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.sentyabrya', i_lang => 'LANGRUS')
                                    when 10 then com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.oktyabrya', i_lang => 'LANGRUS')
                                    when 11 then com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.noyabrya', i_lang => 'LANGRUS')
                                    when 12 then com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.dekabrya', i_lang => 'LANGRUS')
                               end;
    l_date := l_date || ' ' || to_char(i_date, 'yyyy');

    return l_date;
end get_formated_date;

function is_custom(
    i_oper_id in com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean is
    l_return com_api_type_pkg.t_boolean;
begin
    begin
        select com_api_const_pkg.TRUE
          into l_return
          from aup_tag_value atv
         where atv.auth_id = i_oper_id
           and substr(atv.tag_value, 1, 3) = '048'
           and substr(atv.tag_value, 7, 3) = '002'
           and substr(atv.tag_value, 13, 3) in ('532', '552')
           and rownum = 1;
    exception
        when no_data_found then
            l_return := com_api_const_pkg.FALSE;
    end;

    return l_return;
end is_custom;

function is_nonfinancial(
    i_oper_type in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean is
    l_return com_api_type_pkg.t_boolean;
begin
    if i_oper_type = opr_api_const_pkg.OPERATION_TYPE_CUSTOMER_CHECK then
        l_return := com_api_const_pkg.TRUE;
    else
        l_return := com_api_const_pkg.FALSE;
    end if;

    return l_return;
end is_nonfinancial;

    -- Cyberplat operation 
function is_cyberplat(
    i_oper_id in    com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean is
    l_return com_api_type_pkg.t_boolean;
begin
    begin
        select com_api_const_pkg.TRUE
          into l_return
          from aup_cyberplat c
         where c.auth_id = i_oper_id
           and rownum    = 1;
    exception
        when no_data_found then
            l_return := com_api_const_pkg.FALSE;
    end;

    return l_return;
end is_cyberplat;

-- is tag exists
function is_tag_exists(
    i_oper_id in    com_api_type_pkg.t_long_id
  , i_tag_id  in    com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean is
    l_return com_api_type_pkg.t_boolean;
begin
    begin
        select com_api_const_pkg.TRUE
          into l_return
          from aup_tag_value atv
         where atv.auth_id = i_oper_id
           and atv.tag_id = i_tag_id
           and atv.tag_value is not null
           and rownum = 1;
    exception
        when no_data_found then
            l_return := com_api_const_pkg.FALSE;
    end;

    return l_return;
end is_tag_exists;

function is_nspk(
    i_oper_id in com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean is
    l_return com_api_type_pkg.t_boolean;
begin
    select max(case when opa.oper_id is not null or opi.oper_id is not null or a.auth_id is not null then 1
                    else 0
               end) is_nspk
      into l_return
      from opr_operation o
      left join opr_participant opa on opa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                                   and opa.oper_id = o.id and opa.inst_id in (9008, 9009, 9948, 9949, 9959) -- nspk acq1
      left join opr_participant opi on opi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                                   and opi.oper_id = o.id and opi.inst_id in (9008, 9009, 9948, 9949, 9959) -- nspk iss1
      left join opr_participant opa2 on opa2.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                                    and opa2.oper_id = o.id and opa2.inst_id = 9947 -- nspk iss2
      left join aup_way4 a on a.auth_id = opa2.oper_id and a.txn_src_channel = 'W'
     where o.id = i_oper_id;

    return l_return;
end is_nspk;

function get_next_file_number(
    i_inst_id   in com_api_type_pkg.t_inst_id
  , i_file_type in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_tiny_id is
    l_return com_api_type_pkg.t_tiny_id;
begin
    select count(1) + 1 as count_files
      into l_return
      from prc_session_file sf
      join prc_session s on s.id = sf.session_id
     where sf.file_type = i_file_type
       and inst_id = i_inst_id
       and sf.id between com_api_id_pkg.get_from_id(sysdate) and com_api_id_pkg.get_till_id(sysdate);

    return l_return;
end get_next_file_number;

end cst_util_pkg;
/
