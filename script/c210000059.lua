-- Rainbow Realm Masterpiece
local s,id,o=GetID()
-- c210000059
function s.initial_effect(c)
	--[[
	[HOPT]
	Add 1 “Rainbow Realm” card from your Deck to your hand, except “Rainbow Realm Masterpiece”.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,(id+0))
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	During your opponent’s Battle Phase: You can banish this card from your GY;
	you take no battle damage for the rest of this turn.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,(id+1))
	e2:SetHintTiming(TIMING_BATTLE_START)
	e2:SetCondition(s.e2con)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1fil(c)
	return c:IsSetCard(0xce2a)
	and not c:IsCode(id)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_DECK,0,1,nil,tp)
	end
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
	return (Duel.GetCurrentPhase()==PHASE_BATTLE_START or Duel.IsBattlePhase())
	and Duel.IsTurnPlayer(1-tp)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2a:SetTargetRange(1,0)
	e2a:SetValue(1)
	e2a:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2a,tp)

	local e2b=Effect.CreateEffect(c)
	e2b:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
	e2b:SetReset(RESET_PHASE|PHASE_END)
	e2b:SetTargetRange(1,0)
	Duel.RegisterEffect(e2b,tp)
end