# Contributing to DiscordBM

All contributions are welcome, but must follow the rules below.

## Semantic Versioning 
DiscordBM follows Semantic Versioning 2.0.0, with exceptions: https://github.com/MahdiBM/DiscordBM#versioning   
Following Semantic Versioning means that any changes to the source code that can cause existing code to stop compiling must wait until the next major version to be included.   

## Code style
This list is not complete and I'll update this as time goes on. The current rules are:
* Don't change Discord's snake-case property names to camel-case in an attempt to make the names more "Swifty".
* Prefer to use explicit `self`. For example, prefer `self.doSomething()` over `doSomething()`.
