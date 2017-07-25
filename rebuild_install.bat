@echo off
rem Reinstall the latest puppet module on local
rem A handy script for debugging the puppet module

cmd /c puppet module uninstall dellemc-unity
cmd /c puppet module build
cmd /c puppet module install ".\pkg\dellemc-unity-0.1.1.tar.gz"  --ignore-dependencies
