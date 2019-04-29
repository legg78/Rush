package ru.bpc.sv2.scheduler.process.utils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
public enum ResponseResultCodes {

    UNKNOWN(-1, "Unknown"),
    SUCCESS(0, "Full success"),
    SUCCESS_WITH_WARNINGS(1, "Success with rejects"),
    UNCLASSIFIED(100, "Unclassified error"),
    INVALID_SESSION_ID(101, "Invalid session ID"),
    INVALID_PARAMETERS_IN_REQUEST(102, "Invalid parameters in the request"),
    ERROR_OPENING_FILE(103, "Error opening or creating file"),
    ERROR_READ_WRITE_FILE(104, "I/O error (unable to read or write data to the file)"),
    UNABLE_EXECUTE_PROCESS(105, "Unable to execute the process"),
    UNSUCCESSFUL_EXIT_CODE(106, "Executed process finished with unsuccessful exit code"),
    CONCURRENT_PROCESS_EXEC(107, "Concurrent process is executing"),
    USER_CANCELLATION(108, "The process was interrupted by user"),

    ERROR_CLOSE_STTL_DAY(200, "Error closing settlement day"),
    INVALID_DATA_IN_GENERATED_FILE(201, "Invalid data in the generated (posting) file"),
    ERROR_CONSTRUCT_FILE_TRAILER(202, "Error constructing the file trailer"),
    NO_DATA_IN_FILE(203, "No data in generated files"),
    NO_REJECT_FILES(204, "No files have been found"),
    NO_FILES_FOUND(205, "No files have been found"),

    ERROR_OPEN_MQ_SESSION(400, "Error opening the MQ session"),
    ERROR_OPEN_QUEUE(401, "Error opening the queue"),
    ERROR_READ_QUEUE(402, "Error reading the queue"),
    ERROR_WRITE_QUEUE(403, "Error writing into the queue"),
    QUEUE_OVERFLOW(404, "Queue overflow (the error produced after the retry timeout)"),
    MQ_AWAITING_TIMEOUT(405, "Timeout on waiting for incoming data from the queue"),
    ERROR_CONSTRUCT_PACK(406, "Error constructing a data pack"),
    RECEIVED_PACK_HAS_INVALID_FORMAT(407, "The received package has invalid format or divergence in data"),
    ERROR_OPEN_MQ_CONNECTION(408, "Error opening the MQ connection"),
    ERROR_INITIALIZE_MQ(409, "Error initializing the MQ client"),

    UNABLE_SEND_REQUEST_TO_FE(500, "Unable to send request to FE web service"),
    RESPONSE_FE_TIMEOUT(501, "Timed out waiting for response from FE web service"),
    RESPONSE_FE_FAIL(502, "Failed to wait for response from FE web service"),

    SIGN_4XX(4, "4"),
    SIGN_1XX(1, "1"),
    SIGN_2XX(2, "2");

    private static final Logger log = LoggerFactory.getLogger(ResponseResultCodes.class);
    private int code;
    private String text;


    ResponseResultCodes(int code, String text) {
        this.code = code;
        this.text = text;
    }

    public int getCode() {
        return code;
    }

    public String getText() {
        return text;
    }

    public static ResponseResultCodes byCode(int code) {
        for (ResponseResultCodes item : values()) {
            if (item.getCode() == code) {
                return item;
            }
        }
        log.warn("Could not find ProcessorResultCode by code: {}", code);
        return UNKNOWN;
    }
}
