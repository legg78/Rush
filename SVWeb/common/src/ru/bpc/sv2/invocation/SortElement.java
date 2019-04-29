package ru.bpc.sv2.invocation;

import java.io.Serializable;

public class SortElement implements Serializable {
	private static final long serialVersionUID = 4124264540940780021L;
	private static final String DIRECTION_ASC = "ASC";
	private static final String DIRECTION_DESC = "DESC";
	private static final String DIRECTION_AUTO = "AUTO";

	public enum Direction {
		ASC, DESC, AUTO
	}

	private String _property;
	private final Direction _direction;
	private String condition;

	public SortElement() {
		_direction = Direction.ASC;
	}

	public SortElement(String property, Direction direction) {
		setProperty(property);
		_direction = direction;
	}

	public SortElement(String property, String direction) {
		setProperty(property);
		if (direction != null && !direction.trim().isEmpty()) {
			if (DIRECTION_ASC.equalsIgnoreCase(direction.trim())) {
				_direction = Direction.ASC;
			} else if (DIRECTION_DESC.equalsIgnoreCase(direction.trim())) {
				_direction = Direction.DESC;
			} else {
				_direction = Direction.AUTO;
			}
		} else {
			_direction = Direction.AUTO;
		}
	}

	public SortElement(String property) {
		setProperty(property);
		_direction = Direction.AUTO;
	}

	private void setProperty(String property) {
		for (int i = 0; i < property.length(); i++) {
			char ch = property.charAt(i);
			if (!Character.isLetterOrDigit(ch) && ch != '_' && ch != '.') {
				throw new IllegalArgumentException("Property name can contain only letters/digits, points and underscores");
			}
		}

		_property = property;
	}

	public String getProperty() {
		return _property;
	}

	public Direction getDirection() {
		return _direction;
	}

	public String getCondition() {
		return condition;
	}

	public void setCondition(String condition) {
		this.condition = condition;
	}

	@SuppressWarnings("RedundantIfStatement")
	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if (o == null || getClass() != o.getClass()) return false;

		SortElement that = (SortElement) o;
		if (_direction != that._direction) return false;
		if (_property != null ? !_property.equals(that._property) : that._property != null) return false;
		if (condition != null ? !condition.equals(that.condition) : that.condition != null) return false;
		return true;
	}

	@Override
	public int hashCode() {
		int result = _property != null ? _property.hashCode() : 0;
		result = 31 * result + (_direction != null ? _direction.hashCode() : 0);
		result = 31 * result + (condition != null ? condition.hashCode() : 0);
		return result;
	}
}
