--Leo, The Polygod Lion
local s,id,o=GetID()
-- c210000007
function s.initial_effect(c)
	-- While this card is in Attack Position, your opponent cannot activate card effects from the hand.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.e1con)
	e1:SetValue(s.e1val)
	c:RegisterEffect(e1)
	-- If this card would be sent to the GY, banish it instead.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(s.e2con)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)

	if not s.global_check then
		s.global_check=true

		local e2b=Effect.GlobalEffect()
		e2b:SetType(EFFECT_TYPE_FIELD)
		e2b:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e2b:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		e2b:SetTarget(aux.TargetBoolFunction(Card.IsCode,id))
		e2b:SetValue(LOCATION_REMOVED)
		Duel.RegisterEffect(e2b,0)
	end
	--[[
	[HOPT]
	During your Main Phase, while this card is in Attack Position: You can Normal Summon 1 “Polygod” monster from your hand,
	and if you do, change this card to face-up Defense Position.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,0})
	e3:SetCondition(s.e3con)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e1con(e)
	return e:GetHandler():IsAttackPos()
end
function s.e1val(e,re)
	local rc=re:GetHandler()

	return rc
	and rc:IsLocation(LOCATION_HAND)
end
function s.e2con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e3fil(c)
	return c:IsSetCard(0xce1)
	and c:IsSummonable(true,nil)
end
function s.e3con(e,tp,eg)
	local g=Duel.GetMatchingGroup(s.e3fil,tp,LOCATION_HAND,0,nil,e,tp)
	
	return e:GetHandler():IsAttackPos()
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>=1
	and g:GetCount()>=1
end
function s.e3evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local g=Duel.GetMatchingGroup(s.e3fil,tp,LOCATION_HAND,0,nil,e,tp)
	if g:GetCount()>=1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local sel=Group.Select(g,tp,1,1,nil)
		Duel.Summon(tp,sel:GetFirst(),true,nil)
		
		local c=e:GetHandler()
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)

		local e3b=Effect.CreateEffect(c)
		e3b:SetCategory(CATEGORY_POSITION)
		e3b:SetCode(EVENT_SUMMON_SUCCESS)
		e3b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3b:SetRange(LOCATION_MZONE)
		e3b:SetReset(RESET_PHASE+PHASE_END)
		e3b:SetCondition(s.e3bcon)
		e3b:SetOperation(s.e3bevt)
		Duel.RegisterEffect(e3b,tp)
	end
end
function s.e3bcon(e)
	return e:GetHandler():GetFlagEffect(id)==1
end
function s.e3bevt(e,tp)
	local c=e:GetHandler()
	Card.ResetFlagEffect(c,id)

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