%%%%%%%% Initial Quantites %%%%%%
monomer_to_polymer_rate = 0.001;            % percent monomer to polymer conversion per cycle  - DeGuzman et al. 
initial_monomer_mass = 100;                 % initial monomer mass in grams
initial_polymer_mass = 0;                   % initial polymer mass in grams
initial_degraded_monomer = 0;               % initial monomer degraded by depurination
initial_degraded_polymer = 0;
wet_cycle_time = 120;                       % wet cycle time between 1 and 2 minutes  - DaSilva et al. 
dry_cycle_time = 1800;                      % Dry cycle time 30 min.  Thus dry = 30 x 60 = 1800 sec.  - DaSilva et al. 
hydrolysis_rate = 0.000001 ;                % Hydrolysis rate: 1.0 x 10^-6 S^-1   - Ross et al. 
hydrolysis_factor = wet_cycle_time * hydrolysis_rate;
monomer_depurination_rate = 0.12;           % rate of monomer depurination    - From Ryan
monomer_repurination_rate = 0.04;                   % rate of degraded monomer repurination    - From Ryan
polymer_depurination_rate = 0.012;
polymer_repurination_rate = 0.004;
n = 40000;                                  % cycle count  

 

% Wet cycle matrix :  |1    D_p      0    0| 
%                     |0  1-H-D_p    0    0|
%                     |0     H     1-D_m  0|
%                     |0     0      D_m   1|
%
wet_cycle_matrix = [1, polymer_depurination_rate, 0, 0;
                    0, 1-hydrolysis_factor-polymer_depurination_rate, 0, 0; 
                    0, hydrolysis_factor, 1-monomer_depurination_rate, 0;
                    0, 0, monomer_depurination_rate, 1];              
     
                   
% dry cycle matrix:  |1-R_p  0   0     0  |
%                    | R_p   1   M     0  |
%                    |0      0  1-M   R_m |
%                    |0      0   0   1-R_m|
%
dry_cycle_matrix = [1-polymer_repurination_rate, 0, 0, 0;
                    polymer_repurination_rate, 1, monomer_to_polymer_rate, 0; 
                    0, 0, 1-monomer_to_polymer_rate, monomer_repurination_rate;
                    0, 0, 0, 1-monomer_repurination_rate];               
                
                
% reaction vector:   | dp |
%                    |  p |
%                    |  m |
%                    | dm |
%
reaction_vector = [initial_degraded_polymer;
                   initial_polymer_mass; 
                   initial_monomer_mass;
                   initial_degraded_monomer];                 

                
% Needed quantitiy lists
polymers = zeros(1,n);                % list of polymer quantities 
polymers(1) = initial_polymer_mass;
monomers = zeros(1,n);                % list of monomer quantities
monomers(1) = initial_monomer_mass; 
count = zeros(1,n);                   % x-axis of graph
count(1) = wet_cycle_time;

% Cycle Times:  wet = 1.5 minutes, dry = 30 minutes   -DaSilva et al. 

% Reaction Cycle
for i = 1:n
    if mod(i,2) ~= 0
        % dry cycle opperations:
        count(i+1) = count(i) + dry_cycle_time;
        reaction_vector = dry_cycle_matrix*reaction_vector; 
    else                
        % wet cycle opperations: 
        count(i+1) = count(i) + wet_cycle_time;
        reaction_vector = wet_cycle_matrix*reaction_vector;
    end
    
    % add new values to quantity lists
    polymers(i+1) = reaction_vector(2);
    monomers(i+1) = reaction_vector(3);
   
end


%%%%% Print list quantities %%%%%%
% disp(size(polymers));
% disp(size(monomers));
% disp(size(count)); 

%%%%%% Build Figure (Continues) %%%%%%%
% plot monomer and polymer quantities (overlayed)
figure, plot(count(:), polymers(:));
hold on;
plot(count(:), monomers(:));

xlabel('Time (s)');
ylabel('Mass');
legend('Polymer ', ...
    'Monomer');

%%%%%% Build Figure (Discrete) %%%%%%%
% discrete plot of monomer and polymer quantities  
figure, scatter(count(:), polymers(:), '.');
hold on; 
scatter(count(:), monomers(:), '.'); 


xlabel('Time (s)');
ylabel('Mass');
legend('Polymer ', ...
    'Monomer');