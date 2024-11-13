--Polygod Dimensional Explosion
local s,id,o=GetID()
-- c210000030
function s.initial_effect(c)
	--[[
	When an opponent’s monster declares a direct attack:
	Special Summon as many “Polygod” monsters as possible from your banishment, but negate their effects.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
function s.e1fil(c,e,tp)
	return c:IsFaceup()
	and c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e1con(e,tp)
	return tp~=Duel.GetTurnPlayer() and Duel.GetAttackTarget()==nil
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_REMOVED,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.e1evt(e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)

	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_REMOVED,0,ft,ft,nil,e,tp)
	if g:GetCount()>0 then
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		local tc=g:GetFirst()
		while tc do
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				local e1b=Effect.CreateEffect(c)
				e1b:SetType(EFFECT_TYPE_SINGLE)
				e1b:SetCode(EFFECT_DISABLE)
				e1b:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1b)
				local e1c=Effect.CreateEffect(c)
				e1c:SetType(EFFECT_TYPE_SINGLE)
				e1c:SetCode(EFFECT_DISABLE_EFFECT)
				e1c:SetValue(RESET_TURN_SET)
				e1c:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1c)
			end

			tc=g:GetNext()
		end
		Duel.SpecialSummonComplete()
	end
end
