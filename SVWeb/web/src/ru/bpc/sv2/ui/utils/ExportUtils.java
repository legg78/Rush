package ru.bpc.sv2.ui.utils;

import org.apache.commons.lang3.StringUtils;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import ru.bpc.sv2.invocation.ModelAdapter;
import ru.bpc.sv2.invocation.ModelDTO;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.Marshaller;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

public abstract class ExportUtils {

	//----------------- EXPORT EXCEL -------------------
	public Sheet sheet;

	public ExportUtils() {
	}

	public void exportXLS(OutputStream outputStream) throws IOException {
		Workbook wb = new HSSFWorkbook();
		sheet = wb.createSheet("new sheet");
		createHeadRow();
		createRows();
		wb.write(outputStream);
		System.out.println("Your excel file has been generated!");
	}

    public void exportXLSX(OutputStream outputStream) throws IOException {
        Workbook wb = new XSSFWorkbook();
        sheet = wb.createSheet("new sheet");
        createHeadRow();
        createRows();
        wb.write(outputStream);
        System.out.println("Your excel file has been generated!");
    }

	public abstract void createHeadRow();

	public abstract void createRows();


	private HashMap<String, CellStyle> styleCache = new HashMap<String, CellStyle>();

	protected void fillCellDate(Cell cell, Date value, String dateFormat, Locale locale) {
		if (value != null) {
			CellStyle timeStampCellStyle = styleCache.get(dateFormat);
			if (timeStampCellStyle == null) {
				Workbook wb = sheet.getWorkbook();
				timeStampCellStyle = wb.createCellStyle();
				timeStampCellStyle.setDataFormat(wb.createDataFormat().getFormat(ExcelDateFormatConverter.convert(locale, dateFormat)));
				styleCache.put(dateFormat, timeStampCellStyle);
			}
			cell.setCellValue(value);
			cell.setCellType(Cell.CELL_TYPE_NUMERIC);
			cell.setCellStyle(timeStampCellStyle);
		}
	}
	protected void fillCellNumber(Cell cell, BigDecimal value) {
		if (value != null) {
			cell.setCellValue(value.doubleValue());
		}
	}
	protected void fillCellNumber(Cell cell, Long value) {
		if (value != null) {
			cell.setCellValue(value);
		}
	}
	protected void fillCellNumber(Cell cell, Integer value) {
		if (value != null) {
			cell.setCellValue(value);
		}
	}
	protected void fillCellNumber(Cell cell, Double value) {
		if (value != null) {
			cell.setCellValue(value);
		}
	}
	protected void fillCellString(Cell cell, String value) {
		if (value != null) {
			cell.setCellValue(value);
		}
	}
	protected void fillCellBoolean(Cell cell, Boolean value) {
		if (value != null) {
			cell.setCellValue(value);
		}
	}

	//----------------- EXPORT XML -----------------
	public static void exportXML(OutputStream outputStream, List<? extends ModelIdentifiable> objList, final String rootEle,
	                             ModelAdapter adapter, ModelDTO modelDto, Class<? extends ModelDTO>... cls) throws Exception {
		final PrintStream printer = new PrintStream(outputStream);
		Marshaller marshaller = prepareMarshaller(cls);

		printer.println("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>");
		printer.print("<" + rootEle + ">");

		for (ModelIdentifiable obj : objList) {
			adapter.populateDTO(modelDto, obj);
			marshaller.marshal(modelDto, outputStream);
		}

		printer.println("</" + rootEle + ">");
	}


	private static Marshaller prepareMarshaller(Class<? extends ModelDTO>... cls) throws Exception {
		final JAXBContext jaxbContext = JAXBContext.newInstance(cls);
		final Marshaller marshaller = jaxbContext.createMarshaller();
		marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
		marshaller.setProperty(Marshaller.JAXB_FRAGMENT, true);

		return marshaller;
	}

}
