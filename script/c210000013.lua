--Scutum, The Polygod Shield Generator
local s,id,o=GetID()
-- c210000013
function s.initial_effect(c)
	-- Cannot be destroyed by battle while in Defense Position.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.e1con)
	e1:SetValue(1)
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
	[SOPT]
	Once per turn, if your “Polygod” monster is targeted for an attack, while this card is in face-up Defense Position (Quick Effect):
	You can change the attack target to this card,
	then change this card to Attack Position at the end of the Damage Step.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e1con(e)
	return e:GetHandler():IsDefensePos()
end
function s.e2con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e3con(e,tp,eg,ep,ev,re,r)
	local c=e:GetHandler()
	local d=Duel.GetAttackTarget()

	return e:GetHandler():IsDefensePos()
	and c~=d
	and d:IsSetCard(0xce1)
	and r~=REASON_REPLACE
	and d:IsFaceup()
	and d:IsControler(tp)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetAttacker():GetAttackableTarget():IsContains(e:GetHandler())
	end
end
function s.e3evt(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		if Duel.ChangeAttackTarget(c) then
			local c=e:GetHandler()
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)

			local e3b=Effect.CreateEffect(c)
			e3b:SetCategory(CATEGORY_POSITION)
			e3b:SetCode(EVENT_DAMAGE_STEP_END)
			e3b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e3b:SetRange(LOCATION_MZONE)
			e3b:SetReset(RESET_PHASE+PHASE_END)
			e3b:SetCondition(s.e3bcon)
			e3b:SetOperation(s.e3bevt)
			Duel.RegisterEffect(e3b,tp)
		end
	end
end
function s.e3bcon(e)
	return e:GetHandler():GetFlagEffect(id)==1
end
function s.e3bevt(e)
	local c=e:GetHandler()
	Card.ResetFlagEffect(c,id)

	if c:IsDefensePos() then
		Duel.ChangePosition(c,POS_FACEUP_ATTACK)
	end
end