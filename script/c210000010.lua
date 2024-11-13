--Piscis, The Polygod Fish
local s,id,o=GetID()
-- c210000010
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
	During your Main Phase, while this card is in Attack Position: You can target 1 “Polygod” monster you control;
	change this card to face-up Defense Position,
	and if you do, that target can be treated as a Tuner if used as Synchro Material for the Synchro Summon of “Polygod” Synchro Monster this turn.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,(id+0))
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If this card is banished face-up to activate an effect, or by an effect, except its own: You can Special Summon it.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,(id+1))
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e1con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e2con(e)
	return e:GetHandler():IsAttackPos()
end
function s.e2fil(c)
	return c:IsFaceup()
	and c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and not c:IsType(TYPE_TUNER)
	and c:IsCanBeSynchroMaterial()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(tp)
		and s.e2fil(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e2fil,tp,LOCATION_MZONE,0,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.e2fil,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
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
				local e2b=Effect.CreateEffect(c)
				e2b:SetType(EFFECT_TYPE_SINGLE)
				e2b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e2b:SetCode(30765615) -- Code : 30765615
				e2b:SetRange(LOCATION_MZONE)
				e2b:SetValue(s.e2bval)
				e2b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2b)
			end
		end
	end
end
function s.e2bval(e,sc)
	return e:GetHandler():IsControler(sc:GetControler()) and sc:IsSetCard(0xce1)
end
function s.e3con(e,tp,eg,ep,ev,re)
	local c=e:GetHandler()

	return (c:IsReason(REASON_EFFECT) or c:IsReason(REASON_COST))
	and re:IsHasType(0x7f0)
	and c~=re:GetHandler()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end