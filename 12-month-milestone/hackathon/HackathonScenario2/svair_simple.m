function yp = svair_simple(t,y,beta,beta_v1,beta_v2,beta_R,ai_beta_ratio,gamma,nu_v1,nu_v2,nu_R,ai,ai_V,ai_R,mu,mu_I,mu_IV)

% retrieve current populations
n_var = 1;  % number of viruses simulated
n_vax = 1;
ind  = 1;
S    = y(ind); ind=ind+1;  % original susceptible
SVR  = y(ind); ind=ind+1;  % lost immunity after vaccination or recovery
V1   = y(ind:ind+n_vax-1); ind=ind+n_vax;  % one-dose vaccination
V2   = y(ind:ind+n_vax-1); ind=ind+n_vax;  % fully vaccinated
I    = y(ind:ind+n_var-1); ind=ind+n_var;  % infected
IV   = y(ind:ind+n_var-1); ind=ind+n_var;  % infected even with vaccination
IR   = y(ind:ind+n_var-1); ind=ind+n_var;  % infected again after recovery from a different variant
A    = y(ind:ind+n_var-1); ind=ind+n_var;  % asymptomatic infections
AR   = y(ind:ind+n_var-1); ind=ind+n_var;  % asymptomatic infections after recovery from a different variant
R    = y(ind:ind+n_var-1); ind=ind+n_var;  % recovered
R2   = y(ind); ind=ind+1;  % recovered after getting both variants

% get time-dependent parameters
% [vr1, vr2] = get_vaccine_rate (t);
% no vaccine for the first year
vr1 = 0;
vr2 = 0;

beta_scale = get_beta (t);
beta       = beta*beta_scale;
beta_v1    = beta_v1*beta_scale;
beta_v2    = beta_v2*beta_scale;
beta_R     = beta_R*beta_scale;

% total infectious population
I_total = I+IV+IR+ai_beta_ratio.*(A+AR);
% % need the following to compute infection of recovered from another variant
% mm = ones(n_var+1)-diag(ones(1,n_var+1));
% mv = mm.*repmat(R,1,n_var+1);
Rv = 0; %sum(mv)'; % in simple case, don't consider infection from a different variant

% compute time derivatives
dSdt   = - sum(beta.*S.*(I_total)) - sum(vr1.*S) + mu*(1-S);
dSVRdt = + nu_v1.*sum(V1) + nu_v2.*sum(V2) + sum(nu_R.*R) + nu_R.*R2 - sum(beta.*SVR.*(I_total)) - mu*SVR;
dV1dt  = + vr1.*(S+sum(A)) - vr2.*V1 - nu_v1.*V1 - sum(beta_v1.*(V1*(I_total)'),2) - mu*V1;
dV2dt  = + vr2.*V1 - nu_v2.*V2 - sum(beta_v2.*(V2.*(I_total)'),2) - mu*V2;
dIdt   = (1-ai).*(+ beta.*S.*(I_total) + beta.*SVR.*(I_total)) - gamma.*I - mu_I.*I;
dIVdt  = (1-ai_V).*(+ sum(beta_v1.*(V1*(I_total)'))' + sum(beta_v2.*(V2.*(I_total)'))') - gamma.*IV - mu_IV.*IV;
dIRdt  = (1-ai_R).*(+ beta_R.*Rv.*(I_total)) - gamma.*IR - mu*IR;
dAdt   = ai.*(+ beta.*S.*(I_total) + beta.*SVR.*(I_total)) + ai_V.*(sum(beta_v1.*(V1*(I_total)'))' + sum(beta_v2.*(V2.*(I_total)'))') - sum(vr1).*A - gamma.*A - mu.*A;
dARdt  = ai_R.*(+ beta_R.*Rv.*(I_total)) - gamma.*AR - mu*AR;
dRdt   = + gamma.*(I_total) - nu_R.*R - beta_R.*Rv.*(I_total) - mu*R;
dR2dt  = + sum(gamma.*(IR+AR)) - nu_R.*R2 - mu*R2;

yp = [dSdt;dSVRdt;dV1dt;dV2dt;dIdt;dIVdt;dIRdt;dAdt;dARdt;dRdt;dR2dt];


