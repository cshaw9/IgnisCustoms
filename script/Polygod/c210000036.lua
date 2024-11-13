--Veneficus, The Polygod Warlock
local s,id,o=GetID()
-- c210000036
function s.initial_effect(c)
	-- 1 “Polygod” Tuner + 1+ non-Tuner “Polygod” monsters
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xce1),1,1,Synchro.NonTunerEx(Card.IsSetCard,0xce1),1,99)
	c:EnableReviveLimit()
	--[[
	When this card is Synchro Summoned: You can shuffle all cards from both players’ banishment into the Deck,
	and if you do, this card gains ATK equal to the number of cards shuffled into the Deck by this effect x 300.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	When your opponent activates a Spell / Trap Card (Quick Effect):
	You can banish 1 “Polygod” monster from your hand; negate the activation, and if you do, destroy it.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,(id+0))
	e2:SetCondition(s.e2con)
	e2:SetCost(s.e2cst)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1con(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_REMOVED,LOCATION_REMOVED)>0
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	local ct=Duel.GetFieldGroupCount(tp,LOCATION_REMOVED,LOCATION_REMOVED)

	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,ct*300)
end
function s.e1evt(e,tp)
	local g=Duel.GetFieldGroup(tp,LOCATION_REMOVED,LOCATION_REMOVED)
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if ct>0 then
		local c=e:GetHandler()

		local e1b=Effect.CreateEffect(c)
		e1b:SetType(EFFECT_TYPE_SINGLE)
		e1b:SetCode(EFFECT_UPDATE_ATTACK)
		e1b:SetValue(ct*300)
		e1b:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1b)
	end
end
function s.e2fil(c)
	return c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and c:IsAbleToRemoveAsCost()
end
function s.e2con(e,tp,eg,ep,ev,re)
	return ep~=tp
	and re:IsHasType(EFFECT_TYPE_ACTIVATE)
	and Duel.IsChainNegatable(ev)
	and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
	and Duel.IsExistingMatchingCard(s.e2fil,0,LOCATION_HAND,0,1,nil)
end
function s.e2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_HAND,0,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)

	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_HAND,0,1,1,nil)
	
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.e2evt(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end