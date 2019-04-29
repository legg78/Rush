create or replace force view din_ui_fin_vw
as
select f.id
     , f.status
     , get_article_text(
           i_article => f.status
         , i_lang    => l.lang
       ) as status_desc
     , f.network_id
     , get_text(
           i_table_name  => 'net_network'
         , i_column_name => 'name'
         , i_object_id   => f.network_id
         , i_lang        => l.lang
       ) as network_name
     , f.inst_id
     , get_text(
           i_table_name  => 'ost_institution'
         , i_column_name => 'name'
         , i_object_id   => f.inst_id
         , i_lang        => l.lang
       ) as inst_name
     , f.file_id
     , f.record_number
     , f.batch_id
     , f.is_incoming
     , f.is_rejected
     , f.is_reversal
     , f.is_invalid
     , f.dispute_id
     , f.card_id
     , l.lang
     -- Batch/recap fields:
     , com_api_currency_pkg.get_currency_name(i_curr_code => f.oper_currency) as CURKY
     , f.program_transaction_amount                                           as DRATE
     , com_api_currency_pkg.get_currency_name(i_curr_code => f.alt_currency)  as ACRKY
     -- Financial message fields:
     , case f.is_incoming when 0 then 'FRRC' else 'RFRC' end                  as TRANS
     , 'XD'                                                                   as FUNCD
     , f.sending_institution                                                  as SFTER
     , r.recap_number                                                         as RCPNO
     , f.receiving_institution                                                as DFTER
     , b.batch_number                                                         as BATCH
     , f.sequential_number                                                    as SEQNO
     , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)   as ACCT
     , f.oper_amount                                                          as CAMTR
     , f.charge_date                                                          as CHGDT
     , f.date_type                                                            as DATYP
     , f.charge_type                                                          as CHTYP
     , f.merchant_name                                                        as ESTAB
     , f.merchant_city                                                        as LCITY
     , f.merchant_country                                                     as GEOCD
     , f.action_code                                                          as APPCD
     , f.type_of_charge                                                       as TYPCH
     , f.originator_refnum                                                    as REFNO
     , f.auth_code                                                            as ANBR
     , f.merchant_number                                                      as SENUM
     , f.sttl_currency                                                        as BLCUR
     , f.sttl_amount                                                          as BLAMT
     , f.merchant_international_code                                          as INTES
     , f.merchant_street                                                      as ESTST
     , f.merchant_state                                                       as ESTCO
     , f.merchant_postal_code                                                 as ESTZP
     , f.merchant_phone                                                       as ESTPN
     , f.mcc                                                                  as MCCCD
     , f.tax_amount1                                                          as TAX1
     , f.tax_amount2                                                          as TAX2
     , f.original_document_number                                             as ORIGD
     , f.crdh_presence                                                        as CHOLDP
     , f.card_presence                                                        as CARDP
     , f.card_data_input_mode                                                 as CPTRM
     , f.network_refnum                                                       as NRID
     , f.card_data_input_capability                                           as CRDINP
     , to_char(f.sttl_date, 'HH24MISS')                                       as SCGMT
     , to_char(f.sttl_date, 'YYMMDD')                                         as SCDAT
     , to_char(f.host_date, 'HH24MISS')                                       as LCTIM
     , to_char(f.host_date, 'YYMMDD')                                         as LCDAT
     , f.terminal_number                                                      as ATMID
     , f.card_type                                                            as VCRDD
     , f.payment_token                                                        as TKNID
     , f.token_requestor_id                                                   as TKRQID
     , f.token_assurance_level                                                as TKLVL
     , sf.file_name
     , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)   as card_number
  from      din_fin_message f
  left join din_batch        b  on b.id  = f.batch_id
  left join din_recap        r  on r.id  = b.recap_id
  left join din_card         c  on c.id  = f.card_id
  left join prc_session_file sf on sf.id = f.file_id
 cross join com_language_vw l
/
