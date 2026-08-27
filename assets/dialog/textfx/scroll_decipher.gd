tool

extends RichTextEffect
class_name ScrollDecipher

var bbcode: String = "scroll"
var offsets: PoolVector2Array = []
var character: PoolIntArray = []

func _process_custom_fx(char_fx: CharFXTransform):
	var lift_height: int = char_fx.env.get("lift_height", 20)
	var text_color: Color = char_fx.env.get("text_color", Color.black)
	var glow_color: Color = char_fx.env.get("glow_color", Color.yellow)
	var lift_duration: float = char_fx.env.get("lift_duration", 1.0)
	var deglibberish_duration: float = char_fx.env.get("deglibberish_duration", 1.25)
	var deglibberish_character: float = char_fx.env.get("deglibberish_character", 0.5)
	if len(offsets) <= char_fx.relative_index:
		var column = randi() % 100 / 100.0 - 0.5
		var row = randi() % 100 / 100.0 - 0.5
		offsets.append(Vector2(-column * lift_height / 2, row * lift_height))
		character.append(randi() % 96 + 32)
	char_fx.color = text_color
	var time = char_fx.elapsed_time
	if time < lift_duration:
		char_fx.character = character[char_fx.relative_index]
		char_fx.offset = offsets[char_fx.relative_index]
		char_fx.offset.y -= lift_height * sin(PI * time / lift_duration / 2)
		return true
	if fmod(time, 0.025) < 0.01:
		character[char_fx.relative_index] = randi() % 96 + 32
	char_fx.offset.y = -lift_height
	time -= lift_duration
	if time < deglibberish_duration:
		var start_time = char_fx.relative_index * (deglibberish_duration - deglibberish_character) / len(offsets)
		var weight = sin(0.5 * PI * (time - start_time) / deglibberish_character)
		if time - start_time < deglibberish_character:
			if time > start_time:
				char_fx.offset += offsets[char_fx.relative_index].linear_interpolate(Vector2(0, 0), weight)
				char_fx.color = text_color.linear_interpolate(glow_color, weight)
			char_fx.character = character[char_fx.relative_index]
		else:
			char_fx.color = glow_color
		return true
	time -= deglibberish_duration
	var weight = cos(0.5 * PI * time) / 2.0 + 0.5
	char_fx.color = text_color.linear_interpolate(glow_color, weight)
	return true
