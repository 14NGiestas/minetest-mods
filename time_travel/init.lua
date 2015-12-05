-- GENERATED CODE
-- Node Box Editor, version 0.9.0
-- Namespace: test
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
--WORLD LINE - number of divergence
WORLD_LINE = minetest.get_worldpath().."/world_line.txt"
--Check if file exists else create
f = io.open(WORLD_LINE,"r")
if f == nil then
	f2 = io.open(WORLD_LINE,"w")
	f2:write(minetest.serialize(d))
	io.close(f2)
end
for line in io.lines(WORLD_LINE) do
	if line == nil then
		local file = io.open(WORLD_LINE,"w")
		file:write(minetest.serialize(d))
		file:close()
	end
	d = minetest.deserialize(line)
	break
end
--PHONE number by player_name/object_name/node_name

PHONE_BOOK = minetest.get_worldpath().."/timetravel_phones.txt"
--Check if file exists else create
f = io.open(PHONE_BOOK,"r")
rawset(_G, "PHN_DATA", {["singleplayer"] = 10000000})
if f == nil then
	f2 = io.open(PHONE_BOOK,"w")
	local phn_data = minetest.serialize(PHN_DATA)
	f2:write(phn_data)
	io.close(f2)
else
	f = io.open(PHONE_BOOK,"r")
	data = f:read("*all")
	if data then
		PHN_DATA = minetest.deserialize(data)
	end
	f:close()
end

--#  PHONE_MESSAGES - Txt database containing phone messages
PHONE_MESSAGES = minetest.get_worldpath().."/timetravel_messages.txt"
--### Check if file exists else create
f = io.open(PHONE_MESSAGES,"r")
rawset(_G, "MSG_DATA", {["10000000"] = {received = {{phone = 'Minetest',message = 'Hi,\n you don\'t have any message yet!',s = false,t = 0}},sent = {{phone = 'Minetest',message = 'Hi, you don\'t have sent messages!',s = false, t = 0}} }})
if f == nil then
	f2 = io.open(PHONE_MESSAGES,"w")
	local msg_data = minetest.serialize(MSG_DATA)
	f2:write(msg_data)
	f2:close()
else
	f = io.open(PHONE_MESSAGES,"r")
	data = f:read("*all")
	if data then
		MSG_DATA = minetest.deserialize(data)
	end
	f:close()
end

--CREATE NEW PHONES
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if not PHN_DATA[name] then
		PHN_DATA[name] = math.random(10000000,99999999)
	end

	local time = minetest.get_timeofday()

	if not MSG_DATA[PHN_DATA[name]] then
		MSG_DATA[PHN_DATA[name]] = {}
		MSG_DATA[PHN_DATA[name]] = {received = {{phone = 'Minetest',message = 'Hi,\n you don\'t have any message yet!',s = false,t = time}},sent = {{phone = 'Minetest',message = 'Hi, you don\'t have sent messages!',s = false,t = time}} }
	end
end)

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer >= 5 then -- Save every #minute
		local msg_data = minetest.serialize(MSG_DATA)
		local phn_data = minetest.serialize(PHN_DATA)
		local f1 = io.open(PHONE_MESSAGES,"w")
		f1:write(msg_data)
		f1:close()
		local f2 = io.open(PHONE_BOOK,"w")
		f2:write(phn_data)
		f2:close()
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
	file:write(minetest.serialize(d))
	if player:get_player_name() == nil then return end
	--Play sound and make something like Chrono Trigger travel
	--FIXME try reboot
	minetest.kick_player(player:get_player_name(),"Time Traveller, please log again!!!")
end

minetest.register_node("time_travel:div_meter", {
	description = "Divergence Meter",
	tiles = {
		"textop.png",
		"textop.png",
		"texfront.png", --right
		"texfront.png", --left
		"(texback.png^[combine:200x200:0,0=texback.png:1,50="..d.n_1..".png:16,50="..d.n_2..".png:31,50="..d.n_3..".png:46,50="..d.n_4..".png:61,50="..d.n_5..".png:76,50="..d.n_6..".png:91,50="..d.n_7..".png:106,50="..d.n_8..".png^texfront.png)^[transformFX", --back
		"texback.png^[combine:200x200:0,0=texback.png:1,50="..d.n_1..".png:16,50="..d.n_2..".png:31,50="..d.n_3..".png:46,50="..d.n_4..".png:61,50="..d.n_5..".png:76,50="..d.n_6..".png:91,50="..d.n_7..".png:106,50="..d.n_8..".png^texfront.png", --front
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
function show_apps(player)
	minetest.show_formspec(player:get_player_name(), "time_travel:phoneform",
		"size[10,10]" ..
		"background[0,0;10,10;timetravel_phone.png]"..
		"image_button[2,0.5;2,2;timetravel_phone_messages.png;messages;\n\n\n\nMessages]"..
		"image_button[4,0.5;2,2;timetravel_phone_calls.png;calls;\n\n\n\nCalls]"..
		"image_button[6,0.5;2,2;timetravel_phone_contacts.png;contacts;\n\n\n\nContacts]"..				
		"image_button[2,2.5;2,2;timetravel_phone_photoglry.png;1;\n\n\n\nPhotos]"..				
		"image_button[4,2.5;2,2;timetravel_phone_.png;2;\n\n\n\nVideos]"..				
		"image_button[6,2.5;2,2;timetravel_phone_.png;3;\n\n\n\nAlarm]"..				
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
--slice tables utility
function slice(tbl, first, last, step)
	local sliced = {}

	for i = first or 1, last or #tbl, step or 1 do
		sliced[#sliced+1] = tbl[i]
	end

	return sliced
end


function tablelength(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end
function show_msg(player,pgnum,phone,box,field)
	--*** TODO BEAUTYFY THIS ***
	if phone and box then
		local message_book = MSG_DATA[phone][box]
		num_pags = math.ceil(tablelength(message_book)/4)
		message_book  = slice(message_book, 1 + 4*(pgnum - 1), 4*(pgnum), 1)
		local message_text = message_book[field]
		local deco = ''
		if box == "sent" then
			deco = "To"
		elseif box == "received" then
			deco = "From"
		end
		local tel = minetest.formspec_escape(message_text.phone)
		local formspec = "size[10,10]"..
			"background[0,0;10,10;timetravel_phone.png]"..
			"textlist[2,1;5.8,7.4;;"..deco..": "..tel..","
		local msg = minetest.formspec_escape(message_text.message)
		for i = 1,#msg do
			if i % 37 == 0 then
				formspec = formspec..msg:sub(i,i)..","
			else
				formspec = formspec..msg:sub(i,i)
			end
		end
		formspec = formspec..";]image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
			"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
			"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
		minetest.show_formspec(player:get_player_name(), "time_travel:msg", formspec)
	end
end
function messages_menu(player)
	local formspec = "size[10,10]"..
		"background[0,0;10,10;timetravel_phone.png]"..
		"image_button[2,0.5;6,2;timetravel_sentbox.png;1;]"..
		"image_button[2,2.5;6,2;timetravel_rcvdbox.png;2;]"..
		"image_button[2,4.5;6,2;timetravel_new_msg.png;3;]"..
		"image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
	minetest.show_formspec(player:get_player_name(), "time_travel:messages_menu", formspec)
end
function show_compose_msg(player,number)
	local formspec = "size[10,10]"..
		"background[0,0;10,10;timetravel_phone.png]"..
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
	if phone and box then
		local message_book = MSG_DATA[phone][box]
		rawset(_G, "num_pags", math.ceil(tablelength(message_book)/4))
		message_book  = slice(message_book, 1 + 4*(pgnum - 1), 4*(pgnum), 1)
		local formspec = "size[10,10]"..
			"label[4.2,0.1;Pages "..pgnum.."/"..num_pags.."]"..
			"background[0,0;10,10;timetravel_phone.png]"
		local s_img = 'timetravel_read_msg.png'
		local i = 0.5 
		for j,line in ipairs(message_book) do
			if line.s == 1 then
				s_img = 'timetravel_unread_msg.png'
			elseif line.s == 0 then
				s_img = 'timetravel_read_msg.png'
			end
			local time_fmt = string.format("%.2d:%.2d:%.2d", line.t/(60*60), line.t / 60 % 60, line.t % 60)
			formspec = formspec.."image_button[2,"..i..";6,2;timetravel_button.png;"..j..";]"..
				"imagem[2.5,"..(i+0.2)..";10,10;"..s_img.."]"..
				"label[6.5,"..(i+0.5)..";"..time_fmt.."]"..
				"label[2.5,"..(i+0.5)..";"..line.phone.."]"..
				"label[3.5,"..(i+0.9)..";"..string.sub(line.message,1,20).."...]"..
				""
			i = i + 2
		end
		formspec = formspec.."image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
			"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
			"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
		minetest.show_formspec(player:get_player_name(), "time_travel:messages", formspec)
	else
		local formspec = "size[10,10]"..
			"background[0,0;10,10;timetravel_phone.png]"..
			"image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
			"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
			"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
		minetest.show_formspec(player:get_player_name(), "time_travel:messages", formspec)
	end
end
function show_calls(player)
	minetest.show_formspec(player:get_player_name(), "time_travel:calls",
		"size[10,10]" ..
		"background[0,0;10,10;timetravel_phone.png]"..
		"image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"..
		"")
end
function show_contacts(player)
	minetest.show_formspec(player:get_player_name(), "time_travel:contacts",
		"size[10,10]" ..
		"background[0,0;10,10;timetravel_phone.png]"..
		"image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"..
		"")
end
function show_bg(player)
	local time = minetest.get_timeofday() * 24000
	minetest.show_formspec(player:get_player_name(), "time_travel:bg",
		"size[10,10]" ..
		"background[0,0;10,10;timetravel_phone.png^]"..
		"image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"..
		"")
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
		--[[
		--print("Player "..player:get_player_name().." submitted fields "..dump(fields))
		--Play Sounds Hacking the gate
		minetest.rollback_revert_actions_by("player:"..player:get_player_name(), 5) -- hours*minutes*seconds
		]]
	end,
})
page = 1
box = "sent"
minetest.register_on_player_receive_fields(function(player, formname, fields)
	print(dump(fields))
	local phone = PHN_DATA[player:get_player_name()]
	if not player:get_wielded_item() == "time_travel:phone" then return end
	if formname == "time_travel:phoneform" then -- Replace this with your form name
		if fields.messages then
			--messages screen
			messages_menu(player)
		elseif fields.calls then
			show_calls(player)
		elseif fields.contacts then
			--contacts screen
			show_contacts(player)
		elseif fields.p then
			--just the background
			show_bg(player)
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
			show_messages(player,page,phone,box)
		end
		if fields.key_up then
			if page > 1 then
				page = page - 1
			else
				page = 1
			end
			show_messages(player,page,phone,box)
		end
		if fields["1"] then
			show_msg(player,page,phone,box,1)
		elseif fields["2"] then
			show_msg(player,page,phone,box,2)
		elseif fields["3"] then
			show_msg(player,page,phone,box,3)
		elseif fields["4"] then
			show_msg(player,page,phone,box,4)
		end
		if fields.o then
			messages_menu(player)
		elseif fields.p then
			--just the background
			show_bg(player)
		end
	elseif formname == "time_travel:calls" then
		if fields.o then
			show_apps(player)
		elseif fields.p then
			--just the background
			show_bg(player)
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
			show_messages(player,1,phone,box)
		end
	elseif formname == "time_travel:bg" then
		if fields.o then
			show_apps(player)
		end
	elseif formname == "time_travel:messages_menu" then
		if fields["1"] then
			box = "sent"
			show_messages(player,1,phone,box)
		elseif fields["2"] then
			box = "received"
			show_messages(player,1,phone,box)
		elseif fields["3"] then
			show_compose_msg(player,'')
		end
		if fields.o then
			show_apps(player)
		end
		if fields.p then
			show_bg(player)
		end
	elseif formname == "time_travel:messages_compose_menu" then
		if fields.o or fields.CANCEL then
			messages_menu(player)
		elseif fields.p then
			--just the background
			show_apps(player)
		elseif fields.OK then
			local to = fields["time_travel:dest_msg"]
			local body = fields["time_travel:body_msg"]
			if not to then return end
			if not body then return end
			--if number does not exists
			if not MSG_DATA[to] then
				MSG_DATA[to] = {received = {{phone = '',message = '',s = 0, t = 0}},sent = {{phone = '',message = '',s = 0, t = 0}} }
				print('I used this 1st')
			end
			--if number does not exists
			if not MSG_DATA[phone] then
				MSG_DATA[phone] = {received = {{phone = '',message = '',s = 0,t = 0}},sent = {{phone = '',message = '',s = 0, t = 0}} }
				print('I used this 2nd')
			end
			local time = minetest.get_timeofday()
			--send message to dest
			print(to,"received")
			table.insert(MSG_DATA[to]["received"], {["phone"] = phone,["message"] = body, ["s"] = 1, ["t"] = time})
			--save a copy
			print(phone,"sent")
			table.insert(MSG_DATA[phone]["sent"], {["phone"] = to,["message"] = body, ["s"] = 0, ["t"] = time})
			messages_menu(player)
		end
	end
		
end)
