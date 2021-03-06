--                       --
-- A Little Optimization --
--                       --
local compress                = minetest.compress
local serialize               = minetest.serialize
local get_worldpath           = minetest.get_worldpath
local decompress              = minetest.decompress
local deserialize             = minetest.deserialize
local register_globalstep     = minetest.register_globalstep
local minetest_after          = minetest.after
local minetest_register_node  = minetest.register_node
local floor                   = math.floor
local ceil                    = math.ceil
local random                  = math.random
local get_timeofday           = minetest.get_timeofday
local get_gametime            = minetest.get_gametime
local show_form               = minetest.show_formspec
local m_play                  = minetest.sound_play
local m_stop                  = minetest.sound_stop
local m_on_joinplayer         = minetest.register_on_joinplayer
local m_on_newplayer          = minetest.register_on_newplayer
local get_connected_players   = minetest.get_connected_players
local kick_player             = minetest.kick_player
local form_escape             = minetest.formspec_escape
local setting_get             = minetest.setting_get
local revert_actions_by       = minetest.rollback_revert_actions_by
local register_craftitem      = minetest.register_craftitem
local p_rcv_fields            = minetest.register_on_player_receive_fields
local t_insert                = table.insert
local char                    = string.char
local setting_get             = minetest.setting_get
local setting_set             = minetest.setting_set
local find_node               = minetest.find_node_near

---------------
-- Utilities --
---------------

-------------------------
--slice tables utility --
-------------------------
local function slice(tbl, first, last, step)
	local sliced = {}

	for i = first or 1, last or #tbl, step or 1 do
		sliced[#sliced+1] = tbl[i]
	end

	return sliced
end


-------------------------
-- Get 1st key utility --
-------------------------
local function get_first_key(T)
	for key, value in pairs(T) do
		return key
	end
end
-------------------------------------------
--         random hash (for videos)      --
-- 4 Bytes Hash in the range a-z A-Z 0-9 --
-------------------------------------------
local function get_newhash()
	return char(random(48,122),random(48,122),random(48,122),random(48,122))
end

-----------------------------------------------------------------------
--  DATABASE_FILE - Txt database containing whole data phone-related --
-----------------------------------------------------------------------
DATABASE_FILE = get_worldpath().."/timetravel_phone_database.txt"
DATABASE = {
	["singleplayer"] = {
		[10000000] = {
			received = {
				{
					phone = 'Minetest',
					message = "Hi, \n you don't have any message yet!",
					s = false,
					t = get_timeofday(),
					d = get_gametime(),
				}
			},
			sent = {
				{
					phone = 'Minetest',
				message = "Hi, you don't have sent messages!",
					s = false,
					t = get_timeofday(),
					d = get_gametime(),
				}
			},
			contacts = {
				{
					name = "My Number",
					phone = 10000000
				}
			},
			notes = {
				{
					text = "Here you can see your notes."
				}
			},
			config = {
				alarm_tone = 1,
				sms_ringtone = 1,
				theme = 1,
				vibration = true,
				silent_mode = false,
				wallpaper = 1
			}
		}
	}
}
--### Check if file exists else create
f = io.open(DATABASE_FILE,"r")
if f == nil then
	--This means there is no file, so let's create one
	--with default values
	f2 = io.open(DATABASE_FILE,"w")
	local db = compress(serialize(DATABASE))
	f2:write(db)
	f2:close()
else
	f = io.open(DATABASE_FILE,"r")
	db = f:read("*all")
	if db then
		DATABASE = deserialize(decompress(db)) or DATABASE
	end
	f:close()
end
	
--VIDEOS - FIXME instructables.txt
VIDEOGLRY_FILE = get_worldpath().."/timetravel_video_galery.txt"
VIDEOGLRY = {
	{
		src = "timetravel_video4.png",
		frames = 12,
		snd = ""
	},
	{
		src = "timetravel_static.png",
		frames = 24,
		snd = "timetravel_staticsound"
	},
	{
		src = "timetravel_arested.png",
		frames = 504,
		snd = "timetravel_a",
		framerate = 1/12
	}
}
--### Check if file exists else create a new one
f = io.open(VIDEOGLRY_FILE,"r")
if f == nil then
	f2 = io.open(VIDEOGLRY_FILE,"w")
	local db = compress(serialize(VIDEOGLRY))
	f2:write(db)
	f2:close()
else
	f = io.open(VIDEOGLRY_FILE,"r")
	db = f:read("*all")
	if db then
		VIDEOGLRY = deserialize(decompress(db)) or VIDEOGLRY
	end
	f:close()
end
--Phone Handler
PHHandler = {}

--CREATE NEW PHONES
m_on_joinplayer(function(player)
	local name = player:get_player_name()
	local phone_nb = random(10000000,99999999)
	if not DATABASE[name] then
		print(get_timeofday(),"HI")
		DATABASE[name] = {
			[phone_nb] = {
				received = {
					{
						phone = 'Minetest',
						message = "Hi,\n you don't have any message yet!",
						s = false,
						t = get_timeofday(),
						d = get_gametime(),
					}
				},
				sent = {
					{
						phone = 'Minetest',
						message = "Hi, you don't have sent messages!",
						s = false,
						t = get_timeofday(),
						d = get_gametime(),
					}
				},
				notes = {
					{
						text = "Here you can see your notes."
					}
				},
				contacts = {
					{
						name = "My Number",
						phone = phone_nb,
					}
				},
				config = {
					alarm_tone = 1,
					sms_ringtone = 1,
					theme = 1,
					vibration = true,
					silent_mode = false,
					wallpaper = 1,
				}
			}
		}
	end
	--phone handler (not necessary store data on Hard Disc)
	PHHandler[name] = {}
	PHHandler[name]["frame"] = 1
	PHHandler[name]["playing"] = false
	PHHandler[name]["video"] = VIDEOGLRY[1]
	PHHandler[name]["page"] = 1
	PHHandler[name]["box"] = "received"
	PHHandler[name]["alarmHandler"] = false
	PHHandler[name]["alarmShift"] = 0
	PHHandler[name]["showing_background"] = false
end)
--Multitreaded Autosave -- I hope that
local timer = 0
autosave = coroutine.create(function()
	register_globalstep(function(dtime)
		timer = timer + dtime
		if timer >= 5 then -- Save every 5 sec
			local db = compress(serialize(DATABASE))
			local f1 = io.open(DATABASE_FILE,"w")
			f1:write(db)
			f1:close()
			timer = 0
		end
	end)
end)
coroutine.resume(autosave)

--------------------------
--     Shows apps       --
--------------------------
function show_apps(player)
	local name = player:get_player_name()
	local phone = get_first_key(DATABASE[name])
	local background = "timetravel_bg"..DATABASE[name][phone]["config"]["wallpaper"]..".png"
	show_form(player:get_player_name(), "time_travel:phoneform",
		"size[10,10]" ..
		"background[0,0;10,10;timetravel_phone.png^"..background.."]"..
		"image_button[2,0.5;2,2;timetravel_phone_messages.png;messages;\n\n\n\nMessages]"..
		"image_button[4,0.5;2,2;timetravel_phone_calls.png;calls;\n\n\n\nCalls]"..
		"image_button[4,0.5;2,2;timetravel_phone_dialling.png;dial;\n\n\n\nPhone]"..
		"image_button[6,0.5;2,2;timetravel_phone_calls.png;calls;\n\n\n\nCalls]"..
		"image_button[2,2.5;2,2;timetravel_phone_photoglry.png;photos;\n\n\n\nPhotos]"..
		"image_button[4,2.5;2,2;timetravel_phone_videos.png;videos;\n\n\n\nVideos]"..				
		"image_button[6,2.5;2,2;timetravel_phone_alarm.png;alarm;\n\n\n\nAlarm]"..			
		"image_button[2,4.5;2,2;timetravel_phone_calc.png;calc;\n\n\n\nCalculator]"..
		"image_button[4,4.5;2,2;timetravel_phone_calendar.png;calendar;\n\n\n\nCalendar]"..
		"image_button[6,4.5;2,2;timetravel_phone_camera.png;camera;\n\n\n\nCamera]"..
		"image_button[2,6.5;2,2;timetravel_phone_notes.png;notes;\n\n\n\nNotes]"..
		"image_button[4,6.5;2,2;timetravel_phone_contacts.png;contacts;\n\n\n\nContacts]"..
		"image_button[6,6.5;2,2;timetravel_phone_conf.png;settings;\n\n\n\nSettings]"..
		"image_button_exit[3.2,8.7;0.6,0.6;timetravel_phone_X.png;x;]".. --close phone
		"image_button[4.7,8.7;0.6,0.6;timetravel_phone_O.png;o;]".. --Apps Menu x close
		"image_button[6.2,8.7;0.6,0.6;timetravel_phone_P.png;p;]".. --close all apps and show background
		"")
end

----------------------
-- Dialling screen  --
----------------------
local function dialling_screen(player)
	local name = player:get_player_name()
	--TODO: make this later
end
----------------------
--    Calculator    --
----------------------
local function dialling_screen(player)
	local name = player:get_player_name()
	local formspec = "size[10,10]"..
		"background[0,0;10,10;timetravel_phone.png]"
	--TODO: stop been a lazy boy and start to code this
end
----------------------
-- Show your notes  --
----------------------
local function show_notes(player,pgnum,phone)
	local name = player:get_player_name()
	local background = "timetravel_bg"..DATABASE[name][phone]["config"].wallpaper..".png"
	if phone then
		local NOTES = DATABASE[name][phone]["notes"]
		local num_pags =  ceil(#NOTES/4)
		if num_pags == 0 then
			num_pags = 1
		end
		NOTES  = slice(NOTES, 1 + 4*(pgnum - 1), 4*(pgnum), 1)
		local formspec = "size[10,10]"..
			"label[4.2,0.1;Pages "..pgnum.."/"..num_pags.."]"..
			"background[0,0;10,10;timetravel_phone.png^"..background.."]"
		local i = 0.5
		for j,line in ipairs(NOTES) do
			formspec = formspec.."image[2,"..i..";7.2,2.2;timetravel_button_normal.png]"..
				"label[3.5,"..(i+0.9)..";"..string.sub(string.gsub(line.text, "\n", " "),1,20).."...]"..
				"image_button[2,"..i..";6,2;timetravel_tranparency.png;"..j..";;false;false;]"..
				"image_button[7,"..(i+0.75)..";0.6,0.6;timetravel_phone_delete.png;delete"..j..";;false;false;]"
			i = i + 2
		end
		formspec = formspec..
			"image_button[2,7;1.5,1.5;timetravel_phone_add.png;new_note;;false;false;]"..
			"image_button_exit[3.2,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
			"image_button[4.7,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
			"image_button[6.2,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
		show_form(name, "time_travel:show_notes", formspec)
	end
end
---------------------------
-- Shows a selected note --
---------------------------
local function show_note(player,pgnum,phone,field)
	local name = player:get_player_name()
	--*** TODO BEAUTYFY THIS ***
	if phone then
		local NOTES = DATABASE[name][phone]["notes"]
		local num_pags = ceil(#NOTES/4)
		if num_pags == 0 then
			num_pags = 1
		end
		NOTES = slice(NOTES, 1 + 4*(pgnum - 1), 4*(pgnum), 1)
		NOTES = NOTES[field]
		local background = "timetravel_bg"..DATABASE[name][phone]["config"].wallpaper..".png"
		local formspec = "size[10,10]"..
			"background[0,0;10,10;timetravel_phone.png^"..background.."]"
		if NOTES then
			formspec = formspec..
				"textlist[2,1;5.8,7.4;;"
			local msg = form_escape(NOTES.text)
			for i = 1,#msg do
				if i % 37 == 0 then
					formspec = formspec..msg:sub(i,i)..","
				else
					formspec = formspec..msg:sub(i,i)
				end
			end
		end
		formspec = formspec..";]image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
			"image_button[4.7,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
			"image_button[6.2,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
		show_form(name, "time_travel:note", formspec)
	end
end

-------------------------------------
--    Shows compose note dialog    -- 
-------------------------------------
local function compose_note(player,phone)
	local name = player:get_player_name()
	local background = "timetravel_bg"..DATABASE[name][phone]["config"].wallpaper..".png"
	local formspec = "size[10,10]"..
		"background[0,0;10,10;timetravel_phone.png^"..background.."]"..
		"textarea[2.3,0.8;6,7;time_travel:body_text;Text:;]"..
		"image_button[2,7.7;3,0.9;timetravel_phone_cancel.png;CANCEL;]"..
		"image_button[5,7.7;3,0.9;timetravel_msg_send.png;OK;]"..
		"image_button_exit[3.2,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.7,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6.2,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
	show_form(name, "time_travel:compose_note", formspec)
end
--------------------------
-- Shows a selected msg --
--------------------------
local function show_msg(player,pgnum,phone,box,field)
	local name = player:get_player_name()
	--*** TODO BEAUTYFY THIS ***
	if phone and box then
		local message_book = DATABASE[name][phone][box]
		local num_pags = ceil(#message_book/4)
		if num_pags == 0 then
			num_pags = 1
		end
		message_book  = slice(message_book, 1 + 4*(pgnum - 1), 4*(pgnum), 1)
		local message_text = message_book[field]
		local deco = ''
		if box == "sent" then
			deco = "To"
		elseif box == "received" then
			deco = "From"
		end
		local background = "timetravel_bg"..DATABASE[name][phone]["config"].wallpaper..".png"
		local formspec = "size[10,10]"..
			"background[0,0;10,10;timetravel_phone.png^"..background.."]"
		if message_text then
			message_text.s = false
			local tel = form_escape(message_text.phone)
			formspec = formspec..
				"textlist[2,1;5.8,7.4;;"..deco..": "..tel..","
			local msg = form_escape(message_text.message)
			for i = 1,#msg do
				if i % 37 == 0 then
					formspec = formspec..msg:sub(i,i)..","
				else
					formspec = formspec..msg:sub(i,i)
				end
			end
		end
		formspec = formspec..";]image_button_exit[3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
			"image_button[4.7,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
			"image_button[6.2,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
		show_form(name, "time_travel:msg", formspec)
	end
end
-------------------------------------
--    Shows main msg menu          -- 
-------------------------------------
local function messages_menu(player,phone)
	local name = player:get_player_name()
	local background = "timetravel_bg"..DATABASE[name][phone]["config"].wallpaper..".png"
	local formspec = "size[10,10]"..
		"background[0,0;10,10;timetravel_phone.png^"..background.."]"..
		"image_button[2,0.5;6,2;timetravel_new_msg.png;3;]"..
		"image_button[2,2.5;6,2;timetravel_rcvdbox.png;2;]"..
		"image_button[2,4.5;6,2;timetravel_sentbox.png;1;]"..
		"image_button_exit[3.2,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.7,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6.2,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
	show_form(name, "time_travel:messages_menu", formspec)
end
-------------------------------------
--    Shows compose msg dialog     -- 
-------------------------------------
local function show_compose_msg(player,number,phone)
	local name = player:get_player_name()
	local background = "timetravel_bg"..DATABASE[name][phone]["config"].wallpaper..".png"
	local formspec = "size[10,10]"..
		"background[0,0;10,10;timetravel_phone.png^"..background.."]"..
		"field[2.3,0.8;6,1;time_travel:dest_msg;To:;"..number.."]"..
		"textarea[2.3,1.8;6,6.8;time_travel:body_msg;Message:;]"..		
		"image_button[2,7.7;3,0.9;timetravel_phone_cancel.png;CANCEL;]"..
		"image_button[5,7.7;3,0.9;timetravel_msg_send.png;OK;]"..
		"image_button_exit[3.2,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.7,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6.2,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
	show_form(name, "time_travel:messages_compose_menu", formspec)
end
-------------------------------------
--          Shows messages         -- 
-------------------------------------
local function show_messages(player,pgnum,phone,box)
	local name = player:get_player_name()
	local background = "timetravel_bg"..DATABASE[name][phone]["config"].wallpaper..".png"
	if phone and box then
		local message_book = DATABASE[name][phone][box]
		local num_pags =  ceil(#message_book/4)
		if num_pags == 0 then
			num_pags = 1
		end
		message_book  = slice(message_book, 1 + 4*(pgnum - 1), 4*(pgnum), 1)
		local formspec = "size[10,10]"..
			"label[4.2,0.1;Pages "..pgnum.."/"..num_pags.."]"..
			"background[0,0;10,10;timetravel_phone.png^"..background.."]"
		local i = 0.5
		local n
		local time_speed = setting_get("time_speed")
		for j,line in ipairs(message_book) do
			if line.s then
				n = 'yellow'
			else
				n = 'normal'
			end
			local date = os.date("%x", (os.time(os.date("*t")))/time_speed) --convert to local minetest time
			--[[ FIXME This "line.t = line.t or 0" is a Uggly 
			Hack, for some strange reason the default message: 
			"You don't sent any msg yet and blablabla" do not
			has the "t" var on table,
			I can't get the time of day for put in table...]]
			line.t = line.t or 0
			local time_fmt = string.format("%.2d:%.2d:%.2d", 
				(line.t*86400)/(60*60), (line.t*86400) / 60 % 60, (line.t*86400) % 60)
			formspec = formspec..
				"background[2,"..i..";7.2,2.2;timetravel_button_"..n..".png]"..
				"label[5,"..(i+0.5)..";"..date..","..time_fmt.."]"..
				"label[2.5,"..(i+0.5)..";"..line.phone.."]"..
				"label[3.5,"..(i+0.9)..";"..string.sub(string.gsub(line.message, "\n", " "),1,20).."...]"..
				"image_button[2,"..i..";6,2;timetravel_tranparency.png;"..j..";;false;false;]"..
				"image_button[7,"..(i+1)..";0.6,0.6;timetravel_phone_delete.png;delete"..j..";;false;false;]"
			i = i + 2
		end
		formspec = formspec.."image_button_exit[3.2,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
			"image_button[4.7,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
			"image_button[6.2,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
		show_form(name, "time_travel:messages", formspec)
	end
end
-------------------------------------
--  TODO     Shows your calls      -- 
-------------------------------------
local function show_calls(player,phone)
	local name = player:get_player_name()
	local background = "timetravel_bg"..DATABASE[name][phone]["config"].wallpaper..".png"
	show_form(name, "time_travel:calls",
		"size[10,10]" ..
		"background[0,0;10,10;timetravel_phone.png^"..background.."]"..
		"image_button_exit[3.2,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.7,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6.2,8.7;0.6,0.6;timetravel_phone_P.png;p;]"..
		"")
end
-------------------------------------
--   TODO Shows the Contacts Screen    -- 
-------------------------------------
local function show_contacts(player,phone)
	local name = player:get_player_name()
	local background = "timetravel_bg"..DATABASE[name][phone]["config"].wallpaper..".png"
	show_form(name, "time_travel:contacts",
		"size[10,10]" ..
		"background[0,0;10,10;timetravel_phone.png^"..background.."]"..
		"image_button_exit[3.2,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.7,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6.2,8.7;0.6,0.6;timetravel_phone_P.png;p;]"..
		"")
end
-------------------------------------
-- That shows the "Main" Screen   -- 
-------------------------------------
local function show_bg(player,phone)
	local name = player:get_player_name()
	local time_speed = setting_get("time_speed")
	local t = 0
	register_globalstep(function(dtime)
		t = t + dtime
		if PHHandler[name]["showing_background"] == true then
			if t >= 1 then
				t = 0
				local time = get_timeofday()
				local background = "timetravel_bg"..DATABASE[name][phone]["config"].wallpaper..".png"
				local c_time = get_timeofday()*86400
				local digit_1 = floor((c_time/(60*60))/10)
				local digit_2 = floor(c_time/(60*60) - digit_1*10)
				local digit_3 = floor((c_time / 60 % 60)/10)
				local digit_4 = floor(c_time / 60 % 60 - digit_3*10)
				show_form(name, "time_travel:bg",
					"size[10,10]" ..
					"background[0,0;10,10;timetravel_phone.png^"..background.."]"..
					"image       [2.5,2;1,1.5;timetravel_numbers.png^[verticalframe:11:"..digit_1.."]"..
					"image       [3.5,2;1,1.5;timetravel_numbers.png^[verticalframe:11:"..digit_2.."]"..
					"image       [4.5,2;1,1.5;timetravel_numbers.png^[verticalframe:11:10]".. --separator is 10
					"image       [5.5,2;1,1.5;timetravel_numbers.png^[verticalframe:11:"..digit_3.."]"..
					"image       [6.5,2;1,1.5;timetravel_numbers.png^[verticalframe:11:"..digit_4.."]"..
					"image_button_exit[3.2,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
					"image_button[4.7,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
					"image_button[6.2,8.7;0.6,0.6;timetravel_phone_P.png;p;]"..
				"")
			end
		else
			return
		end
	end)
end


-------------------------------------
--    Shows the Video Galery       -- 
-------------------------------------
local function video_galery(player,pgnum)
	local name = player:get_player_name()
	local formspec = "size[10,10]" ..
		"background[0,0;10,10;timetravel_phone.png;false]"..
		"label[4.2,0.1;Pages "..pgnum.."/"..ceil(#VIDEOGLRY/8).."]"
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
	formspec = formspec.."image_button_exit[3.2,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.7,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6.2,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
	show_form(name, "time_travel:video_galery", formspec)
end
-------------------------------------
--    Shows the alarm ringing      -- 
-------------------------------------
local function show_alarm(player,phone)
	local name = player:get_player_name()
	local background = "timetravel_bg"..DATABASE[name][phone]["config"].wallpaper..".png"
	local snd = "timetravel_alarm"..DATABASE[name][phone]["config"].alarm_tone
	if not PHHandler[name]["alarmHandler"] then
		PHHandler[name]["alarmHandler"] = m_play(snd, {
			to_player = name,
			gain = 1.0,
			loop = true
		})
	end
	show_form(name, "time_travel:show_alarm",
		"size[10,10]" ..
		"background       [0,0;10,10;timetravel_phone.png^"..background.."^timetravel_alarmbg.png;false]"..
		"image_button_exit[2,5.1;6,1;timetravel_alarmok.png;ok;;false;false;]"..
		"image_button_exit[2,6.1;6,1;timetravel_alarmsnooze.png;snooze;;false;false;]"..
		"image_button     [3,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button     [4.5,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button     [6,8.7;0.6,0.6;timetravel_phone_P.png;p;]"..
		"")
end
-------------------------------------
--    Shows the set alarm screen   -- 
-------------------------------------
local function set_alarm(player,phone)
	local name = player:get_player_name()
	local background = "timetravel_bg"..DATABASE[name][phone]["config"].wallpaper..".png"
	local shift_in_sec = PHHandler[name]["alarmShift"]
	-- If shift < 0 then add one day
	local c_time = get_timeofday()*86400 + shift_in_sec --current time of day in minetest in sec + shift
	local digit_1 = floor((c_time/(60*60))/10)
	local digit_2 = floor(c_time/(60*60) - digit_1*10)
	local digit_3 = floor((c_time / 60 % 60)/10)
	local digit_4 = floor(c_time / 60 % 60 - digit_3*10)
	show_form(name, "time_travel:set_alarm",
		"size[10,10]" ..
		"background[0,0;10,10;timetravel_phone.png^"..background.."^timetravel_alarmbg.png;false]"..
		"image_button[2  ,7.5;6,1;timetravel_alarmok.png;ok;;false;false;]"..
		"image_button[3,4.75;1,1;timetravel_phone_uparrow.png;up1;;false;false;]"..
		"image       [2.5,5.5;1,1.5;timetravel_numbers.png^[verticalframe:11:"..digit_1.."]"..--11px Height for each frame
		"image       [3.5,5.5;1,1.5;timetravel_numbers.png^[verticalframe:11:"..digit_2.."]"..
		"image_button[3,6.65;1,1;timetravel_phone_downarrow.png;down1;;false;false;]"..
		"image       [4.5,5.5;1,1.5;timetravel_numbers.png^[verticalframe:11:10]".. --separator is 10
		"image_button[6,4.75;1,1;timetravel_phone_uparrow.png;up2;;false;false;]"..
		"image       [5.5,5.5;1,1.5;timetravel_numbers.png^[verticalframe:11:"..digit_3.."]"..
		"image       [6.5,5.5;1,1.5;timetravel_numbers.png^[verticalframe:11:"..digit_4.."]"..
		"image_button[6,6.65;1,1;timetravel_phone_downarrow.png;down2;;false;false;]"..
		"image_button_exit[3.2,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.7,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6.2,8.7;0.6,0.6;timetravel_phone_P.png;p;]"..
		"")
end
-----------------------------------------
-- Just a utility for make screenshots --
--    TODO: add filters and a hud      --
-----------------------------------------
local function show_camera(player,phone)
	local name = player:get_player_name()
	local background = "timetravel_bg"..DATABASE[name][phone]["config"].wallpaper..".png"
	--hide built-in
	--player:hud_set_flags({crosshair = true, hotbar = false, healthbar = false, wielditem = false, breathbar = false})
end
------------------
-- Photo Galery ------------------------------
--    TODO: find a way to load screenshots  --
----------------------------------------------
local function photo_galery(player,pgnum)
	local name = player:get_player_name()
	local formspec = "size[10,10]" ..
		"background[0,0;10,10;timetravel_phone.png;false]"..
		"label[4.2,0.1;Pages "..pgnum.."/"..ceil(#VIDEOGLRY/8).."]"
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
	formspec = formspec.."image_button_exit[3.2,8.7;0.6,0.6;timetravel_phone_X.png;x;]"..
		"image_button[4.7,8.7;0.6,0.6;timetravel_phone_O.png;o;]"..
		"image_button[6.2,8.7;0.6,0.6;timetravel_phone_P.png;p;]"
	show_form(name, "time_travel:photo_galery", formspec)
end
-------------------------------------
--     Shows the video player      -- 
-------------------------------------
local function show_video(player)
	local name = player:get_player_name()
	local videosrc = PHHandler[name]["video"].src
	local t_frames = PHHandler[name]["video"].frames
	local snd = PHHandler[name]["video"].snd
	local frame = PHHandler[name]["frame"]
	if PHHandler[name]["playing"] then
		if frame == 1 then
			sndHandler = m_play(snd, {
				to_player = name,
				gain = 1.0
			})
		end
		show_form(name, "time_travel:show_video",
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
		if sndHandler then
			 m_stop(sndHandler)
		end
		show_form(name, "time_travel:show_video",
			"size[10,10]" ..
			"background[0,0;10,10;timetravel_phone_90.png;false]"..
			"image_button[3.5,4;2,2;timetravel_button_play.png;play;;false;false;]"..
			"image_button[0.3,7.4;0.7,0.7;timetravel_button_play.png;play;]"..
			"image[0.8,7.4;9.4,0.6;timetravel_video_bar.png]"..
			"image[0.8,7.4;0,0.6;timetravel_video_bar_BLUE.png]"..
			"image[0.3,2.5;"..(5*2)..","..(2.81*2)..";("..videosrc.."^[verticalframe:"..t_frames..":1)]"..
			"image_button_exit[8.7,3;0.6,0.6;timetravel_phone_X.png;x;]"..
			"image_button[8.7,4.5;0.6,0.6;timetravel_phone_O.png;o;]"..
			"image_button[8.7,6;0.6,0.6;timetravel_phone_P.png;p;]"..
			"")
	end
end
register_craftitem("time_travel:phone", {
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
		--revert_actions_by("player:"..player:get_player_name(), 5) -- hours*minutes*seconds
	end,
})
------------------------------
-- On player receive fields --
------------------------------
p_rcv_fields(function(player, formname, fields)
	print(dump(fields))
	local player_name = player:get_player_name()
	local phone = get_first_key(DATABASE[player_name])
	if not player:get_wielded_item() == "time_travel:phone" then return end
	local page = PHHandler[player_name]["page"]
	if formname == "time_travel:phoneform" then -- Replace this with your form name
		----------------------
		--      Messages    --
		----------------------
		if fields.messages then
			messages_menu(player,phone)
		----------------------
		--       Notes      --
		----------------------
		elseif fields.notes then
			show_notes(player,1,phone)
		----------------------
		--      Videos      --
		----------------------
		elseif fields.videos then
			video_galery(player,page)
		----------------------
		--      Calls       --
		----------------------
		elseif fields.calls then
			show_calls(player,phone)
		----------------------
		--     Contatcts    --
		----------------------
		elseif fields.contacts then
			show_contacts(player,phone)
		----------------------
		--      Alarm       --
		----------------------
		elseif fields.alarm then
			set_alarm(player,phone)
		----------------------
		--     Camera       --
		----------------------
		elseif fields.camera then
			show_camera(player,phone)
		----------------------
		--    Background    --
		----------------------
		elseif fields.p then
			PHHandler[player_name]["showing_background"] = true
			show_bg(player,phone)
		end
	elseif formname == "time_travel:messages" then
		local page = PHHandler[player_name]["page"]
		local box = PHHandler[player_name]["box"]
		local data = DATABASE[player_name][phone][box]
		local num_pags =  ceil(#data/4)
		-- if the list are empty so we have just one page
		if num_pags == 0 then
			num_pags = 1
		end
		-------------------------------
		-- Scrolls to the next page  --
		-------------------------------
		if fields.key_down then
			if page < num_pags then
				page = page + 1
			else
				page = num_pags
			end
			PHHandler[player_name]["page"] = page
			show_messages(player,page,phone,PHHandler[player_name]["box"])
		end
		-------------------------------
		-- Scrolls to the prev page  --
		-------------------------------
		if fields.key_up then
			if page > 1 then
				page = page - 1
			else
				page = 1
			end
			PHHandler[player_name]["page"] = page
			show_messages(player,page,phone,PHHandler[player_name]["box"])
		end
		-------------------------------
		--    Delete det. message    --
		-------------------------------
		if fields["delete1"] then
			--Which one I must use...
			--FIXME remove the last one remaining msg it's not possible...
			DATABASE[player_name][phone][PHHandler[player_name]["box"]][(page-1)*4+1] = nil
			table.remove(DATABASE[player_name][phone][PHHandler[player_name]["box"]],(page-1)*4+1)
			show_messages(player,page,phone,PHHandler[player_name]["box"])
		elseif fields["delete2"] then
			DATABASE[player_name][phone][PHHandler[player_name]["box"]][(page-1)*4+2] = nil
			table.remove(DATABASE[player_name][phone][ PHHandler[player_name]["box"] ],(page-1)*4+2)
			show_messages(player,page,phone,PHHandler[player_name]["box"])
		elseif fields["delete3"] then
			DATABASE[player_name][phone][PHHandler[player_name]["box"]][(page-1)*4+3] = nil
			table.remove(DATABASE[player_name][phone][PHHandler[player_name]["box"]],(page-1)*4+3)
			show_messages(player,page,phone,PHHandler[player_name]["box"])
		elseif fields["delete4"] then
			DATABASE[player_name][phone][PHHandler[player_name]["box"]][(page-1)*4+4] = nil
			table.remove(DATABASE[player_name][phone][PHHandler[player_name]["box"]],(page-1)*4+4)
			show_messages(player,page,phone,PHHandler[player_name]["box"])
		end
		-------------------------------
		--     Shows det. message    --
		-------------------------------
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
			PHHandler[player_name]["showing_background"] = true
			--just the background
			show_bg(player,phone)
		end
	-------------------------------
	--      Shows all notes      --
	-------------------------------
	elseif formname == "time_travel:show_notes" then
		local page = PHHandler[player_name]["page"]
		local data = DATABASE[player_name][phone]["notes"]
		local num_pags =  ceil(#data/4)
		-- if the list are empty so we have just one page
		if num_pags == 0 then
			num_pags = 1
		end
		------------------
		-- Add new note --
		------------------
		if fields.new_note then
			compose_note(player,phone)
		end
		-------------------------------
		-- Scrolls to the next page  --
		-------------------------------
		if fields.key_down then
			if page < num_pags then
				page = page + 1
			else
				page = num_pags
			end
			PHHandler[player_name]["page"] = page
			show_notes(player,page,phone)
		end
		-------------------------------
		-- Scrolls to the prev page  --
		-------------------------------
		if fields.key_up then
			if page > 1 then
				page = page - 1
			else
				page = 1
			end
			PHHandler[player_name]["page"] = page
			show_notes(player,page,phone)
		end
		-------------------------------
		--      Delete det. note     --
		-------------------------------
		if fields["delete1"] then
			--Which one I must use?...
			--FIXME remove the last one remaining msg it's not possible SOMETIMES...
			DATABASE[player_name][phone]["notes"][(page-1)*4+1] = nil
			table.remove(DATABASE[player_name][phone]["notes"],(page-1)*4+1)
			show_notes(player,page,phone)
		elseif fields["delete2"] then
			DATABASE[player_name][phone]["notes"][(page-1)*4+2] = nil
			table.remove(DATABASE[player_name][phone]["notes"],(page-1)*4+2)
			show_notes(player,page,phone)
		elseif fields["delete3"] then
			DATABASE[player_name][phone]["notes"][(page-1)*4+3] = nil
			table.remove(DATABASE[player_name][phone]["notes"],(page-1)*4+3)
			show_messages(player,page,phone)
		elseif fields["delete4"] then
			DATABASE[player_name][phone]["notes"][(page-1)*4+4] = nil
			table.remove(DATABASE[player_name][phone]["notes"],(page-1)*4+4)
			show_notes(player,page,phone)
		end
		-------------------------------
		--       Shows det. note     --
		-------------------------------
		if fields["1"] then
			show_note(player,page,phone,1)
		elseif fields["2"] then
			show_note(player,page,phone,2)
		elseif fields["3"] then
			show_note(player,page,phone,3)
		elseif fields["4"] then
			show_note(player,page,phone,4)
		end
		if fields.o then
			show_apps(player)
		elseif fields.p then
			PHHandler[player_name]["showing_background"] = true
			--just the background
			show_bg(player,phone)
		end
	elseif formname == "time_travel:calls" then
		if fields.o then
			show_apps(player)
		elseif fields.p then
			PHHandler[player_name]["showing_background"] = true
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
	elseif formname == "time_travel:note" then
		if fields.p then
			--just the background
			show_apps(player)
		elseif fields.o then
			show_notes(player,1,phone)
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
			PHHandler[player_name]["showing_background"] = false
			show_apps(player)
		elseif fields.x then
			PHHandler[player_name]["showing_background"] = false
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
			PHHandler[player_name]["showing_background"] = true
			show_bg(player,phone)
		end
	------------------------------
	-- the video galery logical --
	------------------------------
	elseif formname == "time_travel:video_galery" then
		if fields.o then
			show_apps(player)
		end
		if fields.p then
			PHHandler[player_name]["showing_background"] = true
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
	------------------------------
	-- the video player logical --
	------------------------------
	elseif formname == "time_travel:show_video" then
		if fields.quit then
			PHHandler[player_name]["playing"] = false
			PHHandler[player_name]["frame"] = 1
			if sndHandler then
				 m_stop(sndHandler)
			end
		elseif fields.o then
			PHHandler[player_name]["playing"] = false
			PHHandler[player_name]["frame"] = 1
			if sndHandler then
				 m_stop(sndHandler)
			end
			video_galery(player,page)
		elseif fields.p then
			PHHandler[player_name]["playing"] = false
			PHHandler[player_name]["frame"] = 1
			if sndHandler then
				 m_stop(sndHandler)
			end
			PHHandler[player_name]["showing_background"] = true
			show_bg(player,phone)
		--FIXME Buggy: I think this would be impossible pause also the audio trail currenttly
		elseif fields.pause then
			PHHandler[player_name]["playing"] = false
			show_video(player)
		elseif fields.play then
			PHHandler[player_name]["playing"] = true
			local rate = PHHandler[player_name]["video"].framerate or 1/14 -- Frame rate
			local frame = PHHandler[player_name]["video"].frames
			local s = 0
			local hash = get_newhash()
			PHHandler[player_name]["playing"] = hash
			for i = 1, frame do
				minetest_after(s, function()
					-- the variable hash does not change after function registration so this works!
					if PHHandler[player_name]["playing"] == hash then
						show_video(player)
						if i <= frame then
							PHHandler[player_name]["frame"] = PHHandler[player_name]["frame"] + 1
						else
							PHHandler[player_name]["frame"] = 1
						end
					end
				end)
				s = s + rate
			end
			minetest_after(s + rate, function()
				PHHandler[player_name]["playing"] = false
				PHHandler[player_name]["frame"] = 1
				if PHHandler[player_name]["playing"] == hash then
					show_video(player)
				end
			end)
		end
	-------------------------------
	--       Alarm ringing       --
	-------------------------------
	elseif formname == "time_travel:show_alarm" then
		if fields.ok or fields.quit then
			if PHHandler[player_name]["alarmHandler"] then
				 m_stop(PHHandler[player_name]["alarmHandler"])
			end
			PHHandler[player_name]["alarmHandler"] = false
			PHHandler[player_name]["alarmShift"] = 0
		elseif fields.snooze then
			--FIXME It isn't working
			minetest_after(3,show_alarm,player,phone)
			if PHHandler[player_name]["alarmHandler"] then
				 m_stop(PHHandler[player_name]["alarmHandler"])
			end
			PHHandler[player_name]["alarmHandler"] = false
			PHHandler[player_name]["alarmShift"] = 0
		end
	-------------------------------
	--    Create a new alarm     --
	-------------------------------
	elseif formname == "time_travel:set_alarm" then
		--if there's any alarm playing
		print(dump(PHHandler[player_name]["alarmHandler"]))
		if PHHandler[player_name]["alarmHandler"] then
			show_alarm(player,phone)
		else
			local time_alarm = get_timeofday()*86400 + PHHandler[player_name]["alarmShift"]
			if fields.up1 then
				PHHandler[player_name]["alarmShift"] = PHHandler[player_name]["alarmShift"] + 60*60
				if time_alarm >= 23*60*60 then --23:00
					PHHandler[player_name]["alarmShift"] = - get_timeofday()*86400
				end
				set_alarm(player,phone)
			elseif fields.down1 then
				PHHandler[player_name]["alarmShift"] = PHHandler[player_name]["alarmShift"] - 60*60
				if time_alarm <= 60*60 - 60 then -- 00:59
					PHHandler[player_name]["alarmShift"] = 24*60*60 - 60 - get_timeofday()*86400
				end
				set_alarm(player,phone)
			elseif fields.up2 then
				PHHandler[player_name]["alarmShift"] = PHHandler[player_name]["alarmShift"] + 60
				if time_alarm >= 24*60*60 - 60 then --23:59
					PHHandler[player_name]["alarmShift"] = - get_timeofday()*86400
				end
				set_alarm(player,phone)
			elseif fields.down2 then
				PHHandler[player_name]["alarmShift"] = PHHandler[player_name]["alarmShift"] - 60
				if time_alarm <= 0 then -- 00:00
					PHHandler[player_name]["alarmShift"] = 24*60*60 - 60 - get_timeofday()*86400
				end
				set_alarm(player,phone)
			end
			if fields.ok then
				local time_speed = setting_get("time_speed")
				minetest_after(PHHandler[player_name]["alarmShift"]/time_speed, show_alarm,player,phone)
				show_apps(player)
			end
			if fields.o then
				show_apps(player)
			end
			if fields.p then
				PHHandler[player_name]["showing_background"] = true
				show_bg(player,phone)
			end
		end
	-------------------------------
	--      Create msg dialog    --
	-------------------------------
	elseif formname == "time_travel:messages_compose_menu" then
		if fields.o or fields.CANCEL then
			messages_menu(player,phone)
		elseif fields.p then
			--just the background
			show_apps(player)
		elseif fields.OK then
			--Destination
			local to = fields["time_travel:dest_msg"]
			--Body of message
			local body = fields["time_travel:body_msg"]
			--If theres some empty field do not send anything
			if not to then return end
			if not body then return end
			local dest_player_name = to
			--TODO: add suport only for contacts
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
			local function send() --send message to dest
				--FIXME D-Mail
				local pos = player:get_pos()
				find_node(pos, 5, {"homedecor:television"})
				t_insert(DATABASE[dest_player_name][to]["received"],1, {
					phone = phone,
					message = body,
					s = true,
					t = get_timeofday(),
					d = get_gametime()
				})
			end
			local function sv_copy()--save a copy
				t_insert(DATABASE[player_name][phone]["sent"],1, {
					phone = to,
					message = body,
					s = false,
					t = get_timeofday(),
					d = get_gametime()
				})
			end
			local tone = DATABASE[dest_player_name][phone]["config"]["sms_ringtone"]
			local vibration = DATABASE[dest_player_name][phone]["config"]["vibration"]
			--TRY EXCEPT Lua version
			if not pcall(send) then
				--Error probably only when user or phone not exists
				t_insert(DATABASE[player_name][phone]["received"],1, {
					phone = 'Minetest',
					message = "Message not sent, reason: name or number incorrect.",
					s = true,
					t = get_timeofday(),
					d = get_gametime()
				})
			else
				if vibration then
					m_play("timetravel_vibration", {
						to_player = dest_player_name,
						gain = 1.5,
					})
				end
				m_play("timetravel_sms_tone"..tone, {
					to_player = dest_player_name,
					gain = 1.5,
				})
			end
			if not pcall(sv_copy) then
				print("strange error!!!")
			end
			messages_menu(player,phone)
		end
	-------------------------------
	--     Create note dialog    --
	-------------------------------
	elseif formname == "time_travel:compose_note" then
		if fields.o or fields.CANCEL then
			show_notes(player,1,phone)
		elseif fields.p then
			--just the background
			show_apps(player)
		elseif fields.OK then
			local txt = fields["time_travel:body_text"]
			if not txt then return end
			t_insert(DATABASE[player_name][phone]["notes"],1, {
				text = txt
			})
			show_notes(player,1,phone)
		end
	end
		
end)
