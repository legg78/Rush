package ru.bpc.sv2.svng;

import org.dom4j.Element;
import org.dom4j.Node;

import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;

public class CardStatusGenerate {
    public static void generate(Node node, CardStatus card, StringBuilder path) throws ParseException {
        generate(node, card, path, "yyyy-MM-dd'T'HH:mm:ss");
    }

    public static void generate(Node node, CardStatus card, StringBuilder path, String dateFormat) throws ParseException {
        if (node != null && node.getNodeType() == Node.ELEMENT_NODE) {
            Element element = (Element) node;
            Integer len = path.length();
            path.append("/").append(node.getName());
            match(element, card, path.toString(), dateFormat);
            List list = element.elements();
            for (Object child : list) {
                generate((Element) child, card, path, dateFormat);
            }
            path.setLength(len);
        }
    }

    public static CardStatus assembleFromNode(Node node, String dateFormat) throws ParseException {
        CardStatus card = new CardStatus();
        generate(node, card, new StringBuilder(), dateFormat);
        return card;
    }

    private static void match(Element element, CardStatus card, String path, String dateFormat) throws ParseException {
        SimpleDateFormat df = new SimpleDateFormat(dateFormat);

        if (path.equals("/card_status/card_id")) {
            card.setId(Long.valueOf(element.getText()));
        } else if (path.equals("/card_status/card_number")) {
            card.setCardNumber(element.getText());
        } else if (path.equals("/card_status/expiration_date")) {
            card.setExpDate(df.parse(element.getText()));
        } else if (path.equals("/card_status/seq_number")) {
            card.setSeqNumber(Integer.valueOf(element.getText()));
        } else if (path.equals("/card_status/change_date")) {
            card.setChangeDate(df.parse(element.getText()));
        } else if (path.equals("/card_status/status")) {
            card.setStatus(element.getText());
        } else if (path.equals("/card_status/state")) {
            card.setState(element.getText());
        } else if (path.equals("/card_status/initiator")) {
            card.setInitiator(element.getText());
        } else if (path.equals("/card_status/status_reason")) {
            card.setStatusReason(element.getText());
        } else if (path.equals("/card_status/change_id")) {
            card.setChangeId(element.getText());
        } else if (path.equals("/card_status/result_code")) {
            card.setResultCode(element.getText());
        } else if (path.equals("/card_status/error_code")) {
            card.setErrorCode(element.getText());
        }
    }
}
