package ru.bpc.sv2.rest.v1.fraud;

import org.springframework.web.bind.annotation.*;
import ru.bpc.sv2.fraud.McwFraud;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.IntegrationDao;
import ru.bpc.sv2.rest.v1.BaseRestController;
import ru.bpc.sv2.rest.v1.PaginatedListResult;
import ru.bpc.sv2.utils.UserException;

@RestController
@RequestMapping("/fraud")
public class McwFraudRest extends BaseRestController {
	private IntegrationDao integrationDao = new IntegrationDao();

	@GetMapping(value = "/list/{offset}/{count}")
	public PaginatedListResult<McwFraud> getMcwFrauds(
			@PathVariable(value = "offset") Integer offset,
			@PathVariable(value = "count") Integer count,

			@RequestParam(value = "id", required = false) Long id,
			@RequestParam(value = "instId", required = false) Integer instId,
			@RequestParam(value = "fileId", required = false) Long fileId,
			@RequestParam(value = "disputeId", required = false) Long disputeId,
			@RequestParam(value = "status", required = false) String status) throws UserException {

		Long sessionId = getSessionId();

		SelectionParams params = createSelectionParams(offset, count, "id", id,
				"instId", instId,
				"fileId", fileId,
				"disputeId", disputeId,
				"status", status);

		PaginatedListResult<McwFraud> result = new PaginatedListResult<McwFraud>();
		result.setOffset(offset);
		result.setTotal(integrationDao.getMcwFraudsCount(sessionId, params));
		result.setEntries(integrationDao.getMcwFrauds(sessionId, params));
		result.setCount(result.getEntries().size());

		return result;
	}

	@PostMapping()
	public McwFraud createMcwFraud(@RequestBody McwFraud fraud) throws UserException {

		integrationDao.createMcwFraud(getSessionId(), fraud);
		return fraud;
	}

	@PutMapping(value = "/{id}")
	public McwFraud updateMcwFraud(
			@PathVariable("id") Long id,
			@RequestBody McwFraud fraud) throws UserException {

		fraud.setId(id);
		integrationDao.updateMcwFraud(getSessionId(), fraud);
		return fraud;
	}

	@DeleteMapping(value = "/{id}")
	public void deleteMcwFraud(@PathVariable("id") Long id) throws UserException {
		integrationDao.deleteMcwFraud(getSessionId(), id);
	}
}
