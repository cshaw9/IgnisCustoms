--Cervus, The Polygod Deer
local s,id,o=GetID()
-- c210000006
function s.initial_effect(c)
	-- Unaffected by Trap effects.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.e1fil)
	c:RegisterEffect(e1)
	--[[
	You can banish this card you control; Special Summon 1 Level 4 “Polygod” monster from your banishment, except “Cervus, The Polygod Deer”,
	and if you do, it gains ATK equal to the ATK this card had on the field, until the end of this turn.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.e2cst) -- aux.bfgcost
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1fil(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
function s.e2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetAttack()
	e:SetLabel(atk)
	if chk==0 then return true end
end
function s.e2fil(c,e,tp)
	return c:IsSetCard(0xce1)
	and not c:IsCode(id)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and c:GetLevel()==4
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_REMOVED,0,1,nil,e,tp)
	end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,e:GetLabel())
end
function s.e2evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local c=e:GetHandler()

		local e2b=Effect.CreateEffect(c)
		e2b:SetType(EFFECT_TYPE_SINGLE)
		e2b:SetCode(EFFECT_UPDATE_ATTACK)
		e2b:SetValue(e:GetLabel())
		e2b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sc:RegisterEffect(e2b)
	end
end