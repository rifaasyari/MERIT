function [signals_] = delay(signals, delays, axis_)
  % delay signals (in time or frequency domain) by delays.
  %
  % td_ = merit.process.delay(td, delays);
  %   td: must be real
  %   delays: 1 x C x ... array of sample delays
  %     will be expanded to the number of dimensions of td
  %
  % signals_ = merit.process.delay(signals, delays, axis);
  %   if signals is real:
  %     signals are the time domain signals
  %     delays: in seconds
  %     axis: must match first dimension of signals, provides sampling information
  %   else signals are complex:
  %     signals are in the frequency domain
  %     delays: in seconds
  %     axis: match the first dimension of signals, frequency of each point.

  dim_size = size(signals);
  delays = merit.utility.expand(delays, reshape(signals(1, :), [1, dim_size(2:end)]));

  if isreal(signals)
    %% Time domain
    if nargin == 2
      %% time domain, delay in samples
      signals_ = merit.utility.reshape2d(@delay_sample, signals, delays);
    elseif narargin == 3
      %% Time axis provided
      validateattributes(axis_, {'numeric'},...
        {'vector', 'increasing', 'real'});
      if ~merit.utility.linearlysampled(axis_)
        error('merit:process:delay', 'Time axis needs to be linearly sampled');
      end
      dt = diff(axis_(1:2));
      signals_ = merit.utility.reshape2d(@delay_sample, signals, delays.*dt);
    end
  elseif ~isreal(signals) && nargin == 3
    %% Frequency domain
    signals_ = signals .* exp(2*j*pi*bsxfun(@times, delays, axis_(:)));
  else
    signals_ = signals;
  end
end

function [signals_] = delay_sample(signals, delays)
  signals_ = nan(size(signals), 'like', signals);
  signals_(:, delays==0) = signals(:, delays==0);

  for d = unique(delays),
    cs = delays == d;
    if d > 0
      signals_(d+1:end, cs) = signals(1:end-d, cs);
    else
      signals_(1:end+d,cs) = signals(1-d:end, cs);
    end
  end
end