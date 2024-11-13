--Serpens, The Polygod Snake
local s,id,o=GetID()
-- c210000003
function s.initial_effect(c)
	-- If this card would be sent to the GY, banish it instead.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(s.e1con)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)

	if not s.global_check then
		s.global_check=true

		local e1b=Effect.GlobalEffect()
		e1b:SetType(EFFECT_TYPE_FIELD)
		e1b:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e1b:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		e1b:SetTarget(aux.TargetBoolFunction(Card.IsCode,id))
		e1b:SetValue(LOCATION_REMOVED)
		Duel.RegisterEffect(e1b,0)
	end
	--[[
	[HTPT]
	If your opponent Special Summons a monster(s) (except during the Damage Step): You can Special Summon 1 “Polygod” monster from your banishment,
	and if you do, change this card to face-up Defense Position during the End Phase.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(2,(id+0))
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e2con(e,tp,eg)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.e2fil(c,e,tp)
	return c:IsSetCard(0xce1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_REMOVED,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.e2evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			local c=e:GetHandler()
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)

			local e2b=Effect.CreateEffect(c)
			e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2b:SetCode(EVENT_PHASE+PHASE_END)
			e2b:SetRange(LOCATION_MZONE)
			e2b:SetCountLimit(1)
			e2b:SetCondition(s.e2bcon)
			e2b:SetOperation(s.e2bevt)
			e2b:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2b,tp)
		end
	end
end
function s.e2bcon(e)
	return e:GetHandler():GetFlagEffect(id)==1
end
function s.e2bevt(e,tp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		local repl=c:GetEquipGroup():Filter(Card.IsCode,nil,210000024)
		if repl:GetCount()>0 then
			if not Duel.SelectEffectYesNo(tp,repl:GetFirst()) then
				Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
			end
		else
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
end