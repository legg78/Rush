package ru.bpc.sv2.ui.utils;

import net.coobird.thumbnailator.Thumbnails;
import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.richfaces.event.UploadEvent;
import org.richfaces.model.UploadItem;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.awt.image.RenderedImage;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

/**
 * User: Mamedov Eduard
 * Date: 20.11.13
 */
@SessionScoped
@ManagedBean(name = "MbLogo")
public class LogoUtils extends AbstractBean {

    private final static Logger LOGGER = Logger.getLogger("COMMON");
    private final static int MAX_LOGO_HEIGHT = 37;
    private final static int MAX_LOGO_WIDTH  = 170;
    private final static String LOGO_PATH    = "/_img/bpc_logo.png";
    private String logoPath;
    private BufferedImage image;
    protected SettingsDao settingsDao = new SettingsDao();

    @SuppressWarnings("deprecation")
    public void logoUploadListener(UploadEvent event) throws Exception {
        UploadItem item = event.getUploadItem();
        if (!checkMaximumFileSize(item.getFileSize())) {
            FacesUtils.addMessageError("File size is too big");
            LOGGER.error("File size is too big");
        }
        FileOutputStream fos = null;
        FileInputStream fis = null;
        try {
            fis = new FileInputStream(resize(item.getFile()));
            File logo = new File(RequestContextHolder.getRequest().getRealPath(LOGO_PATH));
            if (logo.exists()) {
	            //noinspection ResultOfMethodCallIgnored
	            logo.delete();
	            //noinspection ResultOfMethodCallIgnored
	            logo.createNewFile();
                fos = new FileOutputStream(logo);
                IOUtils.copy(fis, fos);
            }
        } catch (Throwable e){
            LOGGER.error("Can't change logo:", e);
        }
        finally {
            IOUtils.closeQuietly(fis);
            IOUtils.closeQuietly(fos);
        }
    }

    private File resize(File file) throws Exception {
        BufferedImage image = ImageIO.read(file);
        File resizeImage = file;
        if (image.getHeight() > MAX_LOGO_HEIGHT || image.getWidth() > MAX_LOGO_WIDTH) {
            resizeImage = File.createTempFile("logo", ".png");
            int height = image.getHeight() > MAX_LOGO_HEIGHT ? MAX_LOGO_HEIGHT : image.getHeight();
            int width =  image.getWidth() > MAX_LOGO_WIDTH ? MAX_LOGO_WIDTH : image.getWidth();
            Thumbnails.of(image).forceSize(width, height).toFile(resizeImage);
        }
        return resizeImage;
    }

    public RenderedImage getLogo(){
        if (image == null) {
            reloadImage();
            LOGGER.debug("loading image");
            String pathToLogo;
            if (LOGO_PATH.equalsIgnoreCase(logoPath)) {
                pathToLogo = FacesContext.getCurrentInstance().getExternalContext().getRealPath(LOGO_PATH);
            } else {
                pathToLogo = logoPath;
            }
            try {
                image = ImageIO.read(new File(pathToLogo));
            } catch (Exception e) {
                LOGGER.error(e.getMessage(), e);
            }
        }
        return image;
    }

    private void reloadImage(){
	    try {
		    if (settingsDao == null) {
			    settingsDao = new SettingsDao();
		    }

            String pathToLogo = userSessionId != null ?
		            settingsDao.getParameterValueV(userSessionId,
                    SettingsConstants.PATH_TO_LOGO, LevelNames.INSTITUTION, null) : null;
            if (pathToLogo == null) {
                logoPath = LOGO_PATH;
            } else {
                logoPath = pathToLogo;
            }
        }catch (Exception e){
		    LOGGER.error(e.getMessage(), e);
            logoPath = LOGO_PATH;
        }
    }

    public void nullImage(){
        image = null;
    }

	@Override
	public void clearFilter() {
		// noop
	}
}
