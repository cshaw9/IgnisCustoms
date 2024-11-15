-- Banishite Castle
local s,id,o=GetID()
-- c210000077
function s.initial_effect(c)
	--[[
	[HAPT]
	Add 1 “Banishite King” and 1 “Banishite Queen” from your Deck to your hand.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
function s.e1fil1(c)
	return c:IsCode(210000066)
	and c:IsAbleToHand()
end
function s.e1fil2(c)
	return c:IsCode(210000067)
	and c:IsAbleToHand()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1fil1,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(s.e1fil2,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.e1evt(e,tp)
	local g=Group.CreateGroup()
	local tg1=Duel.GetFirstMatchingCard(s.e1fil1,tp,LOCATION_DECK,0,nil)
	if tg1 then
		g:AddCard(tg1)
	end

	local tg2=Duel.GetFirstMatchingCard(s.e1fil2,tp,LOCATION_DECK,0,nil)
	if tg2 then
		g:AddCard(tg2)
	end
	
	if g:GetCount()==2 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end