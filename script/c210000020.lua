--Polyworld
local s,id,o=GetID()
-- c210000020
function s.initial_effect(c)
	-- [Activation]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- The ATK / DEF of all “Polygod” monsters on the field become equal to the combined total of their original ATK / DEF.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xce1))
	e2:SetValue(s.e2val)
	c:RegisterEffect(e2)
	
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD)
	e2b:SetCode(EFFECT_SET_DEFENSE)
	e2b:SetRange(LOCATION_FZONE)
	e2b:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2b:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xce1))
	e2b:SetValue(s.e2bval)
	c:RegisterEffect(e2b)
	-- If a “Polygod” monster is destroyed by battle, banish both that destroyed monster and the monster that destroyed it.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	-- [FIX] : QUICK_O >> TRIGGER_O
	[SOPT]
	Once per turn, when a “Polygod” card(s) on the field is targeted by a card effect:
	You can banish those targeted cards until the End Phase.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_BECOME_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
end
function s.e2val(e,c)
	return c:GetBaseAttack() + c:GetBaseDefense()
end
function s.e2bval(e,c)
	return c:GetBaseAttack() + c:GetBaseDefense()
end
function s.e3fil(c)
	return c:IsSetCard(0xce1)
end
function s.e3con(e,tp,eg)
	return eg:IsExists(s.e3fil,1,nil)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local ac=Duel.GetAttacker()
	local dc=e:GetHandler()

	if chk==0 then
		return Duel.GetAttackTarget()~=nil
	end

	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
function s.e3evt(e,tp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
function s.e4fil(c)
	return c:IsSetCard(0xce1)
	and c:IsOnField()
	and not c:IsCode(id)
end
function s.e4con(e,tp,eg)
	return eg:Filter(s.e4fil, nil):GetCount()==eg:GetCount()
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(s.e4fil,1,nil)
	end
	
	e:SetLabelObject(eg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0)
end
function s.e4evt(e,tp)
	local g=e:GetLabelObject()
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
		local c=e:GetHandler()
		for tc in aux.Next(og) do
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		og:KeepAlive()

		local e4b=Effect.CreateEffect(c)
		e4b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4b:SetCode(EVENT_PHASE+PHASE_END)
		e4b:SetLabelObject(og)
		e4b:SetCountLimit(1)
		e4b:SetCondition(s.e4bcon)
		e4b:SetOperation(s.e4bevt)
		e4b:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e4b,tp)
	end
end
function s.e4bfil(c)
	return c:GetFlagEffect(id)==1
end
function s.e4bcon(e)
	return e:GetLabelObject():IsExists(s.e4bfil,1,nil)
end
function s.e4bevt(e)
	local c=e:GetHandler()
	Card.ResetFlagEffect(c,id)

	local g=e:GetLabelObject():Filter(s.e4bfil,nil)
	for tc in aux.Next(g) do
		Duel.ReturnToField(tc)
	end
end