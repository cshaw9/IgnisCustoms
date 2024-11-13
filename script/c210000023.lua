--The Polygod Dimensional Portal
local s,id,o=GetID()
-- c210000023
function s.initial_effect(c)
	-- [Activation]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- If this card on the field is destroyed, banish it.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.e2con)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	-- If a “Polygod” card(s) is banished: You can shuffle 2 other “Polygod” cards from your banishment into the Deck.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	[HOPT]
	If this card is banished: You can return it to the GY, then Special Summon 1 “Polygod” monster from your banishment.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,(id+0))
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
end
function s.e2con(e)
	local c=e:GetHandler()

	return c:IsReason(REASON_DESTROY)
	and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e2evt(e)
	local c=e:GetHandler()
	Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
end
function s.e3fil(c)
	return c:IsFaceup()
	and c:IsSetCard(0xce1)
end
function s.e3rdfil(c,e,tp,eg)
	return c:IsFaceup()
	and c:IsSetCard(0xce1)
	and c:IsAbleToDeck()
	and not eg:IsContains(c)
end
function s.e3con(e,tp,eg,ep,ev,re)
	local g=Duel.GetMatchingGroup(s.e3rdfil,tp,LOCATION_REMOVED,0,nil,e,tp,eg)

	return eg:IsExists(s.e3fil,1,nil)
	and g:GetCount()>=2
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.e3rdfil,tp,LOCATION_REMOVED,0,nil,e,tp,eg)

	if chk==0 then
		return g:GetCount()>=2
	end

	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
function s.e3evt(e,tp,eg,ep,ev,re)
	local g=Duel.GetMatchingGroup(s.e3rdfil,tp,LOCATION_REMOVED,0,nil,e,tp,eg)
	if g:GetCount()>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sel = Group.Select(g,tp,2,2,nil)
		Duel.SendtoDeck(sel,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end
function s.e4fil(c,e,tp)
	return c:IsFaceup()
	and c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e4con(e,tp)
	local g=Duel.GetMatchingGroup(s.e4fil,tp,LOCATION_REMOVED,0,nil,e,tp)
	
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>=1
	and g:GetCount()>0
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e4fil,tp,LOCATION_REMOVED,0,1,nil,e,tp)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.e4evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end

	if Duel.SendtoGrave(e:GetHandler(), REASON_EFFECT)>0 then
		Duel.BreakEffect()

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.e4fil,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end