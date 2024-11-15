-- Shields of Banishite
local s,id,o=GetID()
-- c210000080
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--[[
	If a card(s) you control would be destroyed by battle or an opponent’s card effect:
	Pay 1000 LP for each card that would be destroyed, instead
	(you must protect all your cards that would be destroyed, if you use this effect).
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetValue(s.e2val)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e2fil(c,tp)
	return c:IsLocation(LOCATION_ONFIELD)
	and c:IsControler(tp)
	and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
end
function s.e2con(e)
	return e:GetHandler():IsFaceup()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	local p=eg:Filter(s.e2fil,nil,tp):GetCount()*1000

	if chk==0 then
		return eg:IsExists(s.e2fil,1,nil,tp)
		and Duel.CheckLPCost(tp,p)
	end
	
	e:SetLabel(p)
	return Duel.SelectEffectYesNo(tp,c)
end
function s.e2val(e,c)
	return s.e2fil(c,e:GetHandlerPlayer())
end
function s.e2evt(e,tp,eg)
	Duel.PayLPCost(tp,e:GetLabel())
	Duel.BreakEffect()
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end