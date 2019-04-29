create or replace force view mcw_ui_ird_vw
as
select opr.id                                      as oper_id
     , opr.sttl_type
     , get_article_text(opr.sttl_type)             as sttl_type_text
     , opr.oper_type
     , get_article_text(opr.oper_type)             as oper_type_text
     , opr.status                                  as oper_status
     , get_article_text(opr.status)                as oper_status_text
     , fin.mti                                     as message_type_id
     , fin.de024                                   as function_code
     , fin.de003_1                                 as processing_code  -- '00' = Purchase
     , bin.brand                                   as card_program_id
     , substr(fin.de063, 2, 3)                     as gcms_product_id
     , ac.mastercard_region                        as acquirer_region
     , case ac.mastercard_region
           when 'A'
           then 'Canada'
           when 'B'
           then 'Latin America and the Caribbean'
           when 'C'
           then 'Asia/Pacific'
           when 'D'
           then 'Europe'
           when 'E'
           then 'MEA'
           when '1'
           then 'U.S.'
           else 'Undefined'
       end                                         as acquirer_region_text
     , fin.de043_6                                 as acquirer_country_name
     , com_api_i18n_pkg.get_text(
                   i_table_name  => 'COM_COUNTRY'
                 , i_column_name => 'NAME'
                 , i_object_id   => ac.id
                 , i_lang        => 'LANGENG'
       )                                           as acquirer_country_text
     , ic.mastercard_region                        as issuer_region
     , case ic.mastercard_region
           when 'A'
           then 'Canada'
           when 'B'
           then 'Latin America and the Caribbean'
           when 'C'
           then 'Asia/Pacific'
           when 'D'
           then 'Europe'
           when 'E'
           then 'MEA'
           when '1'
           then 'U.S.'
           else 'Undefined'
       end                                         as issuer_region_text
     , ic.name                                     as issuer_country_name
     , com_api_i18n_pkg.get_text(
           i_table_name  => 'COM_COUNTRY'
         , i_column_name => 'NAME'
         , i_object_id   => ic.id
         , i_lang        => 'LANGENG'
       )                                          as issuer_country_text
     , to_date(substr(fil.p0105, 4, 6), 'yymmdd') as file_header_date
     , fin.de012                                  as transaction_date
     , fin.de026                                  as mcc
     , (select com_api_i18n_pkg.get_text(
                   i_table_name  => 'COM_MCC'
                 , i_column_name => 'NAME'
                 , i_object_id   => mcc.id
                 , i_lang        => 'LANGENG'
               )
          from com_mcc mcc
         where mcc.mcc = fin.de026
       )                                          as mcc_text
     , (select listagg(cab.cab_program, ', ') within group (order by cab_program)
         from mcw_mcc cab
        where cab.mcc = fin.de026
       )                                          as cab_program
     , fin.ird_trace
     , mcw_api_fin_pkg.get_ird_trace_desc(
           i_ird_trace => fin.ird_trace
       )                                          as ird_trace_desc
     , fin.p0158_4                                as calculated_ird
  from opr_operation        opr
     , mcw_fin              fin
     , opr_card             crd
     , net_bin_range_index  ind
     , mcw_bin_range        bin
     , mcw_file             fil
     , com_country          ac
     , com_country          ic
 where fin.id               = opr.id
   and crd.oper_id          = opr.id
   and crd.participant_type = 'PRTYISS'
   and ind.pan_prefix       = substr(iss_api_token_pkg.decode_card_number(i_card_number => crd.card_number), 1, 5)
   and iss_api_token_pkg.decode_card_number(i_card_number => crd.card_number) between ind.pan_low and ind.pan_high
   and bin.pan_low          = ind.pan_low
   and bin.pan_high         = ind.pan_high
   and bin.product_id       = substr(fin.de063, 2, 3)
   and fil.id               = fin.file_id
   and ac.name              = fin.de043_6
   and ic.code              = bin.country
/
