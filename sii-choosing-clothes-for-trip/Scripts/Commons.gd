class_name T
## Класс вспомогательных терминов (типов данных) и вспомогательных функций.
##
## [br][br][color=yellow]Author[/color] [url=Yaros-Lav]https://github.com/Yaros1113[/url] [color=green](YR Games)[/color]

enum Terrains {
	равнинная,
	горная,
	лесистая
}

enum WeatherPhenomena {
	ясно, облачно, туман, дождь, снег
}

static var temp: Vector2i = Vector2i(-75, 56)
static var wind: Vector2i = Vector2i(0, 30)


## Допустимые условия.
class ACond:
	var terrains: Array[Terrains]
	var weather_phenoms: Array[WeatherPhenomena]
	var min_temperature: float
	var max_temperature: float
	var min_windy: float
	var max_windy: float

	var avr_temp: float
	var avr_wind: float

	func _init(terra:Array[Terrains]=[], 
			weat_phen:Array[WeatherPhenomena]=[],
			min_temp:float=0, max_temp: float=0,
			min_wind: float=0, max_wind: float=0,
			) -> void:
		terrains.append_array(terra)
		terrains.make_read_only()
		weather_phenoms.append_array(weat_phen)
		weather_phenoms.make_read_only()
		min_temperature = clampf(min_temp, T.temp.x, T.temp.y)
		max_temperature = clampf(max_temp, T.temp.x, T.temp.y)
		avr_temp = (max_temperature+min_temperature)*0.5
		min_windy = clampf(min_wind, T.wind.x, T.wind.y)
		max_windy = clampf(max_wind, T.wind.x, T.wind.y)
		avr_wind = (max_windy+min_windy)*0.5

	## Соответствие допустимых условий условиям похода.
	func matches(tc: TripCond) -> bool:
		if (tc.terrain in terrains
				and tc.weather_phenom in weather_phenoms
				and tc.temperature <= max_temperature
				and tc.temperature >= min_temperature
				and tc.windy <= max_windy and tc.windy >= min_windy
				):
			return true
		return false


## Условия похода.
class TripCond:
	var terrain: Terrains
	var weather_phenom: WeatherPhenomena
	var temperature: float
	var windy: float

	func _init(terra:Terrains=Terrains.равнинная, 
			weat_phen:WeatherPhenomena=WeatherPhenomena.ясно,
			temp:float=0,
			wind: float=0
			) -> void:
		terrain=terra
		weather_phenom=weat_phen
		temperature = clampf(temp, T.temp.x, T.temp.y)
		windy = clampf(wind, T.wind.x, T.wind.y)


## Возвращает числовую степень соответствия условий похода допустимым условиям.
static func get_score(tc: TripCond, ac: ACond) -> int:
	var score: int = 0

	if not tc.terrain in ac.terrains:
		score += 1000

	if not tc.weather_phenom in ac.weather_phenoms:
		score += 1000

	if (tc.temperature >= ac.max_temperature
			or tc.temperature <= ac.min_temperature
			):
		score += abs(tc.temperature - ac.avr_temp)*10
	else:
		score += abs(tc.temperature - ac.avr_temp)

	if tc.windy >= ac.max_windy or tc.windy <= ac.min_windy:
		score += abs(tc.windy - ac.avr_wind)*10
	else:
		score += abs(tc.windy - ac.avr_wind)

	return score
