
=  Synthetic data creation
(~5 pages)

Explain how synthetic observations are made, why they are considered, the components of it, and the process (a figure would be nice), comparing the performance of existing algos.

== Primary UVW syntheis

==== Synoptic Background Profile
The synoptic background profile models the smooth logarithmic atmospheric boundary layer wind shear near the surface, decaying exponentially with altitude in the troposphere.

$ u_"bl" = (u^*_"bg" / kappa_"bg") log((z_m + z_"bg") / z_"bg") exp(-h / L_"bg") $ <eq_sgp>

- $h$ : Height bins [km]
- $z_m$ : Height in meters, $z_m = h dot 1000$ [m]
- $z_"bg"$ : Surface roughness length for terrain [0.05 m]
- $u^*_"bg"$ : Friction velocity representing surface stress [0.3 m/s]
- $kappa_"bg"$ : von Kármán constant [0.4]
- $L_"bg"$ : Boundary layer height scale [1.5 km]

==== Low-Level Somali Jet
The low-level Somali jet models the intense cross-equatorial onshore South-West monsoon flow in the lower troposphere using a Gaussian vertical velocity core centered near 1.5 km altitude.

$ u_"llj" = u_"sj" exp[- ((h - z_"sj") \/ sigma_"sj")^2] \
v_"llj" = v_"sj" exp[- ((h - z_"sj") \/ sigma_"sj")^2] $ <eq_llsj>

- $u_"sj"$ : Zonal onshore wind speed of the SW monsoon jet [12 m/s]
- $v_"sj"$ : Meridional onshore wind speed of the SW monsoon jet [14 m/s]
- $z_"sj"$ : Altitude of the jet core center [1.5 km]
- $sigma_"sj"$ : Gaussian vertical thickness scale of the jet [0.8 km]

==== Tropical Easterly Jet (TEJ)
The Tropical Easterly Jet represents the strong upper-tropospheric easterly (westward) jet stream near the tropopause during the summer monsoon season.

$ u_"tej" = u_"tej,core" exp[- ((h - z_"tej") \/ sigma_"tej")^2] \
 v_"tej" = v_"tej,core" exp[- ((h - z_"tej") \/ sigma_"tej")^2] $ <eq_tej>

- $u_"tej,core"$ : Peak zonal easterly jet core speed [35 m/s]
- $v_"tej,core"$ : Peak meridional jet core speed [3 m/s]
- $z_"tej"$ : TEJ core altitude [15.0 km]
- $sigma_"tej"$ : TEJ core vertical layer thickness scale [2.5 km]

==== Stratospheric Quasi-Biennial Oscillation (QBO)
The Quasi-Biennial Oscillation simulates downward-propagating alternating zonal and meridional wind regimes in the tropical stratosphere using a sinusoidal wave envelope activated above the tropopause.

$ u_"qbo" &= u^*_"qbo" sin[2 pi (h - z_"qbo") \/ lambda_"qbo"] dot E_"qbo" \
v_"qbo" &= v^*_"qbo" cos[2 pi (h - z_"qbo") \/ lambda_"qbo"] dot E_"qbo" $<eq_qbo>

Where $ E_"qbo" = 1/2 [1 + tanh((h - z_"qbo") \/ 2)] $
and
- $z_"qbo"$ : Altitude of QBO onset region [17 km]
- $lambda_"qbo"$ : Vertical wavelength of alternating wind regimes [20 km]
- $u^*_"qbo"$ : Peak zonal amplitude of QBO phase shifts [8 m/s]
- $v^*_"qbo"$ : Peak meridional amplitude of QBO phase shifts [3 m/s]

==== Orographic Updraft
The orographic updraft models forced vertical lifting over mountainous terrain features (e.g., Western Ghats ridge) proportional to the mean zonal flow and decaying exponentially with height.

$ w_"oro" = max(0, u_"mean") dot tan(alpha_"slope") exp(-h / H_"lift") $<eq_oro>

- $u_"mean"$ : Mean zonal wind profile [m/s]
- $alpha_"slope"$ : Western Ghats ridge terrain slope angle [$"arctan"(1.5 \/ 30.0) approx 0.05$ rad]
- $H_"lift"$ : Vertical decay scale for atmospheric lifting [3.5 km]

==== Continuous Gravity Wave Spectrum
Continuous gravity waves synthesize atmospheric wave perturbations across multiple vertical modes, incorporating amplitude growth with height (density scale height) and high-altitude damping.

$ u_"gw" &= A_"gw"dot A(h) dot "norm"[thin sum_(i=1)^(N_"modes") sqrt(E(m_i)) cos(m_i h + phi.alt_(u,i))] \
v_"gw" &= A_"gw"dot A(h) dot "norm"[thin sum_(i=1)^(N_"modes") sqrt(E(m_i)) sin(m_i h + phi.alt_(v,i))] \
w_"gw" &= -c_f dot u_"gw" $ <eq_cgw>
Where $m_i$ is vector of wavenumbers that range from $lambda_max$ to 0.4km across $N_"modes"$ bins  and  
$ A(h) = exp(h / (2 H_s) -h / h_"damp") #h(2cm)  E(m_i) = (m_i^(-1.5)) / (sum_j m_j^(-1.5)) $
is the normalized spectral energy density distribution across vertical wavenumbers. 

- $h$ : Height bins [in km]
- $N_"modes"$ : Number of continuous gravity wave spectrum modes [20]
- $A_"gw"$ : Scaling factor for horizontal gravity wave velocity [2.5 m/s]
- $lambda_"max"$ : Upper limit for gravity wave vertical scale [4.0 km]
- $h_"damp"$ : Damping scale height to control upper atmospheric amplitude [12.0 km]
- $c_f$ : Coupling factor deriving vertical wave speed from horizontal wave speed [0.05]
- $H_s$ : Density scale height for wave amplification [7.0 km]
- $phi.alt_(u,i), phi.alt_(v,i)$: vector of random initial phase shifts ($phi.alt in [0, 2pi)$)

==== Convective Thermal Plumes
Convective thermal plumes generate localized vertical updrafts and downdrafts caused by surface solar heating and thermal buoyancy in the lower troposphere.
$ w_"plumes" (h) = sum_(p=1)^(N_"plumes") w_"peak" (p) exp[- ((z - h_"center" (p)) / (w_"width" (p)))^2] $<eq_plume>

- $N_"plumes"$ : Number of random convective updrafts/downdrafts [4]
- $H_"max"$ : Maximum altitude ceiling for thermal plumes [6.0 km]
- $h_"center" (p)$ : Altitude center of plume $p$, drawn randomly between 0.8 km and  $H_"max"$
- $w_"peak" (p)$ : Peak vertical velocity for plume $p$, drawn randomly between -0.75 and 1.75 
- $w_"width" (p)$ : Vertical thickness scale of plume $p$, drawn randomly between 0.2 km and 0.6 km

==== Kolmogorov Turbulence and Intermittency
Kolmogorov turbulence introduces sub-grid scale velocity perturbations. It takes generated mean zonal and meridional wind profile profiles ($dash(u), dash(v)$) and adds this terms also.

$ u_("kt") &= hat(u)_"raw" dot sigma_"turb" \
v_("kt") &= hat(v)_"raw" dot sigma_"turb" \
w_("kt") &= hat(w)_"raw" dot sigma_"turb" dot alpha_"vaf" $ <eq_kolturb>
Where: 
$ sigma_"turb" = [0.15 + 0.4 "norm"(sqrt(S))] dot T_"boost" dot W_"interm" $

$ S = ((d dash(u)) / (d h))^2 + ((d dash(v)) / (d h))^2 + epsilon $
$ T_"boost" = cases(
  B_"kt" + B_"kt,max" dot exp[- ((h - H_"turb") \/ d_"turb")^2]  #h(1cm)&"Ri" < "Ri"_c,
  B_"kt"  &"Ri" >= "Ri"_c,
) $
$ "Ri" = (N_"bv"^2) \/ S^2 $
$ W_"interm" = exp(- 1/2 sigma_"interm"^2 + sigma_"interm" dot hat(u)_"raw") $

- $N_"bv"$ : Brunt-Väisälä buoyancy frequency [0.012 rad/s]
- $"Ri"_c$ : Critical Richardson number threshold for dynamic instability [0.25]
- $B_"kt,max"$ : Maximum turbulence boost factor under instability [2.5]
- $B_"kt"$ : Baseline factor for turbulence scaling [1.0]
- $H_"turb"$ : Turbulent layer peak altitude [3.0 km]
- $d_"turb"$ : Vertical thickness scale of turbulent layer [2.5 km]
- $sigma_"interm"$ : Intermittency parameter for log-normal weighting [0.5]
- $alpha_"vaf"$ : Vertical anisotropy scaling factor [0.25]
- $hat(u)_"raw", hat(v)_"raw", hat(w)_"raw"$: random initial u,v,w velocities
==== Combining all factors
Final u,v,w is given by:
$ u &= (dash(u) + u_"gw" + u_"kt")'\
v &= (dash(v) + v_"gw" + v_"kt")'\
w &= (w_"oro" + w_"gw" + w_"plumes" + w_"kt")' $ <eq_finaluvw>

And
$
dash(u) &= [u_"llj" + u_"bl" + u_"tej" + u_"qbo"] J \
dash(v) &= [v_"llj" + v_"tej" + v_"qbo"] J
$
$J$ is some extra jitter added
== Spectrum broadening

@Nathanson

$ sigma_v = sqrt(sigma_"shear" ^ 2 + sigma_"beam" ^ 2 + sigma_t ^ 2) $

Wind shear:
$ sigma_"shear" = (d v)/(d z) thin (Delta r) / sqrt(12) $

Beam Broadening:
$  sigma_"beam" = "HPBW" / (4 sqrt(ln 2)) thin abs(v_"cross") $


Where $v_"cross"$ is wind component perpendicular to the beam axis given by:
$ v_"cross" = sqrt(U^2 + V^2 + W^2 - v_"radial"^2)  $

HPBW = $3.3degree$ @titu


Turbulance: $sigma_"t" = 0.6 "m/s"$

== DC clutter
DC spectra is modeled as a gaussian distribution with peak amplitude scaled by $r_"DC"$ times total power of that height range ($P_S = P_"signal" + P_"noise"$) with spectral width $sigma_"DC"$ which is again normally distributed random variable. This spectra is added to signal to finally obtain BeamData
$ S_"DC" (f, h) =  r_"DC" P_S  exp[-f^2 / (2 sigma_"DC"^2 (h))](exp[h/N] - 0.7) $ <eq_dc_clut>
Where $N$ is number of range bins.
#show heading.where(level: 1): it => [
  #pagebreak()
  #align(center)[
    #it.body
  ]
]

== Bright band
Similar to DC clutter, bright bands are also modeled by stretched gaussian distribution.
$ S_"bb" (f, h) = P_S dot 10 ^ (-3.5) dot  chi_N dot exp(-f^2 / (2 sigma_"bb"^2 (h))) $ <eq_bb>
$chi_N$ is random variable sampled from range [1, 1.333].  $sigma_"bb"^2 (h)$ is spectral width of bright band. $10 ^ (-3.5)$ is chosen to account for -30 to -40dB reflectivity of bright band