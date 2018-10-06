
extension = sgs.Package("luaba", sgs.Package_GeneralPack)            
bayuanshu = sgs.General(extension, "bayuanshu", "qun", 4) 
bayongsi=sgs.CreateTriggerSkill{
	frequency = sgs.Skill_Compulsory, --锁定技
	
	name = "bayongsi",
	can_preshow = true,
	events={sgs.DrawNCards,sgs.EventPhaseStart}, --两个触发时机
	can_trigger=function(self,event,room,player,data)
		if (event==sgs.EventPhaseStart) and (player:getPhase()~=sgs.Player_Discard) then
			return ""
		end
		if table.contains(self:TriggerSkillTriggerable(event, room, player, data, player), self:objectName()) then
			return self:objectName()
		else
			return ""
		end
	end,
	on_cost=function(self,event,room,player,data)
		if (player:hasShownSkill(self) or player:askForSkillInvoke(self:objectName())) then
            room:broadcastSkillInvoke(self:objectName())
            return true
        else
			return false
		end
	end,
	on_effect=function(self,event,room,player,data)
		--local room=player:getRoom()
		
		local getKingdoms=function() --可以在函数中定义函数，本函数返回存活势力的数目
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
		
		if event==sgs.DrawNCards then 
			--摸牌阶段，改变摸牌数
			--room:playSkillEffect("bayongsi")
			data:setValue(data:toInt()+getKingdoms()) 
			--DrawNCards事件的data是一个int类型的QVariant即摸牌数，改变该QVariant对象会改变摸牌数
		elseif (event==sgs.EventPhaseStart) and (player:getPhase()==sgs.Player_Discard) then
			--进入弃牌阶段时，先执行庸肆弃牌，然后再执行常规弃牌
			local x = getKingdoms()
			local e = player:getEquips():length()+player:getHandcardNum()
			if e>x and x>0 then 
				room:askForDiscard(player,"@bayongsi-discard",x,x,false,true) 
			--要求玩家弃掉一些牌
			-- 最后两个参数为”是否强制“以及”是否包含装备“
			elseif x>0 then
			--如果玩家的牌未达到庸肆的弃牌数目，那么跳过询问全部弃掉
				player:throwAllHandCards()
				player:throwAllEquips()
			end
		end
	end
}
sgs.LoadTranslationTable{
	["luaba"] = "sp包",
	["bayuanshu"] = "袁术",
	["#bayuanshu"] = "仲家帝",
	["bayongsi"] = "庸肆",
	[":bayongsi"] = "锁定技，摸牌阶段，你额外摸X张牌，X为场上已亮明势力数。弃牌阶段，你至少须弃掉等同于场上已亮明势力数的牌（不足则全弃）。",
	["@bayongsi-discard"] = "你至少须弃掉等同于场上已亮明势力数的牌",
}
bayuanshu:addSkill(bayongsi)
bayuanshu:addCompanion("jiling")