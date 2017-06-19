@echo off
rem Reinstall the latest puppet module on local
rem A handy script for debugging the puppet module

cmd /c puppet module uninstall puppet-unity
cmd /c puppet module build
cmd /c puppet module install ".\pkg\puppet-unity-0.1.0.tar.gz"  --ignore-dependencies
