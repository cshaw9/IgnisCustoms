-- Wanderer of the Rainbow Realm
local s,id,o=GetID()
-- c210000063
function s.initial_effect(c)
	--[[
	[HOPT]
	You can discard this card;
	Add 1 “Rainbow Realm of Doom”, or 1 card that mentions it, from your Deck to your hand, except “Wanderer of the Rainbow Realm”.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.e1con)
	e1:SetCost(s.e1cst)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	When an opponent’s monster declares a direct attack (Quick Effect):
	You can shuffle this card from your GY into the Deck; negate the attack.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.e2con)
	e2:SetCost(s.e2cst)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1fil(c)
	return c:IsSetCard(0xce2c)
	and not c:IsCode(id)
	and c:IsAbleToHand()
end
function s.e1con(e)
	return Duel.IsExistingMatchingCard(s.e1fil,0,LOCATION_DECK,0,1,nil)
end
function s.e1cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:IsDiscardable()
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.e1evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

	local g=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_DECK,0,1,1,nil)
	
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.e2con(e,tp)
	return Duel.GetAttacker():IsControler(1-tp)
	and Duel.GetAttackTarget()==nil
end
function s.e2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:IsAbleToDeckAsCost()
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.e2evt(e)
	Duel.NegateAttack()
end