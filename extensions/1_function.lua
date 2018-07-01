function sendMsg(room,message)
	local msg = sgs.LogMessage()
	msg.type = "#message"
	msg.arg = message
	room:sendLog(msg)
end
function sendMsgByFrom(room,message,player)
	local msg = sgs.LogMessage()
	msg.from = player
	msg.type = "#message1"
	msg.arg = message
	room:sendLog(msg)
end
function sendMsgFrom(room,player,message)
	local msg = sgs.LogMessage()
	msg.from = player
	msg.type = "#message1"
	msg.arg = message
	room:sendLog(msg)
end
function extra_general_init()
	local extra_list = {}
	for _,general in pairs(sgs.Sanguosha:getGeneralNames()) do
		if general:endsWith("_shu") or general:endsWith("_wei") or general:endsWith("_wu") or general:endsWith("_qun")
			or general == "machao" then
			table.insert(extra_list, general)
		end
	end
	return extra_list
end
--初始化分配武将  多势力场景专用
--[[function init()
	local hash = {}
	local multy_kingdom = {}
	for _,general in pairs(sgs.Sanguosha:getLimitedGeneralNames())do
		if general:startsWith("lord_") then continue end
		if general == "zhonghui" then continue end
		if general:endsWith("_shu") or general:endsWith("_wei") or general:endsWith("_wu") or general:endsWith("_qun") then
			local generalRealName
			if general:endsWith("_wu") then
				generalRealName = string.sub(general, 1, string.len(general) - 3)
			else
				generalRealName = string.sub(general, 1, string.len(general) - 4)
			end
			if multy_kingdom[generalRealName] then
				table.insert(multy_kingdom[generalRealName],general)
			else
				local name = {}
				table.insert(name, general)
				multy_kingdom[generalRealName] = name
			end
		else
			if not table.contains(hash, general) then
				table.insert(hash,general)
			end
		end
	end
	for key,value in pairs(multy_kingdom) do
		local general = value[math.random(1,#value)]
		table.insert(hash,general)
	end
	return hash, multy_kingdom
end--]]
function init(extra_list, ban_list)
	local hash = {}
	local multy_kingdom = {}
	for _,general in pairs(sgs.Sanguosha:getLimitedGeneralNames())do
		if general:startsWith("lord_") then continue end
		if table.contains(extra_list, general) then continue end
		if table.contains(ban_list, general) then continue end
		if not table.contains(hash, general) then
			table.insert(hash,general)
		end
	end
	for _,general in pairs(extra_list) do
		if general:endsWith("_shu") or general:endsWith("_wei") or general:endsWith("_wu") or general:endsWith("_qun") then
			local generalRealName
			if general:endsWith("_wu") then
				generalRealName = string.sub(general, 1, string.len(general) - 3)
			else
				generalRealName = string.sub(general, 1, string.len(general) - 4)
			end
			if multy_kingdom[generalRealName] then
				table.insert(multy_kingdom[generalRealName],general)
			else
				local name = {}
				table.insert(name, general)
				multy_kingdom[generalRealName] = name
			end
		elseif general == "machao" then
			if multy_kingdom[general] then
				table.insert(multy_kingdom[general],general)
			else
				local name = {}
				table.insert(name, general)
				multy_kingdom[general] = name
			end
		else
			if not table.contains(hash, general) then
				table.insert(hash,general)
			end
		end
	end
	for key,value in pairs(multy_kingdom) do
		local general = value[math.random(1,#value)]
		table.insert(hash,general)
	end
	return hash, multy_kingdom
end
--随机选取n名武将
function getRandomAllGenerals(n,hash,exceptions)
	hash = table.Shuffle(hash)
	local result = {}
	for _,general in pairs(hash)do
		if #result == n then break end
		if not table.contains(exceptions,general) then
			table.insert(result,general)
		end
	end
	return result
end
--初始化分配武将 根据势力分配,注：只能和getRandomGenerals搭配使用
function initByKingdom(extra_list, ban_list)
	local hash = {wei = {},shu = {},wu = {},qun = {}}
	local multy_kingdom = {}
	for _,general in pairs(sgs.Sanguosha:getLimitedGeneralNames()) do
		if general:startsWith("lord_") then continue end
		if table.contains(extra_list, general) then continue end
		if table.contains(ban_list, general) then continue end
		if hash[sgs.Sanguosha:getGeneral(general):getKingdom()] then
			if not table.contains(hash[sgs.Sanguosha:getGeneral(general):getKingdom()], general) then
				table.insert(hash[sgs.Sanguosha:getGeneral(general):getKingdom()],general)
			end
		end
	end
	for _,general in pairs(extra_list) do
		if general:endsWith("_shu") or general:endsWith("_wei") or general:endsWith("_wu") or general:endsWith("_qun") then
			local generalRealName
			if general:endsWith("_wu") then
				generalRealName = string.sub(general, 1, string.len(general) - 3)
			else
				generalRealName = string.sub(general, 1, string.len(general) - 4)
			end
			if multy_kingdom[generalRealName] then
				table.insert(multy_kingdom[generalRealName],general)
			else
				local name = {}
				table.insert(name, general)
				multy_kingdom[generalRealName] = name
			end
		elseif general == "machao" then
			if multy_kingdom[general] then
				table.insert(multy_kingdom[general],general)
			else
				local name = {}
				table.insert(name, general)
				multy_kingdom[general] = name
			end
		else
			if hash[sgs.Sanguosha:getGeneral(general):getKingdom()] then
				if not table.contains(hash[sgs.Sanguosha:getGeneral(general):getKingdom()], general) then
					table.insert(hash[sgs.Sanguosha:getGeneral(general):getKingdom()],general)
				end
			end
		end
	end
	for key,value in pairs(multy_kingdom) do
		local general = value[math.random(1,#value)]
		local kingdom
		if general:endsWith("_wu") then
			kingdom = string.sub(general, string.len(general) - 1, string.len(general))
		elseif general:endsWith("_shu") or general:endsWith("_wei") or general:endsWith("_qun") then
			kingdom = string.sub(general, string.len(general) - 2, string.len(general))
		end
		if hash[kingdom] then
			table.insert(hash[kingdom],general)
		end
	end
	return hash, multy_kingdom
end
--[[function initByKingdom()
	local hash = {wei = {},shu = {},wu = {},qun = {}}
	local multy_kingdom = {}
	for _,general in pairs(sgs.Sanguosha:getLimitedGeneralNames())do
		if general:startsWith("lord_") then continue end
		if general == "zhonghui" then continue end
		if general:endsWith("_shu") or general:endsWith("_wei") or general:endsWith("_wu") or general:endsWith("_qun") then
			local generalRealName
			if general:endsWith("_wu") then
				generalRealName = string.sub(general, 1, string.len(general) - 3)
			else
				generalRealName = string.sub(general, 1, string.len(general) - 4)
			end
			if multy_kingdom[generalRealName] then
				table.insert(multy_kingdom[generalRealName],general)
			else
				local name = {}
				table.insert(name, general)
				multy_kingdom[generalRealName] = name
			end
		else
			if hash[sgs.Sanguosha:getGeneral(general):getKingdom()] then
				if not table.contains(hash[sgs.Sanguosha:getGeneral(general):getKingdom()], general) then
					table.insert(hash[sgs.Sanguosha:getGeneral(general):getKingdom()],general)
				end
			end
		end
	end
	for key,value in pairs(multy_kingdom) do
		local general = value[math.random(1,#value)]
		local kingdom
		if general:endsWith("_wu") then
			kingdom = string.sub(general, string.len(general) - 1, string.len(general))
		elseif general:endsWith("_shu") or general:endsWith("_wei") or general:endsWith("_qun") then
			kingdom = string.sub(general, string.len(general) - 2, string.len(general))
		end
		if hash[kingdom] then
			table.insert(hash[kingdom],general)
		end
	end
	return hash, multy_kingdom
end--]]
--根据势力随机选取n名武将
function getRandomGenerals(n,hash,kingdom,exceptions)
	hash[kingdom] = table.Shuffle(hash[kingdom])
	local result = {}
	for _,general in pairs(hash[kingdom])do
		if #result == n then break end
		if not table.contains(exceptions,general) then
			table.insert(result,general)
		end
	end
	return result
end
--获得场上的势力数
function getKingdoms(room) --可以在函数中定义函数，本函数返回存活势力的数目
	local kingdoms={}
	local kingdom_number=0
	local players=room:getAlivePlayers()
	for _,aplayer in sgs.qlist(players) do
		if aplayer:hasShownOneGeneral() then
			if (not kingdoms[aplayer:getKingdom()]) and (aplayer:getRole() ~= "careerist") then
				kingdoms[aplayer:getKingdom()]=true
				kingdom_number=kingdom_number+1
			elseif aplayer:getRole() == "careerist" then
				kingdom_number=kingdom_number+1
			end
		end 
	end
	return kingdom_number
end
--疯狂杀戮初始化
function initValue(extra_list, ban_list)
	local game_use_value = {}
	--[[
		@param1: 血量
		@param2: 攻击
		@param3: 防御
		@param4: 智慧
		@param5: 健康
	--]]
	game_use_value["caocao"] = { 451, 122, 52, 78, 100 }
	game_use_value["simayi"] = { 355, 108, 50, 83, 100 }
	game_use_value["xiahoudun"] = { 488, 164, 61, 52, 100 }
	game_use_value["zhangliao"] = { 510, 151, 70, 48, 100 }
	game_use_value["xuchu"] = { 504, 190, 69, 36, 100 }
	game_use_value["zhenji"] = { 315, 85, 35, 71, 125 }
	game_use_value["xiahouyuan"] = { 446, 177, 62, 50, 100 }
	game_use_value["zhanghe"] = { 420, 150, 58, 69, 100 }
	game_use_value["xuhuang"] = { 430, 134, 61, 69, 100 }
	game_use_value["caoren"] = { 530, 100, 96, 63, 120 }
	game_use_value["yuejin"] = { 410, 133, 62, 69, 100 }
	game_use_value["liubei"] = { 421, 102, 77, 77, 100 }
	game_use_value["guanyu"] = { 530, 200, 62, 50, 100 }
	game_use_value["zhangfei"] = { 500, 178, 69, 36, 100 }
	game_use_value["zhugeliang"] = { 331, 116, 48, 95, 100 }
	game_use_value["zhaoyun"] = { 441, 198, 74, 60, 100 }
	game_use_value["machao"] = { 456, 198, 70, 60, 100 }
	game_use_value["huangyueying"] = { 300, 52, 45, 94, 200 }
	game_use_value["weiyan"] = { 450, 179, 63, 72, 100 }
	game_use_value["wolong"] = { 331, 116, 48, 95, 100 }
	game_use_value["liushan"] = { 300, 50, 25, 80, 300 }
	game_use_value["zhurong"] = { 470, 136, 66, 58, 100 }
	game_use_value["sunquan"] = { 410, 116, 82, 83, 100 }
	game_use_value["ganning"] = { 466, 178, 63, 56, 100 }
	game_use_value["lvmeng"] = { 458, 135, 71, 66, 100 }
	game_use_value["zhouyu"] = { 351, 159, 70, 85, 100 }
	game_use_value["daqiao"] = { 314, 61, 34, 71, 150 }
	game_use_value["luxun"] = { 360, 151, 56, 86, 100 }
	game_use_value["sunshangxiang"] = { 315, 100, 48, 68, 100 }
	game_use_value["taishici"] = { 488, 199, 75, 54, 100 }
	game_use_value["lusu"] = { 330, 67, 60, 83, 100 }
	game_use_value["erzhang"] = { 322, 71, 55, 80, 100 }
	game_use_value["dingfeng"] = { 441, 174, 56, 65, 100 }
	game_use_value["huatuo"] = { 300, 50, 20, 78, 300 }
	game_use_value["lvbu"] = { 600, 230, 73, 20, 100 }
	game_use_value["diaochan"] = { 302, 50, 29, 78, 160 }
	game_use_value["yuanshao"] = { 500, 122, 66, 51, 100 }
	game_use_value["yanliangwenchou"] = { 480, 191, 67, 55, 100 }
	game_use_value["pangde"] = { 454, 166, 61, 58, 100 }
	game_use_value["zhangjiao"] = { 400, 140, 70, 70, 100 }
	game_use_value["caiwenji"] = { 301, 66, 37, 75, 160 }
	game_use_value["mateng"] = { 458, 148, 71, 53, 100 }
	game_use_value["kongrong"] = { 333, 81, 44, 81, 100 }
	game_use_value["jiling"] = { 477, 177, 77, 55, 100 }
	game_use_value["panfeng"] = { 411, 155, 55, 55, 150 }
	game_use_value["zoushi"] = { 322, 71, 38, 70, 150 }
	game_use_value["dengai"] = { 401, 161, 75, 72, 100 }
	game_use_value["caohong"] = { 305, 71, 44, 90, 80 }
	game_use_value["jiangwei"] = { 408, 174, 74, 88, 100 }
	game_use_value["jiangwanfeiyi"] = { 333, 110, 48, 79, 100 }
	game_use_value["jiangqin"] = { 447, 151, 70, 65, 100 }
	game_use_value["xusheng"] = { 510, 141, 70, 62, 100 }
	game_use_value["hetaihou"] = { 300, 88, 42, 74, 150 }
	game_use_value["lidian"] = { 356, 147, 62, 77, 100 }
	game_use_value["zangba"] = { 448, 155, 62, 54, 100 }
	game_use_value["madai"] = { 474, 156, 55, 55, 100 }
	game_use_value["mifuren"] = { 300, 57, 32, 74, 200 }
	game_use_value["chenwudongxi"] = { 466, 147, 70, 56, 100 }
	game_use_value["huaxiong"] = { 540, 181, 64, 41, 100 }
	game_use_value["sunhao"] = { 660, 110, 64, 38, 100 }
	game_use_value["niujin"] = { 720, 132, 61, 37, 100 }
	game_use_value["liaohua"] = { 640, 123, 61, 52, 100 }
	game_use_value["bulianshi"] = { 315, 61, 33, 70, 150 }
	game_use_value["jianyong"] = { 360, 88, 56, 82, 100 }
	game_use_value["xushu"] = { 351, 67, 61, 85, 100 }
	game_use_value["liuxie"] = { 355, 55, 55, 80, 100 }
	game_use_value["buzhi"] = { 334, 86, 52, 82, 100 }
	game_use_value["litong"] = { 467, 147, 71, 100 }
	game_use_value["liru"] = { 334, 125, 47, 80, 100 }
	game_use_value["yufan"] = { 327, 94, 51, 81, 100 }
	game_use_value["liyan"] = { 334, 140, 61, 70, 100 }
	game_use_value["zhugejin"] = { 350, 74, 47, 81, 100 }
	game_use_value["chengyu"] = { 300, 132, 40, 89, 100 }
	game_use_value["zhoucang"] = { 488, 178, 78, 54, 100 }
	game_use_value["caimao"] = { 455, 177, 77, 67, 100 }
	game_use_value["miheng"] = { 327, 64, 44, 82, 100 }
	game_use_value["masu"] = { 334, 112, 51, 74, 100 }
	game_use_value["maliang"] = { 319, 99, 55, 83, 100 }
	game_use_value["xuezong"] = { 351, 81, 84, 80, 100 }
	game_use_value["xushi"] = { 322, 61, 38, 76, 140 }
	game_use_value["wangji"] = { 361, 110, 44, 78, 100 }
	game_use_value["caojie"] = { 332, 58, 34, 72, 150 }
	game_use_value["chengong"] = { 310, 55, 55, 92, 100 }
	game_use_value["caochong"] = { 479, 137, 65, 57, 100 }
	game_use_value["meng_zhaoyun"] = { 441, 198, 74, 60, 100 }
	game_use_value["meng_luxun"] = { 360, 151, 56, 86, 100 }
	game_use_value["meng_dianwei"] = { 520, 202, 80, 31, 88 }
	game_use_value["meng_dongzhuo"] = { 520, 161, 78, 37, 100 }
	game_use_value["liuqi_shu"] = { 317, 117, 61, 74, 75 }
	game_use_value["liuqi_qun"] = { 317, 117, 61, 74, 75 }
	game_use_value["huangquan_shu"] = { 350, 135, 51, 64, 100 }
	game_use_value["huangquan_wei"] = { 350, 135, 51, 64, 100 }
	game_use_value["sufei_wu"] = { 425, 141, 64, 60, 100 }
	game_use_value["sufei_qun"] = { 425, 141, 64, 60, 100 }
	game_use_value["tangzi_wu"] = { 437, 110, 54, 69, 100 }
	game_use_value["tangzi_wei"] = { 437, 110, 54, 69, 100 }
	local defult_value = { 400, 100, 60, 60, 100 }
	return game_use_value,defult_value
end
