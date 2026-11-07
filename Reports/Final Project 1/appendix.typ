#pagebreak();
#set page(
  margin: 1.2in,
  header: [],
  footer: context {
    align(center)[
      #text(size: 10pt)[
        #counter(page).display()
      ]]
  },
)
#heading(level: 1, numbering: none)[Appendix]
#counter(heading).update(1)
#set heading(numbering: "A.1.1")
== Source code
#box(
  width: 100%,
  stroke: 1pt,
  inset: 20pt,
)[
  #align(center)[
    Entire MATLAB implementations of the algorithms are available in \
    #link("https://github.com/roopeshor/Radar-Signal-Processing", text(
      weight: "bold",
      font: "Fira Mono",
    )[` https://github.com/roopeshor/Radar-Signal-Processing `])
  ]]
Below is the implementation of MCCF and IME \
#show raw: set text(size: 9pt, font: "DM Mono");
#show raw: set par(leading: 6pt);
=== MCCF
```
function new_beam = compute_all_params(beam, cfg)
arguments (Input)
	beam RadarData
	cfg.prev_frame_peaks (1,:) double = []
		cfg.apply_mclms (1,1) logical = true
		cfg.win_coeff (1,1) double = 2
		cfg.wind_shear (1,1) double = 1
		cfg.velocity_res (1,1) double = 0.06
		cfg.cost_weights (1,2) double = [0.5, 0.5]
end
arguments (Output)
	new_beam RadarData
end
beamData = beam.BeamData;
[height_bins, nfft, ~] = size(beamData);
alpha =cfg.win_coeff;
max_shear =cfg.wind_shear;
dv =cfg.velocity_res;
if (isfield(beam.a_params, "alpha"))
	alpha = beam.a_params.alpha;
end
if (isfield(beam.a_params, "max_shear"))
	max_shear = beam.a_params.max_shear;
end
if (isfield(beam.a_params, "velocity_res"))
	dv = beam.a_params.velocity_res;
end
df = round(max_shear / dv); w1 = cfg.cost_weights(1);
w2 = cfg.cost_weights(2);
mclms_len = 10;                     
cost_scores = zeros(height_bins, nfft);
mclms_denoised_spectra = zeros(height_bins, nfft);
peaks_idx = zeros(height_bins, 1);
F0 = []; 
spectra = fft(beam.BeamData, [], 2);
spectra = mean(spectra, 3);
noise_val = median(abs(spectra), 2);
[height_bins, nfft] = size(spectra);
mask_bins = [1, 2, 3, nfft, nfft-1];
rand_phase = exp(1j * 2 * pi * rand(height_bins, length(mask_bins)));
spectra(:, mask_bins) = noise_val .* rand_phase;
CS = ifft(spectra / max(spectra(:)), [], 2);
ST_W_array = zeros(height_bins, 2);
for r = 1:height_bins
	signal_clean = CS(r, :);
				if r == 1
				ST_W = 1:nfft;
	else
				W1 = max(1, round(F0 - alpha*df)) : min(nfft, round(F0 + alpha*df));
		if ~isempty(cfg.prev_frame_peaks) && length(cfg.prev_frame_peaks) >= r
			T0 = cfg.prev_frame_peaks(r);
						W2 = max(1, round(T0 - alpha*df)) : min(nfft, round(T0 + alpha*df));
			inter_W = intersect(W1, W2);
			if length(inter_W) >= alpha * df
				ST_W = inter_W;
			else
				ST_W = W1;
			end
		else
			ST_W = W1;
		end
	end
	ST_W_array(r, :) = [min(ST_W), max(ST_W)];
			
	seg_len = floor(nfft / 2);
	num_delays = 8;
	step = floor((nfft - seg_len) / (num_delays - 1));
	v_r1 = signal_clean(1:seg_len);
	V_conv = zeros(num_delays - 1, seg_len);
	max_powers = zeros(1, num_delays - 1);
	for d = 2:num_delays
		start_idx = 1 + (d-1)*step;
		v_ri = signal_clean(start_idx : start_idx + seg_len - 1);
		v_ri_hr = conj(v_ri(end:-1:1));
		v_ci = conv(v_r1, v_ri_hr);
				v_ci_center = v_ci(floor(seg_len/2) : floor(3*seg_len/2) - 1);
		V_conv(d-1, :) = v_ci_center;
		spec_d = abs(fftshift(fft(v_ci_center, nfft))).^2;
				max_powers(d-1) = max(spec_d(ST_W));
	end
	[~, best_d_idx] = max(max_powers);
		X_opt = V_conv(best_d_idx, :);
		if best_d_idx > 1
		X_sopt = V_conv(best_d_idx - 1, :);
	else
		X_sopt = V_conv(best_d_idx + 1, :);
	end
				Y_r = X_opt;
	if (cfg.apply_mclms)
		Y_r = mccf.mclms_filter(X_opt, X_sopt, mclms_len);
	end
	spec_mclms = abs(fftshift(fft(Y_r, nfft))).^2;
	spec_mclms = spec_mclms / max(spec_mclms);
	mclms_denoised_spectra(r, :) = spec_mclms;
				if r == 1
				avg_conv = mean(V_conv, 1);
		final_spectr = abs(fftshift(fft(avg_conv, nfft))).^2;
		[~, selected_peak_idx] = max(final_spectr);
	else
		ST_W_spec = spec_mclms(ST_W);
		M_rmax = max(ST_W_spec);
		[pks, locs_in_stw] = findpeaks(ST_W_spec);
				valid_mask = pks >= 0.4 * M_rmax;
		cand_pks = pks(valid_mask);
		cand_locs = ST_W(locs_in_stw(valid_mask));
		if isempty(cand_locs)
			[~, max_rel_idx] = max(ST_W_spec);
			cand_locs = ST_W(max_rel_idx);
			cand_pks = M_rmax;
		end
				[cand_pks, sort_idx] = sort(cand_pks, 'descend');
		if length(cand_locs) > 3
			cand_locs = cand_locs(sort_idx(1:3));
			cand_pks = cand_pks(sort_idx(1:3));
		end
		best_cost = -inf;
		selected_peak_idx = cand_locs(1);
		for c = 1:length(cand_locs)
			cand_idx = cand_locs(c);
			cand_power = cand_pks(c);
						V_cost = 1 - abs((cand_idx - F0) * dv) / (alpha * max_shear);
						cost_val = w1 * V_cost + w2 * cand_power;
			cost_scores(r, cand_idx) = cost_val;
			if cost_val > best_cost
				best_cost = cost_val;
				selected_peak_idx = cand_idx;
			end
		end
	end
	F0 = selected_peak_idx;
	peaks_idx(r) = selected_peak_idx;
				l = selected_peak_idx;
	minI = l; maxI = l;
	while minI > 1 && spec_mclms(minI - 1) > 0
		minI = minI - 1;
	end
	while maxI < nfft && spec_mclms(maxI + 1) > 0
		maxI = maxI + 1;
	end
end
fmax = (nfft/2) / (nfft * beam.ipp_us * 1e-6 * beam.n_coh);
beam.M1 = rescale(peaks_idx, -fmax, fmax, InputMax=1024, InputMin=1);
beam.denoised_spectra = mclms_denoised_spectra;
beam.a_params.mccf_cost_scores = cost_scores;
beam.a_params.mccf_ST_W = ST_W_array;
beam.a_params.peaks_idx = peaks_idx;
new_beam = beam;
end
```

=== IME
```
% entry point
function beam = estimate_params(beam, cfg)
arguments (Input)
	beam RadarData
	cfg.vel_axis (1, :) double
end
arguments (Output)
	beam RadarData
end
if isempty(beam.noise_level)
	beam.noise_level = ime.HS_noise_estimate(beam.spectra, beam.in_coh);
end
candidates = ime.get_candidate_peaks(beam.denoised_spectra, beam.noise_level, cfg.vel_axis);
delta_R = 3.0e8 * beam.m_fBaudLength_us * 1e-6 / 2;
profile = ime.trace_profile(candidates, beam.m_fOffZenith, delta_R);
beam.M1 = profile.velocity / (3e8 / 205e6 / 2);
beam.a_params.ime_candidates = candidates;
beam.a_params.ime_radial_vel = profile.velocity;
beam.a_params.ime_power = profile.power;
beam.a_params.ime_snr_db = profile.snr_db;
end

function noise_level = HS_noise_estimate(spectra, in_coh)
arguments(Input)
	spectra (:, 1024) double
	in_coh (1,1) double
end
arguments(Output)
	noise_level (1, :) double
end
[numRangeBins, N] = size(spectra);
noise_level = zeros(1, numRangeBins);
if in_coh < 1
	in_coh = 1;
end
for r = 1:numRangeBins
	A = sort(spectra(r, :), 'ascend');
	n = (1:N);
	Pn = cumsum(A) ./ n;
	secondMoment = cumsum(A.^2) ./ n;
	Qn = secondMoment - Pn.^2;
	Qn(Qn <= 0) = NaN;
	Rn = (Pn.^2) ./ (in_coh .* Qn);
	valid = find(Rn > 1);
	if isempty(valid)
		k = max(1, round(0.1*N));
	else
		k = max(valid);
	end
	noise_level(r) = Pn(k);
end
end

function candidates = get_candidate_peaks(Pclean, noise_level, vel_axis)
[numRangeBins, nfft] = size(Pclean);
candidates = cell(numRangeBins, 1);
total_bandwidth = max(vel_axis) - min(vel_axis);
half_width = (0.20 * total_bandwidth) / 2;
previous_velocity = NaN;
for r = 1:numRangeBins
	P = Pclean(r, :);
	Sn = noise_level(r);
	if r == 1
		[~, peak_idx] = max(P);
		center_velocity = vel_axis(peak_idx);
	else
		center_velocity = previous_velocity;
	end
	lower_velocity = center_velocity - half_width;
	upper_velocity = center_velocity + half_width;
	idx_window = find(vel_axis >= lower_velocity & vel_axis <= upper_velocity);
	if isempty(idx_window)
		candidates{r} = struct([]);
		continue;
	end
	Pworking = P(idx_window);
	selected = struct('idx', {}, 'velocity', {}, 'power', {}, 'snr_db', {}, 'width', {});
	for p = 1:3
		if isempty(Pworking), break; end
		[max_amp, local_idx] = max(Pworking);
		if max_amp <= 0, break; end
		left = local_idx;
		while left > 1 && Pworking(left-1) > 0
			left = left - 1;
		end
		right = local_idx;
		while right < length(Pworking) && Pworking(right+1) > 0
			right = right + 1;
		end
		P_peak = Pworking(left:right);
		V_peak = vel_axis(idx_window(left:right));
		total_peak_power = sum(P_peak);
		mean_velocity = sum(P_peak .* V_peak) / total_peak_power;
		if Sn > 0
			total_noise_power = Sn * nfft;
			snr_linear = total_peak_power / total_noise_power;
		else
			snr_linear = Inf;
		end
		snr_db = 10 * log10(snr_linear);
		if snr_db <= 0, break; end
		newCandidate.idx = idx_window(local_idx);
		newCandidate.velocity = mean_velocity;
		newCandidate.power = total_peak_power;
		newCandidate.snr_db = snr_db;
		newCandidate.width = (right - left + 1);
		selected(end+1) = newCandidate;
		Pworking(left:right) = 0;
	end
	candidates{r} = selected;
	if ~isempty(selected)
		velocities = [selected.velocity];
		[~, closest] = min(abs(velocities - center_velocity));
		previous_velocity = velocities(closest);
	else
		if r == 1
			previous_velocity = center_velocity;
		end
	end
end
end

function profile = trace_profile(candidates, off_zenith, delta_R)
numRangeBins = length(candidates);
profile = struct('velocity', zeros(1, numRangeBins), ...
	'power', zeros(1, numRangeBins), ...
	'snr_db', zeros(1, numRangeBins));
w1 = 0.4;
w2 = 0.6;
group_size = 5;
delta_vm = max(0.5, 0.05 * sind(off_zenith) * delta_R);
for g = 1:ceil(numRangeBins / group_size)
	start_bin = (g - 1) * group_size + 1;
	end_bin = min(g * group_size, numRangeBins);
	bins_in_group = end_bin - start_bin + 1;
	cost_dp = cell(bins_in_group, 1);
	path_dp = cell(bins_in_group, 1);
	peaks_curr = candidates{start_bin};
	num_peaks = length(peaks_curr);
	if num_peaks == 0
		cost_dp{1} = 0;
		path_dp{1} = {1};
		peaks_curr = struct('velocity', NaN, 'power', NaN, 'snr_db', NaN);
		candidates{start_bin} = peaks_curr;
	else
		snr_max = max([peaks_curr.snr_db]);
		if snr_max <= 0, snr_max = 1; end
		cost_dp{1} = zeros(num_peaks, 1);
		path_dp{1} = num2cell(1:num_peaks)';
		for p = 1:num_peaks
			P_rj = peaks_curr(p).snr_db / snr_max;
			cost_dp{1}(p) = w2 * P_rj;
		end
	end
	for i = 2:bins_in_group
		r = start_bin + i - 1;
		peaks_prev = candidates{r-1};
		peaks_curr = candidates{r};
		if isempty(peaks_curr)
			peaks_curr = struct('velocity', NaN, 'power', NaN, 'snr_db', NaN);
			candidates{r} = peaks_curr;
		end
		num_prev = length(peaks_prev);
		num_curr = length(peaks_curr);
		snr_max = max([peaks_curr.snr_db]);
		if snr_max <= 0, snr_max = 1; end
		new_cost_dp = zeros(num_curr, 1);
		new_path_dp = cell(num_curr, 1);
		for c = 1:num_curr
			max_path_cost = -inf;
			best_prev_idx = 1;
			P_rj = peaks_curr(c).snr_db / snr_max;
			for p = 1:num_prev
				if isnan(peaks_curr(c).velocity) || isnan(peaks_prev(p).velocity)
					x = inf;
				else
					x = abs(peaks_curr(c).velocity - peaks_prev(p).velocity);
				end
				if x <= delta_vm
					T_x = 1;
				elseif x <= 2 * delta_vm
					T_x = (2 * delta_vm - x) / delta_vm;
				else
					T_x = 0;
				end
				transition_cost = w1 * T_x + w2 * P_rj;
				total_cost = cost_dp{i-1}(p) + transition_cost;
				if total_cost > max_path_cost
					max_path_cost = total_cost;
					best_prev_idx = p;
				end
			end
			new_cost_dp(c) = max_path_cost;
			new_path_dp{c} = [path_dp{i-1}{best_prev_idx}, c];
		end
		cost_dp{i} = new_cost_dp;
		path_dp{i} = new_path_dp;
	end
	[~, best_final_idx] = max(cost_dp{bins_in_group});
	best_path = path_dp{bins_in_group}{best_final_idx};
	for i = 1:bins_in_group
		r = start_bin + i - 1;
		selected_peak_idx = best_path(i);
		chosen_peak = candidates{r}(selected_peak_idx);
		profile.velocity(r) = chosen_peak.velocity;
		profile.power(r)    = chosen_peak.power;
		profile.snr_db(r)   = chosen_peak.snr_db;
	end
end
end
```
== Presentation Slides
#align(center)[
  #let exclude = (3,4,7,13,18,28);
  #grid(
    columns: 2,
    row-gutter: 10pt,
    ..for i in range(1, 29) {
      if (i not in exclude) {
        (
          block(
            image("slides/" + str(i) + ".pdf", width: 100% - 5pt),
            stroke: .5pt,
          ),
        )
      }
    }
  )
]
