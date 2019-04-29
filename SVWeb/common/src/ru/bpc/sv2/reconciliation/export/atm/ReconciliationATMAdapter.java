package ru.bpc.sv2.reconciliation.export.atm;

import ru.bpc.sv2.invocation.ModelAdapter;
import ru.bpc.sv2.invocation.ModelDTO;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.reconciliation.RcnMessage;

import java.math.BigDecimal;

public class ReconciliationATMAdapter implements ModelAdapter {

    @Override
    public void populateDTO(ModelDTO modelDto, ModelIdentifiable model) {
        if (modelDto instanceof ReconciliationATMDTO && model instanceof RcnMessage) {
            ReconciliationATMDTO dto = (ReconciliationATMDTO) modelDto;
            RcnMessage rec = (RcnMessage) model;

            dto.setReconStatus(rec.getReconStatus());
            dto.setReconLastDateTime(rec.getReconLastDateTime());
            dto.setOperDate(rec.getOperDate());
            dto.setOperAmount(rec.getOperAmount() != null ? new BigDecimal(rec.getOperAmount()) : null);
            dto.setOperCurrency(rec.getOperCurrency());
            dto.setTraceNumber(rec.getTraceNumber());
            dto.setAcqInstId(rec.getAcqInstId());
            dto.setCardMask(rec.getCardMask());
            dto.setAuthCode(rec.getAuthCode());
            dto.setTerminalNum(rec.getTerminalNum());
            dto.setAccFrom(rec.getAccFrom());
            dto.setAccTo(rec.getAccTo());
        }
    }
}
