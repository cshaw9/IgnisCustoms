--Equus, The Polygod Pegasus
local s,id,o=GetID()
-- c210000005
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
	[HOPT]
	When this card declares an attack: You can change it to face-up Defense Position,
	and if you do, Special Summon 1 “Polygod” monster from your Extra Deck in Attack Position,
	but destroy it at the end of the Battle Phase.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,(id+0))
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e2fil(c,e,tp)
	return c:IsSetCard(0xce1)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
	and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		local req=true

		local repl=c:GetEquipGroup():Filter(Card.IsCode,nil,210000024)
		if repl:GetCount()>0 then
			if not Duel.SelectEffectYesNo(tp,repl:GetFirst()) then
				Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
			end
		else
			req=Duel.ChangePosition(c,POS_FACEUP_DEFENSE)>0
		end

		if req then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				local tc=g:GetFirst()
				if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)>0 then
					local fid=c:GetFieldID()
					tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)

					local e2b=Effect.CreateEffect(c)
					e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					e2b:SetCode(EVENT_PHASE+PHASE_BATTLE)
					e2b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
					e2b:SetCountLimit(1)
					e2b:SetLabel(fid)
					e2b:SetLabelObject(tc)
					e2b:SetCondition(s.e2bcon)
					e2b:SetOperation(s.e2bevt)
					e2b:SetReset(RESET_PHASE+PHASE_END)
					Duel.RegisterEffect(e2b,tp)
				end
			end
		end
	end
end
function s.e2bcon(e)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(id)==e:GetLabel()
end
function s.e2bevt(e)
	local tc=e:GetLabelObject()
	Duel.Destroy(tc,REASON_EFFECT)
end