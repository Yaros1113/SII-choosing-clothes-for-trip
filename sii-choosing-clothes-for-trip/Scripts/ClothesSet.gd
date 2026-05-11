class_name ClothesSet
## Набор одежды.
##
## [br][br][color=yellow]Author[/color] [url=Yaros-Lav]https://github.com/Yaros1113[/url] [color=green](YR Games)[/color]

var condition: T.TripCond
var score: int
var elements: Array[Subtype]

func _init(cond: T.TripCond) -> void:
	condition = cond

func try_append(subtype: Subtype) -> bool:
	if not subtype.type or not subtype.acceptable_conditions:
		return false

	var s: int = T.get_score(condition, subtype.acceptable_conditions)
	if s > 800 or not is_acceptable(elements, subtype):
		return false
	elements.append(subtype)
	score += s
	return true


static func is_acceptable(e: Array[Subtype], s: Subtype) -> bool:
	for i in e:
		if not s.type in i.type.compatible_types:
			return false
	return true


func finalize_score()->void:
	if elements.size() > 1:
		score /= elements.size()



func _to_string() -> String:
	return "\nУсловие: "+str(condition)+"; score: "+str(score)+"; elements: \n "+str(elements)
