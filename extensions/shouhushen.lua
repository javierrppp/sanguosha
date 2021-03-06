extension = sgs.Package("shouhushen", sgs.Package_GeneralPack)

local sendMsg = function(room,message)
	local msg = sgs.LogMessage()
	msg.type = "#message"
	msg.arg = message
	room:sendLog(msg)
end
shijiu = sgs.CreateTriggerSkill{  
	name = "shijiu" ,
	limit_mark = "@shijiuMark",
	frequency = sgs.Skill_Limited,
	events = {sgs.Dying} ,
	can_trigger = function(self, event, room, player, data)
		local room = player:getRoom()
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		local dying = data:toDying()
		local to = dying.who
		if to:getMark("@shouhu") == 0 then return "" end
		if to:objectName() == player:objectName() then return "" end
		if player:hasShownOneGeneral() and player:getMark("@shijiuMark") > 0 and player:getKingdom() == to:getKingdom() then
			return self:objectName()
		end
		--[[for _, p in sgs.qlist(room:getOtherPlayers(to)) do
			if p:getRole() ~= "careerist" and p:getMark("@shijiuMark") > 0 and p:getKingdom() == to:getKingdom() then
				return self:objectName(), p
			end
		end--]]
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if ask_who:askForSkillInvoke(self:objectName(), data) then
			--room:broadcastSkillInvoke(self:objectName(), ask_who)
			return true
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		ask_who:loseMark("@shijiuMark")
		local dying = data:toDying()
		room:loseHp(ask_who)
		local hp = dying.who:getHp()
		local recover_hp = 1 - hp
		local recover = sgs.RecoverStruct()
		recover.who = ask_who
		recover.recover = recover_hp
		room:recover(dying.who, recover)
	end
}	
shouhu = sgs.CreateTriggerSkill{  
	name = "shouhu" ,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart, sgs.Damaged} ,
	can_trigger = function(self, event, room, player, data)
		local room = player:getRoom()
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		if event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_Start then return "" end
		end
	--[[	return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		return true
	end,
	on_effect = function(self, event, room, player, data,ask_who)--]]
		--room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		local lose_skill_str = player:getTag("shouhuSkillTag"):toString()
		if lose_skill_str and player:hasSkill(lose_skill_str) then
			room:detachSkillFromPlayer(player,lose_skill_str)
		end
		local skill_list_str
		local skill_list
		local head = true 
		if not player:hasShownGeneral1() then
			head = false
		end
		if player:getKingdom() == "shu" then
			skill_list_str = "rende+paoxiao+wusheng+liegong+tieqi+kuanggu+zaiqi+longdan+jizhi+kongcheng+shoucheng+fangquan"
		elseif player:getKingdom() == "wei" then
			skill_list_str = "jianxiong+fankui+tiandu+qingguo+xingshang+xiaoguo+duanliang+ganglie+luoyi+qiaobian"
		elseif player:getKingdom() == "wu" then
			skill_list_str = "zhiheng+qixi+keji+duanbing+yinghun_sunjian+yingzi_zhouyu+liuli+tianxiang+yicheng+qianxun"
		elseif player:getKingdom() == "qun" then
			skill_list_str = "leiji+shuangxiong+weimu+sijian+biyue+wushuang+mengjin+lirang+kuangfu+shuangren"
		end
		skill_list = skill_list_str:split("+")
		for _, skill in sgs.qlist(player:getSkillList()) do 
			if table.contains(skill_list, skill:objectName()) then
				table.removeOne(skill_list, skill:objectName())
			end
		end
		local randomNum = math.random(1,#skill_list)
		local skill_str = skill_list[randomNum]
		sendMsg(room, "skill:"..skill_str)
		room:acquireSkill(player, skill_str,true, head)
		player:setTag("shouhuSkillTag", sgs.QVariant(skill_str))
		return ""
	end,
	priority = -100
}
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("shijiu") then skills:append(shijiu) end
if not sgs.Sanguosha:getSkill("shouhu") then skills:append(shouhu) end
sgs.Sanguosha:addSkills(skills)
sgs.LoadTranslationTable{
	["shouhushen"] = "守护包",
	["shijiu"] = "施救",
	[":shijiu"] = "限定技，当你的守护者濒死时，若你已经亮出武将牌，你可以失去一点体力，然后令守护者的体力值回复至一点。",
	["shouhu"] = "守护",
	[":shouhu"] = "锁定技，回合开始时，你根据势力随机获得以下技能（无法获得已有的技能）：蜀，仁德、咆哮、武圣、烈弓、铁骑、龙胆、狂骨、再起、集智、空城、守城、放权；魏，奸雄、反馈、天妒、倾国、行殇、骁果、断粮、刚烈、裸衣、巧变；吴，制衡、奇袭、克己、短兵、英魂、英姿、流离、天香、疑城、谦逊；群雄，雷击、双雄、帷幕、死谏、闭月、无双、猛进、礼让、狂斧、双刃。你受到伤害后，重置获得的技能。",
	["zhujiang"] = "主将",
	["fujiang"] = "副将",
	["#message"] = "%arg",
	["@shouhu"] = "守护",
	["@shijiuMark"] = "施救",
}
return {extension}