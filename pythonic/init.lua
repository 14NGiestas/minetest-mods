local path = minetest.get_modpath("pythonic")
function speak(text)
	os.execute("python "..path.."/speaker.py   \'"..text.."\'")
	os.execute("python.exe "..path.."/speaker.py   \'"..text.."\'")
end
function talk_name_item(name)
	for _,player in ipairs(minetest.get_connected_players()) do
		if player:get_player_name() == name then
			--minetest.sound_play("pythonic_googletalk", {object = minetest.get_player_by_name(player:get_player_name()), gain = 1.0, max_hear_distance = 32, loop = false })
			speak(player:get_wielded_item():get_name())
		end
	end
end

minetest.register_chatcommand("say", {
	params = "<text>",
	description = "Hei you, say something!!!",
	privs = {shout = true},
	func = function( _ , text)
		speak(text)
	end,
})


minetest.register_on_chat_message(function(name, message)
	if message == "say_item" then
		talk_name_item(name)
	end
end)
