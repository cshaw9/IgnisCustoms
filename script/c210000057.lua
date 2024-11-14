-- Abjection of the Rainbow Realm
local s,id,o=GetID()
-- c210000057
function s.initial_effect(c)
	-- If you control a face-up Continuous Trap Card, you can activate this card from your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetCondition(s.e1con)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	When your opponent activates a card or effect that targets a card(s) you control,
	while “Rainbow Realm of Doom” is face-up on the field:
	Negate the activation, and if you do, destroy it.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,(id+0))
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	During your opponent’s Battle Phase: You can banish this card from your GY;
	you take no battle damage for the rest of this turn.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,(id+1))
	e3:SetHintTiming(TIMING_BATTLE_START)
	e3:SetCondition(s.e3con)
	e3:SetCost(aux.bfgcost)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e1fil(c)
	return c:IsFaceup()
	and c:IsContinuousTrap()
end
function s.e1con(e)
	return Duel.IsExistingMatchingCard(s.e1fil,0,LOCATION_SZONE,0,1,nil)
end
function s.e2fil(c,tp)
	return c:IsOnField()
	and c:IsControler(tp)
end
function s.e2con(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end

	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg
	and tg:IsExists(s.e2fil,1,nil,tp)
	and Duel.IsChainNegatable(ev)
	and Duel.IsEnvironment(210000046)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.e2evt(e,tp,eg,ep,ev,re)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.e3con(e,tp)
	return (Duel.GetCurrentPhase()==PHASE_BATTLE_START or Duel.IsBattlePhase())
	and Duel.IsTurnPlayer(1-tp)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()

	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD)
	e3a:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3a:SetTargetRange(1,0)
	e3a:SetValue(1)
	e3a:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e3a,tp)

	local e3b=Effect.CreateEffect(c)
	e3b:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
	e3b:SetReset(RESET_PHASE|PHASE_END)
	e3b:SetTargetRange(1,0)
	Duel.RegisterEffect(e3b,tp)
end