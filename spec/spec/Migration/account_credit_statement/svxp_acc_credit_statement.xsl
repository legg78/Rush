<?xml version="1.0" encoding="UTF-8" ?>
<stylesheet version="2.0"
            xmlns="http://www.w3.org/1999/XSL/Transform"
            xpath-default-namespace="http://sv.bpc.in/SVAP"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            xmlns:bpc="http://sv.bpc.in/functions"
            xmlns:d="http://sv.bpc.in/date"
            >
    <variable name="debug" select="xs:boolean('false')" />

    <output method="text"/>
    <strip-space elements="*"/>

    <variable name="records">
        <d:rec name='account_number'    width='32'    type='S' />
        <d:rec name='currency'          width='3'     type='S' />
        <d:rec name='account_type'      width='8'     type='S' />
        <d:rec name='inst_id'           width='16'    type='N' />
        <d:rec name='agent_id'          width='16'    type='S' />

        <d:rec name='customer_number'   width='200'   type='S' />
        <d:rec name='customer_category' width='8'     type='S' />
        <d:rec name='resident'          width='1'     type='N' />
        <d:rec name='customer_relation' width='8'     type='S' />
        <d:rec name='nationality'       width='3'     type='S' />

        <d:rec name='surname'           width='200'   type='S' />
        <d:rec name='first_name'        width='200'   type='S' />
        <d:rec name='second_name'       width='200'   type='S' />

        <d:rec name='id_type'           width='8'     type='S' />
        <d:rec name='id_series'         width='200'   type='S' />
        <d:rec name='id_number'         width='200'   type='S' />

        <d:rec name='contact_type'      width='8'     type='S' />
        <d:rec name='preferred_lang'    width='8'     type='S' />

        <d:rec name='commun_method'     width='8'     type='S' />
        <d:rec name='commun_address'    width='200'   type='S' />

        <d:rec name='address_type'      width='8'     type='S' />
        <d:rec name='country'           width='3'     type='S' />

        <d:rec name='region'            width='200'   type='S' />
        <d:rec name='city'              width='200'   type='S' />
        <d:rec name='street'            width='200'   type='S' />

        <d:rec name='house'             width='200'   type='S' />
        <d:rec name='apartment'         width='200'   type='S' />

        <d:rec name='contract_type'      width='8'    type='S' />
        <d:rec name='product_id'         width='16'   type='N' />
        <d:rec name='contract_number'    width='200'  type='S' />
        <d:rec name='start_date'         width='10'   type='D' />

        <d:rec name='opening_balance'    width='23'   type='F' />
        <d:rec name='closing_balance'    width='23'   type='F' />
        <!--<d:rec name='start_date'         width='10'   type='D' />-->
        <d:rec name='invoice_date'       width='10'   type='D' />
        <d:rec name='payment_sum'        width='23'   type='F' />
        <d:rec name='interest_sum'       width='23'   type='F' />
        <d:rec name='available_credit'   width='23'   type='F' />
        <d:rec name='serial_number'      width='20'   type='N' />
        <d:rec name='invoice_type'       width='8'    type='S' />
        <d:rec name='exceed_limit'       width='23'   type='F' />
        <d:rec name='total_amount_due'   width='23'   type='F' />
        <d:rec name='own_funds'          width='23'   type='F' />
        <d:rec name='min_amount_due'     width='23'   type='F' />
        <d:rec name='grace_date'         width='10'   type='D' />
        <d:rec name='due_date'           width='10'   type='D' />
        <d:rec name='penalty_date'       width='10'   type='D' />
        <d:rec name='aging_period'       width='10'   type='N' />

        <d:rec name='is_mad_paid'    width='1'   type='N' />
        <d:rec name='is_tad_paid'    width='1'    type='N' />


        <d:rec name='oper_type'          width='8'    type='S' />
        <d:rec name='oper_description'   width='200'  type='S' />
        <d:rec name='card_mask'          width='16'   type='S' />
        <d:rec name='card_id'            width='16'   type='N' />
        <d:rec name='posting_date'       width='10'   type='D' />
        <d:rec name='oper_date'          width='10'   type='D' />
        <d:rec name='oper_amount'        width='23'   type='F' />
        <d:rec name='oper_currency'      width='3'    type='S' />
        <d:rec name='credit_oper_amount' width='23'   type='F' />

        <d:rec name='debit_oper_amount'  width='23'   type='F' />
        <d:rec name='overdraft_amount'   width='23'   type='F' />
        <d:rec name='repayment_amount'   width='23'   type='F' />
        <d:rec name='interest_amount'    width='23'   type='F' />
        <d:rec name='oper_type_interest' width='1'    type='N' />

    </variable>

    <template match="root">
        <apply-templates select="child::account_credit_statement" />
    </template>

    <template match="account_credit_statement">
        <value-of select="if($debug) then '&#xD;&#xA;' else ''" />
        <value-of select="'RCTP24'"/>
        <apply-templates select="child::account" />
        <value-of select="bpc:getFormattedOutputValue(opening_balance)" />
        <value-of select="bpc:getFormattedOutputValue(closing_balance)" />
        <value-of select="bpc:getFormattedOutputValue(start_date)" />
        <value-of select="bpc:getFormattedOutputValue(invoice_date)" />
        <value-of select="bpc:getFormattedOutputValue(payment_sum)" />
        <value-of select="bpc:getFormattedOutputValue(interest_sum)" />
        <value-of select="bpc:getFormattedOutputValue(available_credit)" />
        <value-of select="bpc:getFormattedOutputValue(serial_number)" />
        <value-of select="bpc:getFormattedOutputValue(invoice_type)" />
        <value-of select="bpc:getFormattedOutputValue(exceed_limit)" />
        <value-of select="bpc:getFormattedOutputValue(total_amount_due)" />
        <value-of select="bpc:getFormattedOutputValue(own_funds)" />
        <value-of select="bpc:getFormattedOutputValue(min_amount_due)" />
        <value-of select="bpc:getFormattedOutputValue(grace_date)" />
        <value-of select="bpc:getFormattedOutputValue(due_date)" />
        <value-of select="bpc:getFormattedOutputValue(penalty_date)" />
        <value-of select="bpc:getFormattedOutputValue(aging_period)" />
        <value-of select="bpc:getFormattedOutputValue(is_mad_paid)" />
        <value-of select="bpc:getFormattedOutputValue(is_tad_paid)" />
        <apply-templates select="child::operations" />
        <value-of select="if($debug) then '&#xD;&#xA;' else ''" />
    </template>


    <template match="account">
        <value-of select="bpc:getFormattedOutputValue(account_number)" />
        <value-of select="bpc:getFormattedOutputValue(currency)" />
        <value-of select="bpc:getFormattedOutputValue(account_type)" />
        <value-of select="bpc:getFormattedOutputValue(inst_id)" />
        <value-of select="bpc:getFormattedOutputValue(agent_id)" />
        <apply-templates select="child::customer" />
        <apply-templates select="child::contract" />
    </template>

    <template match="customer">
        <value-of select="bpc:getFormattedOutputValue(customer_number)" />
        <value-of select="bpc:getFormattedOutputValue(customer_category)" />
        <value-of select="bpc:getFormattedOutputValue(resident)" />
        <value-of select="bpc:getFormattedOutputValue(customer_relation)" />
        <value-of select="bpc:getFormattedOutputValue(nationality)" />
        <apply-templates select="child::person/child::person_name" />
        <apply-templates select="child::person/child::identity_card" />
        <apply-templates select="child::contact" />
        <apply-templates select="child::address" />
    </template>

    <template match="person_name">
        <value-of select="bpc:getFormattedOutputValue(surname)" />
        <value-of select="bpc:getFormattedOutputValue(first_name)" />
        <value-of select="bpc:getFormattedOutputValue(second_name)" />
    </template>

    <template match="identity_card">
        <value-of select="bpc:getFormattedOutputValue(id_type)" />
        <value-of select="bpc:getFormattedOutputValue(id_series)" />
        <value-of select="bpc:getFormattedOutputValue(id_number)" />
    </template>

    <template match="contact">
        <value-of select="bpc:getFormattedOutputValue(contact_type)" />
        <value-of select="bpc:getFormattedOutputValue(preferred_lang)" />
        <apply-templates select="child::contact_data" />
    </template>

    <template match="contact_data">
        <value-of select="bpc:getFormattedOutputValue(commun_method)" />
        <value-of select="bpc:getFormattedOutputValue(commun_address)" />
    </template>

    <template match="address">
        <value-of select="bpc:getFormattedOutputValue(address_type)" />
        <value-of select="bpc:getFormattedOutputValue(country)" />
        <apply-templates select="child::address_name" />
        <value-of select="bpc:getFormattedOutputValue(house)" />
        <value-of select="bpc:getFormattedOutputValue(apartment)" />

    </template>

    <template match="address_name">
        <value-of select="bpc:getFormattedOutputValue(region)" />
        <value-of select="bpc:getFormattedOutputValue(city)" />
        <value-of select="bpc:getFormattedOutputValue(street)" />
    </template>

    <template match="contract">
        <value-of select="bpc:getFormattedOutputValue(contract_type)" />
        <value-of select="bpc:getFormattedOutputValue(product_id)" />
        <value-of select="bpc:getFormattedOutputValue(contract_number)" />
        <value-of select="bpc:getFormattedOutputValue(start_date)" />
    </template>

    <template match="operations">
        <apply-templates select="child::operation" />
    </template>

    <template match="operation">
        <call-template name="CRLF" />
        <value-of select="'RCTP25'" />
        <value-of select="bpc:getFormattedOutputValue(oper_type)" />
        <value-of select="bpc:getFormattedOutputValue(oper_description)" />
        <value-of select="bpc:getFormattedOutputValue(card_mask)" />
        <value-of select="bpc:getFormattedOutputValue(card_id)" />
        <value-of select="bpc:getFormattedOutputValue(posting_date)" />
        <value-of select="bpc:getFormattedOutputValue(oper_date)" />
        <value-of select="bpc:getFormattedOutputValue(oper_amount)" />
        <value-of select="bpc:getFormattedOutputValue(oper_currency)" />
        <value-of select="bpc:getFormattedOutputValue(credit_oper_amount)" />
        <value-of select="bpc:getFormattedOutputValue(debit_oper_amount)" />
        <value-of select="bpc:getFormattedOutputValue(overdraft_amount)" />
        <value-of select="bpc:getFormattedOutputValue(repayment_amount)" />
        <value-of select="bpc:getFormattedOutputValue(interest_amount)" />
        <value-of select="bpc:getFormattedOutputValue(oper_type_interest)" />

    </template>

    <template name="INSERT_SPACES">
        <param name="count" required="yes" as="xs:integer" />
        <call-template name="INSERT_CHARACTERS">
            <with-param name="count" select="$count" />
            <with-param name="value" select="if($debug) then '.' else ' ' " />
        </call-template>
    </template>

    <template name="INSERT_CHARACTERS">
        <param name="value"  required="yes" />
        <param name="count"  required="yes" as="xs:integer" />
        <for-each select="1 to $count">
            <value-of select="$value" />
        </for-each>
    </template>

    <template name="CRLF">
        <text>&#xD;&#xA;</text>
    </template>


    <function name="bpc:get-repeated-spaces">
        <param name="count" required="yes" as="xs:integer" />
        <value-of>
            <call-template name="INSERT_SPACES">
                <with-param name="count" select="$count" />
            </call-template>
        </value-of>
    </function>

    <function name="bpc:get-repeated-chars">
        <param name="character" required="yes" as="xs:string" />
        <param name="count" required="yes" as="xs:integer" />
        <value-of>
            <call-template name="INSERT_CHARACTERS">
                <with-param name="value" select="$character" />
                <with-param name="count" select="$count" />
            </call-template>
        </value-of>
    </function>

    <function name="bpc:getFormattedOutputValue">
        <param name="element" required="yes" />

        <variable name="elementWidth" select="string-length(normalize-space($element))" />
        <variable name="normalizedValue" select="normalize-space($element)" />
        <variable name="elementOutputWidth" select="number($records/*[@name=local-name($element)]/@width)" />
        <variable name="elementType" select="$records/*[@name=local-name($element)]/@type" />
        <variable name="diffLength" select="$elementOutputWidth - $elementWidth" />

        <value-of select="if ($debug) then concat('&lt;', local-name($element),'>=[') else ''"  />
        <choose>
            <when test="$elementType eq 'S'">
                <value-of select="if($diffLength > 0)
                                  then
                                    concat($normalizedValue, string(
                                        bpc:get-repeated-spaces(xs:integer($diffLength))))
                                  else
                                    $normalizedValue" />
            </when>
            <when test="$elementType eq 'N'">
                <value-of select="if($diffLength > 0)
                                  then
                                   format-number(number($normalizedValue), string(
                                        bpc:get-repeated-chars('0', xs:integer($elementOutputWidth))))
                                  else
                                   format-number(number($normalizedValue), '0')" />
            </when>
            <when test="$elementType eq 'D'">
                <value-of select="format-date(xs:date($normalizedValue), '[D01].[M01].[Y0001]')" />
            </when>
            <when test="$elementType eq 'F'">
                <value-of select="format-number(xs:double($normalizedValue), '000000000000000000.0000')" />
            </when>

            <otherwise>
                <value-of select="$normalizedValue" />
            </otherwise>
        </choose>
        <value-of select="if($debug) then ']   ' else ''" />
    </function>

</stylesheet>