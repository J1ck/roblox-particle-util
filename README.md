# roblox-particle-util
Particle Utility Plugin for Roblox

## Selection Modes
|Name|Description|
|--|--|
|Default|Will only select particles that you are directly selecting|
|Children|Will also select particles that are a child of anything youre selecting|
|Descendants|Will also select particles that are a descendant of anything youre selecting|

## Usage
When youre selecting atleast 1 particle, this UI will show up in the top left of your viewport:
![image](https://github.com/J1ck/roblox-particle-util/assets/88492622/ece619b9-2f9a-4bf8-8a7e-6db6edcffabf)

You can input an Emit Count and a Delay Time, and it will set the Emit Count and Delay Time of every selected particle.
If you have multiple particles selected with different Emit Count's or Delay Time's, the prompt will show "..." instead.
Pressing the Emit button will emit every particle selected, taking their Emit Count and Delay Time into account.

Clicking the Selection Mode button will cycle through all available Selection Modes.

## Code Usage
Each particle's Emit Count and Delay Time are stored in attributes for programmers to use as "EmitCount" and "DelayTime" respectively.
If you havent interacted with a particle using the plugin, the attributes will not be there.

Example:
```lua
for _, Particle : ParticleEmitter in Object:GetDescendants do
  if Particle:IsA("ParticleEmitter") == false then
    continue
  end
  
  local DelayTime : number = Particle:GetAttribute("DelayTime") or 0
  local EmitCount : number = Particle:GetAttribute("EmitCount") or 1
  
  task.delay(DelayTime, Particle.Emit, Particle, EmitCount)
end
```
