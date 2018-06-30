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
		if general:endsWith("_shu") or general:endsWith("_wei") or general:endsWith("_wu") or general:endsWith("_qun") then
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