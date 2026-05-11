extends Control
## Скрипт, управляющий всем интерфейсом и обрабатывающий
## все сигналы интерфейса.
##
## [br][br][color=yellow]Author[/color] [url=Yaros-Lav]https://github.com/Yaros1113[/url] [color=green](YR Games)[/color]

func _ready() -> void:
	var trip_cond := T.TripCond.new(T.Terrains.равнинная, T.WeatherPhenomena.ясно, 18, 3)
	var css: Array[ClothesSet] = ClothesSetGenerator.generate(trip_cond)
	print()
