
extension=sgs.Package("study", sgs.Package_GeneralPack)

anni =sgs.General(extension, "anni", "wei", 4, false)
kate=sgs.General(extension, "kate", "wei", 4, false)
xueer =sgs.General(extension, "xueer", "wei", 4, false)
shanni =sgs.General(extension, "shanni", "wei", 5, false)
shuiyan=sgs.General(extension, "shuiyan", "wei", 3, false)
yaoyao = sgs.General(extension, "yaoyao", "shu", 4, false)
youxue = sgs.General(extension, "youxue", "shu", 4, false)
xinghun=sgs.General(extension, "xinghun", "shu", 2, false)
yanpo=sgs.General(extension, "yanpo", "shu", 4, false)
xinxin=sgs.General(extension, "xinxin", "shu", 4, false)
yanyan=sgs.General(extension, "yanyan", "shu", 4, false)
lanyin=sgs.General(extension, "lanyin", "wu", 4, false)
shali=sgs.General(extension, "shali", "wu", 3, false)
dieer=sgs.General(extension, "dieer", "wu", 3, false)
youyue=sgs.General(extension, "youyue", "wu", 5, false)
yueya=sgs.General(extension, "yueya", "wu", 3, false)
momo=sgs.General(extension, "momo", "qun", 4, false)
lingming=sgs.General(extension, "lingming", "qun", 4, false)
yanmo=sgs.General(extension, "yanmo", "qun", 3, false)
youyue:setDeputyMaxHpAdjustedValue(-1)
lord_yanyan = sgs.General(extension, "lord_yanyan$", "shu", 4, false, true)
yanyan:addCompanion("xinxin")
lord_xueer = sgs.General(extension, "lord_xueer$", "wei", 3, false, true)
lord_momo=sgs.General(extension, "lord_momo$", "qun", 4, false, true)
lord_lanyin=sgs.General(extension, "lord_lanyin$", "wu", 4, false, true)

hunyanCard = sgs.CreateSkillCard{
	name = "hunyanCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return (#targets==0)  and (not to_select:isKongcheng()) 
	end,
	extra_cost = function(self, room, use)
		local pd = sgs.PindianStruct()
		pd = use.from:pindianSelect(use.to:first(), "hunyan")
		local d = sgs.QVariant()
		d:setValue(pd)
		use.from:setTag("hunyan_pd",d)
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local source = effect.from
		local target = effect.to
		local pd = source:getTag("hunyan_pd"):toPindian()
		source:removeTag("hunyan_pd")
		if pd then
		  local success = source:pindian(pd)
		  if success then
		     local rec=sgs.RecoverStruct()
             rec.recover=1
	         rec.who=source
	         room:recover(source,rec)
		  elseif pd.from_number < pd.to_number then
		    local rec=sgs.RecoverStruct()
             rec.recover=1
	         rec.who=source
	         room:recover(target,rec)
		  end
		end
	end
}
hunyan = sgs.CreateZeroCardViewAsSkill{
	name = "hunyan",
	can_preshow = false,
	view_as = function(self, cards) 
		return hunyanCard:clone()
	end, 
	enabled_at_play = function(self, player)	    
		return player:isWounded() and not player:isKongcheng()
	end, 
}
moyi = sgs.CreateTriggerSkill{
		name = "moyi" ,
		frequency = sgs.Skill_Compulsory,
		events = {sgs.SlashProceed} ,
		can_trigger=function(self,event,room,player,data)
		local yanpo=room:findPlayerBySkillName(self:objectName())
		local use = data:toSlashEffect()
			if (use.from:objectName()==yanpo:objectName() and yanpo:isWounded() and not use.to:isWounded()) then return self:objectName() end
		end,
		on_cost= function(self, event, room, player, data,ask_who)		
        return true
        end,
        on_effect = function(self, event, room, player, data,ask_who)
		    local yanpo=room:findPlayerBySkillName(self:objectName())
            local effect = data:toSlashEffect()
			room:slashResult(effect,nil)
			return true
		end
}
moyimod=sgs.CreateTargetModSkill{
    name = "#moyimod" ,
	distance_limit_func = function(self, from)
		if from:isWounded() and from:hasSkill(self:objectName()) then
			return 1000
		else
			return 0
		end
	end
}
shuiyue = sgs.CreateTriggerSkill{
name="shuiyue",
frequency = sgs.Skill_Compulsory,
events={sgs.DamageForseen},
can_trigger=function(self,event,room,player,data)
	local damage=data:toDamage()
	if damage.nature==sgs.DamageStruct_Fire and (damage.to:hasShownSkill(self:objectName()) or damage.from:hasShownSkill(self:objectName())) then
	return self:objectName()
	end
end,
on_cost= function(self, event, room, player, data,ask_who)
  return true
end,
on_effect = function(self, event, room, player, data,ask_who)
  return true
end 
}
yuanan=sgs.CreateTriggerSkill{
name="yuanan",
frequency = sgs.Skill_NotFrequent,
events={sgs.CardsMoveOneTime},
can_trigger=function(self,event,room,player,data)
local shuiyan=room:findPlayerBySkillName(self:objectName())
 local current = room:getCurrent()
	  local move = data:toMoveOneTime()
	  local source = move.from
	  local flag= bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
	  if source and flag==sgs.CardMoveReason_S_REASON_DISCARD and shuiyan==player and (move.to_place == sgs.Player_DiscardPile) and current:getPhase()==sgs.Player_Discard and source:objectName()==current:objectName() and source:objectName()==shuiyan:objectName() and move.card_ids:length()>=3 then
	     return self:objectName(),shuiyan
	  end
end,
on_cost= function(self, event, room, player, data,ask_who)
  if room:askForSkillInvoke(ask_who,self:objectName(),data) then
  return true
  end
end,
on_effect = function(self, event, room, player, data,ask_who)
  local shuiyan=room:findPlayerBySkillName(self:objectName())
  local move = data:toMoveOneTime()
  for i = 0, move.card_ids:length()-1, 3 do
     local list=room:getAlivePlayers()
     local who=room:askForPlayerChosen(shuiyan,list,self:objectName())
	 local rec=sgs.RecoverStruct()
     rec.recover=1
	 rec.who=who
	 room:recover(who,rec)
	 if not who:isFriendWith(shuiyan) then shuiyan:drawCards(1,self:objectName()) end
  end
  return true
end 
}

kuiyanCard = sgs.CreateSkillCard{
	name = "kuiyanCard",
	skill_name = "kuiyan",
	target_fixed = true,
	about_to_use = function(self, room, cardUse)
		room:removePlayerMark(cardUse.from, "@rescue")
		room:broadcastSkillInvoke("kuiyan", cardUse.from)
		self:cardOnUse(room, cardUse)
	end,
	on_use = function(self, room, source, targets)
		local list=room:getOtherPlayers(source)
		for _,from in sgs.qlist(list) do
		  local card_id = room:askForCardChosen(source,from, "he", self:objectName())
		  if card_id then 
	      local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, source:objectName())
		  room:obtainCard(source, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
		  else 
		    room:loseHp(from)
		  end
		end
		
	end
}
kuiyanVS = sgs.CreateZeroCardViewAsSkill{
	name = "kuiyan",
	view_as = function(self)
		local card = kuiyanCard:clone()
		card:setSkillName(self:objectName())
		card:setShowSkill(self:objectName())
		return card
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@rescue") >= 1
	end,
}
kuiyan = sgs.CreateTriggerSkill{
	name = "kuiyan",
	frequency = sgs.Skill_Limited,
	limit_mark = "@rescue",
	view_as_skill = kuiyanVS,
}



juejue=sgs.CreateTriggerSkill{
name="juejue",
frequency = sgs.Skill_NotFrequent,
events={sgs.Death,sgs.EventPhaseStart},
can_trigger=function(self,event,room,player,data)
  local yanmo=room:findPlayerBySkillName(self:objectName())
  if event==sgs.EventPhaseStart and yanmo:getPhase()==sgs.Player_Finish and yanmo:faceUp() and yanmo==player and yanmo:hasShownSkill(self:objectName()) then
    return self:objectName(),yanmo
  end
  if event==sgs.Death and yanmo:isAlive() and player:objectName()==yanmo:objectName() and yanmo:getPhase()==sgs.Player_NotActive then
    return self:objectName(),yanmo
  end
  return ""
  end,
on_cost= function(self, event, room, player, data,ask_who) 
local yanmo=room:findPlayerBySkillName(self:objectName()) 
  if event==sgs.Death and room:askForSkillInvoke(yanmo,self:objectName(),data) then
     return true
  end	
   if event==sgs.EventPhaseStart and room:askForSkillInvoke(yanmo,"diezhi",data)   then
  return true 
  end
  return false
end,
on_effect = function(self, event, room, player, data,ask_who)
  local yanmo=room:findPlayerBySkillName(self:objectName())
  if event==sgs.EventPhaseStart then
    yanmo:turnOver()
  end
  if event==sgs.Death then
    yanmo:drawCards(3,self:objectName())
	if yanmo:faceUp() then
	  yanmo:turnOver()
	end
  end
end
}
juejueg = sgs.CreateTriggerSkill{
    name = "#juejueg",  
	frequency = sgs.Skill_Compulsory,  
	events = {sgs.DamageForseen},  
	can_trigger=function(self,event,room,player,data)
	  local damage = data:toDamage() 
	  local yanmo=room:findPlayerBySkillName("juejue")
	  if damage.to:objectName()==yanmo:objectName() and not yanmo:faceUp() and yanmo:hasShownSkill("juejue") then
	    return self:objectName(),yanmo
	  end
	  return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
	  return true
	end ,	
	on_effect = function(self, event, room, player, data,ask_who)
	local damage = data:toDamage() 
	 local yanmo=room:findPlayerBySkillName("juejue")
	  if damage.to:objectName()==yanmo:objectName() and not yanmo:faceUp() and yanmo:hasShownSkill("juejue") then 
	    return true
	  else return false end
	end
}
guwei = sgs.CreateTriggerSkill{
    name = "guwei",  
	frequency = sgs.Skill_Limited, 
    limit_mark = "@guwei_use",	
	events = {sgs.EventPhaseStart},  
	can_trigger=function(self,event,room,player,data)
	 local yanmo=room:findPlayerBySkillName(self:objectName())	
     if  yanmo:getPhase()==sgs.Player_Start and player:objectName()==yanmo:objectName() and yanmo:hasShownSkill(self:objectName()) and yanmo:getMark("@guwei_use")>0 then
	   local list=room:getOtherPlayers(yanmo)
	   local can_use=true
	   for _,p in sgs.qlist(list) do
	     if not p:hasShownOneGeneral() then 
		   can_use=false 
		 end
	     if p:getKingdom()==yanmo:getKingdom() and p:isFriendWith(yanmo) then		 
		   can_use=false
		 end
	   end
	   if can_use then
         return self:objectName(),yanmo
	   else
	   return ""
	   end
	 end
	 return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
	local yanmo=room:findPlayerBySkillName(self:objectName())
	if room:askForSkillInvoke(yanmo,self:objectName(),data) then
	    yanmo:loseAllMarks("@guwei_use")
		room:broadcastSkillInvoke(self:objectName(), 1)
	  return true
	end
	  return false
	end ,	
	on_effect = function(self, event, room, player, data,ask_who)
	local yanmo=room:findPlayerBySkillName(self:objectName())
	 for _, card in sgs.qlist(yanmo:getJudgingArea()) do
		  room:throwCard(card,nil)
	end
	 local mhp=sgs.QVariant()			  
	  local count=yanmo:getMaxHp()			  
	  mhp:setValue(count+1)			  
	  room:setPlayerProperty(yanmo,"maxhp",mhp)	  
	    local rec=sgs.RecoverStruct()
		rec.recover=yanmo:getMaxHp()-yanmo:getHp()
		rec.who=yanmo
	    room:recover(yanmo,rec)
		room:handleAcquireDetachSkills(yanmo, "wusheng")
		room:handleAcquireDetachSkills(yanmo, "moyv")
	  return true
	end
}
moyv=sgs.CreateTargetModSkill{
    name = "moyv" ,
	residue_func = function(self, from)
		if not from:isWounded() and from:hasSkill(self:objectName()) then
			return 1000
		else
			return 0
		end
	end ,
	distance_limit_func = function(self, from)
		if not from:isWounded() and from:hasSkill(self:objectName()) then
			return 1000
		else
			return 0
		end
	end
}
local skillList = sgs.SkillList()
if not sgs.Sanguosha:getSkill("moyv") then skillList:append(moyv) end
sgs.Sanguosha:addSkills(skillList)
diehun=sgs.CreateTriggerSkill{
name="diehun",
frequency = sgs.Skill_Compulsory,
events = {sgs.DamageForseen},
can_trigger=function(self,event,room,player,data)
    local dieer=room:findPlayerBySkillName(self:objectName())
	local damage=data:toDamage()
	if damage.from:isFriendWith(dieer)and damage.from:hasShownOneGeneral() and damage.to:objectName()==dieer:objectName() then
	  return self:objectName(),dieer end
	end,
  on_cost= function(self, event, room, player, data,ask_who)  
     return true
  end,
  on_effect = function(self, event, room, player, data,ask_who)
  	local damage = data:toDamage() 
	return true
  end
}
huanyueVS = sgs.CreateOneCardViewAsSkill{
	name = "huanyue", 
	filter_pattern = ".|.|.|tao",
	expand_pile = "tao",
	view_as = function(self, originalCard) 
		local peach = sgs.Sanguosha:cloneCard("peach", originalCard:getSuit(), originalCard:getNumber())
		peach:addSubcard(originalCard:getId())
		peach:setSkillName(self:objectName())
		return peach
	end, 
	enabled_at_play = function(self, player)
		return true
	end,
	enabled_at_response = function(self, player, pattern)
		return string.find(pattern, "peach") and (not player:getPile("tao"):isEmpty())
	end
}
huanyue=sgs.CreateTriggerSkill{
    name = "huanyue",
	events = {sgs.CardsMoveOneTime,sgs.Dying,sgs.EventPhaseChanging},	
	frequency = sgs.Skill_NotFrequent,
    view_as_skill=huanyueVS,
    can_trigger=function(self,event,room,player,data)
      local dieer=room:findPlayerBySkillName(self:objectName())
      if event==sgs.Dying and player==dieer and (not player:isKongcheng() or player:hasEquip()) then 	 
        return self:objectName(),dieer
      end
	  if event==sgs.EventPhaseChanging and dieer:hasShownSkill(self:objectName())then
	       local change = data:toPhaseChange()
		   local current=room:getCurrent()
		if change.to== sgs.Player_Start then 
				return self:objectName(),dieer
			end
	  end
      if event==sgs.CardsMoveOneTime then
	  local current = room:getCurrent()
	  local move = data:toMoveOneTime()
	  local source = move.from
	  local flag= bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
	  if source and flag==sgs.CardMoveReason_S_REASON_DISCARD and dieer==player and (move.to_place == sgs.Player_DiscardPile) and current:getPhase()==sgs.Player_Discard and source:objectName()==current:objectName() and source:objectName()==dieer:objectName() then
	     return self:objectName(),dieer
	  end
	  end	  
      return ""	
	  end,
     on_cost= function(self, event, room, player, data,ask_who) 
	 local dieer=room:findPlayerBySkillName(self:objectName())
	  if event==sgs.EventPhaseChanging then return true end
        if room:askForSkillInvoke(dieer,self:objectName(),data) then
          return true end
		  return false
     end,		  
	 on_effect = function(self, event, room, player, data,ask_who)
	 local dieer=room:findPlayerBySkillName(self:objectName())
	  if event==sgs.EventPhaseChanging then 	 
	    room:removePlayerCardLimitation(dieer, "use,response", "Peach|.|.|.$1")
	  end
	    if event==sgs.Dying then		   
	       local cards=sgs.Sanguosha:cloneCard("slash")
		   cards = room:askForExchange(dieer, self:objectName(), 1, 1, "yuecover", "", ""):getSubcards():first()
		   dieer:addToPile("tao", cards)
		   local _type = "Peach|.|.|."
		   room:setPlayerCardLimitation(dieer, "use,response", _type, true)
	    end
    if event==sgs.CardsMoveOneTime then
      local card
	  local move = data:toMoveOneTime()
	  local dummy = sgs.Sanguosha:cloneCard("jink")
	  local count=0
	    for i = 0, move.card_ids:length()-1, 1 do
	      local id = move.card_ids:at(i)
	      card = sgs.Sanguosha:getCard(id)
          if card:isKindOf("BasicCard") and count<=2 then		  
		    dummy:addSubcard(id)
			count=count+1
		  end
	    end
	    for _,id in sgs.qlist(dummy:getSubcards()) do
			move.card_ids:removeOne(id)
	    end	  
	    data:setValue(move)
        dieer:addToPile("tao", dummy:getSubcards())
	    dummy:deleteLater()
	  end
	 end
}	  

leiyingCard = sgs.CreateSkillCard{
	name = "leiyingCard",
	target_fixed = true,
	will_throw = false,
	on_use=function(self,room,source,targets)
	    local choice = room:askForChoice(source, self:objectName(), "all_recover+recover_to_full")
		if choice then
		  if choice=="recover_to_full" then
		    local rec=sgs.RecoverStruct()
		    rec.recover=source:getMaxHp()-source:getHp()
		    rec.who=source
	        room:recover(source,rec)
		  else
		    local list=room:getAlivePlayers()
		    for _,p in sgs.qlist(list) do
		      if source:getKingdom()==p:getKingdom() then
			    local rec=sgs.RecoverStruct()
		        rec.recover=1
		        rec.who=p
	            room:recover(p,rec)
			  end
		    end
		  end
		end
		source:gainMark("@lei",1)
	end,
}
leiying = sgs.CreateZeroCardViewAsSkill{
	name = "leiying$",
	can_preshow = false,
	view_as = function(self, cards) 
		return leiyingCard:clone()
	end, 
	enabled_at_play = function(self, player)	    
		return player:getMark("@lei")==1 and player:isWounded()
	end
}
zhongjue=sgs.CreateTriggerSkill{
  name="zhongjue",
  frequency = sgs.Skill_NotFrequent,
  events = {sgs.Death,sgs.GeneralShown},
  can_trigger=function(self,event,room,player,data)
    local lanyin=room:findPlayerBySkillName(self:objectName())
    if event==sgs.GeneralShown and player:objectName()==lanyin:objectName() then	
	  local zhu=lanyin:getGeneralName()
	  local fu=lanyin:getGeneral2Name()
	  if lanyin:hasShownGeneral1() and (zhu=="lanyin" or zhu=="lord_lanyin") then
	    return self:objectName(),lanyin		
	  end
	  if lanyin:hasShownGeneral2() and (fu=="lanyin" or fu=="lord_lanyin") then
	    return self:objectName(),lanyin
	  end
	end
	if event==sgs.Death and player:hasSkill(self:objectName()) and lanyin:isAlive() then
	  return self:objectName()
	end 
	return ""
end,
  on_cost= function(self, event, room, player, data,ask_who)  
    if event==sgs.GeneralShown then return true end
	 local lanyin=room:findPlayerBySkillName(self:objectName())
	if event==sgs.Death and room:askForSkillInvoke(lanyin,self:objectName(),data) then return true end
  end,
  on_effect = function(self, event, room, player, data,ask_who)
  local lanyin=room:findPlayerBySkillName(self:objectName())  
	  local zhu=lanyin:getGeneralName()
	  local fu=lanyin:getGeneral2Name()
    if event==sgs.GeneralShown then 
	   if (zhu=="lord_lanyin" or  fu=="lord_lanyin") and lanyin:getMark("@lei")==0 then lanyin:gainMark("@lei",1) end
	   if zhu=="lanyin" or zhu=="lord_lanyin"then
	   lanyin:removeGeneral(false)
	  end
	  if fu=="lanyin" or fu=="lord_lanyin" then
	    lanyin:removeGeneral(true)
	  end
	end
	if event==sgs.Death then
	  local choice = room:askForChoice(lanyin, self:objectName(), "draw+change+rec")
	  if choice=="rec" then
	    local rec=sgs.RecoverStruct()
		rec.recover=lanyin:getMaxHp()-lanyin:getHp()
		rec.who=lanyin
	    room:recover(lanyin,rec)
	  elseif choice=="draw" then
	    lanyin:drawCards(3,self:objectName())
	  else
	    local death=data:toDeath()
	    local targets={}
		table.insert(targets,death.who:getGeneralName())
		table.insert(targets,death.who:getGeneral2Name())
		local general=room:askForGeneral(lanyin, table.concat(targets, "+"))
		local target=sgs.Sanguosha:getGeneral(general)
		local skills=target:getVisibleSkillList()
		local skill_name={}
		for _,skill in sgs.qlist(skills) do
		  if not skill:inherits("SPConvertSkill") then
		  table.insert(skill_name,skill:objectName())
		  end
		end	
       local choices=table.concat(skill_name,"+")        
	local choice=room:askForChoice(lanyin,self:objectName(),choices)
room:handleAcquireDetachSkills(lanyin,choice,true)
	  end
	end
  end
  }
  
 lanyin:addSkill(zhongjue)

shenjiangCard = sgs.CreateSkillCard{
	name = "shenjiangCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return (#targets==0) and (to_select:getHp()>sgs.Self:getHp()) and (not to_select:isKongcheng()) 
	end,
	extra_cost = function(self, room, use)
		local pd = sgs.PindianStruct()
		pd = use.from:pindianSelect(use.to:first(), "Shenjiang")
		local d = sgs.QVariant()
		d:setValue(pd)
		use.from:setTag("shenjiang_pd",d)
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local source = effect.from
		local target = effect.to
		local pd = source:getTag("shenjiang_pd"):toPindian()
		source:removeTag("shenjiang_pd")
		if pd then
		  local success = source:pindian(pd)
		  if success then
			room:handleAcquireDetachSkills(source, "wansha")
			source:setFlags("getshuang")
		  else
			room:handleAcquireDetachSkills(source, "qiancai")
			source:setFlags("getqian")
		  end
		end
	end
}
shenjiang = sgs.CreateZeroCardViewAsSkill{
	name = "shenjiang$",
	can_preshow = false,
	view_as = function(self, cards) 
		return shenjiangCard:clone()
	end, 
	enabled_at_play = function(self, player)	    
		return (not player:hasUsed("#shenjiangCard")) and not player:isKongcheng()
	end, 
}
shenjianglose=sgs.CreateTriggerSkill{
	name = "shenjiang$",
	events = {sgs.EventPhaseStart},	
	frequency = sgs.Skill_NotFrequent,
    view_as_skill=shenjiang,
     can_trigger=function(self,event,room,player,data)
     local momo=room:findPlayerBySkillName(self:objectName())
    if (momo:getPhase()==sgs.Player_Start or momo:getPhase()==sgs.Player_Finish) and momo==player then
	return self:objectName(), momo
	end 
	return ""
  end,	
  on_cost= function(self, event, room, player, data,ask_who)
  return true
  end,
	on_effect = function(self, event, room, player, data,ask_who)
      local momo=room:findPlayerBySkillName(self:objectName())
	  local phase=momo:getPhase()	  
	  if phase==sgs.Player_Start then	
		if momo:hasSkill("qiancai") then
		 room:handleAcquireDetachSkills(momo, "-qiancai")
		end
	  elseif phase==sgs.Player_Finish then
	  if momo:hasSkill("wansha") then
		  room:handleAcquireDetachSkills(momo,"-wansha")
		end
	    end
      end
}
lveying=sgs.CreateTriggerSkill{
  name="lveying$",
  frequency = sgs.Skill_NotFrequent,
  events = {sgs.EventPhaseStart},
  can_trigger=function(self,event,room,player,data)
    local yanyan=room:findPlayerBySkillName(self:objectName())
    if not yanyan:getPile("yue"):isEmpty() and yanyan:getPhase()==sgs.Player_Start and not yanyan:getJudgingArea():isEmpty() then
	return self:objectName(),yanyan
	end return ""
  end,
  on_cost = function(self, event, room, player, data,ask_who)
    if room:askForSkillInvoke(ask_who,self:objectName(),data) then return true else return false end
  end,
  on_effect = function(self, event, room, player, data,ask_who)
    local yanyan=room:findPlayerBySkillName(self:objectName())
    room:throwCard(sgs.Sanguosha:getCard(yanyan:getPile("yue"):first()), reason, nil)
    for _, card in sgs.qlist(yanyan:getJudgingArea()) do
		  room:throwCard(card,nil)
	end
  end
}
lveyinghand=sgs.CreateMaxCardsSkill{
name="#lveyinghand",
extra_func = function(self, player)
   local extra = 0
		local players = player:getSiblings()
		for _,p in sgs.qlist(players) do
			if p:isAlive() and (p:hasShownGeneral1()or p:hasShownGeneral2())then
				if p:getKingdom() == "shu" then
					extra = extra -1
				end
			end
		end
		if player:hasSkill(self:objectName()) then
			return extra-1
		end
end
}
shenyue=sgs.CreateTriggerSkill{
  name="shenyue",
  frequency = sgs.Skill_NotFrequent,
  events = {sgs.CardsMoveOneTime, sgs.TargetConfirming,sgs.CardFinished},
  can_trigger=function(self,event,room,player,data)
     local yanyan=room:findPlayerBySkillName(self:objectName())
	  if event==sgs.CardFinished and  yanyan:hasFlag("shenyueing") then
	    return self:objectName()
	  end
	  if event==sgs.CardsMoveOneTime  and player:hasSkill(self:objectName())then
	  local current = room:getCurrent()
	  local move = data:toMoveOneTime()
	  local source = move.from
	  local flag= bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
	  if source and flag==sgs.CardMoveReason_S_REASON_DISCARD and player:hasSkill(self:objectName()) and (move.to_place == sgs.Player_DiscardPile) and current:getPhase()==sgs.Player_Discard and source:objectName()==current:objectName() and source:objectName()==player:objectName() then
	     return self:objectName()
	  end
	  end
	  if event == sgs.TargetConfirming then
	    local use = data:toCardUse()	
	    if (use.card:isKindOf("Slash") or use.card:isNDTrick()) and not yanyan:getPile("yue"):isEmpty() and not yanyan:hasFlag("shenyueing")then  return self:objectName(),yanyan  end
	  end
	  return ""
	end,
 	on_cost = function(self, event, room, player, data,ask_who)
	local yanyan=room:findPlayerBySkillName(self:objectName())
	if event==sgs.CardFinished then
	  return true
	elseif event == sgs.TargetConfirming then 
	   if room:askForSkillInvoke(yanyan,self:objectName(),data) then 	   
	   return true 
	   else
	     local use = data:toCardUse()
		 if use.to:length()>1 then
	       room:setPlayerFlag(yanyan,"shenyueing") 		  
		 end
		 return false
	   end
	elseif event == sgs.CardsMoveOneTime and room:askForSkillInvoke(yanyan,self:objectName(),data) then 
	  return true 
	 end 
	 return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
	local yanyan=room:findPlayerBySkillName(self:objectName())
	if event==sgs.CardFinished then
	  room:setPlayerFlag(yanyan,"-shenyueing")
	end
	if event==sgs.CardsMoveOneTime then
	  local card
	  local move = data:toMoveOneTime()
	  local dummy = sgs.Sanguosha:cloneCard("jink")
	  for i = 0, move.card_ids:length()-1, 1 do
	    local id = move.card_ids:at(i)
	    card = sgs.Sanguosha:getCard(id)	  
		dummy:addSubcard(id)
	  end
	  for _,id in sgs.qlist(dummy:getSubcards()) do
			move.card_ids:removeOne(id)
	  end
	  
	  data:setValue(move)
      yanyan:addToPile("yue", dummy:getSubcards())
	  dummy:deleteLater()		
	elseif event == sgs.TargetConfirming then
	  local use = data:toCardUse()	 
	  if (use.card:isKindOf("Slash") or use.card:isNDTrick()) and not yanyan:getPile("yue"):isEmpty() then
	    if use.to:length()==1 then
		  local nullified_list = use.nullified_list
		  for _, p in sgs.qlist(use.to) do
			table.insert(nullified_list, p:objectName())
		  end
		  use.nullified_list = nullified_list
		  data:setValue(use)  
		  room:throwCard(sgs.Sanguosha:getCard(yanyan:getPile("yue"):first()), reason, nil)
	      return false
		elseif use.to:length()>1 then
		      local current = room:getCurrent()
		      if not yanyan:hasFlag("shenyueing") then
		        local nullified_list = use.nullified_list
		        for _, p in sgs.qlist(use.to) do
			      table.insert(nullified_list, p:objectName())
		        end
			    use.nullified_list = nullified_list
		        data:setValue(use)  
		        room:throwCard(sgs.Sanguosha:getCard(yanyan:getPile("yue"):first()), reason, nil)
	            yanyan:drawCards(1,self:objectName())	
			  end
			  room:setPlayerFlag(yanyan,"shenyueing")
	    end
	  end
	end
  end
}
yanyan:addSkill(shenyue)
lord_yanyan:addSkill(shenyue)
lord_yanyan:addSkill(lveying)
lord_yanyan:addSkill(lveyinghand)
extension:insertRelatedSkills("lveying", "#lveyinghand")
juepanCard=sgs.CreateSkillCard{
    name = "juepanCard",
	target_fixed = false,
	filter = function(self, targets, to_select)	
	  local can_die=true	
	  if(to_select:objectName() == sgs.Self:objectName()) then can_die=false end	  
	  return can_die
	end,
	feasible = function(self, targets, Self)	   
		return #targets == 1 and not targets[1]:hasShownSkill(self:objectName())
	end ,
	on_effect = function(self, effect)
	    local room=effect.to:getRoom()		
		local player=room:findPlayerBySkillName("juepan")
		if effect.to then    
		  player:loseMark("@pan",6)
		  room:killPlayer(effect.to)
	    end
	end	
}
juepan=sgs.CreateZeroCardViewAsSkill{
    name = "juepan",
	n = 0,
	can_preshow = true,
	view_filter = function(self, selected, to_select)
		return false
	end,
	view_as = function(self, cards)
		local card=juepanCard:clone()
		card:setSkillName(self:objectName())
		return card
	end,
	enabled_at_play = function(self, player)	    
		return player:getMark("@pan")>=6 
	end
}
juepanget=sgs.CreateTriggerSkill{
  name = "juepanget",
  frequency = sgs.Skill_NotFrequent,
  events = {sgs.EventPhaseStart,sgs.Damaged},
  can_trigger=function(self,event,room,player,data)
      local xinxin=room:findPlayerBySkillName(self:objectName())
	  if event==sgs.Damaged then
	    local damage = data:toDamage() 	    
	    if damage.to==xinxin  then
	      return self:objectName(),xinxin
		end
	  end
	  if event==sgs.EventPhaseStart then
	    local phase=xinxin:getPhase()
	    if phase==sgs.Player_Finish or (phase==sgs.Player_Start and xinxin:isKongcheng()) then
		  return self:objectName(),xinxin
	    end
	  end
	end,
	on_cost = function(self, event, room, player, data,ask_who)
        local xinxin=room:findPlayerBySkillName(self:objectName())
		local phase=xinxin:getPhase()
		if event==sgs.EventPhaseStart and phase==sgs.Player_Finish and not xinxin:isKongcheng() and room:askForSkillInvoke(xinxin,self:objectName(),data) then
			room:broadcastSkillInvoke(self:objectName())
			return true
		end
		if event==sgs.EventPhaseStart and xinxin:isKongcheng() then
			room:broadcastSkillInvoke(self:objectName())
			return true
		end
		 if event==sgs.Damaged then return true end		 
		 return false
	end ,	
	on_effect = function(self, event, room, player, data,ask_who)
	 local xinxin=room:findPlayerBySkillName(self:objectName())
	  if event==sgs.Damaged then
	    local damage = data:toDamage()
	    local x = damage.damage
	    xinxin:gainMark("@pan",x)
        if xinxin:isKongcheng() and room:askForSkillInvoke(xinxin,self:objectName(),data) then
          xinxin:drawCards(2,self:objectName())
        end		
	    return false
	  end 
	if event==sgs.EventPhaseStart then	 
		 xinxin:throwAllHandCards()
	     xinxin:gainMark("@pan",1)
	end
  end
}
qiancai=sgs.CreateTriggerSkill{
	name = "qiancai" ,
	frequency = sgs.Skill_NotFrequent ,
	events = {sgs.CardsMoveOneTime} ,
	can_trigger=function(self,event,room,player,data)
      local yaoyao=room:findPlayerBySkillName(self:objectName())
	   local move=data:toMoveOneTime()	   
	   local places=move.from_places
	   if move.from and move.from:objectName()==yaoyao:objectName() and yaoyao==player then     
	   if places:contains(sgs.Player_PlaceHand) or places:contains(sgs.Player_PlaceEquip) then 			
		if yaoyao:getPhase() == sgs.Player_NotActive then
		  return self:objectName(),yaoyao
		 end 
		 end 
		 end
	end,
    on_cost = function(self, event, room, player, data,ask_who)	
	 local yaoyao=room:findPlayerBySkillName(self:objectName())--询问技能发动
	   if  yaoyao:askForSkillInvoke(self:objectName(), data) then 	   
			room:broadcastSkillInvoke(self:objectName()) --播放配音
			return true 
		end
		return false --表示没有执行消耗，技能不执行
	end ,	
	on_effect = function(self, event, room, player, data,ask_who)
	local yaoyao=room:findPlayerBySkillName(self:objectName())
	   local move=data:toMoveOneTime()	   
	   if move.from and move.from:objectName()==yaoyao:objectName() then 
	     if yaoyao:getPhase() == sgs.Player_NotActive then
	       local places=move.from_places
	       if places:contains(sgs.Player_PlaceHand) or places:contains(sgs.Player_PlaceEquip) then 	 
			     room:drawCards(yaoyao,2,self:objectName())
			end
        end			
	end
end
}

zhiming = sgs.CreateTriggerSkill{
    name = "zhiming",  
	frequency = sgs.Skill_Compulsory,  
	events = {sgs.DamageForseen},  
	can_trigger=function(self,event,room,player,data)
	  local damage = data:toDamage() 
	  local yaoyao=room:findPlayerBySkillName(self:objectName())
	  if damage.to==yaoyao and damage.nature ~= sgs.DamageStruct_Normal then
	    return "zhiming",yaoyao
	  end
	  return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
	    local damage = data:toDamage() 	
		local room=player:getRoom()
        local yaoyao = room:findPlayerBySkillName("zhiming")	--	询问技能发动
			room:broadcastSkillInvoke(self:objectName()) --播放配音
			return true --表示技能已经消耗完成			
			--对于一些有消耗的触发技，比如神智，就要把弃置手牌放进来
	end ,	
	on_effect = function(self, event, room, player, data,ask_who)
	local damage = data:toDamage() 
	return damage.nature ~= sgs.DamageStruct_Normal
	end
}
moyu = sgs.CreateTriggerSkill{
	name = "moyu" ,
	events = {sgs.TargetConfirmed},
	frequency = sgs.Skill_NotFrequent,   
	on_cost = function(self, event, room, player, data,ask_who)	    
	    local use = data:toCardUse()
		local xueer=room:findPlayerBySkillName(self:objectName())		
		if use.from==xueer and use.from:hasShownSkill(self:objectName()) and use.card:isKindOf("Slash")then
			  if xueer:askForSkillInvoke(self:objectName(), data) then
			    room:broadcastSkillInvoke(self:objectName())
			    return true
		  end
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)	
        local xueer=room:findPlayerBySkillName(self:objectName())	
	    xueer:drawCards(2, self:objectName())				
		return false
	end
}

bayuanshu = sgs.General(extension, "bayuanshu", "qun", 4) 
yongsi=sgs.CreateTriggerSkill{
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
yinxue = sgs.CreateTriggerSkill{
    name = "yinxue" ,
	can_preshow = true,
	events={sgs.Damaged},
	frequency = sgs.Skill_NotFrequent,	
	can_trigger=function(self,event,room,player,data)
	   local xueer=room:findPlayerBySkillName(self:objectName())
	   local damage=data:toDamage()
	   if event==sgs.Damaged and damage.to==xueer then return self:objectName(),xueer end
	end,
	on_cost=function(self, event, room, player, data,ask_who)
	local xueer=room:findPlayerBySkillName(self:objectName())
		if (xueer:hasShownSkill(self) or xueer:askForSkillInvoke(self:objectName(), data)) then
            room:broadcastSkillInvoke(self:objectName())
            return true
        else
			return false
		end
	end,
	on_effect=function(self,event,room,player,data)
	local xueer=room:findPlayerBySkillName(self:objectName())
    if event==sgs.Damaged then
	    local damage = data:toDamage()
	    local x = damage.damage
	    xueer:gainMark("@xue",x)	
	  end	
	end
}
yinxuemod = sgs.CreateTargetModSkill{
	name = "#yinxuemod" ,
	pattern = "Slash",
	residue_func = function(self, from)
	  if from:hasSkill("yinxue") then
	    return from:getMark("@xue")
	  end
	end ,
}
mowang=sgs.CreateTriggerSkill{
    name = "mowang$" ,
	can_preshow = true,
	events={sgs.Death},
	frequency = sgs.Skill_NotFrequent,
	can_trigger=function(self,event,room,player,data)
	local xueer=room:findPlayerBySkillName(self:objectName())
	if xueer:isAlive() and xueer:getMark("@xue")>=1 and player:hasSkill(self:objectName())then
	  return self:objectName(),xueer
	end
	end,
	on_cost=function(self, event, room, player, data,ask_who)
	local xueer=room:findPlayerBySkillName(self:objectName())
	if xueer:askForSkillInvoke(self:objectName(), data) then return true end return false
	end ,
	on_effect=function(self,event,room,player,data)
	  local xueer=room:findPlayerBySkillName(self:objectName())
	  local die=data:toDeath()
	  local mhp=sgs.QVariant()			  
	  local count=xueer:getMaxHp()			  
	  mhp:setValue(count+1)			  
	  room:setPlayerProperty(xueer,"maxhp",mhp)
	  local x=xueer:getMark("@xue")
	    local rec=sgs.RecoverStruct()
		rec.recover=x
		rec.who=xueer
	    room:recover(xueer,rec)
	xueer:loseAllMarks("@xue")
	end
}	

huanbian = sgs.CreateTriggerSkill{
    name = "huanbian" ,
	events={sgs.DrawNCards,sgs.Damaged},
	frequency = sgs.Skill_NotFrequent,	
	can_trigger=function(self,event,room,player,data)
	    local anni=room:findPlayerBySkillName(self:objectName())
		if table.contains(self:TriggerSkillTriggerable(event, room, player, data, player), self:objectName()) then
			return self:objectName()
		else
			return ""
		end
		if event==sgs.Damaged then return self:objectName(),anni end return""
	end,
	on_cost=function(self, event, room, player, data,ask_who)
		if (player:hasShownSkill(self)) then
            room:broadcastSkillInvoke(self:objectName())
            return true
        elseif event==sgs.Damaged and room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		else return false
		end
	end ,	
	on_effect=function(self,event,room,player,data)
	  if event==sgs.Damaged then
	    local damage = data:toDamage()
	    local x = damage.damage
	    player:gainMark("@huan",x)	
	  end
	  if event==sgs.DrawNCards and player:getMark("@huan")>0 then
	    data:setValue(player:getMark("@huan")) 
	  end
	end
}
huanbiandraw = sgs.CreateDrawCardsSkill{
    name = "#huanbiandraw" ,
	frequency = sgs.Skill_Compulsory,
    on_cost=function(self, event, room, player, data,ask_who)
	  return true
	end,
    draw_num_func = function(self,event,room,player,data)
		  local room = player:getRoom()
		  local x=player:getMark("@huan")
		     if x>0 then
		    	local count = data:toInt() + x-2
                return count				
	         end		
	end
}
mozhang= sgs.CreateMaxCardsSkill{
name="mozhang",
extra_func = function(self, player)
local extra = player:getMark("@huan")
return extra
end
}

zhanqi=sgs.CreateTriggerSkill{
    name = "zhanqi",  
	frequency = sgs.Skill_NotFrequent,  
	events = {sgs.ConfirmDamage,sgs.Damaged},  
	can_trigger = function(self, event, room, player, data)
      local damage = data:toDamage()
	  local victim=damage.to
	  local shanni = room:findPlayerBySkillName(self:objectName())
	  if shanni and shanni:isAlive() then
	    
		  if player and player:isAlive() then
		    return self:objectName(),shanni
		  end
	  end
	end,
	on_cost=function(self, event, room, player, data,ask_who)
      local damage = data:toDamage()	
	  local shanni = room:findPlayerBySkillName(self:objectName())
	   local victim=damage.to
	  if event==sgs.ConfirmDamage and victim==shanni then return false end
	  if event==sgs.Damaged and victim==shanni then return true end
	  if event==sgs.ConfirmDamage and room:askForSkillInvoke(shanni,self:objectName(),data) then
     	  room:broadcastSkillInvoke(self:objectName())
          return true      
	  end
	  
	  return false
	end,
	on_effect=function(self,event,room,player,data)
		local damage = data:toDamage()
		local victim=damage.to
		local shanni = room:findPlayerBySkillName(self:objectName())		
		if event==sgs.ConfirmDamage then 
		    if shanni:getHp()>0 then
		        damage.to=shanni
		    end
		  data:setValue(damage)
		end
		if event==sgs.Damaged then
		  local x = damage.damage
	      shanni:drawCards(2*x,self:objectName())
		end
	end
}
zhanqiex = sgs.CreateTriggerSkill{
    name = "#zhanqiex" ,
	frequency = sgs.Skill_Frequent,
	events={sgs.Damaged},
	on_trigger = function(self, event, player, data)
	local room = player:getRoom()
	local damage = data:toDamage()
	local x = damage.damage
	player:drawCards(2*x,self:objectName())
	room:setPlayerFlag(player,"damaged")
	return false
	end
}
qiyuanCard = sgs.CreateSkillCard{
	name = "qiyuanCard",
	target_fixed = true,
	on_use=function(self,room,source,targets)
		room=source:getRoom()
		room:setPlayerFlag(source,"qiyuan_used")
		local taoyuan=sgs.Sanguosha:cloneCard("god_salvation")
		taoyuan:setSkillName(self:objectName())
		local use = sgs.CardUseStruct()
		use.card=taoyuan
		use.from=source
		room:useCard(use)
	end,
}

qiyuan = sgs.CreateViewAsSkill{
	name = "qiyuan",
	n = 0,
	view_filter = function(self, selected, to_select)
		return false
	end,
	view_as = function(self, cards)
		local card=qiyuanCard:clone()
		card:addSubcards(sgs.Self:getHandcards())
		card:setSkillName(self:objectName())
		return card
	end,
	enabled_at_play = function(self, player)
		return (not player:isKongcheng()) and (not player:hasFlag("qiyuan_used"))
	end,
}
jingguai=sgs.CreateTriggerSkill{
	name = "jingguai" ,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.HpRecover} ,	
	can_trigger = function(self, event, room, player, data)
	    local shali = room:findPlayerBySkillName(self:objectName())
		if shali and shali:isAlive() then
		  if shali:getPhase()==sgs.Player_NotActive then return "" end
		  return self:objectName(),shali
		else return "" end
	end,
	on_cost=function(self, event, room, player, data,ask_who)
	  local shali = room:findPlayerBySkillName(self:objectName())
	  if room:askForSkillInvoke(shali,self:objectName()) then
     	  room:broadcastSkillInvoke(self:objectName())
		  return true
	  else return false end
	end,
	on_effect=function(self,event,room,player,data)
	   local shali = room:findPlayerBySkillName(self:objectName())
		  room:drawCards(shali,2, self:objectName())
	end
}
shuang = sgs.CreateTriggerSkill{
    name = "shuang",  
	frequency = sgs.Skill_NotFrequent,  
	events = {sgs.Damaged},  
	can_trigger = function(self, event, room, player, data)
	    local xinghun = room:findPlayerBySkillName("shuang")
		if not xinghun:isWounded() then return "" end
		if xinghun:getPhase()~=sgs.Player_Play then return "" end
		return self:objectName(),xinghun
	end,
	on_cost=function(self, event, room, player, data,ask_who)
	  local damage = data:toDamage()
	  local killer=damage.from
	  local xinghun = room:findPlayerBySkillName(self:objectName())
	  if xinghun==killer and room:askForSkillInvoke(xinghun,self:objectName(),data) then
     	  room:broadcastSkillInvoke(self:objectName())
          return true      
	  end
	  return false
	end,
	on_effect=function(self,event,room,player,data)
		local damage = data:toDamage()
		local xinghun=damage.from
		if xinghun and xinghun:hasSkill(self:objectName()) then
			     xinghun:drawCards(2, self:objectName())	
		end		
	return false
	end
}
motong= sgs.CreatePhaseChangeSkill{
    name="motong",
	frequency = sgs.Skill_Compulsory,
	can_preshow=false,
	on_cost=function(self, event, room, player, data,ask_who)
	xinghun=room:findPlayerBySkillName(self:objectName())
	if xinghun:hasShownSkill(self) then
	  return true
	end
	return false
	end,
	on_phasechange = function(self,  player)
	   local phase=player:getPhase()
	   local room=player:getRoom()	  
	   if phase==sgs.Player_Start then
	      local life=player:getHp()
		  room:setTag("hp",sgs.QVariant(life))		  	   
		  return false
	   end
	   if player:getPhase() == sgs.Player_Finish then
			local hpend=player:getHp()
		    local tag=room:getTag("hp")
		    local hpstart=tag:toInt()
			local draws=hpend-hpstart
			if(draws>0) then
		       player:drawCards(draws, self:objectName())
			end
			if(draws<=0) then
			  local mhp=sgs.QVariant()			  
			  local count=player:getMaxHp()			  
			  mhp:setValue(count+1)			  
			  room:setPlayerProperty(player,"maxhp",mhp)
			end
		end  
		return false
	end
}
guming = sgs.CreateTriggerSkill{
	name = "guming" ,
	events = {sgs.TargetConfirmed} ,
	can_trigger = function(self, event, room, player, data)
	  local use=data:toCardUse()
	  local momo=room:findPlayerBySkillName("guming")
	  if use.to:contains(momo) and use.card:isNDTrick() and player==momo then
	    return self:objectName(),momo
	  else return "" end
	end,
	on_cost=function(self, event, room, player, data,ask_who)
	local momo=room:findPlayerBySkillName("guming")
      if room:askForSkillInvoke(momo, self:objectName(), data) then
	     room:broadcastSkillInvoke(self:objectName())
		 return true
	  end
	  return false
	end,
	on_effect=function(self,event,room,player,data)	
		local use = data:toCardUse()
		if player and player:hasSkill(self:objectName()) then
		if not player:isKongcheng() or player:hasEquip() then
		  local choice = room:askForChoice(player, self:objectName(), "drawtwo+noeffect")
		  if choice=="noeffect" then
		    player:setFlags("-gumingtarget")
		    player:setFlags("gumingtarget")			
		    room:askForDiscard(player, self:objectName(), 1, 1, false, true)
		    if player:isAlive() and player:hasFlag("gumingtarget") then
			    player:setFlags("-gumingTarget")
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
		    end
		  else
		    player:drawCards(2,self:objectName())
		  end
		else 
		  player:drawCards(2,self:objectName())
		end
		end
		return false
	end
}
huahun=sgs.CreateTriggerSkill{
	name = "huahun",
	events = {sgs.Death,sgs.EventPhaseStart},
	frequency = sgs.Skill_NotFrequent,
    can_trigger = function(self, event, room, player, data)
	  local momo=room:findPlayerBySkillName(self:objectName())
	  if event==sgs.EventPhaseStart and momo:getPhase()==sgs.Player_Start and momo:hasShownSkill(self) then
	    return self:objectName(),momo
	  end
	  if event==sgs.Death and momo:isAlive() then
	    return self:objectName(),momo
	  end
	  return ""
	end,	
	on_cost=function(self, event, room, player, data,ask_who)
	  local momo=room:findPlayerBySkillName(self:objectName())
	  if event==sgs.EventPhaseStart and momo:hasShownSkill(self) then
	    return true
	  end
	  if event==sgs.Death and player:hasSkill(self:objectName()) and room:askForSkillInvoke(momo, self:objectName(), data) then	     
	     room:broadcastSkillInvoke(self:objectName())
		 room:setPlayerFlag(momo,"huahunturn")
		 return true
	  end
	  return false
	end,
	on_effect=function(self,event,room,player,data)
	    local momo=room:findPlayerBySkillName(self:objectName())
		if event==sgs.Death then	   
			momo:gainAnExtraTurn()
		end
		if event==sgs.EventPhaseStart and momo:getPhase()==sgs.Player_Start then
		  if momo:hasFlag("huahunturn") then
		    room:setPlayerFlag(momo,"-huahunturn")
	        momo:turnOver()			
	      end
        end 
	end
}
shiling = sgs.CreateTriggerSkill{
	name = "shiling" ,
	events = {sgs.TargetConfirmed} ,
	can_trigger = function(self, event, room, player, data)
	  local use = data:toCardUse()
	  local lingming=room:findPlayerBySkillName(self:objectName())
	  if use.to:contains(lingming) and lingming:getPhase() == sgs.Player_NotActive and use.from~=lingming and player==lingming then
	    return self:objectName(),lingming
	  end
	  return ""
	end,
    on_cost=function(self, event, room, player, data,ask_who)
	local use = data:toCardUse()
    local from = use.from
	local lingming=room:findPlayerBySkillName(self:objectName())
    if from and not from:isNude() and player:hasSkill(self:objectName()) and room:askForSkillInvoke(lingming, self:objectName(), data) then
	     room:broadcastSkillInvoke(self:objectName())
		 return true
	end
	  return false
	end,
	on_effect=function(self,event,room,player,data)
		local use = data:toCardUse()		
		local from = use.from
		if player and player:hasSkill(self:objectName()) then
	    	  local card_id = room:askForCardChosen(player,from, "he", self:objectName())
	          local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
		      room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
		      return false
		end
	end	
}
lingyuan = sgs.CreateTriggerSkill{
	name = "lingyuan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseChanging},
	can_trigger = function(self, event, room, player, data)
	  local lingming=room:findPlayerBySkillName(self:objectName())
	  if lingming:getPhase()~=sgs.Player_NotActive then
	    return self:objectName(),lingming
	  else return "" end
	end,
	on_cost=function(self, event, room, player, data,ask_who)	  
	  local lingming=room:findPlayerBySkillName(self:objectName())
	  local change = data:toPhaseChange()
	  if change.to ==sgs.Player_Judge and not lingming:isSkipped(sgs.Player_Judge) then
	    if room:askForSkillInvoke(lingming, self:objectName(), data) then
		  lingming:drawCards(2,self:objectName())
		  room:setPlayerFlag(lingming,"jump_phase")
		  return true
		end
	  end
      if lingming:hasFlag("jump_phase") then return true else return false end	  
	end,
	on_effect=function(self,event,room,player,data)
	  local change = data:toPhaseChange()
	  if player:hasFlag("jump_phase") then
	    if change.to ==sgs.Player_Draw or change.to==sgs.Player_Play or change.to==sgs.Player_Discard then
		   player:skip(change.to)
		end
	  end  
	end
}
qianxin=sgs.CreateTriggerSkill{
   name = "qianxin" ,	
   frequency = sgs.Skill_NotFrequent,  
   events = {sgs.HpRecover,sgs.Dying} ,
   can_trigger = function(self, event, room, player, data)
     local youyue=room:findPlayerBySkillName(self:objectName())	
	 if event==sgs.HpRecover then
	     local rec=data:toRecover()
		 if rec.who==youyue and player:hasSkill(self:objectName()) then return self:objectName(),youyue else return "" end	 
	 end
	 if event==sgs.Dying and player:hasSkill(self:objectName()) then return self:objectName(),youyue else return "" end	
	 return ""
   end,
   on_cost=function(self, event, room, player, data,ask_who)
     local youyue=room:findPlayerBySkillName(self:objectName())
	 if room:askForSkillInvoke(youyue,self:objectName(),data) then
	   return true
	 end
	 return false
   end,
   on_effect=function(self,event,room,player,data)
     local youyue=room:findPlayerBySkillName(self:objectName())
	      local card=room:drawCard()
		   youyue:addToPile("xin", card)
   end
}
qianxinmax = sgs.CreateMaxCardsSkill{
	name = "#qianxinmax" ,
	extra_func = function(self, player)
		if (player:hasSkill(self:objectName())) then
		    local num=player:getPile("xin"):length()
			return num
		end
		return 0
	end
}
heiying = sgs.CreateOneCardViewAsSkill{
	name = "heiying", 
	relate_to_place="deputy",
	filter_pattern = ".|.|.|xin",
	expand_pile = "xin",
	view_as = function(self, originalCard) 
		local snatch = sgs.Sanguosha:cloneCard("nullification", originalCard:getSuit(), originalCard:getNumber())
		snatch:addSubcard(originalCard:getId())
		snatch:setSkillName(self:objectName())
		return snatch
	end, 
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return (pattern == "nullification") and (not player:getPile("xin"):isEmpty())
	end,
	enabled_at_nullification = function(self, player)
	    return not player:getPile("xin"):isEmpty()
	end
}
suoyue=sgs.CreateTriggerSkill{
  name="suoyue",
  relate_to_place="head",
  frequency = sgs.Skill_NotFrequent,  
   events = {sgs.EventPhaseStart},   
   can_trigger = function(self, event, room, player, data)
     local youyue=room:findPlayerBySkillName(self:objectName())	
	 if youyue:getPhase()==sgs.Player_Start and not youyue:getPile("xin"):isEmpty() then
	   return self:objectName(),youyue
	 else return "" end
   end,
   on_cost=function(self, event, room, player, data,ask_who)
     local youyue=room:findPlayerBySkillName(self:objectName())
	 if room:askForSkillInvoke(youyue,self:objectName(),data) then
	   return true
	 end
	 return false
   end,
   on_effect=function(self,event,room,player,data)
     local youyue=room:findPlayerBySkillName(self:objectName())
	 local num=youyue:getPile("xin"):length()
     youyue:drawCards(num,self:objectName())
     youyue:clearOnePrivatePile("xin")
   end
}
jihun=sgs.CreateTriggerSkill{
	name = "jihun",
	events = {sgs.Dying,sgs.Death},
	frequency = sgs.Skill_Compulsory,	
    can_trigger = function(self, event, room, player, data)
	  local youxue=room:findPlayerBySkillName(self:objectName())
	  if event==sgs.Dying and player:hasSkill(self:objectName()) then return self:objectName(),youxue end
	  if event==sgs.Death then return self:objectName(),youxue end
	  return ""
	end,
	on_cost=function(self, event, room, player, data,ask_who)
     local youxue=room:findPlayerBySkillName(self:objectName())
	 if event==sgs.Dying then
	     return true
	 end
	 if event==sgs.Death and youxue:isAlive() and player:hasSkill(self:objectName()) then return true end
	 return false
	 end,
	on_effect=function(self,event,room,player,data)
     local youxue=room:findPlayerBySkillName(self:objectName())
	 if event==sgs.Death then youxue:gainMark("@hun",1) end
	 if event==sgs.Dying then youxue:drawCards(2,self:objectName()) end
   end
}

jihunex= sgs.CreateMaxCardsSkill{
name="#jihunex",
extra_func = function(self, player)
   local extra=player:getMark("@hun")
return extra
end
}

duxue=sgs.CreateTriggerSkill{
	name = "duxue",
	events = {sgs.DamageCaused},
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
	  local kate=room:findPlayerBySkillName(self:objectName())
	  local damage=data:toDamage()
	  if player:hasSkill(self:objectName()) and damage.from==kate and damage.to~=kate then return self:objectName(),kate end
	  return ""
	end,
	on_cost=function(self, event, room, player, data,ask_who)
     local kate=room:findPlayerBySkillName(self:objectName())
	  if room:askForSkillInvoke(kate,self:objectName(),data) then
	    return true
	  end
	 return false
	 end,
    on_effect=function(self,event,room,player,data)
	  local kate=room:findPlayerBySkillName(self:objectName())
	  local damage=data:toDamage()
	  local rec=sgs.RecoverStruct()
	  rec.recover=damage.damage
	  rec.who=kate
	  room:recover(kate,rec)
	  damage.damage=0
	  data:setValue(damage)
	end
}
tongxin=sgs.CreateTriggerSkill{
	name = "tongxin",
	events = {sgs.ConfirmDamage},
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
	local kate=room:findPlayerBySkillName(self:objectName())
	local damage=data:toDamage()
	if damage.from and damage.from~=kate and damage.damage>0  and kate:canDiscard(kate,"h")then	  
	if damage.from:getKingdom()==kate:getKingdom() then
	if damage.from:hasShownOneGeneral() then
	 return self:objectName(),kate 
	end
	end
	end
	return ""
	end,
	on_cost=function(self, event, room, player, data,ask_who)
	  local kate=room:findPlayerBySkillName(self:objectName())
	  if room:askForSkillInvoke(kate,self:objectName(),data) then
	    return true
	  else return false end
	end,
	on_effect=function(self,event,room,player,data)
	local kate=room:findPlayerBySkillName(self:objectName())
	local damage=data:toDamage()
	  room:askForCard(kate, ".", "@tongxin-discard", data, self:objectName())
	  damage.from=kate
	  data:setValue(damage)
	end
}


lingyvan = sgs.CreateTriggerSkill{
	name = "lingyvan",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime, sgs.Damaged,sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
	  local yueya=room:findPlayerBySkillName(self:objectName())
	  if event==sgs.Damaged then
	    local damage=data:toDamage()
	    if damage.to==yueya then return self:objectName(),yueya end	  
	  end
	  if event==sgs.CardsMoveOneTime and player and player:hasSkill(self:objectName()) and not player:faceUp() then
	    return self:objectName()
	  end
	  if event==sgs.EventPhaseStart and player and player:hasSkill(self:objectName()) and player:getPhase()==sgs.Player_Discard and player:isKongcheng() then
	    return self:objectName()
	  end
	end,
	on_cost=function(self, event, room, player, data,ask_who)
	  return true
	end,
	on_effect=function(self,event,room,player,data)
	    local x=player:getMaxHp()
	    if event==sgs.EventPhaseStart then 
		 player:turnOver()
		 player:drawCards(x)		
		end
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			local source = move.from
			local target = move.to
			if not source or source:objectName() ~= player:objectName() then
				if not target or target:objectName() ~= player:objectName() then
					return false
				end
			end
			if move.to_place ~= sgs.Player_PlaceHand then
				if not move.from_places:contains(sgs.Player_PlaceHand) then
					return false
				end
			end
			if player:getPhase() == sgs.Player_Discard then
				return false
			end
		elseif event == sgs.Damaged then
			local damage=data:toDamage()			
			local count = player:getHandcardNum()			
			damage.to:turnOver()
		    if count == x then
			return false
		    elseif count < x then
			  player:drawCards(x - count)
		    elseif count > x then
			  room:askForDiscard(player, self:objectName(), count - x, count - x)
		    end
			return false
		end
		local count = player:getHandcardNum()
		if count ==x then
			return false
		elseif count < x then
			player:drawCards(x - count)
		elseif count > x then
			room:askForDiscard(player, self:objectName(), count - x, count - x)
		end
		return false
	end
}
guijue=sgs.CreateTriggerSkill{
    name = "guijue",
	events = {sgs.EventPhaseChanging},	
	frequency = sgs.Skill_NotFrequent,
    can_trigger=function(self,event,room,player,data)
	local yueya=room:findPlayerBySkillName(self:objectName())
	local change = data:toPhaseChange()
    local current=room:getCurrent()
	if current:objectName()~=yueya:objectName() and change.to==sgs.Player_Discard and not yueya:isKongcheng() then 
	  return self:objectName(),yueya
	end
end,
on_cost=function(self, event, room, player, data,ask_who)
      local yueya=room:findPlayerBySkillName(self:objectName())
      if room:askForSkillInvoke(yueya,self:objectName(),data) then
	    return true
	  end
	  return false
	end,
	on_effect=function(self,event,room,player,data)
	   local yueya=room:findPlayerBySkillName(self:objectName())	 
	    local current=room:getCurrent()	
	   local cards=room:askForExchange(yueya, self:objectName(), 999,1, "", "", ".|.|.|hand")
	   if cards then	
		 local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE,yueya:objectName(),current:objectName(),"guijue","")
		room:obtainCard(current,cards, reason)
	   end
	end
}

dieer:addSkill(diehun)
dieer:addSkill(huanyue)
dieer:addCompanion("youyue")
lord_lanyin:addSkill(zhongjue)
lord_lanyin:addSkill(leiying)
youxue:addSkill(jihun)
youxue:addSkill(jihunex)
extension:insertRelatedSkills("jihun", "#jihunex")
youxue:addCompanion("yaoyao")
youyue:addSkill(qianxin)
youyue:addSkill(qianxinmax)
youyue:addSkill(suoyue)
youyue:addSkill(heiying)
extension:insertRelatedSkills("qianxin", "#qianxinmax")
youyue:addCompanion("shali")
shali:addSkill(qiyuan)
shali:addSkill(jingguai)
anni:addSkill(huanbian)
anni:addSkill(huanbiandraw)
anni:addSkill(mozhang)
anni:addCompanion("kate")
kate:addSkill(duxue)
kate:addSkill(tongxin)
--anni:addSkill(weiming)
yaoyao:addSkill(qiancai)
yaoyao:addSkill(zhiming)
yaoyao:addCompanion("xinghun")
xueer:addSkill(moyu)
lord_xueer:addSkill(yinxue)
lord_xueer:addSkill(yinxuemod)
extension:insertRelatedSkills("yinxue", "#yinxuemod")
lord_xueer:addSkill(mowang)
shanni:addSkill(zhanqi)
shanni:addCompanion("xueer")
--xueer:addSkill(hunluo)
--xueer:addSkill(hunluomod)
--xueer:addSkill(hunluolose)
--xinghun:addSkill(longxin)
xinghun:addSkill(motong)
xinghun:addSkill(shuang)
momo:addSkill(guming)
momo:addSkill(huahun)
momo:addCompanion("lingming")
momo:addCompanion("yanmo")
lingming:addSkill(shiling)
lingming:addSkill(lingyuan)
xinxin:addSkill(juepan)
xinxin:addSkill(juepanget)
bayuanshu:addSkill(yongsi)
bayuanshu:addCompanion("jiling")
lord_momo:addSkill(guming)
lord_momo:addSkill(shenjianglose)
yanmo:addSkill(juejue)
yanmo:addSkill(juejueg)
extension:insertRelatedSkills("juejue", "#juejueg")
yanmo:addSkill(guwei)
shuiyan:addSkill(shuiyue)
shuiyan:addSkill(yuanan)
shuiyan:addSkill(kuiyan)
shuiyan:addCompanion("xueer")
yanpo:addSkill(hunyan)
yanpo:addSkill(moyi)
yanpo:addSkill(moyimod)
extension:insertRelatedSkills("moyi", "#moyimod")
yanpo:addCompanion("xinghun")
--extension:insertRelatedSkills("shenjiang", "#shenjianglose")
yueya:addSkill(lingyvan)
yueya:addSkill(guijue)
yueya:addCompanion("youyue")
sgs.LoadTranslationTable{
["study"]="魔包",
["@xue"]="雪",
["@huan"]="幻",
["@hun"]="魂魄",
["@lei"]="泪",
["guijue_select"]="你可选择任意张手牌交给该角色",
["yaoyao"]="妖妖",
["&yaoyao"]="妖妖",
["#yaoyao"]="幻魂之花",
["qiancai"]="潜才",
[":qiancai"]="在你的回合外，每当你失去一次牌，你可立即摸两张牌。",
["zhiming"]="执命",
[":zhiming"]="锁定技，当你受到属性伤害时，你取消之。",
["youxue"]="游雪",
["&youxue"]="游雪",
["#youxue"]="魂魄之主",
["jihun"]="汲魂",
[":jihun"]="锁定技，每有一名角色陷入濒死状态，你立即摸两张牌；每有一名角色死亡，你的手牌上限+1。",
["kate"]="凯特",
["&kate"]="凯特",
["#kate"]="流逝的空间",
["duxue"]="渎血",
[":duxue"]="每当你将造成伤害时，你可以将此伤害降为0并恢复等同于原本将造成伤害值的体力值，且此伤害视为未被防止。",
["tongxin"]="同心",
[":tongxin"]="与你同一势力的角色将要造成伤害时，你可以弃置一张手牌并成为本次伤害的伤害来源。",
["@tongxin-discard"]="请选择一张手牌弃置并成为此次伤害的来源。",
["xueer"]="雪儿",
["&xueer"]="雪儿",
["#xueer"]="黑暗公主",
["moyu"]="魔语",
[":moyu"]="你每使用杀指定一次对象后，你可立即摸两张牌。",
["hunluo"]="魂落",
[":hunluo"]="主公技。锁定技。在你的回合，你可以额外使用X张杀，X为除你以外的魏势力角色数量。",
["anni"]="安妮",
["&anni"]="安妮",
["#anni"]="异色瞳魔女",
["huanbian"]="幻变",
[":huanbian"]="每当你受到一点伤害，你可以获得一枚“幻”标记。当你持有幻标记时，你摸牌阶段摸的牌始终等于你持有的“幻”标记的数目",
["mozhang"]="魔障",
[":mozhang"]="锁定技，你的手牌上限增加你持有的“幻”标记的数量。",
["weiming"]="托运",
[":weiming"]="主公技。其他魏势力角色死亡时，你可弃置全部“幻”标记，然后获得该角色的所有技能（不包括觉醒技和限定技）。",
["#huanbiandraw"]="幻变",
["shali"]="莎莉",
["&shali"]="莎莉",
["#shali"]="暗黑精灵",
["qiyuanCard"]="祈愿",
["qiyuan"]="祈愿",
[":qiyuan"]="阶段技，你可以将所有手牌当成一张桃园结义使用。",
["jingguai"]="精怪",
[":jingguai"]="在你的回合内，每当有一名角色恢复体力时，你可以摸两张牌。",
["xinghun"]="星魂",
["&xinghun"]="星魂",
["#xinghun"]="黑暗主教",
["shanni"]="珊妮",
["&shanni"]="珊妮",
["#shanni"]="光明之女",
["momo"]="魔魔",
["&momo"]="魔魔",
["#momo"]="世界之花",
["lingming"]="灵冥",
["&lingming"]="灵冥",
["#lingming"]="复活的魔神",
["all_recover"]="所有同势力角色恢复一点体力值",
["recover_to_full"]="你恢复至体力上限",
["draw"]="摸三张牌",
["rec"]="恢复至体力上限",
["change"]="获得一项技能",
["drawtwo"]="摸两张牌",
["gumingcard"]="选择一张牌弃置使锦囊对你无效",
["noeffect"]="弃一张牌使锦囊对你无效",
["basic"]="基本牌",
["not_basic"]="非基本牌",
["zhanqi"]="战骑",
[":zhanqi"]="每当一名角色将要受到伤害时，你可将此伤害减为1然后代为承受之。你每受到一点伤害，若没有伤害来源或伤害来源距离你为1以内，你就可摸两张牌。",
["longxin"]="龙心",
[":longxin"]="每当你对其他角色造成一点伤害，你可立即恢复一点体力值。",
["motong"]="魔统",
[":motong"]="锁定技，回合结束阶段，你摸X张牌，X为你回合结束阶段与回合开始阶段的体力值之差。若X不为正，你增加一点体力上限。",
["shuang"]="双魂",
[":shuang"]="出牌阶段，每当你对其他角色造成一次伤害，且你此时已经受伤，则你可摸两张牌。",
["shiling"]="誓灵",
["youyue"]="游月",
["&youyue"]="游月",
["#youyue"]="若明之光",
["qianxin"]="千馨",
[":qianxin"]="每当你恢复一次体力值或有角色进入濒死状态，你可以展示牌堆顶的一张牌并将其置于武将牌上，称为一张“馨”。你每有一张“馨”，你的手牌上限便加一。",
["suoyue"]="锁月",
[":suoyue"]="主将技，回合开始阶段，你可以弃置所有“馨”并摸取等量的牌。",
["heiying"]="黑瑛",
[":heiying"]="副将技，此武将牌上单独的阴阳鱼个数-1。副将技，你可以将你的“馨”当作无懈可击使用。",
["xin"]="馨",
["yue"]="玥",
["tao"]="月",
["yuecover"]="选择一张牌作为“月”",
["xincover"]="选择一张牌作为“馨”",
[":shiling"]="在你的回合外，每当你成为其他角色卡的对象时，你可以获得使用者的一张牌。",
["lingyuan"]="灵源",
[":lingyuan"]="判定阶段开始前，你可以摸两张牌，若如此做，跳过你本回合的摸牌、出牌、弃牌阶段。",
["shenjiang"]="神降",
[":shenjiang"]="君主技，出牌阶段，你可以与一名体力值大于你的角色拼点，若你赢，你获得技能“完杀”直到回合结束；若你没赢，在下个你的回合开始前你获得技能“潜才”。每回合限一次。",
["guming"]="孤命",
[":guming"]="每当你成为非延时锦囊的目标时，你可以摸两张牌或弃置一张牌令其对你无效。",--注意：自己对自己使用锦囊时，该技能也有效，也就是说可以做到无中生有摸四张牌。
["huahun"]="花魂",
[":huahun"]="每当有角色死亡，你可以在当前回合结束后立即开始一个额外的回合并且将武将牌叠置。在你不以此法开始自己的回合开始前，若你已发动过此技能且你的武将牌平置，则你须将武将牌叠置。",
["xinxin"]="馨馨",
["&xinxin"]="馨馨",
["#xinxin"]="命运逆转",
["juepanget"]="绝境",
[":juepanget"]="每当你受到一点伤害、回合结束阶段或回合开始阶段开始时没有手牌时，你获得一枚“判”标记。你可以在弃牌后弃置所有手牌。若你在没有手牌的时候受到伤害，你可以摸两张牌。",
["@pan"]="判",
["juepan"]="决判",
[":juepan"]="出牌阶段，你可以弃置6枚“判”标记并立即令一名除你以外的角色死亡。",
["yanyan"]="燕燕",
["&yanyan"]="燕燕",
["#yanyan"]="复生的使命",
["lord_yanyan"]="燕燕",
["&lord_yanyan"]="燕燕",
["#lord_yanyan"]="复生的使命",
["lord_xueer"]="雪儿",
["&lord_xueer"]="雪儿",
["#lord_xueer"]="黑暗的少女",
["lord_momo"]="魔魔",
["&lord_momo"]="魔魔",
["#lord_momo"]="魔神之意",
["lord_lanyin"]="兰音",
["&lord_lanyin"]="兰音",
["#lord_lanyin"]="梦幻的黑暗",
["lveying"]="掠樱",
[":lveying"]="君主技，锁定技，你的手牌上限减去场上已亮明的蜀势力角色数。君主技，你在回合开始阶段可以弃置一枚“玥”和所有判定区的牌。",
["shenyue"]="神玥",
[":shenyue"]="弃牌阶段结束时，你可将你所有的弃牌置于武将牌上，称为“玥”。当有非延时锦囊或杀的目标确定时，你可弃置一张“玥”令其无效，然后若该牌原本指定的目标多于一个，你摸一张牌。",
["bayuanshu"] = "袁术",
["#bayuanshu"] = "仲家帝",
["yongsi"] = "庸肆",
[":yongsi"] = "锁定技，摸牌阶段，你额外摸X张牌，X为场上已亮明势力数。弃牌阶段，你至少须弃掉等同于场上已亮明势力数的牌（不足则全弃）。",
["@bayongsi-discard"] = "你至少须弃掉等同于场上已亮明势力数的牌",
["yinxue"]="隐雪",
[":yinxue"]="每当你受到一点伤害，你就获得一个“雪”标记。你每有一个“雪”标记，你在出牌阶段就可以额外使用一张杀。",
["mowang"]="魔王",
[":mowang"]="君主技，当有角色阵亡时，你可以弃置所有“雪”标记（至少为1）增加一点体力上限并恢复X点体力值，X为你弃置的“雪”标记数。",
["lanyin"]="兰音",
["&lanyin"]="兰音",
["#lanyin"]="梦幻的黑暗",
["zhongjue"]="终绝",
[":zhongjue"]="你的另一武将牌在你明置此武将牌时须被移除。每当有其他角色死亡时，你可选择获得其一个技能。若你放弃，则你可立刻恢复至体力上限或摸三张牌。",
["leiying"]="泪影",
[":leiying"]="君主技，限定技，出牌阶段，若你已受伤，你可以令所有同势力角色均恢复1点体力，或你恢复至体力上限。",
["dieer"]="蝶儿",
["&dieer"]="蝶儿",
["#dieer"]="月下奇缘",
["diehun"]="蝶魂",
[":diehun"]="锁定技，与你同势力已亮明的角色对你造成的伤害无效。",
["huanyue"]="幻月",
[":huanyue"]="以下两种情况你可以将指定的牌置于武将牌上，称为“月”（可以当成桃打出或使用）：1、弃牌阶段弃置的至多两张基本牌；2、每当有角色濒死时，你选择一张自己的牌，在此情况下，回合结束前你都不能打出或使用桃。",
["diezhi"]="绝决（叠置武将牌）",
["yanmo"]="颜默",
["&yanmo"]="颜默",
["#yanmo"]="世界的黑暗",
["moyv"]="魔域",
[":moyv"]="锁定技，你的体力值为满时，你使用杀无数量与距离限制。",
["juejue"]="绝决",
[":juejue"]="在你的回合外，每当有一名其他角色死亡时，你可以摸三张牌然后叠置武将牌。每当你回合结束时，你可以叠置你的武将牌。锁定技，当你的武将牌叠置时，你不接受伤害。",
["guwei"]="孤威",
[":guwei"]="限定技，回合开始阶段，若所有角色均已确定势力且你是本势力唯一的角色，你可以弃置判定区所有的牌，增加一点体力上限并恢复至满体力值，获得技能“魔域”和“武圣”。",
["shuiyan"]="水烟",
["&shuiyan"]="水烟",
["#shuiyan"]="海之恩赐",
["shuiyue"]="水月",
[":shuiyue"]="锁定技，你造成或受到火属性伤害时，防止之。",
["yuanan"]="渊暗",
[":yuanan"]="弃牌阶段结束时，你可至多回复场上角色共X点体力（你可以任意分配，且X为此阶段弃置牌数的1/3且不能少于3，向上取整）。此流程中你每令一名不同势力的角色恢复体力，你就可以摸一张牌。",
["kuiyan"]="溃堰",
[":kuiyan"]="限定技，出牌阶段，你可以获得所有其他角色的一张牌，不能获得牌的角色失去一点体力。",
["yanpo"]="炎魄",
["&yanpo"]="炎魄",
["#yanpo"]="双魂同心",
["hunyan"]="魂焰",
[":hunyan"]="出牌阶段，若你已受伤，你可以与其他角色拼点，视为赢的一方使用了一张桃。",
["moyi"]="魔翼",
[":moyi"]="锁定技，出牌阶段，若你已受伤，则你使用杀无距离限制，且未受伤角色无法闪避你使用的杀。",
["yueya"]="月雅",
["&yueya"]="月雅",
["#yueya"]="幽暗弦音",
["lingyvan"]="灵渊",
[":lingyvan"]="锁定技，每当你受到伤害，或者在弃牌阶段开始时没有手牌，则你须将武将牌叠置。当你的武将牌叠置时，你的手牌数始终等于你的体力上限。",
["guijue"]="诡谲",
[":guijue"]="其他角色的弃牌阶段开始前，你可以选择任意张手牌交给该角色。",
["#test"]="我死了"
}
return {extension}
