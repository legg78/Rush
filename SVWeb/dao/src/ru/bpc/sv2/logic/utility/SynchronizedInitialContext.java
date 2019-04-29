package ru.bpc.sv2.logic.utility;

import javax.naming.*;
import java.util.Hashtable;

final class SynchronizedInitialContext extends InitialContext {
	private final InitialContext target;

	public SynchronizedInitialContext(InitialContext target) throws NamingException {
		this.target = target;
	}

	@Override
	public Object lookup(String name) throws NamingException {
		synchronized (target) {
			return target.lookup(name);
		}
	}

	@Override
	public Object lookup(Name name) throws NamingException {
		synchronized (target) {
			return target.lookup(name);
		}
	}

	@Override
	public void bind(String name, Object obj) throws NamingException {
		synchronized (target) {
			target.bind(name, obj);
		}
	}

	@Override
	public void bind(Name name, Object obj) throws NamingException {
		synchronized (target) {
			target.bind(name, obj);
		}
	}

	@Override
	public void rebind(String name, Object obj) throws NamingException {
		synchronized (target) {
			target.rebind(name, obj);
		}
	}

	@Override
	public void rebind(Name name, Object obj) throws NamingException {
		synchronized (target) {
			target.rebind(name, obj);
		}
	}

	@Override
	public void unbind(String name) throws NamingException {
		synchronized (target) {
			target.unbind(name);
		}
	}

	@Override
	public void unbind(Name name) throws NamingException {
		synchronized (target) {
			target.unbind(name);
		}
	}

	@Override
	public void rename(String oldName, String newName) throws NamingException {
		synchronized (target) {
			target.rename(oldName, newName);
		}
	}

	@Override
	public void rename(Name oldName, Name newName) throws NamingException {
		synchronized (target) {
			target.rename(oldName, newName);
		}
	}

	@Override
	public NamingEnumeration<NameClassPair> list(String name) throws NamingException {
		synchronized (target) {
			return target.list(name);
		}
	}

	@Override
	public NamingEnumeration<NameClassPair> list(Name name) throws NamingException {
		synchronized (target) {
			return target.list(name);
		}
	}

	@Override
	public NamingEnumeration<Binding> listBindings(String name) throws NamingException {
		synchronized (target) {
			return target.listBindings(name);
		}
	}

	@Override
	public NamingEnumeration<Binding> listBindings(Name name) throws NamingException {
		synchronized (target) {
			return target.listBindings(name);
		}
	}

	@Override
	public void destroySubcontext(String name) throws NamingException {
		synchronized (target) {
			target.destroySubcontext(name);
		}
	}

	@Override
	public void destroySubcontext(Name name) throws NamingException {
		synchronized (target) {
			target.destroySubcontext(name);
		}
	}

	@Override
	public Context createSubcontext(String name) throws NamingException {
		synchronized (target) {
			return target.createSubcontext(name);
		}
	}

	@Override
	public Context createSubcontext(Name name) throws NamingException {
		synchronized (target) {
			return target.createSubcontext(name);
		}
	}

	@Override
	public Object lookupLink(String name) throws NamingException {
		synchronized (target) {
			return target.lookupLink(name);
		}
	}

	@Override
	public Object lookupLink(Name name) throws NamingException {
		synchronized (target) {
			return target.lookupLink(name);
		}
	}

	@Override
	public NameParser getNameParser(String name) throws NamingException {
		synchronized (target) {
			return target.getNameParser(name);
		}
	}

	@Override
	public NameParser getNameParser(Name name) throws NamingException {
		synchronized (target) {
			return target.getNameParser(name);
		}
	}

	@Override
	public String composeName(String name, String prefix) throws NamingException {
		synchronized (target) {
			return target.composeName(name, prefix);
		}
	}

	@Override
	public Name composeName(Name name, Name prefix) throws NamingException {
		synchronized (target) {
			return target.composeName(name, prefix);
		}
	}

	@Override
	public Object addToEnvironment(String propName, Object propVal) throws NamingException {
		synchronized (target) {
			return target.addToEnvironment(propName, propVal);
		}
	}

	@Override
	public Object removeFromEnvironment(String propName) throws NamingException {
		synchronized (target) {
			return target.removeFromEnvironment(propName);
		}
	}

	@Override
	public Hashtable<?, ?> getEnvironment() throws NamingException {
		synchronized (target) {
			return target.getEnvironment();
		}
	}

	@Override
	public void close() throws NamingException {
		synchronized (target) {
			target.close();
		}
	}

	@Override
	public String getNameInNamespace() throws NamingException {
		synchronized (target) {
			return target.getNameInNamespace();
		}
	}
}
