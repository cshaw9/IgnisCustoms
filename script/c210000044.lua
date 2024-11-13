--Nefas, The Polygod Abomination
local s,id,o=GetID()
-- c210000044
function s.initial_effect(c)
	-- 2+ Level 4 “Polygod” monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xce1),4,2,nil,nil,99)
	c:EnableReviveLimit()
	--[[
	[FIX]
	This card on the field can be treated as a monster whose Level is equal to
	the number of Level 4 monsters attached to this card as material x 4
	when used as material for the Synchro Summon of a "Polygod" Synchro Monster.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_LEVEL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetValue(s.e1val)
	c:RegisterEffect(e1)
	--[[
	If this face-up card on the field has no material, banish it.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCondition(s.e2con)
	c:RegisterEffect(e2)

	local e2b=Effect.CreateEffect(c)
	e2b:SetCategory(CATEGORY_REMOVE)
	e2b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2b:SetCode(EVENT_LEAVE_FIELD)
	e2b:SetRange(LOCATION_GRAVE)
	e2b:SetCondition(s.e2bcon)
	e2b:SetOperation(s.e2bevt)
	c:RegisterEffect(e2b)
	--[[
	[SOPT]
	Once per turn, during your Standby Phase: Detach 1 material from this card;
	Special Summon 1 "Polygod" Tuner from your Deck or GY,
	but negate its effects, also, destroy it during the End Phase.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.e3con)
	e3:SetCost(s.e3cst)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e1fil(c)
	return c:IsType(TYPE_MONSTER)
	and c:GetLevel()==4
end
function s.e1val(e,_,rc)
	local c=e:GetHandler()
	--sc:IsSetCard(0xce1)
	return c:GetOverlayGroup():Filter(s.e1fil, nil):GetCount()*4
end
function s.e2con(e)
	return e:GetHandler():GetOverlayCount()==0
end
function s.e2bcon(e,tp,eg,ep,ev,re)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c==re:GetHandler()
end
function s.e2bevt(e)
	local c=e:GetHandler()
	Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
end
function s.e3con(e,tp)
	return tp==Duel.GetTurnPlayer()
end
function s.e3cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	end
	
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.e3fil(c,e,tp)
	return c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and c:IsType(TYPE_TUNER)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.e3evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e3fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			local c=e:GetHandler()
			local fid=c:GetFieldID()

			local e3b=Effect.CreateEffect(c)
			e3b:SetType(EFFECT_TYPE_SINGLE)
			e3b:SetCode(EFFECT_DISABLE)
			e3b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e3b:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3b)

			local e3c=Effect.CreateEffect(c)
			e3c:SetType(EFFECT_TYPE_SINGLE)
			e3c:SetCode(EFFECT_DISABLE_EFFECT)
			e3c:SetValue(RESET_TURN_SET)
			e3c:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e3c:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3c)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)

			local e3d=Effect.CreateEffect(c)
			e3d:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3d:SetCode(EVENT_PHASE+PHASE_END)
			e3d:SetCountLimit(1)
			e3d:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e3d:SetLabel(fid)
			e3d:SetLabelObject(tc)
			e3d:SetCondition(s.e3d1con)
			e3d:SetOperation(s.e3d1evt)
			Duel.RegisterEffect(e3d,tp)
		end
		Duel.SpecialSummonComplete()
	end
end
function s.e3d1con(e)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
function s.e3d1evt(e)
	local tc=e:GetLabelObject()
	Duel.Destroy(tc,REASON_EFFECT)
end