package ru.bpc.sv2.scheduler.process.utils;

import org.apache.commons.vfs.*;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.process.ProcessFileInfo;
import ru.bpc.sv2.utils.MaskFileSelector;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by Gasanov on 18.03.2016.
 */
public class FilesProcess {
    public static FileObject[] getFiles(ProcessFileInfo file) throws UserException {
        FileSystemManager fsManager;
        FileObject[] fileObjects = new FileObject[0];
        try {
            fsManager = VFS.getManager();
            FileObject locationV = fsManager.resolveFile(file.getDirectoryPath());
            boolean isDirectory = FileType.FOLDER.equals(locationV.getType());

            if (isDirectory) {
                FileSelector selector = new MaskFileSelector(file.getFileNameMask());
                fileObjects = locationV.findFiles(selector);
                locationV.close();
                try {
                    Arrays.sort(fileObjects, new Comparator<FileObject>() {
                        @Override
                        public int compare(FileObject o1, FileObject o2) {
                            return o1.getName().getBaseName().toLowerCase().compareTo(o2.getName().getBaseName().toLowerCase());
                        }
                    });
                } catch (Exception e) {
                }
            }
        } catch (FileSystemException e) {
            throw new UserException(e);
        }
        return fileObjects;
    }

    public static String moveFile(FileObject fileObject, String path) throws FileSystemException {
        String filePath = path + fileObject.getName().getBaseName();
        FileObject newFileObject = VFS.getManager().resolveFile(filePath);
        fileObject.moveTo(newFileObject);
        fileObject.close();
        return filePath;
    }

    public static String moveFile(String file, String path) throws UserException {
        try {
        FileObject fileObject = VFS.getManager().resolveFile(file);
        return moveFile(fileObject, path);
        } catch (FileSystemException e) {
            throw new UserException(e);
        }
    }

    public static String moveTo(String file, ProcessFileInfo fileInfo, String targer, Map<String, Map<String,String>> routes) throws UserException {
        try {
            FileObject fileObject = VFS.getManager().resolveFile(file);
            return moveTo(fileObject, fileInfo, targer, routes);
        } catch (FileSystemException e) {
            throw new UserException(e);
        }
    }

    public static String moveTo(FileObject fileObject, ProcessFileInfo fileInfo, String targer, Map<String, Map<String,String>> routes) throws UserException {
        String separator = System.getProperty("file.separator");
        String folder = fileInfo.getDirectoryPath();
        String path;

        if (fileInfo.getDirectoryPath().endsWith(separator)) {
            folder += targer + separator;
        } else {
            folder += separator + targer + separator;
        }

        try {
            FileObject newFO = VFS.getManager().resolveFile(folder);
            newFO.createFolder();
            path = moveFile(fileObject, folder);
        } catch (FileSystemException e) {
            throw new UserException(e);
        }

        Map<String, String> route = routes.get(fileObject.getName().getBaseName());
        if(route == null){
            route = new HashMap<String, String>();
            route.put("from", fileInfo.getDirectoryPath());
            routes.put(fileObject.getName().getBaseName(), route);
        }
        route.put("to", path);

        return path;
    }

    public static void rollback(Map<String, Map<String, String>> routes) throws UserException {
        for (Map.Entry<String, Map<String, String>> entry : routes.entrySet()) {
            Map<String, String> route = entry.getValue();
            moveFile(route.get("to"), route.get("from"));
        }
    }
}
