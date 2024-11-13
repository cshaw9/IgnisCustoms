--Polygod Emergence
local s,id,o=GetID()
-- c210000027
function s.initial_effect(c)
	-- Banish all “Polygod” cards in the GYs.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
function s.e1fil(c)
	return c:IsSetCard(0xce1)
	and c:IsAbleToRemove()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,LOCATION_GRAVE):Filter(s.e1fil,nil,e,tp)
	
	if chk==0 then
		return g:GetCount()>0
	end
	
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,g:GetCount(),tp,LOCATION_GRAVE)
end
function s.e1evt(e,tp)
	local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,LOCATION_GRAVE):Filter(s.e1fil,nil,e,tp)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end