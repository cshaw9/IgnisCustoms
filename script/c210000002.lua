--Canis, The Polygod Wolf
local s,id,o=GetID()
-- c210000002
function s.initial_effect(c)
	-- If this card would be sent to the GY, banish it instead.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(s.e1con)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)

	if not s.global_check then
		s.global_check=true

		local e1b=Effect.GlobalEffect()
		e1b:SetType(EFFECT_TYPE_FIELD)
		e1b:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e1b:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		e1b:SetTarget(aux.TargetBoolFunction(Card.IsCode,id))
		e1b:SetValue(LOCATION_REMOVED)
		Duel.RegisterEffect(e1b,0)
	end
	--[[
	[HOPT] [FIX] >> Maintain Chain Integrity
	If a “Polygod” monster's battle position is changed by a card effect, except “Canis, The Polygod Wolf”, while this card is in Attack Position,
	you can: Immediately after this effect resolves, Normal Summon 2 “Polygod” monsters from your hand,
	and if you do, change this card to face-up Defense Position.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,(id+0))
	e2:SetCondition(s.e2con)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e2fil(c)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()

	return c:IsSetCard(0xce1)
	and not c:IsCode(id)
	and ((pp==0x1 and np==0x4) or (pp==0x4 and np==0x1) or (pp==0x8 and np==0x1))
	-- and c:IsReason(REASON_EFFECT)
end
function s.e2nsfil(c)
	return c:IsSetCard(0xce1)
	and c:IsSummonable(true,nil)
end
function s.e2con(e,tp,eg)
	local g=Duel.GetMatchingGroup(s.e2nsfil,tp,LOCATION_HAND,0,nil,e,tp)
	
	return e:GetHandler():IsAttackPos()
	and eg:IsExists(s.e2fil,1,nil)
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
	and g:GetCount()>=2
end
function s.e2evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetMatchingGroup(s.e2nsfil,tp,LOCATION_HAND,0,nil,e,tp)
	if g:GetCount()>=2 then		
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local sel = Group.Select(g,tp,1,1,nil)
		
		Duel.Summon(tp,sel:GetFirst(),true,nil)

		local c=e:GetHandler()
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)

		local e2b=Effect.CreateEffect(c)
		e2b:SetCategory(CATEGORY_SUMMON)
		e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2b:SetCode(EVENT_SUMMON_SUCCESS)
		e2b:SetRange(LOCATION_MZONE)
		e2b:SetReset(RESET_PHASE+PHASE_END)
		e2b:SetCondition(s.e2bcon)
		e2b:SetOperation(s.e2bevt)
		Duel.RegisterEffect(e2b,tp)
	end
end
function s.e2bcon(e,tp,eg)
	return e:GetHandler():GetFlagEffect(id)==1
end
function s.e2bevt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local g=Duel.GetMatchingGroup(s.e2nsfil,tp,LOCATION_HAND,0,nil,e,tp)
	if g:GetCount()>=1 then
		local c=e:GetHandler()
		Card.ResetFlagEffect(c,id)

		c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,2)

		local e2c=Effect.CreateEffect(c)
		e2c:SetCategory(CATEGORY_POSITION)
		e2c:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2c:SetCode(EVENT_SUMMON_SUCCESS)
		e2c:SetRange(LOCATION_MZONE)
		e2c:SetReset(RESET_PHASE+PHASE_END)
		e2c:SetCondition(s.e2ccon)
		e2c:SetOperation(s.e2cevt)
		Duel.RegisterEffect(e2c,tp)

		-- breaking recursion (can't use "e" after this line)
		-- e:Reset()

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local sel = Group.Select(g,tp,1,1,nil)

		Duel.Summon(tp,sel:GetFirst(),true,nil)
	end
end
function s.e2ccon(e)
	return e:GetHandler():GetFlagEffect(id+1)==1
end
function s.e2cevt(e,tp)
	local c=e:GetHandler()
	Card.ResetFlagEffect(c,(id+1))

	if c:IsAttackPos() then
		local repl=c:GetEquipGroup():Filter(Card.IsCode,nil,210000024)
		if repl:GetCount()>0 then
			if not Duel.SelectEffectYesNo(tp,repl:GetFirst()) then
				Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
			end
		else
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
end