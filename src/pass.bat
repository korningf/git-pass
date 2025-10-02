@echo off

@rem $env:PATHEXT+=';.PS1;'
@powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0\pass.ps1" %*

@echo ""