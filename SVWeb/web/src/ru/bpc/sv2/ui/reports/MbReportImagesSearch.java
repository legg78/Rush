package ru.bpc.sv2.ui.reports;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.reports.ReportImage;
import ru.bpc.sv2.ui.utils.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.io.*;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbReportImagesSearch")
public class MbReportImagesSearch extends AbstractBean {
    private static final Logger logger = Logger.getLogger("REPORTS");

    private final DaoDataModel<ReportImage> imageSource;
    private final TableRowSelection<ReportImage> itemSelection;
    private ReportImage activeImage;
    private ReportImage filter;

    private ReportsDao reportsDao = new ReportsDao();

    public MbReportImagesSearch() {
        imageSource = new DaoDataListModel<ReportImage>(logger) {
            @Override
            protected List<ReportImage> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return reportsDao.getReportImages(userSessionId, params);
                }
                return new ArrayList<ReportImage>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return reportsDao.getReportImagesCount(userSessionId, params);
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<ReportImage>(null, imageSource);
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", userLang));
        if (filter.getId() != null) {
            filters.add(Filter.create("id", filter.getId()));
        }
        if (filter.getReportId() != null) {
            filters.add(Filter.create("reportId", filter.getReportId()));
        }
        if (StringUtils.isNotBlank(filter.getReportName())) {
            filters.add(Filter.create("reportName", Filter.mask(filter.getReportName())));
        }
        if (filter.getBannerId() != null) {
            filters.add(Filter.create("bannerId", filter.getBannerId()));
        }
        if (StringUtils.isNotBlank(filter.getBannerName())) {
            filters.add(Filter.create("bannerName", Filter.mask(filter.getBannerName())));
        }
        if (filter.getStatus() != null) {
            filters.add(Filter.create("status", filter.getStatus()));
        }
    }

    public ReportImage getFilter() {
        if (filter == null) {
            setFilter(new ReportImage());
        }
        return filter;
    }
    public void setFilter(ReportImage filter) {
        this.filter = filter;
    }

    public DaoDataModel<ReportImage> getImages() {
        return imageSource;
    }

    public ReportImage getActiveImage() {
        return activeImage;
    }
    public void setActiveImage(ReportImage activeImage) {
        activeImage = activeImage;
    }

    public SimpleSelection getItemSelection() {
        try {
            if (activeImage == null && imageSource.getRowCount() > 0) {
                setFirstRowActive();
            } else if (activeImage != null && imageSource.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(activeImage.getModelId());
                itemSelection.setWrappedSelection(selection);
                activeImage = itemSelection.getSingleSelection();
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
        return itemSelection.getWrappedSelection();
    }
    public void setItemSelection(SimpleSelection selection) {
        itemSelection.setWrappedSelection(selection);
        activeImage = itemSelection.getSingleSelection();
    }

    public void setFirstRowActive() {
        imageSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeImage = (ReportImage) imageSource.getRowData();
        selection.addKey(activeImage.getModelId());
        itemSelection.setWrappedSelection(selection);
    }

    public void search() {
        clearState();
        searching = true;
    }

    public void clearState() {
        itemSelection.clearSelection();
        activeImage = null;
        imageSource.flushCache();
        curLang = userLang;
    }

    public byte[] getBannerImage() {
        try {
            if (activeImage != null && StringUtils.isNotBlank(activeImage.getFileName())) {
                return getImageBytes(activeImage.getFileName());
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
        return new byte[0];
    }

    public int getBannerImageSize() {
        return getBannerImage().length;
    }

    @Override
    public void clearFilter() {
        clearState();
        filter = null;
        searching = false;
    }

    private byte[] getImageBytes(String filename) throws Exception {
        InputStream is = null;
        try {
            File file = new File(filename);
            if (file.isFile()) {
                is = new FileInputStream(file);
                int length = 0;
                byte[] buffer = new byte[2048];
                ByteArrayOutputStream out = new ByteArrayOutputStream();
                while ((length = is.read(buffer)) > 0) {
                    out.write(buffer, 0, length);
                }
                return out.toByteArray();
            }
        } catch (Exception e) {
            logger.error("", e);
            throw e;
        } finally {
            if (is != null) {
                try {
                    is.close();
                } catch (IOException e) {
                    logger.error("", e);
                }
            }
        }
        return new byte[0];
    }
}
