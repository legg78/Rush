package util.conversion.installment;

import org.jdom.Document;
import org.jdom.Element;
import ru.bpc.sv.merchantportalws.Installment;
import ru.bpc.sv.merchantportalws.InstallmentAlgorithmType;
import ru.bpc.sv.merchantportalws.InstallmentPlanTypeResp;
import ru.bpc.sv.merchantportalws.InstallmentsType;
import util.conversion.date.ConversionDate;

import java.util.List;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
public class InstallmentPlanConversion {

    Document document;

    private InstallmentPlanConversion(){}

    public InstallmentPlanConversion(Document document) {
        this.document = document;
    }

    public InstallmentPlanTypeResp converseXmlToResponseObject() throws Exception {
        Element root = document.getRootElement();
        InstallmentPlanTypeResp installmentPlanTypeResp = new InstallmentPlanTypeResp();
        installmentPlanTypeResp.setTransactionAmount(Long.valueOf(root.getChild("transaction_amount").getValue()));
        installmentPlanTypeResp.setInstallmentsCount(Integer.valueOf(root.getChild("installments_count").getValue()));
        installmentPlanTypeResp.setFixedPaymentAmount(Long.valueOf(root.getChild("fixed_payment_amount").getValue()));
        installmentPlanTypeResp.setInstallmentPeriod(Integer.valueOf(root.getChild("installment_period").getValue()));
        installmentPlanTypeResp.setFirstInstallmentDate(new ConversionDate(root.getChild("first_installment_date").getValue()).stringDateToCalendar());
        installmentPlanTypeResp.setInterestRate(root.getChild("interest_rate").getValue());
        installmentPlanTypeResp.setInstallmentAlgorithm(InstallmentAlgorithmType.fromValue(root.getChild("installment_algorithm").getValue()));

        Element installmentsElement = root.getChild("installments");
        List installmentList = installmentsElement.getChildren("installment");

        InstallmentsType installmentsType = new InstallmentsType();

        for (int i = 0; i < installmentList.size(); i++) {
            Element item = (Element) installmentList.get(i);
            Installment installment = new Installment();
            installment.setNumber(Integer.valueOf(item.getChild("number").getValue()));
            installment.setDate(new ConversionDate(item.getChild("date").getValue()).stringDateToCalendar());
            installment.setAmount(Long.valueOf(item.getChild("amount").getValue()));
            installment.setInstallmentAmount(Long.valueOf(item.getChild("installment_amount").getValue()));
            installment.setInterest(Integer.valueOf(item.getChild("interest").getValue()));
            installmentsType.getInstallment().add(installment);
        }

        installmentPlanTypeResp.setInstallments(installmentsType);
        return installmentPlanTypeResp;
    }

}
