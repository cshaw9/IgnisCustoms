--Shinu, The Polygod Veiler
local s,id,o=GetID()
-- c210000016
function s.initial_effect(c)
	--[[
	[HOPT]
	When your opponent activates a monster effect, or Spell / Trap Card, while you control a “Polygod” monster (Quick Effect): You can banish this card from your hand;
	negate the activation, and if you do, destroy it.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.e1con)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
function s.e1fil(c)
	return c:IsSetCard(0xce1)
	and c:IsFaceup()
end
function s.e1con(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end

	local g=Duel.GetMatchingGroup(s.e2fil,tp,LOCATION_MZONE,0,nil,e,tp)
	
	return rp==(1-tp)
	and g:GetCount()>=1
	and Duel.IsChainNegatable(ev)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.e1evt(e,tp,eg,ep,ev,re)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end