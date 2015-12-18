d = {
	n_1 = math.floor(math.random(0,1)),
	n_2 = "dot",
	n_3 = math.floor(math.random(0,9)),
	n_4 = math.floor(math.random(0,9)),
	n_5 = math.floor(math.random(0,9)),
	n_6 = math.floor(math.random(0,9)),
	n_7 = math.floor(math.random(0,9)),
	n_8 = math.floor(math.random(0,9))
}
d.n = d.n_1.."."..d.n_3..d.n_4..d.n_5..d.n_6..d.n_7..d.n_8
rawset(_G, "d", d)
--WORLD LINE - number of divergence
WORLD_LINE = minetest.get_worldpath().."/timetrave_metadata.txt"
--Check if file exists else create
f = io.open(WORLD_LINE,"r")
if f == nil then
	f2 = io.open(WORLD_LINE,"w")
	f2:write(minetest.compress(minetest.serialize(d)))
	io.close(f2)
else
	f = io.open(WORLD_LINE,"r")
	db = f:read("*all")
	if db then
		d = minetest.deserialize(minetest.decompress(db))
	end
	f:close()
end

--# DATABASE_FILE - Txt database containing whole data
DATABASE_FILE = minetest.get_worldpath().."/timetravel_phone_database.txt"
--### Check if file exists else create
f = io.open(DATABASE_FILE,"r")

rawset(_G, "DATABASE", {["singleplayer"] = {[10000000] = {received = {{phone = 'Minetest',message = 'Hi,\n you don\'t have any message yet!',s = false,t = minetest.get_timeofday(),d = minetest.get_gametime()}},sent = {{phone = 'Minetest',message = 'Hi, you don\'t have sent messages!',s = false, t = minetest.get_timeofday(),d = minetest.get_gametime()}}, contacts = {{name = "My Number",phone = 10000000}}, config = {sms_ringtone = 1, theme = 1,vibration = true,silent_mode = false,wallpaper = 1} }}})
if f == nil then
	f2 = io.open(DATABASE_FILE,"w")
	local db = minetest.compress(minetest.serialize(DATABASE))
	f2:write(db)
	f2:close()
else
	f = io.open(DATABASE_FILE,"r")
	db = f:read("*all")
	if db then
		DATABASE = minetest.deserialize(minetest.decompress(db))
	end
	f:close()
end


VIDEOGLRY_FILE = minetest.get_modpath("time_travel").."/timetravel_video_galery.txt"
VIDEOGLRY = {{src = "timetravel_video2.png",frames = 35},{src = "timetravel_video1.png",frames = 24},{src = "timetravel_video3.png",frames = 4},{src = "timetravel_static.png",frames = 24},{src = "timetravel_video4.png",frames = 12},{src = "timetravel_video1.png",frames = 24},{src = "timetravel_video2.png",frames = 35},{src = "timetravel_video1.png",frames = 24}}
--### Check if file exists else create
f = io.open(VIDEOGLRY_FILE,"r")
if f == nil then
	f2 = io.open(VIDEOGLRY_FILE,"w")
	local db = minetest.compress(minetest.serialize(VIDEOGLRY))
	f2:write(db)
	f2:close()
else
	f = io.open(VIDEOGLRY_FILE,"r")
	db = f:read("*all")
	if db then
		VIDEOGLRY = minetest.deserialize(minetest.decompress(db))
	end
	f:close()
end

--Phone Handler
PHHandler = {}
--CREATE NEW PHONES
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local time = minetest.get_timeofday()
	local phone_nb = math.random(10000000,99999999)
	if not DATABASE[name] then
		DATABASE[name] = {[phone_nb] = {received = {{phone = 'Minetest',message = 'Hi,\n you don\'t have any message yet!',s = false,t = time,["d"] = minetest.get_gametime()}},sent = {{phone = 'Minetest',message = 'Hi, you don\'t have sent messages!',s = false,t = time,["d"] = minetest.get_gametime()}}, contacts = {{name = "My Number",phone = phone_nb}}, config = {sms_ringtone = 1, theme = 1,vibration = true,silent_mode = false,wallpaper = 1} }}
	end
	--phone handler (not necessary store data on Hard Disc)
	PHHandler[name] = {}
	PHHandler[name]["frame"] = 1
	PHHandler[name]["playing"] = false
	PHHandler[name]["video"] = VIDEOGLRY[1]
	PHHandler[name]["page"] = 1
	PHHandler[name]["box"] = "received"
end)
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if PHHandler[name]["playing"] then
			PHHandler[name]["frame"] = PHHandler[name]["frame"] + 1
			if PHHandler[name]["frame"]  <= PHHandler[name]["video"].frames then
				show_video(player)
			else
				PHHandler[name]["playing"] = false
				show_video(player)
			end
		end
	end
	if timer >= 5 then -- Save every 5 sec
		local db = minetest.compress(minetest.serialize(DATABASE))
		local f1 = io.open(DATABASE_FILE,"w")
		f1:write(db)
		f1:close()
		timer = 0
	end
end)



function time_travel(player)
	d = {
		n_1 = math.floor(math.random(0,1)),
		n_2 = "dot",
		n_3 = math.floor(math.random(0,9)),
		n_4 = math.floor(math.random(0,9)),
		n_5 = math.floor(math.random(0,9)),
		n_6 = math.floor(math.random(0,9)),
		n_7 = math.floor(math.random(0,9)),
		n_8 = math.floor(math.random(0,9))
	}
	d.n = d.n_1.."."..d.n_3..d.n_4..d.n_5..d.n_6..d.n_7..d.n_8
	--save number on a world file
	local file = io.open(WORLD_LINE,"w")
	file:write(minetest.compress(minetest.serialize(d)))
	if player:get_player_name() == nil then return end
	--Play sound and make something like Chrono Trigger travel
	--FIXME try reboot
	minetest.kick_player(player:get_player_name(),"Time Traveller, please log again!!!")
end

minetest.register_node("time_travel:div_meter", {
	description = "Divergence Meter",
	tiles = {
		"timetravel_textop.png",
		"timetravel_textop.png",
		"timetravel_texfront.png", --right
		"timetravel_texfront.png", --left
		"(timetravel_texback.png^[combine:200x200:0,0=timetravel_texback.png:1,50=timetravel_"..d.n_1..".png:16,50=timetravel_"..d.n_2..".png:31,50=timetravel_"..d.n_3..".png:46,50=timetravel_"..d.n_4..".png:61,50=timetravel_"..d.n_5..".png:76,50=timetravel_"..d.n_6..".png:91,50=timetravel_"..d.n_7..".png:106,50=timetravel_"..d.n_8..".png^timetravel_texfront.png)^[transformFX", --back
		"timetravel_texback.png^[combine:200x200:0,0=timetravel_texback.png:1,50=timetravel_"..d.n_1..".png:16,50=timetravel_"..d.n_2..".png:31,50=timetravel_"..d.n_3..".png:46,50=timetravel_"..d.n_4..".png:61,50=timetravel_"..d.n_5..".png:76,50=timetravel_"..d.n_6..".png:91,50=timetravel_"..d.n_7..".png:106,50=timetravel_"..d.n_8..".png^timetravel_texfront.png", --front
	},
	diggable = true,
	drawtype = "nodebox",
	paramtype = "light",
	light_source = 10,
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1875, 0.5, -0.1875, 0.1875}, -- base
			{-0.5, -0.5, 0, 0.5, 0.1075, 0}, -- Nixie's tubes
		}
	},
	groups = {cracky=3, wood=1},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		time_travel(player)
	end,
})

--slice tables utility
function slice(tbl, first, last, step)
	local sliced = {}

	for i = first or 1, last or #tbl, step or 1 do
		sliced[#sliced+1] = tbl[i]
	end

	return sliced
end


function get_first_key(T)
	for key, value in pairs(T) do
		return key
	end
end
function show_apps(player)
	local phone = get_first_key(DATABASE[player:get_player_name()])
	local background = "timetravel_bg"..DATABASE[player:get_player_name()][phone]["config"]["wallpaper"]..".png"
	minetest.show_formspec(player:get_player_name(), "time_travel:phoneform",
		"size[10,10]" ..
		"background[0,0;10,10;timetravel_phone.png^"..background.."]"..
		"image_button[2,0.5;2,2;timetravel_phone_messages.png;messages;\n\n\n\nMessages]"..
		"image_button[4,0.5;2,2;timetravel_phone_calls.png;calls;\n\n\n\nCalls]"..
		"image_button[6,0.5;2,2;timetravel_phone_contacts.png;contacts;\n\n\n\nContacts]"..				
		"image_button[2,2.5;2,2;timetravel_phone_photoglry.png;1;\n\n\n\nPhotos]"..				
		"image_button[4,2.5;2,2;timetravel_phone_videos.png;videos;\n\n\n\nVideos]"..				
		"image_button[6,2.5;2,2;timetravel_phone_alarm.png;alarm;\n\n\n\nAlarm]"..			
		"image_button[2,4.5;2,2;timetravel_phone_.png;3;\n\n\n\nCalculator]"..
		"image_button[4,4.5;2,2;timetravel_phone_.png;3;\n\n\n\nCalendar]"..
		"image_button[6,4.5;2,2;timetravel_phone_.png;3;\n\n\n\nCamera]"..
		"image_button[2,6.5;2,2;timetravel_phone_.png;3;\n\n\n\n]"..
		"image_button[4,6.5;2,2;timetravel_phone_.png;3;\n\n\n\nCall]"..
		"image_button[6,6.5;2,2;timetravel_phone_.png;3;\n\n\n\nSettings]"..
		"image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]".. --close phone
		"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]".. --Apps Menu x close
		"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]".. --close all apps and show background
		"")
end
function show_msg(player,pgnum,phone,box,field)
	--*** TODO BEAUTYFY THIS ***
	if phone and box then
		local message_book = DATABASE[player:get_player_name()][phone][box]
		num_pags = math.ceil(#message_book/4)
		message_book  = slice(message_book, 1 + 4*(pgnum - 1), 4*(pgnum), 1)
		local message_text = message_book[field]
		local deco = ''
		if box == "sent" then
			deco = "To"
		elseif box == "received" then
			deco = "From"
		end
		local background = "timetravel_bg"..DATABASE[player:get_player_name()][phone]["config"].wallpaper..".png"
		local formspec = "size[10,10]"..
			"background[0,0;10,10;timetravel_phone.png^"..background.."]"
		if message_text then
			message_text.s = false
			local tel = minetest.formspec_escape(message_text.phone)
			formspec = formspec..
				"textlist[2,1;5.8,7.4;;"..deco..": "..tel..","
			local msg = minetest.formspec_escape(message_text.message)
			for i = 1,#msg do
				if i % 37 == 0 then
					formspec = formspec..msg:sub(i,i)..","
				else
					formspec = formspec..msg:sub(i,i)
				end
			end
		end
		formspec = formspec..";]image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
			"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
			"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
		minetest.show_formspec(player:get_player_name(), "time_travel:msg", formspec)
	end
end
function messages_menu(player,phone)
	local background = "timetravel_bg"..DATABASE[player:get_player_name()][phone]["config"].wallpaper..".png"
	local formspec = "size[10,10]"..
		"background[0,0;10,10;timetravel_phone.png^"..background.."]"..
		"image_button[2,0.5;6,2;timetravel_new_msg.png;3;]"..
		"image_button[2,2.5;6,2;timetravel_rcvdbox.png;2;]"..
		"image_button[2,4.5;6,2;timetravel_sentbox.png;1;]"..
		"image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
	minetest.show_formspec(player:get_player_name(), "time_travel:messages_menu", formspec)
end
function show_compose_msg(player,number,phone)
	local background = "timetravel_bg"..DATABASE[player:get_player_name()][phone]["config"].wallpaper..".png"
	local formspec = "size[10,10]"..
		"background[0,0;10,10;timetravel_phone.png^"..background.."]"..
		"field[2.3,0.8;6,1;time_travel:dest_msg;To:;"..number.."]"..
		"textarea[2.3,1.8;6,6.8;time_travel:body_msg;Message:;]"..		
		"image_button[2,7.7;3,0.9;timetravel_msg_canc.png;CANCEL;]"..
		"image_button[5,7.7;3,0.9;timetravel_msg_send.png;OK;]"..
		"image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
	minetest.show_formspec(player:get_player_name(), "time_travel:messages_compose_menu", formspec)
end

function show_messages(player,pgnum,phone,box)
	local background = "timetravel_bg"..DATABASE[player:get_player_name()][phone]["config"].wallpaper..".png"
	if phone and box then
		local message_book = DATABASE[player:get_player_name()][phone][box]
		print(dump(message_book))
		rawset(_G, "num_pags", math.ceil(#message_book/4))
		message_book  = slice(message_book, 1 + 4*(pgnum - 1), 4*(pgnum), 1)
		local formspec = "size[10,10]"..
			"label[4.2,0.1;Pages "..pgnum.."/"..num_pags.."]"..
			"background[0,0;10,10;timetravel_phone.png^"..background.."]"
		local i = 0.5
		local n
		local time_speed = minetest.setting_get("time_speed")
		for j,line in ipairs(message_book) do
			if line.s then
				n = 'yellow'
			else
				n = 'normal'
			end
			local date = os.date("%x", (os.time(os.date("*t")))/time_speed) --convert to local minetest time
			local time_fmt = string.format("%.2d:%.2d:%.2d", (line.t*86400)/(60*60), (line.t*86400) / 60 % 60, (line.t*86400) % 60)
			formspec = formspec.."image[2,"..i..";7.2,2.2;timetravel_button_"..n..".png]"..
				"label[5,"..(i+0.5)..";"..date..","..time_fmt.."]"..
				"label[2.5,"..(i+0.5)..";"..line.phone.."]"..
				"label[3.5,"..(i+0.9)..";"..string.sub(string.gsub(line.message, "\n", " "),1,20).."...]"..
				"image_button[2,"..i..";6,2;timetravel_tranparency.png;"..j..";;false;false;]"..
				"image_button[7,"..(i+1)..";0.6,0.6;timetravel_phone_delete.png;delete"..j..";;false;false;]"
			i = i + 2
		end
		formspec = formspec.."image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
			"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
			"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
		minetest.show_formspec(player:get_player_name(), "time_travel:messages", formspec)
	else
		local formspec = "size[10,10]"..
			"background[0,0;10,10;timetravel_phone.png^"..background.."]"..
			"image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
			"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
			"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
		minetest.show_formspec(player:get_player_name(), "time_travel:messages", formspec)
	end
end
function show_calls(player,phone)
	local background = "timetravel_bg"..DATABASE[player:get_player_name()][phone]["config"].wallpaper..".png"
	minetest.show_formspec(player:get_player_name(), "time_travel:calls",
		"size[10,10]" ..
		"background[0,0;10,10;timetravel_phone.png^"..background.."]"..
		"image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"..
		"")
end
function show_contacts(player,phone)
	local background = "timetravel_bg"..DATABASE[player:get_player_name()][phone]["config"].wallpaper..".png"
	minetest.show_formspec(player:get_player_name(), "time_travel:contacts",
		"size[10,10]" ..
		"background[0,0;10,10;timetravel_phone.png^"..background.."]"..
		"image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"..
		"")
end
function show_bg(player,phone)
	local time = minetest.get_timeofday()
	local time_fmt = string.format("%.2d:%.2d:%.2d", (time*86400)/(60*60), (time*86400) / 60 % 60, (time*86400) % 60)
	local background = "timetravel_bg"..DATABASE[player:get_player_name()][phone]["config"].wallpaper..".png"
	minetest.show_formspec(player:get_player_name(), "time_travel:bg",
		"size[10,10]" ..
		"background[0,0;10,10;timetravel_phone.png^"..background.."]"..
		"label[4.5,3.5;"..time_fmt.."]"..
		"image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"..
		"")
end
function video_galery(player,pgnum)
	local name = player:get_player_name()
	local formspec = "size[10,10]" ..
		"background[0,0;10,10;timetravel_phone.png;false]"..
		"label[4.2,0.1;Pages "..pgnum.."/"..math.ceil(#VIDEOGLRY/8).."]"
	local VIDEOGLRY_t  = slice(VIDEOGLRY, 1 + 8*(pgnum - 1), 8*(pgnum), 1)
	local i = 0.5
	local n = 2.2
	for j,line in ipairs(VIDEOGLRY_t) do
		formspec = formspec..
			"image["..n..","..i..";3,2;("..line.src.."^[verticalframe:"..line.frames..":1)]"..
			"image_button["..n..","..i..";3,2;timetravel_tranparency.png;"..j..";;false;false;]" --transparent
		n = n + 3
		if n == 8.2 then
			i = i + 2
			n = 2.2
		end
	end
	formspec = formspec.."image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
	minetest.show_formspec(name, "time_travel:video_galery", formspec)
end
function show_video(player)
	local name = player:get_player_name()
	local videosrc = PHHandler[name]["video"].src
	local t_frames = PHHandler[name]["video"].frames
	local frame = PHHandler[name]["frame"]
	if PHHandler[name]["playing"] then
		minetest.show_formspec(name, "time_travel:show_video",
			"size[10,10]" ..
			"background[0,0;10,10;timetravel_phone_90.png;false]"..
			"image[0.8,7.4;9.4,0.6;timetravel_video_bar.png]"..
			"image[0.3,2.5;"..(5*2)..","..(2.81*2)..";("..videosrc.."^[verticalframe:"..t_frames..":"..frame..")]".. --500 x 281
			"image[0.8,7.4;"..(9.4*(frame-1)/t_frames)..",0.6;timetravel_video_bar_BLUE.png]"..
			"image_button[0.3,7.4;0.7,0.7;timetravel_button_pause.png;pause;]"..
			"image_button_exit[8.7,3;0.6,0.6;timetravel_phone_X.png;x;]"..
			"image_button[8.7,4.5;0.6,0.6;timetravel_phone_O.png;o;]"..
			"image_button[8.7,6;0.6,0.6;timetravel_phone_P.png;p;]"..
			"")
	else
		PHHandler[name]["frame"] = 1
		minetest.show_formspec(name, "time_travel:show_video",
			"size[10,10]" ..
			"background[0,0;10,10;timetravel_phone_90.png;false]"..
			"image_button[3.5,4;2,2;timetravel_button_play.png;play;;false;false;]"..
			"image_button[0.3,7.4;0.7,0.7;timetravel_button_play.png;play;]"..
			"image[0.8,7.4;9.4,0.6;timetravel_video_bar.png]"..
			"image[0.8,7.4;"..(9.4*(frame-1)/t_frames)..",0.6;timetravel_video_bar_BLUE.png]"..
			"image[0.3,2.5;"..(5*2)..","..(2.81*2)..";("..videosrc.."^[verticalframe:"..t_frames..":1)]"..
			"image_button_exit[8.7,3;0.6,0.6;timetravel_phone_X.png;x;]"..
			"image_button[8.7,4.5;0.6,0.6;timetravel_phone_O.png;o;]"..
			"image_button[8.7,6;0.6,0.6;timetravel_phone_P.png;p;]"..
			"")
	end
end
minetest.register_craftitem("time_travel:phone", {
	description = "A common telephone",
	wield_image = "timetravel_phone.png",
	inventory_image = "timetravel_phone.png",
	visual = "sprite",
	physical = true,
	textures = {"timetravel_phone.png"},
	on_use = function(itemstack, user, pointed_thing)
		--help --> https://github.com/minetest/minetest/blob/master/doc/lua_api.txt#L1343
		show_apps(user)
		--Play Sounds Hacking the gate
		--minetest.rollback_revert_actions_by("player:"..player:get_player_name(), 5) -- hours*minutes*seconds
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	print(dump(fields))
	local player_name = player:get_player_name()
	local phone = get_first_key(DATABASE[player:get_player_name()])
	if not player:get_wielded_item() == "time_travel:phone" then return end
	local page = PHHandler[player_name]["page"]
	if formname == "time_travel:phoneform" then -- Replace this with your form name
		if fields.messages then
			--messages screen
			messages_menu(player,phone)
		elseif fields.videos then
			--show_video(player,PHHandler[player_name]["video"].src)
			video_galery(player,page)
		elseif fields.calls then
			show_calls(player,phone)
		elseif fields.contacts then
			--contacts screen
			show_contacts(player,phone)
		elseif fields.p then
			--just the background
			show_bg(player,phone)
		elseif fields.o then
			show_apps(player)
		end
	elseif formname == "time_travel:messages" then
		if fields.key_down then
			if page < num_pags then
				page = page + 1
			else
				page = num_pags
			end
			show_messages(player,page,phone,PHHandler[player_name]["box"])
		end
		if fields.key_up then
			if page > 1 then
				page = page - 1
			else
				page = 1
			end
			show_messages(player,page,phone,PHHandler[player_name]["box"])
		end
		if fields["delete1"] then
			DATABASE[player_name][phone][PHHandler[player_name]["box"]][(page-1)*4+1] = nil
			show_messages(player,page,phone,PHHandler[player_name]["box"])
		elseif fields["delete2"] then
			DATABASE[player_name][phone][PHHandler[player_name]["box"]][(page-1)*4+2] = nil
			show_messages(player,page,phone,PHHandler[player_name]["box"])
		elseif fields["delete3"] then
			DATABASE[player_name][phone][PHHandler[player_name]["box"]][(page-1)*4+3] = nil
			show_messages(player,page,phone,PHHandler[player_name]["box"])
		elseif fields["delete4"] then
			DATABASE[player_name][phone][PHHandler[player_name]["box"]][(page-1)*4+4] = nil
			show_messages(player,page,phone,PHHandler[player_name]["box"])
		end
		if fields["1"] then
			show_msg(player,page,phone,PHHandler[player_name]["box"],1)
		elseif fields["2"] then
			show_msg(player,page,phone,PHHandler[player_name]["box"],2)
		elseif fields["3"] then
			show_msg(player,page,phone,PHHandler[player_name]["box"],3)
		elseif fields["4"] then
			show_msg(player,page,phone,PHHandler[player_name]["box"],4)
		end
		if fields.o then
			messages_menu(player,phone)
		elseif fields.p then
			--just the background
			show_bg(player)
		end
	elseif formname == "time_travel:calls" then
		if fields.o then
			show_apps(player)
		elseif fields.p then
			--just the background
			show_bg(player,phone)
		end
	elseif formname == "time_travel:contacts" then
		if fields.o then
			show_apps(player)
		elseif fields.p then
			--just the background
			show_apps(player)
		end
	elseif formname == "time_travel:msg" then
		if fields.p then
			--just the background
			show_apps(player)
		elseif fields.o then
			show_messages(player,1,phone,PHHandler[player_name]["box"])
		end
	elseif formname == "time_travel:bg" then
		if fields.o then
			show_apps(player)
		end
	elseif formname == "time_travel:messages_menu" then
		if fields["1"] then
			PHHandler[player_name]["box"] = "sent"
			show_messages(player,1,phone,PHHandler[player_name]["box"])
		elseif fields["2"] then
			PHHandler[player_name]["box"] = "received"
			show_messages(player,1,phone,PHHandler[player_name]["box"])
		elseif fields["3"] then
			show_compose_msg(player,'',phone)
		end
		if fields.o then
			show_apps(player)
		end
		if fields.p then
			show_bg(player,phone)
		end
	elseif formname == "time_travel:video_galery" then
		if fields.o then
			show_apps(player)
		end
		if fields.p then
			show_bg(player,phone)
		end
		if fields["1"] then
			PHHandler[player_name]["video"] = VIDEOGLRY[(page-1)*8+1]
			show_video(player)
		elseif fields["2"] then
			PHHandler[player_name]["video"] = VIDEOGLRY[(page-1)*8+2]
			show_video(player)
		elseif fields["3"] then
			PHHandler[player_name]["video"] = VIDEOGLRY[(page-1)*8+3]
			show_video(player)
		elseif fields["4"] then
			PHHandler[player_name]["video"] = VIDEOGLRY[(page-1)*8+4]
			show_video(player)
		elseif fields["5"] then
			PHHandler[player_name]["video"] = VIDEOGLRY[(page-1)*8+5]
			show_video(player)
		elseif fields["6"] then
			PHHandler[player_name]["video"] = VIDEOGLRY[(page-1)*8+6]
			show_video(player)
		elseif fields["7"] then
			PHHandler[player_name]["video"] = VIDEOGLRY[(page-1)*8+7]
			show_video(player)
		elseif fields["8"] then
			PHHandler[player_name]["video"] = VIDEOGLRY[(page-1)*8+8]
			show_video(player)
		end
	elseif formname == "time_travel:show_video" then
		if fields.quit then
			PHHandler[player_name]["playing"] = false
		elseif fields.o then
			PHHandler[player_name]["playing"] = false
			video_galery(player,page)
		elseif fields.p then
			PHHandler[player_name]["playing"] = false
			show_bg(player,phone)
		elseif fields.pause then
			PHHandler[player_name]["playing"] = not PHHandler[player_name]["playing"]
		elseif fields.play then
			PHHandler[player_name]["playing"] = not PHHandler[player_name]["playing"]
			show_video(player)
		end
	elseif formname == "time_travel:messages_compose_menu" then
		if fields.o or fields.CANCEL then
			messages_menu(player,phone)
		elseif fields.p then
			--just the background
			show_apps(player)
		elseif fields.OK then
			local to = fields["time_travel:dest_msg"]
			local body = fields["time_travel:body_msg"]
			if not to then return end
			if not body then return end
			local dest_player_name = to
			if type(to) == "string" then -- a name
				for key, value in pairs(DATABASE[to] or {}) do
					--get the first one
					to = key
					break
				end
			elseif type(to) == "number" then
				for key, value in pairs(DATABASE or {}) do
					for key2, value in value do
						if key2 == to then
							local dest_player_name = key
							break
						end
					end
				end
			end
			local time = minetest.get_timeofday()
			local function send() --send message to dest
				table.insert(DATABASE[dest_player_name][to]["received"],1, {["phone"] = phone,["message"] = body, ["s"] = true, ["t"] = time,["d"] = minetest.get_gametime()})
			end
			local function sv_copy()--save a copy
				table.insert(DATABASE[player_name][phone]["sent"],1, {["phone"] = to,["message"] = body, ["s"] = false, ["t"] = time,["d"] = minetest.get_gametime()})
			end
			--TRY EXCEPT Lua version
			if not pcall(send) then
				--Error probably only when user or phone not exists
				table.insert(DATABASE[player_name][phone]["received"],1, {["phone"] = 'Minetest',["message"] = "Message not sent, reason: player or number incorrect.", ["s"] = true, ["t"] = time,["d"] = minetest.get_gametime()})
			else
				local tone = DATABASE[player_name][phone]["config"]["sms_ringtone"]
				local vibration = DATABASE[player_name][phone]["config"]["vibration"]
				if vibration then
					minetest.sound_play("timetravel_vibration", {
						to_player = dest_player_name,
						gain = 1.5,
					})
				end
				minetest.sound_play("timetravel_sms_tone"..tone, {
					to_player = dest_player_name,
					gain = 1.5,
				})
			end
			if not pcall(sv_copy) then
				print("strange error!!!")
			end
			messages_menu(player,phone)
		end
	end
		
end)
