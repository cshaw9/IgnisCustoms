--Aquilae, The Polygod Eagle
local s,id,o=GetID()
-- c210000001
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
	If there is a “Polygod” monster on the field other than “Aquilae, The Polygod Eagle”, this card can attack directly,
	but when it uses this effect, change this card to face-up Defense Position at the end of the Battle Phase.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(s.e2con)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLED)
	e3:SetCondition(s.e3con)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e1con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e2fil(c)
	return c:IsFaceup()
	and c:IsSetCard(0xce1)
	and not c:IsCode(id)
end
function s.e2con(e)
	return Duel.IsExistingMatchingCard(s.e2fil,0,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
function s.e3con(e,tp)
	local c=e:GetHandler()
	
	return Duel.GetAttackTarget()==nil
	and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2
	and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function s.e3evt(e,tp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3b:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3b:SetRange(LOCATION_MZONE)
	e3b:SetCountLimit(1)
	e3b:SetCondition(s.e3bcon)
	e3b:SetOperation(s.e3bevt)
	e3b:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3b,tp)
end
function s.e3bcon(e)
	return e:GetHandler():GetFlagEffect(id)==1
end
function s.e3bevt(e,tp)
	local c=e:GetHandler()
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