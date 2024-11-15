-- Shields of Banishite
local s,id,o=GetID()
-- c210000080
function s.initial_effect(c)
	--[[
	If a card(s) you control would be destroyed by battle or an opponent’s card effect:
	Pay 1000 LP for each card that would be destroyed, instead
	(you must protect all your cards that would be destroyed, if you use this effect).
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetTarget(s.e1tgt)
	e1:SetValue(s.e1val)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
function s.e1fil(c,tp)
	return c:IsFaceup()
	and c:IsLocation(LOCATION_ONFIELD)
	and c:IsControler(tp)
	and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	local p=eg:Filter(s.e1fil, nil):GetCount()*1000

	if chk==0 then
		return eg:IsExists(s.e1fil,1,nil,tp)
		and Duel.CheckLPCost(tp,p)
	end
	
	e:SetLabel(p)
	return Duel.SelectEffectYesNo(tp,c)
end
function s.e1val(e,c)
	return s.e1fil(c,e:GetHandlerPlayer())
end
function s.e1evt(e,tp,eg)
	Duel.PayLPCost(tp,e:GetLabel())
end