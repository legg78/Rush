create or replace package body way_prc_incoming_pkg as
/*********************************************************
 *  WAY4 XML incoming files API  <br />
 *  Created by Dolgikh D.(dolgikh@bpcbt.com)  at 11.07.2016 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: vis_api_incoming_pkg <br />
 *  @headcom
 **********************************************************/

type t_amount_count_tab is table of integer index by com_api_type_pkg.t_curr_code;

VISA_NETWORK         constant    com_api_type_pkg.t_network_id   := 1003;
MC_NETWORK           constant    com_api_type_pkg.t_network_id   := 1002;
VISA_NETWORK_INST    constant    com_api_type_pkg.t_network_id   := 9002;
MC_NETWORK_INST      constant    com_api_type_pkg.t_network_id   := 9001;
WAY4_CMID            constant    com_api_type_pkg.t_name         := 'ACQ_BIN';
WAY4_H2H_STANDARD    constant    com_api_type_pkg.t_tiny_id      := 1007;

g_amount_tab          t_amount_count_tab;

type t_no_original_rec_rec is record (
    i_mes_rec               mcw_api_type_pkg.t_mes_rec
    , i_file_id             com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  com_api_type_pkg.t_long_id
    , i_network_id          com_api_type_pkg.t_tiny_id
    , i_host_id             com_api_type_pkg.t_tiny_id
    , i_standard_id         com_api_type_pkg.t_tiny_id
    , i_local_message       com_api_type_pkg.t_boolean
    , i_create_operation    com_api_type_pkg.t_boolean
    , i_mes_rec_prev        mcw_api_type_pkg.t_mes_rec
    , io_fin_ref_id         com_api_type_pkg.t_long_id
);

type t_no_original_rec_tab is table of t_no_original_rec_rec index by binary_integer;
g_no_original_rec_tab t_no_original_rec_tab;

subtype t_de_rec is mcw_de%rowtype;
type t_de_tab is table of t_de_rec index by binary_integer;

g_de t_de_tab;

MCC_CASH            constant         com_api_type_pkg.t_mcc          := '6010';
MCC_ATM             constant         com_api_type_pkg.t_mcc          := '6011';

g_processing_date   date   := null;
g_filedate          date   := null;
g_error_flag        com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
g_errors_count      com_api_type_pkg.t_long_id := 0;

subtype t_arn       is varchar2(23);
subtype t_doc_ref   is varchar2(32);
subtype t_cps       is com_api_type_pkg.t_text;
subtype t_de22      is varchar2(12);

subtype t_way_file is way_file%rowtype;
--l_way_file t_way_file;

cursor cu_xml_file_trailer (i_session_file_id number) is
    with xml_file as
        (
         select f.file_xml_contents xml_content from prc_session_file f where f.id = i_session_file_id   -- -1
        )
    select way4_set.*
       from xml_file s
          , xmltable('DocFile/FileTrailer'
               passing s.xml_content
               columns rec_count    number path 'CheckSum/RecsCount'
                     , total_amount number path 'CheckSum/HashTotalAmount'
             ) way4_set;

subtype t_xml_file_trailer is cu_xml_file_trailer%rowtype;
l_xml_file_trailer t_xml_file_trailer;

cursor cu_xml_file_header (i_session_file_id number) is
    with xml_file as
        (
         select f.file_xml_contents xml_content from prc_session_file f where f.id = i_session_file_id   -- -1
        )
    select way4_set.*
       from xml_file s
          , xmltable('DocFile/FileHeader'
               passing s.xml_content
               columns file_label        varchar2 (32)   path 'FileLabel'
                     , format_version    varchar2 (10)   path 'FormatVersion'
                     , sender            varchar2 (32)   path 'Sender'
                     , creation_date     varchar2 (20)   path 'CreationDate'
                     , creation_time     varchar2 (20)   path 'CreationTime'
                     , file_seq_number   number   (10)   path 'FileSeqNumber'
                     , receiver          varchar2 (32)   path 'Receiver'
             ) way4_set;

subtype t_xml_file_header is cu_xml_file_header%rowtype;
l_xml_file_header t_xml_file_header;

cursor cu_xml_records (i_session_file_id number) is
    with xml_file as
        (
         select f.file_xml_contents xml_content from prc_session_file f where f.id = i_session_file_id   -- -1
        )
    select way4_set.*
       from xml_file s
          , xmltable('DocFile/DocList/Doc'
               passing s.xml_content
               columns msg_code          varchar2 (32)   path 'TransType/TransCode/MsgCode'
                     , trans_condition   varchar2 (4000) path 'TransType/TransCondition'
                     , trans_reason_code varchar2 (4000) path 'TransType/DisputeRules/ReasonCode'
                     , doc_ref_set       xmltype         path 'DocRefSet/Parm'
                     , local_date        varchar2 (20)   path 'LocalDt'
                     , nw_date           varchar2 (20)   path 'NWDt'
                     , src_sic           number   (4)    path 'SourceDtls/SIC'
                     , src_country       varchar2 (3)    path 'SourceDtls/Country'
                     , src_state         varchar2 (32)   path 'SourceDtls/State'
                     , src_city          varchar2 (32)   path 'SourceDtls/City'
                     , src_merchant_id   varchar2 (32)   path 'SourceDtls/MerchantID'
                     , src_location      varchar2 (40)   path 'SourceDtls/Location'
                     , src_merch_name    varchar2 (40)   path 'SourceDtls/MerchantName'
                     , src_postal_code   varchar2 (10)   path 'SourceDtls/PostalCode'
                     , org_contract_num  varchar2 (64)   path 'Originator/ContractNumber'
                     , org_relation      varchar2 (32)   path 'Originator/Relation'
                     , org_member_id     varchar2 (32)   path 'Originator/MemberId'
                     , org_channel       varchar2 (32)   path 'Originator/Product/Channel'
                     , org_transit_id    varchar2 (32)   path 'Originator/TransitId'
                     , dst_contract_num  varchar2 (64)   path 'Destination/ContractNumber'
                     , dst_relation      varchar2 (32)   path 'Destination/Relation'
                     , dst_member_id     varchar2 (32)   path 'Destination/MemberId'
                     , dst_card_expiry   varchar2 (4)    path 'Destination/CardInfo/CardExpiry'
                     , dst_card_seq      varchar2 (4)    path 'Destination/CardInfo/CardSeqN'
                     , dst_channel       varchar2 (32)   path 'Destination/Product/Channel'
                     , dst_transit_id    varchar2 (32)   path 'Destination/TransitId'
                     , trn_currency      number   (3)    path 'Transaction/Currency'
                     , trn_amount        number          path 'Transaction/Amount'
                     , trn_add_data      xmltype         path 'Transaction/Extra/AddData/Parm'
                     , trn_extra         xmltype         path 'Transaction/Extra'
                     , bln_phaseDate     varchar2 (20)   path 'Billing/PhaseDate'
                     , bln_currency      number   (3)    path 'Billing/Currency'
                     , bln_amount        number          path 'Billing/Amount'
                     , rcn_phase_date    varchar2 (20)   path 'Reconciliation/PhaseDate'
                     , rcn_currency      number   (3)    path 'Reconciliation/Currency'
                     , rcn_amount        number          path 'Reconciliation/Amount'
                     , add_iso8583_f55   xmltype         path 'Addendum/Info/ISO8583/F55/Tag'
                     , addendum          xmltype         path 'Addendum'
             ) way4_set;

subtype t_xml_record is cu_xml_records%rowtype;
l_xml_record t_xml_record;

function get_inst_id_by_proc_bin(
    i_proc_bin              in      com_api_type_pkg.t_name
  , i_network_id            in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_inst_id is
    l_proc_bin              com_api_type_pkg.t_name;
    l_result                com_api_type_pkg.t_inst_id;
    l_param_tab             com_api_type_pkg.t_param_tab;
begin
    for r in (
        select m.inst_id
             , i.host_member_id host_id
          from net_interface i
             , net_member m
         where m.network_id = i_network_id
           and m.id         = i.consumer_member_id
    ) loop
        begin
            cmn_api_standard_pkg.get_param_value(
                i_inst_id      => r.inst_id
              , i_standard_id  => WAY4_H2H_STANDARD                   --vis_api_const_pkg.VISA_BASEII_STANDARD
              , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST  -- net_api_const_pkg.ENTITY_TYPE_INTERFACE
              , i_object_id    => r.host_id
              , i_param_name   => WAY4_CMID                           --vis_api_const_pkg.CMID
              , o_param_value  => l_proc_bin
              , i_param_tab    => l_param_tab
            );
        exception
            when com_api_error_pkg.e_application_error then
                null;
        end;

        if trim(l_proc_bin) = trim(i_proc_bin) then
            l_result :=  r.inst_id;
            exit;
        end if;

    end loop;

    return l_result;
end;

--Getting BASE II Device (POS terminal) Capability
function get_baseII_terminal_cap(
    i_trans_condition in com_api_type_pkg.t_text
) return com_api_type_pkg.t_dict_value is
    l_cap com_api_type_pkg.t_dict_value;
begin

    if    instr(i_trans_condition, 'TERM_CHIP') > 0
    then l_cap := '5';
    elsif instr(i_trans_condition, 'TERM_TRACK') > 0
    then l_cap := '2';
    elsif instr(i_trans_condition, 'TERM_OCR') > 0
    then l_cap := '4';
    elsif instr(i_trans_condition, 'TERM_BAR') > 0
    then l_cap := '3';
    elsif instr(i_trans_condition, 'TERM_CHIP_CTLS') > 0
    then l_cap := '8';
    elsif instr(i_trans_condition, 'TERM_KEY_ENTRY') > 0  -- 6
    then l_cap := '6';
    elsif instr(i_trans_condition, 'NO_TERM') > 0
    then l_cap := '1';
    else l_cap := '0';
    end if;

    return l_cap;
end get_baseII_terminal_cap;

--Get total count of operations (docs) in all session files
procedure calculate_de22_subfields (
    i_trans_condition in  com_api_type_pkg.t_text
    , o_mc_fin_rec    out mcw_api_type_pkg.t_mes_rec --mcw_api_type_pkg.t_fin_rec --
) is
    l_cond com_api_type_pkg.t_dict_value;
    procedure correct_de22s is
    begin
        if o_mc_fin_rec.de022_3 in ('2') then
            o_mc_fin_rec.de022_3 := '9';
        end if;

        -- correct fe pos modes accordingly to MC specs
        if o_mc_fin_rec.de022_1 = '7' then
            o_mc_fin_rec.de022_1 := 'B';
        elsif o_mc_fin_rec.de022_1 = '5' then
            o_mc_fin_rec.de022_1 := 'D';
        end if;

        if o_mc_fin_rec.de022_7 in ('U', 'V') then
            o_mc_fin_rec.de022_7 := 'S';
        elsif o_mc_fin_rec.de022_7 in ('S', 'T') then
            o_mc_fin_rec.de022_7 := 'S';
            --o_mc_fin_rec.p0023 := 'CT6';
        elsif o_mc_fin_rec.de022_7 in ('5', '7', '9') then
            o_mc_fin_rec.de022_7 := 'S';
        elsif o_mc_fin_rec.de022_7 in ('8') then
            o_mc_fin_rec.de022_7 := 'A';
        elsif o_mc_fin_rec.de022_7 = 'F' and o_mc_fin_rec.de038 is not null then
            o_mc_fin_rec.de022_7 := 'C'; -- Online Chip
        elsif o_mc_fin_rec.de022_7 in ('P', 'N') then
            o_mc_fin_rec.de022_7 := 'A';
        elsif o_mc_fin_rec.de022_7 in ('W') then
            o_mc_fin_rec.de022_7 := 'T';
        elsif o_mc_fin_rec.de022_7 in ('3') then
            o_mc_fin_rec.de022_7 := '0'; -- Unspecified; data unavailable
        elsif o_mc_fin_rec.de022_7 in ('O') then
            o_mc_fin_rec.de022_7 := 'R';
        end if;

       -- if o_mc_fin_rec.de022_7 = 'S' then
       --     null; --o_mc_fin_rec.p0023 := 'CT6';
       -- end if;

        if o_mc_fin_rec.de022_4 = 'S' then
            o_mc_fin_rec.de022_4 := '9';
            --o_mc_fin_rec.p0023   := 'CT1';
        elsif o_mc_fin_rec.de022_4 = 'T' then
            o_mc_fin_rec.de022_4 := '9';
            --o_mc_fin_rec.p0023   := 'CT2';
        elsif o_mc_fin_rec.de022_4 = 'U' then
            o_mc_fin_rec.de022_4 := '9';
            --o_mc_fin_rec.p0023   := 'CT3';
        elsif o_mc_fin_rec.de022_4 = 'V' then
            o_mc_fin_rec.de022_4 := '9';
            --o_mc_fin_rec.p0023   := 'CT4';
        elsif o_mc_fin_rec.de022_4 = 'X' then
            o_mc_fin_rec.de022_4 := '5';
        elsif o_mc_fin_rec.de022_4 = 'A' then
            o_mc_fin_rec.de022_4 := '1';
        elsif o_mc_fin_rec.de022_4 = 'B' then
            o_mc_fin_rec.de022_4 := '2';
        end if;
    end correct_de22s;
begin
    --DBMS_OUTPUT.PUT_LINE ('inside map_way_message_to_mc #4_0: o_mti = ' || o_mc_fin_rec.mti || '; o_de024 = ' || o_mc_fin_rec.de024);

    o_mc_fin_rec.de022_1 := get_baseII_terminal_cap(i_trans_condition); --substr(i_auth_rec.card_data_input_cap, -1);
    /*
    CARD_DATA_INPUT_CAP,CONDITION_VALUE
    F2210000,NO_TERM
    F2210001,NO_TERM
    F2210003,TERM_BAR
    F2210005,TERM_CHIP
    F221000C,TERM_CHIP
    F221000D,TERM_CHIP
    F221000E,TERM_CHIP
    F221000M,TERM_CHIP
    F2210006,TERM_KEY_ENTRY
    F2210002,TERM_TRACK
    F221000A,TERM_TRACK
    F221000B,TERM_TRACK
    */
    o_mc_fin_rec.de022_2 := '0'; --??? no mapping rules delivered --substr(i_auth_rec.crdh_auth_cap, -1);
    o_mc_fin_rec.de022_3 := '0'; --??? no mapping rules delivered --substr(i_auth_rec.card_capture_cap, -1);
    o_mc_fin_rec.de022_4 :=
        case
            when instr(i_trans_condition, 'NO_TERM') > 0 then '0'
            when instr(i_trans_condition, 'TERM') > 0 then '1'
            when instr(i_trans_condition, 'TERM_UNATT') > 0 then 'B'
            else '9'
        end; --substr(i_auth_rec.terminal_operating_env, -1);
    o_mc_fin_rec.de022_5 :=
        case
            when instr(i_trans_condition, 'CARDHOLDER') > 0 then '0'
            when instr(i_trans_condition, 'MAIL') > 0 then '2'
            when instr(i_trans_condition, 'MNET') > 0 then '5'
            when instr(i_trans_condition, 'NO_CARDHOLDER') > 0 then '1'
            when instr(i_trans_condition, 'PHONE') > 0 then '3'
            when instr(i_trans_condition, 'RECURRING') > 0 then '4'
            else '9'
        end; --substr(i_auth_rec.crdh_presence, -1);
    o_mc_fin_rec.de022_6 :=
        case
            when instr(i_trans_condition, 'CARD') > 0 then '1'
            when instr(i_trans_condition, 'NO_CARD') > 0 then '0'
            else '9'
        end; --substr(i_auth_rec.card_presence, -1)
    o_mc_fin_rec.de022_7 :=
        case
            when instr(i_trans_condition, 'DATA_CHIP')  > 0 then 'C'
            when instr(i_trans_condition, 'READ_CHIP')  > 0 then 'F'
            when instr(i_trans_condition, 'DATA_TRACK') > 0 then 'B'
            when instr(i_trans_condition, 'READ_TRACK') > 0 then 'A'
            when instr(i_trans_condition, '') > 0 then ''
            else '0'
        end; --substr(i_auth_rec.card_data_input_mode, -1)
        /*
        F227000C,READ_CHIP
        F227000M,READ_CHIP
        F227000N,READ_CHIP
        F227000B,READ_TRACK
        */
        o_mc_fin_rec.de022_8 :=
            case
                when instr(i_trans_condition, 'AUTHENTICATED')  > 0 then '1'
                when instr(i_trans_condition, 'NO_AUTH')  > 0 then '0'
                when instr(i_trans_condition, 'PBT') > 0 then '1'
                when instr(i_trans_condition, 'SBT_ELV') > 0 then '2'
                when instr(i_trans_condition, 'SBT_MAN') > 0 then '6'
                when instr(i_trans_condition, 'TRANS_AUTH') > 0 then '1'
                else '9'
            end; --substr(i_auth_rec.crdh_auth_method, -1);
        /*
        CRDH_AUTH_METHOD,CONDITION_VALUE
        F2280002,AUTHENTICATED
        F2280005,AUTHENTICATED
        F2280006,AUTHENTICATED
        F228000S,AUTHENTICATED
        F2280002,TRANS_AUTH
        F2280005,TRANS_AUTH
        F2280006,TRANS_AUTH
        F228000S,TRANS_AUTH
        */
        o_mc_fin_rec.de022_9 := '0'; --??? no mapping rules delivered --substr(i_auth_rec.crdh_auth_entity, -1);
        o_mc_fin_rec.de022_10 :=
            case
                when instr(i_trans_condition, 'CARD_CHIP')  > 0 then '3'
                when instr(i_trans_condition, 'CARD_TRACK')  > 0 then '2'
                else '0'
            end; --substr(i_auth_rec.card_data_output_cap, -1);
        o_mc_fin_rec.de022_11 := '0'; --??? no mapping rules delivered --substr(i_auth_rec.terminal_output_cap, -1);
        o_mc_fin_rec.de022_12 := '0'; --??? no mapping rules delivered --substr(i_auth_rec.pin_capture_cap, -1);

        correct_de22s;

        --DBMS_OUTPUT.PUT_LINE ('inside map_way_message_to_mc #5_1: o_mti = ' || o_mc_fin_rec.mti || '; o_de024 = ' || o_mc_fin_rec.de024);
end calculate_de22_subfields;

--Get total count of operations (docs) in all session files
procedure get_doc_total_count (
    o_count    out com_api_type_pkg.t_medium_id
) is
begin
    o_count := 0;

    if cu_xml_file_trailer%ISOPEN then
        close cu_xml_file_trailer;
    end if;

    for rec in (
        select f.id                as file_id
             , f.file_xml_contents as xml_content
          from prc_session_file f
         where f.session_id = prc_api_session_pkg.get_session_id
    ) loop

        open cu_xml_file_trailer (rec.file_id);
        loop
            fetch cu_xml_file_trailer into l_xml_file_trailer;
            exit when cu_xml_file_trailer%NOTFOUND;

            o_count := o_count + nvl(l_xml_file_trailer.rec_count, 0);
        end loop;
        close cu_xml_file_trailer;

    end loop;
end get_doc_total_count;

procedure process_doc_addinfo (
      i_parm       in t_xml_record --cu_xml_records%rowtype
    , o_cps        out t_cps
    , o_src        out t_doc_ref
    , o_de22       out t_de22
) is
begin
    --Output for Transaction/Extra/AddData/Parm
    for par in (
    select * from xmltable('Parm'
                       passing i_parm.trn_add_data
                       columns parm_code    varchar2 (32)   path 'ParmCode'
                             , value_       varchar2 (32)   path 'Value'
                       )
               ) loop
        --DBMS_OUTPUT.PUT_LINE ('ParmCode:' || par.parm_code ||'; ' || 'Value:' || par.value_);
        if    par.parm_code = 'CPS'      then o_cps := par.value_;
        elsif par.parm_code = 'SRC'      then o_src := par.value_;
        elsif par.parm_code = 'DE22'     then o_de22 := par.value_; --POS Entry mode
        end if;
    end loop;

end;

procedure count_amount (
    i_sttl_amount           in com_api_type_pkg.t_money
    , i_sttl_currency       in com_api_type_pkg.t_curr_code
) is
begin
    if g_amount_tab.exists(nvl(i_sttl_currency, '')) then
        g_amount_tab(nvl(i_sttl_currency, '')) := nvl(g_amount_tab(nvl(i_sttl_currency, '')), 0) + i_sttl_amount;
    else
        g_amount_tab(nvl(i_sttl_currency, '')) := i_sttl_amount;
    end if;
end;

--Getting EMV value by Element name
function get_emv_value(
    i_iso8583_f55 in com_api_type_pkg.t_text,
    i_element_id  in com_api_type_pkg.t_attr_name
)
    return  com_api_type_pkg.t_name is
    l_value com_api_type_pkg.t_name;
    l_chk   com_api_type_pkg.t_rate;
begin
    select instr(i_iso8583_f55, '<Tag Id="' || i_element_id || '">') into l_chk from dual;
    if l_chk = 0 then return null; end if;

    select --tag_pos.tag_text,
           substr(tag_pos.tag_text,
                  instr(tag_pos.tag_text, '>')+1
                 ,instr(tag_pos.tag_text, '</') - (instr(tag_pos.tag_text,'>') + 1)
           ) as tag_value
      into l_value
      from (
            select substr(tags,instr(tags,'<Tag Id="' || i_element_id || '">')) tag_text --, instr(tags,'<Tag Id="95">') Tag_95_start
              from ( select i_iso8583_f55 tags from dual )
    ) tag_pos;
    return l_value;

   exception
   when NO_DATA_FOUND
   then return null;
end;

function get_f55_raw (
    i_iso8583_f55  in  com_api_type_pkg.t_text
    --, o_mc_fin_rec out mcw_api_type_pkg.t_mes_rec --mcw_api_type_pkg.t_fin_rec --
) return mcw_fin.de055%type is
    l_emv_tag_tab com_api_type_pkg.t_tag_value_tab;
    l_f55         mcw_fin.de055%type;
begin
    if get_emv_value(i_iso8583_f55, '8A') is not null
    then
        l_emv_tag_tab('82') := get_emv_value(i_iso8583_f55, '8A');
        --o_mc_fin_rec.emv_82 := l_emv_tag_tab('82');
    end if; --'3900';
    if get_emv_value(i_iso8583_f55, '95') is not null then l_emv_tag_tab('95') := get_emv_value(i_iso8583_f55, '95'); end if; --'8000040000';
    if get_emv_value(i_iso8583_f55, '9A') is not null then l_emv_tag_tab('9A') := get_emv_value(i_iso8583_f55, '9A'); end if; --'160304';
    if get_emv_value(i_iso8583_f55, '9C') is not null then l_emv_tag_tab('9C') := get_emv_value(i_iso8583_f55, '9C'); end if; --'01';
    if get_emv_value(i_iso8583_f55, '5F2A') is not null then l_emv_tag_tab('5F2A') := get_emv_value(i_iso8583_f55, '5F2A'); end if; --'643';
    if get_emv_value(i_iso8583_f55, '9F02') is not null then l_emv_tag_tab('9F02') := get_emv_value(i_iso8583_f55, '9F02'); end if; --'000000100000';
    if get_emv_value(i_iso8583_f55, '9F10') is not null then l_emv_tag_tab('9F10') := get_emv_value(i_iso8583_f55, '9F10'); end if; --'0110A00003220000000000000000000000FF';
    if get_emv_value(i_iso8583_f55, '9F1A') is not null then l_emv_tag_tab('9F1A') := get_emv_value(i_iso8583_f55, '9F1A'); end if; --'643';
    if get_emv_value(i_iso8583_f55, '9F26') is not null then l_emv_tag_tab('9F26') := get_emv_value(i_iso8583_f55, '9F26'); end if; --'38BA02302A4EF16E';
    if get_emv_value(i_iso8583_f55, '9F27') is not null then l_emv_tag_tab('9F27') := get_emv_value(i_iso8583_f55, '9F27'); end if; --'80';
    if get_emv_value(i_iso8583_f55, '9F33') is not null then l_emv_tag_tab('9F33') := get_emv_value(i_iso8583_f55, '9F33'); end if; --'604020';
    if get_emv_value(i_iso8583_f55, '9F34') is not null then l_emv_tag_tab('9F34') := get_emv_value(i_iso8583_f55, '9F34'); end if; --'420100';
    if get_emv_value(i_iso8583_f55, '9F35') is not null then l_emv_tag_tab('9F35') := get_emv_value(i_iso8583_f55, '9F35'); end if; --'14';
    if get_emv_value(i_iso8583_f55, '9F36') is not null then l_emv_tag_tab('9F36') := get_emv_value(i_iso8583_f55, '9F36'); end if; --'0028';
    if get_emv_value(i_iso8583_f55, '9F37') is not null then l_emv_tag_tab('9F37') := get_emv_value(i_iso8583_f55, '9F37'); end if; --'17AC2F34';
    if get_emv_value(i_iso8583_f55, '9F53') is not null then l_emv_tag_tab('9F53') := get_emv_value(i_iso8583_f55, '9F53'); end if; --Z -- 5A --R

    --DBMS_OUTPUT.PUT_LINE ('Step1 - Ok ');

    l_f55 := hextoraw(
                emv_api_tag_pkg.format_emv_data(
                    io_emv_tag_tab => l_emv_tag_tab
                  , i_tag_type_tab => mcw_api_const_pkg.EMV_TAGS_LIST_FOR_DE055
                )
            );

    return l_f55;
end get_f55_raw;


function date_yyyy_mm_dd_hh24_mi_ss (
    p_date                  in varchar2
) return date is
begin
    return to_date (p_date, 'yyyy-mm-dd hh24:mi:ss');
end;

procedure process_doc_ref_set (
      i_parm       in t_xml_record --cu_xml_records%rowtype
    , o_arn        out t_arn
    , o_rrn        out t_doc_ref
    , o_auth_code  out t_doc_ref
    , o_srn        out t_doc_ref
    , o_irn        out t_doc_ref
    --, o_drn        out t_doc_ref
) is
begin

    --Output for DocRefSet/Parm
    for par in (
        select *
          from xmltable('Parm'
                   passing i_parm.doc_ref_set
                   columns parm_code    varchar2 (32)   path 'ParmCode'
                         , value_       varchar2 (32)   path 'Value'
               )
    ) loop
        trc_log_pkg.debug('ParmCode:' || par.parm_code ||'; ' || 'Value:' || par.value_);

        if par.parm_code = 'ARN'         then o_arn := par.value_;
        elsif par.parm_code = 'SRN'      then o_srn := par.value_;
        elsif par.parm_code = 'RRN'      then o_rrn := par.value_;
        elsif par.parm_code = 'AuthCode' then o_auth_code := par.value_;
        elsif par.parm_code = 'IRN'      then o_irn := par.value_;
        --elsif par.parm_code = 'DRN'      then o_drn := par.value_;
        end if;
    end loop;

    if o_arn is null
    then
        null;
    end if;
    --DBMS_OUTPUT.PUT_LINE ('o_arn:' || o_arn);
end;

procedure parse_de003 (
    i_de003            in mcw_api_type_pkg.t_de003
    , o_de003_1        out mcw_api_type_pkg.t_de003
    , o_de003_2        out mcw_api_type_pkg.t_de003
    , o_de003_3        out mcw_api_type_pkg.t_de003
) is
begin
    if i_de003 is not null then
        o_de003_1 := substrb(i_de003, 1, 2);
        o_de003_2 := substrb(i_de003, 3, lengthb(mcw_api_const_pkg.DEFAULT_DE003_2));
        o_de003_3 := substrb(i_de003, 5, lengthb(mcw_api_const_pkg.DEFAULT_DE003_3));
    end if;
end;

procedure parse_de022 (
    i_de022             in mcw_api_type_pkg.t_de022
    , o_de022_1         out mcw_api_type_pkg.t_de022s
    , o_de022_2         out mcw_api_type_pkg.t_de022s
    , o_de022_3         out mcw_api_type_pkg.t_de022s
    , o_de022_4         out mcw_api_type_pkg.t_de022s
    , o_de022_5         out mcw_api_type_pkg.t_de022s
    , o_de022_6         out mcw_api_type_pkg.t_de022s
    , o_de022_7         out mcw_api_type_pkg.t_de022s
    , o_de022_8         out mcw_api_type_pkg.t_de022s
    , o_de022_9         out mcw_api_type_pkg.t_de022s
    , o_de022_10        out mcw_api_type_pkg.t_de022s
    , o_de022_11        out mcw_api_type_pkg.t_de022s
    , o_de022_12        out mcw_api_type_pkg.t_de022s
) is
begin
    if i_de022 is not null then
        o_de022_1 := substrb(i_de022, 1, 1);
        o_de022_2 := substrb(i_de022, 2, 1);
        o_de022_3 := substrb(i_de022, 3, 1);
        o_de022_4 := substrb(i_de022, 4, 1);
        o_de022_5 := substrb(i_de022, 5, 1);
        o_de022_6 := substrb(i_de022, 6, 1);
        o_de022_7 := substrb(i_de022, 7, 1);
        o_de022_8 := substrb(i_de022, 8, 1);
        o_de022_9 := substrb(i_de022, 9, 1);
        o_de022_10 := substrb(i_de022, 10, 1);
        o_de022_11 := substrb(i_de022, 11, 1);
        o_de022_12 := substrb(i_de022, 12, 1);
    end if;
end;

    procedure parse_de030 (
        i_de030             in mcw_api_type_pkg.t_de030
        , o_de030_1         out mcw_api_type_pkg.t_de030s
        , o_de030_2         out mcw_api_type_pkg.t_de030s
    ) is
        l_curr_pos           pls_integer;
    begin
        if i_de030 is not null then
            l_curr_pos := 1;
            o_de030_1 := to_number(substrb(i_de030, l_curr_pos, 12));
            l_curr_pos := 12;
            o_de030_2 := to_number(substrb(i_de030, l_curr_pos, 12));
        end if;
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error         => 'MCW_ERROR_WRONG_LENGTH'
                , i_env_param1  => 'DE030'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_de030
            );
    end;

procedure parse_de043 (
    i_de043             in mcw_api_type_pkg.t_de043
    , o_de043_1         out mcw_api_type_pkg.t_de043
    , o_de043_2         out mcw_api_type_pkg.t_de043
    , o_de043_3         out mcw_api_type_pkg.t_de043
    , o_de043_4         out mcw_api_type_pkg.t_de043
    , o_de043_5         out mcw_api_type_pkg.t_de043
    , o_de043_6         out mcw_api_type_pkg.t_de043

) is
    l_curr_pos           pls_integer := 1;
    l_pos                pls_integer := 1;
begin
    if i_de043 is not null then
        l_pos := instrb(i_de043, mcw_api_const_pkg.DE043_FIELD_DELIMITER, l_curr_pos);
        if l_pos > 0 then
            o_de043_1 := substrb(i_de043, l_curr_pos, l_pos - l_curr_pos);
            l_curr_pos := l_pos + 1;
        else
            com_api_error_pkg.raise_error(
                i_error         => 'MCW_SUBFIELD_DELIMITER_NOT_FOUND'
                , i_env_param1  => 'DE043'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_de043
            );
        end if;

        l_pos := instrb(i_de043, mcw_api_const_pkg.DE043_FIELD_DELIMITER, l_curr_pos);
        if l_pos > 0 then
            o_de043_2 := substrb(i_de043, l_curr_pos, l_pos - l_curr_pos);
            l_curr_pos := l_pos + 1;
        else
            com_api_error_pkg.raise_error(
                i_error         => 'MCW_SUBFIELD_DELIMITER_NOT_FOUND'
                , i_env_param1  => 'DE043'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_de043
            );
        end if;

        l_pos := instrb(i_de043, mcw_api_const_pkg.DE043_FIELD_DELIMITER, l_curr_pos);
        if l_pos > 0 then
            o_de043_3 := substrb(i_de043, l_curr_pos, l_pos - l_curr_pos);
            l_curr_pos := l_pos + 1;
        else
            com_api_error_pkg.raise_error(
                i_error         => 'MCW_SUBFIELD_DELIMITER_NOT_FOUND'
                , i_env_param1  => 'DE043'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_de043
            );
        end if;

        o_de043_4 := rtrim(substrb(i_de043, l_curr_pos, 10));
        o_de043_5 := rtrim(substrb(i_de043, l_curr_pos + 10, 3));
        o_de043_6 := rtrim(substrb(i_de043, l_curr_pos + 13, 3));
    end if;
end;

--Getting DE003 (Processing Code by WAY4 Message Code)
function get_de003_by_msg_code(
    i_msg_code    in    com_api_type_pkg.t_name
) return com_api_type_pkg.t_byte_char is
    l_de003 com_api_type_pkg.t_byte_char;
begin

    if i_msg_code in (way_api_const_pkg.MSG_RET_PRESENTMENT, way_api_const_pkg.MSG_RET_PRESENTMENT)
    then l_de003 := '00'; -- Purchase (Goods and Services) transaction
    elsif i_msg_code in (way_api_const_pkg.MSG_ATM_PRESENTMENT, way_api_const_pkg.MSG_ATM_PRESENTMENT_REV)
    then l_de003 := '01'; -- ATM Cash Withdrawal transaction
    elsif i_msg_code in (way_api_const_pkg.MSG_CREDIT_PRESENTMENT, way_api_const_pkg.MSG_CREDIT_PRESENTMENT_REV)
    then l_de003 := '20'; -- Credit transaction
    elsif i_msg_code in (way_api_const_pkg.MSG_CASH_PRESENTMENT, way_api_const_pkg.MSG_CASH_PRESENTMENT_REV)
    then l_de003 := '12'; -- Cash Disbursement transaction
    else
        l_de003 := 18; -- Unique transaction
    end if;

   return l_de003;
end;

procedure process_visa_message (
      i_visa    in vis_api_type_pkg.t_visa_fin_mes_rec
) is
begin
    -- to transfer here visa message processing to make code more readable
    null;
end process_visa_message;

-- procedure to map WAY4 message MasterCard standart
procedure map_way_message_to_mc (
    i_xml_record        in  t_xml_record --cu_xml_records%rowtype
    , o_mes_rec         out mcw_api_type_pkg.t_mes_rec --mcw_api_type_pkg.t_fin_rec --
    /*
    , o_mti             out mcw_api_type_pkg.t_mti
    , o_de002           out mcw_api_type_pkg.t_de002
    , o_de003_1         out mcw_api_type_pkg.t_de003
    , o_de003_2         out mcw_api_type_pkg.t_de003
    , o_de003_3         out mcw_api_type_pkg.t_de003
    , o_de004           out mcw_api_type_pkg.t_de004
    , o_de005           out mcw_api_type_pkg.t_de005
    , o_de006           out mcw_api_type_pkg.t_de006
    , o_de009           out mcw_api_type_pkg.t_de009
    , o_de010           out mcw_api_type_pkg.t_de010
    , o_de012           out mcw_api_type_pkg.t_de012
    , o_de014           out mcw_api_type_pkg.t_de014
    , o_de022_1         out mcw_api_type_pkg.t_de022s
    , o_de022_2         out mcw_api_type_pkg.t_de022s
    , o_de022_3         out mcw_api_type_pkg.t_de022s
    , o_de022_4         out mcw_api_type_pkg.t_de022s
    , o_de022_5         out mcw_api_type_pkg.t_de022s
    , o_de022_6         out mcw_api_type_pkg.t_de022s
    , o_de022_7         out mcw_api_type_pkg.t_de022s
    , o_de022_8         out mcw_api_type_pkg.t_de022s
    , o_de022_9         out mcw_api_type_pkg.t_de022s
    , o_de022_10        out mcw_api_type_pkg.t_de022s
    , o_de022_11        out mcw_api_type_pkg.t_de022s
    , o_de022_12        out mcw_api_type_pkg.t_de022s
    , o_de023           out mcw_api_type_pkg.t_de023
    , o_de024           out mcw_api_type_pkg.t_de024
    , o_de025           out mcw_api_type_pkg.t_de025
    , o_de026           out mcw_api_type_pkg.t_de026
    , o_de030_1         out mcw_api_type_pkg.t_de030s
    , o_de030_2         out mcw_api_type_pkg.t_de030s
    , o_de031           out mcw_api_type_pkg.t_de031
    , o_de032           out mcw_api_type_pkg.t_de032
    , o_de033           out mcw_api_type_pkg.t_de033
    , o_de037           out mcw_api_type_pkg.t_de037
    , o_de038           out mcw_api_type_pkg.t_de038
    , o_de040           out mcw_api_type_pkg.t_de040
    , o_de041           out mcw_api_type_pkg.t_de041
    , o_de042           out mcw_api_type_pkg.t_de042
    , o_de043_1         out mcw_api_type_pkg.t_de043
    , o_de043_2         out mcw_api_type_pkg.t_de043
    , o_de043_3         out mcw_api_type_pkg.t_de043
    , o_de043_4         out mcw_api_type_pkg.t_de043
    , o_de043_5         out mcw_api_type_pkg.t_de043
    , o_de043_6         out mcw_api_type_pkg.t_de043
    , o_de048           out mcw_api_type_pkg.t_de048
    , o_de049           out mcw_api_type_pkg.t_de049
    , o_de050           out mcw_api_type_pkg.t_de050
    , o_de051           out mcw_api_type_pkg.t_de051
    , o_de054           out mcw_api_type_pkg.t_de054
    , o_de055           out mcw_api_type_pkg.t_de055
    , o_de062           out mcw_api_type_pkg.t_de062
    , o_de063           out mcw_api_type_pkg.t_de063
    , o_de071           out mcw_api_type_pkg.t_de071
    , o_de072           out mcw_api_type_pkg.t_de072
    , o_de073           out mcw_api_type_pkg.t_de073
    , o_de093           out mcw_api_type_pkg.t_de093
    , o_de094           out mcw_api_type_pkg.t_de094
    , o_de095           out mcw_api_type_pkg.t_de095
    , o_de100           out mcw_api_type_pkg.t_de100
    , o_de111           out mcw_api_type_pkg.t_de111
    , o_de123           out mcw_api_type_pkg.t_de123
    , o_de124           out mcw_api_type_pkg.t_de124
    , o_de125           out mcw_api_type_pkg.t_de125
    , o_de127           out mcw_api_type_pkg.t_de127
    */
    --, i_charset         in com_api_type_pkg.t_oracle_name
) is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.unpack_message';
    l_de003             mcw_api_type_pkg.t_de003;
    l_de022             mcw_api_type_pkg.t_de022;
    l_de030             mcw_api_type_pkg.t_de030;
    l_de043             mcw_api_type_pkg.t_de_body;

    l_raw_data          com_api_type_pkg.t_raw_data;

    l_rrn               com_api_type_pkg.t_rrn;
    l_auth_code         com_api_type_pkg.t_auth_code;
    l_srn               com_api_type_pkg.t_terminal_number;
    l_cps               t_cps;
    l_de22              t_de22;
    l_irn               t_doc_ref;
    l_add_iso8583_f55   com_api_type_pkg.t_text;
    l_mc_mes_rec        mcw_api_type_pkg.t_mes_rec;

begin

    trc_log_pkg.debug('inside map_way_message_to_mc: i_xml_record.msg_code = ' || i_xml_record.msg_code);

    if i_xml_record.msg_code
        in (way_api_const_pkg.MSG_ATM_PRESENTMENT
            , way_api_const_pkg.MSG_ATM_PRESENTMENT_REV
            , way_api_const_pkg.MSG_CASH_PRESENTMENT
            , way_api_const_pkg.MSG_CASH_PRESENTMENT_REV
            , way_api_const_pkg.MSG_CH_DB_PRESENTMENT_REV
            , way_api_const_pkg.MSG_CH_DB_PRESENTMENT
            , way_api_const_pkg.MSG_RET_PRESENTMENT_REV
            , way_api_const_pkg.MSG_RET_PRESENTMENT
            , way_api_const_pkg.MSG_CREDIT_PRESENTMENT
            , way_api_const_pkg.MSG_CREDIT_PRESENTMENT_REV
        )
     then
         o_mes_rec.mti   := mcw_api_const_pkg.MSG_TYPE_PRESENTMENT;
         o_mes_rec.de024 := mcw_api_const_pkg.FUNC_CODE_FIRST_PRES;
     elsif i_xml_record.msg_code
        in (way_api_const_pkg.MSG_RET_CHARGEBACK
            , way_api_const_pkg.MSG_RET_CHARGEBACK_REV
            , way_api_const_pkg.MSG_CREDIT_CHARGEBACK
            , way_api_const_pkg.MSG_CREDIT_CHARGEBACK_REV
            , way_api_const_pkg.MSG_CASH_CHARGEBACK
            , way_api_const_pkg.MSG_CASH_CHARGEBACK_REV
        )
     then
         o_mes_rec.mti   := mcw_api_const_pkg.MSG_TYPE_CHARGEBACK;
         o_mes_rec.de024 := mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL;
     end if;

    trc_log_pkg.debug('inside map_way_message_to_mc: o_mti = ' || o_mes_rec.mti || '; o_de024 = ' || o_mes_rec.de024);

    -- unpack bit mask
    --??? unpack_bitmask;

    -- get data elements
    o_mes_rec.de002 := i_xml_record.dst_contract_num; --PAN --get_field(o_de002, 2);

    l_de003 := get_de003_by_msg_code(i_msg_code => i_xml_record.msg_code); -- get_field(l_de003, 3);
    o_mes_rec.de003_1 := l_de003;
    o_mes_rec.de003_2 := mcw_api_const_pkg.DEFAULT_DE003_2;
    o_mes_rec.de003_3 := mcw_api_const_pkg.DEFAULT_DE003_3;

    o_mes_rec.de004 := i_xml_record.trn_amount;                             --get_field_number(o_de004, 4);
    o_mes_rec.de012 := date_yyyy_mm_dd_hh24_mi_ss(i_xml_record.local_date); --get_field_date(o_de012, mcw_api_const_pkg.DE012_DATE_FORMAT, 12);
    o_mes_rec.de014 := to_date(i_xml_record.dst_card_expiry,'YYMM');        --get_field_date(o_de014, mcw_api_const_pkg.DE014_DATE_FORMAT, 14);
    o_mes_rec.de014 := last_day(o_mes_rec.de014);

    trc_log_pkg.debug('map_way_message_to_mc: o_mes_rec.de014 = ' || to_char(o_mes_rec.de014) || '; i_xml_record.dst_card_expiry = ' || i_xml_record.dst_card_expiry);
    --DBMS_OUTPUT.PUT_LINE ('inside map_way_message_to_mc #2: o_mti = ' || o_mes_rec.mti || '; o_de024 = ' || o_mes_rec.de024);

    o_mes_rec.de049 := i_xml_record.trn_currency; --get_field(o_de049, 49);
    o_mes_rec.de005 := i_xml_record.rcn_amount;   --get_field_number(o_de005, 5);
    o_mes_rec.de006 := i_xml_record.bln_amount;   --get_field_number(o_de006, 6);
    --??? get_field(o_de009, 9);
    --??? get_field(o_de010, 10);

    o_mes_rec.de023 := i_xml_record.dst_card_seq;      --get_field_number(o_de023, 23, com_api_type_pkg.TRUE);
    o_mes_rec.de025 := i_xml_record.trans_reason_code; --get_field(o_de025, 25);
    o_mes_rec.de026 := i_xml_record.src_sic;               --get_field(o_de026, 26);
    o_mes_rec.de030_1 := o_mes_rec.de004;
    o_mes_rec.de030_2 := 0;

    process_doc_ref_set (
          i_parm      => i_xml_record
        , o_arn       => o_mes_rec.de031
        , o_rrn       => l_rrn --get_field(o_de037, 37);
        , o_auth_code => o_mes_rec.de038 --get_field(o_de038, 38);
        , o_srn       => l_srn   --???
        , o_irn       => l_irn
    );
    o_mes_rec.de037 := l_rrn;
    --DBMS_OUTPUT.PUT_LINE ('inside map_way_message_to_mc #3: o_mti = ' || o_mes_rec.mti || '; o_de024 = ' || o_mes_rec.de024);

    l_mc_mes_rec := o_mes_rec;
    calculate_de22_subfields (
        i_trans_condition => i_xml_record.trans_condition
        , o_mc_fin_rec    => l_mc_mes_rec
    );
    o_mes_rec.de022_1 := l_mc_mes_rec.de022_1;
    o_mes_rec.de022_2 := l_mc_mes_rec.de022_2;
    o_mes_rec.de022_3 := l_mc_mes_rec.de022_3;
    o_mes_rec.de022_4 := l_mc_mes_rec.de022_4;
    o_mes_rec.de022_5 := l_mc_mes_rec.de022_5;
    o_mes_rec.de022_6 := l_mc_mes_rec.de022_6;
    o_mes_rec.de022_7 := l_mc_mes_rec.de022_7;
    o_mes_rec.de022_8 := l_mc_mes_rec.de022_8;
    o_mes_rec.de022_9 := l_mc_mes_rec.de022_9;
    o_mes_rec.de022_10 := l_mc_mes_rec.de022_10;
    o_mes_rec.de022_11 := l_mc_mes_rec.de022_11;
    o_mes_rec.de022_12 := l_mc_mes_rec.de022_12;

    --DBMS_OUTPUT.PUT_LINE ('inside map_way_message_to_mc #5: o_mes_rec.de022_1 = ' || o_mes_rec.de022_1
    --                       || '; o_mes_rec.de022_7 = ' || o_mes_rec.de022_7);

    --DBMS_OUTPUT.PUT_LINE ('inside map_way_message_to_mc #6: o_mti = ' || o_mes_rec.mti || '; o_de024 = ' || o_mes_rec.de024);

    o_mes_rec.de032 := i_xml_record.org_member_id;  --get_field(o_de032, 32);
    o_mes_rec.de033 := i_xml_record.org_transit_id; --get_field(o_de033, 33);

    -- Process Doc/Transaction/Extra/AddInfo
    process_doc_addinfo(
          i_parm  => i_xml_record
        , o_cps   => l_cps   --???
        , o_src   => o_mes_rec.de040 --get_field(o_de040, 40);
        , o_de22  => l_de22  --???
    );

    o_mes_rec.de041 := i_xml_record.org_contract_num; --get_field(o_de041, 41);
    o_mes_rec.de042 := i_xml_record.src_merchant_id;  --get_field(o_de042, 42);
    o_mes_rec.de043_1 := i_xml_record.src_merch_name;
    o_mes_rec.de043_2 := i_xml_record.src_location;
    o_mes_rec.de043_3 := i_xml_record.src_city;
    o_mes_rec.de043_4 := i_xml_record.src_postal_code;
    o_mes_rec.de043_6 := i_xml_record.src_country; --com_api_country_pkg.get_country_name(i_code => i_xml_record.src_country);
    o_mes_rec.de043_5 := o_mes_rec.de043_6;

    --get_field(o_de048, 48); --additional data for administrative message types

    o_mes_rec.de050   := i_xml_record.rcn_currency; --get_field(o_de050, 50);
    o_mes_rec.de051   := i_xml_record.bln_currency; --get_field(o_de051, 51);
    --??? get_field(o_de054, 54); --Purchase with Cash Back transaction

    l_add_iso8583_f55 := xmltype.getStringVal(i_xml_record.add_iso8583_f55);
    o_mes_rec.de055 := get_f55_raw (i_iso8583_f55  => l_add_iso8583_f55
                                    --, o_mc_fin_rec => o_mes_rec
                       ); --get_field_raw(o_de055, 55);

    --get_field(o_de062, 62); -- extention of additional data (see o_de048)


    --!!! To retrieve de063 there is a need to deliver info for ISO8583/F111 tags in incoming XML file - from OPR_OPERATION.NETWORK_REFNUM
    /*
    o_mes_rec.de063 := mcw_utl_pkg.build_nrn(
        i_netw_refnum  =>  i_auth_rec.network_refnum
        , i_netw_date  =>  i_xml_record.nw_date --i_auth_rec.network_cnvt_date
    );
    */

    --???get_field_number(o_de071, 71);
    --???get_field(o_de072, 72);
    --get_field_date(o_de073, mcw_api_const_pkg.DE073_DATE_FORMAT, 73); -- for fee collection only

    o_mes_rec.de093 := i_xml_record.dst_member_id;    --get_field(o_de093, 93);
    o_mes_rec.de094 := i_xml_record.org_member_id;    --get_field(o_de094, 94);
    o_mes_rec.de095 := substr(l_irn, 1, 10);          --get_field(o_de095, 95);
    o_mes_rec.de100 := substr(o_mes_rec.de002, 1, 6); --get_field(o_de100, 100);

    --additional data extention (if de048 is not enough to store all required additional info)
    --???get_field_number(o_de111, 111);
    --get_field(o_de123, 123); -- extention of additional data (see o_de048)
    --get_field(o_de124, 124); -- extention of additional data (see o_de048)
    --get_field(o_de125, 125); -- extention of additional data (see o_de048)
    trc_log_pkg.debug('finishing map_way_message_to_mc: o_mti = ' || o_mes_rec.mti || '; o_de024 = ' || o_mes_rec.de024);

end map_way_message_to_mc;

procedure process_xml_file_header (
      i_session_file_id     in com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_dst_inst_id         in com_api_type_pkg.t_inst_id
    --, o_visa_file           out vis_api_type_pkg.t_visa_file_rec -- should be commented after o_way_file is implemented
    , o_way_file            out t_way_file
) is
    l_security_code         com_api_type_pkg.t_dict_value;
    l_count                 pls_integer;
    l_param_tab             com_api_type_pkg.t_param_tab;
begin
    o_way_file.is_incoming     := com_api_type_pkg.TRUE;

    if cu_xml_file_header%ISOPEN then
        close cu_xml_file_header;
    end if;

    open cu_xml_file_header (i_session_file_id);
    loop
       fetch cu_xml_file_header into l_xml_file_header;
       exit when cu_xml_file_header%NOTFOUND;

       trc_log_pkg.debug('file_label:' || l_xml_file_header.file_label ||'; ' || 'format_version:'
                       || l_xml_file_header.format_version || '/'||l_xml_file_header.sender
                       || '/'|| l_xml_file_header.creation_date
                       || '/'|| l_xml_file_header.creation_time
                       || '/'|| l_xml_file_header.file_seq_number
                       || '/'|| l_xml_file_header.receiver
                       );

        o_way_file.file_label      := l_xml_file_header.file_label;
        o_way_file.sender          := l_xml_file_header.sender;
        o_way_file.proc_date       := to_date(l_xml_file_header.creation_date, 'YYYY-MM-DD');
        g_filedate                 := o_way_file.proc_date;
        o_way_file.file_seq_number := l_xml_file_header.file_seq_number;
        o_way_file.receiver        := l_xml_file_header.receiver;
        o_way_file.is_rejected     := 0;
        o_way_file.proc_time       := l_xml_file_header.creation_time;
        o_way_file.format_version  := l_xml_file_header.format_version;
        o_way_file.session_file_id := i_session_file_id;
        o_way_file.network_id      := i_network_id;

        o_way_file.id := way_file_seq.nextval;

        --, sttl_date           date
        --, inst_id             number(4)
    end loop;
    close cu_xml_file_header;

    begin
        select 1
          into l_count
          from way_file
         where proc_date       = o_way_file.proc_date
           and file_seq_number = o_way_file.file_seq_number
           and sender          = o_way_file.sender
           and file_label      = o_way_file.file_label
           and receiver        = o_way_file.receiver;

        com_api_error_pkg.raise_error (
            i_error    => 'WAY4 File already processed: proc_date[' || to_char(o_way_file.proc_date) || ']; '
                          || 'file_seq_number[' || to_char(o_way_file.file_seq_number) || ']; '
                          || 'sender['   || o_way_file.sender   || ']; '
                          || 'receiver[' || o_way_file.receiver || ']; '
        );
    exception
        when no_data_found then
            null;
    end;

    o_way_file.sttl_date := trunc(o_way_file.proc_date);
    g_processing_date    := o_way_file.sttl_date;

    if i_standard_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'UNKNOWN_NETWORK'
            , i_env_param1  => i_network_id
        );
    end if;

    -- determine internal institution number
    o_way_file.inst_id := i_dst_inst_id;
    if o_way_file.inst_id is null then
        o_way_file.inst_id := get_inst_id_by_proc_bin(o_way_file.sender, i_network_id);
    end if;
    if o_way_file.inst_id is null then
        com_api_error_pkg.raise_error(
            i_error    => 'WAY4 BIN NOT REGISTERED: Sender[' || o_way_file.sender || ']; '
                           || 'i_network_id[' || to_char(i_network_id)            || ']; '
                           || 'inst_id['      || to_char(o_way_file.inst_id)      || ']; '
        );
    end if;

    insert into way_file (
        id
      , is_incoming
      , is_rejected
      , network_id
      , sender
      , proc_date
      , proc_time
      , sttl_date
      , file_label
      , format_version
      , file_seq_number
      , receiver
      , inst_id
      , session_file_id
    ) values (
        o_way_file.id
      , o_way_file.is_incoming
      , o_way_file.is_rejected
      , o_way_file.network_id
      , o_way_file.sender
      , o_way_file.proc_date
      , o_way_file.proc_time
      , o_way_file.sttl_date
      , o_way_file.file_label
      , o_way_file.format_version
      , o_way_file.file_seq_number
      , o_way_file.receiver
      , o_way_file.inst_id
      , o_way_file.session_file_id
    );

end process_xml_file_header;

procedure process_xml_file_trailer (
      i_session_file_id    in  com_api_type_pkg.t_long_id
      , o_total_amount     out com_api_type_pkg.t_money
      , o_total_count      out com_api_type_pkg.t_long_id
) is
    l_total_amount          com_api_type_pkg.t_money :=0;
    l_count                 com_api_type_pkg.t_medium_id :=0;
begin

    if cu_xml_file_trailer%ISOPEN then
        close cu_xml_file_trailer;
    end if;

    open cu_xml_file_trailer (i_session_file_id);
    loop
        fetch cu_xml_file_trailer into l_xml_file_trailer;
        exit when cu_xml_file_trailer%NOTFOUND;

        --Check count and amount from trailer regarding operations in the file
        with xml_file as
            (
             select f.file_xml_contents xml_content
              from prc_session_file f
             where f.id = i_session_file_id  -- -1
            )
        select count(1) rec_count, sum(trn_amount) total_amount -- Count and Total amount of all operations on given XML-file
          into l_count
             , l_total_amount
          from xml_file s
             , xmltable('DocFile/DocList/Doc'
                  passing s.xml_content
                  columns msg_code   varchar2 (32) path 'TransType/TransCode/MsgCode'
                        , trn_amount number        path 'Transaction/Amount'
                ) way4_set;

        if nvl(l_xml_file_trailer.rec_count, 0) <> l_count
           or
           nvl(l_xml_file_trailer.total_amount, 0) <> l_total_amount
        then
            com_api_error_pkg.raise_error (
                i_error => 'Wrong CheckSum in XML file trailer: RecsCount ['|| to_char(nvl(l_xml_file_trailer.rec_count, 0))
                           || '] or/and HashTotalAmount [' || to_char(nvl(l_xml_file_trailer.total_amount, 0))
                           || '] dont correlate with operations count and amount'
        );
        end if;

        o_total_amount := l_xml_file_trailer.total_amount;
        o_total_count  := l_xml_file_trailer.rec_count;
    end loop;

    close cu_xml_file_trailer;

end process_xml_file_trailer;

--Getting SV terminal type
function get_terminal_type(
    i_trans_condition in com_api_type_pkg.t_text
) return com_api_type_pkg.t_dict_value is
    l_term_type com_api_type_pkg.t_dict_value;
begin
    l_term_type :=
        case
            when instr(i_trans_condition, 'POS') > 0 then acq_api_const_pkg.TERMINAL_TYPE_POS
            when instr(i_trans_condition, 'ATM') > 0 then acq_api_const_pkg.TERMINAL_TYPE_ATM
            when instr(i_trans_condition, 'IMPRINTER') > 0 then acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER
            when instr(i_trans_condition, 'MPOS') > 0 then acq_api_const_pkg.TERMINAL_TYPE_MOBILE_POS
            when instr(i_trans_condition, 'TBAPPL') > 0 then acq_api_const_pkg.TERMINAL_TYPE_INTERNET
            when instr(i_trans_condition, 'WEB') > 0 then acq_api_const_pkg.TERMINAL_TYPE_INTERNET
            else '0'
        end;
    return l_term_type;

--TERMINAL_TYPE_MOBILE        constant    com_api_type_pkg.t_dict_value   := 'TRMT0005';
--TERMINAL_TYPE_INFO_KIOSK    constant    com_api_type_pkg.t_dict_value   := 'TRMT0008';
end;

--Getting BASE II Cardholder id method
function get_baseII_crdh_id_method(
    i_trans_condition in com_api_type_pkg.t_text
) return com_api_type_pkg.t_dict_value is
    l_method com_api_type_pkg.t_dict_value;
begin
        if    instr(i_trans_condition, 'AUTH_CAD') > 0    -- PIN
        then l_method := '2';
        elsif instr(i_trans_condition, 'AUTH_MERCH') > 0  -- Signature
        then l_method := '1';
        elsif instr(i_trans_condition, 'AUTH_AGENT') > 0 or instr(i_trans_condition, 'TERM_UNATT') > 0  -- Unattended terminal
        then l_method := '3';
        elsif instr(i_trans_condition, 'AUTH_CARD') > 0   -- Mail/Telephone or Electronic Commerce
        then l_method := '4';
        elsif instr(i_trans_condition, 'NO_AUTH') > 0
        then l_method := null;
        else l_method := null;
        end if;
 return l_method;
end;

--Getting Visa TC (Transaction code by WAY4 Message Code)
function get_tc_by_msg_code(
    i_msg_code    in    com_api_type_pkg.t_name
) return com_api_type_pkg.t_byte_char is
    l_tc com_api_type_pkg.t_byte_char;
begin
   select tc_map.tc
     into l_tc
     from (
         select way_api_const_pkg.MSG_RET_PRESENTMENT msg_code
              , vis_api_const_pkg.TC_SALES tc  from dual
         union all
         select way_api_const_pkg.MSG_CASH_PRESENTMENT
              , vis_api_const_pkg.TC_CASH from dual
         union all
         select way_api_const_pkg.MSG_ATM_PRESENTMENT
              , vis_api_const_pkg.TC_CASH from dual
         union all
         select way_api_const_pkg.MSG_ATM_PRESENTMENT_REV
              , vis_api_const_pkg.TC_CASH_REVERSAL from dual
         union all
         select way_api_const_pkg.MSG_RET_CHARGEBACK
              , vis_api_const_pkg.TC_SALES_CHARGEBACK from dual
         union all
         select way_api_const_pkg.MSG_CREDIT_CHARGEBACK
              , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK from dual
         union all
         select way_api_const_pkg.MSG_CASH_CHARGEBACK
              , vis_api_const_pkg.TC_CASH_CHARGEBACK from dual
         union all
         select way_api_const_pkg.MSG_RET_PRESENTMENT_REV
              , vis_api_const_pkg.TC_SALES_REVERSAL from dual
         union all
         select way_api_const_pkg.MSG_CREDIT_PRESENTMENT
              , vis_api_const_pkg.TC_VOUCHER from dual
         union all
         select way_api_const_pkg.MSG_CREDIT_PRESENTMENT_REV
              , vis_api_const_pkg.TC_VOUCHER_REVERSAL from dual
         union all
         select way_api_const_pkg.MSG_CASH_PRESENTMENT_REV
              , vis_api_const_pkg.TC_CASH_REVERSAL from dual
         union all
         select way_api_const_pkg.MSG_RET_CHARGEBACK_REV
              , vis_api_const_pkg.TC_SALES_CHARGEBACK_REV from dual
         union all
         select way_api_const_pkg.MSG_CREDIT_CHARGEBACK_REV
              , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV from dual
         union all
         select way_api_const_pkg.MSG_CASH_CHARGEBACK_REV
              , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV from dual
     ) tc_map
   where tc_map.msg_code = i_msg_code;

   return l_tc;

   exception
   when NO_DATA_FOUND
   then return null;
end;

procedure init_fin_record (
    io_visa                 in out  vis_api_type_pkg.t_visa_fin_mes_rec
) is
begin
    io_visa.id           := null;
    io_visa.is_incoming  := com_api_type_pkg.TRUE;
    io_visa.is_returned  := com_api_type_pkg.FALSE;
    io_visa.is_invalid   := com_api_type_pkg.FALSE;
    io_visa.is_reversal  := com_api_type_pkg.FALSE;
end;

function date_ddmmmyy (
    p_date                  in varchar2
) return date is
begin
    if p_date is null or p_date = '0000000' or trim(p_date) is null then
        return null;
    end if;

    return to_date(p_date, 'DDMONYY');
end;

function date_yymm (
    p_date                  in varchar2
) return date is
begin
    if p_date is null or p_date = '0000' then
        return null;
    end if;

    return to_date(p_date, 'YYMM');
end;

function date_mmdd (
    p_date                  in varchar2
) return date is
    l_century               varchar2(4) := to_char(g_filedate, 'YYYY');
    l_dt                    date;
begin
    if p_date is null or p_date = '0000' then
        return null;
    end if;
    l_dt := to_date (l_century || p_date, 'YYYYMMDD');
    if l_dt > g_filedate and l_dt > g_processing_date then
        l_century := to_char (to_number (l_century) - 1);
        l_dt := to_date (l_century || p_date, 'YYYYMMDD');
        if abs(months_between(l_dt, g_filedate))>11 then
            l_century := to_char (g_filedate, 'YYYY');
            l_dt := to_date (l_century || p_date, 'YYYYMMDD');
        end if;
    end if;
    return l_dt;
end;

function date_yddd (
    p_date                  in varchar2
) return date is
    v_century               varchar2(4) := to_char (g_filedate, 'YYYY');
    v_dt                    date;
begin
    if p_date is null then
        return null;
    end if;

    if p_date = '0000' then
        return trunc (g_filedate);
    end if;
    v_dt := to_date (substr (v_century, 1, 3) || p_date, 'YYYYDDD');

    return v_dt;
end;

function strange_date_yyyyddd (
    p_date                  in varchar2
) return date is
begin
    if substr (p_date, 1, 2) = '00' then
        return to_date(substr(p_date, 3, 5), 'RRDDD');
    end if;
    return to_date(p_date, 'YYYYDDD');
end;

function date_yyyyddd (
    p_date                  in varchar2
) return date is
begin
    if p_date = '0000000' then
        return null;
    end if;
    return to_date (p_date, 'YYYYDDD');
end;

function date_yymmdd (
    p_date                  in varchar2
) return date is
begin
    if p_date = '000000' then
        return null;
    end if;
    return to_date (p_date, 'YYMMDD');
end;

function date_mmddyy (
    p_date                  in varchar2
) return date is
begin
    if p_date = '000000' then
        return null;
    end if;
    return to_date (p_date, 'MMDDYY');
end;

function date_yyyymmdd (
    p_date                  in varchar2
    , p_time                in varchar2
) return date is
  l_time varchar2(6) := p_time;
begin

    if p_date = '000000' then
        return null;
    end if;
    if l_time is null then
        l_time := '000000';
    end if;

    return to_date (p_date||l_time, 'YYYYMMDDhh24miss');
end;

function correct_sign (
    p_amt                   in number
    , p_sign                in varchar2
) return number is
begin
    return case p_sign when 'DB' then -p_amt else p_amt end;
end;

procedure count_amount (
    io_amount_tab           in out nocopy t_amount_count_tab
    , i_sttl_amount         in com_api_type_pkg.t_money
    , i_sttl_currency       in com_api_type_pkg.t_curr_code
) is
begin
    if io_amount_tab.exists(nvl(i_sttl_currency, '')) then
        io_amount_tab(nvl(i_sttl_currency, '')) := nvl(io_amount_tab(nvl(i_sttl_currency, '')), 0) + i_sttl_amount;
    else
        io_amount_tab(nvl(i_sttl_currency, '')) := i_sttl_amount;
    end if;
end;

procedure info_amount (
    i_amount_tab            in t_amount_count_tab
) is
    l_result                com_api_type_pkg.t_name;
begin
    l_result := i_amount_tab.first;
    loop
        exit when l_result is null;

        trc_log_pkg.info (
            i_text          => 'Settlement currency [#1] amount [#2]'
            , i_env_param1  => l_result
            , i_env_param2  =>
                com_api_currency_pkg.get_amount_str (
                    i_amount            => i_amount_tab(l_result)
                    , i_curr_code       => l_result
                    , i_mask_curr_code  => com_api_type_pkg.TRUE
                    , i_mask_error      => com_api_type_pkg.TRUE
                )
        );

        l_result := i_amount_tab.next(l_result);
    end loop;
end;

function get_card_number (
    i_card_number           in com_api_type_pkg.t_card_number
    , i_network_id          in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_card_number is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_card_number: ';
    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_card_country          com_api_type_pkg.t_curr_code;
    l_pan_length            com_api_type_pkg.t_tiny_id;
    l_iss_inst_id           com_api_type_pkg.t_inst_id;
    l_iss_network_id        com_api_type_pkg.t_tiny_id;
    l_iss_host_id           com_api_type_pkg.t_tiny_id;
    l_card_inst_id          com_api_type_pkg.t_inst_id;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_card_number [#1], i_network_id [' || i_network_id || ']'
      , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
    );

    iss_api_bin_pkg.get_bin_info (
        i_card_number        => i_card_number
        , o_iss_inst_id      => l_iss_inst_id
        , o_iss_network_id   => l_iss_network_id
        , o_iss_host_id      => l_iss_host_id
        , o_card_type_id     => l_card_type_id
        , o_card_country     => l_card_country
        , o_card_inst_id     => l_card_inst_id
        , o_card_network_id  => l_card_network_id
        , o_pan_length       => l_pan_length
        , i_raise_error      => com_api_const_pkg.FALSE
    );
    trc_log_pkg.debug(
        i_text => 'iss_api_bin_pkg.get_bin_info: '
               || 'l_card_inst_id [' || l_card_inst_id
               || '], l_pan_length [' || l_pan_length || ']'
    );

    if l_card_inst_id is null then
        net_api_bin_pkg.get_bin_info (
            i_card_number        => i_card_number
            , i_network_id       => i_network_id
            , o_iss_inst_id      => l_iss_inst_id
            , o_iss_host_id      => l_iss_host_id
            , o_card_type_id     => l_card_type_id
            , o_card_country     => l_card_country
            , o_card_inst_id     => l_card_inst_id
            , o_card_network_id  => l_card_network_id
            , o_pan_length       => l_pan_length
            , i_raise_error      => com_api_const_pkg.FALSE
        );
        trc_log_pkg.debug(
            i_text => 'net_api_bin_pkg.get_bin_info: '
                   || 'l_card_inst_id [' || l_card_inst_id
                   || '], l_pan_length [' || l_pan_length || ']'
        );
    end if;

    if l_pan_length is null then
        com_api_error_pkg.raise_error (
            i_error         => 'UNKNOWN_BIN_CARD_NUMBER_NETWORK'
            , i_env_param1  => substr(i_card_number, 1, 6)
            , i_env_param2  => i_network_id
        );
    end if;

    if l_pan_length = 0 then
        l_pan_length := 16;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END; l_pan_length [' || l_pan_length || ']');

    return substr(i_card_number, 1, l_pan_length);
end;

procedure assign_dispute(
    io_visa                 in out nocopy vis_api_type_pkg.t_visa_fin_mes_rec
    , o_iss_inst_id         out com_api_type_pkg.t_inst_id
    , o_iss_network_id      out com_api_type_pkg.t_tiny_id
    , o_acq_inst_id         out com_api_type_pkg.t_inst_id
    , o_acq_network_id      out com_api_type_pkg.t_tiny_id
    , o_sttl_type           out com_api_type_pkg.t_dict_value
    , o_match_status        out com_api_type_pkg.t_dict_value
) is
    l_dispute_id            com_api_type_pkg.t_long_id;
    l_is_incoming           com_api_type_pkg.t_boolean;

    cursor match_cur is
    select
        min(m.id) id
        , min(m.dispute_id) dispute_id
        , min(m.card_id) card_id
        , io_visa.card_number as card_number
        , min(o.sttl_type) sttl_type
        , min(o.match_status) match_status
        , min(o.status) status
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.inst_id, null)) iss_inst_id
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.network_id, null)) iss_network_id
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.inst_id, null)) acq_inst_id
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.network_id, null)) acq_network_id
    from
        vis_fin_message m
        , vis_card c
        , opr_operation o
        , opr_participant p
    where
        m.trans_code in (vis_api_const_pkg.TC_SALES, vis_api_const_pkg.TC_VOUCHER, vis_api_const_pkg.TC_CASH)
        and m.usage_code = '1'
        and m.is_incoming = 1 --l_is_incoming
        and m.arn = io_visa.arn
        and c.id = m.id
        and c.card_number = iss_api_token_pkg.encode_card_number(i_card_number => io_visa.card_number)
        and o.id = m.id
        and p.oper_id = o.id
    ;
begin
    trc_log_pkg.debug (
        i_text          => 'assign_dispute: card_number[#1], arn[#2]'
        , i_env_param1  => iss_api_card_pkg.get_card_mask(io_visa.card_number)
        , i_env_param2  => io_visa.arn
    );

    case
    when io_visa.trans_code in (
        vis_api_const_pkg.TC_REQUEST_ORIGINAL_PAPER
        , vis_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY
    ) then
        l_is_incoming := com_api_type_pkg.FALSE;

    when io_visa.trans_code in (
        vis_api_const_pkg.TC_SALES_CHARGEBACK
        , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
        , vis_api_const_pkg.TC_CASH_CHARGEBACK
        , vis_api_const_pkg.TC_SALES_CHARGEBACK_REV
        , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
        , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV
    ) then
         l_is_incoming := com_api_type_pkg.FALSE;
    else
         l_is_incoming := com_api_type_pkg.TRUE;
    end case;

    for rec in match_cur loop
        if rec.id is not null then
            io_visa.dispute_id  := rec.id;
            io_visa.card_id     := rec.card_id;
            io_visa.card_number := rec.card_number;
            if rec.status = opr_api_const_pkg.OPERATION_STATUS_MANUAL then
                io_visa.is_invalid := com_api_type_pkg.TRUE;
            end if;

            l_dispute_id        := rec.dispute_id;

            o_iss_inst_id       := rec.iss_inst_id;
            o_iss_network_id    := rec.iss_network_id;
            o_acq_inst_id       := rec.acq_inst_id;
            o_acq_network_id    := rec.acq_network_id;
            o_sttl_type         := rec.sttl_type;
            o_match_status      := rec.match_status;

            trc_log_pkg.debug (
                i_text          => 'Original message found. id = [#1], o_iss_inst_id = [#2]'
                , i_env_param1  => rec.id
                , i_env_param2  => o_iss_inst_id
            );
        end if;

        exit;
    end loop;

    if io_visa.dispute_id is null then

        vis_cst_incoming_pkg.assign_dispute(
            io_visa                 => io_visa
            , o_iss_inst_id         => o_iss_inst_id
            , o_iss_network_id      => o_iss_network_id
            , o_acq_inst_id         => o_acq_inst_id
            , o_acq_network_id      => o_acq_network_id
            , o_sttl_type           => o_sttl_type
            , o_match_status        => o_match_status
        );

    end if;

    if io_visa.dispute_id is null then

        io_visa.is_invalid := com_api_type_pkg.TRUE;

        trc_log_pkg.warn (
            i_text           => 'ORIGINAL_OPERATION_IS_NOT_FOUND'
            , i_env_param1   => io_visa.id
            , i_env_param2   => io_visa.arn
            , i_env_param3   => iss_api_card_pkg.get_card_mask(io_visa.card_number)
            , i_env_param4   => com_api_type_pkg.convert_to_char(io_visa.oper_date)
            , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            , i_object_id    => io_visa.id
        );
    end if;

    -- assign a new dispute id
    if l_dispute_id is null then
        update
            vis_fin_message
        set
            dispute_id = io_visa.dispute_id
        where
            id = io_visa.dispute_id;

        update
            opr_operation
        set
            dispute_id = io_visa.dispute_id
        where
            id = io_visa.dispute_id;
    end if;
end;

procedure create_fin_addendum (
    i_fin_msg_id            in com_api_type_pkg.t_long_id
    , i_raw_data            in varchar2
) is
begin
    insert into vis_fin_addendum (
        id
        , fin_msg_id
        , tcr
        , raw_data
    ) values (
        vis_fin_addendum_seq.nextval
        , i_fin_msg_id
        , substr(i_raw_data, 4, 1)
        , i_raw_data
    );
end;

procedure get_oper_type (
    io_oper_type            in out com_api_type_pkg.t_dict_value
    , i_mcc                 in com_api_type_pkg.t_mcc
    , i_mask_error          in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_cab_type              com_api_type_pkg.t_mcc;
begin
    select
        mastercard_cab_type
    into
        l_cab_type
    from
        com_mcc
    where
        mcc = i_mcc;

    if io_oper_type in (
        opr_api_const_pkg.OPERATION_TYPE_PURCHASE
    ) then
        case l_cab_type
            when mcw_api_const_pkg.CAB_TYPE_UNIQUE then
                io_oper_type := opr_api_const_pkg.OPERATION_TYPE_UNIQUE;
            else
                null;
        end case;
    end if;
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.warn (
                i_text          => 'MCW_UNDEFINED_MCC'
                , i_env_param1  => i_mcc
            );
        else
            com_api_error_pkg.raise_error (
                i_error         => 'MCW_UNDEFINED_MCC'
                , i_env_param1  => i_mcc
            );
        end if;
end;

procedure process_draft(
    --i_tc_buffer           in vis_api_type_pkg.t_tc_buffer
    i_network_id          in com_api_type_pkg.t_tiny_id
  , i_host_id             in com_api_type_pkg.t_tiny_id
  , i_standard_id         in com_api_type_pkg.t_tiny_id
  , i_inst_id             in com_api_type_pkg.t_inst_id
  , i_proc_date           in date
  , i_file_id             in com_api_type_pkg.t_long_id
  , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
  , i_batch_id            in com_api_type_pkg.t_medium_id
  , i_record_number       in com_api_type_pkg.t_short_id
  , i_proc_bin            in com_api_type_pkg.t_dict_value
  , io_amount_tab         in out nocopy t_amount_count_tab
  , i_create_operation    in com_api_type_pkg.t_boolean
  --, i_validate_record     in com_api_type_pkg.t_boolean
  , io_no_original_id_tab in out nocopy vis_api_type_pkg.t_visa_fin_mes_tab
  , i_xml_record          in t_xml_record --cu_xml_records%rowtype
  , i_charset             in com_api_type_pkg.t_oracle_name := null -- for MasterCard messages only
) is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_draft: ';
    l_visa                  vis_api_type_pkg.t_visa_fin_mes_rec;
    l_recnum                pls_integer := 1;
    l_tcr                   varchar2(1);
    l_iss_inst_id           com_api_type_pkg.t_inst_id;
    l_acq_inst_id           com_api_type_pkg.t_inst_id;
    l_card_inst_id          com_api_type_pkg.t_inst_id;
    l_iss_network_id        com_api_type_pkg.t_tiny_id;
    l_acq_network_id        com_api_type_pkg.t_tiny_id;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_country_code          com_api_type_pkg.t_country_code;
    l_bin_currency          com_api_type_pkg.t_curr_code;
    l_sttl_currency         com_api_type_pkg.t_curr_code;
    l_euro_settlement       com_api_type_pkg.t_boolean;
    l_visa_dialect          com_api_type_pkg.t_dict_value;
    l_sttl_type             com_api_type_pkg.t_dict_value;
    l_match_status          com_api_type_pkg.t_dict_value;
    l_card_service_code     com_api_type_pkg.t_curr_code;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_iss_inst_id2          com_api_type_pkg.t_inst_id;
    l_iss_network_id2       com_api_type_pkg.t_tiny_id;
    l_iss_host_id           com_api_type_pkg.t_tiny_id;
    l_card_country          com_api_type_pkg.t_country_code;
    l_pan_length            com_api_type_pkg.t_tiny_id;
    l_currency_exponent     com_api_type_pkg.t_tiny_id;

    l_oper                  opr_api_type_pkg.t_oper_rec;
    l_iss_part              opr_api_type_pkg.t_oper_part_rec;
    l_acq_part              opr_api_type_pkg.t_oper_part_rec;
    l_operation             opr_api_type_pkg.t_oper_rec;
    l_participant           opr_api_type_pkg.t_oper_part_rec;
    l_need_original_id      com_api_type_pkg.t_boolean;

    l_interchng_fee_amount  number(9, 6);
    --

    l_network_id            com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_cps_retail_flag       com_api_type_pkg.t_boolean;
    l_cps_atm_flag          com_api_type_pkg.t_boolean;
    l_cps                   t_cps;
    l_de22                  t_de22;
    l_terminal_type         com_api_type_pkg.t_dict_value;
    l_tcc                   com_api_type_pkg.t_mcc;
    l_diners_code           com_api_type_pkg.t_mcc;
    l_cab_type              com_api_type_pkg.t_mcc;
    l_add_iso8583_f55       com_api_type_pkg.t_text;

    l_mc_mes_rec            mcw_api_type_pkg.t_mes_rec; --mcw_api_type_pkg.t_fin_rec; --
    l_mes_rec_prev          mcw_api_type_pkg.t_mes_rec;
    l_record_number         com_api_type_pkg.t_long_id;
    l_raw_data              com_api_type_pkg.t_raw_data;
    l_irn                   t_doc_ref;
    l_fin_ref_id            com_api_type_pkg.t_long_id;
    l_message_processed     com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE;

    procedure init_record is
    begin
        l_mes_rec_prev := l_mc_mes_rec;
        l_mc_mes_rec := null;
        l_record_number := null;
    end;

    function get_country_code(
        i_country_name    in      com_api_type_pkg.t_country_code
        , i_raise_error   in      com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_country_code is
        l_result            com_api_type_pkg.t_country_code;
    begin
        select code
          into l_result
          from com_country
         where upper(name) = upper(i_country_name);--upper(visa_country_code) = upper(i_visa_country_code);

         return l_result;

    exception
        when no_data_found then
            if i_raise_error = com_api_const_pkg.TRUE then
                com_api_error_pkg.raise_error(
                    i_error             => 'VISA_COUNTRY_CODE_NOT_FOUND'
                  , i_env_param1        => upper(i_country_name) --upper(i_visa_country_code)
                );
            else
                return l_result;
            end if;
    end;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX --|| 'i_tc_buffer.count() = ' || i_tc_buffer.count()
                                   --|| ', io_amount_tab.count() = ' || io_amount_tab.count()
                                   || ', i_inst_id [' || i_inst_id
                                   || '], i_file_id [' || i_file_id
                                   || '], i_batch_id [' || i_batch_id
                                   || '], i_record_number [' || i_record_number
                                   || '], i_create_operation [' || i_create_operation
                                   || '], i_proc_date [#1], i_proc_bin [#2]'
      , i_env_param1 => to_char(i_proc_date, com_api_const_pkg.XML_DATE_FORMAT)
      , i_env_param2 => i_proc_bin
    );

    if substr(i_xml_record.dst_contract_num, 1, 1) = '5' then
        l_network_id := MC_NETWORK;
    elsif substr(i_xml_record.dst_contract_num, 1, 1) = '4' then
        l_network_id := VISA_NETWORK;
    else
        l_network_id := i_network_id;
    end if ;

    trc_log_pkg.debug('Here we are in process_draft. l_network_i: ' || l_network_id );

    if l_network_id = MC_NETWORK
    then
        l_standard_id := 1036; -- Way4 XML

        --here goes MC message processing
        trc_log_pkg.debug('goes to MC message processing');

        l_mc_mes_rec := null;
        map_way_message_to_mc (
            i_xml_record        => i_xml_record
            , o_mes_rec         => l_mc_mes_rec
            --, i_charset         => i_charset
        );

        savepoint sp_message_with_dispute;

        trc_log_pkg.debug('map_way_message_to_mc resuls: l_mc_mes_rec.mti = ' || l_mc_mes_rec.mti || '; l_mc_mes_rec.de024 = ' || l_mc_mes_rec.de024);

        begin
            -- process incoming first presentment
            if ( l_mc_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
                 and l_mc_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
            ) then
                --DBMS_OUTPUT.PUT_LINE ('Here i am creating first presentment...');
                mcw_api_fin_pkg.create_incoming_first_pres (
                    i_mes_rec              => l_mc_mes_rec
                    , i_file_id            => i_file_id
                    , i_incom_sess_file_id => i_incom_sess_file_id
                    , o_fin_ref_id         => l_fin_ref_id
                    , i_network_id         => l_network_id           --i_network_id
                    , i_host_id            => i_host_id
                    , i_standard_id        => l_standard_id          --i_standard_id
                    , i_local_message      => com_api_type_pkg.FALSE --i_local_message
                    , i_create_operation   => i_create_operation
                    , i_validate_record    => com_api_type_pkg.FALSE --i_validate_record
                    , i_need_repeat        => com_api_type_pkg.FALSE --i_need_repeat
                );
                count_amount (
                    i_sttl_amount      => l_mc_mes_rec.de005
                    , i_sttl_currency  => l_mc_mes_rec.de050
                );
                init_record;
            elsif ( l_mc_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
                    and l_mc_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL

            ) then
                --DBMS_OUTPUT.PUT_LINE ('Here i am creating chargeback...');
                mcw_api_fin_pkg.create_incoming_chargeback (
                    i_mes_rec              => l_mc_mes_rec
                    , i_file_id            => i_file_id
                    , i_incom_sess_file_id => i_incom_sess_file_id
                    , i_network_id         => l_network_id           --i_network_id
                    , i_host_id            => i_host_id
                    , i_standard_id        => l_standard_id          --i_standard_id
                    , i_local_message      => com_api_type_pkg.FALSE --i_local_message
                    , i_create_operation   => i_create_operation
                    , i_validate_record    => com_api_type_pkg.FALSE --i_validate_record
                    , i_need_repeat        => com_api_type_pkg.FALSE --i_need_repeat
                );
                count_amount (
                    i_sttl_amount      => l_mc_mes_rec.de005
                    , i_sttl_currency  => l_mc_mes_rec.de050
                );
                init_record;
            else
                l_message_processed := com_api_type_pkg.FALSE;
            end if;
        exception
            when mcw_api_dispute_pkg.e_need_original_record then
                rollback to savepoint sp_message_with_dispute;

                -- Save unprocessed record into buffer.
                g_no_original_rec_tab(g_no_original_rec_tab.count + 1).i_mes_rec        := l_mc_mes_rec;
                g_no_original_rec_tab(g_no_original_rec_tab.count).i_file_id            := i_file_id;
                g_no_original_rec_tab(g_no_original_rec_tab.count).i_incom_sess_file_id := i_incom_sess_file_id;
                g_no_original_rec_tab(g_no_original_rec_tab.count).i_network_id         := l_network_id;
                g_no_original_rec_tab(g_no_original_rec_tab.count).i_host_id            := i_host_id;
                g_no_original_rec_tab(g_no_original_rec_tab.count).i_standard_id        := l_standard_id;
                g_no_original_rec_tab(g_no_original_rec_tab.count).i_local_message      := com_api_type_pkg.TRUE; --i_local_message;
                g_no_original_rec_tab(g_no_original_rec_tab.count).i_create_operation   := i_create_operation;
                g_no_original_rec_tab(g_no_original_rec_tab.count).i_mes_rec_prev       := l_mes_rec_prev;
                g_no_original_rec_tab(g_no_original_rec_tab.count).io_fin_ref_id        := l_fin_ref_id;

                l_message_processed := com_api_type_pkg.TRUE;
                --init_record; -- return l_message_processed;

        end;

    elsif l_network_id = VISA_NETWORK
    then
        --here goes VISA message processing
        l_standard_id := vis_api_const_pkg.VISA_BASEII_STANDARD;
        --DBMS_OUTPUT.PUT_LINE('Prcessing VISA card: ' || i_xml_record.dst_contract_num );
    /*
        cmn_api_standard_pkg.get_param_value(
            i_inst_id      => i_inst_id
          , i_standard_id  => i_standard_id
          , i_object_id    => i_host_id
          , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name   => vis_api_const_pkg.VISA_BASEII_DIALECT
          , o_param_value  => l_visa_dialect
          , i_param_tab    => l_param_tab
        );
    */
        l_visa_dialect := vis_api_const_pkg.VISA_DIALECT_OPENWAY;

        -- Message specific fields
        -- data from TCR0
        init_fin_record(l_visa);
        l_visa.id                   := opr_api_create_pkg.get_id;
        l_visa.trans_code           := get_tc_by_msg_code(i_msg_code => i_xml_record.msg_code);   --substr(i_tc_buffer(l_recnum), 1, 2);
        l_visa.file_id              := i_file_id;
        l_visa.batch_id             := i_batch_id;
        l_visa.record_number        := i_record_number;

        l_visa.is_reversal :=
        case when l_visa.trans_code in (
            vis_api_const_pkg.TC_SALES_REVERSAL
            , vis_api_const_pkg.TC_VOUCHER_REVERSAL
            , vis_api_const_pkg.TC_CASH_REVERSAL
            , vis_api_const_pkg.TC_SALES_CHARGEBACK_REV
            , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
            , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV
        )
        then
            com_api_type_pkg.TRUE
        else
            com_api_type_pkg.FALSE
        end;

        l_visa.trans_code_qualifier := '0'; --??? substr(i_tc_buffer(l_recnum), 3, 1);
        --
        l_visa.inst_id             := i_inst_id;
        l_visa.network_id          := l_network_id;                                                 --i_network_id;
        l_visa.card_number         := get_card_number(i_xml_record.dst_contract_num, l_network_id); --substr(i_tc_buffer(l_recnum), 5, 19)
        l_visa.card_hash           := com_api_hash_pkg.get_card_hash(l_visa.card_number);
        l_visa.card_mask           := iss_api_card_pkg.get_card_mask(l_visa.card_number);
        l_visa.oper_currency       := i_xml_record.trn_currency;                                    --substr(i_tc_buffer(l_recnum), 89, 3);
        --
/*
        if l_visa.is_incoming = com_api_type_pkg.TRUE then
            begin
                l_visa.inst_id    := iss_api_bin_pkg.get_bin(
                                         i_bin         => substr(i_xml_record.dst_contract_num, 1, 6) --substr(i_tc_buffer(l_recnum), 28, 6)
                                       , i_mask_error  => com_api_type_pkg.TRUE
                                     ).inst_id;
                l_visa.network_id := ost_api_institution_pkg.get_inst_network(i_inst_id => l_visa.inst_id);
            exception
                when others then
                    if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                        l_visa.inst_id      := null;
                        l_visa.network_id   := null;
                    else
                        raise;
                    end if;
            end;
        else
            iss_api_bin_pkg.get_bin_info(
                i_card_number      => get_card_number(
                                          i_card_number => i_xml_record.dst_contract_num --substr(i_tc_buffer(l_recnum), 5, 19)
                                        , i_network_id  => l_network_id     --i_network_id
                                      )
              , o_iss_inst_id      => l_visa.inst_id
              , o_iss_network_id   => l_visa.network_id
              , o_card_inst_id     => l_card_inst_id
              , o_card_network_id  => l_card_network_id
              , o_card_type        => l_card_type_id
              , o_card_country     => l_country_code
              , o_bin_currency     => l_bin_currency
              , o_sttl_currency    => l_sttl_currency
            );

            l_card_inst_id     := null;
            l_card_network_id  := null;
            l_card_type_id     := null;
            l_country_code     := null;
            l_bin_currency     := null;
            l_sttl_currency    := null;
        end if;
*/

        trc_log_pkg.debug(
            i_text => 'l_visa.inst_id [' || l_visa.inst_id
                   || '], l_visa.network_id [' || l_visa.network_id
                   || '], l_visa.card_mask [' || l_visa.card_mask || ']'
        );

        -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
        l_currency_exponent := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_visa.oper_currency);
        if l_currency_exponent = 0 then
            l_visa.oper_amount     := to_number(substr(to_char(i_xml_record.trn_amount), 1, length(to_char(i_xml_record.trn_amount)) - 2)); --substr(i_tc_buffer(l_recnum), 77, 12 - 2);
        else
            l_visa.oper_amount     := i_xml_record.trn_amount; --substr(i_tc_buffer(l_recnum), 77, 12);
            if l_currency_exponent > 2 then
                l_visa.oper_amount := l_visa.oper_amount * power(10, l_currency_exponent - 2);
            end if;
        end if;

        l_visa.oper_date           := date_yyyy_mm_dd_hh24_mi_ss(i_xml_record.local_date); --date_mmdd(substr(i_tc_buffer(l_recnum), 58, 4));
        -- if operation date greater than file date then lessen date for a year
        if l_visa.oper_date > i_proc_date then
            l_visa.oper_date       := add_months(l_visa.oper_date, -12);
        end if;

        l_visa.sttl_currency       := i_xml_record.bln_currency;--substr(i_tc_buffer(l_recnum), 74, 3);
        -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
        l_currency_exponent := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_visa.sttl_currency);
        if l_currency_exponent = 0 then
            l_visa.sttl_amount     := to_number(substr(to_char(i_xml_record.bln_amount), 1, length(to_char(i_xml_record.bln_amount)) - 2));--substr(i_tc_buffer(l_recnum), 62, 12 - 2);
        else
            l_visa.sttl_amount     := i_xml_record.bln_amount; --substr(i_tc_buffer(l_recnum), 62, 12);
            if l_currency_exponent > 2 then
                l_visa.sttl_amount := l_visa.sttl_amount * power(10, l_currency_exponent - 2);
            end if;
        end if;

        l_visa.floor_limit_ind      := null; --substr(i_tc_buffer(l_recnum), 24, 1);
        l_visa.exept_file_ind       := null; --substr(i_tc_buffer(l_recnum), 25, 1);
        l_visa.pcas_ind             := null; --substr(i_tc_buffer(l_recnum), 26, 1);

        process_doc_ref_set (
              i_parm      => i_xml_record
            , o_arn       => l_visa.arn
            , o_rrn       => l_visa.rrn
            , o_auth_code => l_visa.auth_code
            , o_srn       => l_visa.sender_reference_number
            , o_irn       => l_irn
            --, o_drn       => null --??? l_visa.drn
        );
        l_visa.acq_inst_bin         := i_xml_record.org_member_id;    -- substr(i_tc_buffer(l_recnum), 28, 6);
        l_visa.acq_business_id      := i_xml_record.src_merchant_id;  --substr(i_tc_buffer(l_recnum), 50, 8);
        l_visa.merchant_name        := i_xml_record.src_merch_name;   --substrb(i_tc_buffer(l_recnum), 92, 25);
        l_visa.merchant_city        := i_xml_record.src_city;         --substrb(i_tc_buffer(l_recnum), 117, 13);
        l_visa.merchant_country     := get_country_code(
                                           i_country_name    => i_xml_record.src_country
                                       ); --com_api_country_pkg.get_country_code(i_visa_country_code => i_xml_record.src_country);--trim(substr(i_tc_buffer(l_recnum), 130, 3))

        l_visa.mcc                  := i_xml_record.src_sic;          --substr(i_tc_buffer(l_recnum), 133, 4);
        l_visa.merchant_postal_code := i_xml_record.src_postal_code;  --substr(i_tc_buffer(l_recnum), 137, 5);
        l_visa.merchant_region      := i_xml_record.src_state;        --substr(i_tc_buffer(l_recnum), 142, 3);

        -- Process Doc/Transaction/Extra/AddInfo
        process_doc_addinfo(
              i_parm  => i_xml_record
            , o_cps   => l_cps
            , o_src   => l_card_service_code
            , o_de22  => l_de22
        );
        --get VISA Retail CPS Participation Flag/VISA ATM CPS Participation Flag
        l_cps_retail_flag := nvl(substr(l_cps, 3, 1),'0');
        l_cps_atm_flag := l_cps_retail_flag;
        --l_visa.req_pay_service      := substr(i_tc_buffer(l_recnum), 145, 1);
        l_visa.req_pay_service :=
            case when l_visa.mcc = '6011' and l_cps_atm_flag = com_api_type_pkg.TRUE then '9'
                 when l_visa.mcc not in ('6010', '6011') and l_cps_retail_flag = com_api_type_pkg.TRUE then 'A'
                 else null
            end;

        l_visa.payment_forms_num    := null; --substr(i_tc_buffer(l_recnum), 146, 1);
        l_visa.usage_code           := '1';  --substr(i_tc_buffer(l_recnum), 147, 1);
        l_visa.reason_code          := '00'; --substr(i_tc_buffer(l_recnum), 148, 2);
        l_visa.settlement_flag      := '9';  --substr(i_tc_buffer(l_recnum), 150, 1);
        l_visa.auth_char_ind        := substr(l_cps, 4, 1); --substr(i_tc_buffer(l_recnum), 151, 1);
        l_visa.pos_terminal_cap     := get_baseII_terminal_cap(i_trans_condition => i_xml_record.trans_condition);   --substr(i_tc_buffer(l_recnum), 158, 1);
        l_visa.crdh_id_method       := get_baseII_crdh_id_method(i_trans_condition => i_xml_record.trans_condition); --substr(i_tc_buffer(l_recnum), 160, 1);

        l_visa.collect_only_flag    := null;           --substr(i_tc_buffer(l_recnum), 161, 1);

        l_visa.pos_entry_mode :=
            case
                when instr(i_xml_record.trans_condition, 'DATA_CHIP')  > 0 then 'C'
                when instr(i_xml_record.trans_condition, 'READ_CHIP')  > 0 then 'F'
                when instr(i_xml_record.trans_condition, 'DATA_TRACK') > 0 then 'B'
                when instr(i_xml_record.trans_condition, 'READ_TRACK') > 0 then 'A'
                when instr(i_xml_record.trans_condition, '') > 0 then ''
                else '0'
            end; --substr(i_auth_rec.card_data_input_mode, -1)  -- substr(i_tc_buffer(l_recnum), 162, 2)
        l_visa.pos_entry_mode :=
            case
                when l_visa.pos_entry_mode = 'B' then '90'                -- Magnetic stripe read and exact content of Track 1 or Track 2 included (CVV check is possible).
                when l_visa.pos_entry_mode in ('C', 'F') then '05'        -- Integrated circuit card read; CVV or iCVV data reliable.
                when l_visa.pos_entry_mode in ('6', 'S', '5', '7', '9') then '01'   -- Manual key entry.
                when l_visa.pos_entry_mode = 'M' then '07'                -- Proximity Payment using VSDC chip data rules.
                when l_visa.pos_entry_mode = 'A' then '91'                -- Proximity payment using magnetic stripe data rules.
                when l_visa.pos_entry_mode = '2' then '02'                -- Magnetic stripe read; CVV checking may not be possible
                else null
            end;


        l_visa.central_proc_date    := to_char(com_api_sttl_day_pkg.get_sysdate, 'YDDD'); --substr(i_tc_buffer(l_recnum), 164, 4);
        -- if central processing date greater than file date then lessen base date for a year
        if to_date(l_visa.central_proc_date,'YDDD') > i_proc_date then
            l_visa.central_proc_date := to_char(to_date(substr(to_char(add_months(i_proc_date, -12), 'YYYY'), 1, 3)
                                     || to_char(com_api_sttl_day_pkg.get_sysdate, 'YDDD'), 'YYYYDDD'), 'YDDD');
        end if;

        l_terminal_type := get_terminal_type(i_trans_condition => i_xml_record.trans_condition);
        --l_visa.reimburst_attr       := substr(i_tc_buffer(l_recnum), 168, 1);
        l_visa.reimburst_attr :=
            case
                when l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS and l_visa.mcc = '6010'  then '0'
                when (l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM and l_visa.mcc != '6011')
                  or (l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS and l_visa.mcc != '6010')
                  or l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS then 'B'
                when l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM and l_visa.mcc = '6011'  then '2'
                when l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS and l_visa.mcc = '6010'  then '0'
                when l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER and l_visa.mcc = '6010' then '6'
                when l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER and l_visa.mcc != '6010' then '8'
                else '0'
            end;

        l_recnum := 2;

        -- TCR1 data present
        --if i_tc_buffer.exists(l_recnum) then
        --    l_tcr := substr(i_tc_buffer(l_recnum), 4, 1);
        --end if;

        -- TCR1 - additional data
        --if l_tcr = '1' then
            l_visa.business_format_code  := null;     --substr(i_tc_buffer(l_recnum), 5, 1);
            --??? l_visa.token_assurance_level := substr(i_tc_buffer(l_recnum), 6, 2);
            l_visa.chargeback_ref_num    := '000000'; --substr(i_tc_buffer(l_recnum), 17, 6);
            l_visa.docum_ind             := null;     --substr(i_tc_buffer(l_recnum), 23, 1);
            l_visa.member_msg_text       := null;     --substr(i_tc_buffer(l_recnum), 24, 50);

            com_api_mcc_pkg.get_mcc_info(
                i_mcc               => l_visa.mcc
              , o_tcc               => l_tcc
              , o_diners_code       => l_diners_code
              , o_mc_cab_type       => l_cab_type
            );
            --l_visa.spec_cond_ind         := substr(i_tc_buffer(l_recnum), 74, 2);
            l_visa.spec_cond_ind :=
            case when l_cab_type = 'U' then
                '8'
            else
                null
            end;
            l_visa.fee_program_ind       := null; --substr(i_tc_buffer(l_recnum), 76, 3);
            l_visa.issuer_charge         := null; --substr(i_tc_buffer(l_recnum), 79, 1);
            l_visa.merchant_number       := i_xml_record.src_merchant_id;  -- substr(i_tc_buffer(l_recnum), 81, 15);
            l_visa.terminal_number       := i_xml_record.org_contract_num; -- substr(i_tc_buffer(l_recnum), 96, 8);
            l_visa.national_reimb_fee    := 0;    --substr(i_tc_buffer(l_recnum), 104, 12);
            --??? l_visa.electr_comm_ind       := substr(i_tc_buffer(l_recnum), 116, 1);
            l_visa.spec_chargeback_ind   := null; --substr(i_tc_buffer(l_recnum), 117, 1);
            l_visa.interface_trace_num   := null; --substr(i_tc_buffer(l_recnum), 118, 6);
            --l_visa.unatt_accept_term_ind := substr(i_tc_buffer(l_recnum), 124, 1);
            l_visa.unatt_accept_term_ind :=
            case when l_visa.pos_terminal_cap in ('2','4','5') then
                case when l_visa.crdh_id_method = '1' then '2'
                else '3'
                end
            else
                ''
            end;

            l_visa.prepaid_card_ind      := null; --substr(i_tc_buffer(l_recnum), 125, 1);
            l_visa.service_development := case when l_visa.electr_comm_ind is null then '0' else '1' end; --substr(i_tc_buffer(l_recnum), 126, 1);
            l_visa.avs_resp_code         := null; --substr(i_tc_buffer(l_recnum), 127, 1);
            l_visa.auth_source_code      := '5';  --substr(i_tc_buffer(l_recnum), 128, 1);

            l_visa.purch_id_format       := '0';  --substr(i_tc_buffer(l_recnum), 129, 1);

            l_visa.account_selection     := ' ';  --substr(i_tc_buffer(l_recnum), 130, 1);
            /*???if i_auth_rec.mcc = '6011' then
                l_fin_rec.account_selection :=
                    case i_auth_rec.account_type
                        when 'ACCT0010' then '1'
                        when 'ACCT0020' then '2'
                        when 'ACCT0030' then '3'
                        else '0'
                    end;
            else
                l_fin_rec.account_selection := ' ';
            end if;*/

            l_visa.installment_pay_count := null; --substr(i_tc_buffer(l_recnum), 131, 2);
            l_visa.purch_id              := null; --substr(i_tc_buffer(l_recnum), 133, 25);
            l_visa.cashback              := 0; --
            -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
            /*???if com_api_currency_pkg.get_currency_exponent(i_curr_code => l_visa.oper_currency) = 0 then
                l_visa.cashback          := substr(i_tc_buffer(l_recnum), 158, 9 - 2);
            else
                l_visa.cashback          := substr(i_tc_buffer(l_recnum), 158, 9);
            end if;*/

            --l_visa.chip_cond_code        := substr(i_tc_buffer(l_recnum), 167, 1);
            if (instr(i_xml_record.trans_condition, 'READ_TRACK') > 0 or instr(i_xml_record.trans_condition, 'DATA_TRACK') > 0)  -- read card via magstripe
               and substr(l_card_service_code, 1, 1) in ('2','6')                                                       -- chip card
               and substr(l_visa.pos_terminal_cap, -1) in ('5', 'C', 'D', 'E', 'M')                                     -- chip-capable terminal
            then
                l_visa.chip_cond_code := '1';
            else
                l_visa.chip_cond_code := '0';
            end if;


            l_visa.pos_environment := null; --substr(i_tc_buffer(l_recnum), 168, 1);
            l_visa.pos_environment :=
                case
                    when instr(i_xml_record.trans_condition, 'CARDHOLDER') > 0 then '0'
                    when instr(i_xml_record.trans_condition, 'MAIL') > 0 then '2'
                    when instr(i_xml_record.trans_condition, 'MNET') > 0 then '5'
                    when instr(i_xml_record.trans_condition, 'NO_CARDHOLDER') > 0 then '1'
                    when instr(i_xml_record.trans_condition, 'PHONE') > 0 then '3'
                    when instr(i_xml_record.trans_condition, 'RECURRING') > 0 then '4'
                    else '9'
                end; --substr(i_auth_rec.crdh_presence, -1);

            if l_visa.pos_environment = '4' --substr(i_auth_rec.crdh_presence, -1)
                and com_api_country_pkg.get_visa_region(i_country_code => l_visa.merchant_country) = vis_api_const_pkg.VISA_REGION_EUROPE
                and com_api_country_pkg.get_visa_region(i_country_code => l_card_country) = vis_api_const_pkg.VISA_REGION_EUROPE
            then
                l_visa.pos_environment := 'R';
            else
                l_visa.pos_environment := ' ';
            end if;

        --end if;

        -- TCR5, TCR7 - chip card transaction data, and TCR8 for OPENWAY
        --for l_recnum in i_tc_buffer.first..i_tc_buffer.last loop
            --if i_tc_buffer.exists(l_recnum) and substr(i_tc_buffer(l_recnum), 4, 1) = '5' then

                --??? l_visa.transaction_id         := trim(substr(i_tc_buffer(l_recnum), 5, 15));
                l_visa.auth_currency          := l_visa.oper_currency; --??? trim(substr(i_tc_buffer(l_recnum), 32, 3));
                -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
                l_visa.auth_amount            := l_visa.oper_amount;
                /*??? if l_visa.auth_currency is not null then
                    if com_api_currency_pkg.get_currency_exponent(i_curr_code => l_visa.auth_currency) = 0 then
                        l_visa.auth_amount := substr(i_tc_buffer(l_recnum), 20, 12 - 2);
                    else
                        l_visa.auth_amount := substr(i_tc_buffer(l_recnum), 20, 12);
                    end if;
                end if;*/

                l_add_iso8583_f55 := xmltype.getStringVal(i_xml_record.add_iso8583_f55);

                l_visa.auth_resp_code         := get_emv_value(l_add_iso8583_f55, '8A'); --trim(substr(i_tc_buffer(l_recnum), 35, 2));

                --??? l_visa.clearing_sequence_num  := trim(substr(i_tc_buffer(l_recnum), 45, 2));
                --??? l_visa.clearing_sequence_count:= trim(substr(i_tc_buffer(l_recnum), 47, 2));
                l_visa.merchant_verif_value   := null; --trim(substr(i_tc_buffer(l_recnum), 82, 10));
                --??? l_visa.product_id             := trim(substr(i_tc_buffer(l_recnum), 136, 2));
                --??? l_visa.spend_qualified_ind    := trim(substr(i_tc_buffer(l_recnum), 149, 1));
                --??? l_visa.pan_token              := trim(substr(i_tc_buffer(l_recnum), 150, 16));
                --??? l_visa.cvv2_result_code       := trim(substr(i_tc_buffer(l_recnum), 168, 1));

                -- Interchange fee defined as a number with six decimals implied, we need to round it with used exponent
                --??? l_interchng_fee_amount := nvl(trim(substr(i_tc_buffer(l_recnum), 92, 9)), 0)
                --???                         + nvl(trim(substr(i_tc_buffer(l_recnum), 101, 6)), 0) / 1000000;
                --??? l_currency_exponent := com_api_currency_pkg.get_currency_exponent(i_curr_code => l_visa.sttl_currency);
                --??? l_visa.interchange_fee_amount := round(l_interchng_fee_amount * power(10, l_currency_exponent));

                --??? l_visa.interchange_fee_sign   := case trim(substr(i_tc_buffer(l_recnum), 107, 1))
                --???                                      when 'C' then  1
                --???                                      when 'D' then -1
                --???                                      else to_number(null)
                --???                                  end;
                --??? l_visa.program_id             := trim(substr(i_tc_buffer(l_recnum), 138, 6));
                --??? l_visa.dcc_indicator          := to_number(nvl(trim(substr(i_tc_buffer(l_recnum), 144, 1)), '0'));

            --elsif i_tc_buffer.exists(l_recnum) and substr(i_tc_buffer(l_recnum), 4, 1) = '7' then

                l_visa.transaction_type      := get_emv_value(l_add_iso8583_f55, '9C');   --substr(i_tc_buffer(l_recnum), 5, 2);
                l_visa.card_seq_number       := i_xml_record.dst_card_seq; --trim(substr(i_tc_buffer(l_recnum), 7, 3));
                l_visa.terminal_profile      := get_emv_value(l_add_iso8583_f55, '9F33'); --substr(i_tc_buffer(l_recnum), 16, 6);
                l_visa.unpredict_number      := get_emv_value(l_add_iso8583_f55, '9F37'); --substr(i_tc_buffer(l_recnum), 33, 8);
                l_visa.appl_trans_counter    := get_emv_value(l_add_iso8583_f55, '9F36'); --substr(i_tc_buffer(l_recnum), 41, 4);
                l_visa.appl_interch_profile  := get_emv_value(l_add_iso8583_f55, '82');   --substr(i_tc_buffer(l_recnum), 45, 4);
                l_visa.cryptogram            := get_emv_value(l_add_iso8583_f55, '9F26'); --substr(i_tc_buffer(l_recnum), 49, 16);
                l_visa.term_verif_result     := get_emv_value(l_add_iso8583_f55, '95');   --substr(i_tc_buffer(l_recnum), 69, 10);
                l_visa.cryptogram_amount     := get_emv_value(l_add_iso8583_f55, '9F02'); --substr(i_tc_buffer(l_recnum), 87, 12);
                l_visa.issuer_appl_data      := get_emv_value(l_add_iso8583_f55, '9F10');
                l_visa.card_verif_result     := substr(l_visa.issuer_appl_data, 7, 8); --substr(i_tc_buffer(l_recnum), 79, 8);
                l_visa.cryptogram_version    := substr(l_visa.issuer_appl_data, 5, 2); --substr(i_tc_buffer(l_recnum), 67, 2);
                l_visa.form_factor_indicator := get_emv_value(l_add_iso8583_f55, '9F6E'); --substr(i_tc_buffer(l_recnum), 151, 8);
                l_visa.issuer_script_result  := get_emv_value(l_add_iso8583_f55, '9F18'); --substr(i_tc_buffer(l_recnum), 159, 10);
                if l_visa.issuer_script_result is not null then
                    l_visa.issuer_script_result := l_visa.issuer_script_result || '00';
                end if;

            --elsif l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_OPENWAY
              --and i_tc_buffer.exists(l_recnum) and substr(i_tc_buffer(l_recnum), 4, 1) = '8'
             --then

                l_visa.card_expir_date          := i_xml_record.dst_card_expiry;               --substr(i_tc_buffer(l_recnum), 31, 4);
                l_visa.card_seq_number          := i_xml_record.dst_card_seq;                  --substr(i_tc_buffer(l_recnum), 35, 3);
                l_visa.merchant_street          := i_xml_record.src_location;                  -- trim(substrb(i_tc_buffer(l_recnum), 85, 30));
                l_visa.merchant_postal_code     := i_xml_record.src_postal_code;               --trim(substr(i_tc_buffer(l_recnum), 115, 10));

                --??? l_visa.chargeback_reason_code   := trim(substr(i_tc_buffer(l_recnum), 63, 4));

                l_visa.destination_channel      := i_xml_record.dst_channel;                   --trim(substr(i_tc_buffer(l_recnum), 67, 1));
                l_visa.source_channel           := i_xml_record.org_channel;                   --trim(substr(i_tc_buffer(l_recnum), 68, 1));

            --elsif i_tc_buffer.exists(l_recnum) and substr(i_tc_buffer(l_recnum), 4, 1) = 'E' then
                /*??? l_visa.business_format_code_e := substr(i_tc_buffer(l_recnum), 5, 2);
                case l_visa.business_format_code_e
                    -- Visa Europe V.me by Visa Data
                    when 'JA' then
                        l_visa.agent_unique_id := substr(i_tc_buffer(l_recnum), 7, 5);
                        l_visa.additional_auth_method := substr(i_tc_buffer(l_recnum), 12, 2);
                        l_visa.additional_reason_code := substr(i_tc_buffer(l_recnum), 14, 2);
                    -- Visa Commerce Overflow Data
                    when 'BB' then
                        null;
                    else
                        null;
                end case;*/

            --elsif i_tc_buffer.exists(l_recnum) and substr(i_tc_buffer(l_recnum), 4, 1) = '3' then
                -- TCR 3
                l_visa.fast_funds_indicator     := null; --substr(i_tc_buffer(l_recnum), 16, 1);
                l_visa.business_format_code_3   := 'CR'; --substr(i_tc_buffer(l_recnum), 17, 2);
                --??? l_visa.business_application_id  := substr(i_tc_buffer(l_recnum), 19, 2);
                l_visa.source_of_funds          := null; --substr(i_tc_buffer(l_recnum), 21, 1);
                l_visa.payment_reversal_code    := null; --substr(i_tc_buffer(l_recnum), 22, 2);

                --??? l_visa.sender_account_number    := substr(i_tc_buffer(l_recnum), 40, 34);
                l_visa.sender_name              := i_xml_record.src_merch_name; --??? substr(i_tc_buffer(l_recnum), 74, 30);
                l_visa.sender_address           := i_xml_record.src_location;   --??? substr(i_tc_buffer(l_recnum), 104, 35);
                l_visa.sender_city              := i_xml_record.src_city;       --??? substr(i_tc_buffer(l_recnum), 139, 25);
                l_visa.sender_state             := i_xml_record.src_state;      --??? substr(i_tc_buffer(l_recnum), 164, 2);
                l_visa.sender_country           := i_xml_record.src_country;    --??? substr(i_tc_buffer(l_recnum), 166, 3);

            --elsif l_visa.trans_code_qualifier = '0'
                --and (l_visa.trans_code like '_5' or l_visa.trans_code like '_6') -- TC_SALES*, TC_VOUCHER*
            --then
            --    l_visa.agent_unique_id          := substr(i_tc_buffer(l_recnum), 5, 5);
            --end if;
        --end loop;
        
        l_oper.oper_type := net_api_map_pkg.get_oper_type(
            i_network_oper_type  => l_visa.trans_code || l_visa.trans_code_qualifier || l_visa.mcc -- '0706011'  --TC_CASH
          , i_standard_id        => vis_api_const_pkg.VISA_BASEII_STANDARD --i_standard_id
        );
        --check trans_code
        if l_visa.trans_code = vis_api_const_pkg.TC_SALES and to_number(l_visa.cashback) > 0 then
            l_oper.oper_cashback_amount := to_number(l_visa.cashback);
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_CASHBACK;
        end if;

        -- Quasi cash transactions
        get_oper_type(
            io_oper_type  => l_oper.oper_type
          , i_mcc         => l_visa.mcc
          , i_mask_error  => com_api_type_pkg.TRUE
        );

        if l_oper.oper_type is null then
            l_visa.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
            l_visa.is_invalid := com_api_type_pkg.TRUE;

            trc_log_pkg.warn(
                i_text        => 'OPERATION_TYPE_EXCEPT'
              , i_env_param1  => l_visa.trans_code || l_visa.trans_code_qualifier || l_visa.mcc
              , i_env_param2  => l_standard_id -- i_standard_id
              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id   => l_visa.id
            );
            g_error_flag := com_api_type_pkg.TRUE;
        end if;
        
        -- post assignment
        if l_visa.trans_code in (
            vis_api_const_pkg.TC_SALES
          , vis_api_const_pkg.TC_VOUCHER
          , vis_api_const_pkg.TC_CASH
        ) then
            iss_api_bin_pkg.get_bin_info(
                i_card_number      => l_visa.card_number
              , o_iss_inst_id      => l_iss_inst_id
              , o_iss_network_id   => l_iss_network_id
              , o_card_inst_id     => l_card_inst_id
              , o_card_network_id  => l_card_network_id
              , o_card_type        => l_card_type_id
              , o_card_country     => l_country_code
              , o_bin_currency     => l_bin_currency
              , o_sttl_currency    => l_sttl_currency
            );

            -- if card BIN not found, then mark record as invalid
            if l_card_inst_id is null then
                l_visa.is_invalid := com_api_type_pkg.TRUE;
                l_iss_inst_id     := i_inst_id;
                l_iss_network_id  := ost_api_institution_pkg.get_inst_network(i_inst_id);

                trc_log_pkg.warn(
                    i_text        => 'BIN_NOT_FOUND_BY_CARD_NUMBER'
                  , i_env_param1  => iss_api_card_pkg.get_card_mask(l_visa.card_number)
                  , i_env_param2  => substr(l_visa.card_number, 1, 6)
                  , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , i_object_id   => l_visa.id
                );
            end if;

            if l_acq_inst_id is null then
            begin
                l_acq_inst_id    := iss_api_bin_pkg.get_bin(
                                        i_bin           => l_visa.acq_inst_bin
                                      , i_mask_error    => com_api_type_pkg.TRUE
                                    ).inst_id;
                l_acq_network_id := ost_api_institution_pkg.get_inst_network(l_acq_inst_id);
            exception
                when others then
                    if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                        l_acq_inst_id      := null;
                        l_acq_network_id   := null;
                    else
                        raise;
                    end if;
            end;
            end if;

            if l_acq_inst_id is null then
                l_acq_network_id := i_network_id;
                l_acq_inst_id    := net_api_network_pkg.get_inst_id(l_network_id);
            end if;

            net_api_sttl_pkg.get_sttl_type(
                i_iss_inst_id      => l_iss_inst_id
              , i_acq_inst_id      => l_acq_inst_id
              , i_card_inst_id     => l_card_inst_id
              , i_iss_network_id   => l_iss_network_id
              , i_acq_network_id   => l_acq_network_id
              , i_card_network_id  => l_card_network_id
              , i_acq_inst_bin     => l_visa.acq_inst_bin
              , o_sttl_type        => l_sttl_type
              , o_match_status     => l_match_status
              , i_oper_type        => l_oper.oper_type
            );

        -- assign dispute id
        else
            assign_dispute(
                io_visa           => l_visa
              , o_iss_inst_id     => l_iss_inst_id
              , o_iss_network_id  => l_iss_network_id
              , o_acq_inst_id     => l_acq_inst_id
              , o_acq_network_id  => l_acq_network_id
              , o_sttl_type       => l_sttl_type
              , o_match_status    => l_match_status
            );
            -- dispute not found
            if l_visa.dispute_id is null then
                if l_visa.trans_code in (
                    vis_api_const_pkg.TC_SALES_CHARGEBACK
                  , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                  , vis_api_const_pkg.TC_CASH_CHARGEBACK
                  , vis_api_const_pkg.TC_SALES_CHARGEBACK_REV
                  , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                  , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV
                ) then

                    iss_api_bin_pkg.get_bin_info(
                        i_card_number      => l_visa.card_number
                      , o_iss_inst_id      => l_iss_inst_id
                      , o_iss_network_id   => l_iss_network_id
                      , o_card_inst_id     => l_card_inst_id
                      , o_card_network_id  => l_card_network_id
                      , o_card_type        => l_card_type_id
                      , o_card_country     => l_country_code
                      , o_bin_currency     => l_bin_currency
                      , o_sttl_currency    => l_sttl_currency
                    );

                    if l_iss_inst_id is null then
                        l_iss_network_id := l_network_id; --i_network_id;--src
                        l_iss_inst_id    := net_api_network_pkg.get_inst_id(i_network_id => l_network_id);
                    end if;
                    l_card_inst_id     := null;
                    l_card_network_id  := null;
                    l_card_type_id     := null;
                    l_country_code     := null;
                    l_bin_currency     := null;
                    l_sttl_currency    := null;

                    begin
                        l_acq_inst_id    := iss_api_bin_pkg.get_bin(
                                                i_bin           => l_visa.acq_inst_bin
                                              , i_mask_error    => com_api_type_pkg.TRUE
                                            ).inst_id; --dst
                        l_acq_network_id := ost_api_institution_pkg.get_inst_network(i_inst_id => l_acq_inst_id);
                    exception
                        when others then
                            if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                                l_acq_inst_id      := null;
                                l_acq_network_id   := null;
                            else
                                raise;
                            end if;
                    end;

                    if l_acq_inst_id is null then
                        l_acq_inst_id    := i_inst_id; --dst
                        l_acq_network_id := ost_api_institution_pkg.get_inst_network(i_inst_id => i_inst_id);
                    end if;

                elsif l_visa.trans_code in (
                    vis_api_const_pkg.TC_SALES
                  , vis_api_const_pkg.TC_VOUCHER
                  , vis_api_const_pkg.TC_CASH
                  , vis_api_const_pkg.TC_SALES_REVERSAL
                  , vis_api_const_pkg.TC_VOUCHER_REVERSAL
                  , vis_api_const_pkg.TC_CASH_REVERSAL
                ) then
                   iss_api_bin_pkg.get_bin_info(
                        i_card_number      => l_visa.card_number
                      , o_iss_inst_id      => l_iss_inst_id
                      , o_iss_network_id   => l_iss_network_id
                      , o_card_inst_id     => l_card_inst_id
                      , o_card_network_id  => l_card_network_id
                      , o_card_type        => l_card_type_id
                      , o_card_country     => l_country_code
                      , o_bin_currency     => l_bin_currency
                      , o_sttl_currency    => l_sttl_currency
                    );

                    if l_iss_inst_id is null then
                        l_iss_inst_id     := i_inst_id; --dst
                        l_iss_network_id  := ost_api_institution_pkg.get_inst_network(i_inst_id => i_inst_id);
                    end if;
                    l_card_inst_id     := null;
                    l_card_network_id  := null;
                    l_card_type_id     := null;
                    l_country_code     := null;
                    l_bin_currency     := null;
                    l_sttl_currency    := null;

                    begin
                        l_acq_inst_id    := iss_api_bin_pkg.get_bin(
                                                i_bin           => l_visa.acq_inst_bin
                                              , i_mask_error    => com_api_type_pkg.TRUE
                                            ).inst_id;
                        l_acq_network_id := ost_api_institution_pkg.get_inst_network(i_inst_id => l_acq_inst_id);--src
                    exception
                        when others then
                            if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                                l_acq_inst_id      := null;
                                l_acq_network_id   := null;
                            else
                                raise;
                            end if;
                    end;

                    if l_acq_inst_id is null then
                        l_acq_network_id := l_network_id;--src
                        l_acq_inst_id    := net_api_network_pkg.get_inst_id(i_network_id => l_network_id);
                    end if;
                end if;

                if l_card_inst_id is null then
                    net_api_bin_pkg.get_bin_info(
                        i_card_number           => l_visa.card_number
                      , i_oper_type             => null
                      , i_terminal_type         => null
                      , i_acq_inst_id           => l_acq_inst_id
                      , i_acq_network_id        => l_acq_network_id
                      , i_msg_type              => null
                      , i_oper_reason           => null
                      , i_oper_currency         => null
                      , i_merchant_id           => null
                      , i_terminal_id           => null
                      , o_iss_inst_id           => l_iss_inst_id2
                      , o_iss_network_id        => l_iss_network_id2
                      , o_iss_host_id           => l_iss_host_id
                      , o_card_type_id          => l_card_type_id
                      , o_card_country          => l_card_country
                      , o_card_inst_id          => l_card_inst_id
                      , o_card_network_id       => l_card_network_id
                      , o_pan_length            => l_pan_length
                      , i_raise_error           => com_api_type_pkg.FALSE
                    );
                end if;

                net_api_sttl_pkg.get_sttl_type(
                    i_iss_inst_id      => l_iss_inst_id
                  , i_acq_inst_id      => l_acq_inst_id
                  , i_card_inst_id     => l_card_inst_id
                  , i_iss_network_id   => l_iss_network_id
                  , i_acq_network_id   => l_acq_network_id
                  , i_card_network_id  => l_card_network_id
                  , i_acq_inst_bin     => l_visa.acq_inst_bin
                  , o_sttl_type        => l_sttl_type
                  , o_match_status     => l_match_status
                  , i_oper_type        => l_oper.oper_type
                );
            end if;
        end if;

        -- Settlement in EUR is used for some TC(s)
        if l_visa.trans_code in (
               vis_api_const_pkg.TC_SALES
             , vis_api_const_pkg.TC_VOUCHER
             , vis_api_const_pkg.TC_CASH
             , vis_api_const_pkg.TC_SALES_REVERSAL
             , vis_api_const_pkg.TC_VOUCHER_REVERSAL
             , vis_api_const_pkg.TC_CASH_REVERSAL
           )
           and l_visa.oper_currency = com_api_currency_pkg.EURO
        then
            cmn_api_standard_pkg.get_param_value(
               i_inst_id      => l_iss_inst_id
             , i_standard_id  => l_standard_id --i_standard_id
             , i_object_id    => i_host_id
             , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
             , i_param_name   => vis_api_const_pkg.EURO_SETTLEMENT
             , o_param_value  => l_euro_settlement
             , i_param_tab    => l_param_tab
            );
            if l_euro_settlement = com_api_type_pkg.TRUE then
                l_visa.network_amount   := l_visa.sttl_amount;
                l_visa.network_currency := l_visa.sttl_currency;
                l_visa.sttl_amount      := l_visa.oper_amount;
                l_visa.sttl_currency    := l_visa.oper_currency;
            end if;
        end if;

        l_visa.card_id := iss_api_card_pkg.get_card_id(i_card_number => l_visa.card_number);
        l_visa.card_mask := iss_api_card_pkg.get_card_mask(i_card_number => l_visa.card_number);

        l_visa.status := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;

        l_oper.match_status := l_match_status;

        l_oper.sttl_type := l_sttl_type;
        if l_oper.sttl_type is null then
            l_visa.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
            l_visa.is_invalid := com_api_type_pkg.TRUE;

            trc_log_pkg.warn(
                i_text        => 'UNABLE_TO_DEFINE_SETTLEMENT_TYPE'
              , i_env_param1  => l_iss_inst_id
              , i_env_param2  => l_acq_inst_id
              , i_env_param3  => l_card_inst_id
              , i_env_param4  => l_iss_network_id
              , i_env_param5  => l_acq_network_id
              , i_env_param6  => l_card_network_id
              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id   => l_visa.id
            );

            g_error_flag := com_api_type_pkg.TRUE;
        end if;

        l_oper.msg_type := net_api_map_pkg.get_msg_type(
            i_network_msg_type  => l_visa.usage_code || l_visa.trans_code -- '107'
          , i_standard_id       => l_standard_id                          --i_standard_id
        );
        if l_oper.msg_type is null then
            l_visa.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
            l_visa.is_invalid := com_api_type_pkg.TRUE;

            trc_log_pkg.warn(
                i_text        => 'NETWORK_MESSAGE_TYPE_EXCEPT'
              , i_env_param1  => l_visa.usage_code||l_visa.trans_code
              , i_env_param2  => l_standard_id -- i_standard_id
              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id   => l_visa.id
            );
            g_error_flag := com_api_type_pkg.TRUE;
        end if;

        l_oper.id                := l_visa.id;
        l_oper.is_reversal       := l_visa.is_reversal;
        l_oper.oper_amount       := l_visa.oper_amount;
        l_oper.oper_currency     := l_visa.oper_currency;
        l_oper.sttl_amount       := l_visa.sttl_amount;
        l_oper.sttl_currency     := l_visa.sttl_currency;
        l_oper.oper_date         := l_visa.oper_date;
        l_oper.host_date         := null;
        l_oper.mcc               := l_visa.mcc;
        l_oper.originator_refnum := l_visa.rrn;
        l_oper.network_refnum    := l_visa.arn;
        l_oper.acq_inst_bin      := l_visa.acq_inst_bin;
        l_oper.merchant_number   := l_visa.merchant_number;
        l_oper.terminal_number   := l_visa.terminal_number;
        l_oper.merchant_name     := l_visa.merchant_name;
        l_oper.merchant_street   := l_visa.merchant_street;
        l_oper.merchant_city     := l_visa.merchant_city;
        l_oper.merchant_region   := l_visa.merchant_region;
        l_oper.merchant_postcode := l_visa.merchant_postal_code;

        l_oper.dispute_id        := l_visa.dispute_id;
        l_oper.original_id       := vis_api_fin_message_pkg.get_original_id(
                                        i_fin_rec          => l_visa
                                      , i_fee_rec          => null
                                      , o_need_original_id => l_need_original_id
                                    );

        if l_need_original_id = com_api_type_pkg.TRUE then
            io_no_original_id_tab(io_no_original_id_tab.count + 1) := l_visa;
        end if;

        if l_visa.dispute_id is null then
            l_oper.merchant_country  := l_visa.merchant_country;
            l_acq_part.merchant_id   := null;
            l_acq_part.terminal_id   := null;
            l_oper.terminal_type     :=
                case l_visa.mcc
                    when '6011'
                    then acq_api_const_pkg.TERMINAL_TYPE_ATM
                    else acq_api_const_pkg.TERMINAL_TYPE_POS
                end;
            l_iss_part.card_expir_date := date_yymm(l_visa.card_expir_date);
        else
            opr_api_operation_pkg.get_operation(
                i_oper_id              => l_visa.dispute_id
              , o_operation            => l_operation
            );
            l_oper.terminal_type      := l_operation.terminal_type;
            l_oper.merchant_country   := l_operation.merchant_country;
            opr_api_operation_pkg.get_participant (
                i_oper_id              => l_operation.id
                , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
                , o_participant        => l_participant
            );
            l_acq_part.merchant_id    := l_participant.merchant_id;
            l_acq_part.terminal_id    := l_participant.terminal_id;
            opr_api_operation_pkg.get_participant (
                i_oper_id              => l_operation.id
                , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ISSUER
                , o_participant        => l_participant
            );
            l_iss_part.card_expir_date := l_participant.card_expir_date;
        end if;
        l_oper.incom_sess_file_id      := i_incom_sess_file_id;

        l_iss_part.inst_id             := l_iss_inst_id;
        l_iss_part.network_id          := l_iss_network_id;
        l_iss_part.card_id             := l_visa.card_id;
        case when l_card_type_id is not null then
            l_iss_part.card_type_id    := l_card_type_id;
        else
            l_iss_part.card_type_id    := iss_api_card_pkg.get_card(
                                              i_card_number   => l_visa.card_number
                                            , i_mask_error    => com_api_type_pkg.TRUE
                                          ).card_type_id;
        end case;
        l_iss_part.card_seq_number     := replace(l_visa.card_seq_number, ' ', '');
        l_iss_part.client_id_type      := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
        l_iss_part.client_id_value     := l_visa.card_number;
        l_iss_part.customer_id         := iss_api_card_pkg.get_card(
                                              i_card_number   => l_visa.card_number
                                            , i_mask_error    => com_api_type_pkg.TRUE
                                          ).customer_id;
        l_iss_part.card_mask           := l_visa.card_mask;
        l_iss_part.card_number         := l_visa.card_number;
        l_iss_part.card_hash           := l_visa.card_hash;
        case when l_country_code is not null then
            l_iss_part.card_country    := l_country_code;
        else
            l_iss_part.card_country    := iss_api_card_pkg.get_card(
                                              i_card_number   => l_visa.card_number
                                            , i_mask_error    => com_api_type_pkg.TRUE
                                          ).country;
        end case;
        l_iss_part.card_inst_id        := l_card_inst_id;
        l_iss_part.card_network_id     := l_card_network_id;
        l_iss_part.split_hash          := com_api_hash_pkg.get_split_hash(l_visa.card_number);
        l_iss_part.card_service_code   := l_card_service_code;
        l_iss_part.account_amount      := null;
        l_iss_part.account_currency    := null;
        --l_oper.netw_date               := to_date(l_visa.central_proc_date,'YDDD');
        l_iss_part.account_number      := null;
        l_iss_part.auth_code           := l_visa.auth_code;

        l_acq_part.inst_id             := l_acq_inst_id;
        l_acq_part.network_id          := l_acq_network_id;
        l_acq_part.split_hash          := null;

        if  l_visa.trans_code in (vis_api_const_pkg.TC_SALES, vis_api_const_pkg.TC_VOUCHER, vis_api_const_pkg.TC_CASH)
            and l_visa.usage_code = com_api_type_pkg.TRUE
            and iss_api_card_pkg.get_card_id(i_card_number => l_visa.card_number) is null
        then
            l_oper.proc_mode := aut_api_const_pkg.AUTH_PROC_MODE_CARD_ABSENT;
            l_oper.status    := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
            trc_log_pkg.warn(
                i_text         => 'CARD_NOT_FOUND'
              , i_env_param1   => iss_api_card_pkg.get_card_mask(l_visa.card_number)
              , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id    => l_visa.id
            );
        end if;

        if l_visa.is_invalid = com_api_type_pkg.TRUE then
            g_error_flag  := com_api_type_pkg.TRUE;
            l_visa.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
            l_oper.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        end if;

        l_oper.clearing_sequence_num   := l_visa.clearing_sequence_num;
        l_oper.clearing_sequence_count := l_visa.clearing_sequence_count;

        if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
            -- Create operation with optional custom preprocessing
            vis_cst_incoming_pkg.before_creating_operation(
                io_oper     => l_oper
              , io_iss_part => l_iss_part
              , io_acq_part => l_acq_part
            );
            opr_api_create_pkg.create_operation(
                i_oper      => l_oper
              , i_iss_part  => l_iss_part
              , i_acq_part  => l_acq_part
            );
        end if;

        l_visa.host_inst_id := net_api_network_pkg.get_inst_id(i_network_id => l_visa.network_id);
        l_visa.proc_bin     := i_proc_bin;

        l_visa.id := vis_api_fin_message_pkg.put_message(
            i_fin_rec => l_visa
        );

        -- collect addendum TCRs
        /*??? for l_recnum in i_tc_buffer.first..i_tc_buffer.last loop
            if i_tc_buffer.exists(l_recnum) and substr(i_tc_buffer(l_recnum), 4, 1) not in ('0', '1', '7') then
                create_fin_addendum(
                    i_fin_msg_id        => l_visa.id
                  , i_raw_data          => i_tc_buffer(l_recnum)
                );
            end if;
        end loop;*/

        count_amount(
            io_amount_tab    => io_amount_tab
          , i_sttl_amount    => l_oper.sttl_amount
          , i_sttl_currency  => l_oper.sttl_currency
        );

        trc_log_pkg.debug(LOG_PREFIX || 'END');

        /*??? if i_validate_record = com_api_const_pkg.true
        then
            for l_recnum in i_tc_buffer.first .. i_tc_buffer.last loop
                if i_tc_buffer.exists(l_recnum) then
                    vis_api_reject_pkg.validate_visa_record_auth(
                        i_oper_id     => l_visa.id
                      , i_visa_data   => i_tc_buffer(l_recnum)
                    );
                end if;
            end loop;
            null;
        end if;*/

    end if; --if l_network_id = MC_NETWORK
end process_draft;

procedure process_returned (
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
    , i_record_number       in com_api_type_pkg.t_short_id
    , i_file_id             in com_api_type_pkg.t_long_id
    , i_batch_id            in com_api_type_pkg.t_medium_id
    , i_validate_record     in com_api_type_pkg.t_boolean
) is
    l_msg                   vis_returned%rowtype := NULL;
    l_orig_file_id          com_api_type_pkg.t_long_id;
    l_orig_batch_id         com_api_type_pkg.t_long_id;
    l_arn                   varchar2(23);

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer(i_tc_buffer.count), i_start, i_length));
    end;

    procedure insert_returned (
        i_msg in vis_returned%ROWTYPE
    ) is
    begin
        insert into vis_returned (
            id
            , dst_bin
            , src_bin
            , original_tc
            , original_tcq
            , original_tcr
            , src_batch_date
            , src_batch_number
            , item_seq_number
            , original_amount
            , original_currency
            , original_sttl_flag
            , crs_return_flag
            , reason_code1
            , reason_code2
            , reason_code3
            , reason_code4
            , reason_code5
            , original_id
            , file_id
            , batch_id
            , record_number
        )
        values (
            vis_returned_seq.nextval
            , i_msg.dst_bin
            , i_msg.src_bin
            , i_msg.original_tc
            , i_msg.original_tcq
            , i_msg.original_tcr
            , i_msg.src_batch_date
            , i_msg.src_batch_number
            , i_msg.item_seq_number
            , i_msg.original_amount
            , i_msg.original_currency
            , i_msg.original_sttl_flag
            , i_msg.crs_return_flag
            , i_msg.reason_code1
            , i_msg.reason_code2
            , i_msg.reason_code3
            , i_msg.reason_code4
            , i_msg.reason_code5
            , i_msg.original_id
            , i_msg.file_id
            , i_msg.batch_id
            , i_msg.record_number
       );
    end;
begin
    if substr(i_tc_buffer(i_tc_buffer.count),4,1)<>'9' then
        trc_log_pkg.error (
            i_text          => 'TCR9_NOT_FOUND_IN_RETURNED_ITEM'
            , i_env_param1  => i_record_number
        );
    end if;

    l_msg.dst_bin            := get_field(5, 6);
    l_msg.src_bin            := get_field(11, 6);
    l_msg.original_tc        := get_field(17, 2);
    l_msg.original_tcq       := get_field(19, 1);
    l_msg.original_tcr       := get_field(20, 1);
    l_msg.src_batch_date     := to_date(get_field(21, 5), 'YYDDD');
    l_msg.src_batch_number   := get_field(26, 6);
    l_msg.item_seq_number    := get_field(32, 4);
    l_msg.original_amount    := get_field(39, 12);
    l_msg.original_currency  := get_field(51, 3);
    l_msg.original_sttl_flag := get_field(54, 1);
    l_msg.crs_return_flag    := get_field(55, 1);
    l_msg.reason_code1       := get_field(36, 3);
    l_msg.reason_code2       := get_field(56, 3);
    l_msg.reason_code3       := get_field(59, 3);
    l_msg.reason_code4       := get_field(62, 3);
    l_msg.reason_code5       := get_field(65, 3);

    -- arn from the transaction being returned
    l_arn := substr(i_tc_buffer(1), 27, 23);

    -- mark original outgoing batch as returned
    update vis_batch b
       set b.is_returned = com_api_const_pkg.TRUE
     where b.batch_number = to_number(l_msg.src_batch_number)
       and trunc(b.proc_date) = l_msg.src_batch_date
       and exists (
               select 1
                 from vis_file f
                where f.id = b.file_id
                  and f.is_incoming = 0
           )
      returning b.id
              , b.file_id
      into      l_orig_batch_id
              , l_orig_file_id;

    -- mark original file as returned
    update vis_file
       set is_returned = com_api_const_pkg.TRUE
     where id = l_orig_file_id;

    -- mark original message as returned
    update vis_fin_message o
       set o.is_returned = com_api_const_pkg.TRUE
     where o.batch_id                         = l_orig_batch_id
       and o.file_id                          = l_orig_file_id
       and to_char(o.record_number, 'FM0000') = l_msg.item_seq_number
       and o.arn                              = l_arn
      returning id
      into      l_msg.original_id;

    if l_msg.original_id is null then
        com_api_error_pkg.raise_error (
            i_error         =>  'CAN_NOT_MARK_ORIGINAL_MESSAGE_AS_RETURNED'
            , i_env_param1  => l_orig_batch_id
            , i_env_param2  => l_orig_file_id
            , i_env_param3  => l_msg.item_seq_number
        );
    end if;

    l_msg.file_id            := i_file_id;
    l_msg.batch_id           := i_batch_id;
    l_msg.record_number      := i_record_number;

    insert_returned(l_msg);

    if i_validate_record = com_api_const_pkg.true
    then
        vis_api_reject_pkg.validate_visa_record_auth(
            i_oper_id     => null
            , i_visa_data => i_tc_buffer(i_tc_buffer.count)
        );
    end if;

end;

procedure process_money_transfer (
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
    , i_file_id             in com_api_type_pkg.t_long_id
    , i_record_number       in com_api_type_pkg.t_short_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_validate_record     in com_api_type_pkg.t_boolean
) is
    l_visa                  vis_api_type_pkg.t_visa_fin_mes_rec := null;
    l_det                   vis_money_transfer%rowtype          := null;
    l_currec                pls_integer                         := 1;
    l_invalid               com_api_type_pkg.t_boolean;

    function get_field (
        i_begin       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_tc_buffer(l_currec), i_begin, i_length), ' ');
    end;
begin
    init_fin_record (l_visa);

    -- message specific fields
    l_visa.trans_code  := get_field(1,2);
    l_visa.id          := null;
    l_det.pay_fee      := null;
    -- data from tcr0
    l_det.dst_bin      := get_field(5, 6);
    l_det.src_bin      := get_field(11, 6);
    l_det.trans_type   := get_field(17, 1);
    l_det.network_id   := get_field(18, 4);
    l_det.an_format    := get_field(22, 1);
    l_visa.card_number := get_field(23, 28);
    if l_det.an_format = 'A' then
       l_visa.card_number  := get_card_number( get_field(23, 19), l_visa.card_number );
    end if;
    l_det.origination_date    := to_date(get_field(51, 6),'YYMMDD');
    l_det.pay_amount          := get_field(62, 12);
    l_det.pay_currency        := get_field(74, 3);
    l_det.src_amount          := get_field(77, 12);
    l_det.src_currency        := get_field(89, 3);
    l_det.orig_ref_number     := get_field(92, 12);
    l_det.benef_ref_number    := get_field(104, 6);
    l_det.service_code        := get_field(110, 2);
    l_det.transfer_code       := get_field(112, 4); --, '5069');
    l_det.sendback_reason_code:= get_field(148, 2);  --, '5070');
    l_visa.settlement_flag    := get_field(150, 1);
    l_det.authorization_code  := get_field(152, 6);
    l_visa.central_proc_date  := date_yddd (get_field(163, 4));
    l_det.market_ind          := get_field(167, 1);
    l_visa.reimburst_attr     := get_field(168, 1);

    begin
        l_det.dst_inst_id := iss_api_bin_pkg.get_bin(
                                 i_bin          => l_det.dst_bin
                               , i_mask_error   => com_api_type_pkg.TRUE
                             ).inst_id;
    exception
        when others then
            if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                l_det.dst_inst_id := null;
            else
                raise;
            end if;
    end;
    if l_det.dst_inst_id is null then
        l_det.dst_inst_id := i_inst_id;
    end if;

    begin
        l_det.src_inst_id := iss_api_bin_pkg.get_bin(
                                 i_bin          => l_det.src_bin
                               , i_mask_error   => com_api_type_pkg.TRUE
                             ).inst_id;
    exception
        when others then
            if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                l_det.src_inst_id := null;
            else
                raise;
            end if;
    end;
    if l_det.src_inst_id is null then
        l_det.src_inst_id := net_api_network_pkg.get_inst_id(i_network_id);
    end if;

    -- iss_api_card_pkg.get_card_id
    if l_det.an_format = 'A' then
        --get_issuer_agent (
--            p_institution => l_visa.inst_id,
--            p_cardnum => l_visa.card_number,
--            p_agent => l_visa.agent,
--            p_invalid => v_invalid
--        );
        if l_invalid = com_api_const_pkg.TRUE then
            -- issuer agent fetched ok
            --l_visa.iss       :=  bf_300defs.c_true;
            l_det.dst_inst_id  := i_inst_id;
            l_det.src_inst_id  := net_api_network_pkg.get_inst_id(i_network_id);
        end if;
    end if;
    l_visa.status := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_visa.id := vis_api_fin_message_pkg.put_message(l_visa);

    --l_det.pay_currency     :=  network_utl.get_curr_code4inst(r_fin.institution, r_det.pay_cur);
    --l_det.source_currency  := network_utl.get_curr_code4inst(r_fin.institution, r_det.c049);

    insert into vis_money_transfer (
        id
        , pay_fee
        , dst_bin
        , src_bin
        , trans_type
        , network_id
        , an_format
        , origination_date
        , pay_amount
        , pay_currency
        , src_amount
        , src_currency
        , orig_ref_number
        , benef_ref_number
        , service_code
        , transfer_code
        , sendback_reason_code
        , authorization_code
        , market_ind
        , dst_inst_id
        , src_inst_id
    )
    values (
        l_visa.id
        , l_det.pay_fee
        , l_det.dst_bin
        , l_det.src_bin
        , l_det.trans_type
        , l_det.network_id
        , l_det.an_format
        , l_det.origination_date
        , l_det.pay_amount
        , l_det.pay_currency
        , l_det.src_amount
        , l_det.src_currency
        , l_det.orig_ref_number
        , l_det.benef_ref_number
        , l_det.service_code
        , l_det.transfer_code
        , l_det.sendback_reason_code
        , l_det.authorization_code
        , l_det.market_ind
        , l_det.dst_inst_id
        , l_det.src_inst_id
    );
    -- collect addendum tcrs
    while l_currec <= i_tc_buffer.count loop
        create_fin_addendum (
            i_fin_msg_id  => l_visa.id
            , i_raw_data  => i_tc_buffer(l_currec)
        );
        l_currec := l_currec + 1;
    end loop;

    if i_validate_record = com_api_const_pkg.true
    then
        vis_api_reject_pkg.validate_visa_record_auth(
            i_oper_id     => l_visa.id
            , i_visa_data => i_tc_buffer(l_currec)
        );
    end if;

end;

-- messages 10/20 fee collection/funds disbursement
procedure process_fee_funds (
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_file_id             in com_api_type_pkg.t_long_id
    , i_batch_id            in com_api_type_pkg.t_medium_id
    , i_record_number       in com_api_type_pkg.t_short_id
    , i_validate_record     in com_api_type_pkg.t_boolean
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
) is
    l_visa                  vis_api_type_pkg.t_visa_fin_mes_rec;
    l_fee                   vis_api_type_pkg.t_fee_rec;
    l_recnum                pls_integer := 1;

    l_card_inst_id          com_api_type_pkg.t_inst_id;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_country_code          com_api_type_pkg.t_country_code;
    l_bin_currency          com_api_type_pkg.t_curr_code;
    l_sttl_currency         com_api_type_pkg.t_curr_code;

    function get_field (
        i_start     in    pls_integer
      , i_length    in    pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_tc_buffer(l_recnum), i_start, i_length), ' ');
    end;

begin
    -- fee
    l_fee.file_id            := i_file_id;
    l_fee.pay_fee            := null;
    l_fee.dst_bin            := get_field(5, 6);
    l_fee.src_bin            := get_field(11, 6);
    l_fee.reason_code        := get_field(17, 4);
    if trim(get_field(21, 3)) is not null then
        l_fee.country_code   := com_api_country_pkg.get_country_code(i_visa_country_code => get_field(21, 3));
    end if;
    l_fee.event_date         := date_mmdd(get_field(24, 4));
    l_fee.pay_amount         := get_field(47, 12);
    l_fee.pay_currency       := get_field(59, 3);
    l_fee.src_amount         := get_field(62, 12);
    l_fee.src_currency       := get_field(74, 3);
    l_fee.message_text       := get_field(77, 70);
    l_fee.trans_id           := get_field(148, 15);
    l_fee.funding_source     := get_field(163, 1);
    l_fee.reimb_attr         := get_field(168, 1);

    begin
        l_fee.dst_inst_id := iss_api_bin_pkg.get_bin(
                                 i_bin          => l_fee.dst_bin
                               , i_mask_error   => com_api_type_pkg.TRUE
                             ).inst_id;
    exception
        when others then
            if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                l_fee.dst_inst_id := null;
            else
                raise;
            end if;
    end;
    if l_fee.dst_inst_id is null then
        l_fee.dst_inst_id := i_inst_id;
    end if;

    begin
        l_fee.src_inst_id := iss_api_bin_pkg.get_bin(
                                 i_bin          => l_fee.src_bin
                               , i_mask_error   => com_api_type_pkg.TRUE
                             ).inst_id;
    exception
        when others then
            if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                l_fee.src_inst_id := null;
            else
                raise;
            end if;
    end;
    if l_fee.src_inst_id is null then
        l_fee.src_inst_id := net_api_network_pkg.get_inst_id(i_network_id => i_network_id);
    end if;

    -- financial message
    init_fin_record(l_visa);

    l_visa.status            := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_visa.trans_code        := get_field(1, 2);
    l_visa.trans_code_qualifier := get_field(3, 1);
    l_visa.file_id           := i_file_id;
    l_visa.batch_id          := i_batch_id;
    l_visa.record_number     := i_record_number;
    l_visa.is_reversal       :=
        case
            when l_visa.trans_code = vis_api_const_pkg.TC_FEE_COLLECTION
              or
                     l_visa.trans_code = vis_api_const_pkg.TC_FEE_COLLECTION
                 and l_fee.reason_code = vis_api_const_pkg.FEE_RSN_CODE_AWARD_REVERSAL
              or     l_visa.trans_code = vis_api_const_pkg.TC_FUNDS_DISBURSEMENT
                 and l_fee.reason_code = vis_api_const_pkg.FEE_RSN_CODE_OFFSET_SUM_RVRSL
            then
                com_api_type_pkg.TRUE
            else
                com_api_type_pkg.FALSE
        end;
    l_visa.settlement_flag   := get_field(147, 1);

    if l_visa.is_incoming = com_api_type_pkg.TRUE then
        begin
            l_visa.inst_id    := iss_api_bin_pkg.get_bin(
                                     i_bin         => substr(i_tc_buffer(l_recnum), 11, 6)
                                   , i_mask_error  => com_api_type_pkg.TRUE
                                 ).inst_id;
            l_visa.network_id := ost_api_institution_pkg.get_inst_network(l_visa.inst_id);
        exception
            when others then
                if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                    l_visa.inst_id     := null;
                    l_visa.network_id  := null;
                else
                    raise;
                end if;
        end;
    else
        iss_api_bin_pkg.get_bin_info(
            i_card_number      => substr(i_tc_buffer(l_recnum), 28, 19)
          , o_iss_inst_id      => l_visa.inst_id
          , o_iss_network_id   => l_visa.network_id
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_card_type        => l_card_type_id
          , o_card_country     => l_country_code
          , o_bin_currency     => l_bin_currency
          , o_sttl_currency    => l_sttl_currency
        );
    end if;

    if l_visa.inst_id is null then
        l_visa.inst_id     := i_inst_id;
        l_visa.network_id  := i_network_id;
    end if;

    l_visa.host_inst_id      := net_api_network_pkg.get_inst_id(l_visa.network_id);
    l_visa.card_number       := substr(i_tc_buffer(l_recnum), 28, 19);
    l_visa.card_hash         := com_api_hash_pkg.get_card_hash(l_visa.card_number);
    l_visa.card_mask         := iss_api_card_pkg.get_card_mask(l_visa.card_number);
    l_visa.oper_currency     := substr(i_tc_buffer(l_recnum), 74, 3); -- Source Currency
    -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
    l_visa.oper_amount       := substr(i_tc_buffer(l_recnum), 62 -- Source Amount
      , 12 - case com_api_currency_pkg.get_currency_exponent(l_visa.oper_currency) when 0 then 2 else 0 end);

    l_visa.sttl_currency     := substr(i_tc_buffer(l_recnum), 59, 3); -- Dest Currency
    -- if currency exponent equal to zero then cut-off last two digits from amount in accordance with VISA rules
    l_visa.sttl_amount       := substr(i_tc_buffer(l_recnum), 47    -- Dest Amount
      , 12 - case com_api_currency_pkg.get_currency_exponent(l_visa.oper_currency) when 0 then 2 else 0 end);

    l_visa.oper_date         := to_date(substr(i_tc_buffer(l_recnum), 24, 4), 'MMDD');
    l_visa.central_proc_date := get_field(164, 4);
    l_visa.usage_code        := '1';

    l_visa.id                := vis_api_fin_message_pkg.put_message(l_visa);

    l_fee.id                 := l_visa.id;

    vis_api_fin_message_pkg.put_fee (
        i_fee_rec  => l_fee
    );

    -- collect addendum tcrs
    l_recnum := l_recnum + 1;
    while l_recnum <= i_tc_buffer.count loop
         create_fin_addendum (
            i_fin_msg_id  => l_visa.id
            , i_raw_data  => i_tc_buffer(l_recnum)
         );
         l_recnum := l_recnum + 1;
    end loop;

    /*-- link raw records to this record
    for l_currec in 1 .. i_tc_buffer.count
    loop
        if not i_tc_buffer (l_currec).utrnno is null then
            update visa_tcrraw_tab
               set rtn = r_fin.bo_utrnno
             where bo_utrnno = pt_trx (v_currec#).utrnno;
        end if;
    end loop; */

    if i_validate_record = com_api_const_pkg.true
    then
        vis_api_reject_pkg.validate_visa_record_auth(
            i_oper_id     => l_visa.id
            , i_visa_data => i_tc_buffer(l_recnum)
        );
    end if;

    if l_fee.reason_code in (vis_api_const_pkg.FEE_RSN_CODE_AWARD
                           , vis_api_const_pkg.FEE_RSN_CODE_AWARD_REVERSAL
                           , vis_api_const_pkg.FEE_RSN_CODE_OFFSET_SUM
                           , vis_api_const_pkg.FEE_RSN_CODE_OFFSET_SUM_RVRSL)
    then
        vis_api_fin_message_pkg.create_operation(
            i_fin_rec            => l_visa
          , i_standard_id        => i_standard_id
          , i_fee_rec            => l_fee
          , i_incom_sess_file_id => i_incom_sess_file_id
        );
    end if;
end process_fee_funds;

procedure process_retrieval_request (
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_file_id             in com_api_type_pkg.t_long_id
    , i_batch_id            in com_api_type_pkg.t_medium_id
    , i_record_number       in com_api_type_pkg.t_short_id
    , i_create_operation    in com_api_type_pkg.t_boolean
    , i_validate_record     in com_api_type_pkg.t_boolean
) is
    l_visa                  vis_api_type_pkg.t_visa_fin_mes_rec;
    l_retrieval             vis_api_type_pkg.t_retrieval_rec;
    l_currec                pls_integer := 1;

    l_iss_network_id        com_api_type_pkg.t_tiny_id;
    l_acq_network_id        com_api_type_pkg.t_tiny_id;
    l_sttl_type             com_api_type_pkg.t_dict_value;
    l_match_status          com_api_type_pkg.t_dict_value;

    l_card_inst_id          com_api_type_pkg.t_inst_id;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_country_code          com_api_type_pkg.t_country_code;
    l_bin_currency          com_api_type_pkg.t_curr_code;
    l_sttl_currency         com_api_type_pkg.t_curr_code;

    function get_field (
          i_start       in pls_integer
          , i_length    in pls_integer
    ) return varchar2 is
    begin
       return rtrim(substr(i_tc_buffer(l_currec), i_start, i_length), ' ');
    end;
begin
    init_fin_record (l_visa);

    -- data from tcr0
    l_retrieval.file_id         := i_file_id;
    l_visa.trans_code           := get_field(1, 2);
    l_visa.card_number          := get_card_number(get_field(5, 19), i_network_id);
    l_visa.arn                  := get_field(24, 23);
    l_visa.acq_business_id      := get_field(47, 8);
    l_visa.merchant_name        := get_field(74, 25);
    l_visa.merchant_city        := get_field(99, 13);
    l_visa.merchant_country     := com_api_country_pkg.get_country_code(
        i_visa_country_code => trim(get_field(112, 3))
    );
    l_visa.mcc                  := get_field(115, 4);
    l_visa.merchant_postal_code := get_field(119, 5);
    l_visa.merchant_region      := get_field(124, 3);

    l_visa.central_proc_date    := get_field(164, 4);

    if l_visa.is_incoming = com_api_type_pkg.TRUE then
        begin
            l_visa.inst_id      := iss_api_bin_pkg.get_bin(
                                       i_bin        => get_field(28, 6)
                                     , i_mask_error => com_api_type_pkg.TRUE
                                   ).inst_id;
            l_visa.network_id   := ost_api_institution_pkg.get_inst_network(l_visa.inst_id);
        exception
            when others then
                if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                    l_visa.inst_id     := null;
                    l_visa.network_id  := null;
                else
                    raise;
                end if;
        end;
    else
        iss_api_bin_pkg.get_bin_info (
            i_card_number      => l_visa.card_number
          , o_iss_inst_id      => l_visa.inst_id
          , o_iss_network_id   => l_visa.network_id
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_card_type        => l_card_type_id
          , o_card_country     => l_country_code
          , o_bin_currency     => l_bin_currency
          , o_sttl_currency    => l_sttl_currency
        );
    end if;

    if l_visa.inst_id is null then
        l_visa.inst_id     := i_inst_id;
        l_visa.network_id  := i_network_id;
    end if;

    l_visa.settlement_flag      := get_field(138, 1);
    l_visa.status               := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;

    l_retrieval.purchase_date        := date_mmdd (get_field(55, 4));
    l_retrieval.source_amount        := get_field(59, 12);
    l_retrieval.source_currency      := get_field(71, 3);
    l_retrieval.reason_code          := get_field(136, 2);
    l_retrieval.national_reimb_fee   := get_field(139, 12);
    l_retrieval.atm_account_sel      := get_field(151, 1);
    l_retrieval.req_id               := get_field(152, 12);
    l_retrieval.reimb_flag           := get_field(168, 1);

    l_currec := l_currec + 1;

    -- data from tcr1 present?
    if l_currec <= i_tc_buffer.count and substr(i_tc_buffer(l_currec), 4, 1) = '1' then
        -- tcr1 data
        l_retrieval.fax_number               := get_field(17, 16);
        l_retrieval.req_fulfill_method       := get_field(39, 1);
        l_retrieval.used_fulfill_method      := get_field(40, 1);
        l_retrieval.iss_rfc_bin              := get_field(41, 6);
        l_retrieval.iss_rfc_subaddr          := get_field(47, 7);
        l_retrieval.iss_billing_currency     := get_field(54, 3);
        l_retrieval.iss_billing_amount       := get_field(57, 12);
        l_retrieval.transaction_id           := get_field(69, 15);
        l_retrieval.excluded_trans_id_reason := get_field(84, 1);
        l_retrieval.crs_code                 := get_field(85, 1);
        l_retrieval.multiple_clearing_seqn   := get_field(86, 2);
        l_visa.pan_token                     := get_field(88, 16);
        l_currec                             := l_currec + 1;
    end if;

    -- data from tcr4 present?
    if l_currec <= i_tc_buffer.count and substr(i_tc_buffer(l_currec), 4, 1) = '4'
    then
      -- tcr4 data
        l_retrieval.product_code := get_field(17, 4);
        l_retrieval.contact_info := get_field(21, 25);
    end if;

    -- assign dispute id. if dispute found, then iss_inst and acq_inst taked from dispute.
    assign_dispute (
        io_visa             => l_visa
        , o_iss_inst_id     => l_retrieval.iss_inst_id
        , o_iss_network_id  => l_iss_network_id
        , o_acq_inst_id     => l_retrieval.acq_inst_id
        , o_acq_network_id  => l_acq_network_id
        , o_sttl_type       => l_sttl_type
        , o_match_status    => l_match_status
    );

    -- if dispute not found, then iss_inst taked from network, acq = file receiver.
    if l_visa.dispute_id is null then
        iss_api_bin_pkg.get_bin_info(
            i_card_number      => l_visa.card_number
          , o_iss_inst_id      => l_retrieval.iss_inst_id
          , o_iss_network_id   => l_iss_network_id
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_card_type        => l_card_type_id
          , o_card_country     => l_country_code
          , o_bin_currency     => l_bin_currency
          , o_sttl_currency    => l_sttl_currency
        );
        if l_retrieval.iss_inst_id is null then
            l_retrieval.iss_inst_id := net_api_network_pkg.get_inst_id(i_network_id);
        end if;

        begin
            l_retrieval.acq_inst_id := iss_api_bin_pkg.get_bin(
                                           i_bin        => get_field(28, 6)
                                         , i_mask_error => com_api_type_pkg.TRUE
                                       ).inst_id;
        exception
            when others then
                if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                    l_retrieval.acq_inst_id := null;
                else
                    raise;
                end if;
        end;

        if l_retrieval.acq_inst_id is null then
            l_retrieval.acq_inst_id := i_inst_id;
        end if;
    end if;

    l_visa.file_id       := i_file_id;
    l_visa.batch_id      := i_batch_id;
    l_visa.record_number := i_record_number;

    l_visa.id := vis_api_fin_message_pkg.put_message(
        i_fin_rec  => l_visa
    );

    l_retrieval.id := l_visa.id;

    vis_api_fin_message_pkg.put_retrieval(
        i_retrieval_rec  => l_retrieval
    );

    if i_validate_record = com_api_const_pkg.true
    then
        vis_api_reject_pkg.validate_visa_record_auth(
            i_oper_id     => l_visa.id
            , i_visa_data => i_tc_buffer(l_currec)
        );
    end if;

end;

procedure process_currency_rate (
     i_tc_buffer            in vis_api_type_pkg.t_tc_buffer
    , i_file_id              in com_api_type_pkg.t_long_id
    , i_proc_date            in date
    , i_inst_id              in com_api_type_pkg.t_inst_id
 ) is
    l_pos                   pls_integer;
    l_effective_date        date;
    l_recnum                pls_integer := 1;
    l_tcr                   varchar2(1);
    l_groups                pls_integer;
    l_action_code           varchar2(1);
    l_count                 number;
    l_ddmm                  date;
    l_dst_bin               com_api_type_pkg.t_bin;
    l_src_bin               com_api_type_pkg.t_bin;
    l_currency_entry        com_api_type_pkg.t_name;
    l_counter_currency_code com_api_type_pkg.t_curr_code;
    l_base_currency_code    com_api_type_pkg.t_curr_code;
    l_buy_scale             com_api_type_pkg.t_tiny_id;
    l_buy_conversion_rate   com_api_type_pkg.t_short_id;
    l_sell_scale            com_api_type_pkg.t_tiny_id;
    l_sell_conversion_rate  com_api_type_pkg.t_short_id;
    l_id                    com_api_type_pkg.t_long_id;
    l_seqnum                com_api_type_pkg.t_tiny_id;
    l_buy_rate              com_api_type_pkg.t_rate;
    l_sell_rate             com_api_type_pkg.t_rate;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2
    is
    begin
        return rtrim(substr(i_tc_buffer(l_recnum), i_start, i_length), ' ');
    end;

begin
    trc_log_pkg.debug('currency_rate is not realized: ' || i_tc_buffer(1));

    while l_recnum <= i_tc_buffer.count loop
        l_tcr := substr(i_tc_buffer(l_recnum), 4, 1);
        if l_tcr = 0 then
            l_dst_bin := get_field(5, 6);
            l_src_bin := get_field(11, 6);
            l_pos := 17;
            l_groups := 5;
        elsif l_tcr = 1 then
            l_pos := 5;
            l_groups := 6;
        end if;

        while l_groups > 0 loop
            -- get currency entry
            l_currency_entry := get_field(l_pos, 27);
            exit when l_currency_entry is null;

            l_action_code           := substr(l_currency_entry, 1, 1);
            l_counter_currency_code := substr(l_currency_entry, 2, 3);
            l_base_currency_code    := substr(l_currency_entry, 5, 3);
            l_ddmm                  := to_date(substr(l_currency_entry, 8, 4), 'DDMM');
            l_buy_scale             := to_number(substr(l_currency_entry, 12, 2));
            l_buy_conversion_rate   := to_number(substr(l_currency_entry, 14, 6));
            l_sell_scale            := to_number(substr(l_currency_entry, 20, 2));
            l_sell_conversion_rate  := to_number(substr(l_currency_entry, 22, 6));

            l_effective_date        := trunc(i_proc_date, 'YEAR') + to_number(to_char(l_ddmm, 'DDD')) - 1;
            l_buy_rate              := l_buy_conversion_rate * power(10, -1 * l_buy_scale);
            l_sell_rate             := l_sell_conversion_rate * power(10, -1 * l_sell_scale);

            insert into vis_currency_rate (
                id
                , file_id
                , dst_bin
                , src_bin
                , action_code
                , effective_date
                , counter_currency_code
                , base_currency_code
                , buy_rate
                , sell_rate
            )
            values (
                vis_currency_rate_seq.nextval
                , i_file_id
                , l_dst_bin
                , l_src_bin
                , l_action_code
                , l_effective_date
                , l_counter_currency_code
                , l_base_currency_code
                , l_buy_rate
                , l_sell_rate
            );

            -- add sell rate to com_rate (sell by fin institute)
            com_api_rate_pkg.set_rate (
                 o_id => l_id
                , o_seqnum => l_seqnum
                , o_count => l_count
                , i_src_currency => l_counter_currency_code
                , i_dst_currency => l_base_currency_code
                , i_rate_type => vis_api_const_pkg.VISA_STTL_SELL_RATE_TYPE
                , i_inst_id => i_inst_id
                , i_eff_date => l_effective_date
                , i_rate => l_sell_rate
                , i_inverted => com_api_type_pkg.FALSE
                , i_src_scale => 1
                , i_dst_scale => 1
                , i_exp_date => null
            );

            -- add buy rate to com_rate (buy by fin institute)
            com_api_rate_pkg.set_rate (
                 o_id => l_id
                , o_seqnum => l_seqnum
                , o_count => l_count
                , i_src_currency => l_counter_currency_code
                , i_dst_currency => l_base_currency_code
                , i_rate_type => vis_api_const_pkg.VISA_STTL_BUY_RATE_TYPE
                , i_inst_id => i_inst_id
                , i_eff_date => l_effective_date
                , i_rate => l_buy_rate
                , i_inverted => com_api_type_pkg.FALSE
                , i_src_scale => 1
                , i_dst_scale => 1
                , i_exp_date => null
            );
            l_pos    := l_pos + 27;
            l_groups := l_groups - 1;
        end loop;
        l_recnum := l_recnum + 1;
    end loop;

end;


procedure process_delivery_report (
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
    , i_file_id             in com_api_type_pkg.t_long_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_record_number       in com_api_type_pkg.t_short_id
    , i_validate_record     in com_api_type_pkg.t_boolean
) is
    l_rep                   vis_general_report%rowtype;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_tc_buffer(1), i_start, i_length), ' ');
    end;

begin
    l_rep.file_id          := i_file_id;
    l_rep.dst_bin          := get_field(5, 6);
    l_rep.src_bin          := get_field(11, 6);
    l_rep.report_text      := get_field(17, 132);
    l_rep.report_id        := get_field(150, 10);
    l_rep.rep_day_seq_num  := to_number(get_field(160, 1));
    l_rep.rep_line_seq_num := to_number(get_field(161, 7));
    l_rep.reimb_attr       := get_field(168, 1);
    l_rep.inst_id          := i_inst_id;

    insert into vis_general_report (
        id
        , file_id
        , dst_bin
        , src_bin
        , report_text
        , report_id
        , rep_day_seq_num
        , rep_line_seq_num
        , reimb_attr
        , inst_id
    )
    values (
        vis_general_report_seq.nextval
        , l_rep.file_id
        , l_rep.dst_bin
        , l_rep.src_bin
        , l_rep.report_text
        , l_rep.report_id
        , l_rep.rep_day_seq_num
        , l_rep.rep_line_seq_num
        , l_rep.reimb_attr
        , l_rep.inst_id
    );

    if i_validate_record = com_api_const_pkg.true
    then
        vis_api_reject_pkg.validate_visa_record_auth(
            i_oper_id     => null
            , i_visa_data => i_tc_buffer(1)
        );
    end if;

end;

procedure process_report_v1 (
    i_tc_buffer             in     vis_api_type_pkg.t_tc_buffer
    , i_file_id             in     com_api_type_pkg.t_long_id
    , i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_record_number       in     com_api_type_pkg.t_short_id
    , o_sttl_data              out vis_api_type_pkg.t_settlement_data_rec
) is
    l_rep                   vis_vss1%rowtype := null;

    function get_field (
        i_start        in pls_integer
        , i_length     in pls_integer
    ) return varchar2 is
    begin
        return rtrim (substr (i_tc_buffer (1), i_start, i_length), ' ');
    end;

begin
    l_rep.file_id         := i_file_id;
    l_rep.record_number   := i_record_number;
    l_rep.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    o_sttl_data.dst_bin         := get_field(5, 6);
    o_sttl_data.src_bin         := get_field(11, 6);
    o_sttl_data.sre_id          := get_field(17, 10);
    o_sttl_data.sttl_service    := get_field(27, 3);
    o_sttl_data.report_date     := date_yyyyddd(get_field (30, 7));
    l_rep.sre_level       := get_field(37, 1);
    o_sttl_data.report_group    := get_field(59, 1);
    o_sttl_data.report_subgroup := get_field(60, 1);
    o_sttl_data.rep_id_num      := get_field(61, 3);
    o_sttl_data.rep_id_sfx      := get_field(64, 2);
    l_rep.sub_sre_id      := get_field(66, 10);
    l_rep.sub_sre_name    := get_field(76, 15);
    l_rep.funds_ind       := get_field(91, 1);
    l_rep.entity_type     := get_field(92, 1);
    l_rep.entity_id1      := get_field(93, 18);
    l_rep.entity_id2      := get_field(111, 18);
    l_rep.proc_sind       := get_field(129, 1);
    l_rep.proc_id         := get_field(130, 10);
    l_rep.network_sind    := get_field(140, 1);
    l_rep.network_id      := get_field(141, 4);
    l_rep.reimb_attr      := get_field(168, 1);
    l_rep.inst_id         := i_inst_id;

    insert into vis_vss1 (
        id
        , file_id
        , record_number
        , status
        , dst_bin
        , src_bin
        , sre_id
        , sttl_service
        , report_date
        , sre_level
        , report_group
        , report_subgroup
        , rep_id_num
        , rep_id_sfx
        , sub_sre_id
        , sub_sre_name
        , funds_ind
        , entity_type
        , entity_id1
        , entity_id2
        , proc_sind
        , proc_id
        , network_sind
        , network_id
        , reimb_attr
        , inst_id
    )
    values (
        vis_vss1_seq.nextval
        , l_rep.file_id
        , l_rep.record_number
        , l_rep.status
        , o_sttl_data.dst_bin
        , o_sttl_data.src_bin
        , o_sttl_data.sre_id
        , o_sttl_data.sttl_service
        , o_sttl_data.report_date
        , l_rep.sre_level
        , o_sttl_data.report_group
        , o_sttl_data.report_subgroup
        , o_sttl_data.rep_id_num
        , o_sttl_data.rep_id_sfx
        , l_rep.sub_sre_id
        , l_rep.sub_sre_name
        , l_rep.funds_ind
        , l_rep.entity_type
        , l_rep.entity_id1
        , l_rep.entity_id2
        , l_rep.proc_sind
        , l_rep.proc_id
        , l_rep.network_sind
        , l_rep.network_id
        , l_rep.reimb_attr
        , l_rep.inst_id
    );
end;

procedure process_report_v2 (
    i_tc_buffer      in     vis_api_type_pkg.t_tc_buffer
  , i_file_id        in     com_api_type_pkg.t_long_id
  , i_inst_id        in     com_api_type_pkg.t_inst_id
  , i_record_number  in     com_api_type_pkg.t_short_id
  , o_sttl_data         out vis_api_type_pkg.t_settlement_data_rec
) is
    l_rep vis_vss2%rowtype := null;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_tc_buffer(1), i_start, i_length), ' ');
    end;

begin
    l_rep.file_id         := i_file_id;
    l_rep.record_number   := i_record_number;
    l_rep.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    o_sttl_data.dst_bin         := get_field(5, 6);
    o_sttl_data.src_bin         := get_field(11, 6);
    o_sttl_data.sre_id          := get_field(17, 10);
    o_sttl_data.up_sre_id       := get_field(27, 10);
    o_sttl_data.funds_id        := get_field(37, 10);
    o_sttl_data.sttl_service    := get_field(47, 3);
    o_sttl_data.sttl_currency   := get_field(50, 3);
    o_sttl_data.no_data         := get_field(53, 1);
    o_sttl_data.report_group    := get_field(59, 1);
    o_sttl_data.report_subgroup := get_field(60, 1);
    o_sttl_data.rep_id_num      := get_field(61, 3);
    o_sttl_data.rep_id_sfx      := get_field(64, 2);
    o_sttl_data.report_date     := date_yyyyddd (get_field(73, 7));

    if o_sttl_data.no_data = 'Y' and o_sttl_data.rep_id_num = '111' then
        o_sttl_data.sttl_date := null;
        o_sttl_data.date_from := null;
        o_sttl_data.date_to   := null;
    else
        o_sttl_data.sttl_date := date_yyyyddd (get_field(66, 7));
        o_sttl_data.date_from := date_yyyyddd (get_field(80, 7));
        o_sttl_data.date_to   := date_yyyyddd (get_field(87, 7));
    end if;

    o_sttl_data.bus_mode  := get_field(95, 1);
    l_rep.amount_type     := get_field(94, 1);
    l_rep.trans_count     := get_field(96, 15);
    l_rep.credit_amount   := get_field(111, 15);
    l_rep.debit_amount    := get_field(126, 15);
    l_rep.net_amount      := correct_sign (get_field(141, 15), get_field(156, 2));
    l_rep.reimb_attr      := get_field(168, 1);
    l_rep.inst_id         := i_inst_id;

    insert into vis_vss2(
        id
      , file_id
      , record_number
      , status
      , dst_bin
      , src_bin
      , sre_id
      , up_sre_id
      , funds_id
      , sttl_service
      , sttl_currency
      , no_data
      , report_group
      , report_subgroup
      , rep_id_num
      , rep_id_sfx
      , sttl_date
      , report_date
      , date_from
      , date_to
      , amount_type
      , bus_mode
      , trans_count
      , credit_amount
      , debit_amount
      , net_amount
      , reimb_attr
      , inst_id)
    values(
        vis_vss2_seq.nextval
      , l_rep.file_id
      , l_rep.record_number
      , l_rep.status
      , o_sttl_data.dst_bin
      , o_sttl_data.src_bin
      , o_sttl_data.sre_id
      , o_sttl_data.up_sre_id
      , o_sttl_data.funds_id
      , o_sttl_data.sttl_service
      , o_sttl_data.sttl_currency
      , o_sttl_data.no_data
      , o_sttl_data.report_group
      , o_sttl_data.report_subgroup
      , o_sttl_data.rep_id_num
      , o_sttl_data.rep_id_sfx
      , o_sttl_data.sttl_date
      , o_sttl_data.report_date
      , o_sttl_data.date_from
      , o_sttl_data.date_to
      , l_rep.amount_type
      , o_sttl_data.bus_mode
      , l_rep.trans_count
      , l_rep.credit_amount
      , l_rep.debit_amount
      , l_rep.net_amount
      , l_rep.reimb_attr
      , l_rep.inst_id
    );
end process_report_v2;

procedure process_report_v4 (
    i_tc_buffer      in     vis_api_type_pkg.t_tc_buffer
  , i_file_id        in     com_api_type_pkg.t_long_id
  , i_inst_id        in     com_api_type_pkg.t_inst_id
  , i_record_number  in     com_api_type_pkg.t_short_id
  , o_sttl_data         out vis_api_type_pkg.t_settlement_data_rec
) is
    l_rep            vis_vss4%rowtype := null;
    l_data           varchar2(200);

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(l_data, i_start, i_length), ' ');
    end;

begin
    l_data                := i_tc_buffer(1);
    l_rep.file_id         := i_file_id;
    l_rep.record_number   := i_record_number;
    l_rep.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    o_sttl_data.dst_bin         := get_field(5, 6);
    o_sttl_data.src_bin         := get_field(11, 6);
    o_sttl_data.sre_id          := get_field(17, 10);
    o_sttl_data.up_sre_id       := get_field(27, 10);
    o_sttl_data.funds_id        := get_field(37, 10);
    o_sttl_data.sttl_service    := get_field(47, 3); --, '5STL');
    o_sttl_data.sttl_currency   := get_field(50, 3);
    o_sttl_data.clear_currency  := get_field(53, 3);
    o_sttl_data.bus_mode        := get_field(56, 1); --, '5VBM');
    o_sttl_data.no_data         := get_field(57, 1);
    o_sttl_data.report_group    := get_field(59, 1);
    o_sttl_data.report_subgroup := get_field(60, 1);
    o_sttl_data.rep_id_num      := get_field(61, 3);
    o_sttl_data.rep_id_sfx      := get_field(64, 2);
    o_sttl_data.sttl_date       := case trim(o_sttl_data.rep_id_sfx)
                                       when 'M' then null
                                       else date_yyyyddd(get_field (66, 7))
                                   end;
    o_sttl_data.report_date     := date_yyyyddd(get_field(73, 7));
    o_sttl_data.date_from       := date_yyyyddd(get_field(80, 7));
    o_sttl_data.date_to         := date_yyyyddd(get_field(87, 7));
    o_sttl_data.charge_type     := get_field(94, 3); --, '5CHA');
    o_sttl_data.bus_tr_type     := get_field(97, 3); --, '5BTT');
    o_sttl_data.bus_tr_cycle    := get_field(100, 1); --, '5BTC');
    o_sttl_data.revers_ind      := get_field(101, 1);
    o_sttl_data.return_ind      := get_field(102, 1);
    o_sttl_data.jurisdict       := get_field(103, 2); --, '5JUR');
    o_sttl_data.routing         := get_field(105, 1);
    o_sttl_data.src_country     := get_field(106, 3);
    o_sttl_data.dst_country     := get_field(109, 3);
    o_sttl_data.src_region      := get_field(112, 2);
    o_sttl_data.dst_region      := get_field(114, 2);
    o_sttl_data.fee_level       := get_field(116, 16);
    o_sttl_data.cr_db_net       := get_field(132, 1);
    o_sttl_data.summary_level   := get_field(133, 2); --, '5SML');
    o_sttl_data.first_count     := 0;
    o_sttl_data.second_count    := 0;
    o_sttl_data.first_amount    := 0;
    o_sttl_data.second_amount   := 0;
    o_sttl_data.third_amount    := 0;
    o_sttl_data.fourth_amount   := 0;
    o_sttl_data.fifth_amount    := 0;
    l_rep.reimb_attr      := get_field(168, 1); -- obsolete, so it isn't passed to o_sttl_data
    l_rep.inst_id         := i_inst_id;

    if nvl(o_sttl_data.no_data, ' ') != 'Y' then
        -- there is tcr 1 record for this report
        if i_tc_buffer.count < 2 then
            com_api_error_pkg.raise_error(
                i_error      => 'VIS_TCR1_RECORD_IS_NOT_PRESENT'
              , i_env_param1 => i_file_id
              , i_env_param2 => i_record_number
            );
        end if;
        l_data                          := i_tc_buffer (2);
        o_sttl_data.currency_table_date := strange_date_yyyyddd(get_field (5, 7));
        o_sttl_data.first_count         := get_field(12, 15);
        o_sttl_data.second_count        := get_field(27, 15);
        o_sttl_data.first_amount        := correct_sign(get_field(42,  15), get_field(57,  2));
        o_sttl_data.second_amount       := correct_sign(get_field(59,  15), get_field(74,  2));
        o_sttl_data.third_amount        := correct_sign(get_field(76,  15), get_field(91,  2));
        o_sttl_data.fourth_amount       := correct_sign(get_field(93,  15), get_field(108, 2));
        o_sttl_data.fifth_amount        := correct_sign(get_field(110, 15), get_field(125, 2));
    end if;

    insert into vis_vss4(
        id
      , file_id
      , record_number
      , status
      , dst_bin
      , src_bin
      , sre_id
      , up_sre_id
      , funds_id
      , sttl_service
      , sttl_currency
      , clear_currency
      , bus_mode
      , no_data
      , report_group
      , report_subgroup
      , rep_id_num
      , rep_id_sfx
      , sttl_date
      , report_date
      , date_from
      , date_to
      , charge_type
      , bus_tr_type
      , bus_tr_cycle
      , revers_ind
      , return_ind
      , jurisdict
      , routing
      , src_country
      , dst_country
      , src_region
      , dst_region
      , fee_level
      , cr_db_net
      , summary_level
      , reimb_attr
      , currency_table_date
      , first_count
      , second_count
      , first_amount
      , second_amount
      , third_amount
      , fourth_amount
      , fifth_amount
      , inst_id)
    values(
        vis_vss4_seq.nextval
      , l_rep.file_id
      , l_rep.record_number
      , l_rep.status
      , o_sttl_data.dst_bin
      , o_sttl_data.src_bin
      , o_sttl_data.sre_id
      , o_sttl_data.up_sre_id
      , o_sttl_data.funds_id
      , o_sttl_data.sttl_service
      , o_sttl_data.sttl_currency
      , o_sttl_data.clear_currency
      , o_sttl_data.bus_mode
      , o_sttl_data.no_data
      , o_sttl_data.report_group
      , o_sttl_data.report_subgroup
      , o_sttl_data.rep_id_num
      , o_sttl_data.rep_id_sfx
      , o_sttl_data.sttl_date
      , o_sttl_data.report_date
      , o_sttl_data.date_from
      , o_sttl_data.date_to
      , o_sttl_data.charge_type
      , o_sttl_data.bus_tr_type
      , o_sttl_data.bus_tr_cycle
      , o_sttl_data.revers_ind
      , o_sttl_data.return_ind
      , o_sttl_data.jurisdict
      , o_sttl_data.routing
      , o_sttl_data.src_country
      , o_sttl_data.dst_country
      , o_sttl_data.src_region
      , o_sttl_data.dst_region
      , o_sttl_data.fee_level
      , o_sttl_data.cr_db_net
      , o_sttl_data.summary_level
      , l_rep.reimb_attr
      , o_sttl_data.currency_table_date
      , o_sttl_data.first_count
      , o_sttl_data.second_count
      , o_sttl_data.first_amount
      , o_sttl_data.second_amount
      , o_sttl_data.third_amount
      , o_sttl_data.fourth_amount
      , o_sttl_data.fifth_amount
      , l_rep.inst_id
    );
end;

procedure process_report_v6 (
    i_tc_buffer      in     vis_api_type_pkg.t_tc_buffer
  , i_file_id        in     com_api_type_pkg.t_long_id
  , i_inst_id        in     com_api_type_pkg.t_inst_id
  , i_record_number  in     com_api_type_pkg.t_short_id
  , o_sttl_data         out vis_api_type_pkg.t_settlement_data_rec
) is
    l_rep  vis_vss6%rowtype := null;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_tc_buffer(1), i_start, i_length ), ' ');
    end;

begin
    l_rep.file_id        := i_file_id;
    l_rep.record_number  := i_record_number;
    l_rep.status         := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    o_sttl_data.dst_bin        := get_field(5, 6);
    o_sttl_data.src_bin        := get_field(11, 6);
    o_sttl_data.sre_id         := get_field(17, 10);
    l_rep.proc_id        := get_field(27, 10);
    l_rep.clear_bin      := get_field(37, 10);
    o_sttl_data.clear_currency := get_field(47, 3);
    o_sttl_data.sttl_service   := get_field(50, 3); --, '5STL');
    o_sttl_data.bus_mode       := get_field(53, 1); --, '5VBM');
    o_sttl_data.no_data        := get_field(54, 1);
    o_sttl_data.report_group   := get_field(59, 1);
    o_sttl_data.report_subgroup:= get_field(60, 1);
    o_sttl_data.rep_id_num     := get_field(61, 3);
    o_sttl_data.rep_id_sfx     := get_field(64, 2);
    o_sttl_data.sttl_date      := date_yyyyddd(get_field(66, 7));
    o_sttl_data.report_date    := date_yyyyddd(get_field(73, 7));
    l_rep.fin_ind        := get_field(80, 1);
    l_rep.clear_only     := get_field(81, 1);
    o_sttl_data.bus_tr_type    := get_field(82, 3); --, '5BTT');
    o_sttl_data.bus_tr_cycle   := get_field(85, 1); --, '5BTC');
    o_sttl_data.revers_ind     := get_field(86, 1);
    l_rep.trans_dispos   := get_field(87, 2); --, '5TDP');
    l_rep.trans_count    := get_field(89, 15);
    l_rep.amount         := correct_sign(get_field(104, 15), get_field(119, 2) );
    o_sttl_data.summary_level  := get_field(121, 2); --, '5SML');
    l_rep.crs_date       := date_ddmmmyy(get_field(123, 7));
    l_rep.reimb_attr     := get_field(168, 1);
    l_rep.inst_id        := i_inst_id;

    insert into vis_vss6(
        id
      , file_id
      , record_number
      , status
      , dst_bin
      , src_bin
      , sre_id
      , proc_id
      , clear_bin
      , clear_currency
      , sttl_service
      , bus_mode
      , no_data
      , report_group
      , report_subgroup
      , rep_id_num
      , rep_id_sfx
      , sttl_date
      , report_date
      , fin_ind
      , clear_only
      , bus_tr_type
      , bus_tr_cycle
      , reversal
      , trans_dispos
      , trans_count
      , amount
      , summary_level
      , reimb_attr
      , inst_id
      , crs_date)
    values(
        vis_vss6_seq.nextval
      , l_rep.file_id
      , l_rep.record_number
      , l_rep.status
      , o_sttl_data.dst_bin
      , o_sttl_data.src_bin
      , o_sttl_data.sre_id
      , l_rep.proc_id
      , l_rep.clear_bin
      , o_sttl_data.clear_currency
      , o_sttl_data.sttl_service
      , o_sttl_data.bus_mode
      , o_sttl_data.no_data
      , o_sttl_data.report_group
      , o_sttl_data.report_subgroup
      , o_sttl_data.rep_id_num
      , o_sttl_data.rep_id_sfx
      , o_sttl_data.sttl_date
      , o_sttl_data.report_date
      , l_rep.fin_ind
      , l_rep.clear_only
      , o_sttl_data.bus_tr_type
      , o_sttl_data.bus_tr_cycle
      , o_sttl_data.revers_ind
      , l_rep.trans_dispos
      , l_rep.trans_count
      , l_rep.amount
      , o_sttl_data.summary_level
      , l_rep.reimb_attr
      , l_rep.inst_id
      , l_rep.crs_date
    );
end;

procedure process_settlement_data(
    i_tc_buffer             in     vis_api_type_pkg.t_tc_buffer
    , i_file_id             in     com_api_type_pkg.t_long_id
    , i_record_number       in     com_api_type_pkg.t_short_id
    , i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_host_id             in     com_api_type_pkg.t_tiny_id
    , i_standard_id         in     com_api_type_pkg.t_tiny_id
) is
    v_report_group          char(1) := substr(i_tc_buffer(1), 59, 1);
    v_report_subgroup       char(1) := substr(i_tc_buffer(1), 60, 1);
    l_sttl_data_rec         vis_api_type_pkg.t_settlement_data_rec;
begin
    case v_report_group || v_report_subgroup
    when 'V1' then
        process_report_v1 (i_tc_buffer     => i_tc_buffer
                         , i_file_id       => i_file_id
                         , i_inst_id       => i_inst_id
                         , i_record_number => i_record_number
                         , o_sttl_data     => l_sttl_data_rec);
    when 'V2' then
        process_report_v2 (i_tc_buffer     => i_tc_buffer
                         , i_file_id       => i_file_id
                         , i_inst_id       => i_inst_id
                         , i_record_number => i_record_number
                         , o_sttl_data     => l_sttl_data_rec);
    when 'V4' then
        process_report_v4 (i_tc_buffer     => i_tc_buffer
                         , i_file_id       => i_file_id
                         , i_inst_id       => i_inst_id
                         , i_record_number => i_record_number
                         , o_sttl_data     => l_sttl_data_rec);
    when 'V6' then
        process_report_v6 (i_tc_buffer     => i_tc_buffer
                         , i_file_id       => i_file_id
                         , i_inst_id       => i_inst_id
                         , i_record_number => i_record_number
                         , o_sttl_data     => l_sttl_data_rec);
    else
        trc_log_pkg.warn (
            i_text        =>  'VIS_UNKNOWN_REPORT_GROUP'
          , i_env_param1  =>  v_report_group
          , i_env_param2  =>  v_report_subgroup
        );
    end case;

    if l_sttl_data_rec.rep_id_num is not null then
        vis_cst_incoming_pkg.process_settlement_data(
            i_sttl_data   => l_sttl_data_rec
          , i_host_id     => i_host_id
          , i_standard_id => i_standard_id
        );
    end if;
end;

procedure process_multipurpose(
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
    , i_file_id             in com_api_type_pkg.t_long_id
    , i_record_number       in com_api_type_pkg.t_short_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_validate_record     in com_api_type_pkg.t_boolean
) is
    l_msg            vis_multipurpose%rowtype := null;--vis_api_type_pkg.t_visa_multipurpose_rec := null;
    l_data           varchar2(200);
    l_record_type    varchar2(6);
    l_auth_oper_type com_api_type_pkg.t_dict_value;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(substr(l_data, 35), i_start, i_length), ' ');
    end;

    function get_sms_oper_type (
        i_proc_code in varchar2
    ) return com_api_type_pkg.t_dict_value is
    begin
      case substr(i_proc_code, 1, 2)
        when '00' then
          return opr_api_const_pkg.OPERATION_TYPE_PURCHASE;
        when '01' then
          return opr_api_const_pkg.OPERATION_TYPE_ATM_CASH;
        else
          return null;
      end case;
    end;

begin
    l_data                := i_tc_buffer(1);
    l_record_type         := get_field(1, 6);

    -- we need to retrieve data only for Financial Transaction Record 1 (V22200) that contains general information about trxn.
    if l_record_type = vis_api_const_pkg.VISA_VSS_RECORD_TYPE_1 then

        l_msg.file_id         := i_file_id;
        l_msg.record_number   := i_record_number;
        l_msg.inst_id         := i_inst_id;
        l_msg.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
        l_msg.iss_acq         := get_field(7, 1);
        l_msg.mvv_code        := get_field(8, 10);
        l_msg.remote_terminal := get_field(18, 1);
        l_msg.charge_ind      := get_field(19, 1);
        l_msg.account_prod_id := get_field(20, 2);
        l_msg.bus_app_ind     := get_field(22, 2);
        l_msg.funds_source    := get_field(24, 1);
        l_msg.affiliate_bin   := get_field(28, 10);
        l_msg.sttl_date       := date_mmddyy(get_field(38, 6));
        l_msg.trxn_ind        := get_field(44, 15);
        l_msg.val_code        := get_field(59, 4);
        l_msg.refnum          := get_field(63, 12);
        l_msg.trace_num       := get_field(75, 6);
        l_msg.batch_num       := get_field(81, 4);
        l_msg.req_msg_type    := get_field(85, 4);
        l_msg.resp_code       := get_field(89, 2);
        l_msg.proc_code       := get_field(91, 6);
        l_msg.card_number     := get_field(97, 19);
        l_msg.trxn_amount     := get_field(116, 12);
        l_msg.currency_code   := get_field(128, 3);

        l_auth_oper_type      := get_sms_oper_type(l_msg.proc_code);

        -- matching with authorization
        begin
            select op.id
              into l_msg.match_auth_id
              from opr_operation op
             where op.originator_refnum = l_msg.refnum
               and op.oper_type = l_auth_oper_type
               and op.msg_type = aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
               and abs(trunc(op.oper_date) - trunc(l_msg.sttl_date)) <= 30
               and (
                     (op.is_reversal = 1
                      and l_msg.req_msg_type in (vis_api_const_pkg.SMS_MSG_TYPE_REVERSAL, vis_api_const_pkg.SMS_MSG_TYPE_REVERSAL_ADVICE)
                     )
                     or
                     (op.is_reversal = 0
                      and l_msg.req_msg_type not in (vis_api_const_pkg.SMS_MSG_TYPE_REVERSAL, vis_api_const_pkg.SMS_MSG_TYPE_REVERSAL_ADVICE)
                     )
               );
        exception
            when NO_DATA_FOUND then
                l_msg.match_auth_id := null;
        end;

        insert into vis_multipurpose(
            id
          , file_id
          , record_number
          , status
          , iss_acq
          , mvv_code
          , remote_terminal
          , charge_ind
          , account_prod_id
          , bus_app_ind
          , funds_source
          , affiliate_bin
          , sttl_date
          , trxn_ind
          , val_code
          , refnum
          , trace_num
          , batch_num
          , req_msg_type
          , resp_code
          , proc_code
          , card_number
          , trxn_amount
          , currency_code
          , match_auth_id
          , inst_id)
        values(
            vis_multipurpose_seq.nextval
          , l_msg.file_id
          , l_msg.record_number
          , l_msg.status
          , l_msg.iss_acq
          , l_msg.mvv_code
          , l_msg.remote_terminal
          , l_msg.charge_ind
          , l_msg.account_prod_id
          , l_msg.bus_app_ind
          , l_msg.funds_source
          , l_msg.affiliate_bin
          , l_msg.sttl_date
          , l_msg.trxn_ind
          , l_msg.val_code
          , l_msg.refnum
          , l_msg.trace_num
          , l_msg.batch_num
          , l_msg.req_msg_type
          , l_msg.resp_code
          , l_msg.proc_code
          , l_msg.card_number
          , l_msg.trxn_amount
          , l_msg.currency_code
          , l_msg.match_auth_id
          , l_msg.inst_id
        );

    end if;

    if i_validate_record = com_api_const_pkg.true
    then
        vis_api_reject_pkg.validate_visa_record_auth(
            i_oper_id     => l_msg.match_auth_id
            , i_visa_data => substr(l_data, 35)
        );
    end if;

end;

-- Process VISA clearing files for records TC 44 - Collection Batch Acknowledgment Transactions
procedure process_rejected (
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
    , i_record_number       in com_api_type_pkg.t_short_id -- record number in file
    , i_validate_record     in com_api_type_pkg.t_boolean default com_api_const_pkg.false
) is
    l_msg                   vis_reject%rowtype := NULL;
    l_orig_file_id          com_api_type_pkg.t_long_id;
    l_orig_batch_id         com_api_type_pkg.t_long_id;
    l_record_number         com_api_type_pkg.t_short_id;
    l_validation_result     com_api_type_pkg.t_boolean default com_api_const_pkg.true;
    l_reject_data_id        com_api_type_pkg.t_long_id;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer(i_tc_buffer.count), i_start, i_length));
    end get_field;

begin
    l_validation_result := com_api_const_pkg.true;
    -- Transaction Component Sequence Number must be = 9
    if substr(i_tc_buffer(i_tc_buffer.count),4,1)<>'9' then
        trc_log_pkg.error (
            i_text          => 'TCR9_NOT_FOUND_IN_RETURNED_ITEM'
            , i_env_param1  => i_record_number
        );
    end if;
    --1 save visa reject data
    l_msg.dst_bin            := get_field(5, 6);  -- Destination BIN
    l_msg.src_bin            := get_field(11, 6); -- Source BIN
    l_msg.original_tc        := get_field(1, 2);  -- Transaction Code
    l_msg.original_tcq       := get_field(3, 1);  -- Transaction Code Qualifier
    l_msg.original_tcr       := get_field(4, 1);  -- Transaction Component Sequence Number
    l_msg.src_batch_date     := to_date(get_field(17, 5), 'YYDDD'); -- Edit Package Batch Date
    l_msg.src_batch_number   := get_field(22, 6); -- Edit Package Batch Number
    l_msg.item_seq_number    := get_field(28, 8);  -- Interchange Window ID Number (?)
    l_msg.original_amount    := null; --get_field(39, 12); -- Source amount of the rejected transaction
    l_msg.original_currency  := null; --get_field(51, 3);  -- Source currency code of the rejected transaction
    l_msg.original_sttl_flag := null; --get_field(54, 1);  -- Settlement flag of the rejected transaction
    l_msg.crs_return_flag    := null; --get_field(55, 1);  -- Chargeback Reduction Service (CRS) Return Flag
    l_msg.reason_code1       := get_field(37, 3); -- Reject Reason Code 1
    l_msg.reason_code2       := null; -- Reject Reason Code 2
    l_msg.reason_code3       := null; -- Reject Reason Code 3
    l_msg.reason_code4       := null; -- Reject Reason Code 4
    l_msg.reason_code5       := null; -- Reject Reason Code 5
    l_msg.reason_code6       := null; -- Reject Reason Code 6
    l_msg.reason_code7       := null; -- Reject Reason Code 7
    l_msg.reason_code8       := null; -- Reject Reason Code 8
    l_msg.reason_code9       := null; -- Reject Reason Code 9
    l_msg.reason_code10      := null; -- Reject Reason Code 10

    --2 mark original outgoing batch as rejected
    update
        vis_batch b
    set
        b.is_rejected = com_api_const_pkg.TRUE
    where
        b.batch_number = to_number(l_msg.src_batch_number)
        and trunc(b.proc_date) = l_msg.src_batch_date
        and exists (
            select 1
              from vis_file f
             where f.id = b.file_id
               and f.is_incoming = 0
        )
    returning
        b.id
        , b.file_id
    into
        l_orig_batch_id
        , l_orig_file_id;

    -- mark original file as rejected
    update
        vis_file
    set
        is_rejected = com_api_const_pkg.TRUE
    where
        id = l_orig_file_id;

    -- arn from the transaction being rejected (not specified in TC44)
    --l_arn := substr(i_tc_buffer(1), 27, 23);

    -- select record_number from batch
    select min(record_number)
      into l_record_number
      from (select record_number -- Number of record in clearing file
                 , arn
                 , row_number() over(order by record_number) as rn -- Number of record in batch
              from vis_fin_message fm
             where batch_id = l_orig_batch_id
               and file_id  = l_orig_file_id
           ) f
     where f.rn >= to_number(l_msg.item_seq_number); -- in TC44 in 'Interchange Window ID Number') ?
     --and arn = l_arn;

    -- 3 mark original message as rejected
    update
        vis_fin_message
    set
        is_rejected = com_api_const_pkg.true
    where
        batch_id          = l_orig_batch_id
        and file_id       = l_orig_file_id
        and record_number = l_record_number
    returning
        id
    into
        l_msg.original_id;

    if l_msg.original_id is null then
        com_api_error_pkg.raise_error (
            i_error         =>  'CAN_NOT_MARK_ORIGINAL_MESSAGE_AS_REJECTED'
            , i_env_param1  => l_orig_batch_id
            , i_env_param2  => l_orig_file_id
            , i_env_param3  => l_msg.item_seq_number
        );
    end if;

    l_msg.file_id            := l_orig_file_id;
    l_msg.batch_id           := l_orig_batch_id;
    l_msg.record_number      := l_record_number;
    --
    vis_api_reject_pkg.put_reject(l_msg);

    -- 4 save operation rejected data in format 'Operation reject data'
    vis_api_reject_pkg.put_reject_data(
        i_reject_rec        => l_msg
        , o_reject_data_id  => l_reject_data_id
    );

    --5 validate record and save visa rejected codes
    if i_validate_record = com_api_const_pkg.true
    then
       l_validation_result :=
           vis_api_reject_pkg.validate_visa_record(
               i_reject_data_id => l_reject_data_id
               , i_visa_record  => i_tc_buffer(i_tc_buffer.count)
           );
       -- set that record failed on format validation
       if l_validation_result = com_api_const_pkg.false
       then
           update vis_reject_data
              --1(REJECTS DUE TO FORMAL/LOGICAL-FORMAL VALIDATIONS
              set reject_type = com_api_reject_pkg.REJECT_TYPE_PRIMARY_VALIDATION -- RJTP0001
            where id = l_reject_data_id;
       end if;
    end if;

end process_rejected;

-- process VISA Rejected Item File record
procedure process_rejected_item (
    i_tc_buffer             in com_api_type_pkg.t_text --vis_api_type_pkg.t_tc_buffer
    , i_record_number       in com_api_type_pkg.t_short_id
    , i_validate_record     in com_api_type_pkg.t_boolean default com_api_const_pkg.false
) is
    l_msg                   vis_reject%rowtype := NULL;
    l_orig_file_id          com_api_type_pkg.t_long_id;
    l_orig_batch_id         com_api_type_pkg.t_long_id;
    l_record_number         com_api_type_pkg.t_short_id;
    l_validation_result     com_api_type_pkg.t_boolean default com_api_const_pkg.true;
    l_reject_data_id        com_api_type_pkg.t_long_id;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer, i_start, i_length));
    end;

begin
    l_validation_result := com_api_const_pkg.true;
    -- Transaction Component Sequence Number must be = 9
    if substr(i_tc_buffer, 4, 1)<>'9' then
        trc_log_pkg.error (
            i_text          => 'TCR9_NOT_FOUND_IN_RETURNED_ITEM'
            , i_env_param1  => i_record_number
        );
        g_error_flag := com_api_type_pkg.true;
    end if;
    --1 save visa reject data
    l_msg.dst_bin            := get_field(5, 6);  -- Destination BIN
    l_msg.src_bin            := get_field(11, 6); -- Source BIN
    l_msg.original_tc        := get_field(1, 2);  -- Transaction Code
    l_msg.original_tcq       := get_field(3, 1);  -- Transaction Code Qualifier
    l_msg.original_tcr       := get_field(4, 1);  -- Transaction Component Sequence Number
    l_msg.src_batch_date     := to_date(get_field(21, 5), 'YYDDD'); -- Run Date
    l_msg.src_batch_number   := get_field(26, 6);  -- Batch Number
    l_msg.item_seq_number    := get_field(32, 4);  -- Batch Sequence
    l_msg.original_amount    := get_field(39, 12); -- Source Amount
    l_msg.original_currency  := get_field(51, 3);  -- Source Currency
    l_msg.original_sttl_flag := get_field(54, 1);  -- Settlement Flag
    l_msg.crs_return_flag    := null;-- get_field(55, 1);  -- Chargeback Reduction Service (CRS) Return Flag
    l_msg.reason_code1       := get_field(68, 4); -- Validation Message Code 1
    l_msg.reason_code2       := get_field(72, 4); -- Validation Message Code 2
    l_msg.reason_code3       := get_field(76, 4); -- Validation Message Code 3
    l_msg.reason_code4       := get_field(80, 4); -- Validation Message Code 4
    l_msg.reason_code5       := get_field(84, 4); -- Validation Message Code 5
    l_msg.reason_code6       := get_field(88, 4); -- Validation Message Code 6
    l_msg.reason_code7       := get_field(92, 4); -- Validation Message Code 7
    l_msg.reason_code8       := get_field(96, 4); -- Validation Message Code 8
    l_msg.reason_code9       := get_field(100, 4); -- Validation Message Code 9
    l_msg.reason_code10      := get_field(104, 4); -- Validation Message Code 10

    --2 mark original outgoing batch as rejected
    update
        vis_batch b
    set
        b.is_rejected = com_api_const_pkg.TRUE
    where
        b.batch_number = to_number(l_msg.src_batch_number)
        and trunc(b.proc_date) = l_msg.src_batch_date
        and exists (
            select 1
              from vis_file f
             where f.id = b.file_id
               and f.is_incoming = 0
        )
    returning
        b.id
        , b.file_id
    into
        l_orig_batch_id
        , l_orig_file_id;

    -- mark original file as rejected
    update
        vis_file
    set
        is_rejected = com_api_const_pkg.TRUE
    where
        id = l_orig_file_id;

    -- select record_number from batch
    select min(record_number)
      into l_record_number
      from (select record_number -- Number of record in clearing file
                 , row_number() over(order by record_number) as rn -- Number of record in batch
              from vis_fin_message fm
             where batch_id = l_orig_batch_id
               and file_id  = l_orig_file_id
           ) f
     where f.rn >= to_number(l_msg.item_seq_number);

    -- 3 mark original message as rejected
    update
        vis_fin_message
    set
        is_rejected = com_api_const_pkg.true
    where
        batch_id          = l_orig_batch_id
        and file_id       = l_orig_file_id
        and record_number = l_record_number
    returning
        id
    into
        l_msg.original_id;

    if l_msg.original_id is null then
        com_api_error_pkg.raise_error (
            i_error         =>  'CAN_NOT_MARK_ORIGINAL_MESSAGE_AS_REJECTED'
            , i_env_param1  => l_orig_batch_id
            , i_env_param2  => l_orig_file_id
            , i_env_param3  => l_msg.item_seq_number
        );
    end if;

    l_msg.file_id       := l_orig_file_id;
    l_msg.batch_id      := l_orig_batch_id;
    l_msg.record_number := l_record_number;

    vis_api_reject_pkg.put_reject(i_msg => l_msg);

    -- 4 save operation rejected data in format 'Operation reject data'
    vis_api_reject_pkg.put_reject_data(
        i_reject_rec        => l_msg
        , o_reject_data_id  => l_reject_data_id
    );

    --5 validate record and save visa rejected codes
    if i_validate_record = com_api_const_pkg.true
    then
       l_validation_result :=
           vis_api_reject_pkg.validate_visa_record(
               i_reject_data_id => l_reject_data_id
               , i_visa_record  => i_tc_buffer
           );
       -- set that record failed on format validation
       if l_validation_result = com_api_const_pkg.false
       then
           update vis_reject_data
              set reject_type = com_api_reject_pkg.REJECT_TYPE_PRIMARY_VALIDATION -- RJTP0001
            where id = l_reject_data_id;
       end if;
    end if;
end process_rejected_item;

procedure process_multipurpose_message (
    i_tc_buffer             in vis_api_type_pkg.t_tc_buffer
) is
    l_low_range                com_api_type_pkg.t_card_number;
    l_high_range               com_api_type_pkg.t_card_number;
    l_curr_code                com_api_type_pkg.t_curr_code;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_tc_buffer(1), i_start, i_length), ' ');
    end;

begin
    if get_field(4, 1) = '0' and get_field(35, 10) like vis_api_const_pkg.DCC_CURRENCY_TCR_MARKER then
        -- This is Account Billing Currency File record (DCC currencies)
        l_low_range  := to_number(get_field(59, 18));
        l_high_range := to_number(get_field(78, 18));
        l_curr_code  := get_field(97, 3);
        merge into
            vis_acc_billing_currency d
        using (
            select l_low_range as low_range, l_high_range as high_range,
                   l_curr_code as currency,  get_sysdate  as load_date
              from dual
        ) s
        on (
            d.low_range = s.low_range and d.high_range = s.high_range
        )
        when matched then
            update set
                d.currency = s.currency, d.load_date = s.load_date
        when not matched then
            insert (d.low_range, d.high_range, d.currency, d.load_date)
            values (s.low_range, s.high_range, s.currency, s.load_date);
    else
        trc_log_pkg.debug('unknown multipurpose message: ' ||i_tc_buffer(1));
    end if;
end;

-- Processing of VISA WAY4 XML Incoming Clearing Files
procedure process_way4_xml (
    i_network_id            in com_api_type_pkg.t_tiny_id
    --, i_test_option         in varchar2
    , i_dst_inst_id         in com_api_type_pkg.t_inst_id
    , i_create_operation    in com_api_type_pkg.t_boolean
    , i_host_inst_id        in com_api_type_pkg.t_inst_id default null
    --, i_validate_records    in com_api_type_pkg.t_boolean default com_api_const_pkg.false
    --, i_charset             in com_api_type_pkg.t_oracle_name := null
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process: ';
    l_tc                       varchar2(2);
    l_msg_code                 varchar2(32);
    l_tcr                      varchar2(1);
    l_tc_buffer                vis_api_type_pkg.t_tc_buffer;
    l_visa_file                vis_api_type_pkg.t_visa_file_rec;
    l_host_id                  com_api_type_pkg.t_tiny_id;
    l_standard_id              com_api_type_pkg.t_tiny_id;
    l_batch_id                 com_api_type_pkg.t_medium_id;
    l_record_number            com_api_type_pkg.t_long_id := 0;
    l_record_count             com_api_type_pkg.t_long_id := 0;
    l_total_amount             com_api_type_pkg.t_money := 0;
    l_total_count              com_api_type_pkg.t_long_id := 0;
    l_errors_count             com_api_type_pkg.t_long_id := 0;
    l_amount_tab               t_amount_count_tab;
    l_create_operation         com_api_type_pkg.t_boolean;
    l_no_original_id_tab       vis_api_type_pkg.t_visa_fin_mes_tab;
    l_operation_id_tab         com_api_type_pkg.t_number_tab;
    l_original_id_tab          com_api_type_pkg.t_number_tab;
    l_way_file                 t_way_file;
/*
    cursor cu_records_count is
        with xml_file as
            (
             select f.file_xml_contents xml_content
               from prc_session_file f
              where f.session_id = prc_api_session_pkg.get_session_id -- f.id = -1
            )
        select count(1) rec_count --Count of all operations (clearing messages) in given session id
           from xml_file s
              , xmltable('DocFile/DocList/Doc'
                   passing s.xml_content
                   columns msg_code   varchar2 (32) path 'TransType/TransCode/MsgCode'
                         , trn_amount number        path 'Transaction/Amount'
                 ) way4_set;
*/
begin
    vis_api_reject_pkg.g_process_run_date := sysdate;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_network_id [' || i_network_id
                             --|| '], i_test_option [' || i_test_option
                             || '], i_dst_inst_id [' || i_dst_inst_id
                             || '], i_create_operation [' || i_create_operation
                             || '], i_host_inst_id [' || i_host_inst_id || ']'
    );
    prc_api_stat_pkg.log_start;
/*
    open  cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;
*/
    get_doc_total_count (o_count => l_record_count);

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    -- get network communication standard
    l_host_id := net_api_network_pkg.get_default_host(
                     i_network_id   => i_network_id
                   , i_host_inst_id => i_host_inst_id
                 );
    l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

    trc_log_pkg.debug(
        i_text => 'l_host_id [' || l_host_id || '], l_standard_id [' || l_standard_id || ']'
    );

    l_record_count := 0;
    g_errors_count := 0;
    l_amount_tab.delete;
    l_no_original_id_tab.delete;
    l_operation_id_tab.delete;
    l_original_id_tab.delete;

    l_create_operation := nvl(i_create_operation, com_api_type_pkg.TRUE);

    for p in (
        select id session_file_id
             , record_count
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id -- id = -1
         order by id
    ) loop
        l_errors_count := 0;
        begin
            savepoint sp_visa_incoming_file;

            l_record_number := 0; -- 1;

            -- processing tag FileHeader
            process_xml_file_header(
                i_session_file_id  => p.session_file_id -- -1
              , i_network_id       => i_network_id
              , i_host_id          => l_host_id
              , i_standard_id      => l_standard_id
              , i_dst_inst_id      => i_dst_inst_id
              --, o_visa_file        => l_visa_file
              , o_way_file         => l_way_file
            );

            -- processing tag FileTrailer
            process_xml_file_trailer (
                i_session_file_id  => p.session_file_id -- -1
                , o_total_amount   => l_total_amount
                , o_total_count    => l_total_count
            );
            trc_log_pkg.debug(
                i_text => 'Processing session_file_id [' || p.session_file_id
                       || '], record_count [' || nvl(l_total_count,0) || ']'
            );
            --l_way_file.amount_total := l_total_amount;
            --l_way_file.trans_total  := l_total_count;

            trc_log_pkg.debug('update way_file: l_way_file.id[' || to_char(l_way_file.id)
                            || ']; l_total_amount[' || to_char(l_total_amount) || ']; '
                            || ']; l_total_count['  || to_char(l_total_count)  || ']; ');

            update way_file
               set amount_total  = l_total_amount
                   , trans_total = l_total_count
             where id = l_way_file.id;

            -- processing transactions - tags DocList/Doc
            if cu_xml_records%ISOPEN then
                close cu_xml_records;
            end if;
            open cu_xml_records (p.session_file_id); -- -1
            loop
                fetch cu_xml_records into l_xml_record;

                --exit when cu_xml_records%NOTFOUND;
                if cu_xml_records%NOTFOUND then --r.rn_desc = 1 then
                    g_errors_count := g_errors_count + l_errors_count;
                    l_errors_count := 0;
                    l_record_count := l_record_count + nvl(l_record_number,0); --r.cnt;

                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => g_errors_count
                    );
                    exit;
                end if;

                g_error_flag := com_api_type_pkg.FALSE;
                l_record_number := nvl(l_record_number,0) + 1; --r.record_number;

                l_msg_code := l_xml_record.msg_code;

                -- process returned transactions
                if l_msg_code in (way_api_const_pkg.MSG_CREDIT_FULFILMENT
                                , way_api_const_pkg.MSG_DEBIT_FULFILMENT)
                                   --, vis_api_const_pkg.TC_RETURNED_NONFINANCIAL)
                then
                    null;
                    /*process_returned(
                        i_tc_buffer       => l_tc_buffer
                      , i_record_number   => l_record_number
                      , i_file_id         => l_visa_file.id
                      , i_batch_id        => l_batch_id
                      , i_validate_record => i_validate_records
                    );*/

                -- process rejected transactions (TC 44 Collection Batch Acknowledgment Transactions)
                elsif l_msg_code = vis_api_const_pkg.TC_REJECTED
                then
                    null;
                    /*process_rejected(
                        i_tc_buffer       => l_tc_buffer
                      , i_record_number   => l_record_number
                      , i_validate_record => i_validate_records
                    );*/

                -- process draft transactions
                elsif l_msg_code in (way_api_const_pkg.MSG_RET_PRESENTMENT
                                   , way_api_const_pkg.MSG_CREDIT_PRESENTMENT
                                   , way_api_const_pkg.MSG_CASH_PRESENTMENT
                                   , way_api_const_pkg.MSG_RET_CHARGEBACK
                                   , way_api_const_pkg.MSG_CREDIT_CHARGEBACK
                                   , way_api_const_pkg.MSG_CASH_CHARGEBACK
                                   , way_api_const_pkg.MSG_RET_PRESENTMENT_REV
                                   , way_api_const_pkg.MSG_CREDIT_PRESENTMENT_REV
                                   , way_api_const_pkg.MSG_CASH_PRESENTMENT_REV
                                   , way_api_const_pkg.MSG_RET_CHARGEBACK_REV
                                   , way_api_const_pkg.MSG_CREDIT_CHARGEBACK_REV
                                   , way_api_const_pkg.MSG_CASH_CHARGEBACK_REV
                                   , way_api_const_pkg.MSG_ATM_PRESENTMENT
                                   , way_api_const_pkg.MSG_ATM_PRESENTMENT_REV
                                   --??? P2P
                                   , way_api_const_pkg.MSG_CH_DB_PRESENTMENT
                                   , way_api_const_pkg.MSG_CH_DB_PRESENTMENT_REV
                                   --???
                                   )
                then
                    process_draft(
                        --i_tc_buffer           => l_tc_buffer
                        i_network_id          => i_network_id
                      , i_host_id             => l_host_id
                      , i_standard_id         => l_standard_id
                      , i_inst_id             => l_way_file.inst_id
                      , i_proc_date           => l_way_file.proc_date
                      , i_file_id             => l_way_file.id
                      , i_incom_sess_file_id  => p.session_file_id
                      , i_batch_id            => l_batch_id
                      , i_record_number       => l_record_number
                      , i_proc_bin            => l_way_file.sender   --proc_bin
                      , io_amount_tab         => l_amount_tab
                      , i_create_operation    => l_create_operation
                      --, i_validate_record     => i_validate_records
                      , io_no_original_id_tab => l_no_original_id_tab
                      , i_xml_record          => l_xml_record
                    );

                -- process money transfer transactions
                elsif l_msg_code in (vis_api_const_pkg.TC_MONEY_TRANSFER
                                   , vis_api_const_pkg.TC_MONEY_TRANSFER2)
                then
                    null;
                    /*process_money_transfer(
                        i_tc_buffer        => l_tc_buffer
                      , i_file_id          => l_visa_file.id
                      , i_record_number    => l_record_number
                      , i_inst_id          => l_visa_file.inst_id
                      , i_network_id       => i_network_id
                      , i_validate_record  => i_validate_records
                    );*/

                -- process fee collections and funds diburstment
                elsif l_msg_code in (vis_api_const_pkg.TC_FEE_COLLECTION
                                   , vis_api_const_pkg.TC_FUNDS_DISBURSEMENT)
                then
                    null;
                    /*process_fee_funds(
                        i_tc_buffer        => l_tc_buffer
                      , i_network_id       => i_network_id
                      , i_standard_id      => l_standard_id
                      , i_inst_id          => l_visa_file.inst_id
                      , i_file_id          => l_visa_file.id
                      , i_batch_id         => l_batch_id
                      , i_record_number    => l_record_number
                      , i_validate_record  => i_validate_records
                    );*/

                -- process retrieval requests
                elsif l_msg_code in (vis_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY) then
                    null;
                    /*process_retrieval_request(
                        i_tc_buffer        => l_tc_buffer
                      , i_network_id       => i_network_id
                      , i_standard_id      => l_standard_id
                      , i_inst_id          => l_visa_file.inst_id
                      , i_file_id          => l_visa_file.id
                      , i_batch_id         => l_batch_id
                      , i_record_number    => l_record_number
                      , i_create_operation => l_create_operation
                      , i_validate_record  => i_validate_records
                    );*/

                -- process currency convertional rate updates
                elsif l_msg_code in (vis_api_const_pkg.TC_CURRENCY_RATE_UPDATE) then
                    null;
                    /*process_currency_rate (
                        i_tc_buffer        => l_tc_buffer
                      , i_file_id          => l_visa_file.id
                      , i_proc_date        => l_visa_file.proc_date
                      , i_inst_id          => l_visa_file.inst_id
                    );*/

                -- process general delivery report
                elsif l_msg_code in (vis_api_const_pkg.TC_GENERAL_DELIVERY_REPORT) then
                    null;
                    /*process_delivery_report(
                        i_tc_buffer        => l_tc_buffer
                      , i_file_id          => l_visa_file.id
                      , i_record_number    => l_record_number
                      , i_inst_id          => l_visa_file.inst_id
                      , i_validate_record  => i_validate_records
                    );*/

                -- process member settlement data
                elsif l_msg_code in (vis_api_const_pkg.TC_MEMBER_SETTLEMENT_DATA) then
                    null;
                    /*process_settlement_data(
                        i_tc_buffer      => l_tc_buffer
                      , i_file_id        => l_visa_file.id
                      , i_record_number  => l_record_number
                      , i_inst_id        => l_visa_file.inst_id
                      , i_host_id        => l_host_id
                      , i_standard_id    => l_standard_id
                    );*/

                -- process multipurpose messages
                elsif l_msg_code in (vis_api_const_pkg.TC_MULTIPURPOSE_MESSAGE) then
                    null;
                    /*process_multipurpose(
                        i_tc_buffer        => l_tc_buffer
                      , i_file_id          => l_visa_file.id
                      , i_record_number    => l_record_number
                      , i_inst_id          => l_visa_file.inst_id
                      , i_validate_record  => i_validate_records
                    );*/

                -- process DCC currencies
                elsif l_msg_code = vis_api_const_pkg.TC_MULTIPURPOSE_MESSAGE then
                    null;
                    -- process_multipurpose_message(l_tc_buffer);
                -- undefined MsgCode
                else 
                    g_error_flag := get_true;
                end if;

                if g_error_flag = com_api_type_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;
                if mod(l_record_number, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count + l_record_number --r.rn
                      , i_excepted_count => g_errors_count + l_errors_count
                    );
                end if;

            end loop;

            close cu_xml_records;

            -- It is case when original record is later than reversal record in the same file.
            if l_no_original_id_tab.count > 0 then
                for i in 1 .. l_no_original_id_tab.count loop
                    l_operation_id_tab(l_operation_id_tab.count + 1) := l_no_original_id_tab(i).id;
                    l_original_id_tab(l_original_id_tab.count + 1)   := vis_api_fin_message_pkg.get_original_id(
                                                                            i_fin_rec => l_no_original_id_tab(i)
                                                                          , i_fee_rec => null
                                                                        );
                end loop;

                forall i in 1 .. l_operation_id_tab.count
                    update opr_operation
                       set original_id = l_original_id_tab(i)
                     where id          = l_operation_id_tab(i);
            end if;

            prc_api_file_pkg.close_file(
                i_sess_file_id          => p.session_file_id
              , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_visa_incoming_file;

                g_errors_count := g_errors_count + p.record_count;
                l_errors_count := 0;
                l_record_count := l_record_count + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_count
                  , i_excepted_count => g_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );

                raise;
        end;
   end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => g_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    info_amount (
        i_amount_tab  => l_amount_tab
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        if cu_xml_records%ISOPEN then
            close cu_xml_records;
        end if;

        if cu_xml_file_header%ISOPEN then
            close cu_xml_file_header;
        end if;
/*
        if cu_records_count%isopen then
            close cu_records_count;
        end if;
*/
        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        l_amount_tab.delete;
        l_no_original_id_tab.delete;
        l_operation_id_tab.delete;
        l_original_id_tab.delete;

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end;

-- Processing of VISA Rejected Item Files
procedure process_rejected_item_file (
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id default null
    , i_validate_records    in com_api_type_pkg.t_boolean default com_api_const_pkg.false
) is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_rejected_item_file: ';
    l_host_id           com_api_type_pkg.t_tiny_id;
    l_standard_id       com_api_type_pkg.t_tiny_id;
    l_record_count      com_api_type_pkg.t_long_id := 0;
    l_errors_count      com_api_type_pkg.t_long_id := 0;
    l_amount_tab        t_amount_count_tab;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    vis_api_reject_pkg.g_process_run_date := sysdate;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_network_id [' || i_network_id
                             || '], i_host_inst_id [' || i_host_inst_id
                             || ']'
    );
    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_record_count
    );

    -- get network communication standard
    l_host_id     := net_api_network_pkg.get_default_host(i_network_id => i_network_id, i_host_inst_id => i_host_inst_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);
    trc_log_pkg.debug(
        i_text => 'l_host_id [' || l_host_id || '], l_standard_id [' || l_standard_id || ']'
    );

    --if l_standard_id != vis_api_const_pkg.VISA_BASEII_STANDARD then
    --    null;
    --end if;

    l_record_count := 0;
    g_errors_count := 0;
    l_amount_tab.delete;

    -- loop by files loaded in current session
    for p in (
        select id session_file_id
             , nvl(record_count, 0) as record_count
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) loop
        trc_log_pkg.debug(
            i_text => 'Processing session_file_id [' || p.session_file_id
                   || '], record_count [' || p.record_count || ']'
        );
        l_errors_count := 0;
        begin
            savepoint sp_visa_incoming_file;

            -- loop by records in current file
            for r in (
                select record_number
                     , raw_data
                     , count(*) over() cnt
                     , row_number() over(order by record_number) rn
                     , row_number() over(order by record_number desc) rn_desc
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number asc
            ) loop
                --trc_log_pkg.debug(
                --    i_text => ' session_file_id [' || p.session_file_id || ']' ||
                --              ', record_number [' || r.record_number || ']' ||
                --              ', raw_data [' || r.raw_data || ']'
                --);
                g_error_flag := com_api_type_pkg.FALSE;

                -- process VISA Rejected Item File record
                process_rejected_item(
                    i_tc_buffer       => r.raw_data
                  , i_record_number   => r.record_number
                  , i_validate_record => i_validate_records
                );

                if g_error_flag = com_api_type_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;

                if mod(r.rn, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count + r.rn
                      , i_excepted_count => g_errors_count + l_errors_count
                    );
                end if;

                if r.rn_desc = 1 then
                    g_errors_count := g_errors_count + l_errors_count;
                    l_errors_count := 0;
                    l_record_count := l_record_count + r.cnt;

                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => g_errors_count
                    );
                end if;
            end loop;

            prc_api_file_pkg.close_file(
                i_sess_file_id => p.session_file_id
              , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_visa_incoming_file;

                g_errors_count := g_errors_count + p.record_count;
                l_errors_count := 0;
                l_record_count := l_record_count + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_count
                  , i_excepted_count => g_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id => p.session_file_id
                  , i_status       => prc_api_const_pkg.FILE_STATUS_REJECTED
                );

                raise;
        end;
    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total => l_record_count
      , i_excepted_total  => g_errors_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        l_amount_tab.delete;

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_rejected_item_file;

end;
/
