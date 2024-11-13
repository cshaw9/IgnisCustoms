--Ursa, The Polygod Bear
local s,id,o=GetID()
-- c210000008
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
	Once per Chain, if a “Polygod” monster(s) is banished (except during the Damage Step):
	You can target 1 monster your opponent controls; destroy it,
	and if you do, change this card to face-up Defense Position during the End Phase.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e2fil(c)
	return c:IsFaceup()
	and c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
end
function s.e2con(e,tp,eg)
	return eg:IsExists(s.e2fil,1,nil)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(1-tp)
	end
	if chk==0 then
		return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	end
	
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.e2evt(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
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