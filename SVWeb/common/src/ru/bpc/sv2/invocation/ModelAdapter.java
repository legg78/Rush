package ru.bpc.sv2.invocation;


public interface ModelAdapter {

	public void populateDTO(final ModelDTO modelDto, final ModelIdentifiable model);

}
