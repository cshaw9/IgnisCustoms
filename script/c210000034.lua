--Polygod Dimensional Collapse
local s,id,o=GetID()
-- c210000034
function s.initial_effect(c)
	-- [Activation]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--[[
	If this card on the field is sent to the GY: Send all “Polygod” monsters on the field to the GY.
	Neither player can activate cards or effects in response to this effect’s activation.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[SOPT]
	Once per turn: You can target 1 card in your banishment and 1 card in your opponent’s banishment;
	return the first target to the GY, and if you do, shuffle the second target into the Deck.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e2fil(c)
	return c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and c:IsAbleToGrave()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	local g=Duel.GetMatchingGroup(s.e2fil,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	Duel.SetChainLimit(aux.FALSE)
end
function s.e2evt(e,tp)
	local g=Duel.GetMatchingGroup(s.e2fil,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	Duel.SendtoGrave(g,REASON_EFFECT)
end
function s.e3retfil(c)
	return c:IsAbleToGrave()
end
function s.e3shffil(c)
	return c:IsAbleToDeck()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return false
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e3retfil,tp,LOCATION_REMOVED,0,1,nil)
		and Duel.IsExistingTarget(s.e3shffil,tp,0,LOCATION_REMOVED,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectTarget(tp,s.e3retfil,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,1,0,0)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectTarget(tp,s.e3shffil,tp,0,LOCATION_REMOVED,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,g2:GetCount(),0,0)
end
function s.e3evt(e,tp)
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TOGRAVE)
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_TODECK)

	if g1:GetFirst():IsRelateToEffect(e) and Duel.SendtoGrave(g1,REASON_EFFECT)>0 then
		local hg=g2:Filter(Card.IsRelateToEffect,nil,e)
		Duel.SendtoDeck(hg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end