class_name Subtype
## Подтип одежды.
##
## [br][br][color=yellow]Author[/color] [url=Yaros-Lav]https://github.com/Yaros1113[/url] [color=green](YR Games)[/color]

## Допустимые условия для подтипа.
var acceptable_conditions: T.ACond
## Тип для подтипа.
var type: Type
var name: StringName

## Название подтипа устанавливается через конструктор.
func _init(n: StringName) -> void:
	name = n


func _to_string() -> String:
	return " name: "+name+"; type: "+type.name+"\n"
