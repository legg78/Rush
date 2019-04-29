package ru.bpc.sv2.common;

import ru.bpc.sv2.utils.AuthOracleTypeNames;

import java.sql.SQLException;
import java.sql.SQLOutput;

public class TranslationTextRec extends SQLDataRec {
    private String sourceText;
    private String destinationText;

    @Override
    public String getSQLTypeName() throws SQLException {
        return AuthOracleTypeNames.COM_TRANSLATION_TEXT_REC;
    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        stream.writeString(sourceText);
        stream.writeString(destinationText);
    }

    public String getSourceText() {
        return sourceText;
    }

    public void setSourceText(String sourceText) {
        this.sourceText = sourceText;
    }

    public String getDestinationText() {
        return destinationText;
    }

    public void setDestinationText(String destinationText) {
        this.destinationText = destinationText;
    }
}
