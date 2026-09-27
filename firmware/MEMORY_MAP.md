# Firmware Memory Map

This is a map of the internal RAM locations and register usage visible in the current firmware.

## Internal RAM

|Address|Purpose|
|-|-|
|`00H-05H`|Six-byte live clock field used by the normal timekeeping logic|
|`0FH`|Temporary saved PSW during Timer0 ISR execution|
|`17H`|Saved PSW when entering the mode-setting UI|
|`31H-36H`|Six-byte alarm field|
|`45H-4AH`|Six reference/position values used by the setting UI|
|`50H+`|Stack region after `SP` is initialized to `50H`|

## Register-bank usage

The PSW register-bank bits are `RS1:RS0` (`PSW.4:PSW.3`).

|Bank|RS1:RS0|Intended role in this firmware|
|-|-|-|
|Bank 0|`00`|Normal clock/timekeeping registers `R0-R7`|
|Bank 1|`01`|Alarm comparison loop uses R0/R1 as pointers and R5 as loop counter|
|Bank 2|`10`|Mode-setting/user-interface routines|
|Bank 3|`11`|Not intentionally used as a long-lived application bank|

## Important aliasing detail

On the 8051, `R0-R7` are physical RAM-backed registers whose addresses depend on the selected register bank. That is why changing `PSW.3/PSW.4` changes what `R0`, `R1`, etc. refer to.

For example:

```text
Bank 0 -> R0 = RAM 00H
Bank 1 -> R0 = RAM 08H
Bank 2 -> R0 = RAM 10H
Bank 3 -> R0 = RAM 18H
```

