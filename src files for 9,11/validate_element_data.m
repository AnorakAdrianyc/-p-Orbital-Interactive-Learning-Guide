function validate_element_data()

E = corrected_element_data();

assert(numel(E) == 118, ...
    'Element dataset must contain exactly 118 records.');

assert(element_Z(E, 'H')  == 1);
assert(element_Z(E, 'C')  == 6);
assert(element_Z(E, 'Fe') == 26);

assert(element_Z(E, 'La') == 57);
assert(element_Z(E, 'Ce') == 58);
assert(element_Z(E, 'Lu') == 71);

assert(element_Z(E, 'Hf') == 72);
assert(element_Z(E, 'Ta') == 73);
assert(element_Z(E, 'Au') == 79);
assert(element_Z(E, 'Rn') == 86);

assert(element_Z(E, 'Ac') == 89);
assert(element_Z(E, 'Th') == 90);
assert(element_Z(E, 'Lr') == 103);

assert(element_Z(E, 'Rf') == 104);
assert(element_Z(E, 'Og') == 118);

assert(numel(unique([E.Z])) == 118, ...
    'Atomic-number entries must be unique.');

assert(all(sort([E.Z]) == 1:118), ...
    'Atomic-number sequence must contain every value from 1 through 118.');

disp('Validation passed: all 118 elements have correct explicit atomic numbers.');
end

function Z = element_Z(E, symbol)

idx = find(strcmp({E.symbol}, symbol), 1);

assert(~isempty(idx), ...
    'Element symbol %s was not found.', symbol);

Z = E(idx).Z;
end