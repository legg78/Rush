package ru.bpc.sv2.issuing.personalization;

import java.io.Serializable;

public class PersoBatchCard extends PersoCard  implements Serializable{
	private static final long serialVersionUID = 1L;

	private Boolean pinGenerated;
	private Boolean pinMailerPrinted;
	private Boolean embossingDone;

	public Boolean getPinGenerated() {
		return pinGenerated;
	}

	public void setPinGenerated(Boolean pinGenerated) {
		this.pinGenerated = pinGenerated;
	}

	public Boolean getPinMailerPrinted() {
		return pinMailerPrinted;
	}

	public void setPinMailerPrinted(Boolean pinMailerPrinted) {
		this.pinMailerPrinted = pinMailerPrinted;
	}

	public Boolean getEmbossingDone() {
		return embossingDone;
	}

	public void setEmbossingDone(Boolean embossingDone) {
		this.embossingDone = embossingDone;
	}

	@Override
	public PersoBatchCard clone() throws CloneNotSupportedException {
		return (PersoBatchCard) super.clone();
	}
}
