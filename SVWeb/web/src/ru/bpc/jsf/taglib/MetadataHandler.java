package ru.bpc.jsf.taglib;

import com.sun.facelets.FaceletContext;
import com.sun.facelets.tag.TagConfig;
import com.sun.facelets.tag.TagHandler;
import com.sun.facelets.tag.jsf.core.FacetHandler;
import com.sun.faces.util.Util;

import javax.faces.application.Application;
import javax.faces.component.UIComponent;
import javax.faces.component.UIPanel;
import javax.faces.component.UIViewRoot;
import java.io.IOException;

public class MetadataHandler extends TagHandler {


	public MetadataHandler(TagConfig config) {
		super(config);
	}


	// ------------------------------------------------- Methods from TagHandler

	public void apply(FaceletContext ctx, UIComponent parent) throws IOException {

		Util.notNull("parent", parent);
		UIViewRoot root;
		if (parent instanceof UIViewRoot) {
			root = (UIViewRoot) parent;
		} else {
			root = ctx.getFacesContext().getViewRoot();
		}
		if (root == null) {
			return;
		}

		UIComponent facetComponent = null;
		if (root.getFacetCount() > 0) {
			facetComponent = root.getFacets().get(UIViewRoot.METADATA_FACET_NAME);
		}
		if (facetComponent == null) {
			root.getAttributes().put(FacetHandler.KEY,
					UIViewRoot.METADATA_FACET_NAME);
			try {
				this.nextHandler.apply(ctx, root);
			} finally {
				root.getAttributes().remove(FacetHandler.KEY);
			}
			facetComponent = root.getFacets().get(UIViewRoot.METADATA_FACET_NAME);
			if (facetComponent != null && !(facetComponent instanceof UIPanel)) {
				Application app = ctx.getFacesContext().getApplication();
				UIComponent panelGroup = app.createComponent(UIPanel.COMPONENT_TYPE);
				panelGroup.getChildren().add(facetComponent);
				root.getFacets().put(UIViewRoot.METADATA_FACET_NAME, panelGroup);
				facetComponent = panelGroup;
				facetComponent.setId(UIViewRoot.METADATA_FACET_NAME);
			}
		}
	}
}
