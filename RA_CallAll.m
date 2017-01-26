% Invokes all four blocks for the day's fMRI display in correct order.
%
% Main function for invoking the day's fMRI display. Counterbalances order
% across subjects according to experimental protocol. If a particular part
% fails, it is easy to fall back on the subfunction.
%
% @param integer subject_id The assigned ID of the subject 
% @param integer day Day of scanning (can only be 1 or 2)

function RA_CallAll(subject_id, day);

startGains = (mod(subject_id, 2) == 0)

if (day == 1)
  if startGains
    RA_Gains1_v6(subject_id)
    RA_Loss1_v6(subject_id)
  else
    RA_Loss1_v6(subject_id)
    RA_Gains1_v6(subject_id)
  end
end

if (day == 2)
  if startGains
    RA_Loss2_v6(subject_id)
    RA_Gains2_v6(subject_id)
  else
    RA_Gains2_v6(subject_id)
    RA_Loss2_v6(subject_id)
  end
end
end

% Wrapper to RA_CallAll that invokes Day 1 blocks
function RA_CallDay1(subject_id);
RA_CallAll(subject_id, 1)
end

% Wrapper to RA_CallAll that invokes Day 2 blocks
function RA_CallDay2(subject_id);
RA_CallAll(subject_id, 2)
end
