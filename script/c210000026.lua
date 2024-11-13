--Polygod Emergence
local s,id,o=GetID()
-- c210000026
function s.initial_effect(c)
	--[[
	[OOPT]
	Banish 1 “Polygod” monster from your hand or face-up field; add 1 Level 4 “Polygod” monster from your Deck to your hand.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,(id+0))
	e1:SetCost(s.e1cst)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[OOPT]
	If a “Polygod” Synchro Monster(s) you control would be destroyed by battle, you can banish this card from your GY instead.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,(id+0))
	e2:SetTarget(s.e2tgt)
	e2:SetValue(s.e2val)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1fil(c)
	return c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
	and c:IsAbleToRemoveAsCost()
end
function s.e1adfil(c)
	return c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and c:IsLevel(4)
	and c:IsAbleToHand()
end
function s.e1cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)

	local g=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1adfil,tp,LOCATION_DECK,0,1,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.e1evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

	local g=Duel.SelectMatchingCard(tp,s.e1adfil,tp,LOCATION_DECK,0,1,1,nil)
	
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.e2fil(c,tp)
	return c:IsFaceup()
	and c:IsSetCard(0xce1)
	and c:IsType(TYPE_SYNCHRO)
	and c:IsLocation(LOCATION_MZONE)
	and c:IsControler(tp)
	and c:IsReason(REASON_BATTLE)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:IsAbleToRemove()
		and eg:IsExists(s.e2fil,1,nil,tp)
	end
	
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.e2val(e,c)
	return s.e2fil(c,e:GetHandlerPlayer())
end
function s.e2evt(e)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end