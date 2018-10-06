--自动更换皮肤（数值定义在default_skins.lua中）
function getSkinId(general_name)
	local skin_id = DefaultSkins[general_name]
	if not skin_id then skin_id = DefaultSkins[string.lower(general_name)] end
	if not skin_id then skin_id = DefaultSkins[string.gsub(general_name, "Lyu", "Lv")] end
	if not skin_id then skin_id = DefaultSkins[string.lower(string.gsub(general_name, "Lyu", "Lv"))] end
	if type(skin_id) == "table" then
		skin_id = skin_id[math.random(1, #skin_id)]
	end
	return skin_id
end
function setSkinId(player, isHead, reset, notifySelf, notifySelfOnly)
	local room = player:getRoom()
	if player:getState() == "robot" and not EnableDefaultSkinsForAI then return end
	
	local function setProperty(property_name, data)
		if notifySelfOnly then
			player:setProperty(property_name, data)
			room:notifyProperty(player, player, property_name)
		elseif notifySelf then
			room:setPlayerProperty(player, property_name, data)
		else
			player:setProperty(property_name, data)
			for _,p in sgs.qlist(room:getOtherPlayers(player, true)) do
				room:notifyProperty(p, player, property_name)
			end
		end
	end
	
	if isHead and player:getGeneral() then
		local skin_id = getSkinId(player:getActualGeneral1Name())
		if skin_id then
			assert(type(skin_id) == "number")
			local current_skin_id = player:property("head_skin_id"):toInt()
			if skin_id > 0 and (not current_skin_id or skin_id ~= current_skin_id) then
				setProperty("head_skin_id", sgs.QVariant(skin_id))
			elseif reset and not (current_skin_id and skin_id == current_skin_id and skin_id ~= 0) then
				setProperty("head_skin_id", sgs.QVariant(0))
			end
		elseif reset then
			setProperty("head_skin_id", sgs.QVariant(0))
		end
	elseif not isHead and player:getGeneral2() then
		local skin_id = getSkinId(player:getActualGeneral2Name())
		if skin_id then
			assert(type(skin_id) == "number")
			local current_skin_id = player:property("deputy_skin_id"):toInt()
			if skin_id > 0 and (not current_skin_id or skin_id ~= current_skin_id) then
				setProperty("deputy_skin_id", sgs.QVariant(skin_id))
			elseif reset and not (current_skin_id and skin_id == current_skin_id and skin_id ~= 0) then
				setProperty("deputy_skin_id", sgs.QVariant(0))
			end
		elseif reset then
			setProperty("deputy_skin_id", sgs.QVariant(0))
		end
	end
end
UseDefaultSkin = sgs.CreateTriggerSkill{
	name = "UseDefaultSkin",
	global = true,
	events = {sgs.GameStart, --[[sgs.GeneralRemoved,]] sgs.DFDebut--[[, sgs.GeneralShown]]},
	priority = -1,  --先进行君主替换和武将替换
	on_record = function(self, event, room, player, data)  --特别注意：国战第一次触发GameStart是系统触发没有player，而第二次能靠玩家触发GameStart就已经发完牌了，所以只能在第一次player=nil时执行；而即使can_trigger返回技能名，也需要玩家去点击发动，也就导致on_cost和on_effect都是废物，因此只能把一切放到can_trigger
		if not EnableDefaultSkins or not DefaultSkins then return end
		if event == sgs.GameStart then
			if (player ~= nil) then return end
			if room:getTag("UseDefaultSkinInvoked"):toBool() then return end
			
			for _,player in sgs.qlist(room:getAllPlayers()) do
				setSkinId(player, true, false, true)
				setSkinId(player, false, false, true)
			end
			room:setTag("UseDefaultSkinInvoked", sgs.QVariant(true))
		--[[elseif event == sgs.GeneralRemoved and player:isAlive() then  --防止飞龙发动导致新武将变成士兵
			if string.find(player:getActualGeneral1Name(), "sujiang") then
				setSkinId(player, true, true)
				player:setFlags("GeneralRemovedHead")
			end
			if player:getGeneral2() and string.find(player:getActualGeneral2Name(), "sujiang") then
				setSkinId(player, false, true)
				player:setFlags("GeneralRemovedDeputy")
			end]]
		elseif event == sgs.DFDebut then
			if player:getGeneral() and player:hasShownGeneral1() then
				--setSkinId(player, true, true, false)
				setSkinId(player, true, true, true)
			elseif player:getGeneral() and not player:hasShownGeneral1() then  --一统天下
				setSkinId(player, true, true, true, true)
			end
			if player:getGeneral2() and player:hasShownGeneral2() then
				--setSkinId(player, false, true, false)
				setSkinId(player, false, true, true)
			elseif player:getGeneral2() and not player:hasShownGeneral2() then  --一统天下
				setSkinId(player, false, true, true, true)
			end
		--[[elseif event == sgs.GeneralShown then  --变副将（失败）
			if player:getGeneral() and player:hasFlag("GeneralRemovedHead") and not string.find(player:getActualGeneral1Name(), "sujiang") then
				setSkinId(player, true, true, true)
				player:setFlags("-GeneralRemovedHead")
			end
			if player:getGeneral2() and player:hasFlag("GeneralRemovedDeputy") and not string.find(player:getActualGeneral2Name(), "sujiang") then
				setSkinId(player, false, true, true)
				player:setFlags("-GeneralRemovedDeputy")
			end]]
		end
	end,
}
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("UseDefaultSkin") then skills:append(UseDefaultSkin) end
sgs.Sanguosha:addSkills(skills)