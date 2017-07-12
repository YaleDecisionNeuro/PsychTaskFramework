# Case study: creating SODM from MDM

You can see the progress as it happened documented in [issue #51](https://github.com/YaleDecisionNeuro/PsychTaskFramework/issues/51).

## Initial inventory

Here’s what MDM already had: 

* both monetary and medical lotteries with symbols to accompany the written descriptions of outcomes
* counterbalancing based on subject ID
* generating a complicated series of trials
* all the other standard stuff: set up, tear down, and running a number of blocks

## Plan of changes

To get to the SODM specification, I needed to do the following:

* create a domain-by-beneficiary 2x2 conditional setup with its own counterbalancing
* shorten the intertemporal intervals to a constant fraction of a second
* display the beneficiary condition of the block (“self” or “friend”) during the choice
* register the choice while the options are being displayed, rather than displaying a separate prompt
* run practice for four blocks rather than two

## Specific changes
### Generating blocks for each condition

([See *Generating blocks* for the general approach](../Generating-blocks.md).)

Since the trials generated for the 2 beneficiary conditions have the same properties, I could get away with reusing the domain-specific configuration and assigning the beneficiary commission on-the-fly.

Furthermore, to make the generation code easier, I used the catch trial generation setting.

### Counterbalancing

Admittedly, counterbalancing has always been the most confusing part of the code. The addition of a new condition makes it even more confusing.

To understand the edits, let's go through the original MDM code first.

#### Original code in MDM

```matlab
% MDM.m
% 4. Determine and save the order of blocks
lastDigit = mod(Data.subjectId, 10);
medFirst = ismember(lastDigit, [1, 2, 5, 6, 9]);
medIdx = [1 1 0 0];
if ~medFirst
  medIdx = 1 - medIdx; % flip
end

numBlocks = length(medIdx);
Data.numFinishedBlocks = 0;
for blockIdx = 1:numBlocks
  blockKind = medIdx(blockIdx);
  withinKindIdx = sum(medIdx(1 : blockIdx) == blockKind);
  if blockKind == 1
    Data = addGeneratedBlock(Data, medBlocks{withinKindIdx}, medConfig);
  else
    Data = addGeneratedBlock(Data, monBlocks{withinKindIdx}, monConfig);
  end
end
```

Let's go over what's going on here. The counterbalancing assignment is decided on the basis of the last digit of the subject ID; `medFirst` is true or false depending on whether the subject falls into a predefined pool that starts with the medical block.

`medIdx` is the confusing part. Here's what it does: for each of the 4 blocks, *it stores whether the blocks are medical or not*. That means that to find out if the third block is medical, I'd have to check if `medIdx(3) == 1`.

It might not be immediately clear that `medIdx = 1 - medIdx` flips the ordering. A clearer way of expressing that would be `medIdx = ~medIdx` - that is, to negate each value in the array, or even:

```matlab
if medFirst
  medIdx = [1 1 0 0];
else
  medIdx = [0 0 1 1];
end
```

Finally, we iterate through the created blocks - but since we created the blocks separately for each condition, we need to check if the next block to assign should be the next unassigned medical block, or the next unassigned monetary block. What's more, we have to figure out at which position the next block to be assigned is in those separate variables. That's what's going on here:

```matlab
blockKind = medIdx(blockIdx);
withinKindIdx = sum(medIdx(1 : blockIdx) == blockKind);
```
`blockKind` finds out what kind of a block should be assigned at this point. (A better name for the variable, perhaps, would be `assignMedical`.)  But it's the next line that's confusing. Let's break it down:

* `medIdx(1 : blockIdx)` subsets the block assignments from the first one to the current one.
* `medIdx(1 : blockIdx) == blockKind` changes each item that's the condition as the block to be assigned into 1 and the rest to 0. *It only does that in that subset of `medIdx`, though.* 
* `sum(medIdx(1 : blockIdx) == blockKind)` counts up how many blocks of the current condition will have been assigned after this one is. In other words, how many blocks into the set of all blocks do we have to go to get the block that we want to assign?
* Now, `withinKindIdx` will hold the correct index of the next block to be assigned, no matter which pile of blocks it's coming from.

Again, this is too smart by half. The alternative approach would keep track of `medicalAssignedSoFar`, increment it anytime a medical block was to be assigned, and obtain it with `medBlocks{medicalAssignedSoFar}`. (Ditto with `monetaryAssignedSoFar`.) The initial implementation works for conditions that have more than two variants, but it could use with more abstraction.

Finally, we add the correct block to the `DataObject`. 

```matlab
  if blockKind == 1
    Data = addGeneratedBlock(Data, medBlocks{withinKindIdx}, medConfig);
  else
    Data = addGeneratedBlock(Data, monBlocks{withinKindIdx}, monConfig);
  end
```

Note that we are also adding the configuration that is associated with this condition. That's because the configuration knows:

* what the current `screenId` is,
* what textures to use to illustrate the payoffs for this particular condition,
* and any other differences between the conditions.

This is a useful reminder that even though there are task-specific fields in the configuration, really, it functions as a configuration for a particular block in a particular condition.

#### Changes to implement SODM

Now, we can apply the same concept, but we are creating eight blocks and we have two conditions to keep track of. 

```matlab
% SODM.m
sortOrder = mod(Data.subjectId, 4);
selfIdx = [1 0 1 0]; % 0 is friend, 1 is self
medIdx = [1 1 0 0];  % 0 is monetary, 1 is medical

switch sortOrder
  case 0
    % Keep order
  case 1
    selfIdx = 1 - selfIdx;
  case 2
    medIdx = 1 - medIdx;
  case 3
    selfIdx = 1 - selfIdx;
    medIdx = 1 - medIdx;
end
```

Notice that we narrowed down the sixteen possible orderings to four. That's because each of these decisions cuts that 16 in half:

* maintain "self-other" order across block types (i.e. never doing `med-self med-other mon-other mon-self`)
* maintain block-kind contingency (i.e. never doing `med-self mon-self med-other mon-other`)

You could make things more complex, but it's unclear whether that amount of order independence is significantly greater than what we have now.

Also, with 8 blocks instead of 4, we'd actually have 16^2 combinations - or, if we repeated the initial logic, 16 again. To maintain ease of analysis and peace of mind, though, will just repeat the order that we came up with for the first 4 blocks.

```matlab
% Repeat the order for the second round
selfIdx = repmat(selfIdx, 1, 2);
medIdx = repmat(medIdx, 1, 2);
```

Finally, as we load the blocks into the Data Object, we assign the beneficiary condition on-the-fly:

```matlab
% Logic: Do mon/med blocks first, pass self/other to them depending on selfIdx
beneficiaryLookup = {'Friend', 'Self'};
numBlocks = length(selfIdx);
Data.numFinishedBlocks = 0;
for blockIdx = 1:numBlocks
  blockKind = medIdx(blockIdx);
  beneficiaryKind = selfIdx(blockIdx);
  beneficiaryStr = beneficiaryLookup{beneficiaryKind + 1}; % 0 (FALSE) -> 1st element in array
  withinKindIdx = sum(medIdx(1 : blockIdx) == blockKind);

  if blockKind == 1
    medConfig.runSetup.conditions.beneficiary = beneficiaryStr;
    Data = addGeneratedBlock(Data, medBlocks{withinKindIdx}, medConfig);
  else
    monConfig.runSetup.conditions.beneficiary = beneficiaryStr;
    Data = addGeneratedBlock(Data, monBlocks{withinKindIdx}, monConfig);
  end
end
```

There is no reason why the on-the-fly assignment needs to happen — it would be just as good to create separate config objects `medSelfConfig`, `monSelfConfig`, `medOtherConfig`, and `monOtherConfig`. Since the beneficiary is really the only difference, though, we can get away with this.

So that's it! On the whole, not magic.

### Changing phase settings
### Displaying the beneficiary condition
### Changing practice settings
