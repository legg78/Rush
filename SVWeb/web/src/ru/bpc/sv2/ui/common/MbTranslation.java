package ru.bpc.sv2.ui.common;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellUtil;
import org.richfaces.event.UploadEvent;
import org.richfaces.model.UploadItem;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.Translation;
import ru.bpc.sv2.common.TranslationTextRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.bundles.BaseBundle;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbTranslation")
public class MbTranslation extends AbstractBean {
	private static final Logger logger = Logger.getLogger("COMMON");

	private static String COMPONENT_ID = "1842:translationsTable";

	
	private Translation filter;
	private final DaoDataModel<Translation> _translationSource;
	private final TableRowSelection<Translation> _itemSelection;
	private Translation _activeTranslation;


    List<TranslationTextRec> uploadedText = null;

	private CommonDao _commonDao = new CommonDao();

	public MbTranslation() {
		
		pageLink = "admin|translation";
		_translationSource = new DaoDataModel<Translation>() {
			@Override
			protected Translation[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Translation[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getTranslations(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					setDataSize(0);
					logger.error("", e);
				}
				return new Translation[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getTranslationCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Translation>(null, _translationSource);
	}

	public void saveTranslation() {
		try {
			List<Translation> translations = getTranslations().getActivePage();
			Set<String> langs = new HashSet<String>();
			for (Translation translation : translations) {
				if (translation.getSrcText() != null &&
						!translation.getSrcText().equals(translation.getSrcTextOld())) {
					_commonDao.modifyTranslationSource(userSessionId, translation);
					langs.add(translation.getSourceLang());
				}
				if (translation.getDstText() != null &&
						!translation.getDstText().equals(translation.getDstTextOld())) {
					_commonDao.modifyTranslationDest(userSessionId, translation);
                    langs.add(translation.getDestLang());
				}
			}
			for(String lang: langs) {
                BaseBundle.clearAll(lang);
            }

			// _idTypesSource.replaceObject(_activeIdType, newIdType);
			// setBeans();
			// curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public SimpleSelection getItemSelection() {
		if (_activeTranslation == null && _translationSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeTranslation != null && _translationSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeTranslation.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeTranslation = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_translationSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTranslation = (Translation) _translationSource.getRowData();
		selection.addKey(_activeTranslation.getModelId());
		_itemSelection.setWrappedSelection(selection);
		// if (_activeTranslation != null) {
		// setInfo();
		// }
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeTranslation = _itemSelection.getSingleSelection();
		// if (_activeCard != null) {
		// setInfo();
		// }
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeTranslation = null;
		_translationSource.flushCache();
		curLang = userLang;
        uploadedText = null;
		// loadedTabs.clear();

		// clearBeansStates();
	}

	public Translation getFilter() {
		if (filter == null) {
			filter = new Translation();
			// filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Translation filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;

		paramFilter = new Filter();
		paramFilter.setElement("translateExists");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(filter.isTranslateExists());
		filters.add(paramFilter);

		if (filter.getSourceLang() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("sourceLang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getSourceLang());
			filters.add(paramFilter);
		}
		if (filter.getDestLang() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("destLang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getDestLang());
			filters.add(paramFilter);
		}

		if (filter.getTableName() != null && filter.getTableName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("tableName");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getTableName().trim().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getColumnName() != null && filter.getColumnName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("columnName");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getColumnName().trim().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getSrcText() != null && filter.getSrcText().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("srcText");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getSrcText().trim().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getDstText() != null && filter.getDstText().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("dstText");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getDstText().trim().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getObjectId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getObjectId());
			filters.add(paramFilter);
		}

	}

	public void search() {
		clearState();
		// clearBeansStates();
		searching = true;
	}

	public DaoDataModel<Translation> getTranslations() {
		return _translationSource;
	}

	public Translation getActiveTranslation() {
		return _activeTranslation;
	}

	public void setActiveTranslation(Translation activeTranslation) {
		_activeTranslation = activeTranslation;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	@Override
	public void clearFilter() {
		filter = null;
		clearState();
        uploadedText = null;
		searching = false;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new Translation();
				if (filterRec.get("sourceLang") != null) {
					filter.setSourceLang(filterRec.get("sourceLang"));
				}
				if (filterRec.get("tableName") != null) {
					filter.setTableName(filterRec.get("tableName"));
				}
				if (filterRec.get("destLang") != null) {
					filter.setDestLang(filterRec.get("destLang"));
				}
				if (filterRec.get("columnName") != null) {
					filter.setColumnName(filterRec.get("columnName"));
				}
				if (filterRec.get("srcText") != null) {
					filter.setSrcText(filterRec.get("srcText"));
				}
				if (filterRec.get("dstText") != null) {
					filter.setDstText(filterRec.get("dstText"));
				}
				if (filterRec.get("translateExists") != null) {
					filter.setTranslateExists(filterRec.get("translateExists").equals("true"));
				}
			}
			if (searchAutomatically) {
				search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			if (filter.getSourceLang() != null) {
				filterRec.put("sourceLang", filter.getSourceLang());
			}
			if (filter.getTableName() != null) {
				filterRec.put("tableName", filter.getTableName());
			}
			if (filter.getDestLang() != null) {
				filterRec.put("destLang", filter.getDestLang());
			}
			if (filter.getColumnName() != null) {
				filterRec.put("columnName", filter.getColumnName());
			}
			if (filter.getSrcText() != null) {
				filterRec.put("srcText", filter.getSrcText());
			}
			if (filter.getDstText() != null) {
				filterRec.put("dstText", filter.getDstText());
			}
			if (filter.isTranslateExists()) {
				filterRec.put("translateExists", filter.isTranslateExists() ? "true" : "false");
			}
			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void unload() {
        try {
            Filter filter = new Filter("lang", getFilter().getSourceLang());
            SelectionParams params = new SelectionParams(filter);
            List<String> strings = _commonDao.getUniqueI18nStrings(userSessionId, params);

            byte[] reportContent = generateXlsx(strings);
            downloadXlsx(reportContent);

        } catch(Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    private byte[] generateXlsx(final List<String> strings) throws IOException {
        final ExportUtils ex = new ExportUtils() {

            @Override
            public void createHeadRow() {
                Row rowhead = sheet.createRow((short) 0);
                rowhead.createCell(0).setCellValue("Source text");
                rowhead.createCell(1).setCellValue("Translated text");

                sheet.setColumnWidth(0, 20 * 256);
                sheet.setColumnWidth(1, 20 * 256);
            }

            @Override
            public void createRows() {
                int i = 2;
                for(String string: strings) {
                    Row row = sheet.createRow(i++);
                    row.createCell(0).setCellValue(string);
                }
            }
        };

        ByteArrayOutputStream outStream = new ByteArrayOutputStream();
        ex.exportXLSX(outStream);

        byte[] reportContent = outStream.toByteArray();
        try {
            outStream.close();
        } catch (IOException ignored) {
        }

        return reportContent;
    }

    private void downloadXlsx(byte[] reportContent) {
        FacesContext context = FacesContext.getCurrentInstance();
        HttpServletResponse response = RequestContextHolder.getResponse();
        response.setHeader("Pragma", "no-cache");
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition","attachment; filename=translations.xlsx;");
        try {
            OutputStream output = response.getOutputStream();
            output.write(reportContent);
            output.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        context.responseComplete();
    }

    public void fileUploadListener(UploadEvent event) throws Exception {
        InputStream is = null;
        try {
            uploadedText = new ArrayList<TranslationTextRec>();
            UploadItem item = event.getUploadItem();
            File file = item.getFile();

            is = new FileInputStream(file);

            Workbook wb = WorkbookFactory.create(is);
            Sheet sheet = wb.getSheetAt(0);

            int size = sheet.getLastRowNum();
            for(int rowIndex = 2; rowIndex < size; rowIndex++) {
                Row row = CellUtil.getRow(rowIndex, sheet);

                String sourceValue = CellUtil.getCell(row, 0).getStringCellValue();
                String destinationValue = CellUtil.getCell(row, 1).getStringCellValue();

                if (StringUtils.isNotEmpty(sourceValue) && StringUtils.isNotEmpty(destinationValue)) {
                    TranslationTextRec rec = new TranslationTextRec();
                    rec.setSourceText(sourceValue);
                    rec.setDestinationText(destinationValue);
                    uploadedText.add(rec);
                }
            }

        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        } finally {
            IOUtils.closeQuietly(is);
        }
    }

    public void saveUploadedText() {
        try {
            if (!uploadedText.isEmpty()) {
                _commonDao.loadTranslationText(userSessionId, getFilter().getSourceLang(), getFilter().getDestLang(), uploadedText);
            }
            uploadedText = null;
            BaseBundle.clearAll(getFilter().getDestLang());
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void closeUploadedText() {
        uploadedText = null;
    }


    public List<TranslationTextRec> getUploadedText() {
        return uploadedText;
    }

    public void setUploadedText(List<TranslationTextRec> uploadedText) {
        this.uploadedText = uploadedText;
    }
}
