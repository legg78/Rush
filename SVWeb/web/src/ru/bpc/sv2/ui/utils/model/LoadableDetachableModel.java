package ru.bpc.sv2.ui.utils.model;

/**
 * Model that holds its value until after RENDER_RESPONSE phase
 * It can be used to cache model value during single request-response event
 * and to accept multiple get() invocations with only single load() one
 * Is intended to be used in a managed bean, request- or view-scoped
 */
public abstract class LoadableDetachableModel<T> implements IDetachable {

	/**
	 * keeps track of whether this model is attached or detached
	 */
	private transient boolean attached = false;

	/**
	 * temporary, transient object.
	 */
	private transient T transientModelObject;

	public LoadableDetachableModel() {
		PhaseListenerSupport.registerDetachable(this);
	}

	/**
	 * This constructor is used if you already have the object retrieved and want to wrap it with a
	 * detachable model.
	 */
	public LoadableDetachableModel(T object) {
		this();
		this.transientModelObject = object;
		attached = true;
	}

	public void detach() {
		if (attached) {
			try {
				onDetach();
			} finally {
				attached = false;
				transientModelObject = null;
			}
		}
	}

	public final T getObject() {
		if (!attached) {
			attached = true;
			transientModelObject = load();
			onAttach();
		}
		return transientModelObject;
	}

	public final boolean isAttached() {
		return attached;
	}

	@Override
	public String toString() {
		return super.toString() + ":attached=" + attached + ":tempModelObject=[" + this.transientModelObject + "]";
	}

	/**
	 * Loads and returns the (temporary) model object.
	 */
	protected abstract T load();

	protected void onAttach() {
	}

	protected void onDetach() {
	}

	public void setObject(final T object) {
		attached = true;
		transientModelObject = object;
	}
}
