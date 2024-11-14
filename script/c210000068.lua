-- Banishite Kingsguard
local s,id,o=GetID()
-- c210000068
function s.initial_effect(c)
	-- Your opponent cannot target cards you control with card effects, except this one.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTarget(s.e1tgt)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--[[
	You can banish this card you control; Special Summon 1 monster from either banishment,
	also, negate any card effect that would move this card from the banishment to a different place,
	except if this card would be shuffled into the Main Deck.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1tgt(e,tc)
	return tc~=e:GetHandler() 
end
function s.e2fil(c,e,tp)
	return c:IsMonster()
	and c:IsFaceup()
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and c~=e:GetHandler()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	local e2b1=Effect.CreateEffect(c)
	e2b1:SetType(EFFECT_TYPE_SINGLE)
	e2b1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2b1:SetRange(LOCATION_REMOVED)
	e2b1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2b1)

	local e2b2=e2b1:Clone()
	e2b2:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e2b2)

	local e2b3=e2b1:Clone()
	e2b3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	c:RegisterEffect(e2b3)

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end