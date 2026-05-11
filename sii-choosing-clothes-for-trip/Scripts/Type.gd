class_name Type
## Тип одежды.
##
## [br][br][color=yellow]Author[/color] [url=Yaros-Lav]https://github.com/Yaros1113[/url] [color=green](YR Games)[/color]

## Ограничения на совместимость типов.
var compatible_types: Array[Type]
var name: StringName

func _init(n: StringName) -> void:
	name = n
