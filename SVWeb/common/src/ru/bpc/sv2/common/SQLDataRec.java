package ru.bpc.sv2.common;

import oracle.sql.CLOB;
import oracle.sql.OracleSQLOutput;
import oracle.xdb.XMLType;


import javax.xml.bind.DatatypeConverter;
import javax.xml.bind.JAXBElement;
import javax.xml.datatype.XMLGregorianCalendar;
import java.io.IOException;
import java.io.Writer;
import java.math.BigDecimal;
import java.sql.*;
import java.util.GregorianCalendar;
import java.util.Date;

public abstract class SQLDataRec implements SQLData {
    protected Connection connection;

    public Connection getConnection() {
        return connection;
    }
    public void setConnection(Connection connection) {
        this.connection = connection;
    }

    @Override
    public abstract String getSQLTypeName() throws SQLException;
    @Override
    public abstract void writeSQL(SQLOutput stream) throws SQLException;
    @Override
    public void readSQL(SQLInput stream, String typeName) throws SQLException {
        throw new UnsupportedOperationException();
    }

    protected void writeValueNull(SQLOutput stream) throws SQLException {
        stream.writeObject(null);
    }

    protected void writeValueV(SQLOutput stream, String str) throws SQLException {
        if (str != null) {
            stream.writeString(str);
        } else {
            stream.writeObject(null);
        }
    }
    protected void writeValueV(SQLOutput stream, JAXBElement str) throws SQLException {
        if (str != null && str.getValue() != null) {
            stream.writeString(str.getValue().toString());
        } else {
            stream.writeObject(null);
        }
    }

    protected void writeValueClob(SQLOutput stream, String str) throws SQLException {
        if (str != null) {
            CLOB clob = CLOB.createTemporary(connection, true, CLOB.DURATION_SESSION);
            try {
                Writer w = clob.getCharacterOutputStream();
                w.write(str);
                w.close();
                ((OracleSQLOutput) stream).writeClob(clob);
            } catch (IOException e) {
                throw new SQLException(e);
            }
        } else {
            stream.writeObject(null);
        }
    }

    protected void writeValueD(SQLOutput stream, Date date) throws SQLException {
        if (date != null) {
            stream.writeDate(new java.sql.Date(date.getTime()));
        } else {
            stream.writeObject(null);
        }
    }
    protected void writeValueD(SQLOutput stream, XMLGregorianCalendar date) throws SQLException {
        if (date != null) {
            stream.writeDate(new java.sql.Date(date.toGregorianCalendar().getTimeInMillis()));
        } else {
            stream.writeObject(null);
        }
    }
    protected void writeValueD(SQLOutput stream, JAXBElement date) throws SQLException {
        if (date != null && date.getValue() != null) {
            writeValueD(stream, date.getValue());
        } else {
            stream.writeObject(null);
        }
    }
    protected void writeValueD(SQLOutput stream, Object date) throws SQLException {
        if (date != null) {
            if (date instanceof Date) {
                writeValueD(stream, (Date) date);
            } else if (date instanceof XMLGregorianCalendar) {
                writeValueD(stream, (XMLGregorianCalendar) date);
            } else {
                stream.writeObject(null);
            }
        } else {
            stream.writeObject(null);
        }
    }

    protected void writeValueT(SQLOutput stream, Date date) throws SQLException {
        if (date != null) {
            stream.writeTimestamp(new java.sql.Timestamp(date.getTime()));
        } else {
            stream.writeObject(null);
        }
    }
    protected void writeValueT(SQLOutput stream, XMLGregorianCalendar date) throws SQLException {
        if (date != null) {
            stream.writeTimestamp(new java.sql.Timestamp(date.toGregorianCalendar().getTimeInMillis()));
        } else {
            stream.writeObject(null);
        }
    }
    protected void writeValueT(SQLOutput stream, JAXBElement date) throws SQLException {
        if (date != null && date.getValue() != null) {
            writeValueD(stream, date.getValue());
        } else {
            stream.writeObject(null);
        }
    }
    protected void writeValueT(SQLOutput stream, Object date) throws SQLException {
        if (date != null) {
            if (date instanceof Date) {
                writeValueD(stream, (Date) date);
            } else if (date instanceof XMLGregorianCalendar) {
                writeValueD(stream, (XMLGregorianCalendar) date);
            } else {
                stream.writeObject(null);
            }
        } else {
            stream.writeObject(null);
        }
    }

    protected void writeValueN(SQLOutput stream, Integer number) throws SQLException {
        if (number != null) {
            stream.writeInt(number);
        } else {
            stream.writeObject(null);
        }
    }
    protected void writeValueN(SQLOutput stream, Long number) throws SQLException {
        if (number != null) {
            stream.writeLong(number);
        } else {
            stream.writeObject(null);
        }
    }
    protected void writeValueN(SQLOutput stream, Float number) throws SQLException {
        if (number != null) {
            stream.writeFloat(number);
        } else {
            stream.writeObject(null);
        }
    }
    protected void writeValueN(SQLOutput stream, Double number) throws SQLException {
        if (number != null) {
            stream.writeDouble(number);
        } else {
            stream.writeObject(null);
        }
    }
    protected void writeValueN(SQLOutput stream, BigDecimal number) throws SQLException {
        if (number != null) {
            stream.writeBigDecimal(number);
        } else {
            stream.writeObject(null);
        }
    }
    protected void writeValueN(SQLOutput stream, JAXBElement number) throws SQLException {
        if (number != null && number.getValue() != null) {
            writeValueN(stream, number.getValue());
        } else {
            stream.writeObject(null);
        }
    }
    protected void writeValueN(SQLOutput stream, Object number) throws SQLException {
        if (number != null) {
            if (number instanceof Long) {
                writeValueN(stream, (Long) number);
            } else if (number instanceof Integer) {
                writeValueN(stream, (Integer) number);
            } else if (number instanceof BigDecimal) {
                writeValueN(stream, (BigDecimal) number);
            } else if (number instanceof Double) {
                writeValueN(stream, (Double) number);
            } else if (number instanceof Float) {
                writeValueN(stream, (Float) number);
            } else {
                stream.writeString(number.toString());
            }
        } else {
            stream.writeObject(null);
        }
    }

    protected void writeValueB(SQLOutput stream, Boolean bool) throws SQLException {
        if (bool != null) {
            stream.writeBoolean(bool);
        } else {
            stream.writeObject(null);
        }
    }
    protected void writeValueB(SQLOutput stream, JAXBElement bool) throws SQLException {
        if (bool != null && bool.getValue() != null) {
            if (bool.getValue() instanceof Boolean) {
                writeValueB(stream, (Boolean)bool.getValue());
            } else {
                stream.writeInt(Integer.valueOf(bool.getValue().toString()));
            }
        } else {
            stream.writeObject(null);
        }
    }

    protected void writeValueXml(SQLOutput stream, String xml) throws SQLException {
        if (xml != null && xml.trim().length() > 0) {
            stream.writeObject(null);
        } else {
            stream.writeSQLXML(XMLType.createXML(connection, xml));
        }
    }

    protected Object getConvertedValue(Object value) {
        if (value instanceof String) {
            try {
                BigDecimal tmp = new BigDecimal((String)value);
                try {
                    return Integer.valueOf((String)value);
                } catch (Exception e) {
                    try {
                        return Long.valueOf((String)value);
                    } catch (Exception e1) {
                        return tmp;
                    }
                }
            } catch (Exception e) {
                try {
                    return DatatypeConverter.parseDateTime((String)value).getTime();
                } catch (Exception ignored) {}
            }
        }
        return value;
    }
}
