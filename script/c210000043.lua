--Bestia, The Polygod Zoo
local s,id,o=GetID()
-- c210000043
function s.initial_effect(c)
	-- 2 Level 4 “Polygod” monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xce1),4,2)
	c:EnableReviveLimit()
	--[[
	[HOPT/HTPT]
	When your opponent activates a card or effect (Quick Effect):
	You can negate that effect, and if you do, attach it to this card as material.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	--e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1,true)
	--[[
	[HOPT]
	You can detach 1 material from this card;
	Special Summon 1 Level 4 "Polygod" Beast monster from your Deck.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.e2cst)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1con(e,tp,eg,ep,ev,re,r,rp)
	local tpt=Duel.GetFlagEffect(tp, id)<1
	if Duel.IsEnvironment(210000037) then
		tpt=Duel.GetFlagEffect(tp, id)<2
	end

	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
	and rp==1-tp
	and Duel.IsChainDisablable(ev)
	and tpt
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)

	Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.e1evt(e,tp,eg,ep,ev,re)
	local c=e:GetHandler()
	local tc=re:GetHandler()
	if Duel.NegateEffect(ev) and tc:IsRelateToEffect(re) and tc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT) and c:IsType(TYPE_XYZ) then
		tc:CancelToGrave()
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
function s.e2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
	end
	
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.e2fil(c,e,tp)
	return c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and c:IsRace(RACE_BEAST)
	and c:GetLevel()==4
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.e2evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end