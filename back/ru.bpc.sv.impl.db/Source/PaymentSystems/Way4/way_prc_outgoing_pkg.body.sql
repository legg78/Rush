create or replace package body way_prc_outgoing_pkg as
/*********************************************************
 *  Visa outgoing files API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 21.10.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: way_prc_outgoing_pkg <br />
 *  @headcom
 **********************************************************/

procedure mark_fin_messages (
    i_id                    in com_api_type_pkg.t_number_tab
  , i_file_id               in com_api_type_pkg.t_long_id
) is
begin
    trc_log_pkg.debug (
        i_text         => 'Mark financial messages'
    );

    forall i in 1..i_id.count
        update
            vis_fin_message_vw
        set
            file_id = i_file_id
            , status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
        where
            id = i_id(i);
end mark_fin_messages;

procedure process(
    i_network_id            in com_api_type_pkg.t_tiny_id
  , i_inst_id               in com_api_type_pkg.t_inst_id
  , i_host_inst_id          in com_api_type_pkg.t_inst_id
  , i_start_date            in date
  , i_end_date              in date
  , i_include_affiliate     in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE  
) is
    LOG_PREFIX       constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) ||'.process: ';
    
    l_record_count            com_api_type_pkg.t_long_id;
    l_standard_param          com_api_type_pkg.t_param_tab;
    l_inst_id                 com_api_type_pkg.t_inst_id_tab;
    l_host_inst_id            com_api_type_pkg.t_inst_id_tab;
    l_network_id              com_api_type_pkg.t_network_tab;
    l_host_id                 com_api_type_pkg.t_number_tab;
    l_standard_id             com_api_type_pkg.t_number_tab;    
    
    l_estimated_count         com_api_type_pkg.t_long_id := 0;
    l_processed_count         com_api_type_pkg.t_long_id := 0;

    l_sysdate                 date := get_sysdate;
    l_xml                     xmltype;
    
    l_ok_mess_id              com_api_type_pkg.t_number_tab;
    l_file_id                 com_api_type_pkg.t_long_id;
    l_file_seq_number         com_api_type_pkg.t_country_code;
    l_session_file_id         com_api_type_pkg.t_long_id;

    type t_xml_tab            is table of xmltype index by pls_integer;
    
    l_inst_clearing           t_xml_tab;
    
    e_cmid_not_found          exception;
    e_sender_not_found        exception;
    e_receiver_not_found      exception;

    procedure mark_ok_message is
    begin
        mark_fin_messages (
            i_id      => l_ok_mess_id
          , i_file_id => l_file_id
        );

        opr_api_clearing_pkg.mark_uploaded (
            i_id_tab  => l_ok_mess_id
        );

        l_ok_mess_id.delete;
    end mark_ok_message;

    procedure register_session_file (
        i_sender_id            in         com_api_type_pkg.t_name
      , i_receiver_id          in         com_api_type_pkg.t_name
      , o_session_file_id      out nocopy com_api_type_pkg.t_long_id
    ) is
        l_params               com_api_type_pkg.t_param_tab;    
        l_name_format_id       com_api_type_pkg.t_tiny_id   := way_api_const_pkg.WAY4_FILE_NAMING_ID;
        l_file_name            com_api_type_pkg.t_name;
    begin
        l_params.delete;
        rul_api_param_pkg.set_param (
            i_name       => 'WAY4_SENDER_ID'
            , i_value    => to_char(i_sender_id)
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'WAY4_RECEIVER_ID'
            , i_value    => to_char(i_receiver_id)
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'REPORT_DATE'
            , i_value    => to_char(get_sysdate, 'yyyymmdd')
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'FILE_TYPE'
            , i_value    => way_api_const_pkg.FILE_TYPE_CLEARING_WAY4
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => i_inst_id
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'FILE_PURPOSE'
            , i_value    => 'FLPSOUTG'
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'FILE_ATTR_ID'
            , i_value    => to_number(null)
            , io_params  => l_params
        );

        l_file_name := rul_api_name_pkg.get_name(
            i_format_id => l_name_format_id
          , i_param_tab => l_params
        );

        prc_api_file_pkg.open_file (
            o_sess_file_id  => o_session_file_id
            , i_file_name   => l_file_name
            , io_params     => l_params
        );
    end register_session_file;

    procedure register_uploaded_message(
        i_xml            in            sys.xmltype
      , o_ok_message_id     out nocopy com_api_type_pkg.t_number_tab
      , io_inst_count    in out nocopy com_api_type_pkg.t_count
      , io_inst_amount   in out nocopy com_api_type_pkg.t_money
    ) is
    begin
        trc_log_pkg.info('start register_uploaded_message');
        begin
            -- regenerate checksum
            select nvl(recs_count ,0)
                 , nvl(tot_amount, 0)
              into io_inst_count
                 , io_inst_amount
              from xmltable('/DocFile/FileTrailer/CheckSum'
                       passing i_xml
                       columns 
                           recs_count number(10)     path 'RecsCount'
                         , tot_amount number(22, 4)  path 'HashTotalAmount'
                   );  
        exception 
            when no_data_found then
                io_inst_count  := 0;
                io_inst_amount := 0;
        end;          
    
        trc_log_pkg.info(
            i_text       => 'start register_uploaded_message [#1] [#2]'
          , i_env_param1 =>  io_inst_count
          , i_env_param2 =>  io_inst_amount
        );
    
        if io_inst_count != 0 and io_inst_amount != 0 then

        -- get oper_id
        select oper_id
          bulk collect into o_ok_message_id
          from xmltable('/DocFile/DocList/Doc'
                   passing i_xml
                   columns
                       oper_id number(16) path 'DocRefSet/Parm[ParmCode[text()="DRN"]]/Value'
               );
        
        else
            o_ok_message_id(1) := null;
        end if;
               
    end register_uploaded_message; 

    procedure register_uploaded_file(
      i_session_file_id in com_api_type_pkg.t_long_id
    , i_network_id      in     com_api_type_pkg.t_network_id   default null
    , i_messages        in     number                          default null
    , i_amount          in     com_api_type_pkg.t_money        default null
    , i_proc_bin        in     com_api_type_pkg.t_tag          default null
    , io_file_id        in out com_api_type_pkg.t_long_id    
    , io_file_seq_num   in out com_api_type_pkg.t_country_code
      )
      is
      l_way_file_id     varchar2(3);
    begin
        if io_file_id is null then
        begin
        -- get way_file_id
            select 
                rtrim(regexp_substr(psf.file_name,'\d{3}.xml$',1,1), '.xml')
              into l_way_file_id
              from
              prc_session_file psf
            where id = i_session_file_id;
        exception 
            when no_data_found then
                l_way_file_id := null;
        end;
    
        insert into 
          vis_file vf (
            id
            , is_incoming
            , is_returned
            , network_id
            , proc_bin
            , proc_date
            , sttl_date
            , release_number
            , test_option
            , security_code
            , visa_file_id
            , batch_total
            , monetary_total
            , tcr_total
            , trans_total
            , src_amount
            , dst_amount
            , inst_id
            , session_file_id
            , is_rejected
          )
          values(
            vis_file_seq.nextval
            , 0
            , 0
            , i_network_id
            , i_proc_bin
            , get_sysdate
            , com_api_sttl_day_pkg.get_open_sttl_date(1001)
            , null              -- release_number
            , null              --test_option
            , null              --securiti code
            , l_way_file_id
            , null              --batch_total
            , null              --monetary_total
            , null              -- tcr_total
                , i_messages
                , i_amount
                , i_amount
            , null              -- inst_id
            , i_session_file_id
            , 0            
                  ) returning id, visa_file_id into io_file_id, io_file_seq_num;
          else 
              update vis_file vf
                set vf.trans_total = nvl(vf.trans_total, 0) + nvl(i_messages, 0)
                    , vf.src_amount = nvl(vf.src_amount, 0) + nvl(i_amount, 0)
                    , vf.dst_amount = nvl(vf.dst_amount, 0) + nvl(i_amount, 0)
              where
                vf.id = io_file_id;
          end if;
                
    end register_uploaded_file;

begin
    trc_log_pkg.debug (
        i_text  => 'WAY UFX outgoing clearing start'
    );

    prc_api_stat_pkg.log_start;

    -- fetch parameters
    select m.id host_id
         , m.inst_id host_inst_id
         , n.id network_id
         , r.inst_id
         , s.standard_id
      bulk collect into
           l_host_id
         , l_host_inst_id
         , l_network_id
         , l_inst_id
         , l_standard_id
      from net_network n
         , net_member m
         , net_interface i
         , net_member r
         , cmn_standard_object s
     where (n.id           = i_network_id    or i_network_id   is null)
       and n.id            = m.network_id
       and n.inst_id       = m.inst_id
       and (m.inst_id      = i_host_inst_id  or i_host_inst_id is null)
       and s.object_id     = m.id
       and s.entity_type   = net_api_const_pkg.ENTITY_TYPE_HOST
       and s.standard_type = cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING
       and (r.inst_id      = i_inst_id       or i_inst_id      is null
            or (i_include_affiliate = com_api_const_pkg.TRUE
                and i_inst_id is not null
                and r.inst_id in (select m.inst_id
                                    from net_interface i
                                       , net_member m
                                   where i.msp_member_id in (select id
                                                               from net_member
                                                              where network_id = i_network_id
                                                                and inst_id    = i_inst_id
                                                            )
                                     and m.id = i.consumer_member_id
                                  )
               )
           )
       and r.id = i.consumer_member_id
       and i.host_member_id = m.id;
    
    -- make estimated count
    for i in 1..l_host_id.count loop                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
        --l_record_count := vis_api_fin_message_pkg.estimate_messages_for_upload (
        l_record_count := way_api_fin_message_pkg.estimate_fin_for_upload (
            i_network_id      => l_network_id(i)
            , i_inst_id       => l_inst_id(i)
            , i_host_inst_id  => l_host_inst_id(i)
            , i_start_date    => trunc(i_start_date)
            , i_end_date      => trunc(i_end_date)
        );

        l_estimated_count := l_estimated_count + l_record_count;
    end loop;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => l_estimated_count
    );

    if l_estimated_count > 0 then
        for i in 1..l_host_id.count loop   
            -- get standard param
            for st_param in (select 
                                  p.name
                                from cmn_parameter p
                               where p.standard_id = l_standard_id(i)
                                order by p.id
                            ) loop              
                cmn_api_standard_pkg.get_param_value(
                      i_inst_id        => l_inst_id(i)
                      , i_standard_id  => l_standard_id(i)
                      , i_object_id    => l_host_id(i)
                      , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
                      , i_param_name   => st_param.name
                      , o_param_value  => l_standard_param(st_param.name)
                      , i_param_tab    => l_standard_param
                      );
            end loop;
            
            -- check mandatory params
            if l_standard_param(way_api_const_pkg.WAY4_SENDER) is null then
                trc_log_pkg.fatal(
                    i_text       => way_api_const_pkg.WAY4_SENDER || ' parameter for standard [#1] was not setted to any version or institute.'
                  , i_env_param1 => l_standard_id(i) 
                  );
                raise e_sender_not_found;

            elsif l_standard_param(way_api_const_pkg.WAY4_RECEIVER) is null then
                trc_log_pkg.fatal(
                    i_text       => way_api_const_pkg.WAY4_RECEIVER || ' parameter for standard [#1] was not setted to any version or institute.'
                  , i_env_param1 => l_standard_id(i) 
                  );                
                raise e_receiver_not_found;                  

            elsif l_standard_param(way_api_const_pkg.WAY4_CMID) is null then
                trc_log_pkg.fatal(
                    i_text       => way_api_const_pkg.WAY4_CMID || ' parameter for standard [#1] was not setted to any version or institute.'
                  , i_env_param1 => l_standard_id(i) 
                  );                
                raise e_cmid_not_found;

            end if;                                     

        -- open file
            if  l_session_file_id is null then
                register_session_file( 
                    i_sender_id       => l_standard_param(way_api_const_pkg.WAY4_SENDER)
                  , i_receiver_id     => l_standard_param(way_api_const_pkg.WAY4_RECEIVER)
                  , o_session_file_id => l_session_file_id
                );                
            end if;
        
        trc_log_pkg.debug (
            i_text  => LOG_PREFIX || 'l_session_file_id = ' || l_session_file_id
        );          

        -- get xml  
        select
            xmlelement("DocFile",
                xmlelement("FileHeader",
                    xmlforest(
                       'DOCUMENT'                                    "FileLabel"
                      , l_standard_param(way_api_const_pkg.WAY4_FORMAT_VERSION) "FormatVersion"
                      , l_standard_param(way_api_const_pkg.WAY4_SENDER)         "Sender"
                      , to_char(l_sysdate, 'yyyy-mm-dd')              "CreationDate"
                      , to_char(l_sysdate, 'hh24:mi:ss')              "CreationTime"
                      , '1'                                           "FileSeqNumber"
                      , l_standard_param(way_api_const_pkg.WAY4_RECEIVER)       "Receiver"
                             )
                          )
              , xmlelement("DocList",
                    xmlagg( 
                        xmlelement("Doc",
                            xmlelement("TransType",
                                xmlelement("TransCode",
                                    xmlelement("MsgCode", t.msg_code)
                                         )     
                                  , xmlelement("TransCondition", t.trans_condition)
                                  , case
                                        when length(t.REASON_DETAILS) > 3 or t.reason_code is not null or t.requirement is not null then
                                            xmlelement("DisputeRules",
                                                case 
                                                    when t.reason_code is not null then
                                                        xmlelement("ReasonCode", t.reason_code)
                                                end
                                              , case
                                                    when t.requirement is not null then 
                                                        xmlelement("Requirement", t.requirement)
                                                end
                                              , case
                                                    when length(t.REASON_DETAILS) > 3 then 
                                                        xmlelement("ReasonDetails", t.reason_details)                                                  
                                                end
                                                      ) 
                                    end 
                                      )
                          , xmlelement("DocRefSet",
                                xmlelement("Parm",
                                    xmlelement("ParmCode", 'ARN')
                                  , xmlelement("Value", t.arn)
                                          )
                              , xmlelement("Parm",
                                    xmlelement("ParmCode", 'AuthCode')
                                  , xmlelement("Value", t.auth_code)                                
                                          )
                              , xmlelement("Parm",
                                    xmlelement("ParmCode", 'DRN')
                                  , xmlelement("Value", t.drn)                                
                                          )
                              , xmlelement("Parm",
                                    xmlelement("ParmCode", 'RRN')
                                  , xmlelement("Value", t.rrn)                                
                                          )
                              , xmlelement("Parm",
                                    xmlelement("ParmCode", 'TRN')
                                  , xmlelement("Value", t.trn)                                
                                          )
                                  , case
                                        when t.OrigDRN is not null then            
                                        xmlelement("Parm",
                                    xmlelement("ParmCode", 'OrigDRN')
                                  , xmlelement("Value", t.OrigDRN)                                
                                          )
                                    end
                                  , case
                                        when t.PrevDRN is not null then
                                        xmlelement("Parm",
                                    xmlelement("ParmCode", 'PrevDRN')
                                  , xmlelement("Value", t.PrevDRN)                                
                                          )                                      
                                    end
                                      )
                            , xmlelement("LocalDt", to_char(t.local_dt, com_api_const_pkg.LOG_DATE_FORMAT))
                            , xmlelement("Description", t.descrp)
                            , xmlelement("SourceDtls",
                                  case 
                                      when t.sic is not null then
                                          xmlelement("SIC", t.sic)
                                  end
                                , case
                                      when t.mrc_country is not null then
                                          xmlelement("Country", t.mrc_country)
                                  end
                                , case
                                      when t.mrc_state is not null then
                                          xmlelement("State", t.mrc_state)
                                  end
                                , case
                                      when t.mrc_city is not null then
                                          xmlelement("City", t.mrc_city)
                                  end 
                                , case
                                      when t.src_mrc_id is not null then
                                          xmlelement("MerchantID", t.src_mrc_id)
                                  end
                                        )
                            , xmlelement("Originator",
                                  case
                                      when t.org_contr_num is not null then
                                          xmlelement("ContractNumber", t.org_contr_num)                                      
                                  end
                                , case
                                      when t.org_reltn is not null then
                                          xmlelement("Relation", t.org_reltn)
                                  end
                                , case
                                      when t.member_id is not null then
                                          xmlelement("MemberId", t.member_id)
                                  end
                                , case
                                      when t.transit_id is not null then
                                          xmlelement("TransitId", t.transit_id)
                                  end  
                                        )
                            , xmlelement("Destination",
                                  case
                                      when t.dest_contr_num is not null then
                                          xmlelement("ContractNumber", t.dest_contr_num)
                                  end
                                , case
                                      when t.dest_reltn is not null then
                                          xmlelement("Relation", t.dest_reltn)
                                  end 
                                        )  
                            /*, case
                                  when t.card_seqn is not null or t.card_exp is not null then
                                      xmlelement("CardInfo",
                                          case 
                                              when t.card_seqn is not null then
                                                  xmlelement("CardSeqN", t.card_seqn)
                                          end
                                        , case
                                              when t.card_exp is not null then
                                                  xmlelement("CardExpiry", to_char(t.card_exp, 'yymm'))
                                          end
                                                )
                            
                              end */
                            , xmlelement("Transaction",
                                  xmlelement("Currency", t.currency)    
                                    , xmlelement("Amount", regexp_replace(to_char(t.amount, com_api_const_pkg.XML_FLOAT_FORMAT), '(\.0+$|0+$)', ''))
                                , case
                                      when t.ptid is not null or t.trans_location is not null or /*t.postal_code is not null or*/ t.src is not null
                                      or t.tcashback_curr is not null or t.tcashback_amount is not null or t.surcharge_curr is not null
                                      or t.surcharge_amount is not null or t.mbr_reconc_ind is not null or t.cpna is not null or t.cpad is not null
                                      or t.cpcy is not null or t.cpst is not null or t.cpcn is not null or t.cppc is not null or t.cpdb is not null 
                                      or t.utrn is not null or t.rpph is not null or t.rpna is not null or t.dev_tag is not null then
                                          xmlelement("Extra",
                                              xmlelement("Type", 'AddInfo')
                                            , xmlelement("AddData",
                                                  case
                                                      when t.ptid is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'PTID')
                                                            , xmlelement("Value", t.ptid)
                                                                    )
                                                  end
                                                , case
                                                      when t.trans_location is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'TRANS_LOCATION')
                                                            , xmlelement("Value", t.trans_location)
                                                                    )
                                                  end
                                                /*, case
                                                      when t.postal_code is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'POSTAL_CODE')
                                                            , xmlelement("Value", t.postal_code)
                                                                    )
                                                  end */
                                                , case
                                                      when t.src is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'SRC')
                                                            , xmlelement("Value", t.src)
                                                                    )
                                                  end
                                                , case
                                                      when t.tcashback_curr is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'TCASHBACK_CURR')
                                                            , xmlelement("Value", t.tcashback_curr)
                                                                    )
                                                  end
                                                , case
                                                      when t.tcashback_amount is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'TCASHBACK_AMOUNT')
                                                            , xmlelement("Value", t.tcashback_amount)
                                                                    )
                                                  end
                                                , case
                                                      when t.surcharge_curr is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'SURCHARGE_CURR')
                                                            , xmlelement("Value", t.surcharge_curr)
                                                                    )
                                                  end
                                                , case
                                                      when t.surcharge_amount is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'SURCHARGE_AMOUNT')
                                                            , xmlelement("Value", t.surcharge_amount)
                                                                    )
                                                  end
                                                , case
                                                      when t.mbr_reconc_ind is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'MBR_RECONC_IND')
                                                            , xmlelement("Value", t.mbr_reconc_ind)
                                                                    )
                                                  end
                                                , case
                                                      when t.cpna is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'CPNA')
                                                            , xmlelement("Value", t.cpna)
                                                                    )
                                                  end
                                                , case
                                                      when t.cpad is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'CPAD')
                                                            , xmlelement("Value", t.cpad)
                                                                    )
                                                  end
                                                , case
                                                      when t.cpcy is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'CPCY')
                                                            , xmlelement("Value", t.cpcy)
                                                                    )
                                                  end
                                                , case
                                                      when t.cpst is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'CPST')
                                                            , xmlelement("Value", t.cpst)
                                                                    )
                                                  end
                                                , case
                                                      when t.cpcn is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'CPCN')
                                                            , xmlelement("Value", t.cpcn)
                                                                    )
                                                  end
                                                , case
                                                      when t.cppc is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'CPPC')
                                                            , xmlelement("Value", t.cppc)
                                                                    )
                                                  end
                                                , case
                                                      when t.cpdb is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'CPDB')
                                                            , xmlelement("Value", to_char(t.cpdb, 'mmddyyyy'))
                                                                    )
                                                  end                                                  
                                                , case
                                                      when t.utrn is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'UTRN')
                                                            , xmlelement("Value", t.utrn)
                                                                    )
                                                  end
                                                , case
                                                      when t.rpph is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'RPPH')
                                                            , xmlelement("Value", t.rpph)
                                                                    )
                                                  end
                                                , case
                                                      when t.rpna is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'RPNA')
                                                            , xmlelement("Value", t.rpna)
                                                                    )
                                                  end
                                                , case
                                                      when t.dev_tag is not null then
                                                          xmlelement("Parm",
                                                              xmlelement("ParmCode", 'DEV')
                                                            , xmlelement("Value", t.dev_tag)
                                                                    )
                                                  end
                                                      )
                                                  )
                                  end
                                        )
                            , case
                                  when t.origtransdate is not null then
                                      xmlelement("ChainDtls",
                                          xmlelement("OrigTransDate", t.origtransdate)
                                                )
                              end
                            , xmlelement("Addendum",
                                  xmlelement("Type", 'CH')
                                , xmlelement("Info", 
                                      case
                                          when t.f23 is not null or t.tag82 is not null or t.tag95 is not null or t.tag9a is not null or t.tag9c is not null 
                                            or t.tag5f2a is not null or t.tag9f02 is not null or t.tag9f10 is not null or t.tag9f1a is not null 
                                            or t.tag9f26 is not null or t.tag9f33 is not null or t.tag9f37 is not null or t.tag9f36 is not null  then
                                                xmlelement("ISO8583", xmlattributes(l_standard_param(way_api_const_pkg.WAY4_DIALECT) "Dialect", '1.0' "Version"),
                                                  xmlforest(t.f23)
                                                , case
                                                      when t.tag82 is not null or t.tag95 is not null or t.tag9a is not null or t.tag9c is not null 
                                                        or t.tag5f2a is not null or t.tag9f02 is not null or t.tag9f10 is not null or t.tag9f1a is not null 
                                                        or t.tag9f26 is not null or t.tag9f33 is not null or t.tag9f37 is not null or t.tag9f36 is not null then
                                                      xmlelement("F55",
                                                          case 
                                                              when t.tag82 is not null then
                                                                  xmlelement("Tag", xmlattributes('82' "Id"), t.tag82)
                                                          end
                                                        , case 
                                                              when t.tag95 is not null then
                                                                  xmlelement("Tag", xmlattributes('95' "Id"), t.tag95)
                                                          end
                                                        , case 
                                                              when t.tag9a is not null then
                                                                  xmlelement("Tag", xmlattributes('9A' "Id"), t.tag9a)
                                                          end
                                                        , case 
                                                              when t.tag9c is not null then
                                                                  xmlelement("Tag", xmlattributes('9C' "Id"), t.tag9c)
                                                          end
                                                        , case 
                                                              when t.tag5f2a is not null then
                                                                  xmlelement("Tag", xmlattributes('5F2A' "Id"), t.tag5f2a)
                                                          end
                                                        , case 
                                                              when t.tag9f02 is not null then
                                                                  xmlelement("Tag", xmlattributes('9F02' "Id"), t.tag9f02)
                                                          end
                                                        , case 
                                                              when t.tag9f10 is not null then
                                                                  xmlelement("Tag", xmlattributes('9F10' "Id"), t.tag9f10)
                                                          end
                                                        , case 
                                                              when t.tag9f1a is not null then
                                                                  xmlelement("Tag", xmlattributes('9F1A' "Id"), t.tag9f1a)
                                                          end
                                                        , case 
                                                              when t.tag9f26 is not null then
                                                                  xmlelement("Tag", xmlattributes('9F26' "Id"), t.tag9f26)
                                                          end
                                                        , case 
                                                              when t.tag9f33 is not null then
                                                                  xmlelement("Tag", xmlattributes('9F33' "Id"), t.tag9f33)
                                                          end
                                                        , case 
                                                              when t.tag9f36 is not null then
                                                                  xmlelement("Tag", xmlattributes('9F36' "Id"), t.tag9f36)
                                                          end
                                                        , case 
                                                              when t.tag9f37 is not null then
                                                                  xmlelement("Tag", xmlattributes('9F37' "Id"), t.tag9f37)
                                                          end                                                          
                                                      )
                                                    end
                                                  )
                                          else
                                                --xmltype('<ISO8583 Dialect="' || l_standard_param(way_api_const_pkg.WAY4_DIALECT) || '" Version="1.0"/>')
                                                xmlelement("ISO8583", xmlattributes(l_standard_param(way_api_const_pkg.WAY4_DIALECT) as "Dialect", '1.0' as "Version"))
                                  end
                                        )
                              )
                              ) -- Doc
                          )
                          )-- DocList
              , xmlelement("FileTrailer",
                    xmlelement("CheckSum",
                        xmlelement("RecsCount", count(t.drn))
                      , xmlelement("HashTotalAmount", nvl(sum(t.amount), 0))
                          )
                          )
                        )  
          into l_xml          
        from
          (select
            owd.msg_code
          , vfm.id                                                  drn
          , case
              when pti.participant_type = 'PRTYISS'
                  and pti.network_id   = l_network_id(i)
                  and pti.inst_id      = l_inst_id(i)
                then
                      vfm.terminal_number
                  else
                  vc.card_number
            end                                                     dest_contr_num
          , vfm.oper_amount / power (10, nvl (cur.exponent, 0))     amount
          , vfm.oper_date                                           local_dt
          , vfm.mcc                                                 sic
          , vfm.arn                                                 arn
          , vfm.auth_code                                           auth_code
          , case
              when pti.participant_type = 'PRTYISS'
                  and pti.network_id   = l_network_id(i)
                  and pti.inst_id      = l_inst_id(i)
                then
                      vc.card_number
                  else
                  vfm.terminal_number
            end                                                     org_contr_num
          , vfm.merchant_number                                     src_mrc_id
          , vfm.merchant_city                                       mrc_city
          , vfm.merchant_region                                     mrc_state
          , com_api_country_pkg.get_country_name(vfm.merchant_country) mrc_country
          , vfm.merchant_name                                       descrp
          , nvl(vfm.card_seq_number, pti.card_seq_number)           card_seqn
          , vfm.oper_currency                                       currency
              , lpad(l_standard_param(way_api_const_pkg.WAY4_SENDER)
                    , 6, '0')                                       member_id
              , lpad(l_standard_param(way_api_const_pkg.WAY4_SENDER)
                    , 6, '0')                                       transit_id
          , owd.orig_drn                                            origdrn
          , owd.prev_drn                                            prevdrn
          , vfm.id                                                  p_bo_utrnno
          , vfm.rrn
          , owd.trans_condition
          , pti.card_expir_date                                     card_exp
          , to_char(owd.orig_trans_date, com_api_const_pkg.LOG_DATE_FORMAT)   origtransdate
          , 0                                                       org_reltn
          , 0                                                       dest_reltn
          , case
              when vfm.pos_entry_mode in ('05', '07')
              then
                  lpad(vfm.card_seq_number, 3, '0')
              else
                  null
            end                                                     f23
          , vfm.appl_interch_profile                                tag82
          , vfm.term_verif_result                                   tag95
          , lpad(vfm.transaction_type, 2, '0')                      tag9c
          , vfm.issuer_appl_data                                    tag9f10
          , vfm.cryptogram                                          tag9f26
          , vfm.terminal_profile                                    tag9f33
          , vfm.appl_trans_counter                                  tag9f36
          , vfm.unpredict_number                                    tag9f37
          , substr(vfm.issuer_script_result, -1)                    tag9f5b
              , vfm.reason_code                                            reason_code
          , substr(
              vc.card_number ||' '||
              ca.street      ||' '||
              ctr.name       ||' '||
              ca.postal_code
            , 50)                                                   reason_details
          , null                                                    requirement
          , owd.ptid
          , owd.trans_location
          , owd.postal_code
          , owd.src
          , owd.tcashback_curr
          , owd.tcashback_amount
          , owd.surcharge_curr
          , owd.surcharge_amount
          , owd.mbr_reconc_ind
          , owd.cpna
          , owd.cpad
          , owd.cpcy
          , owd.cpst
          , owd.cpcn
          , owd.cppc
          , to_char(owd.cpdb, 'dd.mm.yyyy hh24:mi:ss')              cpdb
          , owd.utrn
          , owd.rpph
          , owd.rpna
          , owd.dev_tag
          , owd.cps
          , vfm.form_factor_indicator                               tag9f6e
          , owd.emv_5f2a                                            tag5f2a
          , case
              when owd.emv_9f02 is null
              then
                  to_char(owd.emv_9f02)
              else
              lpad(owd.emv_9f02, 12, '0')
            end                                                     tag9f02
          , owd.emv_9f1a                                            tag9f1a
          , owd.emv_9a                                              tag9a
          , owd.emv_84                                              tag84
          , owd.trn
          , vfm.proc_bin
          , vfm.trans_code
          from
              vis_fin_message vfm
                join way_additional_data owd       
                  on owd.oper_id = vfm.id
                join opr_operation opr
                  on opr.id = vfm.id
                join opr_participant pti
                  on pti.oper_id = opr.id
                  and pti.participant_type = 'PRTYISS'
                left join opr_operation orig
                  on orig.id = opr.original_id
                join com_currency cur
                  on cur.code = vfm.oper_currency   
                join com_country cou
                  on cou.code = vfm.merchant_country
                join vis_card vc
                  on vc.id = vfm.id                    
                left join com_address_object cao
                  on cao.object_id = pti.customer_id
                  and cao.entity_type = 'ENTTCUST'
                  and cao.address_type = 'ADTPHOME'
                left join com_address ca
                  on ca.id = cao.address_id
                left join com_country ctr
                  on ctr.code = ca.country  
          where
            decode(vfm.status
              , 'CLMS0010', 'CLMS0010'
              , null) = 'CLMS0010'
            and vfm.is_incoming = 0
            and vfm.network_id = l_network_id(i)
                and vfm.inst_id = l_inst_id(i)
            and vfm.host_inst_id = l_host_inst_id(i)
            and (vfm.oper_date between nvl(i_start_date, trunc(vfm.oper_date))
                                   and nvl(i_end_date, trunc(vfm.oper_date)) + 1 - 1/86400
                   and vfm.is_reversal = 0
                   or
                   opr.host_date between nvl(i_start_date, trunc(opr.host_date))
                                   and nvl(i_end_date, trunc(opr.host_date)) + 1 - 1/86400
                   and vfm.is_reversal = 1) 
          order by
              proc_bin, trans_code) t;  

            l_inst_clearing(l_inst_id(i)) := l_xml;
                                    
        end loop;
        
        -- process result
        declare
            l_inst_ind       com_api_type_pkg.t_inst_id;
            l_total_messages com_api_type_pkg.t_count   := 0;
            l_result_file    xmltype := null;
            
            l_inst_recs     com_api_type_pkg.t_count    :=0;
            l_inst_amount   com_api_type_pkg.t_money    := 0;
            l_total_amount  com_api_type_pkg.t_money    := 0;
            l_out_clob      clob;
            
            function regenerate_checksum(
                i_result_xml       in xmltype
              , i_total_recs_count in com_api_type_pkg.t_count
              , i_total_amount     in com_api_type_pkg.t_money
              , i_file_seq_num     in com_api_type_pkg.t_country_code
            ) return clob
            is
                l_result clob;        
            begin
                trc_log_pkg.info(
                    i_text => 'regenerate checksum'
                );
                
                -- modify result xml file with total recs count and total amount
                select xmlserialize(document
                           updatexml(i_result_xml
                             , '/DocFile/FileTrailer/CheckSum/RecsCount/text()'
                             , i_total_recs_count
                             , '/DocFile/FileTrailer/CheckSum/HashTotalAmount/text()'
                             , to_char(i_total_amount, com_api_const_pkg.XML_FLOAT_FORMAT)
                             , '/DocFile/FileHeader/FileSeqNumber/text()'
                             , i_file_seq_num                       
                           ) as clob indent size = 2)
                  into l_result
                  from dual;
                  
                return l_result;
                
            end regenerate_checksum;
            
            procedure regenerate_total_file(
                i_file_part         in            xmltype
              , io_regenerated_file in out nocopy xmltype              
            ) is
            begin
                trc_log_pkg.info(
                    i_text => 'regenerate total file'
                );
                    
                select insertchildxml(io_regenerated_file, '/DocFile/DocList', 'Doc', docs)
                  into io_regenerated_file
                  from xmltable('/DocFile/DocList' passing i_file_part  columns docs xmltype path 'Doc');

            end regenerate_total_file;
        begin
            
            trc_log_pkg.info(
                i_text       => 'Start regenerate separated clearing file into one. Separated files count is [#1]'
              , i_env_param1 => l_inst_clearing.count
            );
            
            l_inst_ind := l_inst_clearing.first;
            
            while (l_inst_ind is not null) loop
                                    
                if l_result_file is null then
                    trc_log_pkg.debug(
                        i_text => 'Put first part xml clearing into result file'
                    );
                                        
                    l_result_file := l_inst_clearing(l_inst_ind);
                else
                    -- add new columns to the final file
                    /*
                      select insertchildxml(l_result_file, '/DocFile/DocList', 'Doc', docs)
                        into l_result_file
                        from xmltable('/DocFile/DocList' passing l_inst_clearing(l_inst_ind)  columns docs xmltype path 'Doc');
                     */
                     
                     trc_log_pkg.debug(
                         i_text       => 'Put intitution [#1] part into result xml clearing file.'
                       , i_env_param1 => l_inst_ind
                     );
                     
                     regenerate_total_file(
                         i_file_part         => l_inst_clearing(l_inst_ind)
                       , io_regenerated_file => l_result_file
                     );
                         
                end if;
                 
                trc_log_pkg.debug(
                    i_text       => 'Getting checksum info for inst [#1]'
                  , i_env_param1 => l_inst_ind
                );
                   
                -- register outgoing messages    
                register_uploaded_message(
                    i_xml             => l_inst_clearing(l_inst_ind)
                  , o_ok_message_id   => l_ok_mess_id
                  , io_inst_count     => l_inst_recs
                  , io_inst_amount    => l_inst_amount
                );

                register_uploaded_file(
                    i_session_file_id => l_session_file_id
                  , i_network_id      => l_network_id(1)
                  , i_messages        => to_number(l_inst_recs)
                  , i_amount          => l_inst_amount
                  , i_proc_bin        => l_standard_param(way_api_const_pkg.WAY4_SENDER)
                  , io_file_id        => l_file_id
                  , io_file_seq_num   => l_file_seq_number
                );

                trc_log_pkg.debug (
                    i_text       => 'Checksum params for inst [#1] is recs_count [#2] sum_amount [#3]'
                  , i_env_param1 => l_inst_ind
                  , i_env_param2 => l_inst_recs
                  , i_env_param3 => l_inst_amount
                );

                if l_inst_recs != 0 and l_inst_amount != 0 then   
                  
                    l_total_messages := l_total_messages + l_inst_recs;
                    l_total_amount   := l_total_amount   + l_inst_amount;
                    mark_ok_message; 
                
                   trc_log_pkg.debug(
                        i_text      => 'Total file checksum is recs [#1] amount [#2]'
                     , i_env_param1 => l_total_messages
                     , i_env_param2 => l_total_amount
                   );
                    
                end if; 
                           
                l_inst_ind := l_inst_clearing.next(l_inst_ind);  
            end loop;       
        
            prc_api_stat_pkg.log_current (
                i_current_count   => l_total_messages
              , i_excepted_count  => 0
            );            

            --> Message to file        
            trc_log_pkg.debug (
                i_text       => 'XML CLOB was successfully created. l_session_file_id [#1] '
              , i_env_param1 => l_session_file_id
            );

            -- Put file record
            l_out_clob := com_api_const_pkg.XML_HEADER || chr(10)
                          || regenerate_checksum(
                                 i_result_xml       => l_result_file
                               , i_total_recs_count => l_total_messages
                               , i_total_amount     => l_total_amount
                               , i_file_seq_num     => l_file_seq_number
                             );

            prc_api_file_pkg.put_file (
                i_sess_file_id  => l_session_file_id
              , i_clob_content  => l_out_clob
            );

            trc_log_pkg.debug ('XML was put to the file.');

            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
            --< Message to file
            l_processed_count := l_total_messages;
        end;

        l_standard_param.delete;

    end if;

    prc_api_stat_pkg.log_end(
        i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        , i_processed_total  => l_processed_count
    );

    trc_log_pkg.debug (
        i_text  => 'WAY UFX outgoing clearing end'
    );

exception
    when others then
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

    l_standard_param.delete;
    
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end;

end way_prc_outgoing_pkg;
/
