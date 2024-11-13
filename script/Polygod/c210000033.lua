--Polygod Delineation
local s,id,o=GetID()
-- c210000033
function s.initial_effect(c)
	--[[
	Target 1 “Polygod” card you control and 1 card your opponent controls;
	destroy the first target, and if you do, banish the second target.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
function s.e1desfil(c,e,tp)
	return c:IsFaceup()
	and c:IsSetCard(0xce1)
	and c:IsDestructable()
	and c~=e:GetHandler()
end
function s.e1remfil(c)
	return c:IsAbleToRemove()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return false
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e1desfil,tp,LOCATION_ONFIELD,0,1,nil,e,tp)
		and Duel.IsExistingTarget(s.e1remfil,tp,0,LOCATION_ONFIELD,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,s.e1desfil,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectTarget(tp,s.e1remfil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,g2:GetCount(),0,0)
end
function s.e1evt(e,tp)
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_REMOVE)

	if g1:GetFirst():IsRelateToEffect(e) and g1:GetFirst():IsFaceup() and Duel.Destroy(g1,REASON_EFFECT)>0 then
		local hg=g2:Filter(Card.IsRelateToEffect,nil,e)
		Duel.Remove(hg,POS_FACEUP,REASON_EFFECT)
	end
end