package ru.bpc.sv2.reconciliation.export.sp;

import ru.bpc.sv2.invocation.ModelAdapter;
import ru.bpc.sv2.invocation.ModelDTO;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.reconciliation.RcnMessage;
import ru.bpc.sv2.reconciliation.export.operations.ReconciliationDTO;

import java.math.BigDecimal;
import java.util.Date;

public class ReconciliationSRVPAdapter implements ModelAdapter {
    @Override
    public void populateDTO(ModelDTO modelDto, ModelIdentifiable model) {
        if (modelDto instanceof ReconciliationSRVPDTO && model instanceof RcnMessage) {
            ReconciliationSRVPDTO dto = (ReconciliationSRVPDTO) modelDto;
            RcnMessage msg = (RcnMessage) model;

            dto.setReconType(msg.getReconType());
            dto.setReconStatus(msg.getReconStatus());
            dto.setReconLastDateTime(msg.getReconLastDateTime());
            dto.setMsgSource(msg.getMsgSource());
            dto.setMsgDateTime(msg.getMsgDateTime());
            dto.setOrderId(msg.getOrderId());
            dto.setOrderStatus(msg.getStatus());
            dto.setPaymentOrderNumber(msg.getPaymentOrderNumber());
            dto.setOrderDate(msg.getOrderDate());
            dto.setOrderAmount(msg.getOrderAmount() != null ? new BigDecimal(msg.getOrderAmount()) : null);
            dto.setOrderCurrency(msg.getOrderCurrency());
            dto.setCustomerId(msg.getCustomerId());
            dto.setCustomerNumber(msg.getCustomerNumber());
            dto.setPurposeId(msg.getPurposeId());
            dto.setPurposeNumber(msg.getPurposeNumber());
            dto.setProviderId(msg.getProviderId());
            dto.setProviderNumber(msg.getProviderNumber());
        }
    }
}
