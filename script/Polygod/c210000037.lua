--Siriani, The Polygod Caretaker
local s,id,o=GetID()
-- c210000037
function s.initial_effect(c)
	-- 1 “Polygod” Tuner + 1 non-Tuner “Polygod” monster
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xce1),1,1,Synchro.NonTunerEx(Card.IsSetCard,0xce1),1,1)
	c:EnableReviveLimit()
	--[[
	If this card was Synchro Summoned using “Canis, The Polygod Wolf” as Synchro Material,
	other “Polygod” monsters you control cannot be destroyed by card effects. 
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.e1con)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetCode(EFFECT_MATERIAL_CHECK)
	e1b:SetValue(s.e1val)
	e1b:SetLabelObject(e1)
	c:RegisterEffect(e1b)
	-- If this card would be sent to the GY, banish it instead.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(s.e2con)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)

	if not s.global_check then
		s.global_check=true

		local e2b=Effect.GlobalEffect()
		e2b:SetType(EFFECT_TYPE_FIELD)
		e2b:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e2b:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		e2b:SetTarget(aux.TargetBoolFunction(Card.IsCode,id))
		e2b:SetValue(LOCATION_REMOVED)
		Duel.RegisterEffect(e2b,0)
	end
	--[[
	During your Main Phase, while this card is in face-up Defense Position:
	You can change this card to Attack Position,
	and if you do, destroy all Spell / Traps your opponent controls.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e1con(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
function s.e1evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		local e1c=Effect.CreateEffect(c)
		e1c:SetType(EFFECT_TYPE_FIELD)
		e1c:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1c:SetRange(LOCATION_MZONE)
		e1c:SetTargetRange(LOCATION_MZONE,0)
		e1c:SetTarget(s.e1ctgt)
		e1c:SetValue(1)
		e1c:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1c)
	end
end
function s.e1fil(c)
	return c:IsCode(210000002)
end
function s.e1val(e,c)
	local mg=c:GetMaterial()
	if mg:IsExists(s.e1fil,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function s.e1ctgt(e,c)
	return c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and c~=e:GetHandler()
end
function s.e2con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e3con(e,tp,eg)
	return e:GetHandler():IsDefensePos()
	and Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE+LOCATION_FZONE)>0
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE+LOCATION_FZONE)>0
	end

	local g=Duel.GetFieldGroup(tp,0,LOCATION_SZONE+LOCATION_FZONE)

	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()
	if c:IsDefensePos() then
		if Duel.ChangePosition(c,POS_FACEUP_ATTACK)>0 then
			local g=Duel.GetFieldGroup(tp,0,LOCATION_SZONE+LOCATION_FZONE)
			if g:GetCount()>=1 then
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end