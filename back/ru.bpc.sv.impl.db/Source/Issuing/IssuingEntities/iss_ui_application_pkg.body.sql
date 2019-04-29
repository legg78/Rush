create or replace package body iss_ui_application_pkg as
/*******************************************************************
*  API for application's flow <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 03.08.2010 <br />
*  Last changed by $Author: filimonov $ <br />
*  $LastChangedDate:: 2011-12-09 19:19:12 +0400#$ <br />
*  Revision: $LastChangedRevision: 14428 $ <br />
*  Module: app_ui_flow_pkg <br />
*  @headcom
******************************************************************/

procedure get_customer_xml (
    o_xml               out  clob
  , i_customer_id       in   com_api_type_pkg.t_long_id
  , i_contract_id       in   com_api_type_pkg.t_long_id
) is
    l_result                 xmltype;
    l_customer               xmltype;
    l_contract               xmltype;
    l_contact                xmltype;
    l_person                 xmltype;
    l_address                xmltype;
    l_account                xmltype;
    l_card                   xmltype;
    l_service                xmltype;
    l_customer_type          com_api_type_pkg.t_dict_value;
    l_object_id              com_api_type_pkg.t_long_id;

begin
    select c.entity_type
         , c.object_id
    into l_customer_type
         , l_object_id
    from prd_customer c
    where c.id = i_customer_id;

    -- customer and contract
    select
        xmlconcat(
            xmlelement( "customer_type", entity_type)
            , xmlelement( "company", inst_id)
            , xmlelement( "customer_category", category)
            , xmlelement( "customer_relation", relation)
            , xmlelement( "resident", resident)
            , xmlelement( "nationality", nationality)
            , xmlelement( "status", status)
            , xmlelement( "reg_date", reg_date)
        ),
        xmlconcat(  
                xmlelement( "contract_type", contract_type)
                , xmlelement( "contract_number", contract_number)
                , xmlelement( "start_date", start_date)
                , xmlelement( "end_date", end_date)
                , xmlelement( "product_id", product_id)
            )
        into
            l_customer, l_contract
        from (
            select c.id customer_id
                 , c.entity_type
                 , c.customer_number
                 , c.inst_id
                 , c.category
                 , c.relation
                 , c.resident
                 , c.nationality
                 , c.status
                 , c.reg_date
                 , ct.id contract_id
                 , ct.contract_type
                 , ct.contract_number
                 , ct.start_date
                 , ct.end_date
                 , ct.product_id
            from prd_customer c
                 , prd_contract ct 
            where c.id = ct.customer_id
              and c.id = i_customer_id
              and ct.id = i_contract_id
        );
       
    -- cards 
    begin
    select
        xmlagg(
            xmlelement("card", XMLAttributes(id as "id")
                , xmlelement( "card_number", card_number)
                , xmlelement( "card_type", card_type)
                , xmlelement( "category", category)
                , xmlelement( "expiration_date", expiration_date)
                , xmlelement( "cardholder", XMLAttributes(cardholder_id as "id")
                    , xmlelement( "cardholder_name", cardholder_name)
                    , xmlelement( "cardholder_number", cardholder_number)
                )
            )    
        )
        into 
            l_card
        from (
            select c.id
                 , n.card_number
                 , c.card_type_id card_type
                 , c.category
                 , i.expir_date expiration_date
                 , h.id cardholder_id
                 , h.cardholder_name
                 , h.cardholder_number
              from iss_card c
                 , iss_card_number_vw n  
                 , iss_card_instance i
                 , iss_cardholder h
             where c.id = n.card_id 
               and customer_id = i_customer_id
               and contract_id = i_contract_id
               and c.id = i.card_id
               and c.cardholder_id = h.id
        );
    exception
        when no_data_found then
            select
                xmlelement("card", '')
            into
                l_contact
            from
                dual;
    end;
            
    -- services
    begin
    select
        xmlagg(
            xmlelement("service", XMLAttributes(service_id as "id")
                , xmlelement( "entity_type", entity_type)
                , xmlelement( "status", status)
                , xmlelement( "start_date", start_date)
            )    
        )
        into 
            l_service
        from (
            select s.service_id
                 , s.entity_type
                 , s.status
                 , s.start_date  
            from prd_service_object s
            where s.contract_id = i_contract_id
        );
    exception
        when no_data_found then
            select
                xmlelement("service", '')
            into
                l_contact
            from
                dual;
    end;
           
    -- accounts
    begin
    select
        xmlagg(
            xmlelement("account", XMLAttributes(id as "id")
                , xmlelement( "account_number", account_number)
                , xmlelement( "account_type", account_type)
                , xmlelement( "status", status)
                , xmlelement( "currency", currency)
            )    
        )
        into 
            l_account
        from (
            select a.id
                 , a.account_number
                 , a.account_type
                 , a.status
                 , a.currency 
            from acc_account a
            where a.customer_id = i_customer_id
              and a.contract_id = i_contract_id 
        );
    exception
        when no_data_found then
            select
                xmlelement("account", '')
            into
                l_contact
            from
                dual;
    end; 
          
    -- person
    if l_customer_type = 'ENTTPERS' then
    begin
        select
            xmlconcat(
                xmlelement("person",  
                    XMLAttributes(person_id as "id")
                    , xmlelement( "first_name", first_name)
                    , xmlelement( "second_name", second_name)
                    , xmlelement( "surname", surname)
                    , xmlelement( "suffix", suffix)
                    , xmlelement( "gender", gender)
                    , xmlelement( "birthday", birthday)
                    , xmlelement( "place_of_birth", place_of_birth)
                    , (select
                            xmlagg(
                                xmlelement("document", XMLAttributes(doc_id as "id")
                                    , xmlelement( "id_type", id_type)
                                    , xmlelement( "id_series", id_series)
                                    , xmlelement( "id_number", id_number)
                                    , xmlelement( "id_issuer", id_issuer)
                                    , xmlelement( "id_issue_date", id_issue_date)
                                    , xmlelement( "id_expire_date", id_expire_date)
                                )    
                            )
                        from(
                            select o.id doc_id
                                 , o.id_type
                                 , o.id_series
                                 , o.id_number
                                 , o.id_issuer
                                 , o.id_issue_date
                                 , o.id_expire_date
                                 , o.object_id
                            from com_id_object o 
                         ) r
                         where r.object_id = d.person_id 
                     )
                )
            )     
            into l_person
            from(
                select p.id person_id
                     , p.first_name
                     , p.second_name
                     , p.surname
                     , p.suffix
                     , p.gender
                     , p.birthday
                     , p.place_of_birth
                from com_person p
                where p.id = l_object_id
            )d;
    exception
        when no_data_found then
            select
                xmlelement("person", '')
            into
                l_contact
            from
                dual;
    end;            
    elsif l_customer_type = 'ENTTCOMP' then
    begin
        select
            xmlconcat(
                xmlelement("company",  
                    XMLAttributes(id as "id")
                    , xmlelement( "embossed_name", embossed_name)
                    , xmlelement( "incorp_form", incorp_form)
                    , xmlelement( "inst_id", inst_id)
                    , (select
                            xmlagg(
                                xmlelement("document", XMLAttributes(doc_id as "id")
                                    , xmlelement( "id_type", id_type)
                                    , xmlelement( "id_series", id_series)
                                    , xmlelement( "id_number", id_number)
                                    , xmlelement( "id_issuer", id_issuer)
                                    , xmlelement( "id_issue_date", id_issue_date)
                                    , xmlelement( "id_expire_date", id_expire_date)
                                )    
                            )
                        from(
                            select o.id doc_id
                                 , o.id_type
                                 , o.id_series
                                 , o.id_number
                                 , o.id_issuer
                                 , o.id_issue_date
                                 , o.id_expire_date
                                 , o.object_id
                            from com_id_object o 
                         ) r
                         where r.object_id = d.id 
                     )
                )
            )     
        into l_person
        from(
            select p.id
                 , p.embossed_name
                 , p.incorp_form
                 , p.inst_id
            from com_company p
            where p.id = l_object_id
        ) d;
    exception
        when no_data_found then
            select
                xmlelement("person", '')
            into
                l_contact
            from
                dual;
    end;        
    end if;
    
    -- contact
    begin
        select
            xmlelement("contact", 
                XMLAttributes(id as "id")
                , xmlelement("preferred_lang", preferred_lang)
                , xmlelement("contact_type", contact_type)
                , (select xmlagg(
                            xmlelement("contact_data", XMLAttributes(id as "id")
                                , xmlelement( "commun_method", commun_method)
                                , xmlelement( "commun_address", commun_address)
                                , xmlelement( "start_date", start_date)
                                , xmlelement( "end_date", end_date)
                            )   
                          )
                    from com_contact_data dt 
                    where contact_id = d.id  
                  )                             
            )
        into l_contact
        from(
            select c.id
                 , c.preferred_lang
                 , o.contact_type 
            from com_contact_object o
               , com_contact c
            where o.object_id = i_customer_id
              and o.contact_id = c.id   
        ) d;                
    exception
        when no_data_found then
            select
                xmlelement("contact", '')
            into
                l_contact
            from
                dual;
    end;
    
    -- address
    begin     
    select
        xmlagg(
            xmlelement("address", XMLAttributes(address_id as "id")
                , xmlelement( "address_type", address_type)
                    , xmlelement( "adress_name", 
                        xmlelement( "country", country)
                        , xmlelement( "city", city)
                        , xmlelement( "region", region)
                        , xmlelement( "street", street)
                        , xmlelement( "house", house)
                        , xmlelement( "apartment", apartment)
                        , xmlelement( "postal_code", postal_code)
                        , xmlelement( "region_code", region_code)
                        , xmlelement( "latitude", latitude)
                        , xmlelement( "longitude", longitude)
                    )
            )    
        )
        into 
            l_address
        from (
            select a.id address_id
                 , o.address_type
                 , a.country
                 , a.city
                 , a.region
                 , a.street
                 , a.house
                 , a.apartment
                 , a.postal_code
                 , a.region_code
                 , a.latitude
                 , a.longitude
            from com_address_object o
               , com_address a 
            where o.object_id = i_customer_id
              and o.address_id = a.id 
        );
    exception
        when no_data_found then
            select
                xmlelement("address", '')
            into
                l_contact
            from
                dual;
    end;     
    
    -- result       
    select
        xmlelement (
            "customer",
            XMLAttributes(i_customer_id as "id")
            , l_customer
            , xmlelement("contract",
                XMLAttributes(i_contract_id as "id"),
                l_contract
                , l_card
                , l_service
                , l_account
            )
            , l_person
            , l_contact
            , l_address
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();
end;

end iss_ui_application_pkg;
/
