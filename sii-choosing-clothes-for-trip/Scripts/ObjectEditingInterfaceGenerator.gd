class_name OEIG #ObjectEditingInterfaceGenerator

var is_selected = false
var inspector_root: Control = null
var inspector_canvas: CanvasLayer = null


## [param target] - для кого интерфейс генерировать.
## [param to_parent] - под кого вешать интерфейс.
func toggle_selection(target: Object, to_parent: Node):
	is_selected = not is_selected
	if is_selected:
		print('TIKNFUFDW')
		inspector_root = create_property_editor(target)
		inspector_root.custom_minimum_size = Vector2(400, 600)
		inspector_root.size = Vector2(400, 600)
		inspector_canvas = CanvasLayer.new()
		to_parent.add_child(inspector_canvas)
		inspector_canvas.add_child(inspector_root)
	else:
		close_editor()

func close_editor():
	if inspector_canvas:
		inspector_canvas.queue_free()
		inspector_canvas = null
		inspector_root = null

static func create_property_editor(target_object: Object) -> Control:
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	
	var header := HBoxContainer.new()
	var title := Label.new()
	title.text = "Редактор свойств: " + target_object.get_class()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var close_btn := Button.new()
	close_btn.text = "✕ Закрыть"
	close_btn.modulate = Color(0.8, 0.2, 0.2)
	close_btn.pressed.connect(_close_editor.bind(root))
	header.add_child(title)
	header.add_child(close_btn)
	root.add_child(header)
	
	var sep := HSeparator.new()
	root.add_child(sep)
	
	var container := VBoxContainer.new()
	container.add_theme_constant_override("separation", 4)
	
	var property_list: Array[Dictionary] = target_object.get_property_list()
	
	for prop in property_list:
		if (prop.usage & PROPERTY_USAGE_EDITOR) or prop.type==0:
			continue
		if prop.name.begins_with("_") and not (prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue
		if prop.usage & PROPERTY_USAGE_READ_ONLY:
			continue
		if prop.name in ["resource","ref_counted","resource",
				"resource_local_to_scene",
				"locus_registry",
				"metadata/_custom_type_script",
				"unique_name_in_owner",
				"editor_description",
				"visibility_parent",
				"auto_translate_mode",
				"resource_scene_unique_id",
				"collision_priority",
				"scale",
				"process_thread_messages",
				"process_thread_group_order",
				"process_thread_group",
				"process_physics_priority",
				"process_priority",
				"input_ray_pickable",
				"input_capture_on_drag",
				"slide_on_ceiling",
				"safe_margin",
				"physics_interpolation_mode",
				"source_code", #???
				"script/source",
				]:
			continue
		
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var label := Label.new()
		label.text = prop.name.capitalize()
		label.size_flags_horizontal = Control.SIZE_EXPAND
		label.custom_minimum_size.x = 120
		row.add_child(label)
		
		var editor: Control = _create_editor_for_property(target_object, prop)
		if not editor:
			var current_value = target_object.get(prop.name)
			var value_label := Label.new()
			value_label.text = str(current_value) if current_value != null else "null"
			value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(value_label)
		else:
			continue
		
		container.add_child(row)
		var line := HSeparator.new()
		line.modulate = Color(0.5, 0.5, 0.5, 0.3)
		container.add_child(line)
	
	var scroll := ScrollContainer.new()
	scroll.add_child(container)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var panel := PanelContainer.new()
	panel.add_child(scroll)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	root.add_child(panel)
	return root

static func _close_editor(root_control: Control):
	var node: Node = root_control
	while node and not (node is CanvasLayer):
		node = node.get_parent()
	if node and node is CanvasLayer:
		node.queue_free()

static func _create_editor_for_property(target: Object, prop: Dictionary) -> Control:
	var prop_name = prop.name
	var prop_type = prop.type
	var prop_hint = prop.hint
	var prop_hint_string = prop.hint_string
	
	match prop_type:
		TYPE_BOOL:
			var check := CheckBox.new()
			check.button_pressed = target.get(prop_name)
			check.toggled.connect(func(pressed: bool): target.set(prop_name, pressed))
			return check
		
		TYPE_INT:
			var spin := SpinBox.new()
			spin.value = target.get(prop_name)
			spin.value_changed.connect(func(value: float): target.set(prop_name, int(value)))
			_apply_int_hint(spin, prop_hint, prop_hint_string)
			return spin
		
		TYPE_FLOAT:
			var spin := SpinBox.new()
			spin.value = target.get(prop_name)
			spin.value_changed.connect(func(value: float): target.set(prop_name, value))
			_apply_float_hint(spin, prop_hint, prop_hint_string)
			return spin
		
		TYPE_STRING:
			var line_edit := LineEdit.new()
			line_edit.text = target.get(prop_name)
			line_edit.text_changed.connect(func(new_text: String): target.set(prop_name, new_text))
			return line_edit
		
		TYPE_VECTOR2:
			return _create_vector2_editor(target, prop_name)
		
		TYPE_VECTOR3:
			return _create_vector3_editor(target, prop_name)
		
		TYPE_COLOR:
			var color_button := ColorPickerButton.new()
			color_button.color = target.get(prop_name)
			color_button.color_changed.connect(func(new_color: Color): target.set(prop_name, new_color))
			return color_button
		
		TYPE_ARRAY:
			return _create_array_editor(target, prop_name)
		
		TYPE_OBJECT:
			var resource = target.get(prop_name)
			if resource == null:
				var null_label := Label.new()
				null_label.text = "[null]"
				null_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
				return null_label
			
			var open_btn := Button.new()
			var type_name = resource.get_class()
			if resource.resource_path.is_empty():
				open_btn.text = "Редактировать вложенные " + type_name
			else:
				open_btn.text = "Изменить " + type_name + " ресурс"
			open_btn.pressed.connect(_open_nested_editor.bind(resource))
			return open_btn
		
		_:
			return null

# ----- ARRAY EDITOR WITH PROPER SCOPE HANDLING -----
static func _create_array_editor(target: Object, prop_name: String) -> Control:
	var array: Array = target.get(prop_name)
	
	var main_container := VBoxContainer.new()
	
	var header := HBoxContainer.new()
	var array_label := Label.new()
	array_label.text = "Массив (размер: %d)" % array.size()
	array_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var add_btn := Button.new()
	add_btn.text = "+ Добавить"
	add_btn.pressed.connect(_add_array_element.bind(target, prop_name, main_container))
	header.add_child(array_label)
	header.add_child(add_btn)
	main_container.add_child(header)
	
	var elements_container := VBoxContainer.new()
	elements_container.name = "ElementsContainer"
	main_container.add_child(elements_container)
	
	# Create the refresh callable
	var refresh_func = func():
		# Clear old elements
		for child in elements_container.get_children():
			child.queue_free()
		# Get fresh array
		var current_array: Array = target.get(prop_name)
		array_label.text = "Массив (размер: %d)" % current_array.size()
		# Rebuild rows
		for idx in current_array.size():
			var elem = current_array[idx]
			var elem_row := HBoxContainer.new()
			elem_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var idx_label := Label.new()
			idx_label.text = "[%d]" % idx
			idx_label.custom_minimum_size.x = 40
			elem_row.add_child(idx_label)
			
			var elem_control: Control = _create_element_editor(elem)
			elem_control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			elem_row.add_child(elem_control)
			
			var remove_btn := Button.new()
			remove_btn.text = "X"
			remove_btn.modulate = Color(0.8, 0.2, 0.2)
			remove_btn.pressed.connect(_remove_array_element.bind(target, prop_name, idx, main_container))
			elem_row.add_child(remove_btn)
			
			elements_container.add_child(elem_row)
	
	# Store the refresh function in the container's metadata
	main_container.set_meta("refresh", refresh_func)
	# Initial build
	refresh_func.call()
	
	return main_container

static func _add_array_element(target: Object, prop_name: String, main_container: Control):
	var array: Array = target.get(prop_name)
	array.append(null)
	target.set(prop_name, array)
	if main_container.has_meta("refresh"):
		var refresh: Callable = main_container.get_meta("refresh")
		refresh.call()

static func _remove_array_element(target: Object, prop_name: String, idx: int, main_container: Control):
	var array: Array = target.get(prop_name)
	if idx >= 0 and idx < array.size():
		array.remove_at(idx)
		target.set(prop_name, array)
	if main_container.has_meta("refresh"):
		var refresh: Callable = main_container.get_meta("refresh")
		refresh.call()

static func _create_element_editor(value) -> Control:
	if value is Resource:
		var btn := Button.new()
		var type_name = value.get_class()
		if value.resource_path.is_empty():
			btn.text = "Редактировать вложенные %s" % type_name
		else:
			btn.text = "Редактировать %s" % type_name
		btn.pressed.connect(_open_nested_editor.bind(value))
		return btn
	elif value is Object:
		var label := Label.new()
		label.text = "[Объект: %s]" % value.get_class()
		return label
	else:
		var label := Label.new()
		label.text = str(value) if value != null else "null"
		return label

# ----- NESTED RESOURCE EDITOR (WINDOW) -----
static func _open_nested_editor(resource: Resource):
	var editor = create_property_editor(resource)
	editor.custom_minimum_size = Vector2(400, 500)
	
	var window := Window.new()
	window.title = "Resource Editor: " + resource.get_class()
	window.size = Vector2(420, 540)
	window.min_size = Vector2(300, 400)
	window.exclusive = false
	window.transient = true
	window.unresizable = false
	window.wrap_controls = true
	window.add_child(editor)
	
	if Engine.get_main_loop() and Engine.get_main_loop().current_scene:
		Engine.get_main_loop().current_scene.add_child(window)
	else:
		Engine.get_main_loop().root.add_child(window)
	
	window.popup_centered()
	window.close_requested.connect(window.queue_free)

# ----- VECTOR / HINT HELPERS (unchanged) -----
static func _apply_int_hint(spin: SpinBox, hint: PropertyHint, hint_string: String):
	match hint:
		PROPERTY_HINT_RANGE:
			var parts = hint_string.split(",")
			spin.min_value = float(parts[0])
			spin.max_value = float(parts[1])
			if parts.size() >= 3:
				var step = float(parts[2])
				spin.step = step
		_:
			pass

static func _apply_float_hint(spin: SpinBox, hint: PropertyHint, hint_string: String) -> void:
	match hint:
		PROPERTY_HINT_RANGE:
			var parts = hint_string.split(",")
			spin.min_value = float(parts[0])
			spin.max_value = float(parts[1])
			if parts.size() >= 3:
				var step = float(parts[2])
				spin.step = step
		_:
			pass

static func _create_vector2_editor(target: Object, prop_name: String) -> Control:
	var container := HBoxContainer.new()
	var vec_value: Vector2 = target.get(prop_name)
	
	var x_spin := SpinBox.new()
	x_spin.value = vec_value.x
	x_spin.prefix = "X: "
	x_spin.value_changed.connect(func(x: float): 
		target.set(prop_name, Vector2(x, target.get(prop_name).y))
	)
	
	var y_spin := SpinBox.new()
	y_spin.value = vec_value.y
	y_spin.prefix = "Y: "
	y_spin.value_changed.connect(func(y: float): 
		target.set(prop_name, Vector2(target.get(prop_name).x, y))
	)
	
	container.add_child(x_spin)
	container.add_child(y_spin)
	return container

static func _create_vector3_editor(target: Object, prop_name: String) -> Control:
	var container := HBoxContainer.new()
	var vec_value: Vector3 = target.get(prop_name)
	
	var x_spin := SpinBox.new()
	x_spin.value = vec_value.x
	x_spin.prefix = "X: "
	x_spin.value_changed.connect(func(x: float): 
		target.set(prop_name, Vector3(x, target.get(prop_name).y, target.get(prop_name).z))
	)
	
	var y_spin := SpinBox.new()
	y_spin.value = vec_value.y
	y_spin.prefix = "Y: "
	y_spin.value_changed.connect(func(y: float): 
		target.set(prop_name, Vector3(target.get(prop_name).x, y, target.get(prop_name).z))
	)
	
	var z_spin := SpinBox.new()
	z_spin.value = vec_value.z
	z_spin.prefix = "Z: "
	z_spin.value_changed.connect(func(z: float): 
		target.set(prop_name, Vector3(target.get(prop_name).x, target.get(prop_name).y, z))
	)
	
	container.add_child(x_spin)
	container.add_child(y_spin)
	container.add_child(z_spin)
	return container
