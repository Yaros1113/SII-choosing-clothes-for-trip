extends Node
## Имитация базы данных.
##
## [br][br][color=yellow]Author[/color] [url=Yaros-Lav]https://github.com/Yaros1113[/url] [color=green](YR Games)[/color]


var types: Array[Type]
var subtypes: Array[Subtype]


func _ready() -> void:
	add_type(&"Кепка")
	add_type(&"Футболка")
	add_type(&"Водолазка")
	add_type(&"Шорты")
	add_type(&"Джинсы")
	add_type(&"Носки")


	add_stype_tos(&"Кепка", &"Футболка")
	add_stype_tos(&"Кепка", &"Шорты")
	add_stype_tos(&"Кепка", &"Джинсы")
	add_stype_tos(&"Кепка", &"Носки")

	add_stype_tos(&"Футболка", &"Шорты")
	add_stype_tos(&"Футболка", &"Джинсы")
	add_stype_tos(&"Футболка", &"Носки")

	add_stype_tos(&"Водолазка", &"Джинсы")
	add_stype_tos(&"Водолазка", &"Носки")

	add_stype_tos(&"Джинсы", &"Носки")
	add_stype_tos(&"Шорты", &"Носки")


	set_subtype_condition(&"Летняя футболка", T.ACond.new([T.Terrains.равнинная, T.Terrains.лесистая], [T.WeatherPhenomena.ясно, T.WeatherPhenomena.облачно], 17, 35, 0, 8))
	set_subtype_type(&"Летняя футболка", &"Футболка")

	set_subtype_condition(&"Футболка с начёсом", T.ACond.new([T.Terrains.равнинная, T.Terrains.лесистая, T.Terrains.горная], [T.WeatherPhenomena.ясно, T.WeatherPhenomena.облачно, T.WeatherPhenomena.туман, T.WeatherPhenomena.дождь, T.WeatherPhenomena.снег], -10, 18, 0, 10))
	set_subtype_type(&"Футболка с начёсом", &"Футболка")

	set_subtype_condition(&"Обычная кепка", T.ACond.new([T.Terrains.равнинная, T.Terrains.лесистая, T.Terrains.горная], [T.WeatherPhenomena.ясно, T.WeatherPhenomena.облачно, T.WeatherPhenomena.туман], 10, 30, 0, 7.4))
	set_subtype_type(&"Обычная кепка", &"Кепка")

	set_subtype_condition(&"Водолазка обыкновенная", T.ACond.new([T.Terrains.равнинная, T.Terrains.лесистая, T.Terrains.горная], [T.WeatherPhenomena.ясно, T.WeatherPhenomena.облачно, T.WeatherPhenomena.туман, T.WeatherPhenomena.дождь, T.WeatherPhenomena.снег], -18, 20, 0.5, 11))
	set_subtype_type(&"Водолазка обыкновенная", &"Водолазка")

	set_subtype_condition(&"Шорты спортивные", T.ACond.new([T.Terrains.равнинная, T.Terrains.лесистая, T.Terrains.горная], [T.WeatherPhenomena.ясно, T.WeatherPhenomena.облачно, T.WeatherPhenomena.туман], 16, 35, 0, 8))
	set_subtype_type(&"Шорты спортивные", &"Шорты")

	set_subtype_condition(&"Джинсы чёрные с начёсом", T.ACond.new([T.Terrains.горная, T.Terrains.лесистая], [T.WeatherPhenomena.снег, T.WeatherPhenomena.облачно, T.WeatherPhenomena.туман], -20, 15, 0.5, 12))
	set_subtype_type(&"Джинсы чёрные с начёсом", &"Джинсы")

	set_subtype_condition(&"Термо носки", T.ACond.new([T.Terrains.равнинная, T.Terrains.лесистая], [T.WeatherPhenomena.дождь, T.WeatherPhenomena.облачно], -19.5, 18, 0, 15))
	set_subtype_type(&"Термо носки", &"Носки")




#region Функции добавления типов и совместиых типов:
func add_type(_name: StringName) -> void:
	if not arr_has_type(_name, types):
		types.append(Type.new(_name))

func arr_has_type(n: StringName, arr: Array[Type]) -> bool:
	for i in arr:
		if i.name == n:
			return true
	return false

func get_or_add_type(type_name: StringName) -> Type:
	for i in types:
		if i.name == type_name:
			return i
	var t := Type.new(type_name)
	types.append(t)
	return t

func add_type_to(t:Type, to: Type) -> void:
	if not arr_has_type(t.name, to.compatible_types):
		to.compatible_types.append(t)
	if not arr_has_type(to.name, t.compatible_types):
		t.compatible_types.append(to)

func add_stype_to(type:StringName, to: Type) -> void:
	var t: Type = get_or_add_type(type)
	add_type_to(t, to)

func add_stype_tos(type:StringName, tos: StringName) -> void:
	var to: Type = get_or_add_type(tos)
	add_stype_to(type, to)

#endregion

#region Функции добавления подтипов:
func add_subtype(_name: StringName) -> void:
	if not has_subtype(_name):
		subtypes.append(Subtype.new(_name))

func has_subtype(n: StringName) -> bool:
	for i in subtypes:
		if i.name == n:
			return true
	return false

func get_or_add_subtype(n: StringName) -> Subtype:
	for i in subtypes:
		if i.name == n:
			return i
	var sbtp := Subtype.new(n)
	subtypes.append(sbtp)
	return sbtp

func set_subtype_condition(sbtp_name: StringName, cond: T.ACond) -> void:
	var sbtp := get_or_add_subtype(sbtp_name)
	sbtp.acceptable_conditions = cond

func set_subtype_type(sbtp_name: StringName, _type: StringName) -> void:
	var sbtp := get_or_add_subtype(sbtp_name)
	sbtp.type = get_or_add_type(_type)

#endregion
