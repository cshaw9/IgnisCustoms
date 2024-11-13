-- Red Area
local s,id,o=GetID()
-- c210000047
function s.initial_effect(c)
	-- Must be Set on the field by the effect of “Rainbow Realm of Doom”, and cannot be Set by other ways.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e0)
	-- [Activation]
	-- This card can only be activated during your opponent’s Standby Phase.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE)
	e1:SetCondition(s.e1con)
	c:RegisterEffect(e1)
	-- Your opponent must pay 1000 LP to declare an attack.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ATTACK_COST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCost(s.e2cst)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)

	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD)
	e2b:SetCode(id)
	e2b:SetRange(LOCATION_SZONE)
	e2b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2b:SetTargetRange(0,1)
	c:RegisterEffect(e2b)
	--[[
	If a face-up “Area” Continuous Trap(s) or “Rainbow Realm of Doom” you control would be destroyed by card effect,
	you can send this face-up card on the field to the GY instead.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	e3:SetValue(s.e3val)
	c:RegisterEffect(e3)
end
function s.e1con(e,tp)
	return tp~=Duel.GetTurnPlayer()
	and Duel.GetCurrentPhase()==PHASE_STANDBY
end
function s.e2cst(e,c,tp)
	local ct=#{Duel.GetPlayerEffect(tp,id)}
	return Duel.CheckLPCost(tp,(ct*1000))
end
function s.e2evt(e,tp)
	if Duel.IsAttackCostPaid()~=2 and e:GetHandler():IsLocation(LOCATION_SZONE) then
		Duel.PayLPCost(tp,1000)
		Duel.AttackCostPaid()
	end
end
function s.e3fil(c,tp)
	return ((c:IsSetCard(0xce2b)
	and c:IsType(TYPE_TRAP)
	and c:IsType(TYPE_CONTINUOUS))
	or c:IsCode(210000046))
	and c:IsFaceup()
	and c:IsControler(tp)
	and c:IsReason(REASON_EFFECT)
	and not c:IsReason(REASON_REPLACE)
end
function s.e3con(e)
	local c=e:GetHandler()

	return c:IsFaceup()
	and c:IsAbleToGrave()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return eg:IsExists(s.e3fil,1,nil,tp)
	end
	
	return Duel.SelectEffectYesNo(tp,c)
end
function s.e3val(e,c)
	return s.e3fil(c,e:GetHandlerPlayer())
end
function s.e3evt(e)
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end