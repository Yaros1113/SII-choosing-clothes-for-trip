class_name ClothesSetGenerator
## Генератор наборов одежды.
##
## Сейчас используется реализация на массивах для демонстрации.
## В идеале переделать на словари для эффективного поиска!
##
## [br][br][color=yellow]Author[/color] [url=Yaros-Lav]https://github.com/Yaros1113[/url] [color=green](YR Games)[/color]

static var max_clothes_set_list_length: int = 5


static func generate(condition: T.TripCond) -> Array[ClothesSet]:
	var clothes_set_list: Array[ClothesSet]
	var cs: ClothesSet
	var i: int = -1
	var f: bool

	while (clothes_set_list.size() < max_clothes_set_list_length
			and i < DB.subtypes.size()):
		i += 1
		f = true
		cs = ClothesSet.new(condition)

		for j in range(i+1, DB.subtypes.size()):
			cs.try_append(DB.subtypes[j])
			cs.finalize_score()
			if cs.score > 5600:
				f = false
				break

		if f and not cs.elements.is_empty():
			clothes_set_list.append(cs)

	clothes_set_list.sort_custom(func(a:ClothesSet, b:ClothesSet)->bool:
		return a.score<b.score and a.elements.size()<=b.elements.size())
	print_rich(clothes_set_list)
	return clothes_set_list
