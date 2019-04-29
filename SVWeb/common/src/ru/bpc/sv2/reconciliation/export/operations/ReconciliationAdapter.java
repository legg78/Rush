package ru.bpc.sv2.reconciliation.export.operations;

import ru.bpc.sv2.invocation.ModelAdapter;
import ru.bpc.sv2.invocation.ModelDTO;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.reconciliation.RcnMessage;

import java.math.BigDecimal;

public class ReconciliationAdapter implements ModelAdapter {
    @Override
    public void populateDTO(ModelDTO modelDto, ModelIdentifiable model) {
        if (modelDto instanceof ReconciliationDTO && model instanceof RcnMessage) {
            ReconciliationDTO dto = (ReconciliationDTO) modelDto;
            RcnMessage msg = (RcnMessage) model;

            dto.setOperType(msg.getOperType());
            dto.setMsgType(msg.getMsgType());
            dto.setSttlType(msg.getSttlType());
            dto.setOperDate(msg.getOperDate());
            dto.setOperAmount(msg.getOperAmount() != null ? new BigDecimal(msg.getOperAmount()) : null);
            dto.setOperCurrency(msg.getOperCurrency());
            dto.setOperRequestAmount(msg.getOperRequestAmount() != null ? new BigDecimal(msg.getOperRequestAmount()) : null);
            dto.setOperRequestCurrency(msg.getOperRequestCurrency());
            dto.setOperSurchargeAmount(msg.getOperSurchargeAmount() != null ? new BigDecimal(msg.getOperSurchargeAmount()) : null);
            dto.setOperSurchargeCurrency(msg.getOperSurchargeCurrency());
            dto.setOriginatorRefnum(msg.getOriginatorRefnum());
            dto.setNetworkRefnum(msg.getNetworkRefnum());
            dto.setAcqInstBin(msg.getAcqInstBin());
            dto.setStatus(msg.getStatus());
            dto.setIsReversal(msg.getReversal());
            dto.setMcc(msg.getMcc());
            dto.setMerchantNumber(msg.getMerchantNum());
            dto.setMerchantName(msg.getMerchantName());
            dto.setMerchantStreet(msg.getMerchantStreet());
            dto.setMerchantCity(msg.getMerchantCity());
            dto.setMerchantRegion(msg.getMerchantRegion());
            dto.setMerchantCountry(msg.getMerchantCountry());
            dto.setMerchantPostcode(msg.getMerchantPostcode());
            dto.setTerminalType(msg.getTerminalType());
            dto.setTerminalNumber(msg.getTerminalNum());
            dto.setCardNumber(msg.getCardMask());
            dto.setCardSeqNumber(msg.getCardSeqNum());
            dto.setCardExpirDate(msg.getCardExpirDate());
            dto.setCardCountry(msg.getCardCountry());
            dto.setAcqInstId(msg.getAcqInstId());
            dto.setIssInstId(msg.getIssInstId());
            dto.setAuthCode(msg.getAuthCode());
            dto.setReconLastDateTime(msg.getReconLastDateTime());
        }
    }
}
